-- local function OnTerraform(inst, pt, old_tile_type, old_tile_turf_prefab)

-- end

local function CreateTileAndRemove(inst)
    -- inst.components.terraformer:Terraform(inst:GetPosition())
    local _x, _y, _z = inst:GetPosition():Get()
    if TheWorld.Map:CanPlowAtPoint(_x, _y, _z) then
        local x, y = TheWorld.Map:GetTileCoordsAtPoint(_x, _y, _z)
        TheWorld.Map:SetTile(x, y, WORLD_TILES.FARMING_SOIL)
    end

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

    -- inst:AddComponent("terraformer")
    -- inst.components.terraformer.turf = WORLD_TILES.FARMING_SOIL
    -- inst.components.terraformer.onterraformfn = OnTerraform
    -- inst.components.terraformer.plow = true

    inst.startup_task = inst:DoTaskInTime(0, CreateTileAndRemove)

    return inst
end

return Prefab("gale_farm_soil_creater", main_fn)
