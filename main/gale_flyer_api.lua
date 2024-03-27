AddComponentPostInit("drownable",function(self)
	local old_ShouldDrown = self.ShouldDrown
	self.ShouldDrown = function(self, ... )
		return old_ShouldDrown(self, ... ) 
		and not (self.inst.components.gale_flyer and self.inst.components.gale_flyer:IsFlying())
	end
end)

AddComponentPostInit("locomotor",function(self)
	local old_WalkForward = self.WalkForward
	self.WalkForward = function(self,...)
		local old_ret = old_WalkForward(self,...)
		if self.inst.components.gale_flyer and self.inst.components.gale_flyer:IsEnable() then 
			self.inst.components.gale_flyer:UpdateSpeed()
		end

		return old_ret
	end

	local old_RunForward = self.RunForward
	self.RunForward = function(self,...)
		local old_ret = old_RunForward(self,...)
		if self.inst.components.gale_flyer and self.inst.components.gale_flyer:IsEnable() then 
			self.inst.components.gale_flyer:UpdateSpeed()
		end

		return old_ret
	end

	local old_ScanForPlatform = self.ScanForPlatform
	self.ScanForPlatform = function(self,...)
		local can_hop, hop_x, hop_z, target_platform, blocked = old_ScanForPlatform(self,...)
		if self.inst.components.gale_flyer and self.inst.components.gale_flyer:IsFlying() then 
			can_hop = false 
		end

		return can_hop, hop_x, hop_z, target_platform, blocked
	end
end)

AddPlayerPostInit(function(inst)
	if not TheWorld.ismastersim then 
		return inst
	end 

	inst:AddComponent("gale_flyer")
end)