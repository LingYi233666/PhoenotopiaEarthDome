local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

SetSharedLootTable("galeboss_dragon_snare",
{
    
    {"plantmeat",                1.00},
    {"plantmeat",                1.00},
    {"plantmeat",                1.00},
    {"plantmeat",                0.5},
    {"plantmeat",                0.5},
    {"plantmeat",                0.25},
})

local function CheckUnderground(inst)
    if inst.sg:HasStateTag("underground") then
        inst.components.health:SetInvincible(true)

        inst.Physics:ClearCollisionMask()
        if inst.Physics:GetMass() > 0 then
            inst.Physics:CollidesWith(COLLISION.GROUND)
        end

        if not inst.components.combat.target then
            inst:SetMusicLevel(1)
        end
    else 
        inst.components.health:SetInvincible(false)

        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)

        if not GaleCommon.IsTruelyDead(inst) then
            inst:SetMusicLevel(2)
        else 
            inst:SetMusicLevel(1)
        end
        
    end
end

local function PlantRetarget(inst)
    local dist = 20
    if inst.sg:HasStateTag("idle") and inst.sg:HasStateTag("invisible") then
        dist = 4
    end
    return FindEntity(
        inst,
        dist,
        function(guy)
            return guy ~= inst
                and not guy.components.health:IsDead()
        end,
        { "_combat", "_health","character" },
        { "INLIMBO","galeboss_dragon_snare","galeboss_dragon_snare_token"}
    )
    
end

local function PlantKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.entity:IsVisible()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target:IsNear(inst, 25)
end

local function CustomFoodvalFn(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
    if health_delta < 33 then
        if not food:HasTag("explosive") and not food.components.explosive then
            health_delta = 33
        end
        
    else
        health_delta = health_delta * 5
    end

    return health_delta,hunger_delta,sanity_delta
end

local function OnSave(inst,data)
    data.style = inst.style 
end

local function OnLoad(inst,data)
    if data ~= nil then
        if data.style ~= nil then
            inst.style = data.style
        end
    end

    if inst.style == "TENTACLE" then
        inst.sg:GoToState("attack_using_moving_tentacle")
    elseif inst.style == "BABYPLANT" then
        inst.sg:GoToState("attack_using_babyplant")
    end
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_dragon_snare",
    assets = {
        Asset("ANIM", "anim/eyeplant_trap.zip"),
        Asset("ANIM", "anim/galeboss_dragon_snare.zip"),
        Asset("ANIM", "anim/meat_rack_food.zip"),
    },

    tags = {"monster","galeboss_dragon_snare","veggie","scarytoprey"},

    bank = "eyeplant_trap",
    build = "eyeplant_trap",
    anim = "idle",
    loop_anim = true,

    clientfn = function(inst)
        local s = 1.5
        inst.AnimState:SetScale(s,s,s)

        MakeObstaclePhysics(inst,1.3)

        -- inst.AnimState:HideSymbol("tenticle")

        GaleCommon.AddEpicBGM(inst,"galeboss_dragon_snare")

        inst.AnimState:OverrideSymbol("bulb_leaf","galeboss_dragon_snare","bulb_leaf")
        inst.AnimState:OverrideSymbol("swap_dried","galeboss_dragon_snare_small_flower","swap_flower2")
    end,


    serverfn = function(inst)

        -- style is used in SG
        inst.style = nil 

        inst.EnableRoot = function(inst,enable)
            for i = 1,4 do
                if enable then
                    inst.AnimState:ShowSymbol("vine"..i)
                else 
                    inst.AnimState:HideSymbol("vine"..i)
                end
            end

            inst.root_enabled = enable
        end

        inst.EnableFlower = function(inst,enable)
            if inst.flower ~= nil and not enable then
                inst.flower:Remove()
                inst.flower = nil 
            elseif inst.flower == nil and enable then
                inst.flower = inst:SpawnChild("galeboss_dragon_snare_small_flower")
                inst.flower.AnimState:SetMultColour(0,0,0,0)
                inst.flower.Transform:SetScale(0,0,0)

                GaleCommon.FadeTo(inst.flower,0.33,{
                    Vector3(0,0,0),
                    Vector3(1,1,1),
                },{
                    Vector4(0,0,0,0),
                    Vector4(1,1,1,1),
                })
            end
        end



        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        inst.CheckUnderground = CheckUnderground

        inst:AddComponent("inspectable")

        inst:AddComponent("epicscare")
        inst.components.epicscare:SetRange(12)

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aurafn = function(inst, observer)
            if inst.sg and inst.sg:HasStateTag("invisible") then
                return 0
            end

            return -TUNING.SANITYAURA_MED
        end

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1350)
        inst.components.health.destroytime = 14

        inst:AddComponent("combat")
        inst.components.combat:SetRetargetFunction(1, PlantRetarget)
        inst.components.combat:SetKeepTargetFunction(PlantKeepTarget)

        -- c_findnext("galeboss_dragon_snare").components.galeboss_skill_summon_minion
        -- Used for summoning tentacles and baby-plants
        inst:AddComponent("galeboss_skill_summon_minion")

        -- Dragon Snare can eat food captured by her babies
        inst:AddComponent("eater")
        inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
        inst.components.eater:SetCanEatHorrible()
        inst.components.eater:SetCanEatRaw()
        inst.components.eater:SetStrongStomach(true) 
        inst.components.eater.custom_stats_mod_fn = CustomFoodvalFn

        -- Store foods
        inst:AddComponent("inventory")

        -- Babies can give item to Dragon Snare
        inst:AddComponent("trader")
        inst.components.trader.deleteitemonaccept = false
        inst.components.trader:SetAbleToAcceptTest(function(inst,item,giver)
            return giver and inst.components.galeboss_skill_summon_minion:IsMyMinion(giver)
        end)

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable("galeboss_dragon_snare")
        inst.components.lootdropper.min_speed = 0
        inst.components.lootdropper.max_speed = 3
        inst.components.lootdropper.y_speed = 33
        inst.components.lootdropper.y_speed_variance = 3

        

        inst:SetStateGraph("SGgaleboss_dragon_snare")

        inst:ListenForEvent("newstate",CheckUnderground)
        inst:ListenForEvent("death",function()
            for ent,_ in pairs(inst.components.galeboss_skill_summon_minion.minions) do
                if ent.prefab == "galeboss_dragon_snare_moving_tentacle" then
                    ent:PushEvent("disappear")
                end
            end
            inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_DEATH",false)
        end)
        inst:ListenForEvent("onremove",function()
            for ent,_ in pairs(inst.components.galeboss_skill_summon_minion.minions) do
                if ent.prefab == "galeboss_dragon_snare_moving_tentacle" then
                    ent:PushEvent("disappear")
                end
            end
            inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_REMOVE",false)
        end)
        -- Once lost combat target, disable th BGM
        inst:ListenForEvent("droppedtarget",function()
            inst:SetMusicLevel(1)
        end)

        inst:DoTaskInTime(0,function()
            inst:EnableFlower(inst.sg:HasStateTag("invisible"))
            inst:CheckUnderground()
        end)
    end,


}),
GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_dragon_snare_small_flower",
    assets = {
        Asset("ANIM", "anim/eyeplant_trap.zip"),
        Asset("ANIM", "anim/meat_rack_food.zip"),
        Asset("ANIM", "anim/galeboss_dragon_snare_small_flower.zip"),
        
    },
    tags = {"flower","cattoy"},

    -- bank = "flowers",
    -- build = "flowers",
    -- anim = function(inst)
    --     local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}
    --     return names[math.random(#names)]
    -- end,

    bank = "galeboss_dragon_snare_small_flower",
    build = "galeboss_dragon_snare_small_flower",
    anim = "idle",
    loop_anim = true,

    persists = false,

    clientfn = function(inst)
        local s = 0.8
        inst.AnimState:SetScale(s,s,s)
        inst:SetPrefabNameOverride("flower")

        -- inst.AnimState:SetRayTestOnBB(true)
    end,


    serverfn = function(inst)
        inst:AddComponent("inspectable")

        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_dragon_snare_sand_spike",
    assets = {
        Asset("ANIM", "anim/sand_spike.zip"),
        Asset("ANIM", "anim/galeboss_dragon_snare_sand_spike.zip"),
        Asset("ANIM", "anim/sand_splash_fx.zip"),

        
    },

    tags = {"galeboss_dragon_snare_token","groundspike"},

    bank = "sand_spike",
    build = "sand_spike",
    anim = "anim",

    persists = false,

    clientfn = function(inst)
        -- inst.AnimState:SetScale(1.5,2.5,1)
        -- inst.AnimState:SetMultColour(255/255,122/255,0,1)

        -- inst.AnimState:SetFinalOffset(2)

        inst.entity:AddPhysics()

        inst.AnimState:OverrideSymbol("sand_splash", "sand_splash_fx", "sand_splash")
        -- inst.AnimState:OverrideSymbol("sand_splash", "lavaarena_boarrior_fx", "dust")
        inst.AnimState:OverrideSymbol("sand_spike_01","galeboss_dragon_snare_sand_spike","sand_spike_01")

        inst.AnimState:SetSymbolMultColour("sand_splash",255/255,122/255,0,1)
        inst.AnimState:SetSymbolMultColour("sand_fill",84/255,59/255,0,1)
        
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        -- inst.AnimState:SetSortOrder(2)

        inst.Physics:SetMass(999999)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:SetActive(false)
        inst.Physics:SetCapsule(0.2, 2)

        inst._physics_radius = net_float(inst.GUID,"inst._physics_radius","physics_radius_dirty")

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("physics_radius_dirty",function()
                inst.Physics:SetCapsule(inst._physics_radius:value(), 2)
            end)
        end
    end,

    serverfn = function(inst)
        inst.size = "med"

        -- size: short,med,tall
        -- c_spawn("galeboss_dragon_snare_sand_spike"):SetSize("tall")
        -- galetestmen.size={1.2,3,1} c_spawn("galeboss_dragon_snare_sand_spike"):SetSize("tall")
        inst.SetSize = function(inst,size)
            local damages = {
                short = 66,
                med = 90,
                tall = 130,
            }
            local ranges = {
                short = 0.7,
                med = 0.9,
                tall = 1.1,
            }

            inst.size = size 

            inst.Physics:SetCapsule(ranges[size] - 0.5, 2)
            inst._physics_radius:set(ranges[size] - 0.5)

            inst.components.combat:SetDefaultDamage(damages[size])
            inst.components.combat:SetRange(ranges[size])

            inst.AnimState:SetDeltaTimeMultiplier(1.5)
            inst.AnimState:PlayAnimation(inst.size.."_pre")
            -- inst.AnimState:SetMultColour(255/255,122/255,0,1)
        end

        inst:AddComponent("combat")
        inst.components.combat.playerdamagepercent = 0.5


        inst:ListenForEvent("animover",function(inst)
            local fx_scale = {
                short = {},
                med = {},
                tall = {1.2,3,1},
            }
            -- local size = galetestmen.size 
            if inst.AnimState:IsCurrentAnimation(inst.size.."_pre") then
                local x, y, z = inst.Transform:GetWorldPosition()
                local range = inst.components.combat.hitrange
                local ents = TheSim:FindEntities(x, 0, z, range, {"_combat","_health"}, {"INLIMBO","galeboss_dragon_snare","galeboss_dragon_snare_token"})
                for k, v in pairs(ents) do
                    inst.components.combat:DoAttack(v)
                end

                inst.Physics:SetActive(true)
                inst.AnimState:SetLayer(LAYER_WORLD)
                inst.AnimState:SetDeltaTimeMultiplier(2)
                inst.AnimState:PlayAnimation(inst.size.."_pst")

                inst.SoundEmitter:PlaySound(
                    "dontstarve/creatures/together/antlion/sfx/break",
                    nil,
                    (inst.size == "short" and .6) or
                    (inst.size == "med" and .8) or
                    nil
                )

                
            elseif inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation(inst.size.."_pst") then
                inst.AnimState:SetDeltaTimeMultiplier(1)
                inst.Physics:SetActive(false)
                inst.AnimState:PlayAnimation(inst.size.."_break")

                inst.SoundEmitter:PlaySound(
                    "dontstarve/creatures/together/antlion/sfx/break_spike",
                    nil,
                    (inst.size == "short" and .6) or
                    (inst.size == "med" and .8) or
                    nil
                )


            elseif inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation(inst.size.."_break") then
                inst:Remove()
            end
        end)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "galeboss_dragon_snare_sand_splash_fx",
    assets = {
        Asset("ANIM", "anim/teleport_sand_fx.zip"),
        Asset("ANIM", "anim/sand_splash_fx.zip"),
        Asset("ANIM", "anim/lavaarena_boarrior_fx.zip"),
        -- Asset("ANIM", "anim/galeboss_dragon_snare_sand_splash_fx.zip"),
        
    },

    bank = "sand_splash_fx",
    build = "sand_splash_fx",
    anim = "idle",

    clientfn = function(inst)
        inst.AnimState:SetScale(1.5,2.5,1)
        inst.AnimState:SetMultColour(255/255,122/255,0,1)

        inst.AnimState:SetFinalOffset(3)
    end,
})