local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

local GaleSupportThem = Class(Widget,function(self,width,height)
    Widget._ctor(self, "GaleSupportThem")

    -- self.width = width
    -- self.height = height

    -- self.bg = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
    -- self.bg:SetSize(width,height)
    -- self.bg:SetTint(17/255,31/255,103/255,1.0)

    local ori_img_w,ori_img_h = 641,976
    local img_h = height - 15 
    local img_w = ori_img_w * img_h / ori_img_h

    local img_pos_x = -width/2 + img_w/2 + 10

    self.big_img = self:AddChild(Image("images/ui/supportthem.xml","supportthem.tex"))
    self.big_img:SetSize(img_w,img_h)
    self.big_img:SetPosition(img_pos_x,0)

    self.title = self:AddChild(Text(HEADERFONT, 60))
    self.title:SetString(STRINGS.GALE_UI.SUPPORT_THEM.TITLE)
    self.title:SetColour(unpack(UICOLOURS.HIGHLIGHT_GOLD))

    local title_w,title_h = self.title:GetRegionSize()
    local title_pos_x = img_pos_x + img_w / 2 + (width - img_w - 33) / 2
    local title_pos_y = height / 2 - title_h / 2 - 20

    self.title:SetPosition(title_pos_x,title_pos_y)

    self.text = self:AddChild(Text(HEADERFONT, 40))
    self.text:SetHAlign(ANCHOR_LEFT)
    -- self.text:SetVAlign(ANCHOR_TOP)
    self.text:SetMultilineTruncatedString(STRINGS.GALE_UI.SUPPORT_THEM.DESC,999, width - img_w - 33)

    local text_w,text_h = self.text:GetRegionSize()
    local text_pos_x = img_pos_x + img_w / 2 + text_w / 2 + 10
    local text_pos_y = height / 2 - text_h / 2 - 75

    self.text:SetPosition(text_pos_x,text_pos_y)


    local button_buy_pos_x = title_pos_x
    local button_buy_pos_y = -height / 2 + 150
    self.button_buy = self:AddChild(TEMPLATES.StandardButton(function() 
        VisitURL("https://store.steampowered.com/app/1436590/Phoenotopia_Awakening")
    end, STRINGS.GALE_UI.SUPPORT_THEM.BUTTON_BUY, {400, 80}))
    self.button_buy:SetPosition(button_buy_pos_x,button_buy_pos_y)

    local button_lao_xian_pos_x = title_pos_x
    local button_lao_xian_pos_y = -height / 2 + 75
    self.button_lao_xian = self:AddChild(TEMPLATES.StandardButton(function() 
        VisitURL("https://www.bilibili.com/video/BV1Yf4y147e2",false)
    end, STRINGS.GALE_UI.SUPPORT_THEM.BUTTON_LAO_XIAN, {400, 80}))
    self.button_lao_xian:SetPosition(button_lao_xian_pos_x,button_lao_xian_pos_y)
end)


return GaleSupportThem