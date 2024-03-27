local blaster_api_Assets = {
    Asset("ANIM", "anim/ui_rook_charge_fx.zip"),

	Asset("SOUNDPACKAGE", "sound/rook_charge_sound.fev"),
    Asset("SOUND", "sound/rook_charge_sound.fsb"),
	
}

for k,v in pairs(blaster_api_Assets) do
	table.insert(Assets, v)
end

local GaleBlasterChargeUI = require("widgets/gale_blaster_charge")
AddClassPostConstruct("widgets/controls", function(self)
	self.GaleBlasterChargeUI = self:AddChild(GaleBlasterChargeUI(self.owner))

	self.GaleBlasterChargeUI:SetHAnchor(2)
	self.GaleBlasterChargeUI:SetVAnchor(2)
	self.GaleBlasterChargeUI:SetPosition(-660,125)

	self.GaleBlasterChargeUI:Hide()
	self.GaleBlasterChargeUI:MoveToBack()
end)

AddReplicableComponent("gale_blaster_charge")
