local GaleEntity = require("util/gale_entity")

local function SaveAnim(inst,data)
    data.anim = inst.anim
end

local function LoadAnim(inst,data)
    if data ~= nil then
        if data.anim ~= nil then
            inst.anim = data.anim
            inst.AnimState:PlayAnimation(inst.anim)
        end
    end
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_invincible_wall_hedge1",
    assets = {
        Asset("ANIM", "anim/hedge.zip"),
        Asset("ANIM", "anim/hedge1_build.zip"),
    },

    tags = {"structure","wall"},

    bank = "hedge",
    build = "hedge1_build",

    clientfn = function(inst)
        MakeObstaclePhysics(inst, .5)

        inst.Transform:SetEightFaced()

        inst:SetPrefabNameOverride("gale_invincible_wall_hedge")
    end,

    serverfn = function(inst)
        inst.anim = GetRandomItem({"growth1","growth2"})
        inst.AnimState:PlayAnimation(inst.anim)

        inst.SetAnim = function(inst,anim)
            inst.anim = anim
            inst.AnimState:PlayAnimation(inst.anim)
        end

        inst.OnSave = SaveAnim
        inst.OnLoad = LoadAnim

        inst:AddComponent("inspectable")

        inst:AddComponent("savedscale")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_invincible_wall_hedge2",
    assets = {
        Asset("ANIM", "anim/hedge.zip"),
        Asset("ANIM", "anim/hedge2_build.zip"),
    },

    tags = {"structure","wall"},

    bank = "hedge",
    build = "hedge2_build",

    clientfn = function(inst)
        MakeObstaclePhysics(inst, .5)

        inst.Transform:SetEightFaced()

        inst:SetPrefabNameOverride("gale_invincible_wall_hedge")
    end,

    serverfn = function(inst)
        inst.anim = GetRandomItem({"growth1","growth2"})
        inst.AnimState:PlayAnimation(inst.anim)

        inst.SetAnim = function(inst,anim)
            inst.anim = anim
            inst.AnimState:PlayAnimation(inst.anim)
        end

        inst.OnSave = SaveAnim
        inst.OnLoad = LoadAnim

        inst:AddComponent("inspectable")

        inst:AddComponent("savedscale")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_invincible_wall_hedge3",
    assets = {
        Asset("ANIM", "anim/hedge.zip"),
        Asset("ANIM", "anim/hedge3_build.zip"),
    },

    tags = {"structure","wall"},

    bank = "hedge",
    build = "hedge3_build",

    clientfn = function(inst)
        MakeObstaclePhysics(inst, .5)

        inst.Transform:SetEightFaced()

        inst:SetPrefabNameOverride("gale_invincible_wall_hedge")
    end,

    serverfn = function(inst)
        inst.anim = GetRandomItem({"growth1","growth2"})
        inst.AnimState:PlayAnimation(inst.anim)

        inst.SetAnim = function(inst,anim)
            inst.anim = anim
            inst.AnimState:PlayAnimation(inst.anim)
        end

        inst.OnSave = SaveAnim
        inst.OnLoad = LoadAnim

        inst:AddComponent("inspectable")

        inst:AddComponent("savedscale")
    end,
})