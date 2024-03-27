local Widget = require "widgets/widget" 
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local GaleSubBuffTip = require "widgets/galesubbufftip"

local GaleChargeBattery = Class(Widget, function(self)
	Widget._ctor(self, "GaleChargeBattery")

	self.cell_num = -1
	self.charged = false
	self.slient = false

	self.battery_main = self:AddChild(Widget("GaleChargeBatteryMain"))
	self.battery_main:SetScale(0.18)

	self.battery = self.battery_main:AddChild(UIAnim())
	self.battery:GetAnimState():SetBank("ui_rook_charge_fx")
    self.battery:GetAnimState():SetBuild("ui_rook_charge_fx")
    self.battery:GetAnimState():SetDeltaTimeMultiplier(0.8)

 --    self.battery_hover = self:AddChild(UIAnim())
	-- self.battery_hover:GetAnimState():SetBank("ui_rook_charge_fx")
 --    self.battery_hover:GetAnimState():SetBuild("ui_rook_charge_fx")
 --    self.battery_hover:GetAnimState():HideSymbol("shield_resize")
 --    self.battery_hover:GetAnimState():PlayAnimation("cell_charged")
 --    self.battery_hover:Hide()
 --    if not self.battery_hover.inst.components.uianim then
 --        self.battery_hover.inst:AddComponent("uianim")
 --    end



    self.elec = self.battery_main:AddChild(UIAnim())
	self.elec:GetAnimState():SetBank("ui_rook_charge_fx")
    self.elec:GetAnimState():SetBuild("ui_rook_charge_fx")
    self.elec:GetAnimState():SetDeltaTimeMultiplier(0.6)
    self.elec:SetPosition(30,-30,0)
    self.elec:SetScale(1.2,1,1)

    self.spike = self.battery_main:AddChild(UIAnim())
    self.spike:GetAnimState():SetBank("ui_rook_charge_fx")
    self.spike:GetAnimState():SetBuild("ui_rook_charge_fx")
    self.spike:SetScale(1,1,1)
    self.spike:GetAnimState():SetDeltaTimeMultiplier(0.4)

	self.tip = self:AddChild(GaleSubBuffTip())
	self.tip:SetBuffName(STRINGS.NAMES.CONDITION_GALE_BLASTER_CHARGE)
	self.tip:SetBuffDesc(STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_CHARGE.STATIC)
	self.tip:SetPosition(0,125)
	self.tip:SetScale(1)
	self.tip:Hide()

    -- self.test_img = self:AddChild(Image("fx/explode_rain.xml", "explode_rain.tex"))
    -- self.test_img:SetTexture("images/frontscreen.xml", "snow.tex")
    -- self.test_img:SetScale(10,10,10)
    -- self:SetScale(0.18)

    -- self:SetClickable(true)
    -- self.on
    -- self:SetTooltip(TOOL_TIP)
    -- self:SetTooltipPos(0,60,0)
    self:Uncharge(true,true)
end)

function GaleChargeBattery:TriggerSound(is_chargeup)
	if self.slient or not is_chargeup then 
		return 
	end 

	local path = is_chargeup and "rook_charge_sound/sfx/GL_RookChargeUp_v2_" or "rook_charge_sound/sfx/sfx_battle_cards_negotiation_actions_have_gone_up_01"
	local cell_num = self.cell_num
	if cell_num <= 1 then 
		cell_num = 1
	end
	if cell_num >= 4 then 
		cell_num = 4
	end 
	-- if not is_chargeup and cell_num >= 3 then 
	-- 	cell_num = math.random(1,3)
	-- end
	-- TheFocalPoint.SoundEmitter:PlaySound(path..tostring(cell_num))
	TheFocalPoint.SoundEmitter:PlaySoundWithParams(is_chargeup and (path..tostring(cell_num)) or path, {intensity=GetRandomMinMax(0.3,0.5)})
end



function GaleChargeBattery:SpawnVFX2(data)
	data = data or {}
	local delay = data.delay or 0
	local pos = data.pos or Vector3(20,30,0)
	local roa_range = data.roa_range or {PI/9,PI/2.5}
	local create_count = data.create_count or math.random(20,25)

	for i=1,create_count do 
		-- local ui_effect = self:AddChild(Image(resolvefilepath("fx/explode_rain.xml"), "explode_rain.tex"))
		local ui_effect = self.battery_main:AddChild(UIAnim())
		ui_effect:GetAnimState():SetBank("ui_rook_charge_fx")
    	ui_effect:GetAnimState():SetBuild("ui_rook_charge_fx")
    	ui_effect:GetAnimState():PlayAnimation("rock")
    	ui_effect:MoveToBack()
		local roa = GetRandomMinMax(roa_range[1],roa_range[2])
		local acceleration = GetRandomMinMax(-70,-120)
		local start_rad = GetRandomMinMax(0,3) 
		local start_speed = GetRandomMinMax(15,25)
		local start_vec = Vector3(math.cos(roa),math.sin(roa),0) * start_rad
		local start_pos = pos + start_vec

		ui_effect:SetPosition(start_pos)
		ui_effect.speed = start_speed
		ui_effect.delay = delay
		ui_effect.OnUpdate = function(him,dt)
			dt = dt or FRAMES
			if him.delay > 0 then 
				him.delay = him.delay - dt 
				him:Hide()
				return 
			end
			him:Show()

			local current_pos = him:GetPosition()
			local move_vec = Vector3(math.cos(roa),math.sin(roa),0) * him.speed
			him:SetPosition(current_pos + move_vec)
			him.speed = him.speed + dt * acceleration
			local scale = him.speed / start_speed
			him:SetScale(scale,scale,scale)
			if him.speed <= 0 then 
				self:RemoveChild(him)
				him:Kill()
			end
		end
		ui_effect:StartUpdating()
	end
end

local TINT_START = {r = 1,g = 1,b = 1,a = 1}
local TINT_END = {r = 1,g = 1,b = 1,a = 0}
local PREPARE_DURATION = 0.15
local TINT_DURATION = 0.33
local START_SCALE = 1
local END_SCALE = 1.2

function GaleChargeBattery:Charge(force)
	if self.charged == false or force then 
		self.battery:GetAnimState():PlayAnimation("cell_become_charged2")
		self.battery:GetAnimState():PushAnimation("cell_charged",false)

		-- self.battery_hover:Hide()
		-- self.battery_hover:TintTo(TINT_END,TINT_START,PREPARE_DURATION,function()
			
		-- end)

		-- self.battery_hover:Show()
		-- self.battery_hover:TintTo(TINT_START,TINT_END,TINT_DURATION,function()
		--     self.battery_hover:Hide()
		-- end)
		--     local ui_anim_cmp = self.battery_hover.inst.components.uianim
		-- 	ui_anim_cmp.scale_start = START_SCALE
		--     ui_anim_cmp.scale_dest = END_SCALE
		--     ui_anim_cmp.scale_duration = TINT_DURATION
		--     ui_anim_cmp.scale_t = 0
		

		self.elec:GetAnimState():PlayAnimation("elec")
		self.elec:GetAnimState():PushAnimation("NULL",false)
		self.spike:GetAnimState():PlayAnimation("spike")
		self.spike:GetAnimState():PushAnimation("NULL",false)
		self.charged = true
		self:TriggerSound(true)
		-- self:SpawnVFX()
		self:SpawnVFX2({
			delay = 0,
			pos = Vector3(20,30,0),
			roa_range = {PI/9,PI/2.5},
			create_count = math.random(20,25),
		})
		self:SpawnVFX2({
			delay = 0,
			pos = Vector3(-20,-30,0),
			roa_range = {PI+PI/9,PI+PI/2.5},
			create_count = math.random(20,25),
		})
	else
		-- self:Debug("Try to Charge when is already charged")
	end
end

function GaleChargeBattery:Uncharge(force,instant)
	if self.charged == true or force then 
		if not instant then 
			self.battery:GetAnimState():PlayAnimation("cell_become_empty2")
			self.battery:GetAnimState():PushAnimation("cell_empty",false)
			self.elec:GetAnimState():PlayAnimation("elec")
			self.elec:GetAnimState():PushAnimation("NULL",false)
			self.spike:GetAnimState():PlayAnimation("spike2")
			self.spike:GetAnimState():PushAnimation("NULL",false)
			self.charged = false

			self:TriggerSound(false)
			-- self:SpawnVFX(0.33)
			self:SpawnVFX2({
				delay = 0.33,
				pos = Vector3(15,-30,0),
				roa_range = {-PI/2.5,-PI/9},
				create_count = math.random(20,25),
			})
			self:SpawnVFX2({
				delay = 0.34,
				pos = Vector3(-15,30,0),
				roa_range = {PI/2+PI/9,PI/2+PI/2.5},
				create_count = math.random(20,25),
			})
		else
			self.battery:GetAnimState():PlayAnimation("cell_empty",false)
		end
	else
		-- self:Debug("Try to Uncharge when is empty")
	end
end

function GaleChargeBattery:OnGainFocus()
	self.tip:Show()
end

function GaleChargeBattery:OnLoseFocus()
	self.tip:Hide()
end

function GaleChargeBattery:Debug(desc)
	print("[GaleChargeBattery]:"..desc)
end


return GaleChargeBattery