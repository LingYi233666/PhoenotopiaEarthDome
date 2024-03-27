local function StartWarn(proxy,soundpath,dist)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    proxy:AddChild(inst)

    local theta = math.random() * 2 * PI
    local pos = Vector3(math.cos(theta),0,math.sin(theta)) * dist
    inst.Transform:SetPosition(pos:Get())

    inst:DoTaskInTime(0,function ()
        inst.SoundEmitter:PlaySound(soundpath)
    end)
    
end

local function CreateWarning(soundpath,dist)
    return function ()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        

        inst._player = net_entity(inst.GUID,"inst._player","playerdirty")

        inst:AddTag("FX")


        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst:ListenForEvent("playerdirty",function()
                local net_player = inst._player:value()
                -- print(inst,"playerdirty",ThePlayer , net_player , net_player == ThePlayer)
                if ThePlayer and ThePlayer.HUD and net_player == ThePlayer then
                    -- print(inst,"StartWarn !")
                    StartWarn(inst,soundpath,dist)
                end
            end)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetPlayer = function(inst,player)
            inst._player:set(player)
        end

        inst.persists = false
        inst:DoTaskInTime(10, inst.Remove)

        return inst
    end
end

return 
Prefab("galeboss_ruinforce_warnings_low",CreateWarning("gale_sfx/battle/galeboss_ruinforce/roar_low",20)),
Prefab("galeboss_ruinforce_warnings_high",CreateWarning("gale_sfx/battle/galeboss_ruinforce/roar_high",15)),
Prefab("galeboss_ruinforce_warnings_step",CreateWarning("gale_sfx/battle/galeboss_ruinforce/step",35))