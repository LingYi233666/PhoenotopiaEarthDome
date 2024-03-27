local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_waterpipes",

    assets = {
        Asset("ANIM", "anim/gale_interior_pipes.zip"),
    },
    bank = "gale_interior_pipes",
    build = "gale_interior_pipes",
    anim = "sample_horizontal",

    tags = {"NOCLICK",},

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst.HasDropped = false 
        inst.fx_left = nil
        inst.fx_med = nil 
        inst.fx_right = nil 

        inst.OnSave = function(inst,data)
            data.HasDropped = inst.HasDropped
        end

        inst.OnLoad = function(inst,data)
            if data ~= nil then
                if data.HasDropped ~= nil then
                    inst.HasDropped = data.HasDropped
                end
            end
        end

        inst.EnableFakeKey = function(inst,enabled)
            if inst.fakekey then
                inst.fakekey:Remove()
                inst.fakekey = nil 
            end
            if enabled then
                -- inst.fakekey = SpawnPrefab("gale_eco_dome_keycard_fake")
                -- inst.fakekey.entity:SetParent(inst.entity)
                -- inst.fakekey.Follower:FollowSymbol(inst.GUID,"")
                inst.fakekey = inst:SpawnChild("gale_eco_dome_keycard_fake")
                inst.fakekey.Transform:SetPosition(-4,0,0)
            end
        end

        inst.DropKey = function(inst)
            inst.HasDropped = true 

            inst:EnableFakeKey(false)

            SpawnAt("gale_eco_dome_keycard",inst,nil,Vector3(-4,0,0)).components.inventoryitem:OnDropped(false)
        end

        inst.EnableWaterAt = function(inst,posi,enable)
            if posi == -1 then
                if inst.fx_left then
                    inst.fx_left:KillFX()
                    inst.fx_left = nil 
                end
                if enable then
                    inst.fx_left = inst:SpawnChild("gale_eco_dome_room_waterpipes_leak")
                    inst.fx_left:SetSize("med")
                    inst.fx_left.Transform:SetPosition(-4,0.1,0)
                    if not inst.HasDropped then
                        inst:DropKey()
                    end
                end
            elseif posi == 0 then
                if inst.fx_med then
                    inst.fx_med:KillFX()
                    inst.fx_med = nil 
                end
                if enable then
                    inst.fx_med = inst:SpawnChild("gale_eco_dome_room_waterpipes_waterdrops")
                    inst.fx_med.Transform:SetPosition(0,0.1,0)
                end
            elseif posi == 1 then
                if inst.fx_right then
                    inst.fx_right:KillFX()
                    inst.fx_right = nil 
                end
                if enable then
                    inst.fx_right = inst:SpawnChild("gale_eco_dome_room_waterpipes_waterdrops")
                    inst.fx_right.Transform:SetPosition(4.5,0.1,0)
                end
            end
        end

        

        inst:DoTaskInTime(0,function()
            inst:EnableFakeKey(not inst.HasDropped)
        end)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_eco_dome_room_waterpipes_leak",

    assets = {
        Asset("ANIM", "anim/boat_leak.zip"),
        Asset("ANIM", "anim/boat_leak_build.zip"),
    },
    bank = "boat_leak",
    build = "boat_leak_build",

    animover_remove = false,

    clientfn = function(inst)
        inst.AnimState:HideSymbol("leak_part")
        -- inst.AnimState:HideSymbol("fx_hit_parts")
        inst.AnimState:HideSymbol("shad")
    end,

    serverfn = function(inst)
        inst.size = nil 

        inst.SetSize = function(inst,size)
            inst.SoundEmitter:KillSound("loop")
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
            -- if size == "small" then
            --     inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "loop")
            -- elseif size == "med" then
            --     inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_medium_LP", "loop")
            -- end
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "loop")
            
            inst.AnimState:PlayAnimation("leak_"..size.."_pre")
            inst.AnimState:PushAnimation("leak_"..size.."_loop")
            inst.size = size
        end

        inst.KillFX = function(inst)
            inst.SoundEmitter:KillSound("loop")
            inst.AnimState:PlayAnimation("leak_"..inst.size.."_pst")
            inst:ListenForEvent("animover",inst.Remove)
        end
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_eco_dome_room_waterpipes_waterdrops",

    assets = {
        Asset("ANIM", "anim/sprinkler_fx.zip"),
    },
    bank = "sprinkler_fx",
    build = "sprinkler_fx",
    anim = "spray_loop",
    loop_anim = true,
    animover_remove = false,

    serverfn = function(inst)
        inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "loop")

        inst.AnimState:SetMultColour(0,0,0,0)
        inst.task = GaleCommon.FadeTo(inst,0.5,nil,{Vector4(0,0,0,0),Vector4(1,1,1,1)})
        inst.KillFX = function(inst)
            inst.SoundEmitter:KillSound("loop")
            if inst.task then
                KillThread(inst.task)
            end
            local r,g,b,a = inst.AnimState:GetMultColour()
            inst.task = GaleCommon.FadeTo(inst,0.5,nil,{Vector4(r,g,b,a),Vector4(0,0,0,0)},nil,inst.Remove)
        end
    end,
})