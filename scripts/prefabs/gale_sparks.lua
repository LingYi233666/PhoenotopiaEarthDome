local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_sparks",
    assets = {
        Asset("ANIM", "anim/sparks.zip"),
    },

    bank = "sparks",
    build = "sparks",
    anim = function()
        return "sparks_" .. math.random(3)
    end,

    clientfn = function(inst)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)
    end,
})
