local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local function CommonClientFn(inst)
    inst.entity:AddPhysics()

    inst.Physics:SetMass(0)
    inst.Physics:SetCapsule(0.5, 0.5)
    inst.Physics:SetCollisionGroup(COLLISION.GROUND)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SANITY)

    inst.Physics:SetActive(false)
end

local function CommonServerFn(inst)
    inst.nearby_alert = true 
    inst.triggered = false 

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(45)
    inst.components.combat:SetRange(1.2)
    inst.components.combat:SetAreaDamage(inst.components.combat.hitrange,1.0)
    inst.components.combat:SetHurtSound("dontstarve/creatures/lava_arena/turtillus/shell_impact")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)

    inst:AddComponent("gale_creatureprox")
    inst.components.gale_creatureprox:SetDist(1,1.1)

    inst.OnSave = function(inst,data)
        data.triggered = inst.triggered
    end

    inst.OnLoad = function(inst,data)
        if data ~= nil then
            if data.triggered ~= nil then
                inst.triggered = data.triggered
            end
        end
        inst.sg:GoToState("idle")
    end

    inst.EnableElec = function(inst,enable)
        if inst.elec_fx then
            inst.elec_fx:Remove()
            inst.elec_fx = nil 
        end

        if enable then
            -- .SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
            -- inst.elec_fx
        end
    end

    inst:SetStateGraph("SGgale_spear_trap")

    GaleCondition.AddCondition(inst,"condition_metallic")

    inst:ListenForEvent("gale_creatureprox_occupied",function()
        if inst.nearby_alert and not inst.triggered and inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("extending")
        end
        -- inst.sg:GoToState("extending")
    end)
    inst:ListenForEvent("gale_creatureprox_empty",function()

    end)
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_spear_trap",
    assets = {
        Asset("ANIM", "anim/spear_trap.zip"),
    },

    tags = {"gale_creatureprox_exclude"},

    bank = "spear_trap",
    build = "spear_trap",

    clientfn = function(inst)
        CommonClientFn(inst)
    end,

    serverfn = function(inst)
        CommonServerFn(inst)

    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_spear_trap_broken",
    assets = {
        Asset("ANIM", "anim/spear_trap.zip"),
    },
    tags = {"gale_creatureprox_exclude"},

    bank = "spear_trap",
    build = "spear_trap",
    anim = "broken",

    clientfn = function(inst)
        inst:SetPrefabNameOverride("gale_spear_trap")
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_spear_trap_burnt",
    assets = {
        Asset("ANIM", "anim/spear_trap.zip"),
    },
    tags = {"gale_creatureprox_exclude"},

    bank = "spear_trap",
    build = "spear_trap",
    anim = "burnt",

    clientfn = function(inst)
        inst:SetPrefabNameOverride("gale_spear_trap")
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")
    end,
})