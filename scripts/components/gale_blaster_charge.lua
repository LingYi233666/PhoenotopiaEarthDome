local function oncharge(self, charge)
	self.inst.replica.gale_blaster_charge:SetCharge(charge)
end

local function onmax_charge(self, max_charge)
	self.inst.replica.gale_blaster_charge:SetMaxCharge(max_charge)
end

local function onsurge(self, surge)
	self.inst.replica.gale_blaster_charge:SetSurge(surge)
end

local GaleBlasterCharge = Class(function(self, inst)
	self.inst = inst
	self.charge = 0
	self.max_charge = 4
	self.surge = 0
	self.max_surge = 99


	self.ChargeTask = inst:DoPeriodicTask(5,function()
		self:DoDeltaCharge(1)
	end)
	self.CoolSurgeTask = inst:DoPeriodicTask(8,function()
		self:DoDeltaSurge(math.floor(-self.surge / 2))
	end)

	inst:ListenForEvent("equipped",function(inst,data)
		inst.replica.gale_blaster_charge._last_owner:set(data.owner)
		inst.replica.gale_blaster_charge._is_equipped:set(true)
	end)

	inst:ListenForEvent("unequipped",function()
		inst.replica.gale_blaster_charge._is_equipped:set(false)
	end)

	inst:ListenForEvent("onremove",function()
		inst.replica.gale_blaster_charge._is_equipped:set(false)
	end)
end,nil,{
	charge = oncharge,
	max_charge = onmax_charge,
	surge = onsurge,
})

function GaleBlasterCharge:GetCharge()
	return self.charge
end

function GaleBlasterCharge:GetMaxCharge()
	return self.max_charge
end

function GaleBlasterCharge:GetEmptyCharge()
	return self.max_charge - self.charge
end

function GaleBlasterCharge:GetSurge()
	return self.surge
end

function GaleBlasterCharge:GetMaxSurge()
	return self.max_surge
end

function GaleBlasterCharge:IsFull()
	return self.charge >= self.max_charge
end

function GaleBlasterCharge:IsEmpty()
	return self.charge <= 0 
end

function GaleBlasterCharge:DoDeltaCharge(delta)
	local old_charge = self:GetCharge()
	if delta > self:GetEmptyCharge() then 
		local sub = delta - self:GetEmptyCharge()
		self:DoDeltaSurge(sub)
	end
	self.charge = math.clamp(self.charge+delta,0,self.max_charge)
	local new_charge = self:GetCharge()
	self.inst:PushEvent("chargedelta",{old=old_charge,new=new_charge,try_delta=delta,real_delta=new_charge-old_charge})
	return new_charge - old_charge
end

function GaleBlasterCharge:DoDeltaSurge(delta)
	local old_surge = self:GetSurge()
	self.surge = math.clamp(self.surge+delta,0,self.max_surge)
	local new_surge = self:GetSurge()
	self.inst:PushEvent("surgedelta",{old=old_surge,new=new_surge,try_delta=delta,real_delta=new_surge-old_surge})
	return new_surge - old_surge
end


return GaleBlasterCharge