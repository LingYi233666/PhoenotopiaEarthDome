local SourceModifierList = require("util/sourcemodifierlist")

local preset_mult_add_order = {
    "MULT_FIRST",
    "ADD_FIRST",
}


local GaleSpDefenseBase = Class(function(self, inst)
    self.inst = inst
    self.basedefense = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
    self.defense_mult_add_order = 1
end)

-- key: name, value: number
GaleSpDefenseBase.MultAddOrder = table.invert(preset_mult_add_order)


function GaleSpDefenseBase:SetBaseDefense(defense)
    self.basedefense = defense
end

function GaleSpDefenseBase:GetBaseDefense()
    return self.basedefense
end

function GaleSpDefenseBase:GetDefense()
    assert(preset_mult_add_order[self.defense_mult_add_order] ~= nil)

    if self.defense_mult_add_order == GaleSpDefenseBase.MultAddOrder.MULT_FIRST then
        return self.basedefense * self.externalmultipliers:Get() + self.externalbonuses:Get()
    elseif self.defense_mult_add_order == GaleSpDefenseBase.MultAddOrder.ADD_FIRST then
        return (self.basedefense + self.externalbonuses:Get()) * self.externalmultipliers:Get()
    end

    return 0
end

--------------------------------------------------------------------------

function GaleSpDefenseBase:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function GaleSpDefenseBase:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function GaleSpDefenseBase:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function GaleSpDefenseBase:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function GaleSpDefenseBase:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function GaleSpDefenseBase:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function GaleSpDefenseBase:GetDebugString()
    return string.format("Defense=%.2f [%.2fx%.2f+%.2f]", self:GetDefense(), self:GetBaseDefense(), self:GetMultiplier(),
        self:GetBonus())
end

return GaleSpDefenseBase
