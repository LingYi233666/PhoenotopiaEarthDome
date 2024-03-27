local CG_Assets = {
    Asset( "IMAGE", "images/ui/CG/CG_1A.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_1A.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_1B.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_1B.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_1C.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_1C.xml" ),

    Asset( "IMAGE", "images/ui/CG/CG_2A.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_2A.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_2B.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_2B.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_2C.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_2C.xml" ),

    Asset( "IMAGE", "images/ui/CG/CG_3A.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_3A.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_3B.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_3B.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_3C.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_3C.xml" ),

    Asset( "IMAGE", "images/ui/CG/CG_5A.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_5A.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_5B.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_5B.xml" ),

	Asset( "IMAGE", "images/ui/CG/CG_5C.tex" ),
    Asset( "ATLAS", "images/ui/CG/CG_5C.xml" ),
}

for _,v in pairs(CG_Assets) do
	table.insert(Assets, v)
end

-- local GaleCG = require("widgets/gale_cg_images")
-- local GaleProgressiveText = require("widgets/gale_progressive_text")
-- local GaleProgressiveTextGroup = require("widgets/gale_progressive_text_group")
-- local GalePptPage = require("widgets/gale_ppt_page")
-- local GalePptSequence = require("widgets/gale_ppt_sequence")
-- local ComingSoonTip = require("widgets/comingsoontip")

local GaleFirstCG = require("screens/gale_first_cg")
local Image = require("widgets/image")
local json = require("json")

local function ReadHaveSeenFirstPlayCG()
    local has_seen = false 
    TheSim:GetPersistentString("mod_config_data/gale_first_cg_played", function(success, encoded_data)
        has_seen = success
    end)

    return has_seen
end

local function WriteHaveSeenFirstPlayCG()
    TheSim:SetPersistentString("mod_config_data/gale_first_cg_played", "gale_first_cg_played", false)
end
-- ThePlayer.AnimState:SetDeltaTimeMultiplier(0.1)
AddClassPostConstruct("screens/redux/lobbyscreen", function(self)
    self.no_more_sound = false 

	local old_self_cb = self.cb 

    local old_StartLobbyMusic = self.StartLobbyMusic
    self.StartLobbyMusic = function(self,...)
        -- print("StartLobbyMusic!!!",self.issoundplaying)
        if self.no_more_sound then
            self:StopLobbyMusic()
            return 
        end
        return old_StartLobbyMusic(self,...)
    end

    -- local old_StopLobbyMusic = self.StopLobbyMusic
    -- self.StopLobbyMusic = function(self,...)
    --     print("StopLobbyMusic!!!",self.issoundplaying)
    --     return old_StopLobbyMusic(self,...)
    -- end

    self.cb = function(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet,...)
        -- print(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)

        if char == "gale" and not ReadHaveSeenFirstPlayCG() then
            self.no_more_sound = true 
            self:StopLobbyMusic()
            TheFrontEnd:GetSound():PlaySound("gale_sfx/menu/intro_menu_start")
            TheFrontEnd:PushScreen(GaleFirstCG(function()
                self.black = self:AddChild(Image("images/global.xml", "square.tex"))
                self.black:SetVRegPoint(ANCHOR_MIDDLE)
                self.black:SetHRegPoint(ANCHOR_MIDDLE)
                self.black:SetVAnchor(ANCHOR_MIDDLE)
                self.black:SetHAnchor(ANCHOR_MIDDLE)
                self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
                self.black:SetTint(0, 0, 0, 1)
                self.black:MoveToFront()
                WriteHaveSeenFirstPlayCG()
                old_self_cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
            end))
        else 
            return old_self_cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet,...)
        end
        
    end
end)




-- c_test_cg()
-- ThePlayer.HUD.controls.CG_TEST:DoMouseClick()
-- ThePlayer.HUD.controls.CG_TEST:SetPosition(0,100,0)
GLOBAL.c_test_cg = function()
    TheFrontEnd:PushScreen(GaleFirstCG())
    -- if ThePlayer.HUD.controls.CG_TEST then
    --     ThePlayer.HUD.controls.CG_TEST:Kill()
    -- end

    -- ThePlayer.HUD.controls.CG_TEST = ThePlayer.HUD.controls:AddChild(GalePptSequence.FirstPlay())
    -- ThePlayer.HUD.controls.CG_TEST:SetVAnchor(ANCHOR_MIDDLE)
    -- ThePlayer.HUD.controls.CG_TEST:SetHAnchor(ANCHOR_MIDDLE)
    -- ThePlayer.HUD.controls.CG_TEST:SetPosition(0,0,0)
end

-- c_test_cg()
-- GLOBAL.c_test_cg = function()
--     if ThePlayer.HUD.controls.CG_TEST then
--         ThePlayer.HUD.controls.CG_TEST:Kill()
--     end

--     ThePlayer.HUD.controls.CG_TEST = ThePlayer.HUD.controls:AddChild(GaleCG.TheGreatBattleGround())

--     ThePlayer.HUD.controls.CG_TEST:SetVAnchor(ANCHOR_MIDDLE)
--     ThePlayer.HUD.controls.CG_TEST:SetHAnchor(ANCHOR_MIDDLE)
--     ThePlayer.HUD.controls.CG_TEST:SetPosition(0,0,0)
-- end

-- c_test_ptext()
-- ThePlayer.HUD.controls.P_TEXT_TEST:DoMouseClick()
-- GLOBAL.c_test_ptext = function()
--     if ThePlayer.HUD.controls.P_TEXT_TEST then
--         ThePlayer.HUD.controls.P_TEXT_TEST:Kill()
--     end

--     local ui = GaleProgressiveTextGroup({
--         {
--             text = "我是测试假文1，\n测测测测测测测测测测测测测1。\n安定坊那我发你瓦房牛蛙饭1。"
--         },
--         {
--             text = "我是测试假文2，\n测测测测测测测测测测测测测2。\n安定坊那我发你瓦房牛蛙饭2。"
--         },
--         {
--             text = "我是测试假文3，\n测测测测测测测测测测测测测3。\n安定坊那我发你瓦房牛蛙饭3。"
--         },
--     })
--     -- ThePlayer.HUD.controls.P_TEXT_TEST = ThePlayer.HUD.controls:AddChild(GaleProgressiveText(NUMBERFONT, 55,"我是测试假文，\n测测测测测测测测测测测测测。\n安定坊那我发你瓦房牛蛙饭。"))

--     ThePlayer.HUD.controls.P_TEXT_TEST = ThePlayer.HUD.controls:AddChild(ui)

--     ThePlayer.HUD.controls.P_TEXT_TEST:SetVAnchor(ANCHOR_MIDDLE)
--     ThePlayer.HUD.controls.P_TEXT_TEST:SetHAnchor(ANCHOR_MIDDLE)
--     ThePlayer.HUD.controls.P_TEXT_TEST:SetPosition(0,0,0)

--     ThePlayer.HUD.controls.P_TEXT_TEST:DoMouseClick()
-- end