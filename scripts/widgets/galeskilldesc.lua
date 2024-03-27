local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local GaleTooltip = require "widgets/galetooltip"
local GaleSkillUnlockPanel = require "widgets/galeskillunlockpanel"

local PopupDialogScreen = require "screens/redux/popupdialog"

local GaleCommon = require("util/gale_common")

-- Param 1:Control blank space,must >= 0
-- Param 2:Control image cut,if not cut,use -0.125
-- Param 3:Control main effect,the larger it is,the more Gui-Chu the image show 
-- inst.AnimState:SetErosionParams(0, 0, 0)

local function BrainBlink(inst,self,enable)
    if self.brain_blinking_task then
        self.brain_blinking_task:Cancel()
        self.brain_blinking_task = nil 
    end
    if enable then
        self.brain_blinking_task = inst:DoPeriodicTask(FRAMES * 3,function()
            -- self.brain:SetScale(1 + UnitRand() * 0.05,1 + UnitRand() * 0.05,1 + UnitRand() * 0.05)
            self.brain:GetAnimState():SetErosionParams(GetRandomMinMax(0,0.33),GetRandomMinMax(-0.5,0.5),GetRandomMinMax(-2,0))
        end)
        self.brain_blink_task = inst:DoTaskInTime(GetRandomMinMax(0.8,1),BrainBlink,self,false)
    else 
        -- self.brain:SetScale(1,1,1)
        self.brain:GetAnimState():SetErosionParams(0,0,0)
        self.brain_blink_task = inst:DoTaskInTime(GetRandomMinMax(3,4),BrainBlink,self,true)
    end
end

local GaleSkillDesc = Class(Widget,function(self,owner,w,h)
    Widget._ctor(self,"GaleSkillDesc")

    self.owner = owner

    self.ui_w = w
    self.ui_h = h

    self.target = nil 

    self.leftbar = self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex"))
    self.leftbar:SetSize(13,h)
    self.leftbar:SetPosition(-w / 2,0)

    self.desc_image = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
    self.desc_image:SetSize(w - 20,h / 3)
    local desc_w,desc_h = self.desc_image:GetSize()
    self.desc_image:SetPosition(0,(h - desc_h) / 2 - 5)
    self.desc_image:SetTint(unpack(UICOLOURS.BROWN_MEDIUM))

    self.brain = self.desc_image:AddChild(UIAnim())
    self.brain:GetAnimState():SetBank("gale_skill_desc_brain")
    self.brain:GetAnimState():SetBuild("gale_skill_desc_brain")
    self.brain:GetAnimState():PlayAnimation("idle",true)
    self.brain:GetAnimState():SetSymbolMultColour("brain",214/255,154/255,148/255,1)
    for name,_ in pairs(GALE_SKILL_TREE) do
        self.brain:GetAnimState():HideSymbol(name:lower())
    end

    self.brain_blink_task = self.inst:DoTaskInTime(GetRandomMinMax(3,4),BrainBlink,self,true)
    

    local desc_x,desc_y,_ = self.desc_image:GetPosition():Get()

    self.title = self:AddChild(Text(NUMBERFONT, 55,""))
	-- self.title:SetHAlign(ANCHOR_LEFT)
    self.title:SetPosition(0,desc_y - desc_h/2 - 35)

    local title_x,title_y,_ = self.title:GetPosition():Get()
    self.text = self:AddChild(Text(NUMBERFONT, 33,""))
    self.text:SetVAlign(ANCHOR_TOP)
    self.text:SetHAlign(ANCHOR_LEFT)

    self.unlock_panel = self:AddChild(GaleSkillUnlockPanel(owner))
    self.unlock_panel:SetPosition(0,-h / 2 + 40)

    
end)

function GaleSkillDesc:SetTarget(target)
    self.target = target 
    self.unlock_panel:SetTarget(target)
    self:OnUpdate()
end

function GaleSkillDesc:SetTitle(str)
    self.title:SetString(str)
end

function GaleSkillDesc:SetDesc(str)
    local title_x,title_y,_ = self.title:GetPosition():Get()
    self.text:SetMultilineTruncatedString(str,14, self.ui_w - 20, 163, true)
    local text_w,text_h = self.text:GetRegionSize()
    self.text:SetPosition(0,title_y - 25 - text_h / 2)
end


function GaleSkillDesc:OnUpdate()
    self:SetTitle("")
    self:SetDesc("")

    

    if self.target then
        local tab = STRINGS.GALE_UI.SKILL_TREE[self.target:upper()] or STRINGS.GALE_UI.SKILL_NODES[self.target:upper()]
        if tab then
            self:SetTitle(tab.NAME)
            self:SetDesc(tab.DESC)


            if STRINGS.GALE_UI.SKILL_TREE[self.target:upper()] ~= nil then
                for name,_ in pairs(GALE_SKILL_TREE) do
                    self.brain:GetAnimState():HideSymbol(name:lower())
                end
                self.brain:GetAnimState():ShowSymbol(self.target:lower())
            end
            
        end      
    else 
        for name,_ in pairs(GALE_SKILL_TREE) do
            self.brain:GetAnimState():HideSymbol(name:lower())
        end
    end

    self.unlock_panel:OnUpdate()
end

return GaleSkillDesc