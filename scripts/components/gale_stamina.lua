local easing = require("easing")
local SourceModifierList = require("util/sourcemodifierlist")

local function onmax(self, max)
	self.inst.replica.gale_stamina:SetMax(max)
end

local function oncurrent(self, current)
	self.inst.replica.gale_stamina:SetVal(current)
end

local function PunishWhenLowStamina(inst)
	if inst.components.gale_stamina:GetPercent() <= inst.components.gale_stamina.low_percent then
		local rand = math.random() * inst.components.gale_stamina:GetPercent()
		if rand <= 0.05 then
			inst.sg:GoToState("gale_tired_low_stamina")
		end
	end
end

local GaleStamina = Class(
	function(self, inst)
		self.inst = inst

		self.max = 100
		self.current = self.max

		-- When stamina percent lower than this value,Gale can't do anything
		self.low_percent = 0.1

		self.recoverrate = 1
		self.recoverrate_multipliers = SourceModifierList(self.inst)
		self.consumerate = 1
		self.consumerate_multipliers = SourceModifierList(self.inst)
		self.pausetimerate = 1
		self.pausetimerate_multipliers = SourceModifierList(self.inst)

		self.cant_recover_until_time = -1

		inst:StartUpdatingComponent(self)

		-- Actions in this tab will cost stamina and pause recovery
		self.actions_cost_tab = {
			[ACTIONS.ATTACK] = {
				cost = function(bufferedaction)
					local weapon = inst.components.combat:GetWeapon()
					if weapon and weapon.components.weapon then
						-- gale_bombbox cost will be at newstate
						if weapon.prefab == "gale_bombbox" then
							return
						end

						if weapon.prefab == "gale_blaster_katash" then
							return 15
						end

						if weapon.prefab == "gale_spear" then
							return 12
						end

						if weapon.prefab == "msf_silencer_pistol" and not weapon:HasTag("gale_blaster_jammed") then
							return 1
						end

						local range = weapon.components.weapon.attackrange or 0
						local damage = weapon.components.weapon:GetDamage(self.inst, bufferedaction.target) or 0
						if range > 3.5 then
							return 15 * Remap(math.clamp(damage, 0, 34), 0, 34, 0.1, 1)
						else
							return 3
						end
					else
						return 3
					end
				end,
				pausetime = function(bufferedaction)
					local weapon = inst.components.combat:GetWeapon()
					if weapon and weapon.components.weapon then
						-- gale_bombbox pause will be at newstate
						if weapon.prefab == "gale_bombbox" then
							return
						end

						-- Test
						if weapon.prefab == "gale_blaster_katash" then
							return 3
						end

						if weapon.prefab == "gale_spear" then
							return 2
						end

						if weapon.prefab == "msf_silencer_pistol" and not weapon:HasTag("gale_blaster_jammed") then
							return FRAMES
						end

						local range = weapon.components.weapon.attackrange or 0
						local damage = weapon.components.weapon:GetDamage(self.inst, bufferedaction.target) or 0

						if range > 3.5 then
							return 3 * Remap(math.clamp(damage, 0, 20), 0, 20, 0.1, 1)
						else
							return 1
						end
					end
				end,
			},
			-- [ACTIONS.PICK] = {cost = 7,pausetime = 0.3},
			-- [ACTIONS.MINE] = {cost = 7,pausetime = 0.5,},
			-- [ACTIONS.HAMMER] = {cost = 5,pausetime = 0.5,},
			-- [ACTIONS.DIG] = {cost = 6,pausetime = 1.0},
			-- [ACTIONS.CHOP] = {cost = 1,pausetime = 0.5,},
		}

		-- Actions Consume Listening
		inst:ListenForEvent("performaction", function(player, data)
			local bufferedaction = data.action
			local data = bufferedaction and bufferedaction.action and
				self.actions_cost_tab[bufferedaction.action]

			if data then
				local cost = FunctionOrValue(data.cost, bufferedaction) or 0
				local pausetime = FunctionOrValue(data.pausetime, bufferedaction) or 0

				self:DoDelta(-cost * self:GetConsumeRate())
				self:Pause(pausetime * self:GetPausetimeRate())
			end
		end)

		inst:ListenForEvent("newstate", function(inst, data)
			if inst.sg:HasStateTag("charging_attack_pre") then
				local weapon = inst.components.combat:GetWeapon()
				if weapon and weapon.components.weapon then
					if weapon.prefab == "gale_spear" then
						self:DoDelta(-12 * self:GetConsumeRate())
						self:Pause(2 * self:GetPausetimeRate())
					elseif weapon.prefab == "gale_bombbox" then
						self:DoDelta(-15 * self:GetConsumeRate())
						self:Pause(2 * self:GetPausetimeRate())
					else
						local range = weapon.components.weapon.attackrange or 0
						if range > 3.5 then
							self:DoDelta(-20 * self:GetConsumeRate())
							self:Pause(3 * self:GetPausetimeRate())
						else
							self:DoDelta(-8 * self:GetConsumeRate())
							self:Pause(1 * self:GetPausetimeRate())
						end
					end
				end
			end

			if (self.inst.sg:HasStateTag("busy") or self.inst.sg:HasStateTag("attack") or self.inst.sg:HasStateTag("working"))
				and not inst.sg:HasStateTag("dead")
				and not inst.sg:HasStateTag("gale_tired_low_stamina")
				and not IsEntityDeadOrGhost(inst) then
				PunishWhenLowStamina(inst)
			end
		end)
	end,
	nil,
	{
		max = onmax,
		current = oncurrent,
	}
)


function GaleStamina:SetMax(max)
	self.max = max
	self.current = self.max
	self:DoDelta(0)
end

function GaleStamina:SetVal(val)
	self.current = math.clamp(val, 0, self.max)
end

function GaleStamina:SetPercent(percent)
	self:SetVal(percent * self.max)
	self:DoDelta(0)
end

function GaleStamina:DoDelta(delta)
	local old_val = self.current
	local old_percent = self:GetPercent()
	self:SetVal(self.current + delta)
	local new_val = self.current
	local new_percent = self:GetPercent()

	self.inst:PushEvent("staminadelta",
						{ old_val = old_val, oldpercent = old_percent, new_val = new_val, newpercent = new_percent })
end

function GaleStamina:GetPercent()
	return self.current / self.max
end

-- Note: Naturally Recover Rate Only
function GaleStamina:GetRecoverRate()
	return self.recoverrate * self.recoverrate_multipliers:Get()
end

-- Note: Action Consume Rate Only
function GaleStamina:GetConsumeRate()
	return self.consumerate * self.consumerate_multipliers:Get()
end

-- Note: Action Consume Rate Only
function GaleStamina:GetPausetimeRate()
	return self.pausetimerate * self.pausetimerate_multipliers:Get()
end

function GaleStamina:Pause(delaytime)
	self.cant_recover_until_time = math.max(self.cant_recover_until_time, GetTime() + delaytime)
end

function GaleStamina:Resume()
	self.cant_recover_until_time = -1
end

function GaleStamina:OnUpdate(dt)
	if self.inst.sg:HasStateTag("gale_tired_low_stamina") then
		self:DoDelta(dt * 3 * self:GetRecoverRate())
	else
		if GetTime() >= self.cant_recover_until_time then
			if self.inst.sg:HasStateTag("charging_attack_pre") then
				self:DoDelta(dt * 6 * self:GetRecoverRate())
			elseif not self.inst.sg:HasStateTag("busy") then
				-- Naturally Recover
				self:DoDelta(dt * 10 * self:GetRecoverRate())
			end
		else
			-- Pause the recover
		end
	end
end

function GaleStamina:OnSave()
	return {
		current = self.current
	}
end

function GaleStamina:OnLoad(data)
	if data then
		if data.current ~= nil then
			self.current = data.current
		end
	end
	self:DoDelta(0)
end

GaleStamina.LongUpdate = GaleStamina.OnUpdate

return GaleStamina
