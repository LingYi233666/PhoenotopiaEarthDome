local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalEntity({
    assets = {
        -- Asset("ANIM", "anim/gale_spheralis_node.zip"),
    },
    prefabname = "gale_spheralis_node",
    tags = {"NOBLOCK","FX"},
    bank = "flint",
    build = "flint",
    anim = "idle",
    persists = true,
    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(3)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )

        inst.AnimState:SetLightOverride(1)
    end,
    serverfn = function(inst)
        inst:AddComponent("gale_linked_node")
    end,
})