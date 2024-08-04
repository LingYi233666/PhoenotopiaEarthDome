local GaleEntity = require("util/gale_entity")

local containers = require("containers")
local containers_params = containers.params
local widgetsetup_old = containers.widgetsetup

local slotpos_preset = {}
for y = 0, 6 do
    table.insert(slotpos_preset, Vector3(-162, -75 * y + 240, 0))
    table.insert(slotpos_preset, Vector3(-162 + 75, -75 * y + 240, 0))
end

local function ContainersParamsWrapper(slot_num)
    local param = {
        widget =
        {
            slotpos = {},
            animbank = "ui_krampusbag_2x8",
            animbuild = "ui_krampusbag_2x8",
            pos = Vector3(-5, -120, 0),
        },
        issidewidget = true,
        type = "pack",
        openlimit = 1,
    }

    for k, v in pairs(slotpos_preset) do
        if k > slot_num then
            break
        end

        table.insert(param.widget.slotpos, v)
    end

    return param
end

local function OnEquipToModel(inst, owner, from_ground)
    inst.components.container:Close(owner)
end

local function DoLevelUp(inst, next_level)
    next_level = next_level or inst.level + 1


    local items = inst.components.container:RemoveAllItems()
    local owner = inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() or nil
    local new_backpack = SpawnAt("gale_pocket_backpack_lv" .. next_level, owner or inst)

    for i, v in ipairs(items) do
        new_backpack.components.container:GiveItem(v)
    end

    if owner ~= nil then
        owner.components.inventory:Equip(new_backpack)
    end

    inst:Remove()
end

local function BackpackCreateWrapper(level)
    local prefabname = "gale_pocket_backpack_lv" .. level
    containers_params[prefabname] = ContainersParamsWrapper(level)

    local result = GaleEntity.CreateNormalEquipedItem({
        prefabname = prefabname,
        assets = {
            Asset("ANIM", "anim/backpack.zip"),
            Asset("ANIM", "anim/swap_backpack.zip"),
            Asset("ANIM", "anim/ui_backpack_2x4.zip"),
            Asset("ANIM", "anim/gale_pocket_backpack.zip"),
            Asset("ANIM", "anim/swap_gale_pocket_backpack.zip"),

            Asset("IMAGE", "images/inventoryimages/gale_pocket_backpack.tex"),
            Asset("ATLAS", "images/inventoryimages/gale_pocket_backpack.xml"),

            Asset("IMAGE", "images/map_icons/gale_pocket_backpack.tex"), --小地图
            Asset("ATLAS", "images/map_icons/gale_pocket_backpack.xml"),

        },

        bank = "gale_pocket_backpack",
        build = "gale_pocket_backpack",
        anim = "idle",

        tags = { "backpack", "gale_pocket_backpack", "hide_percentage" },

        inventoryitem_data = {
            imagename = "gale_pocket_backpack",
            atlasname_override = "images/inventoryimages/gale_pocket_backpack.xml",
            floatable_param = { "small", 0.2, nil, nil, nil, { bank = "backpack1", anim = "anim" } },
            use_gale_item_desc = true,
        },


        equippable_data = {
            equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY,

            -- owner_listeners = {},

            onequip_priority = {
                {
                    function(inst, owner)
                        owner.AnimState:OverrideSymbol("backpack", "gale_pocket_backpack", "backpack")
                        owner.AnimState:OverrideSymbol("swap_body", "swap_gale_pocket_backpack", "swap_body")

                        inst.components.container:Open(owner)
                    end,
                    1,
                }
            },

            onunequip_priority = {
                {
                    function(inst, owner)
                        owner.AnimState:ClearOverrideSymbol("swap_body")
                        owner.AnimState:ClearOverrideSymbol("backpack")

                        inst.components.container:Close(owner)
                    end,
                    1,
                }
            },
        },


        clientfn = function(inst)
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("gale_pocket_backpack.tex")

            inst.level = level
            inst.slotpos_preset = slotpos_preset
            inst.foleysound = "dontstarve/movement/foley/backpack"

            inst:SetPrefabNameOverride("gale_pocket_backpack")
        end,

        serverfn = function(inst)
            inst.DoLevelUp = DoLevelUp

            inst.components.inventoryitem.cangoincontainer = false

            inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

            inst:AddComponent("container")
            inst.components.container:WidgetSetup(prefabname)
            inst.components.container.skipclosesnd = true
            inst.components.container.skipopensnd = true

            inst:AddComponent("armor")
            inst.components.armor:InitIndestructible(level * 0.025)

            if inst.level >= 10 then
                inst.components.gale_item_desc:SetSimpleDesc(STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK.SIMPLE_3)
            elseif inst.level >= 6 then
                inst.components.gale_item_desc:SetSimpleDesc(STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK.SIMPLE_2)
            else
                inst.components.gale_item_desc:SetSimpleDesc(STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK.SIMPLE_1)
            end

            inst.components.gale_item_desc:SetComplexDesc(STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK.COMPLEX)

            MakeHauntableLaunchAndDropFirstItem(inst)
        end,
    })

    return result
end


-- for i=1,14 do c_spawn("gale_pocket_backpack_lv"..i) end

local backpacks = {}
for i = 1, 14 do
    table.insert(backpacks, BackpackCreateWrapper(i))
end

return unpack(backpacks)
