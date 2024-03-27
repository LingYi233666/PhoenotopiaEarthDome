local GaleEntity = require("util/gale_entity")

local function CommonClientFn(inst)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
end

local function CommonServerFn(inst)
    inst:AddComponent("gale_creatureprox")
    inst.components.gale_creatureprox:SetDist(0.8, 0.9)

    inst:ListenForEvent("gale_creatureprox_occupied",function()
        inst.AnimState:PlayAnimation("popdown")
        inst.AnimState:PushAnimation("down_idle",true)
    end)
    inst:ListenForEvent("gale_creatureprox_empty",function()
        inst.AnimState:PlayAnimation("popup")
        inst.AnimState:PushAnimation("up_idle",true)
    end)
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_interior_pressure_plate_yellow_stone",
    assets = {
        Asset("ANIM", "anim/pressure_plate.zip"),
        Asset("ANIM", "anim/pressure_plate_build.zip"),
        Asset("ANIM", "anim/pressure_plate_backwards_build.zip"),
        Asset("ANIM", "anim/pressure_plate_forwards_build.zip"),
    },

    bank = "pressure_plate",
    build = "pressure_plate_build",
    anim = "up_idle",

    tags = {"structure","weighdownable","gale_creatureprox_exclude"},

    clientfn = function(inst)
        CommonClientFn(inst)
    end,

    serverfn = function(inst)
        CommonServerFn(inst)
    end
})