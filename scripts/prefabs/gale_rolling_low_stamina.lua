local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_rolling_low_stamina",
    assets = {
        Asset("ANIM","anim/slurper_basic.zip"),
        Asset("ANIM","anim/gale_rolling_low_stamina.zip"),
    },

    bank = "slurper",
    build = "gale_rolling_low_stamina",
    anim = "roll_loop",

    tags = {"NOCLICK"},

    loop_anim = true,

    persists = false,

    clientfn = function(inst)
        inst.Transform:SetFourFaced()    

        MakeInventoryPhysics(inst)
        -- RemovePhysicsColliders(inst)

        local s = 0.8
        inst.Transform:SetScale(s,s,s)

        inst.AnimState:SetDeltaTimeMultiplier(1.3)
    end,

    serverfn = function(inst)
        
    end,
})