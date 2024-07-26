local GaleCommon = require("util/gale_common")

local GaleMultiThruster = Class(function(self, inst)
    self.inst = inst

    self.forward_offset = 1.25

    self.attack_range = 1.25
    self.instant_mults = { 0.75, 0.75 }

    self.onstartfn = nil
    self.onstopfn = nil
    self.oncastfn = nil
end)

----------------------------------------------------------------------------
function GaleMultiThruster:GetForwardOffset()
    return self.forward_offset
end

----------------------------------------------------------------------------
function GaleMultiThruster:SetForwardOffset(forward_offset)
    self.forward_offset = forward_offset
end

function GaleMultiThruster:SetAttackRange(attack_range)
    self.attack_range = attack_range
end

function GaleMultiThruster:SetAttackMults(m1, m2)
    if m1 ~= nil and m2 ~= nil then
        self.instant_mults = { m1, m2 }
    elseif m1 ~= nil then
        self.instant_mults = { m1, m1 }
    end
end

----------------------------------------------------------------------------
function GaleMultiThruster:StartThrusting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstartfn and self.onstartfn(self.inst, owner)
end

function GaleMultiThruster:StopThrusting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstopfn and self.onstopfn(self.inst, owner)
end

function GaleMultiThruster:GetHitPos(doer)
    local face_vec = GaleCommon.GetFaceVector(doer)
    local hit_pos = face_vec * self.forward_offset + doer:GetPosition()

    return hit_pos
end

function GaleMultiThruster:DoThrust(doer, target)
    local hit_pos = self:GetHitPos(doer)

    if self.attack_range > 0 then
        GaleCommon.AoeDoAttack(doer, hit_pos, self.attack_range, function(doer, other)
                return self.inst,
                    nil,
                    nil,
                    GetRandomMinMax(self.instant_mults[1], self.instant_mults[2]),
                    true
            end,
            function(doer, other)
                return doer.components.combat:CanTarget(other)
                    and not doer.components.combat:IsAlly(other)
            end)
    end

    if self.oncastfn == nil or self.oncastfn(self.inst, doer, target) then
        return true
    end
end

return GaleMultiThruster
