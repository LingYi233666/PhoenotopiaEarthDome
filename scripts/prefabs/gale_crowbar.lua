local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleWeaponSkill = require("util/gale_weaponskill")
local GaleCondition = require("util/gale_conditions")
local GaleChargeableWeaponFns = require("util/gale_chargeable_weapon_fns")

local assets = {
    Asset("ANIM", "anim/gale_crowbar.zip"),
    Asset("ANIM", "anim/swap_gale_crowbar.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
    Asset("ANIM", "anim/gale_actions_melee_chargeatk.zip"),

    Asset("ANIM", "anim/gale_circleslash_fx.zip"),


    Asset("IMAGE", "images/inventoryimages/gale_crowbar.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_crowbar.xml"),
}

-- ThePlayer:AddTag("galeatk_multithrust")
local function OnSpecialAtk(owner, data)
    local target = data.target
    if data.name == "galeatk_lunge" then
        if target then
            GaleCommon.AoeDoAttack(owner, target:GetPosition(), 1.2, {
                instancemult = 1.5,
            })
        end
    elseif data.name == "galeatk_multithrust" then
        if data.other_data.areahit then
            if target then
                GaleCommon.AoeDoAttack(owner, target:GetPosition(), 1.25, {
                    instancemult = 0.75,
                })
            end
        end
    elseif data.name == "galeatk_leap" then
        if target then
            local hit_pos = owner:GetPosition() +
                GaleCommon.GetFaceVector(owner) * owner.components.combat:GetHitRange() * 0.75
            GaleCommon.AoeForEach(owner, hit_pos, 2.5, nil, { "INLIMBO" }, { "_combat", "_inventoryitem" },
                function(doer, other)
                    local can_attack = doer.components.combat:CanTarget(other) and
                        not doer.components.combat:IsAlly(other)
                    local is_inv = other.components.inventoryitem ~= nil

                    if can_attack then
                        doer.components.combat.ignorehitrange = true
                        doer.components.combat:DoAttack(other, doer.components.combat:GetWeapon(), nil,
                            nil,
                            GetRandomMinMax(0.75, 1))
                        doer.components.combat.ignorehitrange = false
                    elseif is_inv then
                        GaleCommon.LaunchItem(other, doer, 2)
                    end
                end,
                function(doer, other)
                    return other and other:IsValid()
                end)

            -- SpawnAt("gale_atk_firepuff_cold",target).Transform:SetScale(1,1,1)
            SpawnAt("gale_leap_puff_fx", hit_pos)


            local ring = SpawnAt("gale_ring_fx", hit_pos)
            ring.AnimState:SetDeltaTimeMultiplier(0.95)
            ring.AnimState:SetTime(8 * FRAMES)
            ring.AnimState:SetMultColour(123 / 255, 245 / 255, 247 / 255, 1)
            ring.Transform:SetScale(0.61, 0.61, 0.61)
            ring:SpawnChild("gale_atk_leap_vfx")
            -- owner:SpawnChild("gale_atk_leap_vfx").Transform:SetPosition((target:GetPosition() - owner:GetPosition()):Get())
        end
        ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, owner, 20)
    end
end

local function OnHitOther(owner, data)
    if data.target and owner.sg and owner.sg.currentstate.name == "galeatk_multithrust" then
        GaleCondition.AddCondition(data.target, "condition_bleed")
    end
end

local function OnStartHelmSplitter(inst, attacker)
    local targetpos = attacker.sg.statemem.targetpos
    if targetpos then
        local duration = 13 * FRAMES
        local dist = (attacker:GetPosition() - targetpos):Length()
        local dist_adjust = dist - inst.components.gale_helmsplitter:GetForwardOffset()
        local speed = dist_adjust / duration
        if speed > 0 then
            attacker.Physics:SetMotorVel(speed, 0, 0)
        end
    end
end


local function OnStopHelmSplitter(inst, attacker)
    attacker.Physics:Stop()
end

local function OnCastHelmSplitter(inst, attacker, target)
    attacker.Physics:Stop()
end


local function OnStartMultithruster(inst, doer)
    if not inst.magicgas then
        inst.magicgas = SpawnPrefab("gale_magicgas_vfx")
        inst.magicgas.entity:SetParent(doer.entity)
        inst.magicgas.entity:AddFollower()
        inst.magicgas.Follower:FollowSymbol(doer.GUID, "swap_object", 15, -190, 0)
    end
end

local function OnStopMultithruster(inst, doer)
    if inst.magicgas then
        inst.magicgas:Remove()
    end
    inst.magicgas = nil
end

local function ClientFn(inst)

end


local function ServerFn(inst)
    inst.components.equippable.restrictedtag = "gale_weaponcharge"

    -- inst:AddComponent("gale_chargeable_weapon")
    -- inst.components.gale_chargeable_weapon.do_attack_fn = ChargeCommonAttack
    -- inst.components.gale_chargeable_weapon.do_attack_fn = ChargeCommonAttackWrapper(
    --     config.charge_atk_range, config.charge_atk_damage_mult, config.complete_charge_atk_range,
    --     config.complete_charge_atk_damage_mult)

    -- inst:ListenForEvent("gale_charge_time_change", ChargeTimeCb)

    inst:AddComponent("gale_helmsplitter")
    inst.components.gale_helmsplitter.onstartfn = OnStartHelmSplitter
    inst.components.gale_helmsplitter.onstopfn = OnStopHelmSplitter
    inst.components.gale_helmsplitter.oncastfn = OnCastHelmSplitter

    inst:AddComponent("gale_multithruster")
    inst.components.gale_multithruster.onstartfn = OnStartMultithruster
    inst.components.gale_multithruster.onstopfn = OnStopMultithruster

    local ChargeAttackIfNotCompleted = GaleChargeableWeaponFns.MeleeAttackNonCompletedWrapper()
    local ChargeAttackIfCompleted = GaleChargeableWeaponFns.MeleeAttackCompletedWrapper()

    inst:AddComponent("gale_chargeable_weapon")
    inst.components.gale_chargeable_weapon.do_attack_fn =
        GaleChargeableWeaponFns.WeaponAttackWrapper(
            ChargeAttackIfNotCompleted,
            ChargeAttackIfCompleted)

    inst:ListenForEvent("gale_charge_time_change", GaleChargeableWeaponFns.ChargeTimeCbWrapper())

    -- -- ThePlayer:AddTag("galeatk_leap")
    -- inst:ListenForEvent("equipped", function(inst, data)
    --     if not inst.magicgas then
    --         inst.magicgas = SpawnPrefab("gale_magicgas_vfx")
    --         inst.magicgas.entity:SetParent(data.owner.entity)
    --         inst.magicgas.entity:AddFollower()
    --         inst.magicgas.Follower:FollowSymbol(data.owner.GUID, "swap_object", 15, -190, 0)
    --     end
    -- end)

    -- inst:ListenForEvent("onremove", function(inst, data)
    --     if inst.magicgas then
    --         inst.magicgas:Remove()
    --         inst.magicgas = nil
    --     end
    -- end)

    -- inst:ListenForEvent("unequipped", function(inst, data)
    --     if inst.magicgas then
    --         inst.magicgas:Remove()
    --         inst.magicgas = nil
    --     end
    -- end)
end




return GaleEntity.CreateNormalWeapon({
        assets = assets,
        prefabname = "gale_crowbar",
        tags = { "gale_crowbar", "gale_only_rmb_charge", "gale_parryweapon" },


        bank = "gale_crowbar",
        build = "gale_crowbar",
        anim = "idle",

        equippable_data = {

        },

        inventoryitem_data = {
            use_gale_item_desc = true,
        },

        weapon_data = {
            damage = 34,
        },

        finiteuses_data = {
            maxuse = 175,
        },

        clientfn = ClientFn,
        serverfn = ServerFn,
    }),
    GaleEntity.CreateNormalFx({
        assets = assets,
        prefabname = "gale_circleslash_fx",

        bank = "gale_circleslash_fx",
        build = "gale_circleslash_fx",
        anim = "idle",

        clientfn = function(inst)
            inst.Transform:SetTwoFaced()

            -- inst.Transform:SetScale()
            inst.AnimState:SetScale(1.8, 1.8, 1.8)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetFinalOffset(-1)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        end,
    }),
    GaleEntity.CreateNormalFx({
        assets = assets,
        prefabname = "gale_leap_puff_fx",

        bank = "round_puff_fx",
        build = "round_puff_fx",
        anim = "puff_lg",

        clientfn = function(inst)
            inst.AnimState:SetAddColour(50 / 255, 169 / 255, 255 / 255, 1)
        end,
    })
