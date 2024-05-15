-- local addition_assets_client_dict = {}
-- local addition_assets_server_dict = {}


-- function AutoAddAtlasBuild(xml_path, search_dict, add_to_client_also)
--     if search_dict[xml_path] then
--         return
--     end
--     search_dict[xml_path] = true

--     print("AutoAddAtlasBuild:", xml_path)

--     local prefabname = TheWorld.ismastersim and "GALE_ATLAS_BUILD_ADD_SERVER_" or
--         "GALE_ATLAS_BUILD_ADD_CLIENT_"
--     prefabname = prefabname .. xml_path:gsub("/", "-")

--     local add_assets = {
--         Asset("ATLAS_BUILD", xml_path, 256),
--     }

--     local prefab = Prefab(prefabname, nil, add_assets, nil, true)
--     RegisterPrefabs(prefab)
--     TheSim:LoadPrefabs({ prefabname })

--     if add_to_client_also and TheWorld.ismastersim then

--     end
-- end

-- AddClientModRPCHandler("gale_rpc", "auto_add_atlas_build", function(xml_path)
--     AutoAddAtlasBuild(xml_path, addition_assets_client_dict)
-- end)
