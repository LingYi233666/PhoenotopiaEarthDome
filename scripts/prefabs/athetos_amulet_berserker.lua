local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
    Asset("ANIM", "anim/athetos_amulet_berserker.zip"),

    Asset("IMAGE", "images/inventoryimages/athetos_amulet_berserker.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_amulet_berserker.xml"),

    Asset("IMAGE", "images/inventoryimages/athetos_amulet_berserker_fixed.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_amulet_berserker_fixed.xml"),

    Asset("IMAGE", "images/inventoryimages/athetos_amulet_berserker_broken.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_amulet_berserker_broken.xml"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "athetos_amulet_berserker", "redamulet")

    inst.components.athetos_berserker_enchant:SetTarget(owner)

    inst.consume_fn = function(_, data)
        if data.state == "start" or data.state == "continue" then
            inst.components.fueled:StartConsuming()
        elseif data.state == "over" then
            inst.components.fueled:StopConsuming()
        end
    end

    inst:ListenForEvent("battlestate_change", inst.consume_fn, owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst.components.athetos_berserker_enchant:DropTarget()

    inst:RemoveEventCallback("battlestate_change", inst.consume_fn, owner)
    inst.components.fueled:StopConsuming()
end

local function MakeAmulet(prefabname)
    return GaleEntity.CreateNormalEquipedItem({
        prefabname = prefabname,
        -- prefabname = "athetos_amulet_berserker",
        assets = assets,

        bank = "athetos_amulet_berserker",
        build = "athetos_amulet_berserker",
        anim = "idle",

        tags = {},

        inventoryitem_data = {
            floatable_param = { "med", nil, 0.6 },
            use_gale_item_desc = true,
        },

        -- finiteuses_data = {
        --     maxuse = 600,
        -- },

        equippable_data = {
            equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY,

            onequip_priority = {
                { OnEquip, 1 }
            },

            onunequip_priority = {
                { OnUnequip, 1, }
            },
        },

        clientfn = function(inst)
            -- inst:SetPrefabNameOverride("athetos_amulet_berserker")
        end,

        serverfn = function(inst)
            inst:AddComponent("athetos_berserker_enchant")
            inst.components.athetos_berserker_enchant.power_increased_max = 6

            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = FUELTYPE.MAGIC
            inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * 10)
            inst.components.fueled:SetDepletedFn(inst.Remove)
            inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING
                .TURNON_FULL_FUELED_CONSUMPTION)
        end,
    })
end

return
    MakeAmulet("athetos_amulet_berserker"),
    MakeAmulet("athetos_amulet_berserker_fixed"),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_amulet_berserker_broken",
        assets = assets,

        bank = "athetos_amulet_berserker",
        build = "athetos_amulet_berserker",
        anim = "idle_broken",

        tags = {},

        inventoryitem_data = {
            floatable_param = { "med", nil, 0.6 },
            use_gale_item_desc = true,
        },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = FUELTYPE.MAGIC
            inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * 10)
            inst.components.fueled:SetDepletedFn(function() end)
            inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING
                .TURNON_FULL_FUELED_CONSUMPTION)
            inst.components.fueled:SetPercent(0)
        end,
    })
