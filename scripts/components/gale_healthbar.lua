local json = require "json"

local function onmax_health(self,val)
	self.inst.replica.gale_healthbar:SetMaxHealth(val)
end

local function onpercent(self,val)
	self.inst.replica.gale_healthbar:SetPercent(val)
end

local function ondebuff_data_json(self,val)
	self.inst.replica.gale_healthbar:SetDebuffData(val)
end

local GaleHealthBar = Class(function(self, inst)
	self.inst = inst

	self.max_health = 100
	self.percent = 1.0
	self.debuff_data = {}
	self.debuff_data_json = ""

	self:UpdateHealth()
	inst:ListenForEvent("healthdelta",function()
		self:UpdateHealth()
	end)

	inst:DoPeriodicTask(0.5,function()
		self:UpdateDebuff()
	end)
end,nil,{
	max_health = onmax_health,
	percent = onpercent,
	debuff_data_json = ondebuff_data_json,
})

function GaleHealthBar:UpdateHealth()
	self.max_health = self.inst.components.health.maxhealth
	self.percent = self.inst.components.health:GetPercent()
end

function GaleHealthBar:UpdateDebuff()
	self.debuff_data = {}
	if self.inst.components.debuffable then 
		for name,v in pairs(self.inst.components.debuffable.debuffs) do 
			local debuff = self.inst.components.debuffable:GetDebuff(name)
			if debuff:HasTag("gale_condition") and debuff.condition_data.shown then 

				-- add
				if not self.debuff_data[name] then
					self.debuff_data[name] = {}
				end

				-- update
				self.debuff_data[name].stacks = debuff.condition_data.stacks
				self.debuff_data[name].dtype = debuff.condition_data.dtype
				self.debuff_data[name].max_stacks = debuff.condition_data.max_stacks
				self.debuff_data[name].buff_name = debuff.condition_data.buff_name
				self.debuff_data[name].image_name = debuff.condition_data.image_name
				self.debuff_data[name].addition_tip = debuff.condition_data.addition_tip or ""
			end
		end

		-- for c_name,data in pairs(self.debuff_data) do 
		-- 	if not self.inst.components.debuffable:GetDebuff(c_name) then 
		-- 		self.debuff_data[name] = nil 
		-- 	end
		-- end
	else
		self.debuff_data = {}
	end
	self.debuff_data_json = json.encode(self.debuff_data)
end


return GaleHealthBar