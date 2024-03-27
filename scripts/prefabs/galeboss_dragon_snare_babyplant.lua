local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local brain = require("brains/galeboss_dragon_snare_babyplant_brain")

local function IsAlly(inst,other)
    local leader = inst.components.follower.leader
    return other == leader
         or other:HasTag("galeboss_dragon_snare")
         or other:HasTag("galeboss_dragon_snare_token")
end

local function BabyPlantRetarget(inst)    
    return FindEntity(
        inst,
        6,
        function(guy)
            return guy ~= inst
                and not IsAlly(inst,guy)
                and not guy.components.health:IsDead()
        end,
        { "_combat", "_health","character"},
        { "INLIMBO",}
    )
    
end

local function BabyPlantKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.entity:IsVisible()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target:IsNear(inst, 8)
end

local function PlantOnAttacked(inst,data)
    local attacker = data and data.attacker
    if attacker and attacker == inst.components.follower:GetLeader() then
        return 
    end
    
    inst.components.combat:SetTarget(attacker)

    inst.components.combat:ShareTarget(attacker, 6, function(dude)
        return dude:HasTag("galeboss_dragon_snare_token")
    end,3)
end


return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_dragon_snare_babyplant",
    assets = {
        Asset("ANIM", "anim/eyeplant.zip"),
    },

    tags = {"monster","galeboss_dragon_snare_token","veggie"},

    bank = "eyeplant",
    build = "eyeplant",
    anim = "idle",
    loop_anim = true,


    clientfn = function(inst)
        inst.Transform:SetFourFaced()

        MakeObstaclePhysics(inst, .1)
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")

        inst:AddComponent("follower")

        inst:AddComponent("locomotor")
        inst.components.locomotor:SetSlowMultiplier( 1 )
        inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.pathcaps = { ignorecreep = true }
        inst.components.locomotor.walkspeed = 0
        inst.components.locomotor.runspeed = 0

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(30)
    
        inst:AddComponent("combat")
        inst.components.combat:SetAttackPeriod(1)
        inst.components.combat:SetRange(2.5)
        inst.components.combat:SetRetargetFunction(0.2, BabyPlantRetarget)
        inst.components.combat:SetKeepTargetFunction(BabyPlantKeepTarget)
        inst.components.combat:SetDefaultDamage(20)

        inst:AddComponent("lootdropper")

        inst:AddComponent("inventory")
        inst.components.inventory.maxslots = 1

        inst:SetStateGraph("SGgaleboss_dragon_snare_babyplant")
        inst:SetBrain(brain)

        inst:ListenForEvent("attacked",PlantOnAttacked)
        inst:ListenForEvent("actionfailed",function(inst,data)
            print(inst,data.action.action,"FAILED",data.reason)
        end)
    end,
})