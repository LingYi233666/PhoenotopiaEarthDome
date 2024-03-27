local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local GaleBuffTip = require "widgets/galebufftip"
local GaleBuffSlot = Class(Widget, function(self,data)	
	Widget._ctor(self,"GaleBuffSlot")

	data = data or {}

	-- self.ent = data.ent
	-- data -> image_name,buff_name,addition_tip,
	self.slot_scale = data.slot_scale or 0.5
	self.prefab_name = data.prefab_name
	self.stacks = data.stacks or 1 
	self.buff_name = data.buff_name
	self.addition_tip = data.addition_tip
	self.dtype = data.dtype
	self.tip_type = data.tip_type

	

	local xml_path = "images/ui/bufficons/"..data.image_name..".xml"
	if softresolvefilepath(xml_path) == nil then
		print("GaleBuffSlot can't find "..xml_path..",use default...")
		self.icon = self:AddChild(Image("images/ui/skill_slot/bufficon_empty.xml", "bufficon_empty.tex"))
	else 
		self.icon = self:AddChild(Image(xml_path, data.image_name..".tex"))
	end
	self.icon:SetScale(0.01,0.01)

	-- self.tip = self:AddChild(Text(NUMBERFONT, 32,string.format("%s\n%s",self.buff_name,self.addition_tip)))
	-- self.tip:SetPosition(0,-75,0)
	-- self.tip:SetRegionSize(250,250)
	-- self.tip:SetVAlign(ANCHOR_BOTTOM)
	-- self.tip:SetHAlign(ANCHOR_LEFT)
	-- self.tip:Hide()

	self.tip = self:AddChild(GaleBuffTip({string.upper(self.prefab_name)}))
	self.tip:SetBuffName(self.buff_name)
	self.tip:Hide()


	-- NEWFONT_OUTLINE good 
	-- TALKINGFONT_WORMWOOD very good
	-- TALKINGFONT_HERMIT

	self.stacks_show = self:AddChild(Text(TALKINGFONT_WORMWOOD, 50,"STACKS"))
	self.stacks_show:SetPosition(40,-35,0)
	self.stacks_show:SetColour(228/255,212/255,189/255,1)

	self:Hide()
	self:CheckDesc()
end)

function GaleBuffSlot:OnGainFocus()
    self.tip:Show()
end

function GaleBuffSlot:OnLoseFocus()
    self.tip:Hide()
end

function GaleBuffSlot:SetImage(image_name)
	local xml_path = "images/ui/bufficons/"..image_name..".xml"
	if softresolvefilepath(xml_path) == nil then
		-- print("GaleBuffSlot can't find "..xml_path..",use default...")
		self.icon:SetTexture("images/ui/skill_slot/bufficon_empty.xml", "bufficon_empty.tex")
	else 
		self.icon:SetTexture("images/ui/bufficons/"..image_name..".xml", image_name..".tex")
	end
end

function GaleBuffSlot:SetStacks(stacks)
	self.stacks = stacks
	self:CheckDesc()
end

function GaleBuffSlot:SetBuffName(name)
	self.buff_name = name
	self:CheckDesc()
end

function GaleBuffSlot:SetAdditionTip(tip)
	self.addition_tip = tip 
	self:CheckDesc()
end

function GaleBuffSlot:SetDtype(dtype)
	self.dtype = dtype
	self:CheckDesc()
end

function GaleBuffSlot:CheckDesc()
	self.tip:SetStacks(self.stacks)
	self.stacks_show:SetString(string.format("x%d",self.stacks))
	if self.stacks <= 1 then 
		self.stacks_show:Hide()
	else
		self.stacks_show:Show()
	end 
	self.tip:SetBuffDesc(self.addition_tip)
	self.tip:SetDtype(self.dtype)
	if self.tip_type == "DOWN" then 
		self:UpdateTipPosition(0,-95)
	elseif self.tip_type == "UP" then
		self:UpdateTipPosition(0,95)
	end
end

function GaleBuffSlot:SlideIn()
	self:Show()
	self.icon:ScaleTo(0.01,self.slot_scale,0.33)
end

function GaleBuffSlot:SlideOut(delay)
	self.stacks_show:Hide()
	self.icon:ScaleTo(self.slot_scale,0.01,delay,function()
		self:Kill()
	end)
end

function GaleBuffSlot:UpdateTipPosition(x, y)
	local w0, h0 = self.tip:GetSize()
	if self.tip_type == "DOWN" then 
	   	self.tip:SetPosition(x, y - h0 / 2)
	elseif self.tip_type == "UP" then
		self.tip:SetPosition(x, y + h0 / 2)
	end 
end

return GaleBuffSlot