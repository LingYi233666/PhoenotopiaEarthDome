local assets =
{
    Asset("ANIM", "anim/sandbag_small.zip"),
}

local anims =
{
    -- { threshold = 0,    anim = "rubble" },
    -- { threshold = 0.4,  anim = "heavy_damage" },
    -- { threshold = 0.5,  anim = "half" },
    -- { threshold = 0.99, anim = "light_damage" },
    -- -- { threshold = 1,    anim = { "full", "full", "full" } },
    -- { threshold = 1,    anim = "full" },



    { threshold = 0,   anim = "rubble" },
    { threshold = 0.4, anim = "heavy_damage" },
    { threshold = 0.6, anim = "half" },
    { threshold = 0.8, anim = "light_damage" },
    { threshold = 1,   anim = "full" },
}


-- local function ResolveAnimToPlay(inst, percent)
--     for i, v in ipairs(anims) do
--         if percent <= v.threshold then
--             if type(v.anim) == "table" then
--                 -- get a stable animation, by basing it on world position
--                 local x, y, z = inst.Transform:GetWorldPosition()
--                 local x = math.floor(x)
--                 local z = math.floor(z)
--                 local q1 = #v.anim + 1
--                 local q2 = #v.anim + 4
--                 local t = (((x % q1) * (x + 3) % q2) + ((z % q1) * (z + 3) % q2)) % #v.anim + 1
--                 return v.anim[t]
--             else
--                 return v.anim
--             end
--         end
--     end
-- end


local function ResolveAnimToPlay(inst, percent)
    for i, v in ipairs(anims) do
        if percent <= v.threshold then
            return v.anim
        end
    end
end

local function MakeSandBagObstacle(inst)
    if not inst.Physics then
        inst.entity:AddPhysics()
    end

    inst.Physics:SetMass(0) --Bullet wants 0 mass for static objects
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCapsule(1, 2)

    local x, y, z = inst.Transform:GetWorldPosition()
    TheWorld.Pathfinder:AddWall(x + 0.5, y, z + 0.5)
    TheWorld.Pathfinder:AddWall(x + 0.5, y, z - 0.5)
    TheWorld.Pathfinder:AddWall(x - 0.5, y, z + 0.5)
    TheWorld.Pathfinder:AddWall(x - 0.5, y, z - 0.5)
end


local function ClearSandBagObstacle(inst)
    if not inst.Physics then
        inst.entity:AddPhysics()
    end

    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)

    local x, y, z = inst.Transform:GetWorldPosition()
    TheWorld.Pathfinder:RemoveWall(x + 0.5, y, z + 0.5)
    TheWorld.Pathfinder:RemoveWall(x + 0.5, y, z - 0.5)
    TheWorld.Pathfinder:RemoveWall(x - 0.5, y, z + 0.5)
    TheWorld.Pathfinder:RemoveWall(x - 0.5, y, z - 0.5)
end

local function OnObstacleDirty(inst)
    local val = inst._use_obstacle:value()
    print(inst, "OnObstacleDirty", val)
    if val then
        MakeSandBagObstacle(inst)
    else
        ClearSandBagObstacle(inst)
    end
end

local function OnHammered(inst, worker)
    local max_loots = 2
    local num_loots = math.max(1, math.floor(max_loots * inst.components.health:GetPercent()))
    for k = 1, num_loots do
        -- inst.components.lootdropper:SpawnLootPrefab("sand")
        inst.components.lootdropper:SpawnLootPrefab("turf_desertdirt")
    end

    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function OnHealthDelta(inst, data)
    if data.oldpercent <= 0 and data.newpercent > 0 then
        inst._use_obstacle:set(true)
    end
    if data.oldpercent > 0 and data.newpercent <= 0 then
        inst._use_obstacle:set(false)
    end

    local anim_to_play = ResolveAnimToPlay(inst, data.newpercent)
    inst.AnimState:PlayAnimation(anim_to_play)
end

local function OnWork(inst)
    -- inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandbag")
    local percent = inst.components.health:GetPercent()
    inst.AnimState:PlayAnimation(ResolveAnimToPlay(inst, percent))
end

local function onrepaired(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandbag")
    -- inst._use_obstacle:set(true)
end

local function OnRemove(inst)
    inst._use_obstacle:set(false)
end

local function OnLoad(inst, data)
    if inst.components.health:GetPercent() <= 0 then
        inst._use_obstacle:set(false)
    end
end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    MakeSandBagObstacle(inst)

    inst:AddTag("sandbag")
    inst:AddTag("wall")
    inst:AddTag("noauradamage")
    inst:AddTag("blocker")

    inst.AnimState:SetBank("sandbag_small")
    inst.AnimState:SetBuild("sandbag_small")
    inst.AnimState:PlayAnimation("full", false)


    inst._use_obstacle = net_bool(inst.GUID, "inst._use_obstacle", "use_obstacle_dirty")
    inst._use_obstacle:set(true)
    -- Handled by client and server
    inst:ListenForEvent("use_obstacle_dirty", OnObstacleDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnLoad = OnLoad

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    -- inst:AddComponent("repairable")
    -- inst.components.repairable.repairmaterial = "sandbagsmall"
    -- inst.components.repairable.onrepaired = onrepaired

    inst:AddComponent("combat")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200)
    inst.components.health.nofadeout = true
    inst.components.health.canheal = false

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnWork)

    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    return inst
end

return Prefab("athetos_sandbag", fn, assets)
