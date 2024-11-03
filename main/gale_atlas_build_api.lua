addition_assets_client_dict = {}
addition_assets_server_dict = {}

GLOBAL.addition_assets_client_dict = addition_assets_client_dict
GLOBAL.addition_assets_server_dict = addition_assets_server_dict

-- dumptable(addition_assets_client_dict)
-- dumptable(addition_assets_server_dict)

local function AutoAddAtlasBuild_Internal(xml_path, search_dict, add_to_client_also)
    if search_dict[xml_path] then
        return
    end
    search_dict[xml_path] = true

    print("AutoAddAtlasBuild_Internal:", xml_path)


    local prefabname = TheWorld.ismastersim and "GALE_ATLAS_BUILD_ADD_SERVER_" or
        "GALE_ATLAS_BUILD_ADD_CLIENT_"
    prefabname = prefabname .. xml_path:gsub("/", "-")


    local add_assets = {
        Asset("ATLAS_BUILD", xml_path, 256),
    }

    local prefab = Prefab(prefabname, nil, add_assets, nil, true)
    RegisterPrefabs(prefab)
    TheSim:LoadPrefabs({ prefabname })

    if add_to_client_also then
        for _, v in pairs(AllPlayers) do
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["auto_add_atlas_build"], v.userid, xml_path)
        end
    end
end


AddClientModRPCHandler("gale_rpc", "auto_add_atlas_build", function(xml_path)
    AutoAddAtlasBuild_Internal(xml_path, addition_assets_client_dict)
end)

AddClientModRPCHandler("gale_rpc", "auto_add_atlas_build_sync", function(str_zipped)
    local sync_xml_paths = DecodeAndUnzipString(str_zipped)
    print("Auto add atlas build sync from server:")
    dumptable(sync_xml_paths)

    -- for _, xml_path in pairs(sync_xml_paths) do
    --     print("Processing:", xml_path)
    --     AutoAddAtlasBuild_Internal(xml_path, addition_assets_client_dict)
    -- end

    for xml_path, boolean in pairs(sync_xml_paths) do
        print("Processing:", xml_path, boolean)
        AutoAddAtlasBuild_Internal(xml_path, addition_assets_client_dict)
    end
end)



function GLOBAL.AutoAddAtlasBuild(xml_path)
    AutoAddAtlasBuild_Internal(xml_path, addition_assets_server_dict, true)
end

function GLOBAL.SyncAtlasBuild(userid)
    local str_zipped = ZipAndEncodeString(addition_assets_server_dict)
    print("Server send auto_add_atlas_build_sync:")
    dumptable(addition_assets_server_dict)
    SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["auto_add_atlas_build_sync"], userid, str_zipped)
end

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("playeractivated", function(inst, player)
        SyncAtlasBuild(player.userid)
    end)

    -- inst:DoTaskInTime(5, function()
    --     for _, v in pairs(AllPlayers) do
    --         SyncAtlasBuild(v.userid)
    --     end
    -- end)
end)

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(3, function()
        if inst.userid then
            SyncAtlasBuild(inst.userid)
        end
    end)
end)
