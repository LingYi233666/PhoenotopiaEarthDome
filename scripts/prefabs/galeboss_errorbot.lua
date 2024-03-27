local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local brain = require("brains/galeboss_errorbotbrain")

local assets = {
    Asset("ANIM", "anim/player_living_suit_shoot.zip"),	
	Asset("ANIM", "anim/player_living_suit_morph.zip"),			
	Asset("ANIM", "anim/player_living_suit_punch.zip"),
	Asset("ANIM", "anim/player_living_suit_destruct.zip"),
	Asset("ANIM", "anim/living_suit_build.zip"),
}

local function CreateUnderShadow(owner)
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddDynamicShadow()

    inst.DynamicShadow:SetSize(1.3, .6)

    owner:AddChild(inst)
    inst:DoPeriodicTask(0,function()
        local x,y,z = owner:GetPosition():Get()
        inst.Transform:SetPosition(0,-y,0)


        inst.DynamicShadow:Enable(owner.entity:IsVisible())
    end)

    return inst
end

local function ErrorbotClientFn(inst)
    MakeCharacterPhysics(inst, 75, .5)

    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, .6)

    if not TheNet:IsDedicated() then
        inst._shadow = CreateUnderShadow(inst)
    end
    

    inst.Transform:SetFourFaced()

    inst.AnimState:AddOverrideBuild("player_pistol")
    inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
   	inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")
	inst.AnimState:Show("HEAD")
	inst.AnimState:Hide("HEAD_HAT")

    inst.AnimState:AddOverrideBuild("player_living_suit_morph")

    GaleCommon.AddEpicBGM(inst,"galeboss_mini")

    inst:ListenForEvent("death",function ()
        inst:StopBrain()
    end)
end 

local function RetargetFn(inst)
    return FindEntity(
        inst,
        20,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat"},
        {"FX", "NOCLICK","INLIMBO"}
    )
end

local function KeepTargetFn(inst,target)
    return inst.components.combat:CanTarget(target) 
		and (target.components.health and not target.components.health:IsDead()) 
		and not (inst.components.follower and (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end

local function OnAttacked(inst,data)
	local attacker = data.attacker
	-- inst.components.combat:SuggestTarget(attacker)
    inst.components.combat:SetTarget(attacker)
end 


local function ErrorbotServerFn(inst)
    inst:AddComponent("health")
	inst.components.health:SetMaxHealth(1250)
    inst.components.health.destroytime = 6
    
    inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(0, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn) 
	inst.components.combat:SetDefaultDamage(150)
    inst.components.combat:SetAttackPeriod(3)
	inst.components.combat:SetRange(1.5)
    inst.components.combat:SetHurtSound("gale_sfx/battle/hit_metal")
    inst.components.combat.playerdamagepercent = 0.5

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = 4.5
    inst.components.locomotor.walkspeed = 6.5

    inst:AddComponent("colouradder")
    inst:AddComponent("bloomer")

    inst:AddComponent("lootdropper")

    inst:AddComponent("gale_flyer")
    inst.components.gale_flyer.speed_fn = function(inst,cur_height,target_height)
        local delta = target_height - cur_height
        return delta * (delta > 0 and 2 or 3.33)
    end
    -- inst.components.gale_flyer:Enable(false)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGgaleboss_errorbot")

    GaleCondition.AddCondition(inst,"condition_metallic")

    inst:ListenForEvent("attacked",OnAttacked)
end 

--------------------------------------------------------------------------------------
local function CreateTail(bank, build, anim,lightoverride, addcolour, multcolour)
    local inst = CreateEntity()
  
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false
  
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
  
    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()
  
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim,true)
    inst.AnimState:HideSymbol("orb_group")
    inst.AnimState:SetTime(30 * FRAMES * math.random())
    if addcolour ~= nil then
        inst.AnimState:SetAddColour(unpack(addcolour))
    end
    if multcolour ~= nil then
        inst.AnimState:SetMultColour(unpack(multcolour))
    end
    if lightoverride > 0 then
        inst.AnimState:SetLightOverride(lightoverride)
    end
    inst.AnimState:SetFinalOffset(-1)
    
  
    -- inst:ListenForEvent("animover", inst.Remove)
  
    return inst
end

local function OnUpdateProjectileTail(inst, bank, build, anim,speed, lightoverride, addcolour, multcolour, m_offset, tails)
    if not inst._usetail:value() then return end
    m_offset = m_offset or Vector3(0,0,0)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail(bank, build, anim,lightoverride, addcolour, multcolour)
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * 2 * PI
        local offsradius = math.random() * .4 + .1
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset + m_offset.x, y + voffset + m_offset.y, z + math.cos(rot) * hoffset + m_offset.z)
        tail.Physics:SetMotorVel(speed * (.2 + math.random() * .3), 0, 0)
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
        GaleCommon.FadeTo(tail,1,{Vector3(0.5,0.5,0.5),Vector3(0.2,0.2,0.2)},{Vector4(1,1,1,1),Vector4(0,0,0,0)},nil,function(m_tail)
            m_tail:Remove()
        end)
    end
end

local function ProjectileClientFn(inst)
    inst._usetail = net_bool(inst.GUID,"inst._usetail")

    if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, 
            "metal_hulk_projectile", "metal_hulk_projectile","spin_loop", 15, 1,nil, nil, Vector3(0,0.1,0), {})
    end

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
end

local function OnProjectileLaunch(inst)
    inst._usetail:set(true)
    inst.AnimState:PlayAnimation("spin_loop",true)

    local mypos = inst:GetPosition()
    local tarpos = inst.components.complexprojectile.targetpos
    local dy = tarpos.y - mypos.y
    local dx = Vector3(tarpos.x,0,tarpos.z):Dist(Vector3(mypos.x,0,mypos.z))
    local dt = dx / inst.components.complexprojectile.horizontalSpeed

    local vy = dy / dt

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed,vy,0)

    inst.removetask = inst:DoTaskInTime(5,function()
        inst.components.complexprojectile:Hit()
    end)

    inst:ListenForEvent("death",function()
        inst:Remove()
    end,inst.components.complexprojectile.attacker)

    inst:ListenForEvent("onremove",function()
        inst:Remove()
    end,inst.components.complexprojectile.attacker)

end

local function OnProjectileUpdate(inst)
    local max_speed = 50

    local mypos = inst:GetPosition()
    local tarpos = inst.components.complexprojectile.targetpos
    local dy = tarpos.y - mypos.y
    local dx = Vector3(tarpos.x,0,tarpos.z):Dist(Vector3(mypos.x,0,mypos.z))
    local dt = dx / inst.components.complexprojectile.horizontalSpeed

    local vy = dy / dt

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed,vy,0)
    inst.components.complexprojectile.horizontalSpeed = math.min(max_speed,inst.components.complexprojectile.horizontalSpeed + FRAMES * 25)
    
    local attacker = inst.components.complexprojectile.attacker
    local x,y,z = inst.Transform:GetWorldPosition()

    if y <= 0.05 and inst.hit_ground then 
        inst.components.complexprojectile:Hit()
        return true
    end


    local ents = TheSim:FindEntities(x,y,z,1.5,{"_combat","_health"},{"INLIMBO"})
    for k,v in pairs(ents) do 
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then 
            inst.components.complexprojectile:Hit(v)
            break
        end 
    end
    
    return true
end

local function OnProjectileHit(inst,other)
    inst._usetail:set(false)
    local pos = inst:GetPosition()
    SpawnAt("gale_laser_explosion",Vector3(pos.x,math.max(0,pos.y - 0.4),pos.z))

    -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/smash_3")    
    inst.SoundEmitter:PlaySound("gale_sfx/battle/explode")
    inst.SoundEmitter:PlaySound("gale_sfx/battle/explo_stereo")

    local attacker = inst.components.complexprojectile.attacker

    GaleCommon.AoeDestroyWorkableStuff(attacker,inst:GetPosition(),3,5)
    GaleCommon.AoeForEach(attacker,inst:GetPosition(),3,nil,{"INLIMBO"},{"_combat","_inventoryitem"},function(attacker,other)
        if (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other)) then 
            other.components.combat:GetAttacked(attacker,40)
        elseif other.components.inventoryitem then 
            GaleCommon.LaunchItem(other,inst,5)
        end 

        local adder = SpawnPrefab("gale_hit_color_adder")
        adder.add_colour = Vector3(1,0,0)
        adder:SetTarget(other)
    end,inst.ValidFn)

    if inst.removetask then 
        inst.removetask:Cancel()
        inst.removetask = nil 
    end 

    inst.Physics:Stop()
    inst.AnimState:PlayAnimation("impact")
    inst:ListenForEvent("animover",inst.Hide)
    inst:DoTaskInTime(3,inst.Remove)
end
-- SpawnAt("gale_red_ball_projectile",ThePlayer).components.complexprojectile:Launch(TheInput:GetWorldPosition(),ThePlayer)
local function ProjectileServerFn(inst)
    inst.ValidFn = function(attacker,other)
        return (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other))
        or other.components.inventoryitem
    end

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile.horizontalSpeed = 4
    inst.components.complexprojectile.onupdatefn = OnProjectileUpdate
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)
    inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_errorbot",
    assets = assets,
    bank = "wilson",
    build = "living_suit_build",
    anim = "idle",
    loop_anim = true,
    tags = {"galeboss","mech"},

    clientfn = ErrorbotClientFn,
    serverfn = ErrorbotServerFn,
}),GaleEntity.CreateNormalEntity({
    -- 
    prefabname = "galeboss_errorbot_redball",

    assets = assets,
    persists = false,
    tags = {"NOCLICK","NOBLOCK"},
    bank = "metal_hulk_projectile",
    build = "metal_hulk_projectile",
    lightoverride = 1,

    clientfn = ProjectileClientFn,
    serverfn = ProjectileServerFn,
}),GaleEntity.CreateNormalFx({
    prefabname = "galeboss_errorbot_shadow",

    assets = assets,
    bank = "wilson",
    build = "living_suit_build",
    anim = "idle",
    loop_anim = true,
    lightoverride = 1,

    clientfn = function(inst)
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)

        inst.Transform:SetFourFaced()

        -- inst.AnimState:AddOverrideBuild("player_pistol")
        -- inst.AnimState:AddOverrideBuild("player_actions_roll")
        inst.AnimState:AddOverrideBuild("player_lunge")
        inst.AnimState:AddOverrideBuild("player_attack_leap")
        inst.AnimState:AddOverrideBuild("player_superjump")
        inst.AnimState:AddOverrideBuild("player_multithrust")
        inst.AnimState:AddOverrideBuild("player_parryblock")

        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:Show("HEAD")
        inst.AnimState:Hide("HEAD_HAT")

        inst.AnimState:AddOverrideBuild("player_living_suit_morph")
    end,
})