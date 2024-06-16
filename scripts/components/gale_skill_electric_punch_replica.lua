local GaleSkillElectricPunch = Class(function(self, inst)
    self.inst = inst
    self.anim_index = net_byte(inst.GUID, "GaleSkillElectricPunch.anim_index")
end)

function GaleSkillElectricPunch:SetAnimIndex(index)
    self.anim_index:set(index)
end

function GaleSkillElectricPunch:GetAnimIndex()
    return self.anim_index:value()
end

function GaleSkillElectricPunch:CanPunch(target)
    if self.inst.components.gale_skill_electric_punch then
        return self.inst.components.gale_skill_electric_punch:CanPunch()
    end

    local range = target:GetPhysicsRadius(0) + self.inst.replica.combat._attackrange:value()


    return self:GetAnimIndex() > 0 and self:GetAnimIndex() < 3
        and distsq(target:GetPosition(), self.inst:GetPosition()) <= range * range
end

return GaleSkillElectricPunch
