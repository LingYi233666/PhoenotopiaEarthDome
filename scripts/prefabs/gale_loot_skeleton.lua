local GaleEntity = require("util/gale_entity")

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")
    inst:Remove()
end

local function onsave(inst, data)
    data.anim = inst.animnum
    data.chanceloottable = inst.components.lootdropper.chanceloottable
end

local function onload(inst, data)
    if data ~= nil then 
        if data.anim ~= nil then
            inst.animnum = data.anim
            inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))
        end 

        if data.chanceloottable ~= nil then
            inst.components.lootdropper:SetChanceLootTable(data.chanceloottable)
        end 
    end
end

local function CommonClientFn(inst)
    MakeSmallObstaclePhysics(inst, 0.25)
    inst:SetPrefabNameOverride("skeleton")
end

local function CommonServerFn(inst)

    inst.animnum = math.random(6)
    inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetChanceLootTable("skeleton")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst.OnLoad = onload
    inst.OnSave = onsave
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_loot_skeleton",
    assets = {
        Asset("ANIM", "anim/skeletons.zip"),
    },

    bank = "skeleton",
    build = "skeletons",

    clientfn = function(inst)
        CommonClientFn(inst)
    end,

    serverfn = function(inst)
        CommonServerFn(inst)
    end,
})
