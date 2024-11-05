local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/wx_scanner.zip"),
    Asset("ANIM", "anim/galeboss_katash_skymine.zip"),
}


local function RetargetFn(inst)
    return FindEntity(
        inst,
        8,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat", "_health" },
        { "INLIMBO", "prey", "katash" },
        { "character", }
    )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, 33)
end

local function OnAttacked(inst, data)
    if data.attacker and not data.attacker:HasTag("katash") then
        inst.components.combat:SuggestTarget(data.attacker)
    end
end

local function SetVel(inst, vel)
    local predict_pos = inst:GetPosition() + vel
    local lx, ly, lz = inst.entity:WorldToLocalSpace(predict_pos.x, 0, predict_pos.z)
    inst.Physics:SetMotorVel(lx, 0, lz)
end

local function AddVelocity(inst, vel)
    local cur_vel = Vector3(inst.Physics:GetVelocity())
    local next_vel = cur_vel + vel
    inst:SetVel(next_vel)

    return next_vel
end

local function EnableBeep(inst, period)
    if inst.beep_task then
        inst.beep_task:Cancel()
        inst.beep_task = nil
    end
    if inst.not_red_task then
        inst.not_red_task:Cancel()
        inst.not_red_task = nil
    end
    inst.AnimState:SetAddColour(0, 0, 0, 0)

    if period and period >= 0 then
        local red_keep_time = 2 * FRAMES
        period = math.max(period, red_keep_time + FRAMES)
        inst.beep_task = inst:DoPeriodicTask(period, function()
            inst.SoundEmitter:PlaySound(inst.sounds.beep)
            inst.AnimState:SetAddColour(1, 0, 0, 1)
            if inst.not_red_task then
                inst.not_red_task:Cancel()
            end
            inst.not_red_task = inst:DoTaskInTime(red_keep_time, function()
                inst.AnimState:SetAddColour(0, 0, 0, 0)
                inst.not_red_task = nil
            end)
        end)
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_katash_skymine",
        assets = assets,

        bank = "scanner",
        -- build = "wx_scanner",
        build = "galeboss_katash_skymine",
        anim = "idle",

        tags = { "mech" },

        clientfn = function(inst)
            inst.entity:AddDynamicShadow()
            inst.DynamicShadow:SetSize(1.2, 0.75)

            MakeTinyFlyingCharacterPhysics(inst, 1, 0.5)

            inst.Transform:SetFourFaced()

            inst.AnimState:Hide("top_light")
            inst.AnimState:Hide("bottom_light")
        end,

        serverfn = function(inst)
            inst.SetVel = SetVel
            inst.AddVelocity = AddVelocity
            inst.EnableBeep = EnableBeep

            inst:AddComponent("inspectable")

            inst:AddComponent("lootdropper")

            -- inst:AddComponent("locomotor")
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            -- inst.components.locomotor:SetTriggersCreep(false)
            -- inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
            -- inst.components.locomotor.walkspeed = 4
            -- inst.components.locomotor.runspeed = 6

            inst:AddComponent("combat")
            inst.components.combat.playerdamagepercent = 0.5
            inst.components.combat:SetRange(0.5, 3)
            inst.components.combat:SetDefaultDamage(70)
            inst.components.combat:SetAttackPeriod(1)
            inst.components.combat:SetRetargetFunction(3, RetargetFn)
            inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
            inst.components.combat:SetHurtSound("gale_sfx/battle/hit_metal")

            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(100)

            inst:SetStateGraph("SGgaleboss_katash_skymine")

            GaleCondition.AddCondition(inst, "condition_metallic")


            inst.sounds = {
                turn_on = "gale_sfx/battle/galeboss_katash_skymine/turn_on",
                turn_off = "gale_sfx/battle/galeboss_katash_skymine/turn_off",
                fail = "gale_sfx/battle/galeboss_katash_skymine/fail",
                spin = "gale_sfx/battle/galeboss_katash_skymine/spin",
                explo = "gale_sfx/battle/explode",
                -- explo = "gale_sfx/battle/p1_explode",
                beep = "gale_sfx/battle/galeboss_katash_skymine/beep",
            }

            inst:ListenForEvent("attacked", OnAttacked)


            -- inst.body = inst:SpawnChild("galeboss_katash_skymine_body")
            -- inst.body.entity:AddFollower()
            -- inst.body.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0, true, nil, 7)
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_katash_skymine_body",
        assets = assets,

        bank = "galeboss_katash_skymine",
        build = "galeboss_katash_skymine",
        anim = "debug_body",

        persists = false,

        tags = { "FX" },

        clientfn = function(inst)

        end,

        serverfn = function(inst)

        end,

    })
