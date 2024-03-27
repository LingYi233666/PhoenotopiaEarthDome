local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"

local GaleConditionUtil = require "util/gale_conditions"

local GaleBuffTip = Class(Widget, function(self)
    Widget._ctor(self,"GaleBuffTip")

    self.bg = self:AddChild(Image("images/ui/bufftips/bg.xml", "bg.tex"))
    
	self.dtype_bg_long = self:AddChild(Image("images/ui/bufftips/dtype_bg_long.xml", "dtype_bg_long.tex"))

	self.dtype_bg = self:AddChild(Image("images/ui/bufftips/dtype_bg.xml", "dtype_bg.tex"))

	self.dtype_text = self.dtype_bg:AddChild(Text(NUMBERFONT, 35,"状态"))

	self.buff_name = self:AddChild(Text(NUMBERFONT, 32,"MISSING_BUFF_NAME"))
	self.buff_name:SetHAlign(ANCHOR_LEFT)

	self.buff_desc = self:AddChild(Text(NUMBERFONT, 30,"MISSING_BUFF_DESC"))
	self.buff_desc:SetHAlign(ANCHOR_LEFT)
	self.buff_desc:SetColour(167/255,248/255,228/255,1)

	self.stack_norm = self:AddChild(Text(NUMBERFONT, 28,"层数"))
	self.stack_norm:SetHAlign(ANCHOR_LEFT)
	self.stack_norm:SetColour(89/255,242/255,204/255,1)

	self.stack_x = self:AddChild(Text(NUMBERFONT, 28,"x???"))
	self.stack_x:SetHAlign(ANCHOR_RIGHT)
	self.stack_x:SetColour(89/255,242/255,204/255,1)

	self.corners = {}
	for i=1,4 do 
		table.insert(self.corners,self:AddChild(Image("images/ui/bufftips/corner.xml", "corner.tex")))
	end

	self.bars = {}
	for i=1,4 do 
		table.insert(self.bars,self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex")))
	end

	self.circles = {}
	for i=1,2 do 
		table.insert(self.circles,self:AddChild(Image("images/ui/bufftips/circle.xml", "circle.tex")))
	end

	self.keywords = {}

	self:MakeLayout()
end)
--c_condition("bloodthirsty",1) c_condition("condition_gale_boon",1)
function GaleBuffTip:MakeLayout()
	local bg_w,bg_h = self.bg:GetSize()
	local buff_desc_w,buff_desc_h = self.buff_desc:GetRegionSize()
	local dtype_text_w,dtype_text_h = self.dtype_text:GetRegionSize()
	local dtype_bg_w,dtype_bg_h = self.dtype_bg:GetSize()
	local dtype_bg_long_w,dtype_bg_long_h = self.dtype_bg_long:GetSize()

	self.bg:SetSize(math.max(bg_w,buff_desc_w + 20),math.max(bg_h,buff_desc_h + 115))
	bg_w,bg_h = self.bg:GetSize()

	self.corners[1]:SetPosition(-bg_w/2,bg_h/2)
	self.corners[1]:SetRotation(-90)

	self.corners[2]:SetPosition(-bg_w/2,-bg_h/2)
	self.corners[2]:SetRotation(-180)

	self.corners[3]:SetPosition(bg_w/2,-bg_h/2)
	self.corners[3]:SetRotation(-270)

	self.corners[4]:SetPosition(bg_w/2,bg_h/2)

	local bar_width = 16
	local bar_delta = 2
	self.bars[1]:SetPosition(-bg_w/2-bar_width/2+bar_delta,0)
	self.bars[1]:SetSize(bar_width,bg_h)

	self.bars[2]:SetPosition(0,-bg_h/2-bar_width/2+bar_delta)
	self.bars[2]:SetRotation(-90)
	self.bars[2]:SetSize(bar_width,bg_w)

	self.bars[3]:SetPosition(bg_w/2+bar_width/2-bar_delta,0)
	self.bars[3]:SetRotation(-180)
	self.bars[3]:SetSize(bar_width,bg_h)

	self.bars[4]:SetPosition(0,bg_h/2+bar_width/2-bar_delta)
	self.bars[4]:SetRotation(-270)
	self.bars[4]:SetSize(bar_width,bg_w)

	local circle_w,circle_h = self.circles[1]:GetSize()
	self.circles[1]:SetPosition(0,bg_h/2+circle_h/2)

	self.circles[2]:SetPosition(0,-bg_h/2-circle_h/2)
	self.circles[2]:SetRotation(-180)



	self.dtype_bg:SetSize(math.max(dtype_text_w,dtype_bg_w),math.max(dtype_text_h,dtype_bg_h))
	self.dtype_bg_long:SetSize(bg_w,dtype_bg_long_h)

	dtype_bg_w,dtype_bg_h = self.dtype_bg:GetSize()
	dtype_bg_long_w,dtype_bg_long_h = self.dtype_bg_long:GetSize()

	self.dtype_bg:SetPosition(-bg_w / 2 + dtype_bg_w / 2,bg_h / 2 - dtype_bg_h / 2)
	self.dtype_bg_long:SetPosition(-bg_w / 2 + dtype_bg_long_w / 2,bg_h / 2 - dtype_bg_long_h / 2)


	local buff_name_w,buff_name_h = self.buff_name:GetRegionSize()
	self.buff_name:SetPosition(-bg_w / 2 + buff_name_w / 2 + 10,bg_h / 2 - dtype_bg_h - 15)

	local stack_norm_w,stack_norm_h = self.stack_norm:GetRegionSize()
	self.stack_norm:SetPosition(-bg_w / 2 + stack_norm_w / 2 + 10,bg_h / 2 - dtype_bg_h - 40)

	local stack_x_w,stack_x_h = self.stack_x:GetRegionSize()
	self.stack_x:SetPosition(bg_w / 2 - stack_x_w / 2 - 5,bg_h / 2 - dtype_bg_h - 40)

	buff_desc_w,buff_desc_h = self.buff_desc:GetRegionSize()
	self.buff_desc:SetPosition(-bg_w / 2 + buff_desc_w / 2 + 10,bg_h / 2 - dtype_bg_h - buff_desc_h /2 - 60)
end

function GaleBuffTip:GetSize()
	return self.bg:GetSize()
end

function GaleBuffTip:SetBuffName(val)
	self.buff_name:SetString(val)
end

function GaleBuffTip:SetBuffDesc(val)
	self.buff_desc:SetString(GaleConditionUtil.ReplaceConditionDesc(val))
	self.keywords = GaleConditionUtil.GetConditionKeywords(val)
	self:MakeLayout()
end

function GaleBuffTip:SetStacks(stack)
	self.stack_x:SetString("x"..tostring(stack))
	self:MakeLayout()
end

function GaleBuffTip:SetDtype(dtype)
	self.dtype_text:SetString(dtype)
	if dtype == STRINGS.GALE_BUFF_DTYPE.BUFF then 
		self.dtype_bg:SetTint(52/255,83/255,49/255,1)
		self.dtype_bg_long:SetTint(52/255,83/255,49/255,0.6)
		self.dtype_text:SetColour(73/255,208/255,60/255,1)
		self.buff_name:SetColour(113/255,187/255,107/255,1)
	elseif dtype == STRINGS.GALE_BUFF_DTYPE.DEBUFF then 
		self.dtype_bg:SetTint(138/255,56/255,56/255,1)
		self.dtype_bg_long:SetTint(138/255,56/255,56/255,0.6)
		self.dtype_text:SetColour(236/255,40/255,40/255,1)
		self.buff_name:SetColour(216/255,54/255,54/255,1)
	elseif dtype == STRINGS.GALE_BUFF_DTYPE.PASSIVE then 
		self.dtype_bg:SetTint(107/255,67/255,42/255,1)
		self.dtype_bg_long:SetTint(107/255,67/255,42/255,0.6)
		self.dtype_text:SetColour(244/255,138/255,67/255,1)
		self.buff_name:SetColour(255/255,165/255,105/255,1)
	else
		self.dtype_bg:SetTint(1,1,1,1)
		self.dtype_bg_long:SetTint(1,1,1,0.8)
		self.dtype_text:SetColour(1,1,1,1)
		self.buff_name:SetColour(1,1,1,1)
	end

	self:MakeLayout()
end

return GaleBuffTip