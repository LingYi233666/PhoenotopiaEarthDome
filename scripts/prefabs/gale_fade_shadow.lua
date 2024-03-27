local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

-- c_spawn("gale_fade_shadow"):Copy(ThePlayer)
return GaleEntity.CreateNormalFx({
    prefabname = "gale_fade_shadow",
    assets = {

    },

    bank = "wilson",
    build = "gale",
    anim = "idle",

    animover_remove = false,

    clientfn = function(inst)
        MakeProjectilePhysics(inst)

        inst.Transform:SetFourFaced()

        inst.AnimState:AddOverrideBuild("player_actions_roll")
        inst.AnimState:AddOverrideBuild("player_lunge")
        inst.AnimState:AddOverrideBuild("player_attack_leap")
        inst.AnimState:AddOverrideBuild("player_superjump")
        inst.AnimState:AddOverrideBuild("player_multithrust")
        inst.AnimState:AddOverrideBuild("player_parryblock")

        -- If carry a weapon,use this
        -- inst.AnimState:OverrideSymbol("swap_object", "swap_icey_bluerose", "swap_icey_bluerose")
        -- inst.AnimState:Show("ARM_carry")
        -- inst.AnimState:Hide("ARM_normal")

        inst.AnimState:Show("HEAD")
        inst.AnimState:Hide("HEAD_HAT")
    end,

    serverfn = function(inst)
        -- inst:AddComponent("inventory")

        inst:AddComponent("skinner")
        inst.components.skinner:SetupNonPlayerData()

        inst.Copy = function(inst,target)
            inst.components.skinner:CopySkinsFromPlayer(target)
        end
    end,
})