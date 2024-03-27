local Widget = require ("widgets/widget")
local Image = require ("widgets/image")
local Text = require "widgets/text"

local GaleCG = require("widgets/gale_cg_images")
local GaleProgressiveText = require("widgets/gale_progressive_text")
local GaleProgressiveTextGroup = require("widgets/gale_progressive_text_group")
local TEMPLATES = require("widgets/redux/templates")

local GalePptPage = Class(Widget,function(self)
    Widget._ctor(self,"GalePptPage")


    -- self.bg = self:AddChild(TEMPLATES.BrightMenuBackground())

    local scr_w,scr_h = TheSim:GetScreenSize()

    self.bg_up = self:AddChild(Image("images/ui/bufftips/bg_white.xml","bg_white.tex"))
    self.bg_up:SetTint(0,0,0,1)
    self.bg_up:SetSize(1100,110)
    self.bg_up:SetVAnchor(ANCHOR_TOP)
    self.bg_up:SetHAnchor(ANCHOR_MIDDLE)
    self.bg_up:SetPosition(0,-55)
    self.bg_up:SetScale(scr_w / 1100)

    self.bg_down = self:AddChild(Image("images/ui/bufftips/bg_white.xml","bg_white.tex"))
    self.bg_down:SetTint(0,0,0,1)
    self.bg_down:SetSize(1100,110)
    self.bg_down:SetVAnchor(ANCHOR_BOTTOM)
    self.bg_down:SetHAnchor(ANCHOR_MIDDLE)
    self.bg_down:SetPosition(0,55)
    self.bg_down:SetScale(scr_w / 1100)
end)

function GalePptPage:AddCG(cg_ui)
    self.cg = self:AddChild(cg_ui)

    -- self.cg:SetVAnchor(ANCHOR_MIDDLE)
    -- self.cg:SetHAnchor(ANCHOR_MIDDLE)
    self.cg:SetPosition(0,0,0)

    self.bg_up:MoveToFront()
    self.bg_down:MoveToFront()
end

function GalePptPage:AddTextGroup(text_ui)
    self.bg_up:MoveToFront()
    self.bg_down:MoveToFront()

    self.text_group = self:AddChild(text_ui)
    self.text_group:SetVAnchor(ANCHOR_BOTTOM)
    self.text_group:SetHAnchor(ANCHOR_LEFT)
    self.text_group:SetPosition(400,75,0)
end

function GalePptPage:DoMouseClick()
    if self.cg then
        self.cg:DoMouseClick()
    end
    
    self.text_group:DoMouseClick()
end

function GalePptPage:AtEnd()
    return self.text_group:AtEnd()
end

function GalePptPage:FadeIn(duration,when_done)
    if self.cg then
        self.cg:FadeIn(duration,when_done)
    end
    
    if self.text_group then
        self.text_group:Show()
    end 
end

function GalePptPage:FadeOut(duration,when_done)
    if self.cg then
        self.cg:FadeOut(duration,when_done)
    end

    if self.text_group then
        self.text_group:Hide()
    end 
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- local WholeBlack = Class(GalePptPage,function(self)
--     GalePptPage._ctor(self)

--     self:AddTextGroup(GaleProgressiveTextGroup.StoryBeginAsWorldWar())

-- end)

-- The story of Gale's world begin as a great war.
local StoryBeginAsWorldWar = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddTextGroup(GaleProgressiveTextGroup.StoryBeginAsWorldWar())

end)

-- Different kinds of Human-made war creatures are fighting aginest other.
local TheGreatBattleGround = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddCG(GaleCG.TheGreatBattleGround())
    self:AddTextGroup(GaleProgressiveTextGroup.TheGreatBattleGround())

end)

-- At the end of war,the earth brokes.
local AtEndOfWar = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddTextGroup(GaleProgressiveTextGroup.AtEndOfWar())

end)

-- Finally,people create a new type of Bio-weapon (called Phoenix),which ends this war once for ever.
local PhoenixCreated = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddCG(GaleCG.PhoenixCreated())
    self:AddTextGroup(GaleProgressiveTextGroup.PhoenixCreated())
end)



local EarthNotSuitForPeople = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddTextGroup(GaleProgressiveTextGroup.EarthNotSuitForPeople())
end)

local MostPeopleDecideToSleep = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddCG(GaleCG.MostPeopleDecideToSleep())
    self:AddTextGroup(GaleProgressiveTextGroup.MostPeopleDecideToSleep())
end)

local CentriesPassedAfterWar = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddTextGroup(GaleProgressiveTextGroup.CentriesPassedAfterWar())
end)

local PhoenixTheWorldLegacy = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddCG(GaleCG.PhoenixTheWorldLegacy())
    self:AddTextGroup(GaleProgressiveTextGroup.PhoenixTheWorldLegacy())
end)

local GaleJourneyBegin = Class(GalePptPage,function(self)
    GalePptPage._ctor(self)

    self:AddTextGroup(GaleProgressiveTextGroup.GaleJourneyBegin())
end)



return {
    StoryBeginAsWorldWar = StoryBeginAsWorldWar,
    TheGreatBattleGround = TheGreatBattleGround,
    AtEndOfWar = AtEndOfWar,
    PhoenixCreated = PhoenixCreated,
    EarthNotSuitForPeople = EarthNotSuitForPeople,
    MostPeopleDecideToSleep = MostPeopleDecideToSleep,
    CentriesPassedAfterWar = CentriesPassedAfterWar,
    PhoenixTheWorldLegacy = PhoenixTheWorldLegacy,
    GaleJourneyBegin = GaleJourneyBegin,
}