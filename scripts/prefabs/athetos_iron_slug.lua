local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")
local brain = require("brains/athetos_iron_slug_brain")

local assets = {
    Asset("ANIM", "anim/athetos_iron_slug.zip"),
    Asset("IMAGE", "images/inventoryimages/athetos_iron_slug.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_iron_slug.xml"),
}

local function OnCollide(inst, other)
    if other and inst.components.combat:CanTarget(other)
        and not inst.components.combat:IsAlly(other)
        and GetTime() - (inst.collide_targets[other] or 0) > 1
        and not inst.sg:HasStateTag("fall") then
        local myvel = Vector3(inst.Physics:GetVelocity())
        local othervel = other.Physics and Vector3(other.Physics:GetVelocity()) or Vector3(0, 0, 0)
        local deltavel = othervel - myvel
        local toward_vec = (inst:GetPosition() - other:GetPosition()):GetNormalized()

        local cos_theta = toward_vec:Dot(deltavel) / (toward_vec:Length() * deltavel:Length())

        local toward_sub = deltavel:Length() * cos_theta

        local min_speed = 0.25
        if toward_sub >= min_speed then
            local damage_mult = Remap(math.clamp(toward_sub, 6, 20), 6, 20, 1, 10)

            inst.components.combat.ignorehitrange = true
            inst.components.combat:DoAttack(other, nil, nil, nil, damage_mult)
            inst.components.combat.ignorehitrange = false

            inst.collide_targets[other] = GetTime()
        end
    end
end

local function RedirectHealth(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if amount >= 0 then
        return
    end

    if ignore_invincible or ignore_absorb then
        return
    end

    local damage = -amount

    if damage < 166 then
        return true
    end
end

local function TransformToItem(inst)
    inst.sg:GoToState("idle")

    inst.health_store = 20
    if inst.components.health then
        inst.health_store = inst.components.health.currenthealth
        inst:RemoveComponent("health")
    end

    if not inst.components.armor then
        inst:AddComponent("armor")
    end
    inst.components.armor:InitIndestructible(0.90)

    inst:StopBrain()
end

local function TransformToCreature(inst)
    if not inst.components.health then
        inst:AddComponent("health")
    end

    inst.components.health:SetMaxHealth(20)
    inst.components.health:SetVal(math.clamp(inst.health_store or 20, 1, 20))
    inst.components.health.redirect = RedirectHealth

    inst.health_store = nil

    if inst.components.armor then
        inst:RemoveComponent("armor")
    end


    inst:RestartBrain()
end

local function OnEquip(inst, owner)
    TransformToItem(inst)
    owner.AnimState:OverrideSymbol("swap_body", "athetos_iron_slug", "swap_athetos_iron_slug")
end

local function OnUnequip(inst, owner)
    inst.Physics:Stop()
    TransformToCreature(inst)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst.sg:GoToState("fall")
end

local function DropTargets(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, { "_combat" }, { "INLIMBO", "player" })
    for i, v in ipairs(ents) do
        if v.components.combat:TargetIs(inst) then
            v.components.combat:SetTarget(nil)
        end
    end
end

return GaleEntity.CreateNormalEntity({
    prefabname = "athetos_iron_slug",
    assets = assets,

    bank = "athetos_iron_slug",
    build = "athetos_iron_slug",
    anim = "walk",

    tags = { "heavy", "nonpotatable", "hide_percentage", "thorny" },

    loop_anim = true,

    clientfn = function(inst)
        -- inst.entity:AddPhysics()
        inst.entity:AddDynamicShadow()

        -- inst.Physics:SetMass(1000)
        -- inst.Physics:SetFriction(20)
        -- inst.Physics:SetDamping(0)
        -- inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        -- inst.Physics:ClearCollisionMask()
        -- inst.Physics:CollidesWith(COLLISION.WORLD)
        -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        -- inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        -- inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        -- inst.Physics:CollidesWith(COLLISION.GIANTS)
        -- inst.Physics:SetCapsule(0.75, 1)

        MakeCharacterPhysics(inst, 1000, 0.75)

        inst.DynamicShadow:SetSize(1, 0.6)


        inst.Transform:SetTwoFaced()
    end,

    serverfn = function(inst)
        inst.Physics:SetCollisionCallback(OnCollide)

        inst.collide_targets = {}

        inst:AddComponent("lootdropper")

        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = 0.5
        inst.components.locomotor.runspeed = 0.5

        inst:AddComponent("inventoryitem")
        -- inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem.cangoincontainer = false
        -- inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem:SetSinks(true)
        inst.components.inventoryitem.imagename = "athetos_iron_slug"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/athetos_iron_slug.xml"


        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnUnequip(OnUnequip)
        inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("combat")
        inst.components.combat:SetRange(2)
        inst.components.combat:SetDefaultDamage(5)
        inst.components.combat:SetAttackPeriod(0.1)
        inst.components.combat:SetHurtSound("gale_sfx/battle/hit_metal")

        inst:SetStateGraph("SGathetos_iron_slug")
        inst:SetBrain(brain)

        inst:DoPeriodicTask(10, function()
            inst.collide_targets = {}
        end)

        inst:DoPeriodicTask(10, DropTargets)


        -- inst:AddComponent("hauntable")
        -- inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        TransformToCreature(inst)

        GaleCondition.AddCondition(inst, "condition_metallic")
    end,
})
