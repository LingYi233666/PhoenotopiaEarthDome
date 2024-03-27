local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

SetSharedLootTable("typhon_mimic_cancer_lv1", {
    { "nightmarefuel", 1.00 },
    { "horrorfuel",    0.01 },
    { "cutgrass",      0.10 },
    { "twigs",         0.10 },
    { "log",           0.06 },
    { "rocks",         0.06 },
    { "goldnugget",    0.02 },
    { "berries",       0.10 },
    { "petals",        0.10 },
    { "petals_evil",   0.05 },
    { "smallmeat",     0.05 },
    { "gears",         0.01 },
})

SetSharedLootTable("typhon_mimic_cancer_lv2", {
    { "nightmarefuel", 1.00 },
    { "horrorfuel",    0.33 },
    { "cutgrass",      0.15 },
    { "twigs",         0.15 },
    { "log",           0.10 },
    { "rocks",         0.10 },
    { "goldnugget",    0.06 },
    { "berries",       0.15 },
    { "petals",        0.15 },
    { "petals_evil",   0.10 },
    { "smallmeat",     0.10 },
    { "gears",         0.02 },
})


return GaleEntity.CreateNormalInventoryItem({
    prefabname = "typhon_mimic_cancer",
    assets = {
        Asset("ANIM", "anim/typhon_mimic_cancer.zip"),

        Asset("IMAGE", "images/inventoryimages/typhon_mimic_cancer.tex"),
        Asset("ATLAS", "images/inventoryimages/typhon_mimic_cancer.xml"),
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    bank = "typhon_mimic_cancer",
    build = "typhon_mimic_cancer",
    anim = "idle",

    tags = {
        "show_spoilage",
    },

    clientfn = function(inst)
        local s = 0.7
        inst.Transform:SetScale(s, s, s)
    end,

    serverfn = function(inst)
        inst:AddComponent("lootdropper")

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "nightmarefuel"

        inst:AddComponent("gale_anatomical")
        inst.components.gale_anatomical.loottablenames = {
            "typhon_mimic_cancer_lv1",
            "typhon_mimic_cancer_lv2",
        }
    end,
})
