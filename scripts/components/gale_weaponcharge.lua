local GaleCommon = require("util/gale_common")
local SourceModifierList = require("util/sourcemodifierlist")

local function onpercent(self, percent)
	self.inst.replica.gale_weaponcharge:SetPercent(percent)
end

local GaleWeaponCharge = Class(function(self, inst)
		self.inst = inst
		self.cur_time = 0
		self.state = "RELEASED"
		self.percent = 0
		self.attack_keys = {
			[CONTROL_PRIMARY] = false,
			[CONTROL_SECONDARY] = false,
			[CONTROL_ATTACK] = false,
			[CONTROL_CONTROLLER_ATTACK] = false,
		}


		self.charge_speed_mult = SourceModifierList(self.inst)

		inst:ListenForEvent("newstate", function(inst, data)
			if not inst.sg:HasStateTag("charging_attack") then
				self:Release()
			end
		end)
	end,
	nil,
	{
		percent = onpercent,
	}
)

function GaleWeaponCharge:SetKey(key, pressed)
	if pressed == nil then
		pressed = false
	end

	if self.attack_keys[key] ~= nil then
		self.attack_keys[key] = pressed
	end
end

function GaleWeaponCharge:AtkPressed(is_free_charge)
	if is_free_charge then
		return self.attack_keys[CONTROL_SECONDARY]
	else
		for k, v in pairs(self.attack_keys) do
			if v then
				return v
			end
		end
	end

	return false
end

-- function GaleWeaponCharge:GetFaceVector()
-- 	local angle = (self.inst.Transform:GetRotation() + 90) * DEGREES
-- 	local sinangle = math.sin(angle)
-- 	local cosangle = math.cos(angle)

-- 	return Vector3(sinangle,0,cosangle)
-- end

-- function GaleWeaponCharge:DoCommonAttack()
-- 	local weapon = self.inst.components.combat and self.inst.components.combat:GetWeapon()

-- 	if weapon and weapon.components.gale_chargeable_weapon and weapon.components.gale_chargeable_weapon.common_attack_fn then
-- 		-- params: weapon,attacker,charge_percent
-- 		weapon.components.gale_chargeable_weapon.common_attack_fn(weapon,self.inst,self.percent)
-- 	end
-- end

-- function GaleWeaponCharge:DoSuperAttack()
-- 	local weapon = self.inst.components.combat and self.inst.components.combat:GetWeapon()

-- 	if weapon and weapon.components.gale_chargeable_weapon and weapon.components.gale_chargeable_weapon.super_attack_fn then
-- 		weapon.components.gale_chargeable_weapon.super_attack_fn(weapon,self.inst,self.percent)
-- 	end
-- end

function GaleWeaponCharge:DoAttack(target, target_pos)
	local weapon = self.inst.components.combat and self.inst.components.combat:GetWeapon()

	if weapon and weapon.components.gale_chargeable_weapon and weapon.components.gale_chargeable_weapon.do_attack_fn then
		weapon.components.gale_chargeable_weapon:OnAttack(self.inst, target, target_pos, self.percent)
		self.inst:PushEvent("gale_weaponcharge_doattack",
			{ weapon = weapon, target = target, target_pos = target_pos, percent = self.percent })
	end

	self:Release()


	return true
end

function GaleWeaponCharge:Start()
	self.inst:StartUpdatingComponent(self)
	self.percent = 0
end

function GaleWeaponCharge:Stop()
	self.inst:StopUpdatingComponent(self)
end

function GaleWeaponCharge:Complete()
	self:Stop()
	self.percent = 1
	local weapon = self.inst.components.combat:GetWeapon()
	if weapon and weapon.components.gale_chargeable_weapon then
		weapon.components.gale_chargeable_weapon:Complete()
	end
end

function GaleWeaponCharge:Release()
	self:Stop()
	self.percent = 0
	local weapon = self.inst.components.combat:GetWeapon()
	if weapon and weapon.components.gale_chargeable_weapon then
		weapon.components.gale_chargeable_weapon:Release()
	end
end

function GaleWeaponCharge:GetState()
	local weapon = self.inst.components.combat:GetWeapon()
	if weapon and weapon.components.gale_chargeable_weapon then
		return weapon.components.gale_chargeable_weapon:GetState()
	end
end

function GaleWeaponCharge:IsComplete()
	return self:GetState() == "COMPLETE"
end

function GaleWeaponCharge:IsCharging()
	return self:GetState() == "CHARGING"
end

function GaleWeaponCharge:GetPercent()
	return self.percent
end

function GaleWeaponCharge:OnUpdate(dt)
	local weapon = self.inst.components.combat:GetWeapon()
	if weapon and weapon.components.gale_chargeable_weapon then
		weapon.components.gale_chargeable_weapon:TimeDelta(dt * self.charge_speed_mult:Get())
		self.percent = weapon.components.gale_chargeable_weapon:GetTimePercent()
		if weapon.components.gale_chargeable_weapon:GetState() == "COMPLETE" then
			self:Stop()
		end
	end
end

function GaleWeaponCharge:GetDebugString()
	local s = string.format("moving_vec = %s", tostring(self.moving_vec))
	return s
end

return GaleWeaponCharge
