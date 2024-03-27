local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

return GaleEntity.CreateNormalFx({
    prefabname = "galeboss_ruinforce_superjump_warning",
    assets = {

    },

    bank = "reticuleaoe",
    build = "reticuleaoe",
    anim = "idle_target_6",

    animover_remove = false,

    clientfn = function(inst)
        local s = 1.33
        inst.Transform:SetScale(s,s,s)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_GROUND )
        inst.AnimState:SetSortOrder( 3 )
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetAddColour(1,0,0,1)
    end,

    serverfn = function(inst)
        inst.KillFX = function(inst)
            local s,_,_ = inst.Transform:GetScale()
            local r,g,b,a = inst.AnimState:GetMultColour()
            GaleCommon.FadeTo(inst,1,
                {
                    Vector3(s,s,s),
                    Vector3(s+0.1,s+0.1,s+0.1)
                },
                {
                    Vector4(r,g,b,a),
                    Vector4(0,0,0,0)
                },
                nil,
                inst.Remove
            )
        end
    end,
})