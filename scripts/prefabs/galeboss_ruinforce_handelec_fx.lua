local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM", "anim/laser_explosion.zip"),
    Asset("ANIM", "anim/laser_ring_fx.zip"),
    Asset("ANIM", "anim/laser_explode_sm.zip"),
    Asset("ANIM", "anim/metal_hulk_projectile.zip"),
}

local function CreateElec()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("metal_hulk_projectile")
    inst.AnimState:SetBuild("metal_hulk_projectile")
    inst.AnimState:PlayAnimation("spin_loop",true)
    inst.AnimState:HideSymbol("orb_group")

    -- local s = 0.5
    -- inst.AnimState:SetScale(s,s,s)

    
    inst:DoTaskInTime(GetRandomMinMax(0.5,0.7),function()
        GaleCommon.FadeTo(inst,0.3,nil,{
            Vector4(1,1,1,1),
            Vector4(0,0,0,0)
        },nil,inst.Remove)
    end)
    

    return inst
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst._trigger = net_float(inst.GUID,"inst._trigger","triggerdirty")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("triggerdirty",function()
            if inst.task then
                inst.task:Cancel()
                inst.task = nil 
            end

            local p = inst._trigger:value()
            if p >= 0 then
                inst.task = inst:DoPeriodicTask(p,function()
                    local owner = inst.entity:GetParent()
                    if not owner then
                        return 
                    end
    
                    local fx = CreateElec()
                    fx.AnimState:SetTime(math.random(1,20) * FRAMES)
                    fx.Follower:FollowSymbol(owner.GUID,"deerclops_hand",0,0,0,true,true)
                    fx:DoTaskInTime(0.1,function ()
                        fx.Follower:StopFollowing()
                    end)
                    -- fx.Follower:StopFollowing()
                end)
                
            end
            
            
            
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false 

    inst.Enable = function(inst,periodic)
        inst._trigger:set_local(-99)
        inst._trigger:set(periodic)
    end

    return inst
end

return Prefab("galeboss_ruinforce_handelec_fx",fn,assets)