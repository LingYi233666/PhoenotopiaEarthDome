local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_skill_linkage_circle",
    assets = {
        Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
    },

    bank = "lavaarena_beetletaur_fx",
    build = "lavaarena_beetletaur_fx",
    anim = "defend_fx",
    loop_anim = true,

    animover_remove = false,


    clientfn = function(inst)
        inst.Transform:SetScale(0.77,0.77,0.77)

        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetLightOverride(1)

        inst.AnimState:SetAddColour(255/255,210/255,0/255,1)
        inst.AnimState:SetMultColour(255/255,210/255,0/255,1)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_skill_linkage_puff",
    assets = {
        Asset("ANIM", "anim/round_puff_fx.zip"),
    },

    bank = "round_puff_fx",
    build = "round_puff_fx",
    anim = "puff_lg",

    animover_remove = false,

    clientfn = function(inst)
        inst.AnimState:SetAddColour(255/255, 220/255, 0/255, 1)
    end,

    serverfn = function(inst)
        inst:DoTaskInTime(0,function()
            -- inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            -- inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/hit")
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_death_VO","sd")
            inst.SoundEmitter:SetVolume("sd",0.33)
        end)

        inst:DoTaskInTime(5,inst.Remove)
    end,
})