local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")

    inst.components.athetos_berserker_enchant:SetTarget(owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst.components.athetos_berserker_enchant:DropTarget()
end

local function MakeAmulet(prefabname)
    GaleEntity.CreateNormalEquipedItem({
        prefabname = prefabname,
        -- prefabname = "athetos_amulet_berserker",
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
            -- inst:SetPrefabNameOverride("athetos_amulet_berserker")
        end,

        serverfn = function(inst)
            inst:AddComponent("athetos_berserker_enchant")
            -- inst.components.athetos_berserker_enchant:SetTarget(inst)

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

        clientfn = function(inst)

        end,

        serverfn = function(inst)

        end,
    })
