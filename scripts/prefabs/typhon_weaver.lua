local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

SetSharedLootTable("typhon_weaver", {
    { "nightmarefuel", 1.00 },
    { "nightmarefuel", 1.00 },
    { "nightmarefuel", 0.50 },
    { "nightmarefuel", 0.50 },
    { "nightmarefuel", 0.25 },

    { "horrorfuel",    1.00 },
    { "horrorfuel",    1.00 },
    { "horrorfuel",    0.50 },
})


local function RetargetFn(inst)
    return FindEntity(
        inst,
        8,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and not GaleCommon.IsShadowCreature(guy)
        end,
        { "_combat", "_health" },
        { "INLIMBO" },
        { "character", "prey", "animal", "smallcreature", "lunar_aligned" }
    )
end

local function KeepTargetFn(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
end

-- local MAIN_SHIELD_CD = 1.2
-- local function PickShield(inst)
--     local t = GetTime()
--     if (inst.lastshieldtime or 0) + .2 >= t then
--         return
--     end

--     inst.lastshieldtime = t

--     --variation 3 or 4 is the main shield
--     local dt = t - (inst.lastmainshield or 0)
--     if dt >= MAIN_SHIELD_CD then
--         inst.lastmainshield = t
--         return math.random(3, 4)
--     end

--     local rnd = math.random()
--     if rnd < dt / MAIN_SHIELD_CD then
--         inst.lastmainshield = t
--         return math.random(3, 4)
--     end

--     return rnd < dt / (MAIN_SHIELD_CD * 2) + .5 and 2 or 1
-- end

local function CheckShieldShrine(inst)
    inst.AnimState:SetHaunted(inst.shield_amout > 0)
    if inst.shield_amout > 0 then
        inst.AnimState:SetAddColour(17 / 255, 0 / 255, 49 / 255, 1)
    else
        inst.AnimState:SetAddColour(0, 0, 0, 1)
    end
end

local function RedirectDamageFn(inst, attacker, damage, weapon, stimuli, spdamage)
    if inst.shield_amout > 0 and damage >= 0 and stimuli ~= "q_beam" then
        inst.shield_amout = inst.shield_amout - damage
        inst:CheckShieldShrine()
        return inst:SpawnShieldFX()
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
                                           return dude:HasTag("typhon") and not IsEntityDead(dude, true)
                                       end, 10)
end

-- shadow_shield
-- ThePlayer:SpawnChild("shadow_shield")
return GaleEntity.CreateNormalEntity({
    prefabname = "typhon_weaver",

    assets = {
        Asset("ANIM", "anim/brightmare_melty.zip"),
    },

    tags = { "typhon", "shadow_aligned", "monster", "hositile", "scarytoprey" },

    bank = "brightmare_melty",
    build = "brightmare_melty",
    anim = "idle_loop",
    loop_anim = true,

    clientfn = function(inst)
        MakeCharacterPhysics(inst, 10, .5)

        inst.Transform:SetSixFaced()

        inst.AnimState:SetMultColour(0, 0, 0, 0.9)
    end,

    serverfn = function(inst)
        inst.shield_amout = 200
        inst.SpawnShieldFX = function(inst)
            local fx = inst:SpawnChild("shadow_shield" .. tostring(math.random(1, 6)))
            local s = 1.5
            fx.Transform:SetScale(s, s, s)
            return fx
        end
        inst.CheckShieldShrine = CheckShieldShrine

        inst:AddComponent("timer")

        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor.walkspeed = 3
        inst.components.locomotor.runspeed = 5.75

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(75)

        -- inst:AddComponent("inventory")
        -- inst.components.inventory.maxslots = 1

        inst:AddComponent("combat")
        inst.components.combat:SetRange(7)
        inst.components.combat:SetDefaultDamage(0)
        inst.components.combat:SetAttackPeriod(12)
        inst.components.combat:SetRetargetFunction(1, RetargetFn)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.combat.redirectdamagefn = RedirectDamageFn

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

        inst:AddComponent("areaaware")

        -- 需要消耗灵能
        inst:AddComponent("gale_magic")

        inst:AddComponent("leader")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable("typhon_weaver")

        inst:SetStateGraph("SGtyphon_weaver")

        local brain = require("brains/typhon_weaver_brain")
        inst:SetBrain(brain)

        -- inst:DoPeriodicTask(0, CheckEmergencyEvade)

        inst:ListenForEvent("attacked", OnAttacked)

        inst.sounds = {
            create_phantom2 = "gale_sfx/battle/typhon_weaver/create_phantom2",
            create_phantom3 = "gale_sfx/battle/typhon_weaver/create_phantom3",
            death = "gale_sfx/battle/typhon_weaver/death",
            hit = "gale_sfx/battle/typhon_weaver/hit",
            idle = "gale_sfx/battle/typhon_weaver/idle",
            move = "gale_sfx/battle/typhon_weaver/move",
            shield_all = "gale_sfx/battle/typhon_weaver/shield_all",
            shield_prepare = "gale_sfx/battle/typhon_weaver/shield_prepare",
            shield_finish = "gale_sfx/battle/typhon_weaver/shield_finish",
            attack_pre = "gale_sfx/battle/typhon_weaver/spawn_cystoid_pre",
            attack = "gale_sfx/battle/typhon_weaver/spawn_cystoid",
        }

        inst:DoTaskInTime(1, function()
            inst.SoundEmitter:PlaySound(inst.sounds.idle, "idlenoise")
        end)

        inst:CheckShieldShrine()

        -- inst.SoundEmitter:SetVolume("idlenoise", 0.66)
    end
})
