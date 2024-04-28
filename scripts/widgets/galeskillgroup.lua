local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"
local TabGroup = require "widgets/tabgroup"
local Tab = require "widgets/tab"
local GaleSkillTreeWidget = require "widgets/galeskilltreewidget"
local GaleSkillDesc = require "widgets/galeskilldesc"

local ComingSoonTip = require "widgets/comingsoontip"

local tab_bg = {
    atlas = "images/hud.xml",
    normal = "tab_normal.tex",
    selected = "tab_selected.tex",
    highlight = "tab_highlight.tex",
    bufferedhighlight = "tab_place.tex",
    overlay = "tab_researchable.tex",
}

local tab_icon = {
    SURVIVAL = "SURVIVAL",
    SCIENCE = "SCIENCE",
    COMBAT = "WAR",
    ENERGY = "ANCIENT",
    MORPH = "ANCIENT",
    PSY = "ANCIENT",
}

local GaleSkillGroup = Class(GaleTooltip, function(self, owner)
    GaleTooltip._ctor(self, "GaleSkillGroup")

    local scr_w, scr_h = TheSim:GetScreenSize()
    local BG_WIDTH = scr_w * 0.72
    local BG_HEIGHT = scr_h * 0.7

    self.owner = owner

    self.bg:SetSize(BG_WIDTH, BG_HEIGHT)
    self.bg:SetTint(50 / 255, 205 / 255, 246 / 255, 1)

    self.bg:Hide()
    for _, v in pairs(self.bars) do
        v:Hide()
    end
    for _, v in pairs(self.corners) do
        v:Hide()
    end

    self:MakeLayout()

    -- 414 *
    self.complex_desc = self:AddChild(GaleSkillDesc(self.owner, BG_WIDTH * 0.3, BG_HEIGHT))
    self.complex_desc:SetPosition(BG_WIDTH * (0.5 - 0.15), 0)

    self.skilltree_widgets = {}

    self.group = self:AddChild(TabGroup())
    self.group:SetPosition(-BG_WIDTH / 2, 0)
    self.group.spacing = 90

    for k, _ in pairs(GALE_SKILL_TREE) do
        self.skilltree_widgets[k] = self:AddChild(GaleSkillTreeWidget(self.owner, GALE_SKILL_TREE[k], self.complex_desc))
        self.skilltree_widgets[k]:Hide()
        if #GALE_SKILL_TREE[k]:ListByLeft() <= 1 then
            local tip = self.skilltree_widgets[k]:AddChild(ComingSoonTip())
            tip:SetPosition(-175, 0, 0)
            tip:SetScale(2.5)
        end

        -- self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE[k:upper()].NAME,
        --     resolvefilepath(tab_bg.atlas),
        --     resolvefilepath("images/hud.xml"),
        --     RECIPETABS[tab_icon[k:upper()]].icon,
        --     tab_bg.normal,
        --     tab_bg.selected,
        --     tab_bg.highlight,
        --     tab_bg.bufferedhighlight,
        --     tab_bg.overlay,
        --     function()
        --         self.skilltree_widgets[k:upper()]:Show()
        --         self:SetTarget(k:upper())
        --     end,
        --     function()
        --         self.skilltree_widgets[k:upper()]:Hide()
        --         self:SetTarget()
        --     end
        -- )
    end






    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.SURVIVAL.NAME,
                      resolvefilepath(tab_bg.atlas),
                      resolvefilepath("images/hud.xml"),
                      RECIPETABS.SURVIVAL.icon,
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.SURVIVAL:Show()
                          self:SetTarget("SURVIVAL")
                      end,
                      function()
                          self.skilltree_widgets.SURVIVAL:Hide()
                          self:SetTarget()
                      end
    )

    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.SCIENCE.NAME,
                      resolvefilepath(tab_bg.atlas),
                      resolvefilepath("images/hud.xml"),
                      RECIPETABS.SCIENCE.icon,
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.SCIENCE:Show()
                          self:SetTarget("SCIENCE")
                      end,
                      function()
                          self.skilltree_widgets.SCIENCE:Hide()
                          self:SetTarget()
                      end
    )

    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.COMBAT.NAME,
                      resolvefilepath(tab_bg.atlas),
                      resolvefilepath("images/hud.xml"),
                      RECIPETABS.WAR.icon,
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.COMBAT:Show()
                          self:SetTarget("COMBAT")
                      end,
                      function()
                          self.skilltree_widgets.COMBAT:Hide()
                          self:SetTarget()
                      end
    )

    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.ENERGY.NAME,
                      resolvefilepath(tab_bg.atlas),
        --   resolvefilepath("images/hud.xml"),
        --   RECIPETABS.ANCIENT.icon,
                      resolvefilepath("images/ui/skill_tab/energy.xml"),
                      "energy.tex",
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.ENERGY:Show()
                          self:SetTarget("ENERGY")
                      end,
                      function()
                          self.skilltree_widgets.ENERGY:Hide()
                          self:SetTarget()
                      end
    )

    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.MORPH.NAME,
                      resolvefilepath(tab_bg.atlas),
        --   resolvefilepath("images/hud.xml"),
        --   RECIPETABS.ANCIENT.icon,
                      resolvefilepath("images/ui/skill_tab/morph.xml"),
                      "morph.tex",
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.MORPH:Show()
                          self:SetTarget("MORPH")
                      end,
                      function()
                          self.skilltree_widgets.MORPH:Hide()
                          self:SetTarget()
                      end
    )

    self.group:AddTab(STRINGS.GALE_UI.SKILL_TREE.PSY.NAME,
                      resolvefilepath(tab_bg.atlas),
        --   resolvefilepath("images/hud.xml"),
        --   RECIPETABS.ANCIENT.icon,
                      resolvefilepath("images/ui/skill_tab/psy.xml"),
                      "psy.tex",
                      tab_bg.normal,
                      tab_bg.selected,
                      tab_bg.highlight,
                      tab_bg.bufferedhighlight,
                      tab_bg.overlay,
                      function()
                          self.skilltree_widgets.PSY:Show()
                          self:SetTarget("PSY")
                      end,
                      function()
                          self.skilltree_widgets.PSY:Hide()
                          self:SetTarget()
                      end
    )

    for k, v in pairs(self.group.tabs) do
        local w, h = v.bg:GetSize()
        w = w - 25
        -- v.bg:SetSize(w,h)
        v.icon:SetPosition(w / 2, 0, 0)
        if v.overlay then
            v.overlay:SetPosition(w / 2, 0, 0)
        end

        -- v.basescale =
    end
    self.group:MoveToFront()
end)

function GaleSkillGroup:SetTarget(target)
    self.complex_desc:SetTarget(target)
end

function GaleSkillGroup:OnUpdate()
    for k, v in pairs(self.skilltree_widgets) do
        v:OnUpdate()
    end
    self.complex_desc:OnUpdate()
end

return GaleSkillGroup
