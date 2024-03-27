local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")
local GaleEntity = require("util/gale_entity")

local brain = require("brains/gale_skill_honeybee_token_brain")

local assets = {
    Asset("ANIM", "anim/wilton.zip"),
    Asset("ANIM", "anim/werewilba_actions.zip"),
    Asset("ANIM", "anim/gale_phantom_add.zip"),
    
}

local function CommonClientFn(inst)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.5, .75)

    MakeCharacterPhysics(inst, 50, .5)

    inst.Transform:SetFourFaced()

    inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
   	inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")
    inst.AnimState:AddOverrideBuild("gale_phantom_add")

    inst.AnimState:OverrideSymbol("swap_object", "swap_gale_crowbar", "swap_gale_crowbar")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
	inst.AnimState:Show("HEAD")
	inst.AnimState:Hide("HEAD_HAT")
end

local function CommonServerFn(inst)
    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health.save_maxhealth = true

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = 0.5
    inst.components.combat.defaultdamage = 64

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("lootdropper")

    
end

local function SelectTargetFnPhantom(inst)
    local leader = inst.components.follower:GetLeader()
    local leader_target = leader and leader.components.combat and leader.components.combat.target 

    if leader_target then
        return leader_target
    end
    

    return FindEntity(inst, 12,
        function(guy)
            return guy ~= leader 
                    and inst.components.combat:CanTarget(guy)
                    and (
                        (leader and guy.components.combat:TargetIs(leader))
                        or (guy.components.combat:TargetIs(inst))
                    )
                        
        end,
        {"_combat","_health"}, 
        {"INLIMBO"}
    )
end

local function KeepTargetFnPhantom(inst,target)
    local leader = inst.components.follower:GetLeader()

    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and inst:IsNear(target, 20)
        and (leader == nil or leader:IsNear(inst,15))
end

local function OnAttackedPhantom(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    local leader = inst.components.follower:GetLeader()

    if attacker ~= nil and attacker ~= leader then
        inst.components.combat:SetTarget(attacker)
    end

    if attacker then
        inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
    end
    
end

-- c_spawn("gale_skill_honeybee_token")
-- local x,y,z = ThePlayer:GetPosition():Get() ThePlayer.components.petleash:SpawnPetAt(x,0,z,"gale_skill_honeybee_token")
return GaleEntity.CreateNormalEntity({
    prefabname = "gale_skill_honeybee_token",
    assets = assets,

    tags = {"character"},

    bank = "wilson",
    build = "gale",
    anim = "idle",

    clientfn = CommonClientFn,
    serverfn = function(inst)
        CommonServerFn(inst)

        inst:SetStateGraph("SGgale_skill_honeybee_token")

        inst:SetBrain(brain)
    end,
}),GaleEntity.CreateNormalEntity({
    prefabname = "gale_skill_phantom",
    assets = assets,

    tags = {"character","shadowminion"},

    bank = "wilson",
    build = "wilton",
    anim = "idle",

    clientfn = function(inst)
        CommonClientFn(inst)

        inst.AnimState:ClearOverrideSymbol("swap_object")
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")

        inst.AnimState:SetMultColour(0,0,0,1)

        inst.AnimState:OverrideSymbol("headbase","gale","headbase")

        if not TheNet:IsDedicated() then
            inst._flame1 = SpawnPrefab("gale_phantom_eyes_vfx")
            inst._flame2 = SpawnPrefab("gale_phantom_eyes_vfx")

            inst._flame1.entity:SetParent(inst.entity)
            inst._flame2.entity:SetParent(inst.entity)

            inst._flame1.entity:AddFollower()
            inst._flame2.entity:AddFollower()

            inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",0,0,0)
            inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",0,0,0)

            inst:DoPeriodicTask(0,function()
                local face = inst.Transform:GetFacing()
                local poses = nil 

                if inst:HasTag("reborning") then
                    inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                    inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)

                    inst._flame1.should_emit = true 
                    inst._flame2.should_emit = true 
                elseif inst:HasTag("death") then
                    -- inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                    -- inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)

                    inst._flame1.should_emit = false 
                    inst._flame2.should_emit = false
                elseif inst:HasTag("attacked") then
                    inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                    inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)

                    inst._flame1.should_emit = true 
                    inst._flame2.should_emit = true 
                else
                    if face == 3 then
                        inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                        inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)
    
                        inst._flame1.should_emit = true 
                        inst._flame2.should_emit = true 
                    elseif face == 0 then
                        inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",10,-50,0.1)
                        inst._flame1.should_emit = true 
                        inst._flame2.should_emit = false 
                    elseif face == 1 then
                        inst._flame1.should_emit = false  
                        inst._flame2.should_emit = false 
                    elseif face == 2 then
                        inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",10,-50,0.1)
                        inst._flame1.should_emit = true 
                        inst._flame2.should_emit = false 
                    else 
                        inst._flame1.should_emit = false  
                        inst._flame2.should_emit = false 
                    end
                end
                
            end)
        end
    end,
    serverfn = function(inst)
        CommonServerFn(inst)

        inst.components.locomotor.walkspeed = 2.6
        inst.components.locomotor.runspeed = 7

        inst.components.health:SetMaxHealth(250)
        inst.components.health.nofadeout = true 

        inst.components.combat:SetRange(1.5)
        inst.components.combat:SetDefaultDamage(33)
        inst.components.combat:SetAttackPeriod(0.5)
        inst.components.combat:SetRetargetFunction(1, SelectTargetFnPhantom)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFnPhantom)

        inst:SetStateGraph("SGgale_phantom")

        inst:SetBrain(brain)

        inst:ListenForEvent("attacked",OnAttackedPhantom)
    end,
}),GaleEntity.CreateNormalFx({
    prefabname = "gale_skill_phantom_create_puddle",
    assets = assets,

    bank = "squid_puddle",
    build = "squid_puddle",
    anim = "puddle_dry",

    clientfn = function(inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)

        inst.Transform:SetRotation(GetRandomMinMax(-180,180))
    end,

    serverfn = function(inst)
        inst:DoTaskInTime(0.33,function()
            inst.AnimState:Pause()
        end)

        inst.ResumeAnim = function(inst)
            inst.AnimState:Resume()
        end


    end

}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_skill_phantom_create_splash",
    assets = assets,

    bank = "squid_watershoot",
    build = "squid_watershoot",
    anim = "splash",
})

