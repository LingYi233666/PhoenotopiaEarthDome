local function light()
	local inst = CreateEntity()
	
	inst.persists = false
	
	inst.entity:AddTransform()
	inst.entity:AddLight()
	
	inst.Light:SetRadius(0.5)
	inst.Light:SetIntensity(1)
	inst.Light:SetFalloff(1)
	inst.Light:SetColour(1, 1, 1)
	inst.Light:Enable(true)
		
	inst:AddTag("CLASSIFIED")
		
		
	return inst
end

return Prefab("gale_test_room_light",light)