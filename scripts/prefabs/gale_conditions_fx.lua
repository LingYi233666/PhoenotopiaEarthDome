require "util/vector4"

local function CreateClientAnim(data)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation(data.anim, data.loop)

    if not data.no_removed then 
        inst:ListenForEvent("animover",inst.Remove)
    end 

    if data.fn then 
        data.fn(inst)
    end

    return inst
end

local function CreateExplodeAnim()
    return CreateClientAnim({
        bank = "lavaarena_heal_projectile",
        build = "lavaarena_heal_projectile",
        anim = "hit",
        fn = function(orb)
            orb.AnimState:HideSymbol("fff")
            orb.AnimState:HideSymbol("fff2")
            orb.AnimState:HideSymbol("fff3")
            orb.AnimState:HideSymbol("drop")
            orb.AnimState:SetAddColour(1,1,1,1)
            orb.AnimState:SetFinalOffset(2)
        end,
    })
end

local function CreateMainFrame(data)
    data = data or {}
    return CreateClientAnim({
        bank = "lavaarena_creature_teleport",
        build = "lavaarena_creature_teleport",
        anim = "spawn_small",
        no_removed = true,
        fn = function(main)
            main.AnimState:SetPercent("spawn_small",0.99)
            main:DoTaskInTime(data.remain_time or 5,main.Remove)
        end,
    })
end

local function FadeThread(inst,data)
    return inst:StartThread(function()
        local cur_time = 0
        local time = data.time 
        local mainframe = data.mainframe
        local mainframe_symbol = data.mainframe_symbol or "smoke1"

        local pos = data.pos 
        local max_pos = data.max_pos
        local delta_pos = (pos ~= nil and max_pos ~= nil) and ((max_pos - pos) / (time * 33)) or nil 

        local scale = data.scale 
        local max_scale = data.max_scale 
        local delta_scale = (scale ~= nil and max_scale ~= nil) and ((max_scale - scale) / (time * 33)) or nil 

        local rgba = data.rgba 
        local max_rgba = data.max_rgba 
        local delta_rgba = (max_rgba - rgba) / (time * 33)

        while cur_time <= time do 
            if scale then 
                inst.Transform:SetScale(scale:Get())
                scale = scale + delta_scale 
            end 

            if rgba then 
                -- print("Seeting rgba:",rgba:Get())
                inst.AnimState:SetMultColour(rgba:Get())
                rgba = rgba + delta_rgba
            end 

            if pos then 
                inst.Follower:FollowSymbol(mainframe.GUID, mainframe_symbol,pos:Get())
                pos = pos + delta_pos
            end 
            
            
            cur_time = cur_time + FRAMES

            Sleep(0)
        end
        
        if pos then 
            inst.Follower:FollowSymbol(mainframe.GUID, mainframe_symbol,max_pos:Get())
        end 

        if scale then 
            inst.Transform:SetScale(max_scale:Get())
        end 

        if rgba then 
            inst.AnimState:SetMultColour(max_rgba:Get())
        end 

        if data.completefn then 
            data.completefn(inst)
        end
    end)
end

local assets = {
    Asset("ANIM", "anim/condition_power_fx.zip"),
    Asset("ANIM", "anim/condition_impair_fx.zip"),
    Asset("ANIM", "anim/condition_wound_fx.zip"),

    Asset("ANIM", "anim/lavaarena_creature_teleport.zip"),
    Asset("ANIM", "anim/lavaarena_arcane_orb.zip"),
    Asset("ANIM", "anim/lavaarena_heal_projectile.zip"),

    Asset("ANIM", "anim/gooball_fx.zip"),
}

local function MakeFx(data)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst:DoTaskInTime(0, data.startfx, inst)
        end

        if data.twofaced then
            inst.Transform:SetTwoFaced()
        elseif data.eightfaced then
            inst.Transform:SetEightFaced()
        elseif data.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not data.nofaced then
            inst.Transform:SetFourFaced()
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(5, inst.Remove)

        if data.fn then 
            data.fn(inst)
        end

        return inst
    end

    return Prefab(data.name, fn, assets)
end
    
local fxs = {}
local datas = {
    condition_power_fx = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("gale_sfx/condition/GL_CombatStatus_Buff_Power")
            end)
            mainframe:DoTaskInTime(0.85,function()
                -- mainframe.SoundEmitter:PlaySound("dontstarve/common/lava_arena/heal_staff","explode")
                -- mainframe.SoundEmitter:SetVolume("explode",0.2)
                -- ThePlayer.SoundEmitter:PlaySoundWithParams("dontstarve/common/lava_arena/heal_staff",{intensity = 0.2})
                -- mainframe.SoundEmitter:PlaySound("dontstarve/common/lava_arena/heal_staff")
                mainframe.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold","explode")
                mainframe.SoundEmitter:SetVolume("explode",0.6)
            end)
            inst:AddChild(mainframe)

            CreateClientAnim({
                bank = "lavaarena_creature_teleport",
                build = "lavaarena_creature_teleport",
                anim = "spawn_small",
                fn = function(lightning)
                    lightning.AnimState:SetLightOverride(1)
                    lightning.AnimState:SetFinalOffset(2)
                    lightning.AnimState:HideSymbol("smoke1")
                    lightning.AnimState:HideSymbol("smoke3")
                    lightning.AnimState:HideSymbol("blast")
                    lightning.Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, 0, 0)
                end,
            })
            CreateClientAnim({
                bank = "condition_power_fx",
                build = "condition_power_fx",
                anim = "lionface",
                no_removed = true,
                fn = function(lionface)
                    
                    lionface.AnimState:SetLightOverride(1)
                    lionface.AnimState:SetFinalOffset(3)
                    lionface.AnimState:HideSymbol("liontooth")    

                    FadeThread(lionface,{
                        time = 0.2,
                        mainframe = mainframe,
                        pos = Vector3(0,-900,0),
                        max_pos = Vector3(0,-1200,0),
                        scale = Vector3(0.5,0.5,0.5),
                        max_scale = Vector3(1.3,1.3,1.3),
                        rgba = Vector4(0,0,0,0),
                        max_rgba = Vector4(1,1,1,1),
                    })
                    
                    lionface:DoTaskInTime(0.155,function()
                        lionface.AnimState:ShowSymbol("liontooth")
                    end)
                    lionface:DoTaskInTime(0.9,function()
                        CreateExplodeAnim().Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, -750, 0)
                        lionface:Remove()
                    end)
                end,
            })
            -- ThePlayer:SpawnChild("condition_power_fx")
        end,
    },

    -- ThePlayer:SpawnChild("condition_impair_fx")
    condition_impair_fx = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("gale_sfx/condition/sfx_battle_status_impair_01")
            end)
            mainframe:DoTaskInTime(0.65,function()
                mainframe.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash","explode")
                mainframe.SoundEmitter:SetVolume("explode",0.8)
            end)
            inst:AddChild(mainframe)

            CreateClientAnim({
                bank = "condition_impair_fx",
                build = "condition_impair_fx",
                anim = "cripple_pre",
                no_removed = true,
                fn = function(cripple)
                    cripple.Transform:SetScale(1.3,1.3,1.3)
                    cripple.AnimState:SetLightOverride(1)
                    cripple.AnimState:SetFinalOffset(2)
                    cripple.AnimState:PushAnimation("cripple_pst",false)
                     
                    FadeThread(cripple,{
                        time = 0.1,
                        mainframe = mainframe,
                        pos = Vector3(0,-750,0),
                        max_pos = Vector3(0,-900,0),
                        rgba = Vector4(0,0,0,0),
                        max_rgba = Vector4(159/255,90/255,168/255,1),
                    })
                    cripple:DoTaskInTime(0.65,function()
                        CreateExplodeAnim().Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, -550, 0)
                    end)
                    cripple:DoTaskInTime(1,function()
                        FadeThread(cripple,{
                            time = 0.6,
                            mainframe = mainframe,
                            rgba = Vector4(159/255,90/255,168/255,1),
                            max_rgba = Vector4(0,0,0,0),
                            completefn = cripple.Remove
                        })
                    end)
                end,
            })
        end,

    },

    -- ThePlayer:SpawnChild("condition_wound_fx")
    condition_wound_fx = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("gale_sfx/condition/sfx_battle_status_wound_01")
            end)
            inst:AddChild(mainframe)

            local parent = inst.entity:GetParent()
            inst:StartThread(function()
                local fx_list = parent:HasTag("largecreature") and {
                    {"wound1",Vector3(1.3,1.3,1),Vector3(-150, -450, 0),3,0},
                    {"wound1",Vector3(1,1,1),Vector3(-100, -350, 0),2,0},
                    {"wound1",Vector3(0.7,0.6,1),Vector3(-75, -250, 0),1,FRAMES * 1},

                    {"wound2",Vector3(1.3,1.3,1),Vector3(50, -450, -1),0,0},
                    {"wound2",Vector3(1,1,1),Vector3(25, -350, -1),0,0},
                    {"wound2",Vector3(0.6,0.6,1),Vector3(25, -250, -1),0,0},
                } or {
                    {"wound1",Vector3(1,1.1,1),Vector3(-150, -250, 0),3,0},
                    {"wound1",Vector3(0.6,0.7,1),Vector3(-100, -150, 0),2,0},
                    {"wound1",Vector3(0.4,0.4,1),Vector3(-75, -50, 0),1,FRAMES * 1},

                    {"wound2",Vector3(0.8,0.8,1),Vector3(50, -250, -1),0,0},
                    {"wound2",Vector3(0.6,0.6,1),Vector3(25, -150, -1),0,0},
                    {"wound2",Vector3(0.4,0.4,1),Vector3(25, -50, -1),0,0},
                }

                for k,v in pairs(fx_list) do 
                    CreateClientAnim({
                        bank = "condition_wound_fx",
                        build = "condition_wound_fx",
                        anim = v[1],
                        fn = function(wound)
                            wound.Transform:SetScale(v[2]:Get())
                            wound.AnimState:SetLightOverride(1)
                            wound.AnimState:SetFinalOffset(v[4])

                            if v[1] == "wound1" then 
                                wound.AnimState:SetMultColour(213/255,25/255,25/255,1)
                                wound.AnimState:SetAddColour(1,0,0,1)
                            else
                                wound.AnimState:SetMultColour(149/255,0/255,0/255,1)
                                -- wound.AnimState:SetAddColour(1,0,0,1)
                            end
                            wound.Follower:FollowSymbol(mainframe.GUID, "smoke1",v[3]:Get())
                        end,
                    })
                    Sleep(v[5])
                end
            end)
            
        end,

    },

    condition_bleed_fx_small = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/poison_hit")
            end)
            inst:AddChild(mainframe)

            CreateClientAnim({
                bank = "gooball_fx",
                build = "gooball_fx",
                anim = "smallblast",
                fn = function(blast)
                    blast.AnimState:SetLightOverride(1)
                    blast.AnimState:SetFinalOffset(2)
                    blast.AnimState:SetMultColour(196/255,0,0,1)

                    blast.Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, 0, 0)
                end,
            })
            
            
        end,

    },

    condition_bleed_fx = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/poison_hit")
            end)
            inst:AddChild(mainframe)

            CreateClientAnim({
                bank = "gooball_fx",
                build = "gooball_fx",
                anim = "blast",
                fn = function(blast)
                    blast.AnimState:SetLightOverride(1)
                    blast.AnimState:SetFinalOffset(2)
                    blast.AnimState:SetMultColour(196/255,0,0,1)

                    blast.Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, 0, 0)
                end,
            })
            
            
        end,

    },

    condition_dread_fx = {
        startfx = function(inst)
            local mainframe = CreateMainFrame()
            mainframe:DoTaskInTime(0,function()
                mainframe.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/poison_hit")
            end)
            inst:AddChild(mainframe)

            CreateClientAnim({
                bank = "gooball_fx",
                build = "gooball_fx",
                anim = "blast",
                fn = function(blast)
                    blast.AnimState:SetLightOverride(1)
                    blast.AnimState:SetFinalOffset(2)
                    blast.AnimState:SetMultColour(0,0,0,1)

                    blast.Follower:FollowSymbol(mainframe.GUID, "smoke1", 0, 0, 0)
                end,
            })
            
            
        end,

    },
}

for name,data in pairs(datas) do 
    data.name = name 
    table.insert(fxs,MakeFx(data))
end

return unpack(fxs)
