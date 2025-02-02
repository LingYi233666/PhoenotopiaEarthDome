local WendyWardingBondEnchant = Class(function(self, inst)
    self.inst = inst

    self.protector = nil
    self.beloved = nil

    self.modifier_key_name = "wendy_warding_bond_enchant"
    self.damage_decrease_percent = 0.5
end)


function WendyWardingBondEnchant:Bond(protector, beloved)
    if self.protector or self.beloved then
        self:BreakBond()
    end

    self.protector = protector
    self.beloved = beloved

    self.beloved.components.health.externalabsorbmodifiers:SetModifier(self.inst, self.damage_decrease_percent,
        self.modifier_key_name)
    self.beloved.components.locomotor:SetExternalSpeedMultiplier(self.inst, self.modifier_key_name, 1.1)

    self._share_damage_fn = function(_, data)
        local original_damage = data.original_damage
        local attacker = data.attacker

        local damage = original_damage * self.damage_decrease_percent
        local spdamage = {}

        if data.spdamage then
            for damage_type, value in pairs(data.spdamage) do
                spdamage[damage_type] = value * self.damage_decrease_percent
            end
        end

        self.protector.components.combat:GetAttacked(self.inst, damage, nil, data.stimuli, spdamage)
    end

    self._on_partner_death_or_invalid = function()
        self:BreakBond()
    end

    self.inst:ListenForEvent("playerdeactivated", self._on_partner_death_or_invalid, self.protector)
    self.inst:ListenForEvent("death", self._on_partner_death_or_invalid, self.protector)
    self.inst:ListenForEvent("onremove", self._on_partner_death_or_invalid, self.protector)

    -- incase that beloved is a player
    self.inst:ListenForEvent("playerdeactivated", self._on_partner_death_or_invalid, self.beloved)
    self.inst:ListenForEvent("death", self._on_partner_death_or_invalid, self.beloved)
    self.inst:ListenForEvent("onremove", self._on_partner_death_or_invalid, self.beloved)

    self.inst:ListenForEvent("attacked", self._share_damage_fn, self.beloved)
end

function WendyWardingBondEnchant:BreakBond()
    if self.beloved and self.beloved:IsValid() then
        self.beloved.components.health.externalabsorbmodifiers:RemoveModifier(self.inst, self.modifier_key_name)
        self.beloved.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, self.modifier_key_name)

        self.inst:RemoveEventCallback("playerdeactivated", self._on_partner_death_or_invalid, self.beloved)
        self.inst:RemoveEventCallback("death", self._on_partner_death_or_invalid, self.beloved)
        self.inst:RemoveEventCallback("onremove", self._on_partner_death_or_invalid, self.beloved)

        self.inst:RemoveEventCallback("attacked", self._share_damage_fn, self.beloved)
    end

    if self.protector and self.protector:IsValid() then
        self.inst:RemoveEventCallback("playerdeactivated", self._on_partner_death_or_invalid, self.protector)
        self.inst:RemoveEventCallback("death", self._on_partner_death_or_invalid, self.protector)
        self.inst:RemoveEventCallback("onremove", self._on_partner_death_or_invalid, self.protector)
    end

    self._share_damage_fn = nil
    self._on_partner_death_or_invalid = nil

    self.protector = nil
    self.beloved = nil
end

function WendyWardingBondEnchant:GetDebugString()
    return string.format("Protector: %s. Beloved: %s. Damage decrease: %d%%.",
        tostring(self.protector), tostring(self.beloved), self.damage_decrease_percent * 100)
end

return WendyWardingBondEnchant
