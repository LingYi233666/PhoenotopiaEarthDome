local Widget = require "widgets/widget" 
local Image = require "widgets/image"
local Text = require "widgets/text"
local GaleProgressiveText = require "widgets/gale_progressive_text"

-- groups = {
--     {
--         font, size, text, colour,speed
--     },
-- }
local GaleProgressiveTextGroup = Class(Widget,function(self,groups_data)
    Widget._ctor(self,"GaleProgressiveTextGroup")

    self.groups = {}
    self.current_id = 1 

    for k,v in pairs(groups_data or {}) do
        self:AddProgressiveText(v)
    end
end)

function GaleProgressiveTextGroup:AddProgressiveText(data)
    local ui = GaleProgressiveText(data.font or DEFAULTFONT,data.size or 45,data.text,data.colour,data.speed,data.left_top_pos)

    self:AddChild(ui)

    ui:Hide()

    table.insert(self.groups,ui)
end

function GaleProgressiveTextGroup:AtEnd()
    return self.current_id >= #self.groups and self.groups[self.current_id]:AtEnd()
end

function GaleProgressiveTextGroup:DoMouseClick()
    if self.groups[self.current_id]:AtEnd() then
        self.current_id = math.min(self.current_id + 1,#self.groups)
    end

    self.groups[self.current_id]:Show()
    if self.current_id > 1 then
        self.groups[self.current_id - 1]:Hide()
    end

    self.groups[self.current_id]:DoMouseClick()
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local StoryBeginAsWorldWar = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[1],
        },
    })
end)

local TheGreatBattleGround = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[2],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[3],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[4],
        },
    })
end)

local AtEndOfWar = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[5],
        },
    })
end)

local PhoenixCreated = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[6],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[7],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[8],
        },
    })
end)

local EarthNotSuitForPeople = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[9],
        },
    })
end)

local MostPeopleDecideToSleep = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[10],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[11],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[12],
        },
    })
end)

local CentriesPassedAfterWar = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[13],
        },
    })
end)

local PhoenixTheWorldLegacy = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[14],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[15],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[16],
        },
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[17],
        },
    })
end)

local GaleJourneyBegin = Class(GaleProgressiveTextGroup,function(self)
    GaleProgressiveTextGroup._ctor(self,{
        {
            text = STRINGS.GALE_UI.CG.CG_INTRO[18],
        },
    })
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