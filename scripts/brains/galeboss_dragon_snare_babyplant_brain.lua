require "behaviours/follow"
require "behaviours/wander"
require "behaviours/standandattack"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/faceentity"

local GaleCommon = require("util/gale_common")

local BabyPlantBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function CanFightFn(inst)
    local target = inst.components.combat.target
    return target and target:IsValid()
end

local NO_TAGS =
{
    "FX",
    "NOCLICK",
    "DECOR",
    "INLIMBO",
    "irreplaceable",
    "heavy",
    "galeboss_dragon_snare",
    "galeboss_dragon_snare_token",
    "notarget",
    "noattack",
    "flight",
    "invisible",
    "catchable",
    "fire",
    "eyeplant_immune",
}

local ACT_TAGS =
{
    "_inventoryitem",
    "pickable",
    "donecooking",
    "readyforharvest",
    "dried",
}

local function CaptureThingsAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end 

    local x, y, z = inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 2.5, nil, NO_TAGS, ACT_TAGS)
    for i, v in pairs(ents) do
        if v:IsValid() and v:IsOnValidGround() and v:GetTimeAlive() > 1 then
            local action = nil
            if (v.components.crop ~= nil and v.components.crop:IsReadyForHarvest()) or
                (v.components.stewer ~= nil and v.components.stewer:IsDone()) or
                (v.components.dryer ~= nil and v.components.dryer:IsDone()) then
                --Harvest!
                action = ACTIONS.HARVEST
            elseif v.components.pickable ~= nil and
                    v.components.pickable:CanBePicked() and
                    v.components.pickable.caninteractwith then
                --Pick!
                action = ACTIONS.PICK
            elseif v.components.inventoryitem ~= nil and
                    v.components.inventoryitem.cangoincontainer and
                    (v.components.inventoryitem.canbepickedup or v.components.inventoryitem.canbepickedupalive)
                    then
                    
                
                --Pick up!
                action = ACTIONS.PICKUP

                -- Don't pick moving things
                if v.Physics then
                    local vx,vy,vz = v.Physics:GetVelocity()
                    if math.sqrt(vx*vx + vy*vy + vz*vz) > 1 then
                        action = nil 
                    end
                end
            end
            if action ~= nil then
                local ba = BufferedAction(inst, v, action)
                ba.distance = 4
                return ba
            end
        end
    end
end

local function MurderAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end 

    local item = inst.components.inventory:GetItemInSlot(1)
    if item and item.components.health then
        return BufferedAction(inst, item, ACTIONS.MURDER)
    end
end

local function SubmitOrDropItemAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end 

    local item = inst.components.inventory:GetItemInSlot(1)
    local leader = inst.components.follower:GetLeader()

    if item then
        if leader and item.components.edible  then
            local ba = BufferedAction(inst, leader, ACTIONS.GIVE, item )
            ba.distance = 999
            return ba 
        else 
            -- Drop item
            inst.sg:GoToState("dropitem")
        end
    end 
    
end

local function GetFaceTarget(inst)
	return inst.components.combat.target
end

local function KeepFaceTarget(inst, target)
    return target and inst.components.combat.target == target and target.entity:IsVisible()
end

function BabyPlantBrain:OnStart()


    local root = PriorityNode({
        IfNode(function()  
            local item = self.inst.components.inventory:GetItemInSlot(1)
            return item and item.components.health
        end, "CanMurder",
            DoAction(self.inst,MurderAction)
        ),

        IfNode(function()  
            local item = self.inst.components.inventory:GetItemInSlot(1)
            return item ~= nil
        end, "CanSubmitOrDropItem",
            DoAction(self.inst,SubmitOrDropItemAction)
        ),


        IfNode(function()  
            local item = self.inst.components.inventory:GetItemInSlot(1)
            return item == nil
        end, "CanCaptureThingsAction",
            DoAction(self.inst,CaptureThingsAction)
        ),


        WhileNode(function()
            local target = self.inst.components.combat.target
            return  target ~= nil 
                and self.inst.components.combat:CanAttack(target)
                and not self.inst.components.combat:InCooldown()
        end, "AttackIfNearby",
            StandAndAttack(self.inst, nil, 1)
        ),

        FaceEntity(self.inst,GetFaceTarget,KeepFaceTarget),
        


    }, .25)

    self.bt = BT(self.inst, root)
end

return BabyPlantBrain
