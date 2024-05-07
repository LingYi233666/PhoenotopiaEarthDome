local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/blueprint_tackle.zip"),
}

local function batchfn(prefabname, index)
    return GaleEntity.CreateNormalInventoryItem({
        prefabname = prefabname,
        assets = assets,

        bank = "blueprint_tackle",
        build = "wagstaff_notes",
        anim = "idle",

        inventoryitem_data = {
            floatable_param = { "med", nil, 0.75 },
            -- use_gale_item_desc = true,
            imagename = "wagstaff_mutations_note",
            atlasname_override = "images/inventoryimages1.xml",
        },

        tags = {},


        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("gale_readable_paper")
            inst.components.gale_readable_paper.index = index
        end
    })
end

local prefabs = {}
for i = 1, 4 do
    table.insert(prefabs, batchfn("galeboss_katash_notebook_" .. tostring(i), "GALEBOSS_KATASH_NOTEBOOK_" .. tostring(i)))
end

return unpack(prefabs)
