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


    -- For [A-Z] key input to select
    local old_OnRawKey = self.OnRawKey
    self.OnRawKey = function(self, key, down, ...)
        local ret = old_OnRawKey(self, key, down, ...)

        local str = GaleCommon.GetStringFromKey(key)
        if str ~= nil then
            self.selected_key = key
            self.dialog.body:SetString(string.format(STRINGS.GALE_UI.KEY_SET_UI.TEXT_AFTER, str))
        end

        return ret
    end
end)


return GaleKeyConfigPopupDialog
