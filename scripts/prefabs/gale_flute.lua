local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")


local assets = {
    Asset("ANIM", "anim/gale.zip"),
    Asset("ANIM", "anim/gale_flute.zip"),
    Asset("ANIM", "anim/swap_gale_flute.zip"),
    Asset("ANIM", "anim/gale_actions_flute.zip"),

    Asset("IMAGE","images/inventoryimages/gale_flute.tex"),
	Asset("ATLAS","images/inventoryimages/gale_flute.xml"),

    Asset("IMAGE","images/inventoryimages/gale_flute_duplicate.tex"),
	Asset("ATLAS","images/inventoryimages/gale_flute_duplicate.xml"),
}

local function FluteClientFn(inst)
    
end

local function FluteServerFn(inst)
    inst:AddComponent("gale_flute")
end

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "gale_flute",
    assets = assets,
    -- tags = {"flute","tool"},
    bank = "gale_flute",
    build = "gale_flute",
    anim = "idle",

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    clientfn = FluteClientFn,
    serverfn = FluteServerFn,
}),
GaleEntity.CreateNormalInventoryItem({
    prefabname = "gale_flute_duplicate",
    assets = assets,
    -- tags = {"flute","tool"},
    bank = "gale_flute",
    build = "gale_flute",
    anim = "idle",

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    clientfn = FluteClientFn,
    serverfn = FluteServerFn,
})