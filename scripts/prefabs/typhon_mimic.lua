local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

SetSharedLootTable("typhon_mimic", {
    { "nightmarefuel",       1.00 },
    { "typhon_mimic_cancer", 0.33 },

})

SetSharedLootTable("typhon_mimic_higher", {
    { "nightmarefuel",       1.00 },
    { "typhon_mimic_cancer", 1.00 },
})

local function CanTarget(inst, target)
    return inst.components.combat:CanTarget(target)
        and not GaleCommon.IsShadowCreature(target)
end

local function CanMimic(inst, target)
    local result = not target.components.health
        and target.components.inventoryitem
        and inst.components.gale_skill_mimic:IsValidTarget(target, 1)

    if not result then
        return result
    end

    local anim_data = GaleCommon.GetAnim(target)
    if not (anim_data.anim
            and anim_data.bank
            and anim_data.build
            and anim_data.frame
            and anim_data.frame_all
            and anim_data.percent) then
        result = false
    end

    return result
end

local function IsBlockedOnPath(inst)
    local inst_pos = inst:GetPosition()
    local dest_pt = nil
    local locomotor_dest = inst.components.locomotor.dest
    local combat_target = inst.components.combat.target

    if locomotor_dest and locomotor_dest:IsValid() then
        dest_pt = Vector3(locomotor_dest:GetPoint())
    elseif combat_target then
        dest_pt = combat_target:GetPosition()
    end

    if dest_pt then
        return not (TheWorld.Map:IsPassableAtPoint(dest_pt.x, dest_pt.y, dest_pt.z)
            and TheWorld.Pathfinder:IsClear(inst_pos.x, inst_pos.y, inst_pos.z, dest_pt.x, dest_pt.y, dest_pt.z))
    end


    return false
end

local function RetargetFn(inst)
    return FindEntity(
        inst,
        8,
        function(guy)
            return CanTarget(inst, guy)
        end,
        { "_combat", "_health" },
        { "INLIMBO" },
        { "character", "prey", "animal", "smallcreature", "lunar_aligned" }
    )
end

local function KeepTargetFn(inst, target)
    local leader = inst.components.follower:GetLeader()

    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, 15)
        and (leader == nil or leader:IsNear(inst, 15))
end

local function CheckEmergencyEvade(inst)
    if inst.rankup_process then
        return
    end

    local hositile = FindEntity(
        inst,
        4,
        function(guy)
            return (
                    guy.components.combat
                    and (guy.components.combat:TargetIs(inst) or inst.components.combat:TargetIs(guy))
                    and guy.sg
                    and (
                        guy.sg:HasStateTag("attack")
                        or
                        (
                            guy.sg:HasStateTag("charging_attack")
                            and guy.sg:GetTimeInState() <= 1
                        )
                    )
                    and inst:IsNear(guy, guy.components.combat.hitrange + 1)
                )
                or (
                    guy.components.projectile
                    and guy.components.projectile.target == inst
                ) or (
                    guy.components.complexprojectile
                    and guy.components.complexprojectile.attacker == inst.components.combat.target
                ) or (
                    guy:HasTag("scarytomimic") or guy:HasTag("scarytotyphon")
                )
        end,
        nil,
        { "INLIMBO" }
    )


    if hositile
        and not IsEntityDead(inst, true)
        and not inst.sg:HasStateTag("evade")
        and not inst.sg:HasStateTag("jumping")
        and not inst.sg:HasStateTag("mimicing")
        and (
            (inst.last_evade_time == nil or GetTime() - inst.last_evade_time > 3)
            or (inst.components.combat.lastwasattackedtime and GetTime() - inst.components.combat.lastwasattackedtime < 0.33)
        ) then
        -- print("EmergencyEvade from",hositile)
        if hositile.components.combat then
            inst.components.combat:SuggestTarget(hositile)
        end

        local scary_pos = hositile:GetPosition()
        if hositile:HasTag("projectile") then
            local vec = hositile:GetPosition() - inst:GetPosition()
            local possible_offset = {}
            for i = 1, 360 do
                local cur_offset = Vector3(math.cos(i * DEGREES), 0, math.sin(i * DEGREES))
                local jia_angle = math.acos(cur_offset:Dot(vec) / (cur_offset:Length() * vec:Length()))
                if jia_angle > 180 * DEGREES then
                    jia_angle = jia_angle - 360 * DEGREES
                end
                if jia_angle < -180 * DEGREES then
                    jia_angle = jia_angle + 360 * DEGREES
                end -- control to [-180 * DEGREES,180 * DEGREES]

                if math.abs(jia_angle) >= 90 * DEGREES and math.abs(jia_angle) <= 135 * DEGREES then
                    table.insert(possible_offset, cur_offset)
                end
            end

            scary_pos = inst:GetPosition() + GetRandomItem(possible_offset)
        elseif hositile.components.combat and hositile.components.combat.hitrange >= 5 and inst:IsNear(hositile, inst.components.combat.hitrange + 1) then
            if math.random() <= 0.8 then
                scary_pos = nil
                inst.last_evade_time = GetTime()
            end
        end

        if scary_pos then
            inst.sg:GoToState("evade", scary_pos)
            inst.last_evade_time = GetTime()
        end
    end
end

local function OnHitOther(inst, data)
    if data.target then
        local hunger_dodelta = 3
        if data.target.components.sanity then
            local old_sanity = data.target.components.sanity.current
            data.target.components.sanity:DoDelta(-5)
            hunger_dodelta = hunger_dodelta + math.max(0, old_sanity - data.target.components.sanity.current)
        end

        inst.components.hunger:DoDelta(hunger_dodelta)
    end
end

local function OnAttacked(inst, data)
    if inst.rankup_process and data.attacker:HasTag("typhon") then
        return
    end

    if math.random() <= 0.66 then
        inst.last_leap_time = nil
    end

    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return dude:HasTag("typhon") and not IsEntityDead(dude, true)
    end, 10)
end

local function DoRandomIdleSound(inst)
    local function InterfaceFn(inst)
        if not IsEntityDead(inst, true) and not inst.sg:HasStateTag("mimicing") then
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



local function custom_stats_mod_fn(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
    if food.components.edible then
        health_delta = math.max(0, health_delta or 0)
        hunger_delta = math.max(0, hunger_delta or 0)
    elseif food.components.fuel and food.components.fuel.fueltype == FUELTYPE.NIGHTMARE then
        local percent = food.components.fuel.fuelvalue / (TUNING.TOTAL_DAY_TIME * 3)
        health_delta = inst.components.health.maxhealth * percent
        hunger_delta = inst.components.hunger.max * percent
    else
        health_delta, hunger_delta, sanity_delta = nil, nil, nil
    end


    return health_delta, hunger_delta, sanity_delta
end

local function SetLevel(inst, lv)
    lv = math.min(lv, 4)
    inst.level = lv

    inst.components.planardamage:AddBonus(inst, (inst.level - 1) * 3, "mimic_growth")
    local old_percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(125 + (inst.level - 1) * 15)
    inst.components.health:SetPercent(old_percent)
    if lv >= 3 then
        if not inst.components.planarentity then
            inst:AddComponent("planarentity")
        end
        if inst.higher_vfx == nil then
            inst.higher_vfx = inst:SpawnChild("typhon_mimic_higher_vfx")
            inst.higher_vfx.entity:AddFollower()
            inst.higher_vfx.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0, true)
        end
        -- inst.AnimState:SetMultColour(39 / 255, 0 / 255, 41 / 255, 1)
        inst.components.lootdropper:SetChanceLootTable("typhon_mimic_higher")
    end
end

local function OnSave(inst, data)
    data.level = inst.level
    data.old_health = inst.components.health.currenthealth
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.level ~= nil then
            inst:SetLevel(data.level)
        end
        if data.old_health ~= nil then
            inst.components.health:SetCurrentHealth(data.old_health)
        end
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "typhon_mimic",

        assets = {
            Asset("ANIM", "anim/ds_spider_basic.zip"),
            Asset("ANIM", "anim/typhon_mimic.zip"),
            Asset("ANIM", "anim/ds_spider_boat_jump.zip"),
        },

        tags = { "typhon", "shadow_aligned", "monster", "hositile", "scarytoprey" },

        bank = "spider",
        build = "spider_build",
        anim = "idle",

        clientfn = function(inst)
            inst.entity:AddDynamicShadow()

            MakeCharacterPhysics(inst, 10, .5)

            inst.DynamicShadow:SetSize(1.5, .5)
            inst.Transform:SetFourFaced()

            inst.AnimState:SetMultColour(0.1, 0.1, 0.1, 1)

            inst.AnimState:HideSymbol("face")
            inst.AnimState:OverrideSymbol("leg", "typhon_mimic", "leg")
        end,

        serverfn = function(inst)
            inst.CanTarget = CanTarget
            inst.CanMimic = CanMimic
            inst.IsBlockedOnPath = IsBlockedOnPath
            inst.SetLevel = SetLevel
            inst.level = 1

            inst:AddComponent("inspectable")

            inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
            inst.components.locomotor.walkspeed = 7
            inst.components.locomotor.runspeed = 12
            -- boat hopping setup
            inst.components.locomotor:SetAllowPlatformHopping(true)

            inst:AddComponent("embarker")

            inst:AddComponent("sanityaura")
            -- inst.components.sanityaura.aurafn = CalcSanityAura
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(125)
            inst.components.health.save_maxhealth = true
            inst.components.health.nofadeout = true

            inst:AddComponent("hunger")
            inst.components.hunger:SetMax(100)
            inst.components.hunger:SetRate(10 / TUNING.TOTAL_DAY_TIME)
            inst.components.hunger:SetPercent(GetRandomMinMax(0.1, 0.2))
            inst.components.hunger:SetOverrideStarveFn(function() end)

            inst:AddComponent("eater")
            inst.components.eater.eatwholestack = true
            inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
            inst.components.eater:SetCanEatHorrible()
            inst.components.eater:SetCanEatGears()
            inst.components.eater:SetStrongStomach(true) -- can eat monster meat!
            inst.components.eater:SetCanEatRaw()
            inst.components.eater.custom_stats_mod_fn = custom_stats_mod_fn

            inst:AddComponent("inventory")
            inst.components.inventory.maxslots = 1

            inst:AddComponent("combat")
            inst.components.combat.playerdamagepercent = 0.5
            inst.components.combat:SetRange(3)
            inst.components.combat:SetDefaultDamage(33)
            inst.components.combat:SetAttackPeriod(3)
            inst.components.combat:SetRetargetFunction(3, RetargetFn)
            inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

            inst:AddComponent("planardamage")

            inst:AddComponent("areaaware")

            -- 需要消耗灵能
            inst:AddComponent("gale_magic")

            -- 拟态当然会拟态（确信）
            inst:AddComponent("gale_skill_mimic")

            inst:AddComponent("follower")

            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("typhon_mimic")



            inst.OnSave = OnSave
            inst.OnLoad = OnLoad


            inst:SetStateGraph("SGtyphon_mimic")

            local brain = require("brains.typhon_mimic_brain")
            inst:SetBrain(brain)

            inst:DoPeriodicTask(0, CheckEmergencyEvade)

            inst:ListenForEvent("onhitother", OnHitOther)
            inst:ListenForEvent("attacked", OnAttacked)

            inst.sounds = {
                idle = "gale_sfx/battle/typhon_mimic/idle",
                hit = "gale_sfx/battle/typhon_mimic/hurt",
                taunt = "gale_sfx/battle/typhon_mimic/taunt",
                step = "gale_sfx/battle/typhon_mimic/step",
                evade = "gale_sfx/battle/typhon_mimic/evade",

                attack = "gale_sfx/battle/typhon_mimic/attack",
                attack_jump = "gale_sfx/battle/typhon_mimic/attack_jump",
                death = "gale_sfx/battle/typhon_mimic/death",

                eat = "gale_sfx/battle/typhon_mimic/eat",

                transform = "gale_sfx/battle/typhon_mimic/transform",
                multiply = "gale_sfx/battle/typhon_mimic/multiply",
                rankup = "gale_sfx/battle/typhon_mimic/rankup",
            }

            DoRandomIdleSound(inst)
            inst:SetLevel(math.random(1, 2))
        end
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "typhon_mimic_rankup_splash",
        assets = {},
        bank = "Bubble_fx",
        build = "crab_king_bubble_fx",
        anim = "waterspout",
        clientfn = function(inst)
            inst.AnimState:SetMultColour(0, 0, 0, 0.9)
            inst.AnimState:SetFinalOffset(1)
        end,
        serverfn = function(inst)
            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/waterspout")
        end
    })
