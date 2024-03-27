local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_glitch_explode",

    bank = "explode",
    build = "gale_glitch_explode",
    anim = "small",

    clientfn = function(inst)
        inst.AnimState:SetLightOverride(1)
    end,

    serverfn = function(inst)
        
    end,
})