local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/butterfly_basic.zip"),
    Asset("ANIM", "anim/butterfly_moon.zip"),
    
}

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_skill_picker_butterfly",
    assets = assets,

    tags = {"NOCLICK"},

    bank = "butterfly",
    build = "butterfly_basic",
    anim = "idle",

    persists = false,

    clientfn = function(inst)
        inst.entity:AddDynamicShadow()

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetRayTestOnBB(true)
        -- inst.AnimState:SetAddColour(147/255, 245/255, 247/255,1)
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetFinalOffset(1)

        inst.DynamicShadow:SetSize(.8, .5)

        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    end,

    serverfn = function(inst)
        inst:SetStateGraph("SGgale_skill_picker_butterfly")
    end,
})