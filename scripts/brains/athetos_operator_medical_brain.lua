require "behaviours/follow"
require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
local BrainCommon = require("brains/braincommon")


local OperatorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = { minwaittime = 6, randwaittime = 3 }


function OperatorBrain:OnStart()
    local root = PriorityNode({
                                  BrainCommon.PanicTrigger(self.inst),
                                  WhileNode(function()
                                                local t = self.inst.components.combat:GetLastAttackedTime()

                                                return t > 1e-3 and GetTime() - t < 10
                                            end,
                                            "Runwaya",
                                            RunAway(self.inst, function(guy, inst)
                                                        local lastattacker = inst.components.combat.lastattacker
                                                        return lastattacker ~= nil
                                                            and lastattacker:IsValid()
                                                            and not lastattacker:HasTag("player")
                                                            and guy == lastattacker
                                                    end, 6, 12)),

                                  Wander(self.inst, nil, nil, WANDER_TIMING),
                              }, .25)

    self.bt = BT(self.inst, root)
end

return OperatorBrain
