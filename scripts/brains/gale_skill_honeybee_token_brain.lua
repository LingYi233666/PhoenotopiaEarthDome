require "behaviours/follow"
require "behaviours/wander"

local HoneyBeeTokenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}

local function CanFightFn(inst)
    local target = inst.components.combat.target
    return target and target:IsValid()
end


function HoneyBeeTokenBrain:OnStart()
    local root = PriorityNode({
        WhileNode(function() return CanFightFn(self.inst) end, "CanFight",
            ChaseAndAttack(self.inst, 8)),

        Follow(self.inst, function() return self.inst.components.follower.leader end,
            1, 5, 8, true),
        Wander(self.inst, nil, nil, WANDER_TIMING),
    }, .25)

    self.bt = BT(self.inst, root)
end

return HoneyBeeTokenBrain
