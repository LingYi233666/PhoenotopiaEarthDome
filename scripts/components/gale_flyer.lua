local GaleFlyer = Class(function(self,inst)
	self.inst = inst

	self.target_height = 0
	self.enable = false

	self.speed_fn = nil 

	self.state = "NONE"
	self:Enable(true)
end)

-- function GaleFlyer:Enable(enable,height)
-- 	local old_enable = self.enable
-- 	self.enable = enable
-- 	if old_enable and not enable then 
-- 		self.target_height = 0
-- 	elseif not old_enable and enable then 
-- 		self.target_height = height or 15
-- 	end
-- end

function GaleFlyer:IsFlying()
	return self.enable and self.state == "FLYING"
end

function GaleFlyer:IsEnable()
	return self.enable
end

-- ThePlayer.components.gale_flyer:SetHeight(5)
function GaleFlyer:Enable(enable)
	local old_enable = self.enable
	self.enable = enable
	if old_enable and not enable then 
		self.inst:StopUpdatingComponent(self)
	elseif not old_enable and enable then 
		self.inst:StartUpdatingComponent(self)
	end
end

function GaleFlyer:SetHeight(height)
	local old_height = self.target_height
	self.target_height = height

	if height > 0 then 
		self.state = "FLYING"
	elseif old_height > 0 then 
		self.state = "LANDING"
	end
end

function GaleFlyer:UpdateSpeed()
	if self.state ~= "NONE" then 
		local vx,vy,vz = self.inst.Physics:GetMotorVel()
		local cur_height = self.inst:GetPosition().y 
		local delta_y = (self.target_height - cur_height)

		vy = self.speed_fn and self.speed_fn(self.inst,cur_height,self.target_height) or (delta_y * 3.2)
		self.inst.Physics:SetMotorVel(vx,vy,vz)

		if self.state == "LANDING" and math.abs(delta_y) <= 0.05 then 
			local x,y,z = self.inst:GetPosition():Get()
			self.inst.Transform:SetPosition(x,0,z)
			self.state = "NONE"
		end
	end 
end

function GaleFlyer:OnUpdate(dt)
	self:UpdateSpeed()
	if self:IsFlying() then 
		if self.inst.DynamicShadow then 
			self.inst.DynamicShadow:Enable(false)
		end
	else
		if self.inst.DynamicShadow then 
			self.inst.DynamicShadow:Enable(true)
		end
	end
end

-- function GaleFlyer:OnSave()
-- 	local data = {}
-- 	data.target_height = self.target_height
-- 	data.state = self.state
-- 	return data
-- end

-- function GaleFlyer:OnLoad(data)
-- 	if data then 
-- 		if data.target_height ~= nil then 
-- 			self.target_height = data.target_height
-- 		end
-- 		if data.state ~= nil then 
-- 			self.state = data.state
-- 		end
-- 	end
-- end

return GaleFlyer