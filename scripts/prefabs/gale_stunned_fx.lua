local GaleEntity = require("util/gale_entity")


-- local fx=SpawnPrefab("gale_stunned_loop_fx") fx.Follower:FollowSymbol(ThePlayer.GUID,"headbase",0,-100,0)
return GaleEntity.CreateNormalFx({
    prefabname = "gale_stunned_loop_fx",
    assets = {
        Asset("ANIM","anim/gale_stunned_fx.zip"),
    },
    bank = "gale_stunned_fx",
    build = "gale_stunned_fx",
    anim = "front-fx",
    loop_anim = true,
    animover_remove = false,
    clientfn = function(inst)
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetFinalOffset(3)
        inst.AnimState:SetScale(0.6,0.6,0.6)
    end,

    serverfn = function(inst)
        inst.entity:AddFollower()
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_stunned_burst_fx",
    assets = {
        Asset("ANIM","anim/gale_stunned_fx.zip"),
    },

    bank = "gale_stunned_fx",
    build = "gale_stunned_fx",
    anim = "lunar_burst",
})