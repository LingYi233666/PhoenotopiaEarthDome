local function projectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(0)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(inst.Remove)

    inst:DoTaskInTime(0,inst.Remove)

    return inst
end

local function complexprojectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(0)
    inst.components.complexprojectile:SetGravity(0)
    inst.components.complexprojectile:SetOnLaunch(inst.Remove)
    inst.components.complexprojectile:SetOnHit(inst.Remove)

    inst:DoTaskInTime(0,inst.Remove)

    return inst
end

return Prefab("gale_fake_projectile", projectile_fn),Prefab("gale_fake_complexprojectile", complexprojectile_fn)