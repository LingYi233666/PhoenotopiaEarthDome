local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")


local VELOCITY_THRESHOLD = 2
local SELECT_TARGET_DELTATIME = 1

local function CanAttack(inst, guy)
    return not GaleCommon.IsShadowCreature(guy)
end

local function RetargetFn(inst)
    return FindEntity(
        inst,
        15,
        function(guy)
            return CanAttack(inst, guy)
                and (guy.Physics and Vector3(guy.Physics:GetVelocity()):Length() > VELOCITY_THRESHOLD)
        end,
        nil,
        { "INLIMBO", "FX" }
    )
end

local function KeepTargetFn(inst, target)
    local leader = inst.components.follower:GetLeader()
    local target_vel = target and target.Physics and Vector3(target.Physics:GetVelocity()):Length()
    if target.Physics == nil then
        target_vel = 99999
    end

    return target ~= nil
        and target:IsValid()
        and (inst:IsNear(target, 8) or target_vel > VELOCITY_THRESHOLD)
        and (leader == nil or leader:IsNear(inst, 15))
end

local function OnNewTargetFound(inst)
    -- if inst.alert_sound_task then
    --     return
    -- end

    -- inst.alert_sound_task = inst:DoTaskInTime(GetRandomMinMax(0, 0.3), function()
    --     if inst.components.target and not inst.components.health:IsDead() then
    --         inst.SoundEmitter:PlaySound(inst.sounds.alert)
    --     end
    --     inst.alert_sound_task = nil
    -- end)
    inst.SoundEmitter:PlaySound(inst.sounds.alert)
end

local function SelectTargetManully(inst)
    if not inst.components.health:IsDead() then
        if inst.manual_select_target == nil
            and (
                inst.last_manual_select_time == nil
                or GetTime() - inst.last_manual_select_time > SELECT_TARGET_DELTATIME
            ) then
            inst.manual_select_target = RetargetFn(inst)
            inst.last_manual_select_time = GetTime()

            if inst.manual_select_target ~= nil then
                OnNewTargetFound(inst)
            end
        end

        if inst.manual_select_target ~= nil then
            if not KeepTargetFn(inst, inst.manual_select_target) then
                inst.manual_select_target = nil
            end
        end
    end
end



local function DoRandomIdleSound(inst)
    local function InterfaceFn(inst)
        if not IsEntityDead(inst, true) then
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
        end
        DoRandomIdleSound(inst)
    end

    if inst.random_noise_task then
        inst.random_noise_task:Cancel()
        inst.random_noise_task = nil
    end

    inst.random_noise_task = inst:DoTaskInTime(GetRandomMinMax(4, 8), InterfaceFn)
end


return GaleEntity.CreateNormalEntity({
        prefabname = "typhon_cystoid",

        assets = {
            Asset("ANIM", "anim/puffer.zip"),
        },

        tags = { "typhon", "shadow_aligned", "monster", "hositile", "scarytoprey", "thorny" },

        bank = "puffer",
        build = "puffer",
        anim = "idle",
        loop_anim = true,

        clientfn = function(inst)
            inst.entity:AddDynamicShadow()

            MakeCharacterPhysics(inst, 1, 0.2)

            inst.DynamicShadow:SetSize(0.3, .2)
            inst.Transform:SetTwoFaced()

            local s = 0.5
            inst.Transform:SetScale(s, s, s)

            -- inst.AnimState:SetMultColour(0, 0, 0, 0.9)
            local dark_symbol = {
                "cheek",
                "body",
                -- "mouth",
                "spike",
                -- "splash",
            }

            for _, v in pairs(dark_symbol) do
                inst.AnimState:SetSymbolMultColour(v, 0, 0, 0, 0.9)
            end

            -- inst.AnimState:SetSymbolMultColour("eye", 0, 0, 0, 1)
            inst.AnimState:SetSymbolMultColour("splash", 0, 0, 0, 0.6)

            -- inst.AnimState:SetSymbolAddColour("eye", 1, 1, 0, 1)
            inst.AnimState:SetSymbolLightOverride("eye", 1)

            inst.AnimState:HideSymbol("mouth")
        end,

        serverfn = function(inst)
            inst.manual_select_target = nil
            inst.CanAttack = CanAttack

            inst:AddComponent("inspectable")

            inst:AddComponent("follower")

            inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
            inst.components.locomotor.walkspeed = 4
            inst.components.locomotor.runspeed = 14
            -- boat hopping setup
            inst.components.locomotor:SetAllowPlatformHopping(true)

            inst:AddComponent("embarker")

            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(1)

            inst:AddComponent("combat")
            inst.components.combat.playerdamagepercent = 0.5
            inst.components.combat:SetRange(0.5, 2)
            inst.components.combat:SetDefaultDamage(10)
            inst.components.combat:SetAttackPeriod(3)


            inst:AddComponent("planardamage")
            inst.components.planardamage:AddBonus(inst, 3, "addition_damage")

            inst:AddComponent("lootdropper")


            inst:SetStateGraph("SGtyphon_cystoid")

            local brain = require("brains/typhon_cystoid_brain")
            inst:SetBrain(brain)


            inst.sounds = {
                idle = "gale_sfx/battle/typhon_cystoid/idle",
                alert = "gale_sfx/battle/typhon_cystoid/alert",
                explode_pre = "gale_sfx/battle/typhon_cystoid/explode_pre",
                explode = "gale_sfx/battle/typhon_cystoid/explode",
                land = "dontstarve/creatures/together/hutch/land",
            }


            DoRandomIdleSound(inst)
            inst:DoPeriodicTask(0, SelectTargetManully)
        end
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "typhon_cystoid_land_fx",
        assets =
        {
            Asset("ANIM", "anim/lavae_move_fx.zip"),
        },

        bank = "lava_trail_fx",
        build = "lavae_move_fx",
        anim = function()
            return "trail" .. tostring(math.random(1, 7))
        end,

        clientfn = function(inst)
            inst.AnimState:SetMultColour(0, 0, 0, 0.9)
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)

            inst.Transform:SetRotation(math.random(-180, 180))
        end,

    })
