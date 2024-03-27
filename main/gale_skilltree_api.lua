require "util/multitree"
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local skilltree_Assets = {
    Asset("ANIM", "anim/gale_skill_desc_brain.zip"),

    Asset("IMAGE", "images/ui/skill_slot/anatomy.tex"),
    Asset("ATLAS", "images/ui/skill_slot/anatomy.xml"),
    Asset("IMAGE", "images/ui/skill_slot/bufficon_empty.tex"),
    Asset("ATLAS", "images/ui/skill_slot/bufficon_empty.xml"),
    Asset("IMAGE", "images/ui/skill_slot/burger_eater.tex"),
    Asset("ATLAS", "images/ui/skill_slot/burger_eater.xml"),
    Asset("IMAGE", "images/ui/skill_slot/carry_charge.tex"),
    Asset("ATLAS", "images/ui/skill_slot/carry_charge.xml"),
    Asset("IMAGE", "images/ui/skill_slot/dark_vision.tex"),
    Asset("ATLAS", "images/ui/skill_slot/dark_vision.xml"),
    Asset("IMAGE", "images/ui/skill_slot/dimension_jump.tex"),
    Asset("ATLAS", "images/ui/skill_slot/dimension_jump.xml"),
    Asset("IMAGE", "images/ui/skill_slot/doctor.tex"),
    Asset("ATLAS", "images/ui/skill_slot/doctor.xml"),
    Asset("IMAGE", "images/ui/skill_slot/harpy_whirl.tex"),
    Asset("ATLAS", "images/ui/skill_slot/harpy_whirl.xml"),
    Asset("IMAGE", "images/ui/skill_slot/kinetic_blast.tex"),
    Asset("ATLAS", "images/ui/skill_slot/kinetic_blast.xml"),
    Asset("IMAGE", "images/ui/skill_slot/linkage.tex"),
    Asset("ATLAS", "images/ui/skill_slot/linkage.xml"),
    Asset("IMAGE", "images/ui/skill_slot/mimic_lv1.tex"),
    Asset("ATLAS", "images/ui/skill_slot/mimic_lv1.xml"),
    Asset("IMAGE", "images/ui/skill_slot/mimic_lv2.tex"),
    Asset("ATLAS", "images/ui/skill_slot/mimic_lv2.xml"),
    Asset("IMAGE", "images/ui/skill_slot/mimic_lv3.tex"),
    Asset("ATLAS", "images/ui/skill_slot/mimic_lv3.xml"),
    Asset("IMAGE", "images/ui/skill_slot/parry.tex"),
    Asset("ATLAS", "images/ui/skill_slot/parry.xml"),
    Asset("IMAGE", "images/ui/skill_slot/picker_butterfly.tex"),
    Asset("ATLAS", "images/ui/skill_slot/picker_butterfly.xml"),
    Asset("IMAGE", "images/ui/skill_slot/quick_charge.tex"),
    Asset("ATLAS", "images/ui/skill_slot/quick_charge.xml"),
    Asset("IMAGE", "images/ui/skill_slot/regeneration.tex"),
    Asset("ATLAS", "images/ui/skill_slot/regeneration.xml"),
    Asset("IMAGE", "images/ui/skill_slot/remote_control.tex"),
    Asset("ATLAS", "images/ui/skill_slot/remote_control.xml"),
    Asset("IMAGE", "images/ui/skill_slot/rolling.tex"),
    Asset("ATLAS", "images/ui/skill_slot/rolling.xml"),
    Asset("IMAGE", "images/ui/skill_slot/shou_shen.tex"),
    Asset("ATLAS", "images/ui/skill_slot/shou_shen.xml"),
    Asset("IMAGE", "images/ui/skill_slot/spear_fragment.tex"),
    Asset("ATLAS", "images/ui/skill_slot/spear_fragment.xml"),
    Asset("IMAGE", "images/ui/skill_slot/spear_remain.tex"),
    Asset("ATLAS", "images/ui/skill_slot/spear_remain.xml"),
}

for k, v in pairs(skilltree_Assets) do
    table.insert(Assets, v)
end

AddReplicableComponent("gale_skiller")
AddReplicableComponent("gale_skill_parry")

local Widget = require "widgets/widget"
local GaleMainMenu = require("screens/gale_main_menu")
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local GaleDarkVisionHover = require("widgets/gale_dark_vision_hover")

AddClassPostConstruct("widgets/controls", function(self)
    if self.owner:HasTag("gale") then
        self.GaleMenuCaller_root = self:AddChild(Widget("GaleMenuCaller_root"))
        self.GaleMenuCaller_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.GaleMenuCaller_root:SetHAnchor(ANCHOR_LEFT)
        self.GaleMenuCaller_root:SetVAnchor(ANCHOR_BOTTOM)
        self.GaleMenuCaller_root:SetMaxPropUpscale(MAX_HUD_SCALE)

        -- self.GaleMenuCaller = self:AddChild(ImageButton())
        self.GaleMenuCaller = self.GaleMenuCaller_root:AddChild(TEMPLATES.StandardButton(function()
                                                                                             self:OnCreateNewSlot()
                                                                                         end,
                                                                                         STRINGS.GALE_UI
                                                                                         .MENU_CALLER_NAME, { 120, 60 }))
        -- self.GaleMenuCaller:AddChild(Text(DEFAULTFONT,40,STRINGS.GALE_UI.MENU_CALLER_NAME))

        -- self.GaleMenuCaller:SetScale(0.66)

        self.GaleMenuCaller:SetPosition(60, 28)
        self.GaleMenuCaller:SetOnClick(function()
            TheFrontEnd:PushScreen(GaleMainMenu(self.owner))
        end)
    end
end)

AddComponentPostInit("lootdropper", function(self)
    local old_SpawnLootPrefab = self.SpawnLootPrefab
    self.SpawnLootPrefab = function(self, ...)
        local ret = old_SpawnLootPrefab(self, ...)
        if ret ~= nil then
            if self.inst.components.combat then
                local player = self.inst.components.combat.lastattacker
                if player and player:IsValid()
                    and player.components.gale_skiller and player.components.gale_skiller:IsLearned("picker_butterfly")
                    and not GaleCommon.IsTruelyDead(player) then
                    ret:DoTaskInTime(GetRandomMinMax(0.5, 1), function()
                        if player and player:IsValid() and not GaleCommon.IsTruelyDead(player) and
                            ret.components.inventoryitem
                            and ret.components.inventoryitem.canbepickedup
                            and ret.components.inventoryitem.owner == nil then
                            SpawnPrefab("gale_skill_picker_butterfly").sg:GoToState("land", {
                                target = ret,
                                owner = player,
                            })
                        end
                    end)
                end
            end
        end
        return ret
    end
end)

----------------------------------------------------------------------------------
-- AddComponentPostInit("health",function(self)
--     local old_OnLoad = self.OnLoad
--     self.OnLoad = function(self,...)
--         if self.inst.prefab == "gale" then
--             print("[health]:OnLoad() hacked!")
--         end

--         return old_OnLoad(self,...)
--     end
-- end)

-- OnPressed,OnReleased
GLOBAL.GALE_SKILL_NODES = {
    -- SURVIVAL
    DOCTOR = GaleNode({
        ui_pos = Vector3(0, 2),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 1, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
        _on_owner_heal = function(inst, data)
            local buffered_action = data.action
            local action = buffered_action.action

            if action == ACTIONS.HEAL then
                local target = buffered_action.target or buffered_action.doer
                if target ~= nil and buffered_action.invobject ~= nil
                    and target.components.health ~= nil
                    and not (target.components.health:IsDead() or target:HasTag("playerghost")) then
                    if buffered_action.invobject.components.healer ~= nil then
                        target.components.health:DoDelta(buffered_action.invobject.components.healer.health / 2, false,
                                                         buffered_action.invobject.prefab)
                    end
                end
            end
        end,
        OnLearned = function(inst, is_load)
            inst:ListenForEvent("performaction", GALE_SKILL_NODES.DOCTOR.data._on_owner_heal)
        end,
        OnForget = function(inst)
            inst:RemoveEventCallback("performaction", GALE_SKILL_NODES.DOCTOR.data._on_owner_heal)
        end,
    }),
    -- DISSECT = GaleNode({
    --     ui_pos = Vector3(1,3),
    --     ingredients = {
    --         Ingredient("nightmarefuel",1),
    --     },
    -- }),
    BURGER_EATER = GaleNode({
        ui_pos = Vector3(1, 2),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 3, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
        OnLearned = function(inst, is_load)
            inst:ListenForEvent("oneat", GALE_SKILL_NODES.BURGER_EATER.data.on_owner_eat)
        end,
        OnForget = function(inst)
            inst:RemoveEventCallback("oneat", GALE_SKILL_NODES.BURGER_EATER.data.on_owner_eat)
        end,

        on_owner_eat = function(inst, data)
            local percent = Remap(inst.components.hunger:GetPercent(), 0, 1, 0.2, 0.8)
            local food = data.food
            local amount = food.components.edible:GetHealth(inst) * 0.66
                + food.components.edible:GetSanity(inst) * 0.4
                + food.components.edible:GetHunger(inst) * 0.2

            amount = math.floor(amount * percent)

            if amount > 0 then
                GaleCondition.AddCondition(inst, "condition_mending", amount)
            end
        end,
    }),
    ROLLING = GaleNode({
        ui_pos = Vector3(0, 0),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 1, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
        OnPressed = function(inst, x, y, z, ent)
            if not inst.sg:HasStateTag("dead")
                and not inst.sg:HasStateTag("gale_portal_hopping")
                and not inst.sg:HasStateTag("gale_qte_cooking")
                and not IsEntityDeadOrGhost(inst)
                and not (inst.components.rider and inst.components.rider:IsRiding())
                and not (inst.components.gale_skill_mimic and inst.components.gale_skill_mimic:IsMimic()) then
                local last_cast_time = inst.components.gale_skiller.skillmem.LastRollingTime
                local has_learn_shadow = inst.components.gale_skiller:IsLearned("dimension_jump")

                if last_cast_time == nil or GetTime() - last_cast_time >= 1.0 then
                    if inst.sg:HasStateTag("gale_tired_low_stamina") then
                        if inst.components.gale_skiller:IsLearned("shou_shen") then
                            local buttom_delta = math.max(0, 12 - inst.components.gale_stamina.current)
                            inst.components.gale_stamina:DoDelta(buttom_delta)

                            inst.sg:GoToState("gale_fangun", {
                                targetpos = Vector3(x, y, z),
                            })
                            inst.components.gale_skiller.skillmem.LastRollingTime = GetTime()
                        else

                        end

                        return
                    end

                    if inst.components.gale_stamina.current >= 26 then
                        inst.components.gale_stamina:DoDelta(-15)
                    else
                        return
                    end

                    local weapon = inst.components.combat:GetWeapon()
                    local should_circle = weapon
                        and weapon.prefab == "gale_crowbar"
                        and inst.components.gale_skiller
                        and inst.components.gale_skiller:IsLearned("harpy_whirl")
                        and inst.sg:HasStateTag("charging_attack_pre")
                        and (GaleCondition.GetCondition(inst, "condition_carry_charge") ~= nil
                            or (inst.components.gale_weaponcharge and inst.components.gale_weaponcharge:IsComplete())
                        )
                    inst.sg:GoToState("gale_dodge", {
                        targetpos = Vector3(x, y, z),
                        is_shadow = has_learn_shadow and inst.components.gale_skill_shadow_dodge:CoolDone(),
                        should_circle = should_circle,
                    })
                    inst.components.gale_skiller.skillmem.LastRollingTime = GetTime()
                else
                    -- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"],inst.userid,string.format(STRINGS.GALE_SKILL_CAST.FAILED.COOLING_DOWN,STRINGS.GALE_UI.SKILL_NODES.ROLLING.NAME,GetTime() - last_cast_time))
                end
            end
        end,
    }),
    SHOU_SHEN = GaleNode({
        ui_pos = Vector3(1, 1),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 2, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),
    PARRY = GaleNode({
        ui_pos = Vector3(1, 0),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 3, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
        OnPressed = function(inst, x, y, z, ent)
            if not inst.sg:HasStateTag("dead")
                and not inst.sg:HasStateTag("busy")
                and not IsEntityDeadOrGhost(inst)
                and not (inst.components.rider and inst.components.rider:IsRiding())
                and inst.components.gale_skill_parry
                and not inst.components.gale_skill_parry:IsParrying() then
                local weapon = inst.components.combat:GetWeapon()
                if not (weapon and weapon:HasTag("gale_parryweapon")) then
                    return
                end

                local last_cast_time = inst.components.gale_skiller.skillmem.LastParryTime

                if last_cast_time == nil or GetTime() - last_cast_time >= 0.1 then
                    local weapon = inst.components.combat:GetWeapon()
                    if weapon ~= nil then
                        inst.components.gale_skill_parry:StartParry()
                    end

                    inst.components.gale_skiller.skillmem.LastParryTime = GetTime()
                end
            end
        end,
        OnReleased = function(inst, x, y, z, ent)
            if inst.components.gale_skill_parry and inst.components.gale_skill_parry:IsParrying() then
                inst.components.gale_skill_parry:StopParry()
            end
        end,

    }),

    -- ROLLING_BOMB = GaleNode({
    --     ui_pos = Vector3(1,0),
    --     ingredients = {
    --         Ingredient("nightmarefuel",1),
    --     },
    -- }),
    -- ROLLING_SMOKE = GaleNode({
    --     ui_pos = Vector3(2,0),
    --     ingredients = {
    --         Ingredient("nightmarefuel",1),
    --     },
    -- }),

    -- SCIENCE
    ANATOMY = GaleNode({
        ui_pos = Vector3(0, 3),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 1, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),

    -- COMBAT
    QUICK_CHARGE = GaleNode({
        ui_pos = Vector3(0, 3),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 3, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
        OnLearned = function(inst, is_load)
            inst.components.gale_weaponcharge.charge_speed_mult:SetModifier(inst, 1.66, "gale_skill_quick_charge")
        end,
        OnForget = function(inst)
            inst.components.gale_weaponcharge.charge_speed_mult:RemoveModifier(inst, "gale_skill_quick_charge")
        end,
    }),

    HARPY_WHIRL = GaleNode({
        ui_pos = Vector3(2, 3),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 2, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),

    CARRY_CHARGE = GaleNode({
        ui_pos = Vector3(1, 3),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 1, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),

    SPEAR_FRAGMENT = GaleNode({
        ui_pos = Vector3(0, 2),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 1, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),

    SPEAR_REMAIN = GaleNode({
        ui_pos = Vector3(1, 2),
        ingredients = {
            Ingredient("athetos_mushroom_cap", 3, "images/inventoryimages/athetos_mushroom_cap.xml"),
        },
    }),

    -- ENERGY
    KINETIC_BLAST = GaleNode({
        ui_pos = Vector3(0, 3),
        ingredients = {
            Ingredient("athetos_neuromod", 3, "images/inventoryimages/athetos_neuromod.xml"),
        },
        OnPressed = function(inst, x, y, z, ent)
            if not inst.sg:HasStateTag("dead")
                and not inst.sg:HasStateTag("busy")
                and not IsEntityDeadOrGhost(inst)
                and not (inst.components.rider and inst.components.rider:IsRiding())
                and not (inst.components.gale_skill_mimic and inst.components.gale_skill_mimic:IsMimic()) then
                local last_cast_time = inst.components.gale_skiller.skillmem.LastKineticBlastTime
                local cooldown = 4

                if last_cast_time == nil or GetTime() - last_cast_time >= cooldown then
                    if not (inst.components.gale_magic
                            and inst.components.gale_magic:CanUseMagic(20)) then
                        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], inst.userid,
                                           STRINGS.GALE_SKILL_CAST.FAILED.INSUFFICIENT_MAGIC)
                        return
                    end

                    inst.components.gale_magic:DoDelta(-20)

                    local tar_pos = Vector3(x, y, z)
                    inst.sg:GoToState("gale_skill_kinetic_blast", tar_pos)

                    inst.components.gale_skiller.skillmem.LastKineticBlastTime = GetTime()
                else
                    SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], inst.userid,
                                       string.format(STRINGS.GALE_SKILL_CAST.FAILED.COOLING_DOWN,
                                                     STRINGS.GALE_UI.SKILL_NODES.KINETIC_BLAST.NAME,
                                                     cooldown - (GetTime() - last_cast_time)))
                end
            end
        end,
    }),

    -- MORPH

    MIMIC_LV1 = GaleNode({
        ui_pos = Vector3(0, 3),
        ingredients = {
            Ingredient("athetos_neuromod", 2, "images/inventoryimages/athetos_neuromod.xml"),
        },
        OnPressed = function(inst, x, y, z, ent)
            if not inst.sg:HasStateTag("dead")
                and not inst.sg:HasStateTag("busy")
                and not IsEntityDeadOrGhost(inst)
                and not (inst.components.rider and inst.components.rider:IsRiding()) then
                local last_cast_time = inst.components.gale_skiller.skillmem.LastMimicTime

                if last_cast_time == nil or GetTime() - last_cast_time >= 1.0 then
                    if inst.components.gale_skill_mimic:IsMimic() then
                        inst.components.gale_skill_mimic:StopWithSG()
                    else
                        local is_valid, reason = inst.components.gale_skill_mimic:IsValidTarget(ent)
                        if not is_valid then
                            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], inst.userid, reason)
                            return
                        end

                        if not (inst.components.gale_magic
                                and inst.components.gale_magic:CanUseMagic(5)) then
                            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], inst.userid,
                                               STRINGS.GALE_SKILL_CAST.FAILED.INSUFFICIENT_MAGIC)
                            return
                        end

                        inst.sg:GoToState("gale_mimicing", {
                            target = ent,
                            targetpos = Vector3(x, y, z)
                        })
                        inst.components.gale_skiller.skillmem.LastMimicTime = GetTime()
                    end
                else
                    -- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"],inst.userid,string.format(STRINGS.GALE_SKILL_CAST.FAILED.COOLING_DOWN,STRINGS.GALE_UI.SKILL_NODES.MIMIC_LV1.NAME,GetTime() - last_cast_time))
                end
            end
        end,
    }),

    MIMIC_LV2 = GaleNode({
        ui_pos = Vector3(1, 3),
        ingredients = {
            Ingredient("athetos_neuromod", 4, "images/inventoryimages/athetos_neuromod.xml"),
        },
    }),

    REGENERATION = GaleNode({
        ui_pos = Vector3(1, 2),
        ingredients = {
            Ingredient("athetos_neuromod", 3, "images/inventoryimages/athetos_neuromod.xml"),
        },
        OnLearned = function(inst, is_load)
            inst:ListenForEvent("attacked", GLOBAL.GALE_SKILL_NODES.REGENERATION.data.on_owner_attacked)
        end,
        OnForget = function(inst)
            inst:RemoveEventCallback("attacked", GLOBAL.GALE_SKILL_NODES.REGENERATION.data.on_owner_attacked)
        end,
        on_owner_attacked = function(inst, data)
            local last_regeneration_time = inst.components.gale_skiller.skillmem.LastRegenerationTime
            local stacks = 10
            if last_regeneration_time ~= nil then
                local duration = 5
                local delta_time = GetTime() - last_regeneration_time

                -- print("delta_time = ",delta_time)
                if delta_time <= duration then
                    stacks = math.floor(10 * delta_time / duration)
                end
            end
            -- print("REGENERATION on_owner_attacked",inst,stacks)

            if stacks >= 1 then
                GaleCondition.AddCondition(inst, "condition_mending", stacks)
                inst.components.gale_skiller.skillmem.LastRegenerationTime = GetTime()
            end
        end,
    }),

    DIMENSION_JUMP = GaleNode({
        ui_pos = Vector3(0, 0),
        ingredients = {
            Ingredient("athetos_neuromod", 2, "images/inventoryimages/athetos_neuromod.xml"),
        },
    }),

    -- PSY

    PICKER_BUTTERFLY = GaleNode({
        ui_pos = Vector3(0, 3),
        ingredients = {
            Ingredient("athetos_neuromod", 2, "images/inventoryimages/athetos_neuromod.xml"),
        },
    }),

    LINKAGE = GaleNode({
        ui_pos = Vector3(0, 2),
        ingredients = {
            Ingredient("athetos_neuromod", 3, "images/inventoryimages/athetos_neuromod.xml"),
        },
        OnPressed = function(inst, x, y, z, ent)
            if not inst.sg:HasStateTag("dead")
                and not inst.sg:HasStateTag("busy")
                and not IsEntityDeadOrGhost(inst) then
                if ent == nil or not (ent.components.combat or ent.components.sleeper or ent.components.grogginess) then
                    local ents = TheSim:FindEntities(x, y, z, 3, nil, { "INLIMBO", "NOCLICK", "FX" })
                    for _, v in pairs(ents) do
                        if (v.components.combat or v.components.sleeper or v.components.grogginess) then
                            ent = v
                            break
                        end
                    end
                end

                if ent == nil or not (ent.components.combat or ent.components.sleeper or ent.components.grogginess) then
                    return
                end


                if not inst.components.gale_skill_linkage:IsLinked(ent) then
                    if not (inst.components.gale_magic
                            and inst.components.gale_magic:CanUseMagic(3)) then
                        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], inst.userid,
                                           STRINGS.GALE_SKILL_CAST.FAILED.INSUFFICIENT_MAGIC)
                        return
                    end
                    inst.components.gale_magic:DoDelta(-3)
                    inst.components.gale_skill_linkage:Add(ent)
                else
                    inst.components.gale_skill_linkage:Remove(ent)
                end
            end
        end,
    }),

    DARK_VISION = GaleNode({
        ui_pos = Vector3(1, 2),
        ingredients = {
            Ingredient("athetos_neuromod", 2, "images/inventoryimages/athetos_neuromod.xml"),
        },
        OnPressed_Client = function(inst, x, y, z, ent)
            if inst.components.gale_skill_dark_vision then
                if inst.replica.gale_skiller.skillmem.LastDarkVisionTime
                    and GetTime() - inst.replica.gale_skiller.skillmem.LastDarkVisionTime < 1 then
                    return
                end




                if inst.components.gale_skill_dark_vision:IsEnabled() then
                    if inst.components.gale_skill_dark_vision.HUD_hover then
                        inst.components.gale_skill_dark_vision.HUD_hover:End()
                        inst.components.gale_skill_dark_vision.HUD_hover = nil
                    end
                else
                    if not (inst.replica.gale_magic
                            and inst.replica.gale_magic:CanUseMagic(5)) then
                        ChatHistory:AddToHistory(ChatTypes.Announcement, nil, nil, nil,
                                                 STRINGS.GALE_SKILL_CAST.FAILED.INSUFFICIENT_MAGIC, { 1, 1, 1, 1 },
                                                 "default", true, true)
                        return
                    end

                    if inst.components.gale_skill_dark_vision.HUD_hover == nil then
                        inst.components.gale_skill_dark_vision.HUD_hover = inst.HUD.controls:AddChild(
                            GaleDarkVisionHover(inst))
                    end
                    inst.components.gale_skill_dark_vision.HUD_hover:MoveToFront()
                    inst.components.gale_skill_dark_vision.HUD_hover:Start()
                end

                inst.replica.gale_skiller.skillmem.LastDarkVisionTime = GetTime()
            end
        end,
    })


}

GLOBAL.GALE_SKILL_TREE = {
    SURVIVAL = GaleMultiTree({}),
    SCIENCE = GaleMultiTree({}),
    COMBAT = GaleMultiTree({}),

    ENERGY = GaleMultiTree({}),
    MORPH = GaleMultiTree({}),
    PSY = GaleMultiTree({}),
}

for name, node in pairs(GLOBAL.GALE_SKILL_NODES) do
    node.data.code_name = string.lower(name)
end

for name, node in pairs(GLOBAL.GALE_SKILL_TREE) do
    node.root.data.code_name = string.lower(name)
end



-- SURVIVAL
GLOBAL.GALE_SKILL_NODES.DOCTOR:AddChilds({
    GLOBAL.GALE_SKILL_NODES.BURGER_EATER,
    -- GLOBAL.GALE_SKILL_NODES.DISSECT
})

GLOBAL.GALE_SKILL_NODES.ROLLING:AddChilds({
    -- GLOBAL.GALE_SKILL_NODES.ROLLING_BOMB,
    GLOBAL.GALE_SKILL_NODES.SHOU_SHEN,
    GLOBAL.GALE_SKILL_NODES.PARRY,
})
-- GLOBAL.GALE_SKILL_NODES.ROLLING_BOMB:AddChilds({
--     GLOBAL.GALE_SKILL_NODES.ROLLING_SMOKE
-- })

GLOBAL.GALE_SKILL_TREE.SURVIVAL.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.DOCTOR, GLOBAL.GALE_SKILL_NODES.ROLLING
})

-- COMBAT
GLOBAL.GALE_SKILL_NODES.QUICK_CHARGE:AddChilds({
    GLOBAL.GALE_SKILL_NODES.CARRY_CHARGE,
})

GLOBAL.GALE_SKILL_NODES.CARRY_CHARGE:AddChilds({
    GLOBAL.GALE_SKILL_NODES.HARPY_WHIRL,
})

GLOBAL.GALE_SKILL_NODES.SPEAR_FRAGMENT:AddChilds({
    GLOBAL.GALE_SKILL_NODES.SPEAR_REMAIN,
})

GLOBAL.GALE_SKILL_TREE.COMBAT.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.QUICK_CHARGE,
    GLOBAL.GALE_SKILL_NODES.SPEAR_FRAGMENT,
})

-- SCIENCE
GLOBAL.GALE_SKILL_TREE.SCIENCE.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.ANATOMY,
})

-- ENERGY
GLOBAL.GALE_SKILL_TREE.ENERGY.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.KINETIC_BLAST,
})

-- MORPH
GLOBAL.GALE_SKILL_TREE.MORPH.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.MIMIC_LV1,
    GLOBAL.GALE_SKILL_NODES.DIMENSION_JUMP,
})

GLOBAL.GALE_SKILL_NODES.MIMIC_LV1:AddChilds({
    GLOBAL.GALE_SKILL_NODES.MIMIC_LV2,
    GLOBAL.GALE_SKILL_NODES.REGENERATION
})

-- PSY
GLOBAL.GALE_SKILL_NODES.LINKAGE:AddChilds({
    GLOBAL.GALE_SKILL_NODES.DARK_VISION,
})

GLOBAL.GALE_SKILL_TREE.PSY.root:AddChilds({
    GLOBAL.GALE_SKILL_NODES.PICKER_BUTTERFLY,
    GLOBAL.GALE_SKILL_NODES.LINKAGE,
})

----------------------------------------------------------------------------------
local function IsHUDScreen()
    local defaultscreen = false
    if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and type(TheFrontEnd:GetActiveScreen().name) == "string" and TheFrontEnd:GetActiveScreen().name == "HUD" then
        defaultscreen = true
    end
    return defaultscreen
end

AddModRPCHandler("gale_rpc", "cast_skill", function(inst, name, pressed, x, y, z, ent)
    local data = GLOBAL.GALE_SKILL_NODES[name:upper()].data
    local is_learned = inst.components.gale_skiller:IsLearned(data.code_name)


    if is_learned then
        if pressed then
            if data.OnPressed then
                data.OnPressed(inst, x, y, z, ent)
            end
        else
            if data.OnReleased then
                data.OnReleased(inst, x, y, z, ent)
            end
        end
    end
end)

AddModRPCHandler("gale_rpc", "unlock_skill", function(inst, name)
    local data = GLOBAL.GALE_SKILL_NODES[name:upper()].data
    local is_learned = inst.components.gale_skiller:IsLearned(data.code_name)
    if not is_learned then
        if data.ingredients then
            for k, v in pairs(data.ingredients) do
                local has, num_found = inst.components.inventory:Has(v.type, v.amount)
                if not has then
                    return
                end
            end

            for k, v in pairs(data.ingredients) do
                inst.components.inventory:ConsumeByName(v.type, v.amount)
            end
        end

        inst.components.gale_skiller:Learn(name)
    end
end)

AddModRPCHandler("gale_rpc", "press_space_and_carry_charge", function(inst)
    if inst.components.gale_weaponcharge:IsComplete() and inst.components.gale_skiller:IsLearned("carry_charge") then
        -- inst._just_use_carry_charge = true

        GaleCondition.AddCondition(inst, "condition_carry_charge")
        -- inst:ClearBufferedAction()
        inst.sg:GoToState("gale_carry_charge_pst")
    end
end)

-- AddModRPCHandler("gale_rpc","set_just_use_carry_charge",function(inst,val)
--     inst._just_use_carry_charge = val
-- end)

AddModRPCHandler("gale_rpc", "athetos_treasure_mimic_cast", function(inst, treasure)
    treasure.sg:GoToState("deploy")
end)

AddClientModRPCHandler("gale_rpc", "enable_movement_prediction", function(enable)
    if ThePlayer and ThePlayer:IsValid() then
        ThePlayer:EnableMovementPrediction(enable)
    end
end)

AddModRPCHandler("gale_rpc", "dark_vision_ui2server", function(inst, enable)
    if inst.components.gale_skiller
        and inst.components.gale_skiller:IsLearned("dark_vision")
        and inst.components.gale_skill_dark_vision then
        inst.components.gale_skill_dark_vision:Enable(enable)
    end
end)

AddClientModRPCHandler("gale_rpc", "dark_vision_server2sui", function()
    if ThePlayer.components.gale_skill_dark_vision
        and ThePlayer.components.gale_skill_dark_vision.HUD_hover then
        ThePlayer.components.gale_skill_dark_vision.HUD_hover:End()
        ThePlayer.components.gale_skill_dark_vision.HUD_hover = nil
    end
end)



TheInput:AddKeyHandler(function(key, down)
    if not IsHUDScreen() then
        return
    end

    -- Handle normal skill casting
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.replica and ThePlayer.replica.gale_skiller then
        local name = ThePlayer.replica.gale_skiller.keyhandler[key]
        local node = name and GLOBAL.GALE_SKILL_NODES[name:upper()]

        if node and ThePlayer.replica.gale_skiller:IsLearned(name) then
            local x, y, z = TheInput:GetWorldPosition():Get()
            local ent = TheInput:GetWorldEntityUnderMouse()

            if node.data.OnPressed_Client and down then
                node.data.OnPressed_Client(ThePlayer, x, y, z, ent)
            end
            if node.data.OnReleased_Client and not down then
                node.data.OnReleased_Client(ThePlayer, x, y, z, ent)
            end
            SendModRPCToServer(MOD_RPC["gale_rpc"]["cast_skill"], name, down, x, y, z, ent)
        end
    end
end)

TheInput:AddGeneralControlHandler(function(control, pressed)
    if not IsHUDScreen() then
        return
    end

    -- Handle "press space and carry charge"
    if pressed and control == CONTROL_ACTION then
        if ThePlayer and ThePlayer:IsValid()
            and not ThePlayer:HasTag("gale_skill_carry_charge_trigger")
            and ThePlayer.replica
            and ThePlayer.replica.gale_skiller
            and ThePlayer.replica.gale_weaponcharge:IsComplete()
            and ThePlayer.replica.gale_skiller:IsLearned("carry_charge") then
            -- ThePlayer:ClearBufferedAction()

            ThePlayer._just_use_carry_charge = true
            print("ThePlayer._just_use_carry_charge set to true")
            SendModRPCToServer(MOD_RPC["gale_rpc"]["press_space_and_carry_charge"])
        end
    end

    if not pressed and control == CONTROL_SECONDARY then
        -- if ThePlayer._set_just_use_carry_charge_false_task then
        --     ThePlayer._set_just_use_carry_charge_false_task:Cancel()
        -- end
        -- ThePlayer._set_just_use_carry_charge_false_task = ThePlayer:DoTaskInTime(0.33,function()
        --     print("ThePlayer._just_use_carry_charge set to false")
        --     ThePlayer._just_use_carry_charge = false
        --     ThePlayer._set_just_use_carry_charge_false_task = nil

        --     -- SendModRPCToServer(MOD_RPC["gale_rpc"]["set_just_use_carry_charge"],false)
        -- end)
        ThePlayer._just_use_carry_charge = false
    end
end)


-- Double tap MOVE Btns and dodge
local dodge_doubletap_btns = {
    [CONTROL_MOVE_UP] = function()
        return -TheCamera:GetDownVec()
    end,
    [CONTROL_MOVE_DOWN] = function()
        return TheCamera:GetDownVec()
    end,
    [CONTROL_MOVE_LEFT] = function()
        return -TheCamera:GetRightVec()
    end,
    [CONTROL_MOVE_RIGHT] = function()
        return TheCamera:GetRightVec()
    end,
}

for key, fn in pairs(dodge_doubletap_btns) do
    TheInput:AddControlHandler(key, function(pressed)
        if GetModConfigData("gale_doubletap_arrow_to_dodge", nil, true) ~= true then
            return
        end

        if not IsHUDScreen() then
            return
        end

        if not pressed then
            return
        end

        -- print("dodge_doubletap",key,ThePlayer._dodge_doubletap_time ~= nil and (GetTime() - ThePlayer._dodge_doubletap_time))
        -- print(GetTime(),ThePlayer._dodge_doubletap_time)
        if ThePlayer and ThePlayer:IsValid()
            and ThePlayer.replica
            and ThePlayer.replica.gale_skiller
            and ThePlayer.replica.gale_skiller:IsLearned("rolling") then
            -- if ThePlayer._dodge_doubletap_btn == nil then
            --     ThePlayer._dodge_doubletap_btn = key
            --     ThePlayer._dodge_doubletap_time = GetTime()
            -- elseif GetTime()

            -- end
            if ThePlayer._dodge_doubletap_btn == key and ThePlayer._dodge_doubletap_time and GetTime() - ThePlayer._dodge_doubletap_time <= 0.22 then
                local pos = ThePlayer:GetPosition()
                local offset = fn()
                -- local dodgefn = GLOBAL.GALE_SKILL_NODES.ROLLING.data.OnPressed
                -- OnPressed = function(inst,x,y,z,ent)

                -- SendModRPCToClient()
                SendModRPCToServer(MOD_RPC["gale_rpc"]["cast_skill"], "ROLLING", true, (pos + offset):Get())

                ThePlayer._dodge_doubletap_btn = nil
                ThePlayer._dodge_doubletap_time = nil
            else
                ThePlayer._dodge_doubletap_btn = key
                ThePlayer._dodge_doubletap_time = GetTime()
            end
        end
    end)
end

----------------------------------------------------------------------------------


local DODGE_TIMEOUT = 0.33
-- gale_dodge
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_dodge",
                       tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },

                       onenter = function(inst, data)
                           if data.is_shadow then
                               GaleCommon.ToggleOffPhysics(inst)
                               inst.components.gale_skill_shadow_dodge:Enable(true)
                           end

                           inst.components.locomotor:Stop()
                           if data.is_shadow then
                               if not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                                   -- inst.AnimState:ClearOverrideSymbol("swap_object")

                                   inst.AnimState:PlayAnimation("gale_speedrun_loop")
                               else
                                   inst.AnimState:PlayAnimation("gale_speedrun_withitem_loop")
                               end
                           else
                               inst.AnimState:PlayAnimation("slide_pre")
                               inst.AnimState:PushAnimation("slide_loop")
                           end

                           inst:ForceFacePoint(data.targetpos:Get())
                           inst.Physics:SetMotorVelOverride(20, 0, 0)

                           inst.components.locomotor:EnableGroundSpeedMultiplier(false)




                           inst.sg.statemem.beginpos = inst:GetPosition()
                           inst.sg.statemem.targetpos = data.targetpos
                           inst.sg.statemem.missfxs = {}
                           inst.sg.statemem.is_shadow = data.is_shadow

                           if data.is_shadow then
                               local vfx = SpawnPrefab("gale_shadow_dodge_vfx")
                               vfx.entity:SetParent(inst.entity)
                               vfx.entity:AddFollower()
                               vfx.Follower:FollowSymbol(inst.GUID, "torso", 0, -65, 0)
                               table.insert(inst.sg.statemem.missfxs, vfx)

                               local vfx2 = SpawnPrefab("gale_shadow_dodge_vfx")
                               vfx2.entity:SetParent(inst.entity)
                               vfx2.entity:AddFollower()
                               vfx2.Follower:FollowSymbol(inst.GUID, "torso", 0, -125, 0)
                               table.insert(inst.sg.statemem.missfxs, vfx2)

                               local vfx3 = SpawnPrefab("gale_shadow_dodge_vfx")
                               vfx3.entity:SetParent(inst.entity)
                               vfx3.entity:AddFollower()
                               vfx3.Follower:FollowSymbol(inst.GUID, "torso", 0, -180, 0)
                               table.insert(inst.sg.statemem.missfxs, vfx3)

                               inst.SoundEmitter:PlaySound("gale_sfx/skill/hero_shade_dash_1")
                           else
                               table.insert(inst.sg.statemem.missfxs, inst:SpawnChild("gale_speedrun_vfx"))

                               inst.SoundEmitter:PlaySound("gale_sfx/battle/enm_archer_dodge1")
                           end

                           inst.sg.statemem.should_circle = data.should_circle

                           inst.sg:SetTimeout(DODGE_TIMEOUT)
                       end,

                       onupdate = function(inst)
                           inst.Physics:SetMotorVelOverride(inst.sg.statemem.is_shadow and 30 or 25, 0, 0)
                       end,

                       timeline =
                       {

                       },

                       ontimeout = function(inst)
                           if not inst.sg.statemem.is_shadow then
                               inst.AnimState:PlayAnimation("slide_pst")
                           else
                               if not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                                   inst.AnimState:PlayAnimation("gale_speedrun_pst")
                               else
                                   inst.AnimState:PlayAnimation("gale_speedrun_withitem_pst")
                               end
                           end

                           if inst.sg.statemem.should_circle then
                               inst.sg:GoToState("gale_harpy_whirl")
                           else
                               inst.sg:GoToState("idle", true)
                           end
                       end,

                       onexit = function(inst)
                           inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                           inst.Physics:ClearMotorVelOverride()
                           inst.components.locomotor:Stop()

                           for k, v in pairs(inst.sg.statemem.missfxs) do
                               if v and v:IsValid() then
                                   v:Remove()
                               end
                           end

                           if inst.sg.statemem.is_shadow then
                               GaleCommon.ToggleOnPhysics(inst)
                               inst.components.gale_skill_shadow_dodge:Enable(false)
                           end
                       end,
                   }
)

-- gale_fangun
AddStategraphState("wilson", State {
    name = "gale_fangun",
    tags = { "busy", "evade", "no_stun", "nopredict" },

    onenter = function(inst, data)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()
        inst:ForceFacePoint(data.targetpos:Get())

        GaleCommon.ToggleOffPhysics(inst)

        inst.sg.statemem.ball = SpawnAt("gale_rolling_low_stamina", inst)
        inst.sg.statemem.ball:ForceFacePoint(data.targetpos:Get())
        inst.sg.statemem.ball.Physics:SetMotorVel(30, 0, 0)

        inst.sg.statemem.fx = inst:SpawnChild("gale_speedrun_vfx")

        inst:Hide()
        -- inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close")

        inst.SoundEmitter:PlaySound("gale_sfx/character/gale_roll_short")
        -- inst.SoundEmitter:PlaySound("gale_sfx/battle/enm_archer_dodge1")

        inst.sg:SetTimeout(0.27)
    end,

    onupdate = function(inst)
        if inst.sg.statemem.ball then
            inst.sg.statemem.ball.Physics:SetMotorVel(30, 0, 0)
            inst.Transform:SetPosition(inst.sg.statemem.ball:GetPosition():Get())
        end
    end,

    ontimeout = function(inst)
        inst:Show()
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:GoToState("idle", true)
    end,

    timeline =
    {

    },

    onexit = function(inst)
        inst.Physics:Stop()
        inst.components.locomotor:Stop()
        inst:Show()
        if inst.sg.statemem.ball then
            inst.sg.statemem.ball:Remove()
        end

        if inst.sg.statemem.fx then
            inst.sg.statemem.fx:Remove()
        end

        GaleCommon.ToggleOnPhysics(inst)
        -- inst.SoundEmitter:KillSound("gale_roll")
    end,
}
)

-- gale_mimicing
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_mimicing",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst, data)
                           local fx = SpawnAt("gale_skill_mimic_fx", inst)

                           inst:ForceFacePoint(data.targetpos:Get())

                           inst.AnimState:SetMultColour(0, 0, 0, 1)
                           inst.AnimState:PlayAnimation("pickup")

                           inst.sg.statemem.target = data and data.target
                           inst.sg.statemem.fx = fx

                           inst.components.playercontroller:Enable(false)
                           SpawnAt("statue_transition_2", inst)

                           inst.SoundEmitter:PlaySound("gale_sfx/skill/mimic_pre")

                           inst.sg:SetTimeout(2.2)
                       end,


                       timeline =
                       {
                           TimeEvent(48 * FRAMES, function(inst)
                               inst:Hide()
                           end),
                       },

                       ontimeout = function(inst)
                           inst.sg:GoToState("idle")
                       end,

                       onexit = function(inst)
                           -- inst.Transform:SetFourFaced()

                           -- inst.AnimState:SetBank("wilson")
                           -- inst.AnimState:SetBuild(inst.prefab)
                           -- ThePlayer.AnimState:SetDeltaTimeMultiplier(0.33)
                           -- inst.AnimState:SetDeltaTimeMultiplier(1)
                           inst.AnimState:SetMultColour(1, 1, 1, 1)
                           SpawnAt("statue_transition_2", inst)
                           if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                               inst.components.gale_skill_mimic:Start(inst.sg.statemem.target)
                           else
                               inst:Show()
                           end
                           if inst.sg.statemem.fx then
                               inst.sg.statemem.fx:Remove()
                               inst.sg.statemem.fx = nil
                           end
                           inst.components.playercontroller:Enable(true)
                       end,
                   }
)

-- gale_mimicing_pst
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_mimicing_pst",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst)
                           inst.components.locomotor:Stop()
                           -- inst:ClearBufferedAction()
                           inst.AnimState:PlayAnimation("pickup_pst")
                           SpawnAt("statue_transition_2", inst)

                           inst.sg:SetTimeout(2)
                       end,

                       ontimeout = function(inst)
                           inst.sg:GoToState("idle")
                       end,

                       events = {
                           EventHandler("animover", function(inst)
                               if inst.AnimState:AnimDone() then
                                   inst.sg:GoToState("idle")
                               end
                           end),
                       },

                   }
)
-- ThePlayer.sg:GoToState("gale_super_jump_loop")
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_super_jump_loop",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst, target_pos)
                           target_pos = target_pos or inst:GetPosition()
                           inst.components.locomotor:Stop()
                           inst:ClearBufferedAction()

                           inst.Transform:SetPosition((target_pos + Vector3(0, 5, 0)):Get())
                           inst.AnimState:PlayAnimation("boat_jump_loop", true)
                           -- inst.AnimState:SetDeltaTimeMultiplier(0.1)

                           inst.sg:SetTimeout(0.66)
                       end,

                       timeline = {
                           TimeEvent(10 * FRAMES, function(inst)
                               -- inst.AnimState:Pause()
                           end),
                       },

                       ontimeout = function(inst)
                           inst.sg:GoToState("gale_super_jump_pst")
                       end,

                       onexit = function(inst)
                           inst.AnimState:SetDeltaTimeMultiplier(1)
                           inst.AnimState:Resume()
                       end,
                   }
)

-- gale_super_jump_pst
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_super_jump_pst",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst)
                           local pos = inst:GetPosition()
                           pos.y = 0
                           inst.Transform:SetPosition(pos:Get())

                           inst.components.locomotor:Stop()
                           inst:ClearBufferedAction()

                           inst.AnimState:PlayAnimation("superjump_land")
                           inst.AnimState:SetTime(2 * FRAMES)
                       end,

                       events = {
                           EventHandler("animover", function(inst)
                               if inst.AnimState:AnimDone() then
                                   inst.sg:GoToState("idle")
                               end
                           end),
                       },
                   }
)

-- ThePlayer.sg:GoToState("gale_harpy_whirl")
AddStategraphState("wilson",
                   State
                   {
                       name = "gale_harpy_whirl",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst)
                           inst.components.locomotor:Stop()

                           inst.Transform:SetTwoFaced()

                           inst.AnimState:SetDeltaTimeMultiplier(1.5)
                           inst.AnimState:PlayAnimation("galeatk_circle0")
                           inst.AnimState:PushAnimation("galeatk_circle2", false)
                           inst.AnimState:PushAnimation("galeatk_circle3", false)

                           inst.SoundEmitter:PlaySound("gale_sfx/character/gale_harpy_whirl")

                           local fx = SpawnAt("gale_circleslash_fx", inst)
                           fx.Transform:SetRotation(inst.Transform:GetRotation())
                           fx.AnimState:SetAddColour(0, 1, 1, 1)

                           if GaleCondition.GetCondition(inst, "condition_carry_charge") ~= nil then
                               GaleCondition.RemoveCondition(inst, "condition_carry_charge")
                           end


                           inst.sg.statemem.cast_fn = function(knockback)
                               GaleCommon.AoeForEach(inst, inst:GetPosition(), 4.3, nil, { "INLIMBO" }, { "_combat" },
                                                     function(doer, other)
                                                         doer.components.combat.ignorehitrange = true
                                                         doer.components.combat:DoAttack(other,
                                                                                         doer.components.combat
                                                                                         :GetWeapon(), nil, nil,
                                                                                         GetRandomMinMax(1, 1.2))
                                                         doer.components.combat.ignorehitrange = false

                                                         if knockback or other.components.health:IsDead() then
                                                             other:PushEvent("knockback", { knocker = doer, radius = 8 })
                                                         end

                                                         SpawnPrefab("gale_hit_color_adder"):SetTarget(other)
                                                     end,
                                                     function(doer, other)
                                                         return doer.components.combat:CanTarget(other) and
                                                             not doer.components.combat:IsAlly(other)
                                                     end)
                           end

                           inst.sg.statemem.emit_fn = function(emit_angle)
                               for i = 1, 3 do
                                   local noise_angle = emit_angle + math.random(-30, 30)
                                   noise_angle = noise_angle * PI / 180
                                   local face_pos = Vector3(math.cos(noise_angle), 0, math.sin(noise_angle)) *
                                       GetRandomMinMax(1.8, 2.2)
                                   local fx = SpawnAt("gale_bluerock_fx", inst:GetPosition() + face_pos)
                                   fx:ForceFacePoint((fx:GetPosition() + face_pos):Get())
                                   fx.Physics:SetMotorVel(2.5, 0, 0)
                                   fx.AnimState:SetScale(1.6, 1.6, 1.6)
                                   -- fx.AnimState:SetDeltaTimeMultiplier(1.5)

                                   fx:DoTaskInTime(0.6, function()
                                       GaleCommon.FadeTo(fx, GetRandomMinMax(0.2, 0.8), nil, {
                                                             Vector4(1, 1, 1, 1),
                                                             Vector4(0, 0, 0, 0),
                                                         }, nil, function()
                                                             fx:Remove()
                                                         end)

                                       fx:DoPeriodicTask(0, function()
                                           local vx, _, _ = fx.Physics:GetMotorVel()
                                           fx.Physics:SetMotorVel(math.max(0, vx - FRAMES * 5), 0, 0)
                                       end)
                                   end)
                               end
                           end
                       end,

                       events = {
                           EventHandler("animover", function(inst)
                               if inst.AnimState:AnimDone() then
                                   -- inst.AnimState:PlayAnimation("slide_pst")
                                   inst.sg:GoToState("idle", true)
                               end
                           end),

                           EventHandler("onhitother", function(inst, data)
                               if data.target then
                                   data.target:SpawnChild("gale_quick_spark_vfx")._color_set:set("blue")
                                   if inst.sg.statemem.last_sound_time == nil or GetTime() - inst.sg.statemem.last_sound_time >= 1.9 * FRAMES then
                                       inst.sg.statemem.last_sound_time = GetTime()
                                       if data.target.SoundEmitter then
                                           data.target.SoundEmitter:PlaySound("gale_sfx/battle/P1_punchF")
                                       end
                                   end
                               end
                           end),
                       },

                       timeline = {
                           TimeEvent(1 * FRAMES, function(inst)
                               inst.sg.statemem.cast_fn(false)
                               inst.sg.statemem.emit_fn(inst.Transform:GetRotation() + 120)
                               ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
                           end),

                           TimeEvent(3 * FRAMES, function(inst)
                               inst.sg.statemem.cast_fn(false)
                               inst.sg.statemem.emit_fn(inst.Transform:GetRotation() + 240)
                               ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
                           end),

                           TimeEvent(6 * FRAMES, function(inst)
                               inst.sg.statemem.cast_fn(true)
                               inst.sg.statemem.emit_fn(inst.Transform:GetRotation() + 360)
                               ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
                           end),
                       },

                       onexit = function(inst)
                           inst.AnimState:SetDeltaTimeMultiplier(1)
                           inst.Transform:SetFourFaced()
                       end,
                   }
)

AddStategraphState("wilson",
                   State
                   {
                       name = "gale_skill_kinetic_blast",
                       tags = { "busy", "nopredict", "nointerrupt" },

                       onenter = function(inst, target_pos)
                           inst.components.locomotor:Stop()
                           inst:ClearBufferedAction()

                           inst:ForceFacePoint(target_pos:Get())

                           inst.AnimState:PlayAnimation("hand_shoot")

                           inst.sg.statemem.target_pos = target_pos
                           inst.sg.statemem.carry_fx = inst:SpawnChild("gale_skill_kinetic_blast_carry_vfx")
                           inst.sg.statemem.carry_fx.entity:AddFollower()
                           inst.sg.statemem.carry_fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)

                           inst.SoundEmitter:PlaySound("gale_sfx/skill/launch_pre3")
                       end,

                       timeline = {
                           TimeEvent(15 * FRAMES, function(inst)
                               -- inst.AnimState:Pause()
                               local percent = inst.AnimState:GetCurrentAnimationTime() /
                                   inst.AnimState:GetCurrentAnimationLength()
                               inst.AnimState:SetPercent("hand_shoot", percent)
                           end),

                           TimeEvent(40 * FRAMES, function(inst)
                               local anim_time = inst.AnimState:GetCurrentAnimationTime()
                               inst.AnimState:PlayAnimation("hand_shoot")
                               inst.AnimState:SetTime(anim_time)

                               if inst.sg.statemem.carry_fx then
                                   inst.sg.statemem.carry_fx:Remove()
                                   inst.sg.statemem.carry_fx = nil
                               end

                               local vfx = inst:SpawnChild("gale_skill_kinetic_blast_launch_vfx")
                               vfx.entity:AddFollower()
                               vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)
                               vfx:DoTaskInTime(1, vfx.Remove)

                               inst.AnimState:Resume()

                               local proj = SpawnAt("gale_skill_kinetic_blast_projectile", inst)
                               proj.components.complexprojectile:Launch(inst.sg.statemem.target_pos, inst)

                               ShakeAllCameras(CAMERASHAKE.FULL, .35, .01, 0.25, inst, 33)

                               inst.SoundEmitter:PlaySound("gale_sfx/skill/launch2")
                               -- inst.SoundEmitter:KillSound("cast")
                           end),
                       },

                       events = {
                           EventHandler("animover", function(inst)
                               inst.sg:GoToState("idle")
                           end)
                       },

                       onexit = function(inst)
                           inst.AnimState:Resume()
                           inst.SoundEmitter:KillSound("cast")

                           if inst.sg.statemem.carry_fx then
                               inst.sg.statemem.carry_fx:Remove()
                               inst.sg.statemem.carry_fx = nil
                           end
                       end,
                   }
)

AddStategraphState("wilson", State {
    name = "gale_parry_pre",
    tags = { "preparrying", "parrying", "busy", "nomorph", "nopredict" },

    onenter = function(inst, data)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("parry_pre")
        inst.AnimState:PushAnimation("parry_loop", true)

        inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

        inst.sg.statemem.parrytime = 99999
        inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli)
            return inst.components.gale_skill_parry
                and inst.components.gale_skill_parry:TryParry(attacker, damage, weapon, stimuli)
        end
    end,

    ontimeout = function(inst)
        inst.sg.statemem.parrying = true
        inst.sg:GoToState("parry_idle", { duration = inst.sg.statemem.parrytime, pauseframes = 30 })
    end,

    onexit = function(inst)
        if not inst.sg.statemem.parrying then
            inst.components.combat.redirectdamagefn = nil
        end
    end,
})

AddStategraphState("wilson", State {
    name = "gale_parry_counter_near",
    tags = { "attack", "busy", "nomorph" },

    onenter = function(inst, data)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("lunge_pst")

        if data and data.target then
            inst:ForceFacePoint(data.target:GetPosition())

            inst.sg.statemem.target = data.target
            inst.sg.statemem.pos = data.target:GetPosition()
        end



        inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
    end,

    timeline = {
        TimeEvent(2 * FRAMES, function(inst)
            if inst.sg.statemem.pos then
                GaleCommon.AoeDoAttack(
                    inst,
                    inst.sg.statemem.pos,
                    1.3,
                    {
                        weapon = inst.components.combat:GetWeapon(),
                        instancemult = 2,
                        ignorehitrange = true,
                    }
                )
            end
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),

        TimeEvent(8 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end),
    },

    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },


    onexit = function(inst)
        -- inst.components.health:SetInvincible(false)
    end,
})

----------------------------------------------------------------------------------
-- c_testtree(true)
-- GLOBAL.c_testtree = function(return_whole_node)
--     local tree = GaleMultiTree("A")

--     local Bnode = GaleNode("B")
--     local Cnode = GaleNode("C")
--     local Dnode = GaleNode("D")
--     local Enode = GaleNode("E")
--     local Fnode = GaleNode("F")
--     local Gnode = GaleNode("G")
--     local Hnode = GaleNode("H")

--     --    A
--     --  /   \
--     -- B     C
--     -- |     |
--     -- DEF   GH

--     tree.root:AddChilds({
--         Bnode,Cnode
--     })
--     Bnode:AddChilds({
--         Dnode,Enode,Fnode
--     })
--     Cnode:AddChilds({
--         Gnode,Hnode
--     })



--     dumptable(tree:ListByLeft(return_whole_node))
-- end

-- c_throw_p(Vector3(10,4,0),9.8)

-- AddPrefabPostInitAny(function(inst)
--     if not (inst.prefab and inst.prefab:find("chesspiece_") and inst.components.heavyobstaclephysics) then
--         return
--     end

--     if not TheWorld.ismastersim then
--         return
--     end

--     inst.components.heavyobstaclephysics:AddFallingStates()
-- end)

AddPrefabPostInitAny(function(inst)
    if inst:HasTag("shadowcreature") then
        if inst.HostileToPlayerTest ~= nil then
            local old_HostileToPlayerTest = inst.HostileToPlayerTest
            inst.HostileToPlayerTest = function(inst, player, ...)
                return old_HostileToPlayerTest(inst, player, ...) or (
                    player.components.gale_skill_dark_vision
                    and player.components.gale_skill_dark_vision:IsEnabled()
                )
            end

            -- if not TheNet:IsDedicated() then
            --     -- this is purely view related
            --     if inst.components.transparentonsanity then

            --         inst.components.transparentonsanity:ForceUpdate()
            --     end

            -- end
        end
    end

    if not TheWorld.ismastersim then
        return
    end
end)

AddComponentPostInit("transparentonsanity", function(self)
    local old_CalcaulteTargetAlpha = self.CalcaulteTargetAlpha
    self.CalcaulteTargetAlpha = function(self, ...)
        local player = ThePlayer
        if player
            and player.components.gale_skill_dark_vision
            and player.components.gale_skill_dark_vision:IsEnabled() then
            return self.most_alpha
        end

        return old_CalcaulteTargetAlpha(self, ...)
    end
end)

-- AddGlobalClassPostConstruct("components/combat_replica","Combat",function(self)
--     local old_CanBeAttacked = self.CanBeAttacked
--     self.CanBeAttacked = function(self,attacker,...)

--         return old_CanBeAttacked(self,attacker,...) or (
--             self.inst:HasTag("shadowcreature")
--             and attacker
--             and attacker.components.gale_skill_dark_vision
--             and attacker.components.gale_skill_dark_vision:IsEnabled()
--         )

--     end
-- end)

-- AddComponentPostInit("combat_replica",function(self)
--     local old_CanBeAttacked = self.CanBeAttacked
--     self.CanBeAttacked = function(self,attacker,...)

--         return old_CanBeAttacked(self,attacker,...) or (
--             self.inst:HasTag("shadowcreature")
--             and attacker.components.gale_skill_dark_vision
--             and attacker.components.gale_skill_dark_vision:IsEnabled()
--         )

--     end
-- end)





GLOBAL.c_throw_p = function(speed_init, gravity)
    gravity = gravity or 29
    local pos = TheInput:GetWorldPosition()
    local heavy_obj = SpawnAt("chesspiece_guardianphase3", ThePlayer:GetPosition() + Vector3(0, 1, 0))

    heavy_obj:PushEvent("startfalling")

    heavy_obj:ForceFacePoint(pos:Get())
    heavy_obj.Physics:SetMotorVel(speed_init:Get())
    heavy_obj.vel = speed_init

    heavy_obj.falltask = heavy_obj:DoPeriodicTask(0, function()
        local x, y, z = heavy_obj.Transform:GetWorldPosition()

        local vx, vy, vz = heavy_obj.vel:Get()
        heavy_obj.vel = Vector3(vx, vy - gravity * FRAMES, vz)
        heavy_obj.Physics:SetMotorVel(heavy_obj.vel:Get())

        if vy <= 0 and y <= 0.01 then
            heavy_obj:PushEvent("stopfalling")
            heavy_obj.Transform:SetPosition(x, 0, z)

            heavy_obj.Physics:Stop()

            if heavy_obj.falltask then
                heavy_obj.falltask:Cancel()
                heavy_obj.falltask = nil
            end

            -- heavy_obj:Remove()
        end
    end)
end
