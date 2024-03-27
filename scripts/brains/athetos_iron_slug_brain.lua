require "behaviours/wander"

local SlugBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = {
    minwalktime = 6,
    randwalktime = 2,
    minwaittime = 8,
    randwaittime = 3,
}


function SlugBrain:OnStart()
    local root = PriorityNode({
                                  Wander(self.inst, nil, nil, WANDER_TIMING),
                              }, 1)

    self.bt = BT(self.inst, root)
end

return SlugBrain
