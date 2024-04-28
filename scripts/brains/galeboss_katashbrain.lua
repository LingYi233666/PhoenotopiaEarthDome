require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"

local BrainCommon = require "brains/braincommon"


local MAX_CHASE_TIME       = 30
local MAX_CHASE_DIST       = 50
local RUN_AWAY_DIST        = 15
local STOP_RUN_AWAY_DIST   = 20

local WANDER_MAX_DIST      = 15

local BIGBALL_CD           = 20
local SPINATTACK_CD        = 20
local DASHATTACK_DELAY     = 1
local DASHATTACK_CD        = 20
local DASHATTACK_LOW_HP_CD = 10
local THROW_CD             = 1
local ROLLING_CD           = 20 --20

local THROW_MIN_DIST_SQ    = 8 * 8
local THROW_MAX_DIST_SQ    = 20 * 20

local ROLLING_MAX_DIST_SQ  = 20 * 20


local DASH_HP_THRES = 0.33
local ROLLING_HP_THRES = 0.5 --0.5



local KatashBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


local function ShouldFight(inst)
    return not inst.components.combat:InCooldown() and inst.components.combat.target
end

local function ShouldAvoidFight(inst)
    return
        inst.components.combat:InCooldown()
    -- and inst.components.timer:TimerExists("big_ball")
    -- and inst.components.timer:TimerExists("spin_attack")
    -- and inst.components.timer:TimerExists("dash_attack")
end

local function CanCastBigBall(inst)
    local target = inst.components.combat.target
    if not target
        or inst:GetTimeAlive() < 5
        or IsEntityDead(inst)
        or inst.sg:HasStateTag("busy")
        or inst.components.timer:TimerExists("big_ball") then
        return
    end

    return inst:IsNear(target, 15)
end

local function CastBigBall(inst)
    inst.components.timer:StartTimer("big_ball", BIGBALL_CD)
    inst.sg:GoToState("attack_bigball", {
        count = 4,
        target = inst.components.combat.target,
        lock = true,
    })
end


local function CanCastSpinAttack(inst)
    local target = inst.components.combat.target
    if not target
        or inst:GetTimeAlive() < 5
        or IsEntityDead(inst)
        or inst.sg:HasStateTag("busy")
        or inst.components.timer:TimerExists("spin_attack") then
        return
    end

    return inst:IsNear(target, 15)
end

local function CastSpinAttack(inst)
    inst.components.timer:StartTimer("spin_attack", SPINATTACK_CD)
    inst.sg:GoToState("attack_spin", {
        targetpos = inst.components.combat.target:GetPosition()
    })
end

local function CanCastDash(inst)
    local target = inst.components.combat.target
    if not target
        or not inst:IsNear(target, 15)
        or inst:GetTimeAlive() < 5
        or IsEntityDead(inst)
        or inst.components.timer:TimerExists("dash_attack") then
        return
    end

    if inst.components.health:GetPercent() > DASH_HP_THRES then
        return not inst.sg:HasStateTag("busy")
    else
        return (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("canchangetodash")) and
            (target.sg and (target.sg.currentstate.name == "eat" or target.sg.currentstate.name == "quickeat"))
    end
end

local function CastDash(inst)
    -- local target = inst.components.combat.target
    -- local mypos = inst:GetPosition()
    -- local distsq_thres = 8 * 8
    -- local offset = FindWalkableOffset(target:GetPosition(),math.random() * TWOPI,7,25,nil,false,function(pp)
    --     return (pp - mypos):LengthSq() >= distsq_thres
    -- end,false,true)

    -- if offset == nil then
    --     inst.components.timer:StartTimer("dash_attack",DASHATTACK_DELAY)
    --     return
    -- end

    -- local start_pos = target:GetPosition() + offset
    -- local final_pos = target:GetPosition() - offset

    local target = inst.components.combat.target
    local start_pos, final_pos = inst:GenerateDashPosList(target)
    if start_pos == nil or final_pos == nil then
        inst.components.timer:StartTimer("dash_attack", DASHATTACK_DELAY)
        return
    end
    if inst.components.health:GetPercent() > DASH_HP_THRES then
        inst.components.timer:StartTimer("dash_attack", DASHATTACK_CD)
    else
        inst.components.timer:StartTimer("dash_attack", DASHATTACK_LOW_HP_CD)

        if (target.sg and (target.sg.currentstate.name == "eat" or target.sg.currentstate.name == "quickeat")) then
            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.PLAYER_HEAL))
            inst.SoundEmitter:PlaySound(inst.sounds.eat_good)
        end
    end



    inst.sg:GoToState("attack_dash_pre", {
        start_pos = start_pos,
        target_pos = final_pos,
        count = 3,
    })
end

local function CanCastThrow(inst)
    local target = inst.components.combat.target
    if not target
        or IsEntityDead(inst)
        or inst.sg:HasStateTag("busy")
        or inst.components.timer:TimerExists("throw_attack") then
        return
    end

    local dist_sq = inst:GetDistanceSqToInst(target)

    return dist_sq >= THROW_MIN_DIST_SQ and dist_sq <= THROW_MAX_DIST_SQ
end

local function CastThrow(inst)
    inst.components.timer:StartTimer("throw_attack", THROW_CD)
    inst.sg:GoToState("attack_throw", {
        target_pos = inst.components.combat.target:GetPosition(),
    })
end


local function CanCastRolling(inst)
    local target = inst.components.combat.target
    if not target
        or IsEntityDead(inst)
        or inst.sg:HasStateTag("busy")
        or inst.components.timer:TimerExists("rolling_attack")
        or inst.components.health:GetPercent() > ROLLING_HP_THRES then
        return
    end

    local dist_sq = inst:GetDistanceSqToInst(target)

    return dist_sq <= ROLLING_MAX_DIST_SQ
end

local function CastRolling(inst)
    inst.components.timer:StartTimer("rolling_attack", ROLLING_CD)
    inst.sg:GoToState("lightning_roll_pre", {
        target = inst.components.combat.target,
    })
end

local function GetHomeLocation(inst)
    return inst.components.knownlocations:GetLocation("base")
end


function KatashBrain:OnStart()
    local root = PriorityNode({
                                  IfNode(function()
                                             return CanCastRolling(self.inst)
                                         end, "CastRolling",
                                         ActionNode(function()
                                             CastRolling(self.inst)
                                         end)
                                  ),

                                  IfNode(function()
                                             return CanCastSpinAttack(self.inst)
                                         end, "CastSpinAttack",
                                         ActionNode(function()
                                             CastSpinAttack(self.inst)
                                         end)
                                  ),

                                  IfNode(function()
                                             return CanCastBigBall(self.inst)
                                         end, "CastBigBall",
                                         ActionNode(function()
                                             CastBigBall(self.inst)
                                         end)
                                  ),

                                  IfNode(function()
                                             return CanCastDash(self.inst)
                                         end, "CastDash",
                                         ActionNode(function()
                                             CastDash(self.inst)
                                         end)
                                  ),


                                  IfNode(function()
                                             return CanCastThrow(self.inst)
                                         end, "CastThrow",
                                         ActionNode(function()
                                             CastThrow(self.inst)
                                         end)
                                  ),

                                  WhileNode(function()
                                                return ShouldFight(self.inst)
                                            end, "ShouldFight",
                                            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)
                                  ),

                                  WhileNode(function() return ShouldAvoidFight(self.inst) end, "ShouldAvoidFight",
                                            RunAway(self.inst, function() return self.inst.components.combat.target end,
                                                    RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

                                  IfNode(function()
                                             return self.inst.components.combat.target == nil
                                         end, "Wander",
                                         Wander(self.inst, GetHomeLocation, WANDER_MAX_DIST)
                                  ),

                              }, .25)

    self.bt = BT(self.inst, root)
end

return KatashBrain
