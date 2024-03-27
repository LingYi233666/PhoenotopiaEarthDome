local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"

local GaleConditionUtil = require "util/gale_conditions"

local GaleSubBuffTip = Class(GaleTooltip, function(self)
	GaleTooltip._ctor(self,"GaleSubBuffTip")


	self.buff_name = self:AddChild(Text(NUMBERFONT, 32,"MISSING_BUFF_NAME"))
	self.buff_name:SetHAlign(ANCHOR_LEFT)
	self.buff_name:SetColour(194/255,237/255,251/255,1)

	self.buff_desc = self:AddChild(Text(NUMBERFONT, 30,"MISSING_BUFF_DESC"))
	self.buff_desc:SetHAlign(ANCHOR_LEFT)
	self.buff_desc:SetColour(167/255,248/255,228/255,1)
end)

function GaleSubBuffTip:MakeLayout()
	local bg_w,bg_h = self:GetSize()
	local buff_desc_w,buff_desc_h = self.buff_desc:GetRegionSize()
	self.bg:SetSize(math.max(20,buff_desc_w + 20),math.max(50,buff_desc_h + 50))
	bg_w,bg_h = self:GetSize()

	GaleSubBuffTip._base.MakeLayout(self)

	local buff_name_w,buff_name_h = self.buff_name:GetRegionSize()
	self.buff_name:SetPosition(-bg_w / 2 + buff_name_w / 2 + 10,bg_h / 2 - 20)

	self.buff_desc:SetPosition(-bg_w / 2 + buff_desc_w / 2 + 10,bg_h / 2 - buff_desc_h /2 - 40)

	for k,v in pairs(self.corners) do 
		v:SetScale(0.75,0.75)
	end
end

function GaleSubBuffTip:SetBuffName(val)
	self.buff_name:SetString(val)
end

function GaleSubBuffTip:SetBuffDesc(val)
	self.buff_desc:SetString(GaleConditionUtil.ReplaceConditionDesc(val))
	self:MakeLayout()
end

return GaleSubBuffTip