local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleComplexProjectile = require("util/gale_complexprojectile")
local GaleCondition = require("util/gale_conditions")
--

local function SpawnDrail(spawnpos)
    local trail = SpawnPrefab("damp_trail")
    trail.Transform:SetPosition(spawnpos:Get())
    trail:SetVariation(math.random(1, 7), 1 + math.random() * 0.55, GetRandomMinMax(6, 11))
    if trail:IsOnOcean() then
        -- trail.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        trail.AnimState:SetLayer(LAYER_BELOW_GROUND)
        trail.AnimState:SetSortOrder(3)
        trail.AnimState:SetFinalOffset(-1)
    end
end

local function OnProjectileLaunch(inst)
    GaleComplexProjectile.OnUpdate_Linear(inst)

    inst.removetask = inst:DoTaskInTime(5, function()
        inst.components.complexprojectile:Hit()
    end)

    inst:ListenForEvent("onremove", function()
                            inst:Remove()
                        end, inst.components.complexprojectile.attacker)
end

local function OnProjectileLaunchParacurve(inst)
    inst:ListenForEvent("onremove", function()
                            inst:Remove()
                        end, inst.components.complexprojectile.attacker)
end

local function ShouldHitWhenUpdate(inst)
    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    if y <= 0.05 then
        inst.components.complexprojectile:Hit()
        return
    end


    local ents = TheSim:FindEntities(x, y, z, 1.5, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(ents) do
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            inst.components.complexprojectile:Hit(v)
            break
        end
    end
end

local function OnProjectileUpdate(inst)
    GaleComplexProjectile.OnUpdate_Linear(inst)

    ShouldHitWhenUpdate(inst)

    inst.components.complexprojectile.horizontalSpeed = math.min(50,
                                                                 inst.components.complexprojectile.horizontalSpeed +
                                                                 FRAMES * 25)

    return true
end

local function OnProjectileHit(inst, other)
    local pos = inst:GetPosition()
    -- SpawnAt("gale_laser_explosion",Vector3(pos.x,math.max(0,pos.y - 0.4),pos.z))

    for i = 1, 4 do
        local offset = Vector3(UnitRand() * 2.5, 0, UnitRand() * 2.5)
        SpawnAt("galeboss_ruinforce_projectile_dark_hitsplit", inst, nil, offset)
        SpawnDrail(inst:GetPosition() + offset)
    end

    inst:SpawnChild("galeboss_explode_vfx_shadow_oneshoot")

    inst.SoundEmitter:PlaySound("gale_sfx/battle/explosion_4_wet")


    local attacker = inst.components.complexprojectile.attacker

    GaleCommon.AoeDestroyWorkableStuff(attacker, inst:GetPosition(), 3, 5)
    GaleCommon.AoeForEach(attacker, inst:GetPosition(), 3, nil, { "INLIMBO", },
                          { "_combat", "_inventoryitem" },
                          function(attacker, other)
                              if (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other)) then
                                  if not other:HasTag("epic") then
                                      GaleCondition.AddCondition(other, "condition_dread", 10)
                                  end
                                  other.components.combat:GetAttacked(attacker, 40)
                              elseif other.components.inventoryitem then
                                  GaleCommon.LaunchItem(other, inst, 5)
                              end
                          end, function(attacker, other)
                              -- Should not attack shadow creatures,unless they attack me
                              if GaleCommon.IsShadowCreature(other) and not (attacker.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(attacker))) then
                                  return false
                              end
                              return (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other))
                                  or other.components.inventoryitem
                          end)

    -- inst:Remove()
    inst.vfx:Remove()
    inst.Physics:Stop()
    inst:Hide()

    -- Delay remove to play sound
    inst:DoTaskInTime(1.5, inst.Remove)
end

return GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_ruinforce_projectile_dark",
        assets = {

        },

        clientfn = function(inst)
            MakeProjectilePhysics(inst)
        end,

        serverfn = function(inst)
            inst.persists = false

            inst.vfx = inst:SpawnChild("galeboss_ruinforce_projectile_dark_vfx")

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile.horizontalSpeed = 30
            inst.components.complexprojectile:SetLaunchOffset(Vector3(4, 5.5, 0))
            inst.components.complexprojectile.onupdatefn = OnProjectileUpdate
            inst.components.complexprojectile:SetOnHit(OnProjectileHit)
            inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_ruinforce_projectile_dark_paracurve",
        assets = {

        },

        clientfn = function(inst)
            MakeProjectilePhysics(inst)
        end,

        serverfn = function(inst)
            inst.persists = false

            inst.vfx = inst:SpawnChild("galeboss_ruinforce_projectile_dark_vfx")

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile.horizontalSpeed = 20
            inst.components.complexprojectile:SetGravity(-33)
            inst.components.complexprojectile:SetOnHit(OnProjectileHit)
            inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunchParacurve)
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "galeboss_ruinforce_projectile_dark_hitsplit",
        assets = {},
        bank = "Bubble_fx",
        build = "crab_king_bubble_fx",
        anim = "waterspout",

        clientfn = function(inst)
            inst.AnimState:SetMultColour(0, 0, 0, 0.66)
        end,
    })
