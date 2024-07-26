local GaleCommon = require("util/gale_common")

local GaleHelmsplitter = Class(function(self, inst)
    self.inst = inst

    self.forward_offset = 1.5

    self.attack_range = 2.5
    self.instant_mults = { 1, 1.5 }

    self.launch_item_range = 2.5
    self.launch_item_speed = 2

    self.use_default_fx = true

    self.onstartfn = nil
    self.onstopfn = nil
    self.oncastfn = nil
end)

----------------------------------------------------------------------------
function GaleHelmsplitter:GetForwardOffset()
    return self.forward_offset
end

----------------------------------------------------------------------------
function GaleHelmsplitter:SetForwardOffset(forward_offset)
    self.forward_offset = forward_offset
end

function GaleHelmsplitter:SetAttackRange(attack_range)
    self.attack_range = attack_range
end

function GaleHelmsplitter:SetAttackMults(m1, m2)
    if m1 ~= nil and m2 ~= nil then
        self.instant_mults = { m1, m2 }
    elseif m1 ~= nil then
        self.instant_mults = { m1, m1 }
    end
end

function GaleHelmsplitter:SetLaunchItemParam(v1, v2)
    self.launch_item_range = v1 or 0
    self.launch_item_speed = v2 or 0
end

function GaleHelmsplitter:EnableDefaultFX(enable)
    self.use_default_fx = enable
end

----------------------------------------------------------------------------
function GaleHelmsplitter:StartHelmSplitting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstartfn and self.onstartfn(self.inst, owner)
end

function GaleHelmsplitter:StopHelmSplitting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstopfn and self.onstopfn(self.inst, owner)
end

function GaleHelmsplitter:GetHitPos(doer)
    local face_vec = GaleCommon.GetFaceVector(doer)
    local hit_pos = face_vec * self.forward_offset + doer:GetPosition()

    return hit_pos
end

function GaleHelmsplitter:SpawnDefaultFX(pos)
    SpawnAt("gale_leap_puff_fx", pos)

    local ring = SpawnAt("gale_ring_fx", pos)
    ring.AnimState:SetDeltaTimeMultiplier(0.95)
    ring.AnimState:SetTime(8 * FRAMES)
    ring.AnimState:SetMultColour(123 / 255, 245 / 255, 247 / 255, 1)
    ring.Transform:SetScale(0.61, 0.61, 0.61)
    ring:SpawnChild("gale_atk_leap_vfx")
end

function GaleHelmsplitter:DoHelmSplit(doer, target)
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

    if self.launch_item_range > 0 and self.launch_item_speed ~= 0 then
        GaleCommon.AoeLaunchItems(hit_pos, self.launch_item_range, self.launch_item_speed)
    end

    if self.use_default_fx then
        self:SpawnDefaultFX(hit_pos)
    end

    ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, hit_pos, 20)

    if self.oncastfn == nil or self.oncastfn(self.inst, doer, target) then
        return true
    end
end

return GaleHelmsplitter
