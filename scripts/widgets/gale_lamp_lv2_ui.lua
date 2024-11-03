local GaleLampUi = require("widgets/gale_lamp_ui")


local GaleLampLv2Ui = Class(GaleLampUi, function(self, owner, lamp)
    GaleLampUi._ctor(self, owner, lamp)

    self.linkstick:GetAnimState():SetBank("gale_lamp_lv2")
    self.linkstick:GetAnimState():SetBuild("gale_lamp_lv2")

    self.middle:GetAnimState():SetBank("gale_lamp_lv2")
    self.middle:GetAnimState():SetBuild("gale_lamp_lv2")
    self.middle:GetAnimState():SetMultColour(1, 1, 1, 1)


    self.joystick:GetAnimState():SetBank("gale_lamp_lv2_joystick")
    self.joystick:GetAnimState():SetBuild("gale_lamp_lv2_joystick")
end)

return GaleLampLv2Ui
