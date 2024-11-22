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

AddPrefabPostInit("daywalker", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("athetos_berserker_enchant")
	inst.components.athetos_berserker_enchant:SetChargeFn(function()
		return math.random(7, 13) + math.random(7, 13)
	end)
	inst.components.athetos_berserker_enchant:SetTarget(inst)

	if TheWorld.components.daywalkerspawner
		and not TheWorld.components.daywalkerspawner.athetos_amulet_berserker_dropped then
		-- Change hand symbols with athetos_amulet_berserker
		inst.AnimState:OverrideSymbol("ww_hand", "daywalker_phase2_berserker_amulet", "ww_hand")
	end


	local old_MakeUnchained = inst.MakeUnchained
	inst.MakeUnchained = function(...)
		local rets = old_MakeUnchained(...)
		if TheWorld.components.daywalkerspawner and not TheWorld.components.daywalkerspawner.athetos_amulet_berserker_dropped then
			-- Change hand symbols with athetos_amulet_berserker
			inst.AnimState:OverrideSymbol("ww_hand", "daywalker_phase2_berserker_amulet", "ww_hand")
		end
		return rets
	end


	inst:ListenForEvent("minhealth", function()
		if inst.defeated then
			local pos = inst:GetPosition()

			if TheWorld.components.daywalkerspawner
				and not TheWorld.components.daywalkerspawner.athetos_amulet_berserker_dropped then
				-- Change hand symbols without athetos_amulet_berserker
				inst.AnimState:ClearOverrideSymbol("ww_hand")

				if inst.components.lootdropper then
					inst.components.lootdropper:SpawnLootPrefab("athetos_amulet_berserker_broken", pos)
					inst.components.lootdropper:SpawnLootPrefab("athetos_amulet_berserker_broken", pos)

					TheWorld.components.daywalkerspawner.athetos_amulet_berserker_dropped = true
				end
			end

			if inst.components.lootdropper then
				inst.components.lootdropper:SpawnLootPrefab("athetos_amulet_berserker_blueprint", pos)
			end
		end
	end)
end)

AddComponentPostInit("daywalkerspawner", function(self)
	self.athetos_amulet_berserker_dropped = false

	local old_OnSave = self.OnSave
	local old_OnLoad = self.OnLoad

	function self:OnSave()
		local data, refs = old_OnSave(self)
		data.athetos_amulet_berserker_dropped = self.athetos_amulet_berserker_dropped

		return data, refs
	end

	function self:OnLoad(data, ...)
		old_OnLoad(data, ...)
		if data ~= nil then
			if data.athetos_amulet_berserker_dropped ~= nil then
				self.athetos_amulet_berserker_dropped = data.athetos_amulet_berserker_dropped
			end
		end
	end
end)
