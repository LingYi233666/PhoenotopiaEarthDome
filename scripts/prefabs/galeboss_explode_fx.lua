local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
require("util/vector4")

local assets = {
    Asset("ANIM", "anim/galeboss_explode_fx.zip"),
}

local function CreateSplited()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst,0.01)
    inst.Physics:ClearCollisionMask()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("galeboss_explode_fx")
    inst.AnimState:SetBuild("galeboss_explode_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetDeltaTimeMultiplier(GetRandomMinMax(0.45,0.5))
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetScale(3.5,3.5,3.5)

    inst:DoTaskInTime(GetRandomMinMax(0.4,0.6),function ()
        local mr,mg,mb,ma = inst.AnimState:GetMultColour()
        GaleCommon.FadeTo(inst,GetRandomMinMax(0.6,0.7),nil,{
            Vector4(mr,mg,mb,ma),
            Vector4(0,0,0,0),
        },nil,inst.Remove)
    end)
    -- inst:ListenForEvent("animover",function ()
    --     local mr,mg,mb,ma = inst.AnimState:GetMultColour()
    --     GaleCommon.FadeTo(inst,GetRandomMinMax(0.33,0.5),nil,{
    --         Vector4(mr,mg,mb,ma),
    --         Vector4(0,0,0,0),
    --     },nil,inst.Remove)
    -- end)

    return inst
end

local function NormalEmitFn(inst,data)
    for i = 1,math.random(data.num_min,data.num_max) do
        local spawn_sphere = CreateSphereEmitter(0.25)
        local spawn_offset = Vector3(spawn_sphere())
        local mypos = inst:GetPosition()
        local spawnpos = (mypos+spawn_offset)

        local splited = CreateSplited()

        splited.Transform:SetPosition(spawnpos:Get())

        if data.multcolour then
            splited.AnimState:SetMultColour(unpack(FunctionOrValue(data.multcolour,inst)))
        end
        if data.addcolour then
            splited.AnimState:SetAddColour(unpack(FunctionOrValue(data.addcolour,inst)))
        end

        local v_angle1,v_angle2 = math.random() * PI * 2,math.random() * PI * 2
        local speed = data.speed or 20 

        local vx, vy, vz = speed * math.sin(v_angle1) * math.cos(v_angle2),
                            speed * math.sin(v_angle1) * math.sin(v_angle2),
                            speed * math.cos(v_angle1)

        splited:ForceFacePoint(spawnpos.x + vx, 0,spawnpos.z + vz)
        vx = math.sqrt(vx*vx + vz*vz)
        vz = 0

        splited.vel = Vector3(vx, vy, vz)
        splited.Physics:SetMotorVel(vx, vy, vz)
        splited:StartThread(function()
            while true do
                local length = splited.vel:Length()
                length = length - (data.friction or 4) * FRAMES
                if length <= 0 then
                    splited.Physics:Stop()
                else 
                    splited.vel = splited.vel:GetNormalized() * length
                    splited.vel.y = splited.vel.y - (data.gravity or 8) * FRAMES
                    splited.Physics:SetMotorVel(splited.vel:Get())
                end
                
                Sleep(0)
            end
            
        end)
    end
end


local function Wrapper(data)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
    
        if not TheNet:IsDedicated() then
            inst:StartThread(function()
                
                while true do
                    NormalEmitFn(inst,{
                        num_min = data.num_min or 4,
                        num_max = data.num_max or 6,
                        multcolour = data.multcolour,
                        addcolour = data.addcolour,
                        speed = data.speed,
                        friction = data.friction,
                        gravity = data.gravity,
                    })
                    Sleep(0)
                    if data.emit_once then
                        break
                    end
                end
            end)
        end
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst.persists = false

        if data.emit_once then
            inst:DoTaskInTime(10 * FRAMES,inst.Remove)
        end
    
    
        return inst
    end 

    return fn 
end




-- c_spawn("galeboss_explode_fx")
-- SpawnPrefab("galeboss_explode_fx"):FollowSymbol(ThePlayer,"swap_object",0,-200,0)
-- c_spawn("galeboss_explode_fx_final")
-- c_spawn("galeboss_dragon_snare").components.health:Kill()

local function MultColourFn()
    return math.random() <= 0.4 and {255/255,108/255,0,1} or {1,1,1,1}
end

return 
Prefab("galeboss_explode_fx",Wrapper({
    multcolour = MultColourFn,
}),assets),
Prefab("galeboss_explode_fx_start",Wrapper({
    num_min = 65,
    num_max = 70,
    speed = 13,
    friction = 15,
    gravity = 0,
    emit_once = true,
    multcolour = MultColourFn,
}),assets),
Prefab("galeboss_explode_fx_final",Wrapper({
    num_min = 35,
    num_max = 40,
    speed = 28,
    friction = 18,
    gravity = 0,
    emit_once = true,
    multcolour = MultColourFn,
}),assets)
