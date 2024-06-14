local SourceModifierList = require("util/sourcemodifierlist")

local preset_mult_add_order = {
    -- damage = self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
    "MULT_FIRST",

    -- damage = (self.basedamage + self.externalbonuses:Get()) * self.externalmultipliers:Get()
    "ADD_FIRST",
}

local GaleSpDamageBase = Class(function(self, inst)
    self.inst = inst
    self.basedamage = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
    self.damage_mult_add_order = 1
end)

-- key: name, value: number
GaleSpDamageBase.MultAddOrder = table.invert(preset_mult_add_order)


function GaleSpDamageBase:SetBaseDamage(damage)
    self.basedamage = damage
end

function GaleSpDamageBase:GetBaseDamage()
    return self.basedamage
end

function GaleSpDamageBase:GetDamage()
    assert(preset_mult_add_order[self.damage_mult_add_order] ~= nil)

    if self.damage_mult_add_order == GaleSpDamageBase.MultAddOrder.MULT_FIRST then
        return self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
    elseif self.damage_mult_add_order == GaleSpDamageBase.MultAddOrder.ADD_FIRST then
        return (self.basedamage + self.externalbonuses:Get()) * self.externalmultipliers:Get()
    end

    return 0
end

--------------------------------------------------------------------------

function GaleSpDamageBase:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function GaleSpDamageBase:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function GaleSpDamageBase:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function GaleSpDamageBase:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function GaleSpDamageBase:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function GaleSpDamageBase:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function GaleSpDamageBase:GetDebugString()
    return string.format("Damage=%.2f [%.2fx%.2f+%.2f]", self:GetDamage(), self:GetBaseDamage(), self:GetMultiplier(),
        self:GetBonus())
end

return GaleSpDamageBase
