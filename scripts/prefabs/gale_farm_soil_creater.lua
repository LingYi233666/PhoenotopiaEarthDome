local function OnTerraform(inst, pt, old_tile_type, old_tile_turf_prefab)

end

local function CreateTileAndRemove(inst)
    inst.components.terraformer:Terraform(inst:GetPosition())
    inst:Remove()
end

local function main_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("terraformer")
    inst.components.terraformer.turf = WORLD_TILES.FARMING_SOIL
    inst.components.terraformer.onterraformfn = OnTerraform
    inst.components.terraformer.plow = true

    inst.startup_task = inst:DoTaskInTime(0, CreateTileAndRemove)

    return inst
end

return Prefab("gale_farm_soil_creater", main_fn)
