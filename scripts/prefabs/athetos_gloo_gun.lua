local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local OBSTACLE_WORKLEFT = 3

local function FreeShootFn(inst,attacker,targetpos)
    SpawnAt("gale_hand_shoot_fx",attacker).Transform:SetRotation(attacker.Transform:GetRotation())
    SpawnAt("athetos_gloo_gun_projectile",attacker):DoLaunch(attacker,targetpos)

    return true 
end

local function WeaponOnLaunchedProjectile(inst,attacker,target)
    FreeShootFn(inst,attacker,target:GetPosition())
end

local function OnProjCollide(inst, other)
    -- inst.components.complexprojectile:Hit(other)
    print("OnProjCollide",other)
    if inst:IsOnOcean() then
        if inst:GetPosition().y < 0.1 then
            SpawnAt("crab_king_waterspout", inst).Transform:SetScale(1, 0.7, 0.7)
            inst:Remove()
        else 

        end
    else
        if inst:GetPosition().y < 0.1 then
            local pos = inst:GetPosition()
            pos.y = 0
            SpawnAt("athetos_gloo_gun_obstacle", pos):DoGrow()
            inst:Remove()
        else

        end
    end

    
end

local function OnProjectileLaunch(inst)
    inst:DoTaskInTime(1, function()
        inst.components.complexprojectile:SetGravity(-9.8)
    end)
end

local function OnProjectileHit(inst,other)
    if inst:IsOnOcean() then
        if inst:GetPosition().y < 0.1 then
            SpawnAt("crab_king_waterspout", inst).Transform:SetScale(1, 0.7, 0.7)
        end
    else
        if inst:GetPosition().y < 0.1 then
            SpawnAt("athetos_gloo_gun_obstacle", inst):DoGrow()
        end
    end

    inst:Remove()
end

local function OnObstacleWork(inst, worker, workleft)
    if workleft <= 0 then
        SpawnAt("rock_break_fx", inst)
        inst:Remove()
    else
        inst.AnimState:PlayAnimation(
            (workleft < OBSTACLE_WORKLEFT / 3 and "low") or
                (workleft < OBSTACLE_WORKLEFT * 2 / 3 and "med") or "full")
    end
end

return 
GaleEntity.CreateNormalWeapon({
    prefabname = "athetos_gloo_gun",
    assets = {
        -- Asset("ANIM", "anim/athetos_gloo_gun.zip"), 
        -- Asset("ANIM", "anim/swap_athetos_gloo_gun.zip"), 
        -- Asset("IMAGE","images/inventoryimages/athetos_gloo_gun.tex"),
        -- Asset("ATLAS","images/inventoryimages/athetos_gloo_gun.xml"),
    },

    tags = {"gale_blaster","allow_action_on_impassable"},

    bank = "msf_silencer_pistol",
    build = "msf_silencer_pistol",
    anim = "idle",

    inventoryitem_data = {
        imagename = "msf_silencer_pistol",
        atlasname = "msf_silencer_pistol",
    },

    equippable_data = {
        onequip_priority = {
            {
                function (inst,owner)
                    if owner.components.combat then
                        owner.components.combat:SetAttackPeriod(FRAMES)
                    end
                    

                end,
                1,
            }
            
        },

        onunequip_priority = {
            {
                function (inst,owner)
                    if owner.components.combat then
                        owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
                    end
                    

                end,
                1
            },
            
        }, 
    },

    weapon_data = {
        swapanims = {"swap_msf_silencer_pistol","swap_msf_silencer_pistol"},
        damages = 0,
        ranges = 20,
    },

    

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst:AddComponent("gale_blaster_freeshoot")
        inst.components.gale_blaster_freeshoot.shootfn = FreeShootFn

        inst.components.weapon.attackwear = 0
        inst.components.weapon:SetProjectile("gale_fake_projectile")
        inst.components.weapon:SetOnProjectileLaunched(WeaponOnLaunchedProjectile)
    end,
}),
-- SpawnAt("athetos_gloo_gun_projectile",ThePlayer).components.complexprojectile:Launch(TheInput:GetWorldPosition(),ThePlayer)
-- SpawnAt("athetos_gloo_gun_projectile",ThePlayer):DoLaunch(ThePlayer,TheInput:GetWorldPosition())
GaleEntity.CreateNormalEntity({
    prefabname = "athetos_gloo_gun_projectile",
    assets = {
        -- Asset("ANIM", "anim/athetos_gloo_gun.zip"), 
        -- Asset("ANIM", "anim/swap_athetos_gloo_gun.zip"), 

        -- Asset("IMAGE","images/inventoryimages/athetos_gloo_gun.tex"),
        -- Asset("ATLAS","images/inventoryimages/athetos_gloo_gun.xml"),
    },

    bank = "winona_catapult_projectile",
    build = "winona_catapult_projectile",
    anim = "air",

    loop_anim = true,
    persists = false,

    clientfn = function(inst)
        -- inst.entity:AddPhysics()

        -- inst.Physics:SetMass(1)
        -- inst.Physics:SetFriction(10)
        -- inst.Physics:SetDamping(5)
        -- inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
        -- inst.Physics:ClearCollisionMask()
        -- inst.Physics:CollidesWith(COLLISION.GROUND)
        -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        -- -- inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        -- inst.Physics:SetCapsule(0.02, 0.02)

        MakeProjectilePhysics(inst,1,0.02)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)

        inst.Transform:SetSixFaced()
    end,

    serverfn = function(inst)
        inst.Physics:SetCollisionCallback(OnProjCollide)

        inst.DoLaunch = function(inst, attacker, targetpos)
            local direction_vec =
                (targetpos - attacker:GetPosition()):GetNormalized()
            local spawnpos = attacker:GetPosition() + direction_vec +
                                 Vector3(0, 1.75, 0)

            inst.Transform:SetPosition(spawnpos:Get())
            inst:ForceFacePoint(spawnpos + direction_vec)

            -- local vel = direction_vec * 15 + Vector3(0,7,0)
            -- inst.Physics:SetVel(vel:Get())

            local hor_speed = 15
            local GRAV = -36.66
            local dist = VecUtil_Dist(spawnpos.x,spawnpos.z,targetpos.x,targetpos.z)
            local move_time = dist / hor_speed
            local y_dist = targetpos.y - spawnpos.y 
            local vy = (y_dist - 0.5 * GRAV * move_time * move_time) / move_time
            vy = math.min(15,vy)

            local vel = direction_vec * hor_speed + Vector3(0,vy,0)
            inst.Physics:SetVel(vel:Get())

            inst:DoPeriodicTask(0,function()
                if inst:GetPosition().y <= 0.05 then
                    if inst:IsOnOcean() then
                        SpawnAt("crab_king_waterspout", inst).Transform:SetScale(1, 0.7, 0.7)
                    else
                        local pos = inst:GetPosition()
                        pos.y = 0
                        SpawnAt("athetos_gloo_gun_obstacle", pos):DoGrow()
                    end
                    inst:Remove()
                end
            end)

            inst:DoTaskInTime(10,inst.Remove)
        end

        -- inst:AddComponent("complexprojectile")
        -- inst.components.complexprojectile:SetOnHit(OnProjectileHit)
        -- inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
        -- inst.components.complexprojectile:SetHorizontalSpeed(20)
        -- inst.components.complexprojectile:SetGravity(-0.1)
        -- inst.components.complexprojectile:SetLaunchOffset(Vector3(1, 1.75, 0))
        -- inst.components.complexprojectile:SetTargetOffset(Vector3(-0.5, 0.5, 0))
        -- inst.components.complexprojectile.usehigharc = false


    end
}), 
GaleEntity.CreateNormalEntity({
    prefabname = "athetos_gloo_gun_obstacle",
    assets = {},

    bank = "rock5",
    build = "rock7",
    anim = "full",

    clientfn = function(inst) 
        MakeObstaclePhysics(inst, 1) 
    end,

    serverfn = function(inst)
        inst.DoGrow = function(inst)
            GaleCommon.FadeTo(inst, 0.66, {Vector3(0, 0, 0), Vector3(1, 1, 1)})
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(OBSTACLE_WORKLEFT)
        inst.components.workable:SetOnWorkCallback(OnObstacleWork)
    end
})
