local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/gale_destruct_item_table.zip"),

    Asset("IMAGE", "images/inventoryimages/gale_destruct_item_table.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_destruct_item_table.xml"),
}


local containers = require("containers")
local containers_params = containers.params

local function IsDestructible(item)
    local rewards = GaleCommon.GetDestructRecipesByName(item.prefab)
    local num_rewards = 0
    for k, v in pairs(rewards) do
        num_rewards = num_rewards + v
    end
    return num_rewards > 0
end

local container_param = {
    widget =
    {
        slotpos =
        {
            Vector3(-(64 + 12), 0, 0),
            Vector3(0, 0, 0),
            Vector3(64 + 12, 0, 0),
        },

        slotbg =
        {
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" }, -- item
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" }, -- parer
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" }, -- pencil
        },

        animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
        pos = Vector3(0, 200, 0),
        side_align_tip = 100,

        buttoninfo =
        {
            text = STRINGS.GALE_UI.DESTRUCT_ITEM,
            position = Vector3(0, -65, 0),
            fn = function(inst, doer)
                SendModRPCToServer(MOD_RPC["gale_rpc"]["use_destruct_item_table"], inst)
            end,

            validfn = function(inst)
                return inst.replica.container ~= nil and inst.replica.container:GetItemInSlot(1) ~= nil
            end,
        }
    },
    acceptsstacks = false,
    type = "chest",
    usespecificslotsforitems = true,

    itemtestfn = function(container, item, slot)
        if slot == nil then
            return item.prefab == "papyrus" or item.prefab == "featherpencil" or IsDestructible(item)
        end

        if slot == 1 then
            return IsDestructible(item) and item.prefab ~= "papyrus" and item.prefab ~= "featherpencil"
        elseif slot == 2 then
            return item.prefab == "papyrus"
        elseif slot == 3 then
            return item.prefab == "featherpencil"
        end
    end,
}

containers_params.gale_destruct_item_table = container_param


local function CheckSwapItem(inst)
    local target = inst.components.container:GetItemInSlot(1)
    if target then
        local tex_filename = target.components.inventoryitem.imagename
        local xml_path = target.components.inventoryitem.atlasname

        if tex_filename then
            tex_filename = tex_filename .. ".tex"
        end


        if tex_filename == nil and xml_path == nil then
            tex_filename = target.prefab .. ".tex"
            xml_path = GetInventoryItemAtlas(tex_filename)
        elseif tex_filename == nil then
            tex_filename = target.prefab .. ".tex"
        elseif xml_path == nil then
            xml_path = GetInventoryItemAtlas(tex_filename)
        end

        -- print("xml_path is",xml_path,"tex_filename is",tex_filename)
        -- Is mod inventoryitem
        if resolvefilepath(xml_path):find("../mods/") then
            -- inst._update_xml_path:set(xml_path)
            -- AutoAddAtlasBuild(xml_path, addition_assets_server_dict)
            AutoAddAtlasBuild(xml_path)
        end

        inst.AnimState:OverrideSymbol("swap_object", resolvefilepath(xml_path), tex_filename)
    else
        inst.AnimState:OverrideSymbol("swap_object", "gale_destruct_item_table", "swap_object_empty")
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "gale_destruct_item_table",
        assets = assets,

        bank = "gale_destruct_item_table",
        build = "gale_destruct_item_table",
        anim = "idle",

        clientfn = function(inst)
            inst.entity:AddMiniMapEntity()


            MakeObstaclePhysics(inst, 0.7)

            local s = 0.8
            inst.Transform:SetScale(s, s, s)
        end,

        serverfn = function(inst)
            inst:AddComponent("inspectable")

            inst:AddComponent("container")
            inst.components.container:WidgetSetup("gale_destruct_item_table")

            inst:ListenForEvent("itemget", CheckSwapItem)
            inst:ListenForEvent("itemlose", CheckSwapItem)
            CheckSwapItem(inst)
        end,
    }),
    MakePlacer("gale_destruct_item_table_placer", "gale_destruct_item_table", "gale_destruct_item_table", "idle_placer",
        nil, nil, nil, 0.8)
