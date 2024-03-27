local GaleEntity = require("util/gale_entity")

local function build_collision_mesh(points,height,link_head_and_tail)
    height = height or 12
    local triangles = {}
    local y0,y1 = 0,height

    for k,curr_pt in pairs(points) do
        if link_head_and_tail == false and k == #points then
            break 
        end
        local next_pt = k < #points and points[k+1] or points[1]

        local x0,_,z0 = (curr_pt * 1):Get()
        local x1,_,z1 = (next_pt * 1):Get()
        

        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)
    end

    return triangles
end

local function common_fn()
    local inst = CreateEntity()
    

    inst.entity:AddTransform()
    inst.entity:AddPhysics()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.Physics:SetMass(0)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)

    inst.AttachPtList = function(inst,pt_list,height)
        local PLAYER_COLLISION_MESH = build_collision_mesh(pt_list, height,#pt_list > 2)
        inst.Physics:SetTriangleMesh(PLAYER_COLLISION_MESH)
    end

    inst.AttachPolygon = function(inst,polygon,height)
        inst:AttachPtList(polygon:GetPtList(), height)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false


    return inst
end

local function boat_player_collision_fn()
    local inst = common_fn()
    
    inst.Physics:SetCollisionGroup(COLLISION.GROUND)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
    inst.Physics:CollidesWith(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.GIANTS)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function land_ocean_limit_fn()
    local inst = common_fn()

    inst.Physics:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    
    if not TheWorld.ismastersim then
        return inst
    end


    return inst
end

return Prefab("gale_polygon_physics",boat_player_collision_fn),
Prefab("gale_physics_land_ocean_limit",land_ocean_limit_fn)