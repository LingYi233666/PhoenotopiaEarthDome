local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local GaleFamilyPortraits = Class(Widget, function(self,owner) 
	Widget._ctor(self, "GaleFamilyPortraits") 

	self.owner = owner

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0,0)
    self.black:MoveToFront()
    

    self.image = self:AddChild(Image("images/ui/gale_family_portraits.xml", "gale_family_portraits.tex"))
    self.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.image:SetVAnchor(ANCHOR_MIDDLE)
    self.image:SetHAnchor(ANCHOR_MIDDLE)
    self.image:MoveToFront()
    self.image:Hide()
    -- self.image:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    -- self.close_button = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	-- self.close_button:SetOnClick(function() self:Exit() end)
	-- self.close_button:SetPosition(self.BG_WIDTH / 2, self.BG_HEIGHT / 2 + 27)	

    self.hover = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.hover.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.hover.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.hover.image:SetVAnchor(ANCHOR_MIDDLE)
    self.hover.image:SetHAnchor(ANCHOR_MIDDLE)
    self.hover.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.hover.image:SetTint(0, 0, 0,0)
    self.hover:SetOnClick(function() 
        self:Exit()
    end)
    self.hover:MoveToFront()
end)

function GaleFamilyPortraits:Enter()
    local scr_w, scr_h = TheSim:GetScreenSize()  

    -- 208 96
    local raw_w,raw_h = 208,96
    local min_ratio = math.min(scr_w * 0.6 / raw_w,scr_h * 0.6 / raw_h)

    self.image:SetSize(min_ratio * raw_w,min_ratio * raw_h)
    self.image:MoveTo(Vector3(0,-scr_h),Vector3(0,0),1)
    self.image:Show()

    self.black:TintTo({r=0,g=0,b=0,a=0},{r=0,g=0,b=0,a=0.6},1)
end

function GaleFamilyPortraits:Exit()
    local scr_w, scr_h = TheSim:GetScreenSize()  
    -- self.close_button:Hide()
    self.hover:SetClickable(false)
    self.black:TintTo({r=0,g=0,b=0,a=self.black.tint[4]},{r=0,g=0,b=0,a=0},1)

    self.image:MoveTo(self.image:GetPosition(),Vector3(0,-scr_h),1,function()
        self:Kill()
    end)
end



return GaleFamilyPortraits