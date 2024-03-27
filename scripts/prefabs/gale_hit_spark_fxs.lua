local GaleEntity = require("util/gale_entity")


return GaleEntity.CreateNormalFx({
    prefabname = "gale_hit_spark_yellow_fx",
    assets = {
        Asset("ANIM", "anim/gale_fx_indicator.zip"),
    },

    bank = "gale_fx_indicator",
    build = "gale_fx_indicator",
    anim = "med",

    animover_remove = false,

    clientfn = function(inst)
        inst.AnimState:SetMultColour(0,0,0,0)

        if not TheNet:IsDedicated() then
            local blast = GaleEntity.CreateClientAnim({
                bank = "deer_fire_charge",
                build = "deer_fire_charge",
                anim = "blast",
            })
            blast.AnimState:SetLightOverride(1)
            blast.AnimState:SetScale(0.5,0.5,0.5)

            blast.entity:AddFollower()
    
            inst:AddChild(blast)
            blast.Follower:FollowSymbol(inst.GUID,"glow", 0, 0, 0)

            
        end

    end,

    serverfn = function(inst)
        inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_kobold_bullet_impact")

        local vfx = inst:SpawnChild("gale_quick_spark_vfx")
        vfx.entity:AddFollower()
        vfx.Follower:FollowSymbol(inst.GUID,"glow", 0, 0, 0)

        -- vfx:DoTaskInTime(3 * FRAMES,function ()
        --     vfx._trigger:push()
        -- end)
        

        inst:DoTaskInTime(2,inst.Remove)
    end,
}) 

-- local fx=ThePlayer:SpawnChild("gale_quick_spark_vfx") fx.entity:AddFollower() fx.Follower:FollowSymbol(ThePlayer.GUID,"swap_object", 0, 0, 0)