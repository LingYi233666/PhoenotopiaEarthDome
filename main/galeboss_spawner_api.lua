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
	if TheWorld and TheWorld.shard and TheWorld.shard.shard_galeboss_katash_spawner then
		TheWorld.shard.shard_galeboss_katash_spawner:SetKatashShouldInCave(val)
	end
end)

function GLOBAL.Shard_SyncKatashInCave(val)
	if Shard_IsMaster() then
		if TheWorld and TheWorld.shard and TheWorld.shard.shard_galeboss_katash_spawner then
			TheWorld.shard.shard_galeboss_katash_spawner:SetKatashShouldInCave(val)
		end
	else
		SendModRPCToShard(SHARD_MOD_RPC["gale_rpc"]["katash_should_in_cave"], SHARDID.MASTER, val)
	end
end
