local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_ring_fx",
    assets = {},

    bank = "bearger_ring_fx",
    build = "bearger_ring_fx",
    anim = "idle",

    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(3)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_GROUND )
        inst.AnimState:SetSortOrder( 3 )

        inst.AnimState:SetLightOverride(1)
    end,
})