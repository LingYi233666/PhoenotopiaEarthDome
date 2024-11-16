require "behaviours/follow"
require "behaviours/wander"

local GaleCommon = require("util/gale_common")

local TyphonPhantomBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local RESET_COMBAT_DELAY = 10

local MIN_STALKING_TIME = 5 --before triggering proximity attack
local MAX_STALKING_CHASE_TIME = 4

local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 13
local STALKING_MIN_DIST = 6

local KINETIC_BLAST_DIST_MIN = 6
local KINETIC_BLAST_DIST_MAX = 18

local DASH_FOE_MELLE_DIST_MIN = 4
local DASH_FOE_MELLE_DIST_MAX = 20

local WANDER_TIMING = { minwaittime = 6, randwaittime = 6 }


local function CanCastKineticBlast(inst, cooldown)
    local target = inst.components.combat.target
    if not target then
        return false
    end

    if not inst.components.gale_magic:CanUseMagic(1) then
        return false
    end

    local min_dist = (target:GetCurrentPlatform() ~= nil and inst:GetCurrentPlatform() ~= nil) and 0 or
        KINETIC_BLAST_DIST_MIN

    return not inst.sg:HasStateTag("busy")
        and (inst.last_kinetic_blast_time == nil or GetTime() - inst.last_kinetic_blast_time > cooldown)
        and not inst:IsNear(inst.components.combat.target, min_dist)
        and inst:IsNear(inst.components.combat.target, KINETIC_BLAST_DIST_MAX)
end

local function CastKineticBlast(inst)
    if inst.components.combat.target then
        inst.last_kinetic_blast_time = GetTime()
        inst.sg:GoToState("kinetic_blast", inst.components.combat.target:GetPosition())
    end
end

local function CanCastDashForMelle(inst)
    if not inst.components.gale_magic:CanUseMagic(1) then
        return false
    end

    local target = inst.components.combat.target
    return not inst.sg:HasStateTag("busy")
        and (inst.last_evade_time == nil or GetTime() - inst.last_evade_time > 1)
        and not (target and target:GetCurrentPlatform() ~= nil and inst:GetCurrentPlatform() ~= nil)
        and not inst.components.combat:InCooldown()
        and not inst:IsNear(inst.components.combat.target, DASH_FOE_MELLE_DIST_MIN)
        and inst:IsNear(inst.components.combat.target, DASH_FOE_MELLE_DIST_MAX)
end

local function CastDashForMelle(inst)
    if inst.components.combat.target then
        inst.last_evade_time = GetTime()

        local target_pos = inst.components.combat.target:GetPosition()
        local offset = FindWalkableOffset(target_pos,
            math.random() * PI * 2,
            inst.components.combat.target:GetPhysicsRadius(),
            10,
            nil, false, nil, false, true)
        local evade_pos = target_pos + (offset or Vector3(0, 0, 0))
        local speed = 25
        local timeout = (evade_pos - inst:GetPosition()):Length() / speed
        inst.sg:GoToState("evade", {
            target_pos = evade_pos,
            attack_target = inst.components.combat.target,
            timeout = timeout,
        })
    end
end

local function CastKineticBlastUpperbody(inst)
    if inst.components.combat.target then
        inst.last_kinetic_blast_time = GetTime()
        inst:EnableUpperBody(true)
        local upperbody = inst:GetUpperBody()
        upperbody.sg:GoToState("upperbody_kinetic_blast",
            inst.components.combat.target)
    end
end

local function IsStalkingFar(inst)
    local target = inst.components.combat.target
    return target ~= nil and not inst:IsNear(target, KINETIC_BLAST_DIST_MAX)
end

local function IsStalkingTooClose(inst)
    local target = inst.components.combat.target
    return target ~= nil and inst:IsNear(target, KINETIC_BLAST_DIST_MIN)
end

local function ShouldStalk(inst)
    return inst.components.combat:HasTarget()
        and inst.components.combat:InCooldown()
end

local function IsValidDestPt(inst, target, pt)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = target.Transform:GetWorldPosition()

    -- local target_dist = Vec3Util_Dist(x1, y1, z1, pt.x, pt.y, pt.z)
    return TheWorld.Map:IsPassableAtPoint(pt.x, pt.y, pt.z)
        and TheWorld.Pathfinder:IsClear(x, y, z, pt.x, pt.y, pt.z)
    -- and target_dist > KINETIC_BLAST_DIST_MIN
    -- and target_dist < KINETIC_BLAST_DIST_MAX
end

local function GetStalkingPos(inst)
    -- if CanCastKineticBlast(inst, 3) then
    --     return
    -- end

    local target = inst.components.combat.target

    if target == nil then
        return
    end

    if inst:GetCurrentPlatform() ~= nil or target:GetCurrentPlatform() ~= nil then
        return target:GetPosition()
    end

    -- From nightmare werepig
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = target.Transform:GetWorldPosition()
    local dx = x1 - x
    local dz = z1 - z
    local dist = math.sqrt(dx * dx + dz * dz)
    local strafe_angle = Remap(math.clamp(dist, 4, RUN_AWAY_DIST), 4, RUN_AWAY_DIST, 135, 75)
    local rot = inst.Transform:GetRotation()
    local rot1 = math.atan2(-dz, dx) * RADIANS
    local rota = rot1 - strafe_angle
    local rotb = rot1 + strafe_angle

    local rota_valid = IsValidDestPt(inst, target,
        Vector3(x + math.cos(rota) * 0.5, 0, z - math.sin(rota) * 0.5))
    local rotb_valid = IsValidDestPt(inst, target,
        Vector3(x + math.cos(rotb) * 0.5, 0, z - math.sin(rotb) * 0.5))

    if rota_valid and rotb_valid then
        if DiffAngle(rot, rota) < 30 then
            rot1 = rota
        elseif DiffAngle(rot, rotb) < 30 then
            rot1 = rotb
        else
            rot1 = math.random() < 0.5 and rota or rotb
        end
    elseif rota_valid then
        rot1 = rota
    elseif rotb_valid then
        rot1 = rotb
    else
        rot1 = math.random() < 0.5 and rota or rotb
    end

    rot1 = rot1 * DEGREES
    return Vector3(x + math.cos(rot1) * 10, 0, z - math.sin(rot1) * 10)

    -- local x, y, z = inst.Transform:GetWorldPosition()
    -- local face_vec = GaleCommon.GetFaceVector(inst)
    -- local result = Vector3(x, y, z) + face_vec * 0.5
    -- if IsValidDestPt(inst, target, result) then
    --     return result
    -- end


    -- local offset = FindWalkableOffset(Vector3(x, y, z),
    --                                   math.random() * PI * 2,
    --                                   0.5,
    --                                   33,
    --                                   nil,
    --                                   false,
    --                                   function(pt)
    --                                       return IsValidDestPt(inst, target, pt)
    --                                   end,
    --                                   false,
    --                                   true
    -- )

    -- if offset == nil then
    --     offset = Vector3(0, 0, 0)
    -- else
    --     offset = offset:GetNormalized() * 10
    -- end

    -- return Vector3(x, y, z) + offset
end


function TyphonPhantomBrain:OnStart()
    local root = PriorityNode({
        IfNode(function()
                return CanCastKineticBlast(self.inst, 8)
            end, "KineticBlast",
            ActionNode(function()
                CastKineticBlast(self.inst)
            end)
        ),
        Leash(self.inst, function()
            return not self.inst.components.combat:HasTarget() and
                self.inst.alert_target_pos
        end, 0, 0, false),

        WhileNode(function() return ShouldStalk(self.inst) end, "Stalking",
            ParallelNode {
                SequenceNode {
                    ParallelNodeAny {
                        WaitNode(MIN_STALKING_TIME),
                        ConditionWaitNode(function() return IsStalkingFar(self.inst) end),
                    },
                    ConditionWaitNode(function() return IsStalkingTooClose(self.inst) end),
                    ActionNode(function() self.inst.components.combat:ResetCooldown() end),
                },
                -- FailIfSuccessDecorator(ActionNode(function()
                --     local target = self.inst.components.combat.target
                --     if target and not self.inst.sg:HasStateTag("busy") then
                --         self.inst:EnableUpperBody(true)
                --         local upperbody = self.inst:GetUpperBody()
                --         upperbody:ForceFacePoint(target:GetPosition())
                --     end
                -- end)),
                FailIfSuccessDecorator(PriorityNode {
                    IfNode(function()
                            if self.inst.kinetic_blast_cooldown == nil then
                                self.inst.kinetic_blast_cooldown = GetRandomMinMax(2,
                                    3)
                            end
                            return CanCastKineticBlast(self.inst,
                                self.inst
                                .kinetic_blast_cooldown)
                        end, "KineticBlast",
                        ActionNode(function()
                            CastKineticBlastUpperbody(self.inst)
                            self.inst.kinetic_blast_cooldown = GetRandomMinMax(2, 3)
                        end)
                    ),
                    Leash(self.inst, GetStalkingPos, 0, 0, false),
                    -- Wander(self.inst, nil, nil, WANDER_TIMING),
                }),

            }),


        WhileNode(function()
                if self.inst.components.combat.target == nil then
                    return false
                end

                -- if self.inst:IsBlockedOnPath() then
                --     return false
                -- end

                if not self.inst.components.combat:InCooldown() then
                    return true
                end

                return false
            end, "ShouldFight",
            PriorityNode {
                IfNode(function()
                        return CanCastDashForMelle(self.inst)
                    end, "DashForMelle",
                    ActionNode(function()
                        CastDashForMelle(self.inst)
                    end)
                ),
                ChaseAndAttack(self.inst, 60)
            }
        ),
        Follow(self.inst, function() return self.inst.components.follower.leader end,
            1, 5, 8, true),
        Wander(self.inst, nil, nil, WANDER_TIMING),
    }, .25)

    self.bt = BT(self.inst, root)
end

return TyphonPhantomBrain
