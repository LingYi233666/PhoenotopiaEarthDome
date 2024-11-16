local GaleCondition = require("util/gale_conditions")


local AthetosBerserkerEnchant = Class(function(self, inst)
    self.inst = inst

    self.target = nil

    self.charge_hitother = function()
        return math.random(7, 13)
    end

    self.val = 0
    self.max = 100
    self.power_increased = 0
    self.power_increased_max = 10
end)

-- Leave this for modders
function AthetosBerserkerEnchant:SetChargeFn(fn)
    self.charge_hitother = fn
end

function AthetosBerserkerEnchant:DoDelta(delta)
    self.val = math.max(0, self.val + delta)
    if self.val >= self.max then
        if self.target and self.target:IsValid() then
            self:AddEnchant(1)
        end
        self.val = 0
    end
end

function AthetosBerserkerEnchant:AddEnchant(stacks)
    stacks = math.min(stacks or 1, self.power_increased_max - self.power_increased)
    if stacks > 0 and self.target and self.target:IsValid() then
        GaleCondition.AddCondition(self.target, "condition_power", stacks)
        self.power_increased = self.power_increased + stacks
    end
end

function AthetosBerserkerEnchant:RemoveEnchant(stacks)
    stacks = math.min(stacks or 1, self.power_increased)
    if stacks > 0 and self.target and self.target:IsValid() then
        GaleCondition.RemoveCondition(self.target, "condition_power", stacks)
        self.power_increased = self.power_increased - stacks
    end
end

function AthetosBerserkerEnchant:SetTarget(target)
    if self.target then
        self:DropTarget()
    end

    if not target then
        return
    end

    self.target = target

    self._on_hit_other = function(_, data)
        self:DoDelta(FunctionOrValue(self.charge_hitother, self.inst, self.target, data))
    end

    self._on_exit_battle = function(_, data)
        if data.state == "over" then
            self:RemoveEnchant(self.power_increased)
            self:DoDelta(-self.max)
        end
    end

    self.inst:ListenForEvent("onhitother", self._on_hit_other, self.target)
    self.inst:ListenForEvent("battlestate_change", self._on_exit_battle, self.target)
end

function AthetosBerserkerEnchant:DropTarget()
    if not self.target then
        return
    end

    self.inst:RemoveEventCallback("onhitother", self._on_hit_other, self.target)
    self.inst:RemoveEventCallback("battlestate_change", self._on_exit_battle, self.target)

    self:RemoveEnchant(self.power_increased)
    self:DoDelta(-self.max)

    self.target = nil
end

function AthetosBerserkerEnchant:GetDebugString()
    return string.format("Target: %s, progress: %d / %d, power: %d / %d",
        tostring(self.target), self.val, self.max, self.power_increased, self.power_increased_max)
end

return AthetosBerserkerEnchant
