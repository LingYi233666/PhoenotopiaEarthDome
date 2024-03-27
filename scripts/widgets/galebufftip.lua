local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"
local GaleSubBuffTip = require "widgets/galesubbufftip"

local GaleConditionUtil = require "util/gale_conditions"

local GaleBuffTip = Class(GaleTooltip, function(self,ignore_names)
    GaleTooltip._ctor(self,"GaleBuffTip")

    self.ignore_names = ignore_names or {}

	self.dtype_bg_long = self:AddChild(Image("images/ui/bufftips/dtype_bg_long.xml", "dtype_bg_long.tex"))

	self.dtype_bg = self:AddChild(Image("images/ui/bufftips/dtype_bg.xml", "dtype_bg.tex"))

	self.dtype_text = self.dtype_bg:AddChild(Text(NUMBERFONT, 35,"dtype_text"))

	self.buff_name = self:AddChild(Text(NUMBERFONT, 32,"MISSING_BUFF_NAME"))
	self.buff_name:SetHAlign(ANCHOR_LEFT)

	self.buff_desc = self:AddChild(Text(NUMBERFONT, 30,"MISSING_BUFF_DESC"))
	self.buff_desc:SetHAlign(ANCHOR_LEFT)
	self.buff_desc:SetColour(167/255,248/255,228/255,1)

	self.stack_norm = self:AddChild(Text(NUMBERFONT, 28,STRINGS.GALE_UI.CONDITION_STACK))
	self.stack_norm:SetHAlign(ANCHOR_LEFT)
	self.stack_norm:SetColour(89/255,242/255,204/255,1)

	self.stack_x = self:AddChild(Text(NUMBERFONT, 28,"x???"))
	self.stack_x:SetHAlign(ANCHOR_RIGHT)
	self.stack_x:SetColour(89/255,242/255,204/255,1)

	self.circles = {}
	for i=1,2 do 
		table.insert(self.circles,self:AddChild(Image("images/ui/bufftips/circle.xml", "circle.tex")))
	end

	self.keywords = {}
	self.keywords_tooltip = {}

end)
--c_condition("bloodthirsty",1) c_condition("condition_gale_boon",1)
function GaleBuffTip:MakeLayout()
	local bg_w,bg_h = self:GetSize()
	local buff_desc_w,buff_desc_h = self.buff_desc:GetRegionSize()
	local dtype_text_w,dtype_text_h = self.dtype_text:GetRegionSize()
	local dtype_bg_w,dtype_bg_h = self.dtype_bg:GetSize()
	local dtype_bg_long_w,dtype_bg_long_h = self.dtype_bg_long:GetSize()

	self.bg:SetSize(math.max(bg_w,buff_desc_w + 20),math.max(bg_h,buff_desc_h + 115))
	bg_w,bg_h = self:GetSize()

	GaleBuffTip._base.MakeLayout(self)

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


	-----------------------------------------------------------
	for k,v in pairs(self.keywords_tooltip) do 
		self:RemoveChild(v)
        v:Kill()
	end
	self.keywords_tooltip = {}

	local height = 0
	for k,v in pairs(self.keywords) do 
		local sub = self:AddChild(GaleSubBuffTip())
		sub:SetBuffName(STRINGS.NAMES[string.upper(v)])
		sub:SetBuffDesc(STRINGS.GALE_BUFF_DESC[string.upper(v)].STATIC)
		local sub_w,sub_h = sub:GetSize()
		sub:SetPosition(bg_w / 2 + sub_w / 2 + 55,height + bg_h / 2 - sub_h / 2)
		height = height - sub_h - 35
		table.insert(self.keywords_tooltip,sub)
	end

	for k,v in pairs(self.bars) do 
		v:MoveToFront()
	end 

	for k,v in pairs(self.corners) do 
		v:MoveToFront()
	end 
end

function GaleBuffTip:SetBuffName(val)
	self.buff_name:SetString(val)
end

function GaleBuffTip:SetBuffDesc(val)
	self.buff_desc:SetString(GaleConditionUtil.ReplaceConditionDesc(val))
	self.keywords = GaleConditionUtil.GetConditionKeywords(val)

	local idnore_id = {}
	for k,v in pairs(self.keywords) do 
		if table.contains(self.ignore_names,v) then 
			table.insert(idnore_id,k)
		end
	end
	for k,v in pairs(idnore_id) do 
		table.remove(self.keywords,v)
	end
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
	elseif dtype == STRINGS.GALE_BUFF_DTYPE.PARASITE then 
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