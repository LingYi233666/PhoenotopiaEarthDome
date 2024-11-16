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
            return item.prefab == "papyrus"
                or item.prefab == "featherpencil"
                or item.prefab == "blueprint"
                or item.prefab == "athetos_production_process"
                or IsDestructible(item)
        end

        if slot == 1 then
            return (IsDestructible(item)
                    or item.prefab == "blueprint"
                    or item.prefab == "athetos_production_process")
                and item.prefab ~= "papyrus"
                and item.prefab ~= "featherpencil"
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



local function OnItemGet(inst, data)
    CheckSwapItem(inst)

    local item = data.item
    if item then
        if not inst.listenfns then
            inst.listenfns = {}
        end

        inst.listenfns[item] = function()
            CheckSwapItem(inst)
        end

        inst:ListenForEvent("imagechange", inst.listenfns[item], item)
    end
end

local function OnItemLose(inst, data)
    CheckSwapItem(inst)

    local item = data.prev_item
    if item and inst.listenfns[item] then
        inst:RemoveEventCallback("imagechange", inst.listenfns[item], item)
        inst.listenfns[item] = nil
    end
end

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()

    SpawnAt("collapse_small", inst):SetMaterial("wood")

    inst:Remove()
end

local function OnHit(inst)
    inst.components.container:DropEverything()
    inst.components.container:Close()
end

local function SelectItemInput(inst, doer)
    local container = inst.components.container

    local main_item = container:GetItemInSlot(1)
    local papyrus = container:GetItemInSlot(2)
    local featherpencil = container:GetItemInSlot(3)

    if main_item == nil then
        return
    end

    if papyrus == nil or featherpencil == nil then
        return main_item
    end

    local main_item_prefab = main_item.prefab

    if main_item_prefab == "blueprint"
        or main_item_prefab == "athetos_production_process" then
        if papyrus == nil or featherpencil == nil then
            return
        end

        return main_item, { papyrus, featherpencil }
    end

    local blueprint_name = main_item_prefab .. "_blueprint"

    if Prefabs[blueprint_name] then
        return main_item, { papyrus, featherpencil }
    else
        print("SelectItemInput:", blueprint_name .. " not exists in Prefabs !")
    end

    return main_item
end

local factor_prefabnames = {
    mandrake = 0,
    cookedmandrake = 0,
    dragon_scales = 0.5,
    shroom_skin = 0.5,
    dreadstone = 0.5,
    purebrilliance = 0.5,
}

local function RemoveZeroValues(tab)
    local keys = {}
    for k, v in pairs(tab) do
        if v <= 0 then
            table.insert(keys, k)
        end
    end

    for _, key in pairs(keys) do
        tab[key] = nil
    end
end

local function GetConsumeAndRewardFn(inst, target, subitems, consumes, rewards, rewards_saverecord)
    -- local name_with_one_cnt = {}

    -- for name, cnt in pairs(rewards) do
    --     if cnt == 1 then
    --         table.insert(name_with_one_cnt, name)
    --     end
    -- end

    -- if name_with_one_cnt == GetTableSize(rewards) then

    -- else
    --     for name, cnt in pairs(rewards) do
    --         rewards[name] = math.random(1, cnt)
    --     end

    -- end

    if target.prefab == "blueprint" or target.prefab == "athetos_production_process" then
        table.removearrayvalue(consumes, target)
        table.insert(consumes, subitems[1])
        table.insert(consumes, subitems[2])

        rewards_saverecord[target:GetSaveRecord()] = 1
        return
    end

    for name, cnt in pairs(rewards) do
        rewards[name] = math.random(cnt)
    end

    for name, factor in pairs(factor_prefabnames) do
        if rewards[name] then
            rewards[name] = math.floor(rewards[name] * factor)
        end
    end

    if subitems[1] and subitems[1].prefab == "papyrus"
        and subitems[2] and subitems[2].prefab == "featherpencil" then
        local blueprint_name = target.prefab .. "_blueprint"
        if Prefabs[blueprint_name] then
            table.insert(consumes, subitems[1])
            table.insert(consumes, subitems[2])

            if not rewards[blueprint_name] then
                rewards[blueprint_name] = 0
            end
            rewards[blueprint_name] = rewards[blueprint_name] + 1
        else
            print("GetConsumeAndRewardFn:", blueprint_name .. " not exists in Prefabs !")
        end
    end

    RemoveZeroValues(rewards)
end


-- local MATERIAL_NAMES =
-- {
--     "wood",
--     "metal",
--     "rock",
--     "stone",
--     "straw",
--     "pot",
--     "none",
-- }

local MATERIAL_SOUNDS_MAP =
{
    livinglog = "wood",

    silk = "straw",
    beefalowool = "straw",

    twigs = "wood",

    redgem = "pot",
    bluegem = "pot",
    greengem = "pot",
    purplegem = "pot",
    yellowgem = "pot",
    orangegem = "pot",
    opalpreciousgem = "pot",

    log = "wood",
    boards = "wood",


    rocks    = "stone",
    cutstone = "stone",

    cutgrass = "straw",
    cutreeds = "straw",
}


local function OnDestructFn(inst, doer, target, subitems, rewards, raw_rewards, rewards_saverecord)
    if doer then
        if doer.components.sanity then
            doer.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY, true)
        end
    end

    if target.prefab == "blueprint" or target.prefab == "athetos_production_process" then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
        return
    end

    local sound_cands = {}

    local fx = inst:SpawnChild("collapse_small")

    if not fx.Follower then
        fx.entity:AddFollower()
    end

    fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 100, 0, true)

    for name, cnt in pairs(rewards) do
        if MATERIAL_SOUNDS_MAP[name] then
            table.insert(sound_cands, MATERIAL_SOUNDS_MAP[name])
        end
    end

    for name, cnt in pairs(raw_rewards) do
        if MATERIAL_SOUNDS_MAP[name] then
            table.insert(sound_cands, MATERIAL_SOUNDS_MAP[name])
        end
    end

    if #sound_cands > 0 then
        fx:SetMaterial(sound_cands[math.random(#sound_cands)])
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

            inst:AddComponent("lootdropper")

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(OnHammered)
            inst.components.workable:SetOnWorkCallback(OnHit)

            inst:AddComponent("gale_item_destructor")
            inst.components.gale_item_destructor.base_percent = 1.0
            inst.components.gale_item_destructor:SetSelectItemFn(SelectItemInput)
            inst.components.gale_item_destructor:SetConsumeAndRewardFn(GetConsumeAndRewardFn)
            inst.components.gale_item_destructor:SetOnDestructFn(OnDestructFn)


            inst:ListenForEvent("itemget", OnItemGet)
            inst:ListenForEvent("itemlose", OnItemLose)
            CheckSwapItem(inst)
        end,
    }),
    MakePlacer("gale_destruct_item_table_placer", "gale_destruct_item_table", "gale_destruct_item_table", "idle_placer",
        nil, nil, nil, 0.8)
