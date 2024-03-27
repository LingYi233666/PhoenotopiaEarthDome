local GaleStamina = Class(function(self, inst)
	self.inst = inst 
	self._current = net_ushortint(inst.GUID, "gale_stamina._current")
    self._max = net_ushortint(inst.GUID, "gale_stamina._max")
end)

function GaleStamina:SetMax(max)
	self._max:set(max)
end

function GaleStamina:SetVal(current)
	current = math.max(0,current)
	current = math.min(self._max:value(),current)
	self._current:set(current)
end

function GaleStamina:GetCurrent()
	return self._current:value()
end

function GaleStamina:GetMax()
	return self._max:value()
end 

function GaleStamina:GetPercent()
	return self:GetCurrent() / self:GetMax()
end


return GaleStamina