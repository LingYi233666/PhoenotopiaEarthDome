local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/boat_test.zip"),
}

-- local radius = 8
-- local width = math.sqrt(radius * radius + radius * radius)
-- local height = math.sqrt(radius * radius + radius * radius)

local width = 25
local height = 16
local radius = math.sqrt(width * width + height * height) / 2

local boat_corners = {
    Vector3(-width/2,0,height/2),
    Vector3(width/2,0,height/2),
    Vector3(width/2,0,-height/2),
    Vector3(-width/2,0,-height/2),
}

local function RemoveConstrainedPhysicsObj(physics_obj)
    if physics_obj:IsValid() then
        physics_obj.Physics:ConstrainTo(nil)
        physics_obj:Remove()
    end
end

local function AddConstrainedPhysicsObj(boat, physics_obj)
	physics_obj:ListenForEvent("onremove", function() RemoveConstrainedPhysicsObj(physics_obj) end, boat)

    physics_obj:DoTaskInTime(0, function()
		if boat:IsValid() then
			physics_obj.Transform:SetPosition(boat.Transform:GetWorldPosition())
   			physics_obj.Physics:ConstrainTo(boat.entity)
		end
	end)
end

local function BoatClientFn(inst)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(TUNING.BOAT.MASS)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:SetCylinder(radius, 3)

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
	inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    -- inst.Transform:SetScale(2,2,2)

    
    


    for k,v in pairs(boat_corners) do
        local pt = inst:SpawnChild("pighead")
        pt.Transform:SetPosition(v:Get())
        -- pt.Transform:SetScale(1,10,10)
        pt.persists = false
    end

    inst.doplatformcamerazoom = net_bool(inst.GUID, "doplatformcamerazoom", "doplatformcamerazoomdirty")

    inst:AddComponent("walkableplatform")
    inst.components.walkableplatform.platform_radius = radius
    -- inst.components.walkableplatform.player_collision_prefab = "gale_test_boat_player_collision"
    AddConstrainedPhysicsObj(inst,SpawnPrefab("gale_test_boat_player_collision"))
end


local function BoatServerFn(inst)
    inst.Physics:SetDontRemoveOnSleep(true)
end

local function build_collision_mesh(points,height)
    height = height or 3
    local triangles = {}
    local y0,y1 = 0,height

    for k,curr_pt in pairs(points) do
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

local function boat_player_collision_fn()
    local inst = CreateEntity()
    

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.BOAT_LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.WORLD)

    local PLAYER_COLLISION_MESH = build_collision_mesh(boat_corners, 3)
    -- local PLAYER_COLLISION_MESH = build_boat_collision_mesh_official(radius + 0.1,3)
    phys:SetTriangleMesh(PLAYER_COLLISION_MESH)

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    return inst
end

return GaleEntity.CreateNormalEntity({
    assets = assets,
    prefabname = "gale_test_boat",
    tags = {"ignorewalkableplatforms","antlion_sinkhole_blocker"},

    bank = "boat_01",
    build = "boat_test",
    anim = "idle",

    clientfn = BoatClientFn,
    serverfn = BoatServerFn,

}),Prefab("gale_test_boat_player_collision",boat_player_collision_fn)