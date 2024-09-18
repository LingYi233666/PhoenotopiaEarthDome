local addition_assets_client_dict = {}
local addition_assets_server_dict = {}


local function AutoAddAtlasBuild_Internal(xml_path, search_dict, add_to_client_also)
    if search_dict[xml_path] then
        return
    end
    search_dict[xml_path] = true


    local prefabname = TheWorld.ismastersim and "GALE_ATLAS_BUILD_ADD_SERVER_" or
        "GALE_ATLAS_BUILD_ADD_CLIENT_"
    prefabname = prefabname .. xml_path:gsub("/", "-")

    print("AutoAddAtlasBuild_Internal:", xml_path, prefabname)

    local add_assets = {
        Asset("ATLAS_BUILD", xml_path, 256),
    }

    local prefab = Prefab(prefabname, nil, add_assets, nil, true)
    RegisterPrefabs(prefab)
    TheSim:LoadPrefabs({ prefabname })

    if add_to_client_also and TheWorld.ismastersim then
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["auto_add_atlas_build"], nil, xml_path)
    end
end


AddClientModRPCHandler("gale_rpc", "auto_add_atlas_build", function(xml_path)
    AutoAddAtlasBuild_Internal(xml_path, addition_assets_client_dict)
end)

AddClientModRPCHandler("gale_rpc", "auto_add_atlas_build_sync", function(str_zipped)
    local sync_xml_paths = DecodeAndUnzipString(str_zipped)
    print("Auto add atlas build sync from server")
    for _, xml_path in pairs(sync_xml_paths) do
        AutoAddAtlasBuild_Internal(xml_path, addition_assets_client_dict)
    end
end)

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("playeractivated", function(inst, player)
        local str_zipped = ZipAndEncodeString(addition_assets_server_dict)
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["auto_add_atlas_build_sync"], player.userid, str_zipped)
    end)
end)


function GLOBAL.AutoAddAtlasBuild(xml_path)
    AutoAddAtlasBuild_Internal(xml_path, addition_assets_server_dict, true)
end
