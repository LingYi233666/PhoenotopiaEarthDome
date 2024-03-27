local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_scream_ring_fx",
    assets = {},
    
    bank = "bearger_ring_fx",
    build = "bearger_ring_fx",
    anim = "idle",

    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(1)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_scream_ring_black_fx",
    assets = {},
    
    bank = "bearger_ring_fx",
    build = "bearger_ring_fx",
    anim = "idle",

    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(1)

        inst.AnimState:SetMultColour(0,0,0,1)
    end,
})