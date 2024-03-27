local Widget = require "widgets/widget" 
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text" 
local GaleSubBuffTip = require "widgets/galesubbufftip"


local OverloadFire = Class(Widget, function(self)
	Widget._ctor(self, "RookOverloadFire")

	self.surge_val = 0

	self.anim_fire = self:AddChild(UIAnim())
	self.anim_fire:GetAnimState():SetBank("ui_rook_charge_fx")
    self.anim_fire:GetAnimState():SetBuild("ui_rook_charge_fx")
    self.anim_fire:GetAnimState():PlayAnimation("fire2",true)
    self.anim_fire:SetScale(0.15,0.15,0.15)
    self.anim_fire:SetPosition(5,0,0)
    self.anim_fire:GetAnimState():SetDeltaTimeMultiplier(0.55)

    self.overload_num = self:AddChild(Text(FALLBACK_FONT_FULL, 35,"CNT")) --添加一个文本变量，接收Text实例。
	self.overload_num:SetColour(0,0,0,1)

	self.tip = self:AddChild(GaleSubBuffTip())
	self.tip:SetBuffName(STRINGS.NAMES.CONDITION_GALE_BLASTER_SURGE)
	self.tip:SetBuffDesc(STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_SURGE.STATIC)
	self.tip:SetPosition(0,125)
	self.tip:Hide()

	-- self:SetTooltip(TOOL_TIP)
	-- self:SetTooltipPos(0,60,0)
	self:Hide()
end)

function OverloadFire:SetNum(val)
	local old_surge = self.surge_val
	self.surge_val = val 
	-- local current_scale = self:GetLooseScale()
	if val <= 0 then 
		if old_surge > 0 then 
			self:ScaleTo(1,0.01,0.5,function()
				self:Hide()
			end)
		end
	else
		if old_surge <= 0 then 
			self:ScaleTo(0.01,1,0.5)
		end 
		self:Show()
		-- self.anim_fire:GetAnimState():PlayAnimation("fire",true)
		-- self.anim_fire:GetAnimState():PlayAnimation("idle",true)
	end
	self.overload_num:SetString(tostring(val))
end

function OverloadFire:OnGainFocus()
	self.tip:Show()
end

function OverloadFire:OnLoseFocus()
	self.tip:Hide()
end

return OverloadFire