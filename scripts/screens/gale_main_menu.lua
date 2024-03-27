local HeaderTabs = require "widgets/redux/headertabs"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local SnapshotTab = require "widgets/redux/snapshottab"
local Subscreener = require "screens/redux/subscreener"
local TEMPLATES = require "widgets/redux/templates"
local TextListPopup = require "screens/redux/textlistpopup"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ComingSoonTip = require "widgets/comingsoontip"
local GaleSkillGroup = require "widgets/galeskillgroup"
local NineSlice = require "widgets/nineslice"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local GaleKeyConfiged = require "widgets/gale_key_configed"
local GaleFluteList = require "widgets/gale_flute_list"
local GaleSupportThem = require "widgets/gale_supportthem"

local GaleMainMenu = Class(Screen, function(self,owner)
    Screen._ctor(self, "GaleMainMenu")

    self.owner = owner 

    local scr_w, scr_h = TheSim:GetScreenSize() 
    
    self.BG_WIDTH = scr_w * 0.72
    self.BG_HEIGHT = scr_h * 0.7


    self:AddBGAndBars()

    self.tab_screens = {
        skill_tree = self:AddChild(GaleSkillGroup(self.owner)),
        keyconfig_check = self:AddChild(GaleKeyConfiged(self.owner,{
            widget_width = self.BG_WIDTH / 4 - 33,
            widget_height = self.BG_HEIGHT / 7,
            num_visible_rows = 6,
            num_columns = 4,
        })),
        flute_list = self:AddChild(GaleFluteList({
            widget_width = self.BG_WIDTH / 1.5 - 33,
            widget_height = self.BG_HEIGHT / 6 - 10,
            flute_wh = (self.BG_HEIGHT / 6 - 10) / 2.2,
        })),
        support_them = self:AddChild(GaleSupportThem(self.BG_WIDTH,self.BG_HEIGHT)),
        -- key3 = self:AddChild(ComingSoonTip()),
    }

    self.headertab_screener = Subscreener(self,
        self._BuildHeaderTab,self.tab_screens
    )
    self.headertab_screener:OnMenuButtonSelected("skill_tree")

    self.close_button = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	self.close_button:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
	self.close_button:SetPosition(self.BG_WIDTH / 2, self.BG_HEIGHT / 2 + 27)	

    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0, 0, 0,0)
    self.black:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    self.black:MoveToBack()

    self:GoToMiddle()

    -- You must push "gale_skiller_ui_update" event to update this ui (after learn skill,skill tree change,key config,etc)
    self.inst:ListenForEvent("gale_skiller_ui_update",function ()
        self:OnUpdate()
    end,self.owner)
    self.inst:DoTaskInTime(0,function() self:OnUpdate() end)
end)

function GaleMainMenu:GoToMiddle()
    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)

    self:SetPosition(0,0)
end

function GaleMainMenu:AddBGAndBars()
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)

    self.rect = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
    self.rect:SetSize(self.BG_WIDTH,self.BG_HEIGHT)
    self.rect:SetTint(r,g,b,0.6)

    self.bars = {}
	for i=1,4 do 
		table.insert(self.bars,self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex")))
	end

	self.corners = {}
	for i=1,4 do 
		table.insert(self.corners,self:AddChild(Image("images/ui/bufftips/corner.xml", "corner.tex")))
	end

    local bg_w,bg_h = self.rect:GetSize()

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

function GaleMainMenu:_BuildHeaderTab(subscreener)
    local tabs = {
        { key = "skill_tree", text = STRINGS.GALE_UI.MENU_SUB_SKILL_TREE, },
        { key = "keyconfig_check", text = STRINGS.GALE_UI.MENU_SUB_KEY_CONFIGED, },
        { key = "flute_list", text = STRINGS.GALE_UI.MENU_SUB_FLUTE_LIST,},
        { key = "support_them", text = STRINGS.GALE_UI.MENU_SUB_SUPPORT_THEM, },
        -- { key = "key3", text = "KEY_3", },
    }

    self.header_tabs = self.rect:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    self.header_tabs:SetPosition(0, self.BG_HEIGHT/2 + 27)
    self.header_tabs:MoveToBack()
    

    return self.header_tabs.menu
end


function GaleMainMenu:OnUpdate()
    -- print("GaleMainMenu OnUpdate...")
    self.tab_screens.skill_tree:OnUpdate()
    self.tab_screens.keyconfig_check:OnUpdate()
end

-- GaleMainMenu=require("screens/gale_main_menu") TEST_MAIN=GaleMainMenu() TheFrontEnd:PushScreen(TEST_MAIN)
-- TheFrontEnd:PopScreen(TEST_MAIN) TEST_MAIN=nil 

return GaleMainMenu