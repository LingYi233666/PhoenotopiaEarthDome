local SourceModifierList = require("util/sourcemodifierlist")

local GaleSpellPowerLevel = Class(function(self, inst)
    self.inst = inst

    self.current = 0
    self.max = 10

    self.externallevelmodifiers = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function GaleSpellPowerLevel:DoDeltaLevel(delta)
    self.current = math.clamp(self.current + delta, 0, self.max)
end

function GaleSpellPowerLevel:GetLevel()
    return self.current + self.externallevelmodifiers:Get()
end

function GaleSpellPowerLevel:OnSave()
    return {
        current = self.current,
    }
end

function GaleSpellPowerLevel:OnLoad(data)
    if data ~= nil then
        if data.current ~= nil then
            self.current = data.current
        end
    end
end

return GaleSpellPowerLevel
