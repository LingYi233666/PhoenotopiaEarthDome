require "behaviours/follow"
require "behaviours/wander"

local TyphonCystoidBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = { minwaittime = 3, randwaittime = 1 }

local function ApproachAndExplode(inst)
    if inst.manual_select_target and inst.manual_select_target:IsValid() then
        local buffered_action = BufferedAction(inst, inst.manual_select_target, ACTIONS.TYPHON_CYSTOID_ATTACK)
        buffered_action.distance = inst.components.combat:GetAttackRange()
        buffered_action.validfn = function()
            return inst.manual_select_target ~= nil
                and inst.manual_select_target:IsValid()
                and buffered_action.target == inst.manual_select_target
        end
        return buffered_action
    end
end

function TyphonCystoidBrain:OnStart()
    local root = PriorityNode({
                                  --   WhileNode(function() return CanFightFn(self.inst) end, "CanFight",
                                  --             ChaseAndAttack(self.inst, 8)),
                                  DoAction(self.inst, function() return ApproachAndExplode(self.inst) end,
                                           "ApproachAndExplode", true),
                                  Follow(self.inst, function() return self.inst.components.follower.leader end,
                                         1, 5, 8, true),
                                  Wander(self.inst, nil, nil, WANDER_TIMING),
                              }, .25)

    self.bt = BT(self.inst, root)
end

return TyphonCystoidBrain
