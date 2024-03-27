local GaleWeaponCharge = Class(function(self, inst)
	self.inst = inst
	self.moving_vec = nil
	self.percent = net_float(inst.GUID, "GaleWeaponCharge.percent")
end)


function GaleWeaponCharge:AtkPressed(is_free_charge)
	if is_free_charge then
		return self.inst.components.playercontroller:IsAnyOfControlsPressed(
			CONTROL_SECONDARY)
	else
		return self.inst.components.playercontroller:IsAnyOfControlsPressed(
			CONTROL_PRIMARY,
			CONTROL_ATTACK,
			CONTROL_CONTROLLER_ATTACK)
	end

	return false
end

function GaleWeaponCharge:SetPercent(percent)
	self.percent:set(percent)
end

function GaleWeaponCharge:GetPercent()
	return self.percent:value()
end

function GaleWeaponCharge:IsComplete()
	return self:GetPercent() >= 1.0
end

return GaleWeaponCharge
