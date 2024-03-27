local GaleEntity = require("util/gale_entity")

local function ProjectileGetDamageFn(inst, attacker, target)
    local min_damage = 34
    local max_damage = 42

    local dist = (inst:GetPosition() - inst.start_pos):Length()

    if dist <= 10 then
        return max_damage
    elseif dist <= 20 then
        return Remap(dist, 10, 20, max_damage, min_damage)
    else
        return min_damage
    end
end

local function ProjectileOnUpdate(inst)
    inst.max_range = inst.max_range or GetRandomMinMax(20, 25)
    inst.start_pos = inst.start_pos or inst:GetPosition()

    local dist_moved = (inst:GetPosition() - inst.start_pos):Length()
    if dist_moved >= inst.max_range then
        inst.components.complexprojectile:Hit()
        return true
    else
        if dist_moved >= 0.66 then
            inst:Show()
        else
            inst:Hide()
        end
    end

    if inst.entity:IsVisible() and not inst.tail then
        inst.tail = inst:SpawnChild("msf_ammo_9mm_pistol_projectile_tail_vfx")
        inst.tail.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
    end

    if inst.entity:IsVisible() and not inst.arrow then
        inst.arrow = inst:SpawnChild("msf_ammo_9mm_pistol_projectile_arrow")
        inst.arrow.entity:AddFollower()
        inst.arrow.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 1, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(ents) do
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            inst.components.complexprojectile:Hit(v)
            break
        end
    end

    return true
end

local function ProjectileOnHit(inst, attacker, target)
    if target and attacker and attacker:IsValid() and attacker.components.combat then
        attacker.components.combat:DoAttack(target, inst, inst, nil, nil, 99999)
    end

    SpawnAt("gale_hit_spark_yellow_fx", inst)

    inst:Remove()
end

return GaleEntity.CreateNormalInventoryItem({
        prefabname = "msf_ammo_9mm_pistol",
        assets = {
            Asset("ANIM", "anim/msf_ammo_9mm_pistol.zip"),
            Asset("IMAGE", "images/inventoryimages/msf_ammo_9mm_pistol.tex"),
            Asset("ATLAS", "images/inventoryimages/msf_ammo_9mm_pistol.xml"),
        },

        bank = "msf_ammo_9mm_pistol",
        build = "msf_ammo_9mm_pistol",
        anim = "idle",

        tags = { "msf_ammo_pistol", "msf_ammo" },

        serverfn = function(inst)
            inst:AddComponent("reloaditem")

            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "msf_ammo_9mm_pistol_projectile",
        assets = {
            Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
        },
        tags = { "NOCLICK" },

        bank = "projectile",
        build = "staff_projectile",
        anim = "fire_spin_loop",
        loop_anim = true,

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.AnimState:SetMultColour(0, 0, 0, 0)
        end,

        serverfn = function(inst)
            inst.Physics:SetCollisionCallback(function(inst, other)
                if other and other.prefab == "gale_polygon_physics" and not inst.collide then
                    inst.collide = true
                    inst.components.complexprojectile:Hit(other)
                end
            end)

            inst:AddComponent("weapon")
            inst.components.weapon:SetDamage(ProjectileGetDamageFn)

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile:SetHorizontalSpeed(34)
            inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
            inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "msf_ammo_9mm_pistol_projectile_arrow",
        assets = {
            Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
        },
        bank = "lavaarena_blowdart_attacks",
        build = "lavaarena_blowdart_attacks",
        anim = "attack_3",

        loop_anim = true,
        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetAddColour(1, 1, 0, 0)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end,

        serverfn = function(inst)

        end,
    })
