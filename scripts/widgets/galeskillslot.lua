local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local GaleSkillSlot = Class(ImageButton,function(self,code_name,atlas,image)
    atlas = atlas or "images/ui/skill_slot/bufficon_empty.xml"
    image = image or "bufficon_empty.tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        print("GaleSkillSlot Can't find "..atlas..",use default...")
        
        atlas = "images/ui/skill_slot/bufficon_empty.xml"
        image = "bufficon_empty.tex"
    end

    ImageButton._ctor(self, atlas, image, image, image, image, image)

    -- UNLOCKED = "（已解锁）",
	-- CAN_UNLOCK = "（可解锁）",
	-- CANT_UNLOCK = "（未解锁）",
    self.status = "CANT_UNLOCK"
    self.code_name = ""

    self.corner_image = self:AddChild(Image())
    self.corner_image:SetPosition(50,-30)
    self.corner_image:Hide()

    self:SetNormalScale(0.55)
    self:SetFocusScale(0.55)

    

    self:SetCodeName(code_name)
end)

function GaleSkillSlot:SetLockStatus(status)
    self.status = status
    self:SetTooltip(nil)
    self:UpdateToolTip()
end

function GaleSkillSlot:SetCodeName(name)
    self.code_name = name
    self:SetTooltip(nil)
    self:UpdateToolTip()
end

function GaleSkillSlot:UpdateToolTip()
    if self.code_name then
        local data = STRINGS.GALE_UI.SKILL_NODES[self.code_name:upper()]
        if data then
            self:SetTooltip(data.NAME)
        end
    end

    
    self.image:SetTint(1,1,1,1)
    self.corner_image:SetTint(1,1,1,1)
    self.corner_image:Show()
    self.corner_image:SetPosition(50,-30)

    if self.status == "UNLOCKED" then
        self.corner_image:SetTexture("images/frontend_redux.xml","accountitem_frame_arrow.tex")
        self.corner_image:SetScale(0.55)
        self.corner_image:SetPosition(45,-30)
    elseif self.status == "CAN_UNLOCK" then
        -- self.corner_image:Hide()
        self.corner_image:SetTexture("images/ui.xml","new_label_motd2.tex")
        self.corner_image:SetScale(0.45)
        self.corner_image:SetPosition(35,-30)
    elseif self.status == "CANT_UNLOCK" then
        self.corner_image:SetTexture("images/frontend_redux.xml","accountitem_frame_lock.tex")
        self.corner_image:SetScale(0.3)
        self.image:SetTint(100/255,100/255,100/255,1)
        self.corner_image:SetTint(100/255,100/255,100/255,1)
    else
        self.corner_image:Hide()
    end
end

return GaleSkillSlot