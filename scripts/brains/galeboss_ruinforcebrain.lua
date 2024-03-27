require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "giantutils"
require "vecutil"

local SEE_DIST = 40

local CHASE_DIST = 32
local CHASE_TIME = 20

local OUTSIDE_CATAPULT_RANGE = TUNING.WINONA_CATAPULT_MAX_RANGE + TUNING.WINONA_CATAPULT_KEEP_TARGET_BUFFER + TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 1
local function OceanChaseWaryDistance(inst, target)
    -- We already know the target is on water. We'll approach if our attack can reach, but stay away otherwise.
    return (CanProbablyReachTargetFromShore(inst, target, TUNING.DEERCLOPS_ATTACK_RANGE - 0.25) and 0) or OUTSIDE_CATAPULT_RANGE
end

local function CanCastLaser(inst)
    if inst.phase < 2 or IsEntityDeadOrGhost(inst,true) or inst.sg:HasStateTag("busy") then
        return 
    end

    local target = inst.components.combat.target 
    
    if not target or inst.sg:HasStateTag("busy") then
        return false
    end

    local range = (inst:GetPosition() - target:GetPosition()):Length()

    return range >= 12
        and GetTime() - inst.LastLaserTime >= 6
end

local function CastLaser(inst)
    local target = inst.components.combat.target 
    
    if not target then
        return
    end

    inst.LastLaserTime = GetTime()
    inst.sg:GoToState("attack_laser")
end

local function CanCastSuperJump(inst)
    if inst.phase < 2 or IsEntityDeadOrGhost(inst,true) or inst.sg:HasStateTag("busy") then
        return 
    end
    
    local target = inst.components.combat.target 
    
    if not target or inst.sg:HasStateTag("busy") then
        return false
    end

    local range = (inst:GetPosition() - target:GetPosition()):Length()

    return range >= 16
        and GetTime() - inst.LastSuperJumpTime >= 12
end

local function CastSuperJump(inst)
    local target = inst.components.combat.target 
    
    if not target then
        return
    end

    inst.LastSuperJumpTime = GetTime()
    inst.sg:GoToState("superjump")
end

local function CanCastRoar(inst)
    if IsEntityDeadOrGhost(inst,true) or inst.sg:HasStateTag("busy") then
        return 
    end

    local target = inst.components.combat.target 
    
    if not (target and target:IsNear(inst,25)) then
        return
    end

    return inst.damage_taken_before_roar >= 666 and GetTime() - inst.components.combat:GetLastAttackedTime() <= 10
end

local function CastRoar(inst)
    local target = inst.components.combat.target 
    
    if not target then
        return
    end

    inst.damage_taken_before_roar = 0
    inst.sg:GoToState("roar")
end



local RuinforceBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function RuinforceBrain:OnStart()
    local root =
        PriorityNode(
        {
            IfNode(function() 
                return CanCastRoar(self.inst)
            end, "CanCastRoar",
                ActionNode(function() 
                    CastRoar(self.inst)
                end)
            ),

            IfNode(function() 
                return CanCastLaser(self.inst)
            end, "CanCastLaser",
                ActionNode(function() 
                    CastLaser(self.inst)
                end)
            ),

            IfNode(function() 
                return CanCastSuperJump(self.inst)
            end, "CanCastSuperJump",
                ActionNode(function() 
                    CastSuperJump(self.inst)
                end)
            ),

            AttackWall(self.inst),
            ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST, nil, nil, nil, OceanChaseWaryDistance),
            -- DoAction(self.inst, BaseDestroy, "DestroyBase", true),
            -- WhileNode(function() return self.inst:WantsToLeave() end, "Trying To Leave",
            --     Wander(self.inst, GetHomePos, 30)),

            Wander(self.inst),
        },1)

    self.bt = BT(self.inst, root)
end

return RuinforceBrain
