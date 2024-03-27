AddPrefabPostInit("forest",function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("athetos_treasure_spawner")
end)
