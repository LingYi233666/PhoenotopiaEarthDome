local GaleSkillElectricPunch = Class(function(self, inst)
    self.inst = inst
    self._anim_index = net_byte(inst.GUID, "GaleSkillElectricPunch._anim_index")
    self._enabled = net_bool(inst.GUID, "GaleSkillElectricPunch._enabled")
end)

local PUNCH_RANGE_BASE = 2

function GaleSkillElectricPunch:SetAnimIndex(index)
    self._anim_index:set(index)
end

function GaleSkillElectricPunch:GetAnimIndex()
    return self._anim_index:value()
end

function GaleSkillElectricPunch:SetEnabled(enabled)
    self._enabled:set(enabled)
end

function GaleSkillElectricPunch:IsEnabled()
    return self._enabled:value()
end

function GaleSkillElectricPunch:CanPunch(target)
    if self.inst.components.gale_skill_electric_punch then
        return self.inst.components.gale_skill_electric_punch:CanPunch(target)
    end

    if not (target and target:IsValid()) then
        return false
    end

    local range = target:GetPhysicsRadius(0) + PUNCH_RANGE_BASE

    return self:IsEnabled() and self:GetAnimIndex() > 0 and self:GetAnimIndex() < 3
        and distsq(target:GetPosition(), self.inst:GetPosition()) <= range * range
end

function GaleSkillElectricPunch:CanWork(target)

end

return GaleSkillElectricPunch
