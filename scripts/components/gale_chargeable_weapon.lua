local GaleChargeableWeapon = Class(function(self, inst)
	self.inst = inst
	-- self.common_attack_fn = nil
	-- self.super_attack_fn = nil
	self.do_attack_fn = nil

	self.never_charge = false

	self.state = "RELEASED"

	self.need_time = 1.2
	self.cur_time = 0

	inst:AddTag("allow_action_on_impassable")
	inst:AddTag("gale_chargeable_weapon")

	inst:ListenForEvent("unequipped", function()
		self:Release()
	end)

	inst:ListenForEvent("onremove", function()
		self:Release()
	end)
end)

function GaleChargeableWeapon:Release()
	self:TimeDelta(-self.need_time)
end

function GaleChargeableWeapon:Complete()
	self:TimeDelta(self.need_time)
end

function GaleChargeableWeapon:GetState()
	return self.state
end

function GaleChargeableWeapon:TimeDelta(delta)
	local old = self.cur_time
	local old_percent = self:GetTimePercent()

	if self.never_charge then
		self.cur_time = 0
	else
		self.cur_time = math.clamp(self.cur_time + delta, 0, self.need_time)
	end

	if self.cur_time >= self.need_time then
		self.state = "COMPLETE"
	elseif self.cur_time <= 0 then
		self.state = "RELEASED"
	else
		self.state = "CHARGING"
	end
	self.inst:PushEvent("gale_charge_time_change", {
		old = old,
		old_percent = old_percent,
		current = self.cur_time,
		current_percent = self:GetTimePercent(),
	})
end

function GaleChargeableWeapon:GetTimePercent()
	return self.cur_time / self.need_time
end

function GaleChargeableWeapon:OnAttack(owner, target, target_pos, percent_override)
	local percent = percent_override or self:GetTimePercent()
	if self.do_attack_fn then
		self.do_attack_fn(self.inst, owner, target, target_pos, percent)
		self.inst:PushEvent("gale_chargeable_weapon_onattack",
			{ owner = owner, target = target, target_pos = target_pos, percent = percent })
	end
end

return GaleChargeableWeapon
