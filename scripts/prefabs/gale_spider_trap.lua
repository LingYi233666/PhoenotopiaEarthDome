local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/spider_cocoon.zip"),
}

local function TrapClient(inst)
    inst.AnimState:HideSymbol("bedazzled_flare")
    inst.AnimState:HideSymbol("c1")
    inst.AnimState:HideSymbol("c2")
    inst.AnimState:HideSymbol("c3")
end

-- c_spawn("gale_spider_trap"):DoTrap(c_spawn("spider"),5)
local function TrapServer(inst)
    inst.target = nil 

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(250)

    inst:AddComponent("combat")

    inst:ListenForEvent("attacked",function(inst,data)
        inst.AnimState:PlayAnimation("cocoon_large_hit")
        inst.AnimState:PushAnimation("cocoon_large",false)
        if inst.target and inst.target ~= data.attacker and inst.target.components.combat and inst.target.components.health
        and not inst.target.components.health:IsDead() then
            inst.target.components.combat:GetAttacked(data.attacker,data.damage)
        end
    end)

    inst:ListenForEvent("death",function(inst,data)
        inst.AnimState:PlayAnimation("cocoon_dead")

        if inst.target then
            inst:UnTrap()
        end
        
    end)

    inst:ListenForEvent("onremove",function(inst,data)
        if inst.target then
            inst:UnTrap()
        end
    end)

    inst.seek_target_task = inst:DoPeriodicTask(0,function()
        local x,y,z = inst:GetPosition():Get()
        local ents = TheSim:FindEntities(x,y,z,1.5,{"_combat","_health"},{"INLIMBO"}) 
        for k,v in pairs(ents) do
            if v ~= inst and v:IsValid() and not v.components.health:IsDead() then
                inst:DoTrap(v,15)
                inst.seek_target_task:Cancel()
                inst.seek_target_task = nil 
                break
            end
        end
    end)

    inst._release_event = function()
        inst:UnTrap()
        if not inst.components.health:IsDead() then
            inst.components.health:Kill()
        end
    end

    inst.DoTrap = function(inst,other,time)
        print('Success trapping',other)
        inst.target = other 

        inst.target.Transform:SetPosition(inst:GetPosition():Get())

        if inst.target.components.locomotor then
            inst.target.components.locomotor:SetExternalSpeedMultiplier(inst,inst.prefab,0)
        end

        inst:ListenForEvent("onremove",inst._release_event,inst.target)
        inst:ListenForEvent("death",inst._release_event,inst.target)

        inst.lock_task = inst:DoPeriodicTask(0,function()
            inst.target.Transform:SetPosition(inst:GetPosition():Get())
        end)
        inst.taunt_task = inst:DoPeriodicTask(0,function()
            -- inst.target.Transform:SetPosition(inst:GetPosition():Get())
            inst.target.components.combat:SetTarget(inst)
        end)
        inst.untrap_task = inst:DoTaskInTime(time,function()
            inst:UnTrap()
            if not inst.components.health:IsDead() then
                inst.components.health:Kill()
            end
        end)
    end

    inst.UnTrap = function(inst)
        inst:RemoveEventCallback("onremove",inst._release_event,inst.target)
        inst:RemoveEventCallback("death",inst._release_event,inst.target)

        if inst.lock_task then
            inst.lock_task:Cancel()
            inst.lock_task = nil 
        end

        if inst.taunt_task then
            inst.taunt_task:Cancel()
            inst.taunt_task = nil 
        end

        if inst.untrap_task then
            inst.untrap_task:Cancel()
            inst.untrap_task = nil 
        end

        if inst.target.components.locomotor then
            inst.target.components.locomotor:RemoveExternalSpeedMultiplier(inst,inst.prefab)
        end
        inst.target = nil 
    end
    
end

return GaleEntity.CreateNormalEntity({
    assets = assets,
    prefabname = "gale_spider_trap",
    tags = {"gale_spider_trap"},
    bank = "spider_cocoon",
    build = "spider_cocoon",
    anim = "cocoon_large",

    persists = false,

    clientfn = TrapClient,
    serverfn = TrapServer,
})