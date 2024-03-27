require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/doaction"
require "behaviours/chaseandattackandavoid"

local MAX_WANDER_DIST = 12
local AVOID_BATTLE_DIST = 8

local ErrorbotBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function DoTeleport(inst,data)
    if inst.components.combat.target then 
        inst.sg:GoToState("teleport",data)
    end
end

local function AvoidObjectFn(inst)
    return inst.components.combat.target
end

local function IsSkillCdDone(inst,timer_name,cd)
    cd = cd or 6
    return (inst[timer_name] == nil or GetTime() - inst[timer_name] > cd)
end

local function CanUseSmallBall(inst)
    return inst.components.combat.target 
    and not inst.sg:HasStateTag("attack") 
    and not inst.sg:HasStateTag("teleport") 
    and (inst.CurrentUseSkill == nil or inst.CurrentUseSkill == "ball") 
    and IsSkillCdDone(inst,"LastUseSmallBallTime")
end

local function UseSmallBall(inst,data)
    if inst.components.combat.target then 
        inst.BallCount = 1
        inst.sg:GoToState("ball_charge",data)
        inst.LastUseSmallBallTime = GetTime()
    end 
end

local function CanUseLeapAtk(inst)
    return inst.components.combat.target 
    and not inst.sg:HasStateTag("attack") 
    and not inst.sg:HasStateTag("teleport") 
    and (inst.CurrentUseSkill == nil or inst.CurrentUseSkill == "leap") 
    and IsSkillCdDone(inst,"LastUseLeapAtkTime")
    -- and not IsSkillCdDone(inst,"LastUseSmallBallTime")
end

-- 

local function UseLeapAtk(inst)
    if inst.components.combat.target then 
        inst.sg:GoToState("attack_leap",{time = 0.4})
        inst.LastUseLeapAtkTime = GetTime()
    end 
end

local function CanUseFlyAtk(inst)
    return inst.components.combat.target 
    and not inst.sg:HasStateTag("attack") 
    and not inst.sg:HasStateTag("teleport") 
    and (inst.CurrentUseSkill == nil or inst.CurrentUseSkill == "fly") 
    and IsSkillCdDone(inst,"LastUseFlyAtkTime")
end

local function UseFlyAtk(inst)
    if inst.components.combat.target then 
        inst.sg:GoToState("attack_flying",{target = inst.components.combat.target,time = 5,height = 5})
        inst.LastUseFlyAtkTime = GetTime()
    end 
end

local function ClearCurrentUseSkill(inst)
    inst.CurrentUseSkill = nil 
end

local function PickSkill(inst)
    if inst.CurrentUseSkill == nil then 
        if CanUseSmallBall(inst) then 
            inst.CurrentUseSkill = "ball"
        elseif CanUseLeapAtk(inst) then 
            inst.CurrentUseSkill = "leap"
        elseif CanUseFlyAtk(inst) then 
            inst.CurrentUseSkill = "fly"
        end
    end

    -- print("Picking skill....",inst.CurrentUseSkill)
end

function ErrorbotBrain:OnStart()
    --print(self.inst, "InfectedBrain:OnStart")
    local root = PriorityNode(
    {

        FailIfSuccessDecorator(
            IfNode(function() 
                return self.inst.CurrentUseSkill == nil 
            end, "PickingSkill",
                ActionNode(function()
                    PickSkill(self.inst)
                end)
            )
        ),


		IfNode(function() 
            return self.inst.CurrentUseSkill == "ball"
        end, "CanUseSmallBall",
            SequenceNode{
                ActionNode(function() 
                    DoTeleport(self.inst,{
                        attacker = self.inst.components.combat.target,
                        telerad = 12,
                        start_angle = GetRandomMinMax(0,2 * PI)}
                    ) 
                end),
                WaitNode(0.4),
                ActionNode(function() 
                    UseSmallBall(self.inst,{time = 0.8}) 
                end),
                WaitNode(1.5),
                ActionNode(function() 
                    UseSmallBall(self.inst,{time = 0.8}) 
                end),
                WaitNode(1.5),
                ActionNode(function() 
                    UseSmallBall(self.inst,{time = 0.8}) 
                end),
                WaitNode(1.33),
                ActionNode(function()
                    ClearCurrentUseSkill(self.inst)
                end)
            }
        ),

        IfNode(function() 
            return self.inst.CurrentUseSkill == "leap"
        end, "CanUseLeapAtk",
            SequenceNode{
                ActionNode(function() 
                    DoTeleport(self.inst,{
                        attacker = self.inst.components.combat.target,
                        telerad = 12,
                        start_angle = GetRandomMinMax(0,2 * PI)}
                    ) 
                end),
                WaitNode(0.5),
                ActionNode(function() 
                    DoTeleport(self.inst,{
                        attacker = self.inst.components.combat.target,
                        telerad = 8,
                        start_angle = GetRandomMinMax(0,2 * PI)}
                    ) 
                end),
                WaitNode(0.4),
                ActionNode(function() 
                    DoTeleport(self.inst,{
                        attacker = self.inst.components.combat.target,
                        telerad = 4,
                        start_angle = GetRandomMinMax(0,2 * PI)}
                    ) 
                end),
                WaitNode(0.3),
                ActionNode(function() UseLeapAtk(self.inst) end),
                WaitNode(0.4),
                ActionNode(function() ClearCurrentUseSkill(self.inst) end),
            }
        ),

        IfNode(function() 
            return self.inst.CurrentUseSkill == "fly"
        end, "CanUseFlyAtk",
            SequenceNode{
                ActionNode(function() 
                    DoTeleport(self.inst,{
                        attacker = self.inst.components.combat.target,
                        telerad = 12,
                        start_angle = GetRandomMinMax(0,2 * PI)}
                    ) 
                end),
                WaitNode(0.6),
                ActionNode(function() 
                    UseFlyAtk(self.inst)
                end),
                WaitNode(7.25),
                ActionNode(function() ClearCurrentUseSkill(self.inst) end),
            }
        ),

        ChaseAndAttackAndAvoid(self.inst, AvoidObjectFn, AVOID_BATTLE_DIST),
        Wander(self.inst, function() return  end, MAX_WANDER_DIST),
        
    }, .33)

    self.bt = BT(self.inst, root)
end

return ErrorbotBrain