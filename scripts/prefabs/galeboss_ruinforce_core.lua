local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "galeboss_ruinforce_core",

    assets = {
        Asset("ANIM", "anim/galeboss_ruinforce_core.zip"),
    
        Asset("IMAGE","images/inventoryimages/galeboss_ruinforce_core.tex"),
        Asset("ATLAS","images/inventoryimages/galeboss_ruinforce_core.xml"),
    },

    bank = "galeboss_ruinforce_core",
    build = "galeboss_ruinforce_core",
    anim = "idle",

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    clientfn = function(inst)
        inst.Transform:SetScale(2,2,2)
    end,

    serverfn = function(inst)
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = 6
    end,
})