local json = require "json"
local GaleHealthBar = Class(function(self, inst)
	self.inst = inst

	self._max_health = net_float(inst.GUID,"GaleHealthBar._max_health")
	self._percent = net_float(inst.GUID,"GaleHealthBar._percent")
	self._debuff_data_json = net_string(inst.GUID,"GaleHealthBar._debuff_data_json")
end)

function GaleHealthBar:SetMaxHealth(val)
	self._max_health:set(val)
end

function GaleHealthBar:SetPercent(val)
	self._percent:set(val)
end

function GaleHealthBar:SetDebuffData(str)
	if str then 
		self._debuff_data_json:set(str)
	end 
end

function GaleHealthBar:GetMaxHealth()
	return self._max_health:value()
end

function GaleHealthBar:GetPercent()
	return self._percent:value()
end

function GaleHealthBar:GetDebuffData()
	local val = self._debuff_data_json:value()
	return string.len(val) > 0 and json.decode(val) or {}
end

return GaleHealthBar