local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM","anim/gale_bluerock_fx.zip"),
}

return GaleEntity.CreateNormalFx({
    prefabname = "gale_bluerock_fx", 

    bank = "gale_bluerock_fx",
    build = "gale_bluerock_fx",
    anim = function()
        return "idle_"..tostring(math.random(0,5))
    end,

    clientfn = function(inst)
        inst.Transform:SetTwoFaced()
        
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)

        inst.AnimState:SetLightOverride(1)
    end,

    serverfn = function(inst)
        
    end,
})