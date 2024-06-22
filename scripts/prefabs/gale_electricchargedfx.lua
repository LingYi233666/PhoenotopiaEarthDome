local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_electricchargedfx",
    assets = {
        Asset("ANIM", "anim/elec_charged_fx.zip"),
    },

    bank = "elec_charged_fx",
    build = "elec_charged_fx",
    anim = "discharged",

    clientfn = function(inst)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)

        inst.AnimState:SetSortOrder(1)
    end,
})
