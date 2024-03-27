local GaleEntity = require("util/gale_entity")


return GaleEntity.CreateNormalFx({
    prefabname = "gale_hand_shoot_fx",
    assets = {
        Asset("ANIM", "anim/player_pistol.zip"),
    },

    bank = "wilson",
    build = "player_pistol",
    anim = "hand_shoot",

    clientfn = function(inst)
        inst.Transform:SetFourFaced()
    end,

    serverfn = function(inst)
        inst.AnimState:SetTime(17 * FRAMES)
    end,
})