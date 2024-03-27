local function OnChargeDirty(inst)
	local self = inst.replica.gale_blaster_charge
	local parent = self._last_owner:value()
	local is_equipped = self._is_equipped:value()
	if parent and parent:IsValid() and parent.HUD and parent.HUD.controls and parent.HUD.controls.GaleBlasterChargeUI then 
		if is_equipped then 
			parent.HUD.controls.GaleBlasterChargeUI:SetChargeNum(self:GetCharge())
		end
	end
end

local function OnMaxChargeDirty(inst)
	local self = inst.replica.gale_blaster_charge
	local parent = self._last_owner:value()
	local is_equipped = self._is_equipped:value()
	if parent and parent:IsValid() and parent.HUD and parent.HUD.controls and parent.HUD.controls.GaleBlasterChargeUI then 
		if is_equipped then 
			parent.HUD.controls.GaleBlasterChargeUI:ResetBatteryNum(self:GetMaxCharge())
		end 
	end
end

local function OnSurgeDirty(inst)
	local self = inst.replica.gale_blaster_charge
	local parent = self._last_owner:value()
	local is_equipped = self._is_equipped:value()
	if parent and parent:IsValid() and parent.HUD and parent.HUD.controls and parent.HUD.controls.GaleBlasterChargeUI then 
		if is_equipped then 
			parent.HUD.controls.GaleBlasterChargeUI:SetOverloadNum(self:GetSurge())
		end
	end
end

local function OnIsEquippedDirty(inst)
	local self = inst.replica.gale_blaster_charge
	local parent = self._last_owner:value()
	local is_equipped = self._is_equipped:value()
	if parent and parent:IsValid() and parent.HUD and parent.HUD.controls and parent.HUD.controls.GaleBlasterChargeUI then 
		if not is_equipped then 
			parent.HUD.controls.GaleBlasterChargeUI:SetChargeNum(0,true)
			parent.HUD.controls.GaleBlasterChargeUI:SetOverloadNum(0)
			parent.HUD.controls.GaleBlasterChargeUI:Hide()
		else
			parent.HUD.controls.GaleBlasterChargeUI:Show()
			parent.HUD.controls.GaleBlasterChargeUI:ResetBatteryNum(self:GetMaxCharge())
			parent.HUD.controls.GaleBlasterChargeUI:SetChargeNum(self:GetCharge())
			parent.HUD.controls.GaleBlasterChargeUI:SetOverloadNum(self:GetSurge())
		end
	end
end

local GaleBlasterCharge = Class(function(self, inst)
	self.inst = inst

	self._charge = net_ushortint(inst.GUID, "GaleBlasterCharge._charge","blaster_charge_dirty")
	self._max_charge = net_ushortint(inst.GUID, "GaleBlasterCharge._max_charge","blaster_max_charge_dirty") 
	self._surge = net_ushortint(inst.GUID, "GaleBlasterCharge._surge","blaster_surge_dirty")

	self._last_owner = net_entity(inst.GUID,"GaleBlasterCharge._last_owner","blaster_last_owner_dirty")
	self._is_equipped = net_bool(inst.GUID,"GaleBlasterCharge._is_equipped","blaster_is_equipped_dirty")

	if not TheNet:IsDedicated() then 
		inst:ListenForEvent("blaster_charge_dirty",OnChargeDirty)
		inst:ListenForEvent("blaster_max_charge_dirty",OnMaxChargeDirty)
		inst:ListenForEvent("blaster_surge_dirty",OnSurgeDirty)
		inst:ListenForEvent("blaster_is_equipped_dirty",OnIsEquippedDirty)
	end  
end)

function GaleBlasterCharge:SetCharge(val)
	self._charge:set(val)
end

function GaleBlasterCharge:SetMaxCharge(val)
	self._max_charge:set(val)
end

function GaleBlasterCharge:SetSurge(val)
	self._surge:set(val)
end

function GaleBlasterCharge:GetCharge()
	return self._charge:value()
end

function GaleBlasterCharge:GetMaxCharge()
	return self._max_charge:value()
end

function GaleBlasterCharge:GetSurge()
	return self._surge:value()
end

return GaleBlasterCharge