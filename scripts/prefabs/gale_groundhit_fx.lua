local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/lavaarena_boarrior_fx.zip"),
}

return GaleEntity.CreateNormalFx({
    prefabname = "gale_groundhit_fx",
    assets = assets,

    bank = "lavaarena_boarrior_fx",
    build = "lavaarena_boarrior_fx",

    serverfn = function(inst)
        inst.DoPlayAnim = function(inst,level,excludesymbols)
            if excludesymbols then
                for i, v in ipairs(excludesymbols) do
                    inst.AnimState:Hide(v)
                end
            end
            inst.AnimState:PlayAnimation("ground_hit_"..tostring(level))
        end
    end,
})