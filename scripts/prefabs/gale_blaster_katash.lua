local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleWeaponSkill = require("util/gale_weaponskill")

local assets = {
    Asset("ANIM", "anim/deer_fire_charge.zip"),
    Asset("ANIM", "anim/fireball_2_fx.zip"),

    Asset("ANIM", "anim/gale_blaster_katash.zip"),
    Asset("ANIM", "anim/swap_gale_blaster_katash.zip"),

    Asset("IMAGE", "images/inventoryimages/gale_blaster_katash.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_blaster_katash.xml"),
}

local BLASTER_MIN_DAMAGE = 10
local BLASTER_MAX_DAMAGE = 30
local SURGE_DAMAGE_BONUS = 20

local BLASTER_SKILL_MIN_DAMAGE = 20
local BLASTER_SKILL_MAX_DAMAGE = 30

local function ProjectileGetDamageFn(inst, attacker, target)
    return GetRandomMinMax(BLASTER_MIN_DAMAGE, BLASTER_MAX_DAMAGE + (inst.surge_count or 0) * SURGE_DAMAGE_BONUS)
end

local function ProjectileBigGetDamageFn(inst, attacker, target)
    return GetRandomMinMax(BLASTER_SKILL_MIN_DAMAGE, BLASTER_SKILL_MAX_DAMAGE) + (inst.bonus_damage or 0)
end


return GaleEntity.CreateNormalWeapon({
        prefabname = "gale_blaster_katash",
        assets = assets,
        tags = { "gale_blaster", "hide_percentage" },

        bank = "gale_blaster_katash",
        build = "gale_blaster_katash",
        anim = "idle",

        inventoryitem_data = {
            imagename = "gale_blaster_katash",
            atlasname = "gale_blaster_katash",
            use_gale_item_desc = true,
        },

        equippable_data = {
            onequip_priority = {
                {
                    function(inst, owner)
                        local defence = inst.components.gale_blaster_charge:GetEmptyCharge() * 0.1
                        owner.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 1 - defence, inst
                            .prefab)
                    end,
                    1,
                }

            },

            onunequip_priority = {
                {
                    function(inst, owner)
                        owner.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst, inst.prefab)
                    end,
                    1
                },

            },
        },

        weapon_data = {
            damage = 0,
            ranges = { 12, 18 },
            swapanims = { "swap_gale_blaster_katash", "swap_gale_blaster_katash" },
        },

        clientfn = function(inst)
            inst.projectiledelay = 4 * FRAMES
            inst.shoot_sound = "gale_sfx/battle/kobold_shotty"
            inst.shoot_sound_skill = "gale_sfx/battle/p1_katash_gun2"

            GaleWeaponSkill.AddAoetargetingClient(inst, "line", nil, 15)
        end,

        serverfn = function(inst)
            inst.last_shoot_scale = 1

            inst.components.equippable.restrictedtag = "gale"

            inst.components.weapon:SetProjectile("gale_fake_projectile")
            inst.components.weapon:SetOnProjectileLaunch(function(inst, attacker, target)
                local face_vec = GaleCommon.GetFaceVector(attacker)
                local cross_vec = face_vec:Cross(Vector3(0, 1, 0)):GetNormalized()

                SpawnAt("gale_hand_shoot_fx", attacker).Transform:SetRotation(attacker.Transform:GetRotation())

                attacker:StartThread(function()
                    local start_angle = -45 / 2 * inst.last_shoot_scale
                    local stop_angle = 45 / 2 * inst.last_shoot_scale
                    local delta = (math.abs(start_angle) + math.abs(stop_angle)) / 4 * inst.last_shoot_scale
                    for i = start_angle, stop_angle, delta do
                        if attacker.sg and attacker.sg:HasStateTag("attack") then
                            local tar_pos = attacker:GetPosition() + face_vec + cross_vec * math.tan(i * DEGREES)
                            local proj = SpawnAt("gale_blaster_katash_projectile", attacker)

                            -- local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
                            -- if room then
                            --     proj.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
                            -- end
                            proj.surge_count = inst.components.gale_blaster_charge:GetSurge()
                            proj.components.complexprojectile:Launch(tar_pos, attacker, inst)
                            proj:Hide()
                            Sleep(0)
                        else
                            break
                        end
                    end
                    inst.last_shoot_scale = -inst.last_shoot_scale
                end)
            end)

            inst:AddComponent("gale_blaster_charge")

            -- inst:AddComponent("armor")
            -- inst.components.armor:InitIndestructible(0)


            GaleWeaponSkill.AddAoetargetingServer(inst, function(inst, doer, pos)
                local deltaed = math.abs(inst.components.gale_blaster_charge:DoDeltaCharge(-2))
                -- print("deltaed:",deltaed)
                local proj = SpawnAt("gale_blaster_katash_projectile_super", doer)
                -- local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
                -- if room then
                --     proj.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
                -- end

                proj.bonus_damage = deltaed * 50
                proj.components.complexprojectile:Launch(pos, doer, inst)
                proj:Hide()

                SpawnAt("gale_hand_shoot_fx", doer).Transform:SetRotation(doer.Transform:GetRotation())

                if deltaed == 0 then
                    inst.components.rechargeable:Discharge(5)
                end

                if doer.components.gale_stamina then
                    doer.components.gale_stamina:DoDelta(-20)
                    doer.components.gale_stamina:Pause(3)
                end
            end)

            inst:ListenForEvent("chargedelta", function(inst, data)
                -- inst.components.armor:InitIndestructible(inst.components.gale_blaster_charge:GetEmptyCharge() * 0.12)
                -- if not inst.components.gale_blaster_charge:IsFull() then
                --     inst:AddTag("parrying_hit_weapon")
                -- else
                --     inst:RemoveTag("parrying_hit_weapon")
                -- end

                local owner = inst.components.inventoryitem.owner
                if inst.components.equippable:IsEquipped() and owner then
                    local defence = inst.components.gale_blaster_charge:GetEmptyCharge() * 0.1
                    owner.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 1 - defence, inst.prefab)
                end
            end)
        end,

    }),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_blaster_katash_projectile_hitfx",
        assets = assets,

        bank = "deer_fire_charge",
        build = "deer_fire_charge",
        anim = "blast",

        clientfn = function(inst)
            inst.AnimState:SetScale(0.5, 0.5, 0.5)
            inst.AnimState:SetLightOverride(1)
        end,

        serverfn = function(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_kobold_bullet_impact")
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "gale_blaster_katash_projectile",
        assets = assets,
        tags = { "NOCLICK" },

        bank = "projectile",
        build = "staff_projectile",
        anim = "fire_spin_loop",
        loop_anim = true,

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.AnimState:SetLightOverride(1)
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
            inst.components.complexprojectile:SetHorizontalSpeed(20)
            inst.components.complexprojectile.onupdatefn = function(inst)
                inst.max_range = inst.max_range or GetRandomMinMax(12, 25)
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
                    inst.tail = inst:SpawnChild("gale_blaster_katash_projectile_tail_vfx")
                    inst.tail.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
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

            inst.components.complexprojectile:SetOnHit(function(inst, attacker, target)
                if target and attacker and attacker:IsValid() and attacker.components.combat then
                    -- print("gale_blaster_katash_projectile",attacker,target)
                    attacker.components.combat:DoAttack(target, inst, inst, nil, nil, 99999)
                end

                SpawnAt("gale_hit_spark_yellow_fx", inst)

                inst:Remove()
            end)
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "gale_blaster_katash_projectile_super",
        assets = assets,
        tags = { "NOCLICK" },

        bank = "projectile",
        build = "staff_projectile",
        anim = "fire_spin_loop",
        loop_anim = true,

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.AnimState:SetLightOverride(1)
        end,

        serverfn = function(inst)
            inst.Physics:SetCollisionCallback(function(inst, other)
                if other and other.prefab == "gale_polygon_physics" and not inst.collide then
                    inst.collide = true
                    inst.components.complexprojectile:Hit(other)
                end
            end)

            inst:AddComponent("weapon")
            inst.components.weapon:SetDamage(ProjectileBigGetDamageFn)

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile:SetHorizontalSpeed(8)
            inst.components.complexprojectile.onupdatefn = function(inst)
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

                if inst.entity:IsVisible() and inst.components.complexprojectile.horizontalSpeed <= 50 then
                    inst.components.complexprojectile:SetHorizontalSpeed(inst.components.complexprojectile
                        .horizontalSpeed + FRAMES * 50)
                end

                if not inst.bigball then
                    inst.bigball = inst:SpawnChild("gale_blaster_katash_projectile_bigballanim")
                    inst.bigball.entity:AddFollower()
                    inst.bigball.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
                end

                if inst.entity:IsVisible() and not inst.tail then
                    inst.tail = inst:SpawnChild("gale_blaster_katash_projectile_tail_vfx")
                    inst.tail._sphere_emitter_rad:set(1)
                    inst.tail.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
                end

                inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


                local attacker = inst.components.complexprojectile.attacker
                local x, y, z = inst.Transform:GetWorldPosition()

                local ents = TheSim:FindEntities(x, y, z, 1.75, { "_combat", "_health" }, { "INLIMBO" })
                for k, v in pairs(ents) do
                    if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
                        inst.components.complexprojectile:Hit(v)
                        break
                    end
                end

                return true
            end

            inst.components.complexprojectile:SetOnHit(function(inst, attacker, target)
                inst:Show()

                GaleCommon.AoeForEach(
                    attacker,
                    inst:GetPosition(),
                    3.5,
                    nil,
                    { "INLIMBO" },
                    { "_combat", "_inventoryitem" },
                    function(attacker, v)
                        -- if attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
                        if v.components.combat and attacker:IsValid() then
                            attacker.components.combat:DoAttack(v, inst, inst, nil, nil, 99999)
                            v:PushEvent("knockback",
                                        { knocker = inst, radius = GetRandomMinMax(1.2, 1.4) + v:GetPhysicsRadius(.5) })
                        elseif v.components.inventoryitem then
                            GaleCommon.LaunchItem(v, inst, 5)
                        end
                    end,
                    function(inst, v)
                        local is_combat = v.components.combat and v.components.health and
                            not v.components.health:IsDead()
                            and not (v.sg and v.sg:HasStateTag("dead"))
                            and not v:HasTag("playerghost")
                        local is_inventory = v.components.inventoryitem
                        return v and v:IsValid()
                            and (is_combat or is_inventory or v.components.workable)
                    end
                )

                if inst.tail then
                    inst.tail:Remove()
                    inst.tail = nil
                end

                if inst.bigball then
                    inst.bigball.AnimState:PlayAnimation("impact")
                    inst.bigball:ListenForEvent("animover", inst.bigball.Remove)
                    inst.bigball = nil
                end

                inst.AnimState:SetMultColour(0, 0, 0, 0)

                inst.hitfx = inst:SpawnChild("gale_fire_explode_vfx")
                inst.hitfx.entity:AddFollower()
                inst.hitfx.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)

                inst.SoundEmitter:PlaySound("gale_sfx/battle/explode")
                inst.SoundEmitter:PlaySound("gale_sfx/battle/active_grenade_fire")

                ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)

                inst:DoTaskInTime(1, inst.Remove)
            end)
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_blaster_katash_projectile_bigballanim",
        assets = assets,

        bank = "metal_hulk_projectile",
        build = "metal_hulk_projectile",
        anim = "spin_loop",
        loop_anim = true,
        animover_remove = false,


        clientfn = function(inst)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetAddColour(0.8, 0.66, 0.1, 1)
            inst.Transform:SetScale(0.8, 0.8, 0.8)
        end,

        serverfn = function(inst)

        end,
    })
