local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")
local GaleChargeableWeaponFns = require("util/gale_chargeable_weapon_fns")

local assets = {
    Asset("ANIM", "anim/gale_hammer.zip"),
    Asset("ANIM", "anim/swap_gale_hammer.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
    Asset("ANIM", "anim/gale_actions_melee_chargeatk.zip"),

    Asset("ANIM", "anim/gale_circleslash_fx.zip"),


    Asset("IMAGE", "images/inventoryimages/gale_hammer.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_hammer.xml"),
}

local function GetDamageFn(inst, attacker, target)
    local basedamage = 51
    local power_level = GaleCondition.GetConditionStacks(attacker, "condition_power")

    return basedamage * (1 + power_level * 0.10) / (1 + power_level * 0.05)
end

local function OnStartHelmSplitter(inst, attacker)
    local targetpos = attacker.sg.statemem.targetpos
    if targetpos then
        local duration = 13 * FRAMES
        local dist = (attacker:GetPosition() - targetpos):Length()
        local dist_adjust = dist - inst.components.gale_helmsplitter:GetForwardOffset()
        local speed = dist_adjust / duration
        if speed > 0 then
            attacker.Physics:SetMotorVel(speed, 0, 0)
        end
    end
end


local function OnStopHelmSplitter(inst, attacker)
    attacker.Physics:Stop()
end

local function OnCastHelmSplitter(inst, attacker, target)
    attacker.Physics:Stop()
end

return GaleEntity.CreateNormalWeapon({
    assets = assets,
    prefabname = "gale_hammer",
    tags = { "gale_bat", "gale_only_rmb_charge", "gale_parryweapon" },


    bank = "gale_hammer",
    build = "gale_hammer",
    anim = "idle",

    equippable_data = {
        onequip_priority = {
            {
                function(inst, owner)

                end,
                1,
            }
        },

        onunequip_priority = {
            {
                function(inst, owner)

                end,
                1,
            }
        },
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        damage = GetDamageFn,
        -- ranges = 0.2,
    },

    finiteuses_data = {
        maxuse = 350,
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst.components.equippable.restrictedtag = "gale_weaponcharge"

        inst:AddComponent("tool")
        inst.components.tool:SetAction(ACTIONS.HAMMER)

        inst:AddComponent("gale_helmsplitter")
        inst.components.gale_helmsplitter.onstartfn = OnStartHelmSplitter
        inst.components.gale_helmsplitter.onstopfn = OnStopHelmSplitter
        inst.components.gale_helmsplitter.oncastfn = OnCastHelmSplitter

        local ChargeAttackIfNotCompleted = GaleChargeableWeaponFns.MeleeAttackNonCompletedWrapper()
        local ChargeAttackIfCompleted = GaleChargeableWeaponFns.MeleeAttackCompletedWrapper()

        inst:AddComponent("gale_chargeable_weapon")
        inst.components.gale_chargeable_weapon.do_attack_fn =
            GaleChargeableWeaponFns.WeaponAttackWrapper(
                ChargeAttackIfNotCompleted,
                ChargeAttackIfCompleted)

        inst:ListenForEvent("gale_charge_time_change", GaleChargeableWeaponFns.ChargeTimeCbWrapper(Vector3(0, -175, 0)))
    end,
})
