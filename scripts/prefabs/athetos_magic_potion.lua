local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/athetos_magic_potion.zip"),

    Asset("IMAGE", "images/inventoryimages/athetos_magic_potion.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_magic_potion.xml"),
}

local function OnHealFn(inst, target)
    if target.components.sanity then
        target.components.sanity:DoDelta(10, true)
    end

    if target.components.gale_magic then
        target.components.gale_magic:DoDelta(67)
    end

    target.SoundEmitter:PlaySound("gale_sfx/other/heal_magic")
end

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "athetos_magic_potion",
    assets = assets,

    bank = "athetos_magic_potion",
    build = "athetos_magic_potion",
    anim = "idle",
    loop_anim = true,

    tags = {},

    inventoryitem_data = {
        floatable_param = { "small", 0.1, 0.88 },
        use_gale_item_desc = true,
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst:AddComponent("healer")
        inst.components.healer:SetHealthAmount(10)
        inst.components.healer.onhealfn = OnHealFn

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    end,
})
