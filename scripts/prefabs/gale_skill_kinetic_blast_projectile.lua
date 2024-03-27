local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
-- local GaleComplexProjectile = require("util/gale_complexprojectile")

local function GetDamageFn(inst, attacker, target)
    return GetRandomMinMax(inst.damages[1], inst.damages[2])
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_skill_kinetic_blast_projectile",
    assets = {
        Asset("ANIM", "anim/star_cold.zip"),
        Asset("ANIM", "anim/staff_projectile.zip"),

    },

    bank = "projectile",
    build = "staff_projectile",
    anim = "fire_spin_loop",
    loop_anim = true,

    persists = false,

    tags = { "NOCLICK", "NOBLOCK" },

    clientfn = function(inst)
        MakeProjectilePhysics(inst)

        inst.AnimState:SetSymbolMultColour("glow", 0, 0, 0, 0)
        -- inst.AnimState:SetSymbolAddColour("glow",1,1,1,1)
        -- inst.AnimState:SetLightOverride(1)
    end,

    serverfn = function(inst)
        inst.can_trigger_fn = nil
        inst.can_hit_fn = nil
        inst.damages = { 100, 200 }

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(GetDamageFn)


        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(8)
        inst.components.complexprojectile.onupdatefn = function(inst)
            inst.max_range = inst.max_range or 25
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
                inst.tail = inst:SpawnChild("gale_skill_kinetic_blast_projectile_vfx")
                inst.tail.entity:AddFollower()
                inst.tail.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
            end

            if inst.entity:IsVisible() then
                inst.tail._use_tail:set(true)
            end

            inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

            if inst.entity:IsVisible() and inst.components.complexprojectile.horizontalSpeed <= 50 then
                inst.components.complexprojectile:SetHorizontalSpeed(inst.components.complexprojectile.horizontalSpeed +
                    FRAMES * 50)
            end


            local attacker = inst.components.complexprojectile.attacker
            local x, y, z = inst.Transform:GetWorldPosition()

            local ents = TheSim:FindEntities(x, y, z, 1, { "_combat", "_health" }, { "INLIMBO" })
            for k, v in pairs(ents) do
                if attacker.components.combat
                    and attacker.components.combat:CanTarget(v)
                    and not attacker.components.combat:IsAlly(v)
                    and (inst.can_trigger_fn == nil or inst:can_trigger_fn(attacker, v)) then
                    inst.components.complexprojectile:Hit(v)
                    break
                end
            end

            return true
        end

        inst.components.complexprojectile:SetOnHit(function(inst, attacker, target)
            inst:Show()

            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)

            GaleCommon.AoeDestroyWorkableStuff(attacker, inst:GetPosition(), 4, math.random(4, 6))
            GaleCommon.AoeForEach(
                attacker,
                inst:GetPosition(),
                4,
                nil,
                { "INLIMBO" },
                { "_combat", "_inventoryitem" },
                function(attacker, v)
                    if attacker.components.combat:CanTarget(v)
                        and not attacker.components.combat:IsAlly(v)
                        and (inst.can_hit_fn == nil or inst:can_hit_fn(attacker, v)) then
                        attacker.components.combat:DoAttack(v, inst, inst, nil, nil, 99999)
                        v:PushEvent("knockback",
                                    { knocker = inst, radius = GetRandomMinMax(1.2, 1.4) + v:GetPhysicsRadius(.5) })

                        local adder = SpawnPrefab("gale_hit_color_adder")
                        adder.add_colour = Vector3(1, 1, 0)
                        adder:SetTarget(v)
                    elseif v.components.inventoryitem then
                        local adder = SpawnPrefab("gale_hit_color_adder")
                        adder.add_colour = Vector3(1, 1, 0)
                        adder:SetTarget(v)

                        GaleCommon.LaunchItem(v, inst, 5)
                    end
                end,
                function(inst, v)
                    local is_combat = v.components.combat and v.components.health and not v.components.health:IsDead()
                        and not (v.sg and v.sg:HasStateTag("dead"))
                        and not v:HasTag("playerghost")
                    local is_inventory = v.components.inventoryitem
                    return v and v:IsValid()
                        and (is_combat or is_inventory or v.components.workable)
                end
            )

            if inst.tail then
                inst.tail._static:set(true)
                inst.tail:DoTaskInTime(2 * FRAMES, inst.tail.Remove)
            end



            inst.AnimState:SetMultColour(0, 0, 0, 0)

            inst.hitfx = inst:SpawnChild("gale_skill_kinetic_blast_explode_vfx")
            inst.hitfx.entity:AddFollower()
            inst.hitfx.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)

            inst.SoundEmitter:PlaySound("gale_sfx/battle/explode")

            inst:DoTaskInTime(1, inst.Remove)
        end)
    end,
})
