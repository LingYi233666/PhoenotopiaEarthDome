local PopupDialogScreen = require "screens/redux/popupdialog"

local GaleCommon = require("util/gale_common")


local GaleKeyConfigPopupDialog = Class(PopupDialogScreen, function(self, owner, target_skill_name)
    PopupDialogScreen._ctor(self,
        STRINGS.GALE_UI.KEY_SET_UI.TITLE,
        STRINGS.GALE_UI.KEY_SET_UI.TEXT_BEFORE,
        {
            -- Buttons:
            {
                text = STRINGS.GALE_UI.KEY_SET_UI.DO_SET_SKILL_KEY,
                cb = function()
                    if self.selected_key then
                        self.owner.replica.gale_skiller:SetKeyHandler(self.selected_key, self.target:lower())
                        self.owner.replica.gale_skiller:SaveKeySetting()
                        self.owner:PushEvent("gale_skiller_ui_update")
                    else
                        print("key_select_ui No setting !")
                    end
                    TheFrontEnd:PopScreen(self)
                end
            },
            {
                text = STRINGS.GALE_UI.KEY_SET_UI.CLEAR_SKILL_KEY,
                cb = function()
                    local old_key = nil
                    for key, skill_name in pairs(self.owner.replica.gale_skiller.keyhandler) do
                        if skill_name:lower() == self.target:lower() then
                            old_key = key
                            break
                        end
                    end

                    if old_key then
                        self.owner.replica.gale_skiller:SetKeyHandler(old_key, nil)
                        self.owner.replica.gale_skiller:SaveKeySetting()

                        self.owner:PushEvent("gale_skiller_ui_update")
                    end
                    TheFrontEnd:PopScreen(self)
                end
            },
            {
                text = STRINGS.GALE_UI.KEY_SET_UI.SET_KEY_CANCEL,
                cb = function()
                    TheFrontEnd:PopScreen(self)
                end
            },
        })

    self.owner = owner
    self.selected_key = nil
    self.target = target_skill_name
end)


function GaleKeyConfigPopupDialog:OnRawKey(key, down)
    if down then
        local key_str = GaleCommon.GetStringFromKey(key)

        if key_str then
            self.selected_key = key
            self.dialog.body:SetString(string.format(STRINGS.GALE_UI.KEY_SET_UI.TEXT_AFTER, key_str))
        end
    end

    if GaleKeyConfigPopupDialog._base.OnRawKey(self, key, down) then return true end
end

function GaleKeyConfigPopupDialog:OnMouseButton(mousebutton, down, x, y)
    local valid_mousebuttons = {
        -- MOUSEBUTTON_LEFT,
        -- MOUSEBUTTON_RIGHT,
        MOUSEBUTTON_MIDDLE, -- MOUSEBUTTON_MIDDLE
        1005,               -- "Mouse Button 4",
        1006                -- "Mouse Button 5",
    }

    local entitiesundermouse = TheInput:GetAllEntitiesUnderMouse()
    local hud_entity_is_button = false

    -- print("hud_entity:", hud_entity, hud_entity.widget)

    -- for _, hud_entity in pairs(entitiesundermouse) do
    --     print("hud_entity:", hud_entity, hud_entity.widget)

    --     for k, v in pairs(self.dialog.actions.items) do
    --         if hud_entity.widget == v then
    --             hud_entity_is_button = true
    --             break
    --         end
    --     end
    -- end

    if down and not hud_entity_is_button and
        table.contains(valid_mousebuttons, mousebutton) then
        local button_str = GaleCommon.GetStringFromKey(mousebutton)
        if button_str then
            self.selected_key = mousebutton
            self.dialog.body:SetString(string.format(STRINGS.GALE_UI.KEY_SET_UI.TEXT_AFTER, button_str))
        end
    end

    if GaleKeyConfigPopupDialog._base.OnMouseButton(self, mousebutton, down, x, y) then
        return true
    end
end

return GaleKeyConfigPopupDialog
