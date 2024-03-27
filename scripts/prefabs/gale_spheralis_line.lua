local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")


-- TEST_LINE = c_spawn("gale_spheralis_line")
-- TEST_LINE = c_findnext("gale_spheralis_line")
-- TEST_LINE.components.gale_spheralis_line:SetTargetPos(ThePlayer:GetPosition())
-- c_findnext("gale_spheralis_line").components.gale_spheralis_line:SetTargetPos(ThePlayer:GetPosition())
return GaleEntity.CreateNormalEntity({
    assets = {
        Asset("ANIM", "anim/gale_spheralis_line.zip"),
    },
    prefabname = "gale_spheralis_line",
    tags = {"NOBLOCK","FX"},
    bank = "gale_spheralis_line",
    build = "gale_spheralis_line",
    anim = "idle",
    persists = false,
    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(3)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )

        inst.AnimState:SetLightOverride(1)
    end,
    serverfn = function(inst)
        inst:AddComponent("gale_linked_line")
    end,
})