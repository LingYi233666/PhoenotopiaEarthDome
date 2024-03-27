-- AddPrefabPos


-- TheWorld.components.galeboss_ruinforce_spawner:SpawnAt(ThePlayer,30)
AddPrefabPostInit("forest", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("galeboss_ruinforce_spawner")

	-- inst:AddComponent("galeboss_katash_spawner")
end)
