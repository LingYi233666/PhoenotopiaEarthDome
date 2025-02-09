local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

SetSharedLootTable("typhon_phantom_organ_lv1", {
    { "nightmarefuel", 1.00 },
    { "horrorfuel",    0.75 },
})

SetSharedLootTable("typhon_phantom_organ_lv2", {
    { "nightmarefuel", 1.00 },
    { "horrorfuel",    1.00 },
    { "horrorfuel",    0.75 },
})


return GaleEntity.CreateNormalInventoryItem({
    prefabname = "typhon_phantom_organ",
    assets = {
        Asset("ANIM", "anim/typhon_phantom_organ.zip"),

        Asset("IMAGE", "images/inventoryimages/typhon_phantom_organ.tex"),
        Asset("ATLAS", "images/inventoryimages/typhon_phantom_organ.xml"),
    },

    inventoryitem_data = {
        -- floatable_param = { "small", 0.1, 0.88 },
        use_gale_item_desc = true,
    },

    bank = "typhon_phantom_organ",
    build = "typhon_phantom_organ",
    anim = "idle2",

    tags = {
        "show_spoilage",
    },

    clientfn = function(inst)
        -- local s = 0.9
        -- inst.Transform:SetScale(s, s, s)
    end,

    serverfn = function(inst)
        inst:AddComponent("lootdropper")

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "nightmarefuel"

        inst:AddComponent("gale_anatomical")
        inst.components.gale_anatomical.loottablenames = {
            "typhon_phantom_organ_lv1",
            "typhon_phantom_organ_lv2",
        }
    end,
})
