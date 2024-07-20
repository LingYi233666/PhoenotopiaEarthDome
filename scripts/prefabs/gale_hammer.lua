local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleWeaponSkill = require("util/gale_weaponskill")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/gale_hammer.zip"),
    Asset("ANIM", "anim/swap_gale_hammer.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
    Asset("ANIM", "anim/gale_actions_melee_chargeatk.zip"),

    Asset("ANIM", "anim/gale_circleslash_fx.zip"),


    Asset("IMAGE", "images/inventoryimages/gale_hammer.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_hammer.xml"),
}

local function GetDamageFn(inst, attacker, target)
    local basedamage = 49.5
    local power_level = GaleCondition.GetConditionStacks(attacker, "condition_power")
    if power_level <= 0 then
        return basedamage
    end

    -- basedamage with power bonus, damage = basedamage * (1 + power_level * 0.05)

    return basedamage * (1 + power_level * 0.10) / (1 + power_level * 0.05)
end

local HELMSPLITTER_WEAPON_LENGTH = 1.5

local function OnStartHelmSplitter(inst, attacker)
    local targetpos = attacker.sg.statemem.targetpos
    if targetpos then
        local duration = 13 * FRAMES
        local speed = ((attacker:GetPosition() - targetpos):Length() - HELMSPLITTER_WEAPON_LENGTH) / duration
        if speed > 0 then
            attacker.Physics:SetMotorVel(speed, 0, 0)
        end
    end
end


local function OnStopHelmSplitter(inst, attacker)
    attacker.Physics:Stop()
end

local function OnCastHelmSplitter(inst, attacker, target)
    local face_vec = GaleCommon.GetFaceVector(attacker)
    local hit_pos = face_vec * HELMSPLITTER_WEAPON_LENGTH + attacker:GetPosition()

    GaleCommon.AoeForEach(attacker,
                          hit_pos,
                          2.5,
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
                                                                  nil,
                                                                  GetRandomMinMax(1, 1.5))
                                  doer.components.combat.ignorehitrange = false
                              elseif is_inv then
                                  GaleCommon.LaunchItem(other, doer, 2)
                              end
                          end,
                          function(doer, other)
                              return other and other:IsValid()
                          end)

    SpawnAt("gale_leap_puff_fx", hit_pos)


    local ring = SpawnAt("gale_ring_fx", hit_pos)
    ring.AnimState:SetDeltaTimeMultiplier(0.95)
    ring.AnimState:SetTime(8 * FRAMES)
    ring.AnimState:SetMultColour(123 / 255, 245 / 255, 247 / 255, 1)
    ring.Transform:SetScale(0.61, 0.61, 0.61)
    ring:SpawnChild("gale_atk_leap_vfx")

    ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, attacker, 20)

    attacker.Physics:Stop()
end


local function ChargeAttackIfNotCompleted(inst, attacker, target)
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
                                                instancemult = 0.66,
                                            },
                                            function(inst, other)
                                                local tar_deg = GaleCommon.GetFaceAngle(inst, other)

                                                return math.abs(tar_deg) <= 45
                                                    and inst.components.combat
                                                    and inst.components.combat:CanTarget(other)
                                                    and not inst.components.combat:IsAlly(other)
                                            end)
    inst.components.weapon.attackwear = 1
    inst.components.finiteuses:Use(#hit_ents)
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

local function ChargeAttackIfCompleted(inst, attacker)
    local face_vec = GaleCommon.GetFaceVector(attacker)
    local hit_pt = face_vec * attacker.components.combat:GetHitRange() + attacker:GetPosition()

    inst.components.weapon.attackwear = 0

    local attack_ents_num = 0
    GaleCommon.AoeForEach(attacker,
                          hit_pt,
                          2.2,
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
                                                                  nil, GetRandomMinMax(2.8, 3.0))
                                  doer.components.combat.ignorehitrange = false

                                  other:PushEvent("knockback", { knocker = doer, radius = 8 })

                                  attack_ents_num = attack_ents_num + 1
                              elseif is_inv then
                                  GaleCommon.LaunchItem(other, doer, 6.5)
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

local function WeaponAttackFn(inst, attacker, target, target_pos, percent)
    local complete_charge = percent >= 1.0 or GaleCondition.GetCondition(attacker, "condition_carry_charge") ~= nil

    if not complete_charge then
        local bufferedaction = attacker:GetBufferedAction()

        if bufferedaction.action == ACTIONS.ATTACK then
            ChargeAttackIfNotCompleted(inst, attacker, target)
        else
            ChargeAttackIfNotCompleted(inst, attacker)
        end
    else
        ChargeAttackIfCompleted(inst, attacker)
        if GaleCondition.GetCondition(attacker, "condition_carry_charge") ~= nil then
            GaleCondition.RemoveCondition(attacker, "condition_carry_charge")
        end
    end
end

local function ChargeTimeCb(inst, data)
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
            inst.charge_fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -190, 0)
            inst.charge_fx.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge")
        end
    end
end

return GaleEntity.CreateNormalWeapon({
    assets = assets,
    prefabname = "gale_hammer",
    tags = { "gale_hammer", "gale_only_rmb_charge", "gale_parryweapon" },


    bank = "gale_hammer",
    build = "gale_hammer",
    anim = "idle",

    equippable_data = {
        onequip_priority = {
            {
                function(inst, owner)

                end,
                1,
            }
        },

        onunequip_priority = {
            {
                function(inst, owner)

                end,
                1,
            }
        },
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        damage = GetDamageFn,
        -- ranges = 0.2,
    },

    finiteuses_data = {
        maxuse = 350,
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst.components.equippable.restrictedtag = "gale_weaponcharge"

        inst:AddComponent("tool")
        inst.components.tool:SetAction(ACTIONS.HAMMER)

        inst:AddComponent("gale_helmsplitter")
        inst.components.gale_helmsplitter.onstartfn = OnStartHelmSplitter
        inst.components.gale_helmsplitter.onstopfn = OnStopHelmSplitter
        inst.components.gale_helmsplitter.oncastfn = OnCastHelmSplitter

        inst:AddComponent("gale_chargeable_weapon")
        -- inst.components.gale_chargeable_weapon.do_attack_fn = ChargeCommonAttack
        inst.components.gale_chargeable_weapon.do_attack_fn = WeaponAttackFn

        inst:ListenForEvent("gale_charge_time_change", ChargeTimeCb)
    end,
})
