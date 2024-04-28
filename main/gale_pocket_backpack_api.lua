local Image = require "widgets/image"
local GaleTooltip = require("widgets/galetooltip")
local GaleSubBuffTip = require "widgets/galesubbufftip"

AddClassPostConstruct("widgets/containerwidget", function(self)
    local old_Open = self.Open
    local old_Close = self.Close
    self.Open = function(self, container, doer, ...)
        local old_ret = old_Open(self, container, doer, ...)
        if container:HasTag("gale_pocket_backpack") then
            self.gale_pocket_backpack_ban_slots = {}

            self.gale_pocket_backpack_tip = self:AddChild(GaleSubBuffTip())
            self.gale_pocket_backpack_tip:SetBuffName(STRINGS.GALE_UI.GALE_POCKET_BACKPACK.LOCKED_SLOT.TITLE)
            self.gale_pocket_backpack_tip:SetBuffDesc(STRINGS.GALE_UI.GALE_POCKET_BACKPACK.LOCKED_SLOT.DESC)
            -- self.gale_pocket_backpack_tip:SetPosition(-200,0)
            self.gale_pocket_backpack_tip:SetScale(1 / self:GetScale().x)
            self.gale_pocket_backpack_tip:Hide()

            local max_slots = container.replica.container:GetNumSlots()
            local slotpos_preset = container.slotpos_preset

            for k, pos in pairs(slotpos_preset) do
                if k > max_slots then
                    local ui = self:AddChild(Image("images/frontend_redux.xml", "accountitem_frame_lock.tex"))
                    ui:SetScale(0.3)
                    ui:SetPosition(pos)
                    ui:SetOnGainFocus(function()
                        local tip_w, tip_h = self.gale_pocket_backpack_tip:GetSize()
                        self.gale_pocket_backpack_tip:SetPosition(-350 - tip_w / 2, pos.y)
                        self.gale_pocket_backpack_tip:Show()
                    end)
                    ui:SetOnLoseFocus(function()
                        self.gale_pocket_backpack_tip:Hide()
                    end)
                    self.gale_pocket_backpack_ban_slots[k] = ui
                end
            end
        end
        return old_ret
    end

    self.Close = function(self, ...)
        if self.gale_pocket_backpack_ban_slots then
            for k, v in pairs(self.gale_pocket_backpack_ban_slots) do
                v:Kill()
            end
            self.gale_pocket_backpack_ban_slots = nil
        end

        return old_Close(self, ...)
    end
end)

AddPrefabPostInit("sewing_kit", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("gale_pocket_backpack_updater")
end)


AddAction("GALE_UPDATE_POCKET_BACKPACK", "GALE_UPDATE_POCKET_BACKPACK", function(act)
    local kit = act.invobject
    local backpack = act.target

    if kit and backpack and backpack.level and backpack.level < 14 then
        backpack:DoLevelUp()
        kit:Remove()

        act.doer.SoundEmitter:PlaySound("gale_sfx/other/flag_touch")

        return true
    end
end)

ACTIONS.GALE_UPDATE_POCKET_BACKPACK.priority = 1
ACTIONS.GALE_UPDATE_POCKET_BACKPACK.strfn = ACTIONS.SEW.strfn
ACTIONS.GALE_UPDATE_POCKET_BACKPACK.actionmeter = true

AddComponentAction("USEITEM", "gale_pocket_backpack_updater", function(inst, doer, target, actions, right)
    if right and doer:HasTag("player") and target:HasTag("gale_pocket_backpack") and target.level and target.level < 14 then
        table.insert(actions, ACTIONS.GALE_UPDATE_POCKET_BACKPACK)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_UPDATE_POCKET_BACKPACK, function(inst)
    return "gale_dolongaction_25"
end))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GALE_UPDATE_POCKET_BACKPACK, function(inst)
    return "dolongaction"
end))
