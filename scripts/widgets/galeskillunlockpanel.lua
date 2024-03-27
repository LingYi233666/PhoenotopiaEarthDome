local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"
local ImageButton = require "widgets/imagebutton"
local IngredientUI = require "widgets/ingredientui"
local PopupDialogScreen = require "screens/redux/popupdialog"
local GaleKeyConfigPopupDialog = require "screens/gale_key_config_popupdialog"

local GaleCommon = require("util/gale_common")

local GaleSkillUnlockPanel = Class(Widget,function(self,owner)
    Widget._ctor(self,"GaleSkillUnlockPanel")

    self.target = nil 
    self.owner = owner

    self.unlock_button = self:AddChild(ImageButton())
    self.unlock_button:AddChild(Text(DEFAULTFONT,40,STRINGS.GALE_UI.SKILL_UNLOCK_PANEL.UNLOCK))
    self.unlock_button:Hide()
    
    self.setkey_button = self:AddChild(ImageButton())
    self.setkey_button:AddChild(Text(DEFAULTFONT,40,STRINGS.GALE_UI.SKILL_UNLOCK_PANEL.SET_KEY))
    self.setkey_button:Hide()

    self.upper_tip = self:AddChild(Text(NUMBERFONT, 45,""))
    self.upper_tip:SetPosition(0,100,0)
    self.upper_tip:Hide()

    self.small_tip = self:AddChild(Text(NUMBERFONT, 45,""))
    self.small_tip:Hide()

    self.ingredient_uis = {}

    self._listen_and_update = function()
        self:OnUpdate()
    end

    self.inst:ListenForEvent("newactiveitem",self._listen_and_update,self.owner)
    self.inst:ListenForEvent("itemget",self._listen_and_update,self.owner)
    self.inst:ListenForEvent("itemlose",self._listen_and_update,self.owner)
    self.inst:ListenForEvent("stacksizechange",self._listen_and_update,self.owner)
    
end)

local function CanSetSkillKey(name)
    local node = GALE_SKILL_NODES[name:upper()]
    return node.data.OnPressed ~= nil 
        or node.data.OnReleased ~= nil 
        or node.data.OnPressed_Client ~= nil 
        or node.data.OnReleased_Client ~= nil 
end

function GaleSkillUnlockPanel:SetTarget(target)
    self.target = target 
    self:OnUpdate()
end

function GaleSkillUnlockPanel:OnUpdate()
    self.setkey_button:Hide()
    self.setkey_button:SetOnClick(nil)

    self.unlock_button:SetOnClick(nil)
    self.unlock_button:Hide()

    self.small_tip:Hide()

    for k,v in pairs(self.ingredient_uis) do
        v:Kill()    
    end
    self.ingredient_uis = {}
    
    if not self.target then
        return 
    end 

    local data = GALE_SKILL_NODES[self.target:upper()] and GALE_SKILL_NODES[self.target:upper()].data

    if not data then
        return 
    end

    if self.owner.replica.gale_skiller:IsLearned(self.target:lower()) then
        if CanSetSkillKey(self.target) then
            self.setkey_button:Show()
            self.setkey_button:SetOnClick(function()
                TheFrontEnd:PushScreen(GaleKeyConfigPopupDialog(self.owner,self.target))
            end)
        else
            self.small_tip:SetString(STRINGS.GALE_UI.SKILL_UNLOCK_PANEL.UNLOCKED)
            self.small_tip:SetColour(0,1,0,1)
            self.small_tip:Show()
        end
    else
        -- show recipes here
        local ingredients = data.ingredients
        local enough_ingredients = true
        if ingredients and #ingredients > 0 then
            local w = 64
            local div = 10
            local half_div = div * .5
            local offset = 0 --center
            local num = #ingredients
            if num > 1 then
                offset = offset - (w *.5 + half_div) * (num - 1)
            end
            for k,v in pairs(ingredients) do
                local has, num_found = self.owner.replica.inventory:Has(v.type,v.amount)
                local ui = self:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), v.amount, num_found, has, STRINGS.NAMES[string.upper(v.type)], self.owner, v.type))
                ui:SetPosition(Vector3(offset,80,0))
                offset = offset + w + half_div
                table.insert(self.ingredient_uis,ui)

                if not has then
                    enough_ingredients = false
                end
            end
        else

        end

        local can_unlock_skills = self.owner.replica.gale_skiller:GetCanUnlockSkill()
        if table.contains(can_unlock_skills,self.target:lower()) then
            if enough_ingredients then
                self.unlock_button:SetOnClick(function()
                    SendModRPCToServer(MOD_RPC["gale_rpc"]["unlock_skill"],self.target:lower())
                end)
                self.unlock_button:Show()
            else
                self.small_tip:SetString(STRINGS.GALE_UI.SKILL_UNLOCK_PANEL.CANT_UNLOCK_MISS_INV)
                self.small_tip:SetColour(1,0,0,1)
                self.small_tip:Show()
            end
            
        else
            self.small_tip:SetString(STRINGS.GALE_UI.SKILL_UNLOCK_PANEL.CANT_UNLOCK_NEED_PRE_SKILL)
            self.small_tip:SetColour(1,0,0,1)
            self.small_tip:Show()
        end

    end
end

return GaleSkillUnlockPanel