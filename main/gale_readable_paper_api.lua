local GaleFamilyPortraits = require("widgets/gale_family_portraits")
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


AddClientModRPCHandler("gale_rpc", "show_readable_paper", function(title, content)
    if ThePlayer and ThePlayer.HUD and TheFrontEnd then
        ThePlayer.HUD.controls:ShowGaleReadablePaper(title, content)
    end
end)
