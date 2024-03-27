local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ComingSoonTip = require "widgets/comingsoontip"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local GaleSkillSlot = require "widgets/galeskillslot"
local GaleKeyConfigPopupDialog = require "screens/gale_key_config_popupdialog"

local GaleCommon = require("util/gale_common")

local scrollbar_tint = {0xA0/255, 0x52/255, 0x2D/255, 1}

local function CanSetSkillKey(name)
    local node = GALE_SKILL_NODES[name:upper()]
    return node.data.OnPressed ~= nil 
        or node.data.OnReleased ~= nil 
        or node.data.OnPressed_Client ~= nil 
        or node.data.OnReleased_Client ~= nil 
end

-- GaleKeyConfiged is the second big widget in main menu

local GaleKeyConfiged = Class(Widget,function(self,owner,scroll_data)
    Widget._ctor(self, "GaleKeyConfiged")

    self.owner = owner
    self.scroll_data = scroll_data

    self:AddItemsAndList()

    -- self:SetVAnchor(ANCHOR_MIDDLE)
    -- self:SetHAnchor(ANCHOR_MIDDLE)
end)

function GaleKeyConfiged:AddItemsAndList()
    self.data = {}

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(
        self.data,
        {
            context = {},
            widget_width  = self.scroll_data.widget_width,
            widget_height = self.scroll_data.widget_height,
            num_visible_rows = self.scroll_data.num_visible_rows,
            num_columns      = self.scroll_data.num_columns,
            item_ctor_fn = function(context, i)
                local label = Widget("label")
                local label_root = label:AddChild(Widget("label_root"))

                label_root.bg = label_root:AddChild(TEMPLATES.ListItemBackground(
                    self.scroll_data.widget_width, 
                    self.scroll_data.widget_height,function()
                        TheFrontEnd:PushScreen(GaleKeyConfigPopupDialog(self.owner,label.target))
                    end)
                )

                label_root.label_text = label_root:AddChild(Text(HEADERFONT, 28))
                label_root.label_text:SetVAlign(ANCHOR_TOP)
                label_root.label_text:SetHAlign(ANCHOR_LEFT)
                
                label_root.skill_img = label_root:AddChild(Image())

                label.SetText = function(_, new_label)
                    label_root.label_text:SetString(new_label)
                end

                label.SetTexture = function(_,xml,tex)
                    label_root.skill_img:SetTexture(xml,tex)
                end

                label.MakeLayout = function(_)
                    local img_wh = math.min(self.scroll_data.widget_width / 3.5,self.scroll_data.widget_height - 15)
                    local img_pos_x = -self.scroll_data.widget_width / 2 + img_wh / 2 + 15
                    label_root.skill_img:SetSize(img_wh,img_wh)
                    label_root.skill_img:SetPosition(img_pos_x,0)

                    local text_w,text_h = label_root.label_text:GetRegionSize()

                    local text_pos_x = math.max(0,img_pos_x + img_wh / 2 + text_w / 2 + 15)
                    label_root.label_text:SetPosition(text_pos_x,0)
                end
                -- Let bg get focus to change colour with gamepad navigation.
                label.focus_forward = label_root.bg

                return label

            end,
            apply_fn     = function(context, widget, data, index)
                if widget == nil then
                    return
                elseif data == nil then
                    widget:Hide()
                    return
                else
                    widget:Show()
                end

                widget.target = data.skill_name:lower()

                local key_str = data.key ~= nil and GaleCommon.GetStringFromKey(data.key) or STRINGS.GALE_UI.KEY_CONFIGED_CURRENT_NO_KEY

                widget:SetText(string.format(STRINGS.GALE_UI.KEY_CONFIGED_TIP,STRINGS.GALE_UI.SKILL_NODES[data.skill_name:upper()].NAME,key_str))

                -- data.skill_name:lower() is the skill name
                local skill_atlas = "images/ui/skill_slot/"..data.skill_name:lower()..".xml"
                local skill_image = data.skill_name:lower()..".tex" 
                if softresolvefilepath(skill_atlas) == nil then
                    -- print("GaleKeyConfiged Can't find "..skill_atlas..",use default...")
                    
                    skill_atlas = "images/ui/skill_slot/bufficon_empty.xml"
                    skill_image = "bufficon_empty.tex"
                end

                widget:SetTexture(skill_atlas,skill_image)
                
                widget:MakeLayout()
            end,
            scrollbar_offset = 15,
            scrollbar_height_offset = 0,
        }
    ))

    -- self.scroll_list.up_button.image:SetTint(unpack(scrollbar_tint))
	-- self.scroll_list.down_button.image:SetTint(unpack(scrollbar_tint))
	-- self.scroll_list.position_marker.image:SetTint(unpack(scrollbar_tint))
end


function GaleKeyConfiged:OnUpdate()
    self.data = {}

    -- if self.owner.replica.gale_skiller then
    --     for key,skill_name in pairs(self.owner.replica.gale_skiller.keyhandler) do
    --         -- local node = GLOBAL.GALE_SKILL_NODES[skill_name:upper()]
    --         table.insert(self.data,{
    --             key = key,
    --             skill_name = skill_name,
    --         })
    --     end
    -- end

    for skill_name_learned,v in pairs(self.owner.replica.gale_skiller.learned_skill) do
        if v and CanSetSkillKey(skill_name_learned) then
            local valid_key = nil 
            for key,skill_name_configed in pairs(self.owner.replica.gale_skiller.keyhandler) do
                if skill_name_configed == skill_name_learned then
                    valid_key = key 
                    break 
                end
            end 

            table.insert(self.data,{
                key = valid_key,
                skill_name = skill_name_learned,
            })

        end
    end
    self.scroll_list:SetItemsData(self.data)
    self.scroll_list:RefreshView() 
end

-- local GaleKeyConfiged = require "widgets/gale_key_configed" TheFrontEnd:PushScreen(GaleKeyConfiged(ThePlayer))

return GaleKeyConfiged