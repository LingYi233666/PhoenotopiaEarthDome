local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")
local GaleChargeableWeaponFns = require("util/gale_chargeable_weapon_fns")

local assets = {
    Asset("ANIM", "anim/gale_mace.zip"),
    Asset("ANIM", "anim/swap_gale_mace.zip"),

    Asset("IMAGE", "images/inventoryimages/gale_mace.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_mace.xml"),
}

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

    inst.components.planardamage:AddBonus(inst, GaleCommon.SumDices(5, 8), "divine_smite")

    attacker.AnimState:SetSymbolAddColour("swap_object", 1, 1, 0, 1)
    attacker.AnimState:SetSymbolLightOverride("swap_object", 1)

    if inst.delat_light_over_task then
        inst.delat_light_over_task:Cancel()
        inst.delat_light_over_task = nil
    end

    if inst.periodic_light_over_task then
        inst.periodic_light_over_task:Cancel()
        inst.periodic_light_over_task = nil
    end

    if inst.fx == nil then
        -- cane_victorian_fx
        inst.fx = attacker:SpawnChild("cane_victorian_fx")
        inst.fx.entity:AddFollower()
        inst.fx.Follower:FollowSymbol(attacker.GUID, "swap_object", 0, -160, 0)
    end
end


local function OnStopHelmSplitter(inst, attacker)
    attacker.Physics:Stop()

    inst.components.planardamage:RemoveBonus(inst, "divine_smite")

    -- attacker.AnimState:SetSymbolAddColour("swap_object", 0, 0, 0, 0)
    -- attacker.AnimState:SetSymbolLightOverride("swap_object", 0)
end

local function SpawnFX(inst, attacker)
    local hit_pos = inst.components.gale_helmsplitter:GetHitPos(attacker)
    SpawnAt("gale_divine_smite_circle_fx", hit_pos)
    SpawnAt("gale_divine_smite_explode_fx", hit_pos)
    SpawnAt("gale_divine_smite_burntground_fx", hit_pos)
end

local function OnCastHelmSplitter(inst, attacker, target, hit_targets, hit_items)
    attacker.Physics:Stop()

    SpawnFX(inst, attacker)

    -- for _, v in pairs(hit_targets) do
    --     local fx = v:SpawnChild("gale_divine_smite_fire_vfx")
    --     fx:DoTaskInTime(GetRandomMinMax(2, 4), fx.Remove)
    -- end

    inst.delat_light_over_task = inst:DoTaskInTime(2.6, function()
        inst.periodic_light_over_task = inst:DoPeriodicTask(0, function()
            local r, g, b, a = attacker.AnimState:GetSymbolAddColour("swap_object")
            r = r - FRAMES * 5
            if r > 0 then
                attacker.AnimState:SetSymbolAddColour("swap_object", r, r, 0, 1)
                attacker.AnimState:SetSymbolLightOverride("swap_object", r)
            else
                attacker.AnimState:SetSymbolAddColour("swap_object", 0, 0, 0, 0)
                attacker.AnimState:SetSymbolLightOverride("swap_object", 0)

                if inst.fx then
                    inst.fx:Remove()
                    inst.fx = nil
                end

                inst.periodic_light_over_task:Cancel()
                inst.periodic_light_over_task = nil
            end
        end)
        inst.delat_light_over_task = nil
    end)
end

return GaleEntity.CreateNormalWeapon({
    assets = assets,
    prefabname = "gale_mace",
    tags = { "gale_mace", "gale_only_rmb_charge", "gale_parryweapon" },


    bank = "gale_mace",
    build = "gale_mace",
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
                    if inst.delat_light_over_task then
                        inst.delat_light_over_task:Cancel()
                        inst.delat_light_over_task = nil
                    end

                    if inst.periodic_light_over_task then
                        inst.periodic_light_over_task:Cancel()
                        inst.periodic_light_over_task = nil
                    end

                    owner.AnimState:SetSymbolAddColour("swap_object", 0, 0, 0, 0)
                    owner.AnimState:SetSymbolLightOverride("swap_object", 0)
                    if inst.fx then
                        inst.fx:Remove()
                        inst.fx = nil
                    end
                end,
                1,
            }
        },
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        damage = 55,
    },

    finiteuses_data = {
        maxuse = 600,
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst.components.equippable.restrictedtag = "gale_weaponcharge"

        inst:AddComponent("planardamage")
        inst.components.planardamage:SetBaseDamage(10)

        inst:AddComponent("gale_helmsplitter")
        inst.components.gale_helmsplitter:SetWhooshSound("gale_sfx/skill/divine_smite_whoosh")
        inst.components.gale_helmsplitter:SetImpactSound("gale_sfx/skill/divine_smite_impact")
        inst.components.gale_helmsplitter:EnableDefaultFX(false)
        -- inst.components.gale_helmsplitter:SetAttackMults(1.5, 1.8)
        inst.components.gale_helmsplitter.onstartfn = OnStartHelmSplitter
        inst.components.gale_helmsplitter.onstopfn = OnStopHelmSplitter
        inst.components.gale_helmsplitter.oncastfn = OnCastHelmSplitter

        local ChargeAttackIfNotCompleted = GaleChargeableWeaponFns.MeleeAttackNonCompletedWrapper()
        local ChargeAttackIfCompleted = GaleChargeableWeaponFns.MeleeAttackCompletedWrapper()

        inst:AddComponent("gale_chargeable_weapon")
        inst.components.gale_chargeable_weapon.do_attack_fn =
            GaleChargeableWeaponFns.WeaponAttackWrapper(
                ChargeAttackIfNotCompleted,
                ChargeAttackIfCompleted)

        inst:ListenForEvent("gale_charge_time_change", GaleChargeableWeaponFns.ChargeTimeCbWrapper(Vector3(0, -170, 0)))
    end,
})
