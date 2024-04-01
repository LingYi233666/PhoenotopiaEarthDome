require "behaviours/wander"
require "behaviours/leash"

local SlugBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = {
    minwalktime = 6,
    randwalktime = 2,
    minwaittime = 8,
    randwaittime = 3,
}

local function FindFarmPoint(inst)
    local cands = inst:FindFarmPoints()
    return cands[1]
end

function SlugBrain:OnStart()
    local root = PriorityNode({
                                  Leash(self.inst, FindFarmPoint, 2, 1, false),
                                  Wander(self.inst, nil, nil, WANDER_TIMING),
                              }, 1)

    self.bt = BT(self.inst, root)
end

return SlugBrain
