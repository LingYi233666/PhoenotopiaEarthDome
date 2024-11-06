local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
}

local function DoDeltaChargeProgress(inst, owner, delta)
    inst.power_charge_progress = inst.power_charge_progress + delta
    if inst.power_charge_progress >= 1 then
        inst.power_charge_progress = 0
        inst.power_charged = inst.power_charged + 1

        GaleCondition.AddCondition(owner, "condition_power")
    end
end

local function OnOwnerHitOther(inst, owner, data)
    local damage = data.damage
    if GetTime() - inst.last_trigger_time > 1
        and GaleCondition.GetConditionStacks(owner, "condition_power") < 10 then
        DoDeltaChargeProgress(inst, owner, 0.1)

        inst.last_trigger_time = GetTime()
    end
end

local function OnOwnerChargeAttack(inst, owner, data)
    if GetTime() - inst.last_trigger_time > 3
        and GaleCondition.GetConditionStacks(owner, "condition_power") < 10 then
        DoDeltaChargeProgress(inst, owner, 1)


        inst.last_trigger_time = GetTime()
    end
end

local function OnOwnerBattleStateChange(inst, owner, data)
    if data.state == "over" then
        inst.power_charge_progress = 0
        inst.power_charged = 0
    end
end

local function MakeAmulet()

end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")

    inst.last_trigger_time = GetTime()

    inst:ListenForEvent("onhitother", inst._on_owner_hit_other_wrapper, owner)
    inst:ListenForEvent("gale_weaponcharge_doattack", inst._on_owner_charge_attack, owner)
    inst:ListenForEvent("battlestate_change", inst._on_owner_battle_state_change, owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst:RemoveEventCallback("onhitother", inst._on_owner_hit_other_wrapper, owner)
    inst:RemoveEventCallback("gale_weaponcharge_doattack", inst._on_owner_charge_attack, owner)
    inst:RemoveEventCallback("battlestate_change", inst._on_owner_battle_state_change, owner)

    if GaleCondition.GetConditionStacks(owner, "condition_power") > 0 then
        GaleCondition.RemoveCondition(owner, "condition_power", inst.power_charged)
    end

    inst.power_charge_progress = 0
    inst.power_charged = 0
end

return GaleEntity.CreateNormalEquipedItem({
    prefabname = "athetos_amulet_berserker",
    assets = assets,

    bank = "amulets",
    build = "amulets",
    anim = "redamulet",

    tags = {},

    inventoryitem_data = {
        imagename = "amulet",
        atlasname_override = "images/inventoryimages.xml",
        floatable_param = { "med", nil, 0.6 },
        use_gale_item_desc = true,
    },

    finiteuses_data = {
        maxuse = 600,
    },

    equippable_data = {
        equipslot = EQUIPSLOTS.AMULET or EQUIPSLOTS.BODY,

        onequip_priority = {
            { OnEquip, 1 }
        },

        onunequip_priority = {
            { OnUnequip, 1, }
        },
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst.last_trigger_time = GetTime()
        inst.power_charge_progress = 0
        inst.power_charged = 0

        inst._on_owner_hit_other_wrapper = function(owner, data)
            OnOwnerHitOther(inst, owner, data)
        end

        inst._on_owner_charge_attack = function(owner, data)
            OnOwnerChargeAttack(inst, owner, data)
        end

        inst._on_owner_battle_state_change = function(owner, data)
            OnOwnerBattleStateChange(inst, owner, data)
        end
    end,
})
