require "behaviours/follow"
require "behaviours/wander"

local TyphonWeaverBrain  = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING      = { minwaittime = 3, randwaittime = 1 }
local RUN_AWAY_DIST      = 8
local STOP_RUN_AWAY_DIST = 16

local function CanFightFn(inst)
    local target = inst.components.combat.target
    return target and target:IsValid()
end

local function CanCastRecoverShield(inst)
    if not inst.components.gale_magic:CanUseMagic(1) then
        return false
    end

    return not inst.sg:HasStateTag("busy")
        and (inst.last_recover_shield_time == nil or GetTime() - inst.last_recover_shield_time > 33)
        and inst.shield_amout <= 100
end

local function CastRecoverShield(inst)
    inst.last_recover_shield_time = GetTime()
    inst.sg:GoToState("recover_shield", inst.components.combat.target)
end

local function CreatePhantomAction(inst)
    if inst.components.timer:TimerExists("create_phantom_cd")
        or (inst.components.combat:HasTarget() and inst:IsNear(inst.components.combat.target, 8))
    then
        return
    end

    if not inst.components.gale_magic:CanUseMagic(1) then
        return
    end

    if not (inst.create_phantom_target and inst.create_phantom_target:IsValid()) then
        local inst_pos = inst:GetPosition()
        inst.create_phantom_target = FindEntity(inst, 15, function(guy)
                                                    if guy.prefab ~= "skeleton" and guy.prefab ~= "skeleton_player" then
                                                        return false
                                                    end

                                                    local dest_pt = guy:GetPosition()

                                                    return TheWorld.Map:IsPassableAtPoint(dest_pt.x, dest_pt.y, dest_pt
                                                            .z)
                                                        and TheWorld.Pathfinder:IsClear(inst_pos.x, inst_pos.y,
                                                                                        inst_pos.z, dest_pt.x, dest_pt.y,
                                                                                        dest_pt.z)
                                                end, nil, { "INLIMBO" })
    end

    if inst.create_phantom_target == nil then
        return
    end

    -- inst.components.named:SetName(

    return BufferedAction(inst, inst.create_phantom_target, ACTIONS.TYPHON_WEAVER_CREATE_PHANTOM)
end

function TyphonWeaverBrain:OnStart()
    local root = PriorityNode({
                                  --   WhileNode(function() return CanFightFn(self.inst) end, "CanFight",
                                  --             ChaseAndAttack(self.inst, 8)),
                                  --   Follow(self.inst, function() return self.inst.components.follower.leader end,
                                  --          1, 5, 8, true),

                                  DoAction(self.inst, CreatePhantomAction, "create_phantom", true, 9),
                                  IfNode(function()
                                             return CanCastRecoverShield(self.inst)
                                         end, "CastRecoverShield",
                                         ActionNode(function()
                                             CastRecoverShield(self.inst)
                                         end)
                                  ),
                                  WhileNode(function()
                                                if self.inst.components.combat.target == nil then
                                                    return false
                                                end

                                                if not self.inst.components.combat:InCooldown() then
                                                    return true
                                                end
                                            end, "ShouldFight",
                                            ChaseAndAttack(self.inst, 30)),
                                  WhileNode(function()
                                                return self.inst.components.combat.target and
                                                    self.inst.components.combat:InCooldown()
                                            end, "ShouldAvoidFight",
                                            RunAway(self.inst, function() return self.inst.components.combat.target end,
                                                    RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
                                  ),
                                  --   ChaseAndAttackAndAvoid(self.inst, function()
                                  --                              return self.inst.components.combat:InCooldown() and
                                  --                              self.inst.components.combat.target
                                  --                          end,
                                  --                          STOP_RUN_AWAY_DIST),
                                  Wander(self.inst, nil, nil, WANDER_TIMING),
                              }, 1)

    self.bt = BT(self.inst, root)
end

return TyphonWeaverBrain
