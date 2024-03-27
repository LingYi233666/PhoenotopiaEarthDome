local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local GaleTooltip = Class(Widget, function(self)
    Widget._ctor(self,"GaleTooltip")

    self.bg = self:AddChild(Image("images/ui/bufftips/bg.xml", "bg.tex"))

	self.bars = {}
	for i=1,4 do 
		table.insert(self.bars,self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex")))
	end

	self.corners = {}
	for i=1,4 do 
		table.insert(self.corners,self:AddChild(Image("images/ui/bufftips/corner.xml", "corner.tex")))
	end
end)


--c_condition("bloodthirsty",1) c_condition("condition_gale_boon",1)
function GaleTooltip:MakeLayout()
	local bg_w,bg_h = self.bg:GetSize()

	self.corners[1]:SetPosition(-bg_w/2,bg_h/2)
	self.corners[1]:SetRotation(-90)

	self.corners[2]:SetPosition(-bg_w/2,-bg_h/2)
	self.corners[2]:SetRotation(-180)

	self.corners[3]:SetPosition(bg_w/2,-bg_h/2)
	self.corners[3]:SetRotation(-270)

	self.corners[4]:SetPosition(bg_w/2,bg_h/2)

	local bar_width = 16
	local bar_delta = 4
	self.bars[1]:SetPosition(-bg_w/2-bar_width/2+bar_delta,0)
	self.bars[1]:SetSize(bar_width,bg_h)

	self.bars[2]:SetPosition(0,-bg_h/2-bar_width/2+bar_delta/2)
	self.bars[2]:SetRotation(-90)
	self.bars[2]:SetSize(bar_width,bg_w)

	self.bars[3]:SetPosition(bg_w/2+bar_width/2-bar_delta,0)
	self.bars[3]:SetRotation(-180)
	self.bars[3]:SetSize(bar_width,bg_h)

	self.bars[4]:SetPosition(0,bg_h/2+bar_width/2-bar_delta/2)
	self.bars[4]:SetRotation(-270)
	self.bars[4]:SetSize(bar_width,bg_w)
end

function GaleTooltip:GetSize()
	return self.bg:GetSize()
end

return GaleTooltip