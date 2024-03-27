local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/athetos_neuromod.zip"),
    Asset("ANIM", "anim/swap_athetos_neuromod.zip"),

    Asset("IMAGE", "images/inventoryimages/athetos_neuromod.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_neuromod.xml"),
}

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "athetos_neuromod",
    assets = assets,

    bank = "athetos_neuromod",
    build = "athetos_neuromod",
    anim = "idle",

    tags = { "gale_skill_learning_item" },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    clientfn = function(inst)
        local s = 1.7
        inst.Transform:SetScale(s, s, s)
    end,

    serverfn = function(inst)
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end
})
