local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Screen = require "widgets/screen"
local ImageButton = require "widgets/imagebutton"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/redux/templates"
local TrueScrollArea = require "widgets/truescrollarea"

local GaleReadablePaper = Class(Screen, function(self, owner, title, content)
    Screen._ctor(self, "GaleReadablePaper")
    TheInput:ClearCachedController()

    self.owner = owner

    local paper_r, paper_g, paper_b = unpack(UICOLOURS.BROWN_DARK)
    -- local paper_r, paper_g, paper_b = 39 / 255, 34 / 255, 25 / 255
    local title_r, title_g, title_b = unpack(UICOLOURS.GOLD_SELECTED)
    local content_r, content_g, content_b = unpack(UICOLOURS.WHITE)


    -- self.paper = self:AddChild(Image("images/global.xml", "square.tex"))
    -- self.paper:SetVRegPoint(ANCHOR_MIDDLE)
    -- self.paper:SetHRegPoint(ANCHOR_MIDDLE)
    -- self.paper:SetVAnchor(ANCHOR_MIDDLE)
    -- self.paper:SetHAnchor(ANCHOR_MIDDLE)
    -- self.paper:SetScaleMode(SCALEMODE_PROPORTIONAL)
    -- self.paper:SetTint(paper_r, paper_g, paper_b, 0.66)
    -- self.paper:SetSize(500, 600)

    local buttons = {
        { text = STRINGS.UI.OPTIONS.CLOSE, cb = function() self:Exit() end, },
    }


    self.paper = self:AddChild(TEMPLATES.RectangleWindow(500, 600, nil, buttons))
    self.paper:SetVAnchor(ANCHOR_MIDDLE)
    self.paper:SetHAnchor(ANCHOR_MIDDLE)
    self.paper:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.paper:SetBackgroundTint(paper_r, paper_g, paper_b, 0.6)
    -- self.paper.top:Hide() -- top crown would cover our tabs.

    -- self.top_line = self.paper:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    -- self.top_line:SetScale(.705, 1)
    -- self.top_line:SetPosition(0, 132, 0)

    -- self.bottom_line = self.paper:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    -- self.bottom_line:SetScale(.705, 1)
    -- self.bottom_line:SetPosition(0, -253, 0)

    self.title = self.paper:AddChild(Text(TITLEFONT, 38))
    -- self.title:SetColour(194 / 255, 237 / 255, 251 / 255, 1)
    self.title:SetColour(title_r, title_g, title_b, 1)
    self.title:SetString(title or "MISSING_TITLE")
    self.title:SetPosition(0, 275)



    local visiable_width = 460
    local visiable_height = 530
    local text_max_width = visiable_width

    local sub_root = Widget("text_root")

    self.content = sub_root:AddChild(Text(UIFONT, 30))
    -- self.content:SetColour(167 / 255, 248 / 255, 228 / 255, 1)
    self.content:SetColour(content_r, content_g, content_b, 1)
    self.content:SetHAlign(ANCHOR_LEFT)
    self.content:SetVAlign(ANCHOR_TOP)
    self.content:SetMultilineTruncatedString(content or GALE_LOREM_IPSUM_CHS_NO_UPDATE, 99999, text_max_width)
    local text_w, text_h = self.content:GetRegionSize()
    self.content:SetPosition(text_w * 0.5, -0.5 * text_h)


    local scissor_data = {
        x = 0,
        y = -visiable_height / 2,
        width = visiable_width,
        height =
            visiable_height
    }
    local context = { widget = sub_root, offset = { x = 0, y = visiable_height / 2 }, size = { w = text_w, height = text_h } }
    local scrollbar = { scroll_per_click = 20 * 3 }
    self.scroll_area = self.paper:AddChild(TrueScrollArea(context, scissor_data, scrollbar))
    self.scroll_area:SetPosition(-visiable_width / 2, -10)

    self.hover = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.hover.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.hover.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.hover.image:SetVAnchor(ANCHOR_MIDDLE)
    self.hover.image:SetHAnchor(ANCHOR_MIDDLE)
    self.hover.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.hover.image:SetTint(0, 0, 0, 0)
    self.hover:SetOnClick(function()
        self:Exit()
    end)
    self.hover:MoveToBack()
end)

function GaleReadablePaper:Enter()
    local scr_w, scr_h = TheSim:GetScreenSize()

    self.paper:SetPosition(0, -scr_h)
    self.paper:MoveTo(Vector3(0, -scr_h), Vector3(0, 0), 1)
    self.hover:TintTo({ r = 0, g = 0, b = 0, a = 0 }, { r = 0, g = 0, b = 0, a = 0.6 }, 1)
end

function GaleReadablePaper:Exit()
    local scr_w, scr_h = TheSim:GetScreenSize()
    -- self.close_button:Hide()
    self:SetClickable(false)
    self.hover:TintTo({ r = 0, g = 0, b = 0, a = self.hover.image.tint[4] }, { r = 0, g = 0, b = 0, a = 0 }, 1)

    self.paper:MoveTo(self.paper:GetPosition(), Vector3(0, -scr_h), 1, function()
        -- self:Kill()
        TheFrontEnd:PopScreen(self)
    end)
end

return GaleReadablePaper
