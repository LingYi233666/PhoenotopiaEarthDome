-- local GaleFamilyPortraits = require("widgets/gale_family_portraits")
local GaleReadablePaper = require("screens/gale_readable_paper")


AddClassPostConstruct("widgets/controls", function(self)
    function self:ShowGaleReadablePaper(title, content)
        local ui = GaleReadablePaper(self.owner, title, content)
        TheFrontEnd:PushScreen(ui)
        ui:Enter()
    end
end)
-- ThePlayer.HUD.controls:ShowGaleReadablePaper(nil,"ABCDEFG")
-- ThePlayer.HUD.controls:ShowGaleReadablePaper()


AddClientModRPCHandler("gale_rpc", "show_readable_paper", function(title_or_index, content)
    if ThePlayer and ThePlayer.HUD and TheFrontEnd then
        if title_or_index ~= nil and content ~= nil then
            ThePlayer.HUD.controls:ShowGaleReadablePaper(title_or_index, content)
        elseif title_or_index ~= nil and STRINGS.GALE_UI.READABLE_PAPER[title_or_index] ~= nil then
            local tab = STRINGS.GALE_UI.READABLE_PAPER[title_or_index]
            ThePlayer.HUD.controls:ShowGaleReadablePaper(tab.TITLE, tab.CONTENT)
        end
    end
end)


AddAction("GALE_READ_PAPER", "GALE_READ_PAPER", function(act)
    if act.doer and act.doer:IsValid() and act.doer.userid ~= nil
        and act.invobject and act.invobject:IsValid() and act.invobject.components.gale_readable_paper then
        return act.invobject.components.gale_readable_paper:ReadBy(act.doer)
    end
end)
ACTIONS.GALE_READ_PAPER.rmb = true

AddComponentAction("INVENTORY", "gale_readable_paper", function(inst, doer, actions, right)
    if doer and doer:HasTag("player") then
        table.insert(actions, ACTIONS.GALE_READ_PAPER)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_READ_PAPER, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GALE_READ_PAPER, "doshortaction"))
