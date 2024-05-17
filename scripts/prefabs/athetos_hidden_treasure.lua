local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local containers = require("containers")
local containers_params = containers.params

containers_params.athetos_revealed_treasure = deepcopy(containers_params.treasurechest)
containers_params.athetos_revealed_treasure.widget.buttoninfo = {
    text = STRINGS.GALE_UI.ATHETOS_REVEALED_TREASURE.DEPLOY,
    position = Vector3(0, -150, 0),
    fn = function(inst)
        SendModRPCToServer(MOD_RPC["gale_rpc"]["athetos_treasure_mimic_cast"], inst)
    end,
}

local BOARD_OVERRIDE_PIXEL = 153

local assets_revealed = {
    -- Asset("ANIM", "anim/treasure_chest.zip"),
    -- Asset("ANIM", "anim/luggage.zip"),
    Asset("ANIM", "anim/athetos_revealed_treasure.zip"),

    Asset("IMAGE", "images/override_symbols/athetos_revealed_treasure_boards1.tex"),
    Asset("ATLAS", "images/override_symbols/athetos_revealed_treasure_boards1.xml"),
    Asset("ATLAS_BUILD", "images/override_symbols/athetos_revealed_treasure_boards1.xml", BOARD_OVERRIDE_PIXEL),

    Asset("IMAGE", "images/override_symbols/athetos_revealed_treasure_boards2.tex"),
    Asset("ATLAS", "images/override_symbols/athetos_revealed_treasure_boards2.xml"),
    Asset("ATLAS_BUILD", "images/override_symbols/athetos_revealed_treasure_boards2.xml", BOARD_OVERRIDE_PIXEL),
}


local function ShowTrueTreasure(inst)
    inst.found = true

    if inst.fuzz_task then
        inst.fuzz_task:Cancel()
        inst.fuzz_task = nil
    end

    if inst.period_fuzz_task then
        inst.period_fuzz_task:Cancel()
        inst.period_fuzz_task = nil
    end

    inst.persists = false

    inst.AnimState:SetErosionParams(0, 0, 0)

    -- SpawnAt("collapse_small",inst)
    inst.SoundEmitter:PlaySound("gale_sfx/other/hologram_static", "hologram")

    inst:StartThread(function()
        local val1 = 0
        local val3 = 0
        while val3 < 15 do
            inst.AnimState:SetErosionParams(val1, -0.125, -val3)


            val1 = val1 + 1 / 250
            val3 = val3 + 0.3

            Sleep(0)
        end

        inst.SoundEmitter:KillSound("hologram")

        if inst.mimic_type == "tree" then
            local fx = SpawnAt("gale_glitch_explode", inst, { 1.2, 2, 1.2 })
            fx:SpawnChild("athetos_treasure_explode_tree_vfx")
            fx.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/explode")
        elseif inst.mimic_type == "sapling" then
            local fx = SpawnAt("gale_glitch_explode", inst, { 1.2, 2, 1.2 })
            fx:SpawnChild("athetos_treasure_explode_sapling_vfx")
            fx.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/explode")
        elseif inst.mimic_type == "rock_flintless" then
            local fx = SpawnAt("gale_glitch_explode", inst, { 1.2, 2, 1.2 })
            fx:SpawnChild("athetos_treasure_explode_rock_flintless_vfx")
            fx.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/explode")
        elseif inst.mimic_type == "seastack" then
            local fx = SpawnAt("gale_glitch_explode", inst, { 1.2, 2, 1.2 })
            fx:SpawnChild("athetos_treasure_explode_seastack_vfx")
            fx.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/explode")
        end




        -- local prefab = inst:IsOnOcean() and "athetos_revealed_treasure_sea" or "athetos_revealed_treasure"

        local box = nil
        if inst.treasure_data then
            box = SpawnSaveRecord(inst.treasure_data)
            box.Transform:SetPosition(inst:GetPosition():Get())
        else
            box = SpawnAt("athetos_revealed_treasure", inst)
            for k, v in pairs(inst.loot_list) do
                local name, num = v[1], v[2]

                for i = 1, num do
                    local item = SpawnPrefab(name)
                    if item then
                        item.Transform:SetPosition(box:GetPosition():Get())
                        if not box.components.container:GiveItem(item) and item:IsValid() then
                            item:Remove()
                            print(string.format("Can't GiveItem %s to %s", name, tostring(box)))
                        end
                    else
                        print(string.format("Can't Spawn %s to give %s", name, tostring(box)))
                    end
                end
            end
            inst.loot_list = {}
        end
        box.AnimState:SetMultColour(0, 0, 0, 0)

        GaleCommon.FadeTo(box, 2, nil, { Vector4(0, 0, 0, 0), Vector4(1, 1, 1, 1) })

        local val3 = -4
        box.AnimState:SetErosionParams(0, -1, val3)
        box:StartThread(function()
            while true do
                box.AnimState:SetErosionParams(0, -1, val3)
                val3 = math.min(0, val3 + FRAMES * 3 / 2)
                Sleep(0)

                if val3 >= 0 then
                    break
                end
            end

            box.AnimState:SetErosionParams(0, 0, 0)
        end)

        if inst.treasure_data == nil then
            box:DoTaskInTime(2.5, function()
                box.SoundEmitter:PlaySound("gale_sfx/other/secret_discovered")
            end)
        end



        inst:Remove()
    end)
end

local mimic_types = {
    tree = {
        function(inst)
            inst.Transform:SetTwoFaced()

            inst:SetPrefabNameOverride("evergreen")

            inst.AnimState:SetBank("evergreen_short")
            inst.AnimState:SetBuild("evergreen_new")
            inst.AnimState:PlayAnimation(string.format("sway%d_loop_short", math.random(1, 2)))

            inst.AnimState:Hide("snow")
        end,

        function(inst)
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.CHOP)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(ShowTrueTreasure)

            inst:ListenForEvent("animover", function()
                inst.AnimState:PlayAnimation(string.format("sway%d_loop_short", math.random(1, 2)))
            end)
        end,
    },




    sapling = {
        function(inst)
            inst.Transform:SetTwoFaced()

            inst:SetPrefabNameOverride("sapling")

            inst.AnimState:SetRayTestOnBB(true)
            inst.AnimState:SetBank("sapling")
            inst.AnimState:SetBuild("sapling")
            inst.AnimState:PlayAnimation("sway", true)

            inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
        end,

        function(inst)
            inst:AddComponent("lootdropper")

            inst:AddComponent("pickable")
            inst.components.pickable:SetUp(nil)
            inst.components.pickable.use_lootdropper_for_product = true
            inst.components.pickable.onpickedfn = ShowTrueTreasure

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(ShowTrueTreasure)
        end,
    },



    rock_flintless = {
        function(inst)
            inst:SetPrefabNameOverride("rock_flintless")

            inst.AnimState:SetBank("rock_flintless")
            inst.AnimState:SetBuild("rock_flintless")
            inst.AnimState:PlayAnimation("full")
        end,

        function(inst)
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.MINE)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(ShowTrueTreasure)

            inst.components.inspectable.nameoverride = "ROCK"
        end,
    },



    seastack = {
        function(inst)
            inst:SetPrefabNameOverride("seastack")

            inst.AnimState:SetBank("water_rock01")
            inst.AnimState:SetBuild("water_rock_01")
            inst.AnimState:PlayAnimation("1_full")

            MakeInventoryFloatable(inst, "med", 0.1, { 1.1, 0.9, 1.1 })
            inst.components.floater.bob_percent = 0

            local land_time = (POPULATING and math.random() * 5 * FRAMES) or 0
            inst:DoTaskInTime(land_time, function(inst)
                inst.components.floater:OnLandedServer()
            end)
        end,

        function(inst)
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.MINE)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(ShowTrueTreasure)
        end,
    },
}

local function DoFuzzFX(inst)
    if inst.fuzz_task then
        inst.fuzz_task:Cancel()
        inst.fuzz_task = nil
    end

    inst.AnimState:SetErosionParams(0, -0.125, GetRandomMinMax(-1, 0))

    inst.fuzz_task = inst:DoTaskInTime(GetRandomMinMax(0.5, 1), function()
        inst.AnimState:SetErosionParams(0, 0, 0)
        inst.fuzz_task = nil
    end)
end

local function PeriodFuzzFX(inst)
    if inst.period_fuzz_task then
        inst.period_fuzz_task:Cancel()
        inst.period_fuzz_task = nil
    end

    inst.period_fuzz_task = inst:DoTaskInTime(GetRandomMinMax(5, 10), function()
        DoFuzzFX(inst)
        PeriodFuzzFX(inst)
    end)
end

local function HiddenTreasureWrapper(prefabname, data)
    return GaleEntity.CreateNormalEntity({
        -- prefabname = "athetos_hidden_treasure",
        prefabname = prefabname,
        assets = {},

        tags = { "ignorewalkableplatforms", "athetos_treasure" },


        clientfn = function(inst)
            inst.entity:AddAnimState()

            -- MakeObstaclePhysics(inst,0.5,2)
            -- inst:SetPhysicsRadiusOverride(2.35)
            MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

            if data.clientfn then
                data.clientfn(inst)
            end

            inst.mimic_type = data.mimic_type
        end,

        serverfn = function(inst)
            inst.treasure_data = nil
            inst.loot_list = {}

            inst.OnSave = function(inst, sdata)
                sdata.treasure_data = inst.treasure_data
                sdata.loot_list = inst.loot_list
            end

            inst.OnLoad = function(inst, ldata)
                if ldata ~= nil then
                    if ldata.treasure_data ~= nil then
                        inst.treasure_data = ldata.treasure_data
                    end
                    if ldata.loot_list ~= nil then
                        inst.loot_list = ldata.loot_list
                    end
                end
            end

            inst.OnEntityWake = function(inst)
                inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/noise", "noise")
            end

            inst.OnEntitySleep = function(inst)
                inst.SoundEmitter:KillSound("noise")
            end

            inst:AddComponent("inspectable")

            PeriodFuzzFX(inst)

            if data.serverfn then
                data.serverfn(inst)
            end
        end,
    })
end

local hidden_treasure_prefabs = {}

for mimic_type, data in pairs(mimic_types) do
    table.insert(hidden_treasure_prefabs, HiddenTreasureWrapper(
        "athetos_hidden_treasure_" .. mimic_type,
        {
            clientfn = data[1],
            serverfn = data[2],
            mimic_type = mimic_type,
        }
    ))
end

-----------------------------------------------------------------------------------------------------
local function TreasureOnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()

    SpawnAt("collapse_small", inst):SetMaterial("wood")
    inst:Remove()
end

local function TreasureOnHit(inst, worker)
    -- inst.components.container:DropEverything()
    inst.components.container:Close()
    -- inst.AnimState:PlayAnimation("hit")
    -- inst.AnimState:PushAnimation("idle")
end

-- local addition_assets_client_dict = {}
-- local addition_assets_server_dict = {}

-- local function AutoAddAtlasBuild(xml_path, search_dict)
--     if search_dict[xml_path] then
--         return
--     end
--     search_dict[xml_path] = true

--     print("AutoAddAtlasBuild:", xml_path)

--     local prefabname = TheWorld.ismastersim and "ATHETOS_REVEALED_TREASURE_ATLAS_BUILD_ADD_SERVER_" or
--         "ATHETOS_REVEALED_TREASURE_ATLAS_BUILD_ADD_CLIENT_"
--     prefabname = prefabname .. xml_path:gsub("/", "-")

--     local add_assets = {
--         Asset("ATLAS_BUILD", xml_path, 256),
--     }

--     local prefab = Prefab(prefabname, nil, add_assets, nil, true)
--     RegisterPrefabs(prefab)
--     TheSim:LoadPrefabs({ prefabname })
-- end

local function TreasureClientFn(inst)
    -- MakeObstaclePhysics(inst,0.5,2)

    -- inst:SetPhysicsRadiusOverride(2.35)
    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    MakeInventoryFloatable(inst, "med", 0.3, { 0.6, 0.7, 0.6 })
    inst.components.floater.bob_percent = 0

    local land_time = (POPULATING and math.random() * 5 * FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()

        if inst:IsOnOcean() and inst.groundfx then
            inst.groundfx:Remove()
            inst.groundfx = nil
        end
    end)

    -- inst:SetPrefabNameOverride("treasurechest")

    inst.Transform:SetScale(1.8, 1.8, 1.8)


    -- inst._update_xml_path = net_string(inst.GUID, "inst._update_xml_path", "gale_update_xml_path")

    if not TheNet:IsDedicated() then
        local groundfx = GaleEntity.CreateClientAnim({
            bank = "burntground",
            build = "burntground",
            anim = "idle"
        })

        groundfx.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        groundfx.AnimState:SetLayer(LAYER_GROUND)
        groundfx.AnimState:SetSortOrder(3)
        groundfx.Transform:SetRotation(math.random() * 360)

        local s = 0.5
        groundfx.AnimState:SetScale(s, s, s)
        -- c_select().groundfx.AnimState:SetScale(0.6,0.6,0.6)


        inst:AddChild(groundfx)

        inst.groundfx = groundfx


        -- inst:ListenForEvent("gale_update_xml_path", function()
        --     local xml_path = inst._update_xml_path:value()
        --     AutoAddAtlasBuild(xml_path, addition_assets_client_dict)
        -- end)
    end


    -- inst.AnimState:SetSymbolMultColour("board", 0, 0, 0, 0)
end




-- c_select().AnimState:ClearOverrideSymbol("board")
-- c_select():SetBoardSeg(0)
local function TreasureServerFn(inst)
    inst.img_seg = 0
    inst.target_img_seg = 0

    -- inst.board_anim = inst:SpawnChild("athetos_revealed_treasure_boardanim")
    -- inst.board_anim.entity:AddFollower()
    -- inst.board_anim.Follower:FollowSymbol(inst.GUID, "board", 0, 0, 0, true)
    -- inst.board_anim.AnimState:SetPercent("board_open2", 0)
    -- inst.board_anim.components.highlightchild:SetOwner(inst)


    inst.EnableOpenLoopSound = function(inst, enbale)
        if enbale and not inst.SoundEmitter:PlayingSound("open_loop") then
            inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/open_loop", "open_loop")
        elseif not enbale and inst.SoundEmitter:PlayingSound("open_loop") then
            inst.SoundEmitter:KillSound("open_loop")
        end
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("athetos_revealed_treasure")
    -- inst.components.container.onopenfn = TreasureOnOpen
    -- inst.components.container.onclosefn = TreasureOnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(10)
    inst.components.workable:SetOnFinishCallback(TreasureOnHammered)
    inst.components.workable:SetOnWorkCallback(TreasureOnHit)

    inst:SetStateGraph("SGathetos_revealed_treasure")

    inst:ListenForEvent("floater_startfloating", function()
        inst.AnimState:OverrideSymbol("main", "athetos_revealed_treasure", "main_water")
    end)

    inst:ListenForEvent("floater_stopfloating", function()
        inst.AnimState:ClearOverrideSymbol("main")
    end)




    local function CheckItemInSlot(inst, slot)
        local item = inst.components.container:GetItemInSlot(slot)
        if item then
            local tex_filename = item.components.inventoryitem.imagename
            local xml_path = item.components.inventoryitem.atlasname

            if tex_filename then
                tex_filename = tex_filename .. ".tex"
            end


            if tex_filename == nil and xml_path == nil then
                tex_filename = item.prefab .. ".tex"
                xml_path = GetInventoryItemAtlas(tex_filename)
            elseif tex_filename == nil then
                tex_filename = item.prefab .. ".tex"
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

            inst.AnimState:OverrideSymbol("item" .. slot, resolvefilepath(xml_path), tex_filename)
        else
            -- inst.AnimState:OverrideSymbol("item"..slot,"NULL","NULL")
            inst.AnimState:ClearOverrideSymbol("item" .. slot)
        end
    end

    -- { slot = in_slot, item = item, src_pos = src_pos, }
    inst:ListenForEvent("itemget", function(inst, data)
        CheckItemInSlot(inst, data.slot)
    end)

    inst:ListenForEvent("itemlose", function(inst, data)
        CheckItemInSlot(inst, data.slot)
    end)
end

-- c_spawn("athetos_hidden_treasure").mimic_type = "sapling"
return GaleEntity.CreateNormalEntity({
        prefabname = "athetos_revealed_treasure",
        assets = assets_revealed,

        bank = "athetos_revealed_treasure",
        build = "athetos_revealed_treasure",
        anim = "idle",
        tags = { "ignorewalkableplatforms", "athetos_treasure" },

        clientfn = TreasureClientFn,

        serverfn = TreasureServerFn,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "athetos_revealed_treasure_boardanim",
        assets = assets_revealed,

        bank = "athetos_revealed_treasure",
        build = "athetos_revealed_treasure",

        clientfn = function(inst)
            inst:AddComponent("highlightchild")
        end,

        serverfn = function(inst)

        end,
    }),
    unpack(hidden_treasure_prefabs)
