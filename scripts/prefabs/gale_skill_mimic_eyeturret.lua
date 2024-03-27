local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/eyeball_turret.zip"),
    Asset("ANIM", "anim/eyeball_turret_object.zip"),
    Asset("ANIM", "anim/eyeball_turret_base.zip"),
}

local function syncanim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
    inst.base.AnimState:PlayAnimation(animname, loop)
end

local function syncanimpush(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
    inst.base.AnimState:PushAnimation(animname, loop)
end

local function EquipWeapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("eye_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
        weapon:AddComponent("equippable")

        inst.components.inventory:Equip(weapon)
    end
end

local function MimicClientFn(inst)
    inst.entity:AddMiniMapEntity()

    MakeInventoryPhysics(inst)

    inst.Transform:SetFourFaced()

    inst.MiniMapEntity:SetIcon("eyeball_turret.png")


    inst._mimic_nameoverride = net_string(inst.GUID,"inst._mimic_nameoverride","mimic_nameoverride_dirty")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("mimic_nameoverride_dirty",function()
            inst.nameoverride = inst._mimic_nameoverride:value()
        end)
    end
end

local function MimicServerFn(inst)

    -- Turret Base is here
    -- The Turret itself is just an eye,LOL
    inst.base = SpawnPrefab("eyeturret_base")
    inst.base.entity:SetParent(inst.entity)
    
    inst.syncanim = syncanim
    inst.syncanimpush = syncanimpush
    inst.EquipWeapon = EquipWeapon

    inst:AddComponent("inventory")
    inst:DoTaskInTime(1, EquipWeapon)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYETURRET_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(6)
    inst.components.combat:SetDefaultDamage(TUNING.EYETURRET_DAMAGE)
    inst.components.combat:SetAttackPeriod(0.1)

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 3

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = function(inst,other)
        return other == inst.owner and 0 or -TUNING.SANITYAURA_TINY
    end

    inst:SetStateGraph("SGgale_skill_mimic_eyeturret")    
end

return GaleEntity.CreateNormalEntity({
    assets = assets,
    prefabname = "gale_skill_mimic_eyeturret",
    tags = {"shadow_aligned","eyeturret","companion"},
    bank = "eyeball_turret",
    build = "eyeball_turret",
    anim = "idle_loop",

    persists = false,

    clientfn = MimicClientFn,
    serverfn = MimicServerFn,
})