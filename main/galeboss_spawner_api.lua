-- AddPrefabPos


-- TheWorld.components.galeboss_ruinforce_spawner:SpawnAt(ThePlayer,30)
AddPrefabPostInit("forest", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("galeboss_ruinforce_spawner")
	inst:AddComponent("galeboss_katash_spawner")
end)

AddPrefabPostInit("shard_network", function(inst)
	inst:AddComponent("shard_galeboss_katash_spawner")
end)

AddPrefabPostInit("cave", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("galeboss_katash_spawner_cave")
end)

AddShardModRPCHandler("gale_rpc", "katash_should_in_cave", function(shardid, val)
	Shard_SyncKatashInCave(val)
end)

function GLOBAL.Shard_SyncKatashInCave(val)
	if Shard_IsMaster() then
		TheWorld:PushEvent("master_shardkatashincave", { incave = val })
	else
		SendModRPCToShard(SHARD_MOD_RPC["gale_rpc"]["katash_should_in_cave"], SHARDID.MASTER, val)
	end
end
