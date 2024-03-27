require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"

local GaleCommon         = require("util/gale_common")

-- local MAX_CHASE_TIME      = 30
-- local MAX_CHASE_DIST      = 50
local RUN_AWAY_DIST      = 4
local STOP_RUN_AWAY_DIST = 8

-- local WANDER_MAX_DIST = 15
-- local WANDER_TIMING = {minwaittime = 1, randwaittime = 10}


local TyphonMimicBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function CanCastLeapAttack(inst)
    return not inst.sg:HasStateTag("busy")
        and (inst.last_leap_time == nil or GetTime() - inst.last_leap_time > 9)
        and inst.components.combat.target
        -- and not inst:IsNear(inst.components.combat.target,4)
        and inst:IsNear(inst.components.combat.target, 15)
end

local function CastLeapAttack(inst)
    inst.last_leap_time = GetTime()
    inst.sg:GoToState("attack_leap", inst.components.combat.target)
end

local function CanCastMimic(inst)
    if not inst.sg:HasStateTag("busy")
        and inst:GetBufferedAction() == nil
        and (inst.last_try_mimic_time == nil or GetTime() - inst.last_try_mimic_time > 3)
        and not IsEntityDead(inst, true)
        and inst.components.hunger:GetPercent() < 0.9
        and inst.components.gale_magic:CanUseMagic(33)
        and (inst.components.combat.target == nil or not inst:IsNear(inst.components.combat.target, 15)) then
        local mimic_target = FindEntity(inst, 8, function(guy)
                                            return inst:CanMimic(guy)
                                        end, nil, { "INLIMBO" })


        if not mimic_target then
            local x, y, z = inst:GetPosition():Get()
            for _, container in pairs(TheSim:FindEntities(x, y, z, 6, nil, { "INLIMBO" })) do
                if container.components.container then
                    local cands = container.components.container:FindItems(function(item)
                        return inst:CanMimic(item)
                    end)
                    mimic_target = GetRandomItem(cands)
                end

                if mimic_target then
                    break
                end
            end
        end

        inst.mimic_target = mimic_target
        inst.last_try_mimic_time = GetTime()

        return inst.mimic_target ~= nil
    end

    return false
end

local function CastMimic(inst)
    if inst.mimic_target and inst.mimic_target:IsValid() and inst:IsNear(inst.mimic_target, 8) then
        inst.sg:GoToState("gale_mimicing", { target = inst.mimic_target })
    end
end

local function PickupFoodAction(inst)
    if inst.components.inventory:GetItemInSlot(1) or inst.components.hunger:GetPercent() > 0.95 then
        return nil
    end

    local x, y, z = inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 10, { "_inventoryitem" }, { "INLIMBO" })
    -- local cand_foods = {}
    local cand = nil

    for _, v in pairs(ents) do
        if v:IsOnPassablePoint()
            and (inst.components.eater:CanEat(v)
                or (
                    v.components.fuel and v.components.fuel.fueltype == FUELTYPE.NIGHTMARE
                )) then
            -- table.insert(cand_foods,v)
            cand = v
            break
        end
    end

    -- local result = cand ~= nil and BufferedAction(inst, cand, ACTIONS.PICKUP) or nil
    -- if result and inst.sg:HasStateTag("mimicing") then
    --     inst.components.gale_skill_mimic:StopWithSG()
    -- end

    if cand then
        local buffered_action = BufferedAction(inst, cand, ACTIONS.PICKUP)
        local old_validfn = buffered_action.validfn
        buffered_action.validfn = function(...)
            return (old_validfn == nil or old_validfn(...)) and not inst:IsBlockedOnPath()
        end

        return buffered_action
    end
end

local function DestroyObstacleAction(inst)
    local rot = inst.Transform:GetRotation()
    local target = FindEntity(inst, 1.5 + inst:GetPhysicsRadius(0),
                              function(guy)
                                  return
                                      guy:GetPhysicsRadius(0) > 0.1
                                      and math.abs(anglediff(rot,
                                                             inst:GetAngleToPoint(guy.Transform:GetWorldPosition()))) <
                                      30
                                      and (
                                          inst:CanTarget(guy)
                                          or (
                                              guy.components.workable
                                              and guy.components.workable:CanBeWorked()
                                              and guy.components.workable:GetWorkAction() == ACTIONS.HAMMER
                                          )
                                      )
                              end,
                              nil,
                              { "INLIMBO" },
                              { "HAMMER_workable", "_combat" }
    )

    if target then
        if inst:CanTarget(target) then
            inst.components.combat:TryAttack(target)
        elseif target.components.workable
            and target.components.workable:CanBeWorked()
            and target.components.workable:GetWorkAction() == ACTIONS.HAMMER then
            local buffered_action = BufferedAction(inst, target, ACTIONS.HAMMER)
            buffered_action.distance = math.max(inst.components.combat:GetHitRange(), buffered_action.distance or 0)

            return buffered_action
        end
    end
end

-- local function ConsumeItemAction(inst)
--     local item = inst.components.inventory:GetItemInSlot(1)
--     if item then
--         inst.sg:GoToState("")
--     end
-- end

local function MoveAwayFromTargetWrapper(inst)
    return function(pt)
        local old_dist = (inst:GetPosition() - inst.components.combat.target:GetPosition())
            :Length()
        local new_dist = (pt - inst.components.combat.target:GetPosition()):Length()
        return new_dist >= 8 or (new_dist > 4 and new_dist >= old_dist) or
            (new_dist >= old_dist)
    end
end

function TyphonMimicBrain:OnStart()
    local combat_node = PriorityNode({
        DoAction(self.inst, function() return DestroyObstacleAction(self.inst) end),

        IfNode(function()
                   return CanCastLeapAttack(self.inst)
               end, "LeapAttack",
               ActionNode(function()
                   CastLeapAttack(self.inst)
               end)
        ),

        -- AttackWall(self.inst),

        WhileNode(function()
                      if self.inst.components.combat.target == nil then
                          return true
                      end

                      if self.inst:IsBlockedOnPath() then
                          return false
                      end

                      if not self.inst.components.combat:InCooldown() then
                          return true
                      end
                  end, "ShouldFight",
                  ChaseAndAttack(self.inst, 60)),

        WhileNode(function()
                      return self.inst.components.combat.target and self.inst.components.combat:InCooldown()
                  end, "ShouldAvoidFight",
                  PriorityNode {
                      -- RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
                      Wander(self.inst,
                             function() return (self.inst.components.combat.target or self.inst):GetPosition() end,
                             10,
                             { minwaittime = 0.2, randwaittime = 0.05 },

                             function(inst)
                                 -- get direction
                                 local inst_pos = inst:GetPosition()
                                 local valid_pt_fn = MoveAwayFromTargetWrapper(inst)
                                 local away_offset = FindWalkableOffset(inst_pos, math.random() * TWOPI * 2, 3, 30, true,
                                                                        false, valid_pt_fn)
                                 if away_offset then
                                     return inst:GetAngleToPoint(inst:GetPosition() + away_offset) * DEGREES
                                 end

                                 away_offset = FindWalkableOffset(inst_pos, math.random() * TWOPI * 2, 3, 30, true,
                                                                  false)

                                 if away_offset then
                                     return inst:GetAngleToPoint(inst:GetPosition() + away_offset) * DEGREES
                                 end

                                 return nil
                             end,
                             nil,
                             nil,
                             {
                                 wander_dist = function() return GetRandomMinMax(2, 3) end,
                                 offest_attempts = 30,
                                 should_run = true,
                             }
                      ),
                  }
        ),
    })

    local activity_node = PriorityNode({
        DoAction(self.inst, function() return PickupFoodAction(self.inst) end),
        -- DoAction(self.inst, function() return ConsumeItemAction(self.inst) end ),
    })


    local root = PriorityNode({
                                  IfNode(
                                      function()
                                          if self.inst.level >= 4
                                              and self.inst.components.combat.target == nil
                                              and not self.inst.sg:HasStateTag("busy") then
                                              local x, y, z = self.inst:GetPosition():Get()
                                              local mimic_nearvy_cnt = 0
                                              for _, v in pairs(TheSim:FindEntities(x, y, z, 15, { "typhon" }, {
                                                  "INLIMBO" })) do
                                                  if v ~= self.inst
                                                      and v.prefab == "typhon_mimic"
                                                      and not v.components.health:IsDead() then
                                                      mimic_nearvy_cnt = mimic_nearvy_cnt + 1
                                                  end
                                              end

                                              return mimic_nearvy_cnt >= 3
                                          end
                                      end, "WantToBecomeWeaver",
                                      ActionNode(function()
                                          self.inst.rankup_process = true
                                          self.inst.sg:GoToState("rankup")
                                      end)
                                  ),
                                  combat_node,
                                  activity_node,

                                  IfNode(function()
                                             return CanCastMimic(self.inst)
                                         end, "CastMimic",
                                         ActionNode(function()
                                             CastMimic(self.inst)
                                         end)
                                  ),


                                  IfNode(function()
                                             return not self.inst.sg:HasStateTag("mimicing")
                                         end, "Wander",
                                         Wander(self.inst)
                                  ),


                              }, .25)

    self.bt = BT(self.inst, root)
end

return TyphonMimicBrain
