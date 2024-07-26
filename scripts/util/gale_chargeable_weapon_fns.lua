local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")


local function MeleeAttackNonCompletedWrapper(attack_mult, range_degree)
    attack_mult = attack_mult or 0.66
    range_degree = range_degree or 90

    local function fn(inst, attacker, target)
        if target then
            attacker.components.combat:DoAttack(target)
            return
        end

        inst.components.weapon.attackwear = 0
        local hit_ents = GaleCommon.AoeDoAttack(attacker,
            attacker:GetPosition(),
            attacker.components.combat:GetHitRange(),
            {
                ignorehitrange = false,
                instancemult = attack_mult,
            },
            function(inst, other)
                local tar_deg = GaleCommon.GetFaceAngle(inst, other)

                return math.abs(tar_deg) <= (range_degree / 2.0)
                    and inst.components.combat
                    and inst.components.combat:CanTarget(other)
                    and not inst.components.combat:IsAlly(other)
            end)
        inst.components.weapon.attackwear = 1
        inst.components.finiteuses:Use(#hit_ents)
    end

    return fn
end


local function EmitChargeAttackFXs(inst, attacker, hit_pt)
    local sparkle = attacker:SpawnChild("gale_sparkle_vfx")
    sparkle.Transform:SetPosition(1.2, 0, 0)
    sparkle._target_pos_x:set(hit_pt.x - attacker:GetPosition().x)
    sparkle._target_pos_y:set(0)
    sparkle._target_pos_z:set(hit_pt.z - attacker:GetPosition().z)
    sparkle._can_emit:set(true)

    local animfx = SpawnAt("hammer_mjolnir_crackle", hit_pt)
    animfx.AnimState:SetAddColour(50 / 255, 169 / 255, 255 / 255, 1)
    animfx.AnimState:HideSymbol("flash_up")
    animfx.AnimState:HideSymbol("lightning_land")
    animfx.AnimState:HideSymbol("lightning1")
    animfx.AnimState:HideSymbol("droplet")
    animfx.AnimState:SetDeltaTimeMultiplier(1.66)
    animfx.AnimState:SetLightOverride(2)
    animfx.persists = false
    animfx:ListenForEvent("animover", animfx.Remove)
end


local function MeleeAttackCompletedWrapper(attack_mults, aoe_radius, knockback_dist, item_launch_speed)
    aoe_radius = aoe_radius or 2.2
    knockback_dist = knockback_dist or 8
    item_launch_speed = item_launch_speed or 6.5

    if attack_mults and type(attack_mults) == "number" then
        local num = attack_mults
        attack_mults = { num, num }
    else
        attack_mults = attack_mults or { 2.8, 3 }
    end

    local function fn(inst, attacker)
        local face_vec = GaleCommon.GetFaceVector(attacker)
        local hit_pt = face_vec * attacker.components.combat:GetHitRange() + attacker:GetPosition()

        inst.components.weapon.attackwear = 0

        local attack_ents_num = 0
        GaleCommon.AoeForEach(attacker,
            hit_pt,
            aoe_radius,
            nil,
            { "INLIMBO" },
            { "_combat", "_inventoryitem" },
            function(doer, other)
                local can_attack = doer.components.combat:CanTarget(other) and
                    not doer.components.combat:IsAlly(other)
                local is_inv = other.components.inventoryitem ~= nil

                if can_attack then
                    doer.components.combat.ignorehitrange = true
                    doer.components.combat:DoAttack(other, doer.components.combat:GetWeapon(), nil,
                        nil, GetRandomMinMax(attack_mults[1], attack_mults[2]))
                    doer.components.combat.ignorehitrange = false

                    other:PushEvent("knockback", { knocker = doer, radius = knockback_dist })

                    attack_ents_num = attack_ents_num + 1
                elseif is_inv then
                    GaleCommon.LaunchItem(other, doer, item_launch_speed)
                end

                if other ~= doer then
                    SpawnPrefab("gale_hit_color_adder"):SetTarget(other)
                end
            end,
            function(doer, other)
                return other and other:IsValid()
            end
        )

        inst.components.weapon.attackwear = 1
        inst.components.finiteuses:Use(attack_ents_num)

        EmitChargeAttackFXs(inst, attacker, hit_pt)

        attacker.SoundEmitter:PlaySound("gale_sfx/battle/P1_punchF")
        attacker.SoundEmitter:PlaySound("gale_sfx/character/p1_gale_charge_atk_shout")

        ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, attacker, 40)
    end

    return fn
end

local function WeaponAttackWrapper(ChargeAttackIfNotCompletedFn, ChargeAttackIfCompletedFn)
    local function fn(inst, attacker, target, target_pos, percent)
        local complete_charge = percent >= 1.0 or GaleCondition.GetCondition(attacker, "condition_carry_charge") ~= nil

        if not complete_charge then
            local bufferedaction = attacker:GetBufferedAction()

            if bufferedaction.action == ACTIONS.ATTACK then
                ChargeAttackIfNotCompletedFn(inst, attacker, target)
            else
                ChargeAttackIfNotCompletedFn(inst, attacker)
            end
        else
            ChargeAttackIfCompletedFn(inst, attacker)
            if GaleCondition.GetCondition(attacker, "condition_carry_charge") ~= nil then
                GaleCondition.RemoveCondition(attacker, "condition_carry_charge")
            end
        end
    end

    return fn
end

local function ChargeTimeCbWrapper(offset)
    offset = offset or Vector3(0, -190, 0)
    offset = ToVector3(offset)

    local function fn(inst, data)
        local old_percent = data.old_percent
        local percent = data.current_percent
        local owner = inst.components.inventoryitem:GetGrandOwner()
        local equipped = inst.components.equippable:IsEquipped()

        if percent <= 0 or not (owner and equipped) then
            if inst.charge_fx then
                inst.charge_fx:KillFX()
                inst.charge_fx = nil
            end
        elseif percent >= 1 and (owner and equipped) then
            if not inst.charge_fx then
                inst.charge_fx = SpawnPrefab("gale_charge_fx")
                inst.charge_fx.entity:SetParent(owner.entity)
                inst.charge_fx.entity:AddFollower()
                inst.charge_fx.Follower:FollowSymbol(owner.GUID, "swap_object", offset:Get())
                inst.charge_fx.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge")
            end
        end
    end

    return fn
end

return {
    MeleeAttackNonCompletedWrapper = MeleeAttackNonCompletedWrapper,
    MeleeAttackCompletedWrapper = MeleeAttackCompletedWrapper,
    WeaponAttackWrapper = WeaponAttackWrapper,
    ChargeTimeCbWrapper = ChargeTimeCbWrapper,

    EmitChargeAttackFXs = EmitChargeAttackFXs,
}
