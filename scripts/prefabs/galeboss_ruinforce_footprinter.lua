local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM", "anim/gale_groundpound_fx_dynamic.zip"),
    Asset("ANIM", "anim/antlion_sinkhole.zip"),
}

-- local hole = CreateSinkhole(GetRandomItem({1,2,3}))
local function CreateSinkhole(state)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("sinkhole")
    inst.AnimState:SetBuild("antlion_sinkhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    local s = 0.66
    inst.Transform:SetScale(s,s,s)

    state = state or 1
    if state == 3 then
        inst.AnimState:ClearOverrideSymbol("cracks1")
    else 
        inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre"..tostring(state))
    end
    
    inst:DoTaskInTime(GetRandomMinMax(5,8),function()
        GaleCommon.FadeTo(inst,GetRandomMinMax(1,1.5),nil,{
            Vector4(1,1,1,1),
            Vector4(0,0,0,0)
        })
    end)
    

    return inst
end

-- local dirt = CreateDirt(GetRandomItem({3,4,5}))
local function CreateDirt(symbol,s)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gale_groundpound_fx_dynamic")
    inst.AnimState:SetBuild("gale_groundpound_fx_dynamic")
    inst.AnimState:PlayAnimation("dynamic",true)
    inst.AnimState:SetDeltaTimeMultiplier(1.2)

    if symbol then
        inst.AnimState:OverrideSymbol("1","gale_groundpound_fx_dynamic",tostring(symbol))
    end

    s = s or 0.8
    inst.Transform:SetScale(s,s,s)
    GaleCommon.FadeTo(inst,GetRandomMinMax(1.5,2),{
        Vector3(s,s,s),
        Vector3(s*0.6,s*0.6,s*0.6),
    },nil,nil,inst.Remove)

    inst.task = inst:DoPeriodicTask(0,function()
        local x,y,z = inst:GetPosition():Get()
        local gravity = 40
        local vx,vy,vz = inst.Physics:GetMotorVel()
        vy = vy - gravity * FRAMES
        inst.Physics:SetMotorVel(vx,vy,vz)

        if y <= 0.05 and vy <= 0 then
            inst.Transform:SetPosition(x,0,z)
            inst.Physics:Stop()
            inst.AnimState:Pause()
            inst.task:Cancel()
        end
    end)

    return inst
end

-- local function GetWalkLoopPartOffset(inst)
--     local offset = Vector3(0,0,0)
--     local play_time = inst.AnimState:GetCurrentAnimationTime()
--     -- if 22 * FRAMES <= play_time and play_time <= 28 * FRAMES then
--     --     -- 25 * FRAMES
--     --     offset = TheCamera:GetRightVec() * 2.75
--     -- elseif 41 * FRAMES <= play_time and play_time <= 47 * FRAMES then
--     --     -- 44 * FRAMES
--     --     offset = TheCamera:GetRightVec() * 3
--     -- end
--     if 15 * FRAMES <= play_time and play_time <= 35 * FRAMES then
--         -- 25 * FRAMES
--         offset = TheCamera:GetRightVec() * 2.75
--     elseif 35 * FRAMES < play_time and play_time <= 54 * FRAMES then
--         -- 44 * FRAMES
--         offset = TheCamera:GetRightVec() * 3
--     end

--     return offset 
-- end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    -- inst._x = net_float(inst.GUID,"inst._x")
    -- inst._z = net_float(inst.GUID,"inst._z")
    inst._trigger = net_string(inst.GUID,"inst._trigger","triggerdirty")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("triggerdirty",function()
            local owner = inst.entity:GetParent()
            local dtype = inst._trigger:value()
            if not owner then
                print(inst,"Get No owner")
            elseif dtype == "superland" then
                for i = 1,GetRandomMinMax(18,25) do
                    local spawn_offset = Vector3(CreateSphereEmitter(3.5)())
                    spawn_offset.y = GetRandomMinMax(0.5,0.8)

                    local dirt = CreateDirt(GetRandomItem({3,4,5}),1.2)
                    dirt.Transform:SetPosition((owner:GetPosition() + spawn_offset):Get())
                    dirt:ForceFacePoint((owner:GetPosition() + spawn_offset*2):Get())

                    local vx_init = GetRandomMinMax(0,2)
                    local vy_init = GetRandomMinMax(10,15)
                    dirt.Physics:SetMotorVel(vx_init,vy_init,0)
                end 
            elseif dtype == "superjump" then
                local length = 2.8
                local pos_list = {
                    owner:GetPosition() + TheCamera:GetRightVec()*length,
                    owner:GetPosition() - TheCamera:GetRightVec()*length
                }

                for _,pos in pairs(pos_list) do
                    local hole = CreateSinkhole(2)
                    hole.Transform:SetPosition(pos:Get())

                    for i = 1,GetRandomMinMax(7,10) do
                        local spawn_offset = Vector3(CreateSphereEmitter(0.5)())
                        spawn_offset.y = GetRandomMinMax(0.5,0.8)
    
                        local dirt = CreateDirt(GetRandomItem({3,4,5}))
                        dirt.Transform:SetPosition((pos + spawn_offset):Get())
                        -- dirt.AnimState:SetMultColour(74/255,69/255,57/255,1)
                        dirt:ForceFacePoint((pos + spawn_offset*2):Get())
    
                        local vx_init = GetRandomMinMax(0,2)
                        local vy_init = GetRandomMinMax(10,15)
                        dirt.Physics:SetMotorVel(vx_init,vy_init,0)
                    end 
                end

                
            else
                local facing = owner.AnimState:GetCurrentFacing()
                local offset = Vector3(0,0,0)
                if facing == FACING_RIGHT then
                    if owner.AnimState:IsCurrentAnimation("walk_pre") then
                        offset = TheCamera:GetRightVec() * 2.75
                    elseif owner.AnimState:IsCurrentAnimation("walk_loop") then
                        
                        local play_time = owner.AnimState:GetCurrentAnimationTime()
                        if 15 * FRAMES <= play_time and play_time <= 35 * FRAMES then
                            -- 25 * FRAMES
                            offset = TheCamera:GetRightVec() * 2.75
                        elseif 36 * FRAMES <= play_time and play_time <= 54 * FRAMES then
                            -- 44 * FRAMES
                            offset = TheCamera:GetRightVec() * 3
                        end
                    elseif owner.AnimState:IsCurrentAnimation("walk_pst") then
                        offset = TheCamera:GetRightVec() * 2.75
                    end

                elseif facing == FACING_UP then 
                    offset = -TheCamera:GetDownVec() * 2.75

                    if owner.AnimState:IsCurrentAnimation("walk_pre") then
                        offset = offset + TheCamera:GetRightVec() * 1
                    elseif owner.AnimState:IsCurrentAnimation("walk_loop") then
                        
                        local play_time = owner.AnimState:GetCurrentAnimationTime()
                        if 15 * FRAMES <= play_time and play_time <= 35 * FRAMES then
                            -- 25 * FRAMES,Left
                            offset = offset - TheCamera:GetRightVec() * 1
                        elseif 36 * FRAMES <= play_time and play_time <= 54 * FRAMES then
                            -- 44 * FRAMES,Right
                            offset = offset + TheCamera:GetRightVec() * 1
                        end
                    elseif owner.AnimState:IsCurrentAnimation("walk_pst") then
                        offset = TheCamera:GetRightVec() * 3
                    end

                elseif facing == FACING_LEFT then 
                    if owner.AnimState:IsCurrentAnimation("walk_pre") then
                        offset = -TheCamera:GetRightVec() * 2.75
                    elseif owner.AnimState:IsCurrentAnimation("walk_loop") then
                        
                        local play_time = owner.AnimState:GetCurrentAnimationTime()
                        if 15 * FRAMES <= play_time and play_time <= 35 * FRAMES then
                            -- 25 * FRAMES
                            offset = -TheCamera:GetRightVec() * 2.75
                        elseif 36 * FRAMES <= play_time and play_time <= 54 * FRAMES then
                            -- 44 * FRAMES
                            offset = -TheCamera:GetRightVec() * 3
                        end
                    elseif owner.AnimState:IsCurrentAnimation("walk_pst") then
                        offset = -TheCamera:GetRightVec() * 2.75
                    end
                elseif facing == FACING_DOWN then 
                    offset = TheCamera:GetDownVec() * 1

                    if owner.AnimState:IsCurrentAnimation("walk_pre") then
                        offset = offset - TheCamera:GetRightVec() * 1
                    elseif owner.AnimState:IsCurrentAnimation("walk_loop") then
                        
                        local play_time = owner.AnimState:GetCurrentAnimationTime()
                        if 15 * FRAMES <= play_time and play_time <= 35 * FRAMES then
                            -- 25 * FRAMES,Right
                            offset = offset + TheCamera:GetRightVec() * 1
                        elseif 36 * FRAMES <= play_time and play_time <= 54 * FRAMES then
                            -- 44 * FRAMES,Left
                            offset = offset - TheCamera:GetRightVec() * 0.75
                        end
                    elseif owner.AnimState:IsCurrentAnimation("walk_pst") then
                        offset = TheCamera:GetRightVec() * 1
                    end
                end

                local hole = CreateSinkhole(2)

                -- owner:GetPosition() has a delay,try net vars ?
                -- local owner_pos = Vector3(inst._x:value(),0,inst._z:value())
                hole.Transform:SetPosition((owner:GetPosition() + offset):Get())

                for i = 1,GetRandomMinMax(7,10) do
                    local spawn_offset = Vector3(CreateSphereEmitter(0.5)())
                    spawn_offset.y = GetRandomMinMax(0.5,0.8)

                    local dirt = CreateDirt(GetRandomItem({3,4,5}))
                    dirt.Transform:SetPosition((owner:GetPosition() + offset + spawn_offset):Get())
                    -- dirt.AnimState:SetMultColour(74/255,69/255,57/255,1)
                    dirt:ForceFacePoint((owner:GetPosition() + offset + spawn_offset*2):Get())

                    local vx_init = GetRandomMinMax(0,2)
                    local vy_init = GetRandomMinMax(10,15)
                    dirt.Physics:SetMotorVel(vx_init,vy_init,0)
                end 
            end
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false 

    inst.TriggerStep = function(inst,dtype)
        dtype = dtype or "step"
        -- local x,_,z = inst.Transform:GetWorldPosition()
        -- inst._x:set(x)
        -- inst._z:set(z)
        inst._trigger:set_local("")
        inst._trigger:set(dtype)
    end

    return inst
end

return Prefab("galeboss_ruinforce_footprinter",fn,assets)