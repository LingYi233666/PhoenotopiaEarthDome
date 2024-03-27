require "behaviours/follow"
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"

local TentacleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- local WANDER_TIMING = {minwaittime = 0.25, randwaittime = 0.1}
local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}

local function CanFightFn(inst)
    local target = inst.components.combat.target
    return target and target:IsValid()
end

local function CanCastDash(inst)
    if not inst.CanDash then
        return false
    end
    if not CanFightFn(inst) then
        return false
    end

    local leader = inst.components.follower:GetLeader()
    local pos = (leader or inst):GetPosition()
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z,12,{"galeboss_dragon_snare_token","tentacle"},{"INLIMBO"})
    local dash_cnt = 0

    for k,v in pairs(ents) do
        if v ~= inst 
            and (v.sg:HasStateTag("attack_dash") or v.sg:HasStateTag("attack_dash_prepare")) then
            dash_cnt = dash_cnt + 1
        end
    end

    return 
        not inst.sg:HasStateTag("busy")
        and dash_cnt == 0
        and (inst.LastCastDashTime == nil or GetTime() - inst.LastCastDashTime >= 10)
end

local function dash_data_fn(inst)
    local target = inst.components.combat.target
    return {
        face_pos = target and target:GetPosition(),
        stop_time = GetTime() + GetRandomMinMax(2,4),
        fx = true,
        start_pos = inst:GetPosition(),
        max_dist = 12,
    }
end

local function CastDash(inst)
    local target = inst.components.combat.target

    local offset = FindWalkableOffset(target:GetPosition(),
                                        GetRandomMinMax(0,2*PI),
                                        GetRandomMinMax(4,8),
                                        12,
                                        nil,
                                        false,
                                        nil,
                                        false,
                                        false
                                    ) or Vector3(0,0,0)

    

    inst.sg:GoToState("attack_dash_prepare",{
        prepare_pos = inst:GetPosition() + offset,
        prepare_time = GetRandomMinMax(2,3),
        dash_data_fn = dash_data_fn,
    })

    
    inst.LastCastDashTime = GetTime()
end

local hunterparams = {
    notags = { "NOCLICK" },
    fn = function(hunter, inst)
        return inst.components.combat.target and hunter == inst.components.combat.target
    end,
}
function TentacleBrain:OnStart()
    local ChaseAndAttackNode = WhileNode(
        function()  
            local leader = self.inst.components.follower:GetLeader()
            local pos = (leader or self.inst):GetPosition()
            local other_tentacles = TheSim:FindEntities(pos.x,pos.y,pos.z,10,{"_combat","_health","galeboss_dragon_snare_token","tentacle"})

            local attacking_cnt = 0
            for k,v in pairs(other_tentacles) do
                if v ~= self.inst and v.brain 
                    and v.brain.ChaseAndAttackNode 
                    and v.brain.ChaseAndAttackNode.status == RUNNING then
                    
                    attacking_cnt = attacking_cnt + 1
                end
            end

            return attacking_cnt == 0 and not self.inst.components.combat:InCooldown() 
        end, 
        "CanFight",
        ChaseAndAttack(self.inst, 12)
    )

    local BattleNode = WhileNode(function() 
        return CanFightFn(self.inst) 
    end, 
    "BattleNode",
    PriorityNode({
        IfNode(function() return CanCastDash(self.inst) end, "CanCastDash",
            ActionNode(function()
                CastDash(self.inst)
            end)),
        WhileNode(function() return self.inst.sg:HasStateTag("attack_dash") end,"Dashing",
            ActionNode(function()
                -- Brain should do nothing while dashing
            end)),
        ChaseAndAttackNode,
        RunAway(self.inst, hunterparams, 8, 12),
        -- Wander(self.inst, function ()
        --     return self.inst.components.combat.target and self.inst.components.combat.target:GetPosition()
        -- end, 6, WANDER_TIMING),
    }, .1))

    local root = PriorityNode({
        BattleNode,

        Follow(self.inst, function() return self.inst.components.follower.leader end,
            3, 8, 12, true),
        Wander(self.inst, nil, nil, WANDER_TIMING),
    }, .25)

    self.bt = BT(self.inst, root)
    self.ChaseAndAttackNode = ChaseAndAttackNode
end

return TentacleBrain
