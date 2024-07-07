local GaleEntity = require("util/gale_entity")


local containers = require("containers")
local containers_params = containers.params

local container_param = {
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    -- usespecificslotsforitems = true,
    type = "clip",
    acceptsstacks = false,
    excludefromcrafting = true,
    itemtestfn = function(container, item, slot)
        return item:HasTag("msf_ammo_pistol")
    end,
}

for y = 0, 6 do
    table.insert(container_param.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(container_param.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

containers_params.msf_clip_pistol = container_param

local function OnPutInInventoryFn(inst, owner)
    if owner and owner.components.container and owner:HasTag("gale_blaster") then
        if inst.components.container:IsOpen() then
            inst.components.container:Close()
        end
        inst.components.container.canbeopened = false

        inst:AddTag("reloaditem_ammo")
        if not inst.components.reloaditem then
            inst:AddComponent("reloaditem")
        end
    else
        inst.components.container.canbeopened = true

        inst:RemoveTag("reloaditem_ammo")
        if inst.components.reloaditem then
            inst:RemoveComponent("reloaditem")
        end
    end
end

local function OnDroppedFn(inst)
    inst:RemoveTag("reloaditem_ammo")
    if inst.components.reloaditem then
        inst:RemoveComponent("reloaditem")
    end
    inst.components.container.canbeopened = true
end

local function SortItem(inst)
    if inst._sorting then
        return
    end

    inst._sorting = true


    if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner:HasTag("gale_blaster") then
        -- Inside gun,bullet to up
        local cur_index = 1
        for k, v in pairs(inst.components.container.slots) do
            if v ~= nil and k ~= cur_index then
                local item = inst.components.container:RemoveItem(v, true)
                if inst.components.container:GiveItem(item, cur_index, nil, true) then
                    cur_index = cur_index + 1
                end
            end
        end
    else
        local cur_index = inst.components.container:GetNumSlots()
        for k = inst.components.container:GetNumSlots(), 0, -1 do
            local v = inst.components.container:GetItemInSlot(k)
            if v ~= nil and k ~= cur_index then
                local item = inst.components.container:RemoveItem(v, true)
                if inst.components.container:GiveItem(item, cur_index, nil, true) then
                    cur_index = cur_index - 1
                end
            end
        end
    end


    inst._sorting = false
end


local function CreateClip(suffix)
    return GaleEntity.CreateNormalInventoryItem({
        prefabname = suffix and ("msf_clip_pistol_" .. suffix) or "msf_clip_pistol",
        assets = {
            Asset("ANIM", "anim/msf_clip_pistol.zip"),

            Asset("IMAGE", "images/inventoryimages/msf_clip_pistol.tex"),
            Asset("ATLAS", "images/inventoryimages/msf_clip_pistol.xml"),
        },

        bank = "msf_clip_pistol",
        build = "msf_clip_pistol",
        anim = "idle",

        tags = {
            "msf_clip_pistol",
            "msf_clip",
            -- "reloaditem_ammo",
        },

        inventoryitem_data = {
            -- use_gale_item_desc = true,
            imagename = "msf_clip_pistol",
            atlasname = "msf_clip_pistol",
            floatable_param = { "small", 0.15, 0.5 },
        },


        clientfn = function(inst)
            if suffix then
                inst:SetPrefabName("msf_clip_pistol")
            end
            inst.Transform:SetScale(2, 2, 2)
        end,

        serverfn = function(inst)
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("msf_clip_pistol")

            inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventoryFn)
            inst.components.inventoryitem:SetOnDroppedFn(OnDroppedFn)

            -- inst:ListenForEvent("itemget",SortItem)
            -- inst:ListenForEvent("itemlose",SortItem)

            if suffix == "full" then
                for i = 1, #container_param.widget.slotpos do
                    inst.components.container:GiveItem(SpawnAt("msf_ammo_9mm_pistol", inst))
                end
            elseif suffix == "random" then
                for i = 1, math.random(1, #container_param.widget.slotpos) do
                    inst.components.container:GiveItem(SpawnAt("msf_ammo_9mm_pistol", inst))
                end
            end
        end,
    })
end

return CreateClip(), CreateClip("full"), CreateClip("random")
