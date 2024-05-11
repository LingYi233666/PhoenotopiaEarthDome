local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/wx_scanner.zip"),
}


local function RetargetFn(inst)
    return FindEntity(
        inst,
        8,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat", "_health" },
        { "INLIMBO", "prey", },
        { "character", }
    )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, 15)
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_katash_skymine",
    assets = assets,

    bank = "scanner",
    build = "wx_scanner",
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
        inst.components.combat:SetRange(2, 6)
        inst.components.combat:SetDefaultDamage(33)
        inst.components.combat:SetAttackPeriod(1)
        inst.components.combat:SetRetargetFunction(3, RetargetFn)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(50)

        inst:SetStateGraph("SGgaleboss_katash_skymine")

        GaleCondition.AddCondition(inst, "condition_metallic")
    end,
})
