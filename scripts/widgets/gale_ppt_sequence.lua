local Widget = require ("widgets/widget")
local Image = require ("widgets/image")
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local GaleCG = require("widgets/gale_cg_images")
local GaleProgressiveText = require("widgets/gale_progressive_text")
local GaleProgressiveTextGroup = require("widgets/gale_progressive_text_group")
local GalePptPage = require("widgets/gale_ppt_page")
local TEMPLATES = require("widgets/redux/templates")

local function MakeNoClickSound(self)
    function self:OnControl(control, down)
        if not self:IsEnabled() or not self.focus then return end
    
        if self:IsSelected() and not self.AllowOnControlWhenSelected then return false end
    
        if control == self.control and (not self.mouseonly or TheFrontEnd.isprimary) then
            if down then
                if not self.down then
                    if self.has_image_down then
                        self.image:SetTexture(self.atlas, self.image_down)
    
                        if self.size_x and self.size_y then
                            self.image:ScaleToSize(self.size_x, self.size_y)
                        end
                    end
                    self.o_pos = self:GetLocalPosition()
                    if self.move_on_click then
                        self:SetPosition(self.o_pos + self.clickoffset)
                    end
                    self.down = true
                    if self.whiledown then
                        self:StartUpdating()
                    end
                    if self.ondown then
                        self.ondown()
                    end
                end
            else
                if self.down then
                    if self.has_image_down then
                        self.image:SetTexture(self.atlas, self.image_focus)
    
                        if self.size_x and self.size_y then
                            self.image:ScaleToSize(self.size_x, self.size_y)
                        end
                    end
                    self.down = false
                    self:ResetPreClickPosition()
                    if self.onclick then
                        self.onclick()
                    end
                    self:StopUpdating()
                end
            end
            return true
        end
    end
end

local GalePptSequence = Class(Widget,function(self)
    Widget._ctor(self,"GalePptSequence")

    self.pages = {}
    self.last_page = -1
    self.current_page = 1

    local scr_w,scr_h = TheSim:GetScreenSize()
    
    self.bg = self:AddChild(Image("images/ui/bufftips/bg_white.xml","bg_white.tex"))
    self.bg:SetTint(0,0,0,0)
    self.bg:SetSize(scr_w,scr_h)
    self.bg:MoveToBack()

    -- self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    -- self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    -- self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    -- self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    -- self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    -- self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    -- self.black.image:SetTint(0, 0, 0,0.01)
    -- self.black:SetOnClick(function() self:DoMouseClick() end)
    -- MakeNoClickSound(self.black)
end)

function GalePptSequence:AddPage(page_ui)
    self:AddChild(page_ui)
    page_ui:Hide()
    table.insert(self.pages,page_ui)

    -- self.black:MoveToFront()
end

function GalePptSequence:FadeIn(duration,when_done)
    self.bg:SetTint(0,0,0,0)
    self.bg:TintTo({r=0,g=0,b=0,a=0},{r=0,g=0,b=0,a=1},duration,when_done)
end

function GalePptSequence:FadeOut(duration,when_done)
    for _,v in pairs(self.pages) do
        v:Hide()
    end
    -- self.black:Hide()
    self.bg:TintTo({r=0,g=0,b=0,a=1},{r=0,g=0,b=0,a=0},duration,when_done)
end

function GalePptSequence:DoMouseClick()
    if self.pages[self.current_page]:AtEnd() then
        self.current_page = math.min(self.current_page + 1,#self.pages)
    end

    if self.last_page ~= self.current_page then
        self.last_page = self.current_page
        self.pages[self.current_page]:Show()
        self.pages[self.current_page]:FadeIn(2)
        -- if self.pages[self.current_page].cg then
        --     self.pages[self.current_page].cg:EnableMoving(true)
        -- end
        if self.current_page > 1 then
            local old_id = self.current_page - 1
            self.pages[old_id]:FadeOut(2,function()
                self.pages[old_id]:Hide()
            end)
        end
    end

    
    
    if self:AtEnd() then
        print("PPT Seq play all done !")
    else 
        self.pages[self.current_page]:DoMouseClick()
    end

end

function GalePptSequence:AtEnd()
    return self.current_page >= #self.pages and self.pages[self.current_page]:AtEnd()
end

local GalePptSequence_FirstPlay = Class(GalePptSequence,function(self)
    GalePptSequence._ctor(self)

    self:AddPage(GalePptPage.StoryBeginAsWorldWar())
    self:AddPage(GalePptPage.TheGreatBattleGround())
    self:AddPage(GalePptPage.AtEndOfWar())
    self:AddPage(GalePptPage.PhoenixCreated())
    self:AddPage(GalePptPage.EarthNotSuitForPeople())
    self:AddPage(GalePptPage.MostPeopleDecideToSleep())
    self:AddPage(GalePptPage.CentriesPassedAfterWar())
    self:AddPage(GalePptPage.PhoenixTheWorldLegacy())
    self:AddPage(GalePptPage.GaleJourneyBegin())

    -- self:DoMouseClick()
end)


return {
    FirstPlay = GalePptSequence_FirstPlay,
}