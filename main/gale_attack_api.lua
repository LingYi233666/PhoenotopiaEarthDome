local GaleStateGraphs = require "util/gale_stategraphs"
local GaleCommon = require("util/gale_common")
local UpvalueHacker = require("util/upvaluehacker")
local GaleCondition = require("util/gale_conditions")

require("entityscript")

AddReplicableComponent("gale_weaponcharge")

-- Hack aoe actions
print("[GaleMod]Hack aoe actions:")
local COMPONENT_ACTIONS = UpvalueHacker.GetUpvalue(EntityScript.IsActionValid,
                                                   "COMPONENT_ACTIONS")
local aoespell_fn = COMPONENT_ACTIONS.POINT.aoespell
-- COMPONENT_ACTIONS.POINT.aoespell = function(inst, doer, pos, actions, right)
--     for k,v in pairs(actions) do
--         if v.rmb == true and v ~= ACTIONS.CASTAOE then
--             return
--         end
--     end

--     return aoespell_fn(inst, doer, pos, actions, right)
-- end
-- ThePlayer.components.playercontroller:OnRightClick(true)
-- TheWorld:DoTaskInTime(1,function() print(ThePlayer.components.playercontroller:GetRightMouseAction()[1]) end)
-- print(ThePlayer.components.playeractionpicker:GetRightClickActions(TheInput:GetWorldPosition(), TheInput:GetWorldEntityUnderMouse())[1])
-- print(ThePlayer.components.playeractionpicker:GetEquippedItemActions(TheInput:GetWorldEntityUnderMouse(), ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS), true))

-- ACTIONS.CASTAOE.priority = -1
AddComponentPostInit("playercontroller", function(self)
    -- local old_TryAOETargeting = self.TryAOETargeting
    -- self.TryAOETargeting = function(self,...)
    --     local position = TheInput:GetWorldPosition()
    --     local target = TheInput:GetWorldEntityUnderMouse()
    --     local right_action = self.inst.components.playeractionpicker:GetRightClickActions(position, target)[1]
    --     if right_action ~= nil and right_action.action ~= ACTIONS.CASTAOE then
    --         return false
    --     end

    --     return old_TryAOETargeting(self,...)
    -- end

    local old_GetRightMouseAction = self.GetRightMouseAction
    self.GetRightMouseAction = function(self, ...)
        local equipitem = self.inst.replica.inventory:GetEquippedItem(
                              EQUIPSLOTS.HANDS)
        if equipitem and equipitem.components.aoetargeting then
            local position = TheInput:GetWorldPosition()
            local target = TheInput:GetWorldEntityUnderMouse()
            local old_right =
                self.inst.components.playeractionpicker:GetRightClickActions(
                    position, target)[1]
            -- local scene_action_right = target and self.inst.components.playeractionpicker:GetSceneActions(target, true)[1]
            -- local scene_action_left = target and self.inst.components.playeractionpicker:GetSceneActions(target)[1]

            if old_right and old_right.action ~= ACTIONS.CASTAOE then
                return old_right
            end

            -- if scene_action_right and scene_action_right.action.priority >= 0 and scene_action_right.action.rmb then
            --     return scene_action_right
            -- end
        end

        return old_GetRightMouseAction(self, ...)
    end
end)

AddComponentPostInit("playeractionpicker", function(self)
    -- local old_GetEquippedItemActions = self.GetEquippedItemActions
    -- self.GetEquippedItemActions = function(self,target, useitem, right,...)
    --     local actions = old_GetEquippedItemActions(self,target, useitem, right,...)
    --     if useitem.components.aoetargeting ~= nil and right and (#actions <= 0 or actions[1].action == ACTIONS.CASTAOE) then
    --         local scene_actions = self:GetSceneActions(target, true)
    --         if scene_actions and #scene_actions > 0 then
    --             actions = scene_actions
    --         end
    --     end

    --     return actions
    -- end

    local old_GetRightClickActions = self.GetRightClickActions
    self.GetRightClickActions = function(self, position, target, ...)
        local actions = old_GetRightClickActions(self, position, target, ...)
        if actions == nil or #actions <= 0 or actions[1].action ==
            ACTIONS.CASTAOE then
            local equipitem = self.inst.replica.inventory:GetEquippedItem(
                                  EQUIPSLOTS.HANDS)
            if equipitem and target and equipitem.components.aoetargeting ~= nil then
                local scene_action = self:GetSceneActions(target, true)[1]
                if scene_action then
                    if (scene_action.action.priority >= 0 and
                        scene_action.action.rmb) or
                        (scene_action.action == ACTIONS.RUMMAGE) then
                        actions = {scene_action}
                    end
                end
                -- if scene_action and scene_action.action.priority >= -1 then
                --     actions = {scene_action}
                -- end
            end
        end

        return actions
    end
end)

local function CanUseCharge(inst)
    local weapon = (inst.components.combat and
                       inst.components.combat:GetWeapon()) or
                       (inst.replica.combat and inst.replica.combat:GetWeapon())
    local is_riding = (inst.components.rider and
                          inst.components.rider:IsRiding()) or
                          (inst.replica.rider and inst.replica.rider:IsRiding())
    local is_valid_user = inst:HasTag("gale_weaponcharge")
    local is_sg_gale_carry_charge_pst = (inst.sg and
                                            inst.sg:HasStateTag(
                                                "gale_carry_charge_pst"))
    return
        weapon and weapon:HasTag("gale_chargeable_weapon") and is_valid_user and
            not is_riding
end

local function ServerGetChargeSG(inst)
    if inst.sg:HasStateTag("charging_attack_pre") then return false end

    if CanUseCharge(inst) then
        local weapon = inst.components.combat:GetWeapon()
        if weapon:HasTag("gale_crowbar") then
            return "gale_charging_attack_pre"
        elseif weapon.prefab == "gale_bombbox" then
            if weapon:HasTag("out_of_bomb") then
                return false
            else
                return "gale_charging_attack_pre"
            end
        end
        return "gale_charging_attack_pre"
    end
end

local function ClientGetChargeSG(inst)
    if inst.sg:HasStateTag("charging_attack_pre") then return false end

    if CanUseCharge(inst) then
        local weapon = inst.replica.combat:GetWeapon()
        if weapon:HasTag("gale_crowbar") then
            return "gale_charging_attack_pre"
        elseif weapon.prefab == "gale_bombbox" then
            if weapon:HasTag("out_of_bomb") then
                return false
            else
                return "gale_charging_attack_pre"
            end
        end
        return "gale_charging_attack_pre"
    end
end

local function ServerGetAttackSG(inst, action)
    local weapon = inst.components.combat:GetWeapon()
    local is_riding = inst.components.rider:IsRiding()

    inst.sg.mem.localchainattack = not action.forced or nil

    local playercontroller = inst.components.playercontroller
    local attack_tag = playercontroller ~= nil and
                           playercontroller.remote_authority and
                           playercontroller.remote_predicting and
                           "abouttoattack" or "attack"

    if not (inst.sg:HasStateTag(attack_tag) and action.target ==
        inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
        if not is_riding and inst.components.gale_skill_electric_punch and
            inst.components.gale_skill_electric_punch:CanPunch(action.target) then
            return "galeatk_electric_punch"
        end

        if weapon then
            if not weapon:HasTag("gale_only_rmb_charge") then
                local chargesg = ServerGetChargeSG(inst)
                if chargesg ~= nil then return chargesg end
            end

            if not is_riding then
                if weapon:HasTag("gale_crowbar") then
                    if inst:HasTag("galeatk_lunge") then
                        return "galeatk_lunge"
                    elseif inst:HasTag("galeatk_multithrust") then
                        return "galeatk_multithrust"
                    elseif inst:HasTag("galeatk_leap") then
                        return "galeatk_leap"
                    end
                elseif weapon:HasTag("gale_blaster") then
                    if weapon:HasTag("gale_blaster_jammed") or
                        weapon:HasTag("gale_blaster_out_of_ammo") then
                        return
                    end
                    if weapon.prefab == "msf_silencer_pistol" then
                        return
                            "galeatk_pistol_earlier_14_remove_attacktag_at_18"
                    end

                    if weapon.prefab == "gale_blaster_katash" then
                        return "galeatk_pistol_remove_attacktag_at_30"
                    end

                    return "galeatk_pistol_remove_attacktag_at_30"
                end
            end
        end
    end
end

local function ClientGetAttackSG(inst, action)
    local weapon = inst.replica.combat:GetWeapon()
    local is_riding = inst.replica.rider:IsRiding()

    if not (inst.sg:HasStateTag("attack") and action.target ==
        inst.sg.statemem.attacktarget or IsEntityDead(inst)) then
        if not is_riding and inst.replica.gale_skill_electric_punch and
            inst.replica.gale_skill_electric_punch:CanPunch(action.target) then
            return "galeatk_electric_punch"
        end

        if weapon then
            if not weapon:HasTag("gale_only_rmb_charge") then
                local chargesg = ClientGetChargeSG(inst)
                if chargesg ~= nil then return chargesg end
            end

            if not is_riding then
                if weapon:HasTag("gale_crowbar") then
                    if inst:HasTag("galeatk_lunge") then
                        return "galeatk_lunge"
                    elseif inst:HasTag("galeatk_multithrust") then
                        return "galeatk_multithrust"
                    elseif inst:HasTag("galeatk_leap") then
                        return "galeatk_leap"
                    end
                elseif weapon:HasTag("gale_blaster") then
                    if weapon:HasTag("gale_blaster_jammed") or
                        weapon:HasTag("gale_blaster_out_of_ammo") then
                        return
                    end

                    if weapon.prefab == "msf_silencer_pistol" then
                        return
                            "galeatk_pistol_earlier_14_remove_attacktag_at_18"
                    end

                    if weapon.prefab == "gale_blaster_katash" then
                        return "galeatk_pistol_remove_attacktag_at_30"
                    end

                    return "galeatk_pistol_remove_attacktag_at_30"
                end
            end
        end
    end
end

local function PushSpecialAtkEvent(inst, other_data)
    local target = inst.sg.statemem.attacktarget or
                       inst.components.combat.target
    if not (target and target:IsValid()) then return end
    inst:PushEvent("gale_speicalatk", {
        name = inst.sg.currentstate.name,
        target = target,
        other_data = other_data or {}
    })
end

local SERVER_SG = {}
local CLIENT_SG = {}

local function ChargingRunOrStop(inst, ismastersim)
    local cmp_gale_weaponcharge = ismastersim and
                                      inst.components.gale_weaponcharge or
                                      inst.replica.gale_weaponcharge

    -- local buffaction = inst:GetBufferedAction()
    -- local is_free_charge = buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE
    local is_free_charge = inst.sg.statemem.is_free_charge

    local is_moving = inst.sg:HasStateTag("moving")
    local moving_vec =
        inst.components.gale_control_key_helper:GetMovingDirectVector()
    local should_move = moving_vec and moving_vec:Length() > 0 and
                            cmp_gale_weaponcharge:AtkPressed(is_free_charge) and
                            inst.sg:GetTimeInState() >= 3 * FRAMES

    if should_move then inst:ForceFacePoint(inst:GetPosition() + moving_vec) end

    if is_moving and not should_move then
        inst.sg:RemoveStateTag("moving")
        inst.sg:RemoveStateTag("running")
        inst.components.locomotor:Stop()

        -- inst.Physics:Stop()
        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk_lag", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil,
                                    true)
    elseif not is_moving and should_move then
        -- inst.Physics:SetMotorVel(3, 0, 0)
        inst.sg:AddStateTag("moving")
        inst.sg:AddStateTag("running")
        inst.components.locomotor:RunForward()

        inst.AnimState:PlayAnimation("careful_walk_pre")
        inst.AnimState:PushAnimation("careful_walk", true)
    end

    if inst.sg:HasStateTag("moving") then
        inst.components.locomotor:RunForward()
    end
end

table.insert(SERVER_SG, State {
    name = "gale_charging_attack_pre",
    tags = {
        "charging_attack", "charging_attack_pre", "moving", "running",
        "autopredict"
    },

    onenter = function(inst)
        inst:AddTag("charging_attack_pre")

        inst.components.locomotor:SetExternalSpeedMultiplier(inst,
                                                             "gale_charging_attack_pre",
                                                             0.5)

        local buffaction = inst:GetBufferedAction()
        -- buffaction will be automatally cleared when moving,store it
        inst.sg.statemem.buffaction_storage = buffaction
        inst.sg.statemem.target = buffaction and buffaction.target
        inst.sg.statemem.is_free_charge =
            buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE

        GaleStateGraphs.ServerChargePreEnter(inst)
        ChargingRunOrStop(inst, true)
    end,

    timeline = {},

    onupdate = function(inst)
        ChargingRunOrStop(inst, true)
        GaleStateGraphs.ServerChargePreUpdate(inst, {
            last_anim = "atk_lag",
            attack_sg_name = "gale_charging_attack",
            target = inst.sg.statemem.target,
            is_free_charge = inst.sg.statemem.is_free_charge,
            buffaction_storage = inst.sg.statemem.buffaction_storage
        })
    end,

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end)
    },

    onexit = function(inst)
        inst:RemoveTag("charging_attack_pre")

        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst,
                                                                "gale_charging_attack_pre")
    end
})

table.insert(SERVER_SG, State {
    name = "gale_charging_attack",
    tags = {
        "attack", "charging_attack", "doing", "busy", "notalking", "autopredict"
    },

    onenter = function(inst, data)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("atk")

        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil,
                                    true)

        if data.complete then
            inst.sg:AddStateTag("completed_charging_attack")
        end

        inst.sg.statemem.charge_complete = data.complete
        inst.sg.statemem.buffaction_storage = data.buffaction_storage
    end,
    timeline = {
        TimeEvent(FRAMES, function(inst)
            local cur_buffered_action = inst:GetBufferedAction()
            if cur_buffered_action == nil or
                (cur_buffered_action ~= nil and cur_buffered_action ~=
                    inst.sg.statemem.buffaction_storage) then
                inst:ClearBufferedAction()
                -- inst:PushBufferedAction(inst.sg.statemem.buffaction_storage)
                inst.bufferedaction = inst.sg.statemem.buffaction_storage
            end
            local result = inst:PerformBufferedAction()
            if not result then print(inst, "action failed:", result) end
        end), TimeEvent(4 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("doing")
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("actionfailed", function(inst, data)
            print(inst, "action failed !")
            print("Action = ", data.action, "Reason = ", data.reason)
        end), EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }
})

table.insert(SERVER_SG, State {
    name = "gale_crowbar_superattack",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst, data)
        -- inst.Transform:SetEightFaced()

        inst.components.locomotor:Stop()
        -- inst.Physics:SetMotorVel(3.5,0,0)

        -- inst.AnimState:PlayAnimation("atk_leap")
        -- inst.AnimState:SetDeltaTimeMultiplier(1.2)
        -- inst.AnimState:PlayAnimation("gale_melee_chargeatk_pre")
        -- inst.AnimState:PushAnimation("gale_melee_chargeatk_loop",false)
        -- inst.AnimState:PushAnimation("gale_melee_chargeatk_pst",false)

        inst.AnimState:PlayAnimation("atk_prop_pre")
        inst.AnimState:PushAnimation("atk_prop_lag", false)

        -- inst.AnimState:PushAnimation("gale_melee_chargeatk_pst",false)

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    end,
    timeline = {
        -- TimeEvent(10 * FRAMES, function(inst)
        --     inst.sg.statemem.fade_thread = GaleCommon.FadeTo(inst,15 * FRAMES,nil,nil,{Vector4(0,0.9,0.9,1),Vector4(0,0,0,1)})
        -- end),
        -- TimeEvent(13 * FRAMES, function(inst)
        --     inst:PerformBufferedAction()
        --     inst.Physics:Stop()
        -- end),

        TimeEvent(8 * FRAMES, function(inst)
            inst.AnimState:PlayAnimation("atk_prop")
            inst.SoundEmitter:PlaySound(
                "gale_sfx/character/p1_gale_charge_atk_shout")
            inst.sg.statemem.fade_thread =
                GaleCommon.FadeTo(inst, 15 * FRAMES, nil, nil, {
                    Vector4(0, 0.9, 0.9, 1), Vector4(0, 0, 0, 1)
                })
        end), TimeEvent(10 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.Physics:Stop()
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        -- if inst.sg.statemem.fade_thread then
        --     KillThread(inst.sg.statemem.fade_thread)
        -- end
        inst.AnimState:SetDeltaTimeMultiplier(1)
        inst.Transform:SetFourFaced()
    end
})

table.insert(SERVER_SG, State {
    name = "galeatk_multithrust",
    tags = {"attack", "notalking", "abouttoattack", "autopredict"},
    onenter = function(inst)
        local target = GaleStateGraphs.ServerAttackEnter(inst)
        if target == false then return end

        inst.AnimState:PlayAnimation("multithrust")
        inst.Transform:SetEightFaced()

        inst.sg:SetTimeout(28 * FRAMES)
    end,
    timeline = {
        TimeEvent(7 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
            inst:PerformBufferedAction()
            PushSpecialAtkEvent(inst)
        end), TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
            inst.components.combat:DoAttack()
            PushSpecialAtkEvent(inst, {areahit = true})
        end), TimeEvent(11 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
            inst.components.combat:DoAttack()
            PushSpecialAtkEvent(inst, {areahit = true})
        end), TimeEvent(15 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
            inst.components.combat:DoAttack()
            PushSpecialAtkEvent(inst)
        end), TimeEvent(19 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)
    },

    ontimeout = function(inst) inst.sg:GoToState("idle", true) end,

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end

})

table.insert(SERVER_SG, State {
    name = "galeatk_leap",
    tags = {"attack", "notalking", "abouttoattack", "autopredict"},

    onenter = function(inst, data)
        local target = GaleStateGraphs.ServerAttackEnter(inst)
        if target == false then return end

        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof", nil, nil,
                                    true)
    end,
    timeline = {
        TimeEvent(12 * FRAMES, function(inst)
            inst.sg.statemem.fade_thread =
                GaleCommon.FadeTo(inst, 15 * FRAMES, nil, nil, {
                    Vector4(0, 0.9, 0.9, 1), Vector4(0, 0, 0, 1)
                })
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke", nil,
                                        nil, true)
        end), TimeEvent(13 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            PushSpecialAtkEvent(inst)
        end), TimeEvent(18 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end
})

table.insert(SERVER_SG, State {
    name = "galeatk_lunge",
    tags = {"attack", "notalking", "abouttoattack", "autopredict"},

    onenter = function(inst, data)
        local target = GaleStateGraphs.ServerAttackEnter(inst)
        if target == false then return end

        inst.AnimState:PlayAnimation("lunge_pre")
        inst.AnimState:PushAnimation("lunge_pst", false)

        -- inst.AnimState:PlayAnimation("lunge_pst")
    end,
    timeline = {
        -- TimeEvent(8 * FRAMES, function(inst)
        --     inst:PerformBufferedAction()
        --     PushSpecialAtkEvent(inst)
        -- end),

        -- TimeEvent(8 * FRAMES, function(inst)
        --     inst.sg:RemoveStateTag("abouttoattack")
        --     inst.sg:RemoveStateTag("attack")
        -- end),

        TimeEvent(4 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil,
                                        true)
        end), TimeEvent(12 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball",
                                        nil, nil, true)

            inst:PerformBufferedAction()
            PushSpecialAtkEvent(inst)
        end), TimeEvent(17 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end
})

-- table.insert(SERVER_SG,State{
--     name = "galeatk_blaster",
--     tags = { "attack", "notalking", "abouttoattack", "autopredict" },
--     onenter = function(inst)
--         if inst.components.combat:InCooldown() then
--             inst.sg:RemoveStateTag("abouttoattack")
--             inst:ClearBufferedAction()
--             inst.sg:GoToState("idle", true)
--             return
--         end

--         GaleStateGraphs.ServerAttackEnter(inst)

--         inst.AnimState:PlayAnimation("hand_shoot")

--         if inst.sg.laststate == inst.sg.currentstate and inst:HasTag("gale_steady_hand") then
--             inst.sg.statemem.chained = true
--             inst.AnimState:SetTime(7 * FRAMES)
--         end

--         local bufferedaction = inst:GetBufferedAction()
--         local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--         if (equip ~= nil and equip.projectiledelay or 0) > 0 then
--             --V2C: Projectiles don't show in the initial delayed frames so that
--             --     when they do appear, they're already in front of the player.
--             --     Start the attack early to keep animation in sync.
--             inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 10 or 17) * FRAMES - equip.projectiledelay
--             if inst.sg.statemem.projectiledelay <= 0 then
--                 inst.sg.statemem.projectiledelay = nil
--             end
--         end

--         inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 20 or 30) * FRAMES, inst.components.combat.min_attack_period + .5 * FRAMES))

--         if equip and bufferedaction then
--             inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and equip.shoot_sound_skill or equip.shoot_sound
--         end

--     end,

--     ontimeout = function(inst)
--         inst.sg:RemoveStateTag("attack")
--         inst.sg:AddStateTag("idle")
--     end,

--     onupdate = function(inst, dt)
--         if (inst.sg.statemem.projectiledelay or 0) > 0 then
--             inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
--             if inst.sg.statemem.projectiledelay <= 0 then
--                 inst:PerformBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end
--     end,

--     timeline =
--     {
--         TimeEvent(9 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(10 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst:PerformBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--         TimeEvent(16 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(17 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst:PerformBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),
--     },

--     events =
--     {
--         EventHandler("animover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("idle")
--             end
--         end),
--     },

--     onexit = function(inst)
--         inst.components.combat:SetTarget(nil)
--         if inst.sg:HasStateTag("abouttoattack") then
--             inst.components.combat:CancelAttack()
--         end
--     end,
-- })

-- local QUICK_SHOOT_EARLY_TIME = 14 * FRAMES
-- local QUICK_SHOOT_CHAIN_DURATION = 8 * FRAMES

-- table.insert(SERVER_SG,State{
--     name = "galeatk_quick_pistol",
--     tags = { "attack", "notalking", "abouttoattack", "autopredict" },
--     onenter = function(inst)
--         if inst.components.combat:InCooldown() then
--             inst.sg:RemoveStateTag("abouttoattack")
--             inst:ClearBufferedAction()
--             inst.sg:GoToState("idle", true)
--             return
--         end

--         local target = GaleStateGraphs.ServerAttackEnter(inst)

--         inst.sg.statemem.retarget = target

--         inst.AnimState:PlayAnimation("hand_shoot")

--         if inst.gale_last_pistol_shoot_time and GetTime() - inst.gale_last_pistol_shoot_time <= QUICK_SHOOT_CHAIN_DURATION then
--             inst.sg.statemem.chained = true
--             inst.AnimState:SetTime(QUICK_SHOOT_EARLY_TIME)
--         end

--         local bufferedaction = inst:GetBufferedAction()
--         local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--         if equip and bufferedaction then
--             inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and equip.shoot_sound_skill or equip.shoot_sound
--         end

--         inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 4 or 18) * FRAMES, inst.components.combat.min_attack_period + .5 * FRAMES))
--         -- inst.sg:SetTimeout((inst.sg.statemem.chained and 4 or 18) * FRAMES)
--     end,

--     ontimeout = function(inst)
--         inst.sg:RemoveStateTag("attack")
--         inst.sg:AddStateTag("idle")
--     end,

--     timeline =
--     {
--         TimeEvent(2 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(3 * FRAMES, function(inst)
--             if inst.sg.statemem.chained then
--                 if inst:PerformBufferedAction() then

--                 end
--                 inst.gale_last_pistol_shoot_time = GetTime()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--         TimeEvent(16 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(17 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained then

--                 if inst:PerformBufferedAction() then
--                     inst.gale_last_pistol_shoot_time = GetTime()
--                 end

--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),
--     },

--     events =
--     {
--         EventHandler("animover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("idle")
--             end
--         end),
--     },

--     onexit = function(inst)
--         inst.components.combat:SetTarget(nil)
--         if inst.sg:HasStateTag("abouttoattack") then
--             inst.components.combat:CancelAttack()
--         end
--     end,
-- })

table.insert(SERVER_SG, State {
    name = "gale_carry_charge_pst",
    tags = {"busy", "nopredict", "nointerrupt", "gale_carry_charge_pst"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        -- inst:ClearBufferedAction()
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:SetTimeout(2)
    end,

    ontimeout = function(inst) inst.sg:GoToState("idle") end,

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }

})

table.insert(SERVER_SG, State {
    name = "gale_fire_dash",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst)
        inst.Physics:Stop()
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("multithrust_yell")

        inst.Transform:SetEightFaced()

        inst.sg.statemem.hitted_targets = {}
        inst.sg.statemem.fxs = {}

        local firepuff = inst:SpawnChild("gale_atk_firepuff_hot")
        firepuff.Transform:SetScale(0.8, 0.8, 0.8)
        firepuff.entity:AddFollower()
        firepuff.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 50, 0)

        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end,

    timeline = {
        TimeEvent(1 * FRAMES, function(inst)
            inst:PerformBufferedAction()

            if inst.sg.statemem.addition_attack then
                local vfx_pos = {
                    Vector3(-1, -73, 0.1), Vector3(-10, -135, 0.1),
                    Vector3(-18, -191, 0.1)
                }
                for _, pos in pairs(vfx_pos) do
                    local fx = inst:SpawnChild("gale_flame_vfx")
                    fx.entity:AddFollower()
                    fx.Follower:FollowSymbol(inst.GUID, "swap_object", pos:Get())

                    table.insert(inst.sg.statemem.fxs, fx)
                end
            end
        end), TimeEvent(8 * FRAMES, function(inst)
            inst.AnimState:PlayAnimation("multithrust")
        end), TimeEvent(17 * FRAMES, function(inst)
            inst.AnimState:SetAddColour(1, 1, 0, 0)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/sky_striker/fire_dash2")
            inst.sg.statemem.tail_fx = inst:SpawnChild(
                                           "gale_sky_striker_blade_fire_tail")
            -- inst.sg.statemem.tail_fx:DoPeriodicTask(0,function()
            --     inst.sg.statemem.tail_fx.Transform:SetRotation(inst.Transform:GetRotation())
            -- end)
            inst.sg.statemem.dash_task =
                inst:DoPeriodicTask(0, function()
                    inst.Physics:SetMotorVel(50, 0, 0)

                    local anim_data = GaleCommon.GetAnim(inst)

                    local shadow = SpawnAt("gale_fade_shadow", inst)
                    shadow.Transform:SetEightFaced()
                    shadow.Transform:SetRotation(inst.Transform:GetRotation())
                    shadow:Copy(inst)

                    shadow.AnimState:Show("ARM_carry")
                    shadow.AnimState:Hide("ARM_normal")
                    shadow.AnimState:OverrideSymbol("swap_object",
                                                    "swap_gale_sky_striker_blade_fire",
                                                    "swap_gale_sky_striker_blade_fire")
                    shadow.AnimState:SetPercent("multithrust", anim_data.percent)

                    GaleCommon.FadeTo(shadow, 0.6, nil, {
                        Vector4(1, 1, 0, 1), Vector4(0, 0, 0, 0)
                    }, {Vector4(1, 1, 0, 1), Vector4(0, 0, 0, 0)}, shadow.Remove)

                    local hit_ents = GaleCommon.AoeDoAttack(inst,
                                                            inst:GetPosition(),
                                                            2.2, {
                        ignorehitrange = true,
                        instancemult = 2.5
                    }, function(inst, other)
                        return not inst.sg.statemem.hitted_targets[other] and
                                   inst.components.combat and
                                   inst.components.combat:CanTarget(other) and
                                   not inst.components.combat:IsAlly(other)
                    end)

                    -- When attack charged lightninggoat,it will go to electrocute SG,
                    -- and if you do,the inst.sg.statemem.hitted_targets will be nil here
                    if inst.sg.currentstate.name == "gale_fire_dash" then
                        for k, v in pairs(hit_ents) do
                            inst.sg.statemem.hitted_targets[v] = true
                        end
                    end
                end)
        end), TimeEvent(24 * FRAMES, function(inst)
            if inst.sg.statemem.addition_attack then
                inst.sg:GoToState("gale_fire_dash_addition",
                                  inst.sg.statemem.fxs)
            else
                inst.sg:GoToState("idle", true)
            end
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end)
    },

    onexit = function(inst)
        if inst.sg.statemem.dash_task then
            inst.sg.statemem.dash_task:Cancel()
        end
        if inst.sg.statemem.tail_fx then
            inst.sg.statemem.tail_fx:Remove()
        end

        if not inst.sg.statemem.addition_attack then
            for _, v in pairs(inst.sg.statemem.fxs) do v:Remove() end
        end
        inst.Physics:Stop()
        inst.AnimState:SetAddColour(0, 0, 0, 0)

        inst.Transform:SetFourFaced()
    end
})

table.insert(SERVER_SG, State {
    name = "gale_charge_and_sway",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk_lag", false)

        local weapon = inst.components.inventory:GetEquippedItem(
                           EQUIPSLOTS.HANDS)
        local charge_sound = weapon and weapon.charge_sound or
                                 "dontstarve/wilson/attack_weapon"

        inst.SoundEmitter:PlaySound(charge_sound)
    end,

    timeline = {

        TimeEvent(15 * FRAMES,
                  function(inst) inst.AnimState:PlayAnimation("atk") end),

        TimeEvent(16 * FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(27 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end)
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() and
                inst.AnimState:IsCurrentAnimation("atk") then
                inst.sg:GoToState("idle")
            end
        end)
    }
})

table.insert(SERVER_SG, State {
    name = "gale_fire_dash_addition",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst, fxs)
        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("atk_leap")
        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof", nil, nil,
                                    true)

        inst.sg.statemem.fxs = fxs

        inst.components.health:SetInvincible(true)
    end,
    timeline = {
        TimeEvent(12 * FRAMES, function(inst)
            inst.sg.statemem.fade_thread =
                GaleCommon.FadeTo(inst, 15 * FRAMES, nil, nil,
                                  {Vector4(1, 1, 0, 1), Vector4(0, 0, 0, 1)})
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke", nil,
                                        nil, true)
        end), TimeEvent(13 * FRAMES, function(inst)
            local local_pos = Vector3(1.66, 0, 0)
            local world_pos = Vector3(inst.entity:LocalToWorldSpace(
                                          local_pos:Get()))

            -- GaleCommon.AoeDoAttack(inst,world_pos,5,{
            --     ignorehitrange = true,
            --     instancemult = 3.5,
            -- })

            inst._gale_fire_dash_addition_hitted_targets = {}

            inst:StartThread(function()
                local radius = 0.1
                while radius < 5 do
                    local hit_ents = GaleCommon.AoeDoAttack(inst, world_pos,
                                                            radius, {
                        ignorehitrange = true,
                        instancemult = 3.5
                    }, function(inst, other)
                        return
                            not inst._gale_fire_dash_addition_hitted_targets[other] and
                                inst.components.combat and
                                inst.components.combat:CanTarget(other) and
                                not inst.components.combat:IsAlly(other)
                    end)

                    for k, v in pairs(hit_ents) do
                        inst._gale_fire_dash_addition_hitted_targets[v] = true
                    end

                    radius = radius + 0.5
                    Sleep(0)
                end

                inst._gale_fire_dash_addition_hitted_targets = nil
            end)

            ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)

            inst:SpawnChild("gale_explode_ray_yellow_vfx").Transform:SetPosition(
                local_pos:Get())

            SpawnAt("gale_sky_striker_blade_fire_hitground_fx", world_pos)

            local ring = SpawnAt("gale_laser_ring_fx", world_pos)
            ring.Transform:SetScale(0.9, 0.9, 0.9)
            ring.AnimState:SetFinalOffset(3)
            ring.AnimState:SetLayer(LAYER_GROUND)
            ring.AnimState:HideSymbol("lightning01")
            ring.AnimState:SetSymbolAddColour("glow_2", 1, 1, 0, 1)
            ring.AnimState:SetSymbolAddColour("circle", 1, 1, 0, 1)

            local explosion = SpawnAt("gale_laser_explosion", world_pos)
            explosion.Transform:SetScale(0.66, 0.66, 0.66)
            explosion.AnimState:SetAddColour(1, 1, 0, 1)
            explosion.AnimState:SetDeltaTimeMultiplier(0.8)
        end)
    },

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        inst.components.health:SetInvincible(false)

        for _, v in pairs(inst.sg.statemem.fxs) do v:Remove() end
    end
})

table.insert(SERVER_SG, State {
    name = "gale_lightning_roll_pre",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("emote_fistshake")

        inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_katash/howl")
        inst:PerformBufferedAction()
    end,

    timeline = {},

    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("gale_lightning_roll")
        end)
    },

    onexit = function(inst) inst.Physics:Stop() end
})

-- ThePlayer.sg:GoToState("gale_lightning_roll")
table.insert(SERVER_SG, State {
    name = "gale_lightning_roll",
    tags = {"aoe", "doing", "busy", "nointerrupt", "nomorph", "nopredict"},

    onenter = function(inst)
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("fangun_pre")
        inst.AnimState:PushAnimation("fangun_loop", true)

        inst.sg.statemem.fxs = {}
        inst.sg.statemem.hitted_targst = {}

        local s = 0.6
        local fx_num = 3
        for i = 1, fx_num do
            local fx = inst:SpawnChild("cracklehitfx")
            fx.Transform:SetScale(s, s, s)
            fx.persists = false

            fx.AnimState:PlayAnimation("crackle_loop")
            fx.AnimState:SetTime((i - 1) *
                                     fx.AnimState:GetCurrentAnimationLength() /
                                     fx_num)
            fx.AnimState:SetAddColour(0 / 255, 0 / 255, 255 / 255, 1)

            fx:ListenForEvent("animover", function()
                if fx.perish then
                    fx:Remove()
                else
                    fx.AnimState:PlayAnimation("crackle_loop")
                end
            end)

            table.insert(inst.sg.statemem.fxs, fx)
        end

        inst.components.locomotor:SetExternalSpeedMultiplier(inst,
                                                             "gale_lightning_roll",
                                                             1.2)

        inst.SoundEmitter:PlaySound("gale_sfx/battle/static_shocked",
                                    "static_shocked")
        inst.SoundEmitter:PlaySound("gale_sfx/battle/ElectricalBuzzLoop",
                                    "ElectricalBuzzLoop")
        inst.sg:SetTimeout(10)
    end,

    onupdate = function(inst)
        local moving_dir =
            inst.components.gale_control_key_helper:GetMovingDirectVector()

        if moving_dir ~= nil then
            local cur_dir = GaleCommon.GetFaceVector(inst)
            local new_dir = (cur_dir + moving_dir * FRAMES * 3):GetNormalized()

            inst:ForceFacePoint(inst:GetPosition() + new_dir)
        end

        -- inst.sg.statemem.hitted_targst
        local victims = GaleCommon.AoeDoAttack(inst, inst:GetPosition(),
                                               inst:GetPhysicsRadius(0) + 2,
                                               function(inst, other)
            local weapon, projectile, stimuli, instancemult, ignorehitrange
            instancemult = 0.2
            ignorehitrange = true

            instancemult = instancemult *
                               math.clamp(other:GetPhysicsRadius(0) + 0.5, 1, 3)
            if other:HasTag("largecreature") then
                instancemult = instancemult * 1.2
            end

            return weapon, projectile, stimuli, instancemult, ignorehitrange
        end, function(inst, other)
            return inst.components.combat and
                       inst.components.combat:CanTarget(other) and
                       not inst.components.combat:IsAlly(other) and
                       (GetTime() - (inst.sg.statemem.hitted_targst[other] or 0) >
                           0.1)
        end)

        for k, v in pairs(victims) do
            inst.sg.statemem.hitted_targst[v] = GetTime()
        end
        -- if dir ~= nil then
        --     inst:ForceFacePoint(inst:GetPosition() + dir)
        -- end

        inst.Physics:SetMotorVel(inst.components.locomotor:GetRunSpeed(), 0, 0)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("fangun_pst")
        inst.sg:GoToState("idle", true)
    end,

    timeline = {},

    events = {
        EventHandler("unequip", function(inst)
            inst.AnimState:PlayAnimation("fangun_pst")
            inst.sg:GoToState("idle", true)
        end)
    },

    onexit = function(inst)
        inst.Physics:Stop()
        inst.SoundEmitter:KillSound("static_shocked")
        inst.SoundEmitter:KillSound("ElectricalBuzzLoop")

        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst,
                                                                "gale_lightning_roll")

        for _, v in pairs(inst.sg.statemem.fxs) do
            -- v:ListenForEvent("animqueueover", v.Remove)
            v.perish = true
        end
    end
})

table.insert(SERVER_SG, State {
    name = "galeatk_electric_punch",
    tags = {"attack", "notalking", "abouttoattack", "autopredict"},

    onenter = function(inst)
        local target = GaleStateGraphs.ServerAttackEnter(inst)
        if target == false then return end

        local anims = {"atk_werewilba", "atk_2_werewilba"}

        local anim_index =
            inst.components.gale_skill_electric_punch:GetAnimIndex()
        local bufferedaction = inst:GetBufferedAction()
        if bufferedaction and bufferedaction.action ~= ACTIONS.ATTACK then
            local equip = inst.components.inventory:GetEquippedItem(
                              EQUIPSLOTS.HANDS)
            if equip then anim_index = 1 end
        end

        inst.AnimState:PlayAnimation(anims[anim_index])

        inst.sg.statemem.attack = (bufferedaction and bufferedaction.action ==
                                      ACTIONS.ATTACK)

        inst.sg:SetTimeout(12 * FRAMES)
    end,
    timeline = {
        TimeEvent(6 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/typhon_phantom/whip",
                                        nil, nil, true)
        end), TimeEvent(9 * FRAMES, function(inst)
            if inst.components.gale_skill_electric_punch then
                if inst.sg.statemem.attack then
                    inst.components.gale_skill_electric_punch.force_punch_weapon =
                        true
                    inst:PerformBufferedAction()
                    inst.components.gale_skill_electric_punch.force_punch_weapon =
                        false
                else
                    inst:PerformBufferedAction()
                end
            else
                inst:ClearBufferedAction()
            end
            inst.sg:RemoveStateTag("abouttoattack")
        end)
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
        -- inst.sg:GoToState("idle", true)
    end,

    events = {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
        if inst.components.gale_skill_electric_punch then
            inst.components.gale_skill_electric_punch.force_punch_weapon = false
        end
    end
})

table.insert(CLIENT_SG, State {
    name = "gale_charging_attack_pre",
    tags = {"charging_attack", "charging_attack_pre", "moving", "running"},

    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        inst.sg.statemem.target = buffaction and buffaction.target
        inst.sg.statemem.is_free_charge =
            buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE

        inst:PerformPreviewBufferedAction()

        ChargingRunOrStop(inst, false)
    end,

    timeline = {},

    onupdate = function(inst)
        ChargingRunOrStop(inst, false)

        GaleStateGraphs.ClientChargePreUpdate(inst, {
            last_anim = "atk_lag",
            attack_sg_name = "gale_charging_attack",
            target = inst.sg.statemem.target,
            is_free_charge = inst.sg.statemem.is_free_charge
        })
    end,

    onexit = function(inst) end,

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end)
    }
})

table.insert(CLIENT_SG, State {
    name = "gale_charging_attack",
    tags = {"attack", "charging_attack", "doing", "busy", "notalking"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil,
                                    true)
        inst:PerformPreviewBufferedAction()
    end,
    timeline = {
        TimeEvent(4 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("doing")
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end),

        TimeEvent(13 * FRAMES,
                  function(inst) inst.sg:GoToState("idle", true) end)
    },

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }
})

table.insert(CLIENT_SG, State {
    name = "gale_crowbar_superattack",
    tags = {"aoe", "doing", "busy", "nomorph"},

    onenter = function(inst, data) inst:PerformPreviewBufferedAction() end,

    events = {
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }
})

table.insert(CLIENT_SG, State {
    name = "galeatk_multithrust",
    tags = {"attack", "notalking", "abouttoattack"},
    onenter = function(inst)
        local target = GaleStateGraphs.ClientAttackEnter(inst)
        if target == false then return end

        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("multithrust")
        inst.sg:SetTimeout(28 * FRAMES)
    end,
    timeline = {
        TimeEvent(7 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
        end), TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
        end), TimeEvent(11 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
        end), TimeEvent(15 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil,
                                        nil, true)
        end), TimeEvent(19 * FRAMES, function(inst)
            inst:ClearBufferedAction()
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("abouttoattack")
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
        inst.sg:GoToState("idle", true)
    end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
            inst.replica.combat:CancelAttack()
        end
    end

})

table.insert(CLIENT_SG, State {
    name = "galeatk_leap",
    tags = {"attack", "notalking", "abouttoattack"},
    onenter = function(inst)
        local target = GaleStateGraphs.ClientAttackEnter(inst)
        if target == false then return end

        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("atk_leap")

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof", nil, nil,
                                    true)
        inst.sg:SetTimeout(30 * FRAMES)
    end,
    timeline = {
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke", nil,
                                        nil, true)
        end), TimeEvent(18 * FRAMES, function(inst)
            inst:ClearBufferedAction()
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("abouttoattack")
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
        inst.sg:GoToState("idle", true)
    end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
            inst.replica.combat:CancelAttack()
        end
    end

})

table.insert(CLIENT_SG, State {
    name = "galeatk_lunge",
    tags = {"attack", "notalking", "abouttoattack"},
    onenter = function(inst)
        local target = GaleStateGraphs.ClientAttackEnter(inst)
        if target == false then return end

        inst.AnimState:PlayAnimation("lunge_pre")
        inst.AnimState:PushAnimation("lunge_pst", false)

        -- inst.AnimState:PlayAnimation("lunge_pst")
        -- inst.sg:SetTimeout(5 * FRAMES)
    end,
    timeline = {

        -- TimeEvent(8 * FRAMES, function(inst)
        --     inst:ClearBufferedAction()

        -- end),

        -- TimeEvent(8 * FRAMES, function(inst)
        --     inst.sg:RemoveStateTag("abouttoattack")
        --     inst.sg:RemoveStateTag("attack")
        -- end),

        TimeEvent(4 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil,
                                        true)
        end), TimeEvent(12 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball",
                                        nil, nil, true)
            inst:ClearBufferedAction()
        end), TimeEvent(17 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:RemoveStateTag("attack")
        end)

    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("abouttoattack")
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
        inst.sg:GoToState("idle", true)
    end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
            inst.replica.combat:CancelAttack()
        end
    end

})

-- table.insert(CLIENT_SG,State{
--     name = "galeatk_blaster",
--     tags = { "attack", "notalking", "abouttoattack"},
--     onenter = function(inst)
--         local target = GaleStateGraphs.ClientAttackEnter(inst)
--         if target == false then
--             return
--         end

--         inst.AnimState:PlayAnimation("hand_shoot")

--         if inst.sg.laststate == inst.sg.currentstate and inst:HasTag("gale_steady_hand") then
--             inst.sg.statemem.chained = true
--             inst.AnimState:SetTime(7 * FRAMES)
--         end

--         local bufferedaction = inst:GetBufferedAction()
--         local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--         if (equip.projectiledelay or 0) > 0 then
--             inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 10 or 17) * FRAMES - equip.projectiledelay
--             if inst.sg.statemem.projectiledelay <= 0 then
--                 inst.sg.statemem.projectiledelay = nil
--             end
--         end

--         inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 20 or 30) * FRAMES, inst.replica.combat:MinAttackPeriod() + .5 * FRAMES))

--         if equip and bufferedaction then
--             inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and equip.shoot_sound_skill or equip.shoot_sound
--         end
--     end,

--     ontimeout = function(inst)
--         inst.sg:RemoveStateTag("attack")
--         inst.sg:AddStateTag("idle")
--     end,

--     onupdate = function(inst, dt)
--         if (inst.sg.statemem.projectiledelay or 0) > 0 then
--             inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
--             if inst.sg.statemem.projectiledelay <= 0 then
--                 inst:ClearBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end
--     end,

--     timeline = {
--         TimeEvent(9 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(10 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst:ClearBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--         TimeEvent(16 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(17 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst:ClearBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--     },

--     events =
--     {
--         EventHandler("animqueueover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("idle")
--             end
--         end),
--     },

--     onexit = function(inst)
--         if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
--             inst.replica.combat:CancelAttack()
--         end
--     end,

-- })

-- table.insert(CLIENT_SG,State{
--     name = "galeatk_quick_pistol",
--     tags = { "attack", "notalking", "abouttoattack"},
--     onenter = function(inst)
--         local target = GaleStateGraphs.ClientAttackEnter(inst)
--         if target == false then
--             return
--         end

--         inst.sg.statemem.retarget = target

--         inst.AnimState:PlayAnimation("hand_shoot")

--         if inst._gale_last_pistol_shoot_time and GetTime() - inst._gale_last_pistol_shoot_time <= QUICK_SHOOT_CHAIN_DURATION then
--             inst.sg.statemem.chained = true
--             inst.AnimState:SetTime(QUICK_SHOOT_EARLY_TIME)
--         end

--         local bufferedaction = inst:GetBufferedAction()
--         local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--         local timeout = math.max((inst.sg.statemem.chained and 4 or 18) * FRAMES, inst.replica.combat:MinAttackPeriod() + .5 * FRAMES)
--         inst.sg:SetTimeout(timeout)

--         if equip and bufferedaction then
--             inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and equip.shoot_sound_skill or equip.shoot_sound
--         end
--     end,

--     ontimeout = function(inst)
--         inst.sg:RemoveStateTag("attack")
--         inst.sg:AddStateTag("idle")
--     end,

--     timeline = {
--         TimeEvent(2 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(3 * FRAMES, function(inst)
--             if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst._gale_last_pistol_shoot_time = GetTime()
--                 inst:ClearBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--         TimeEvent(16 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
--                 inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
--             end
--         end),

--         TimeEvent(17 * FRAMES, function(inst)
--             if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
--                 inst._gale_last_pistol_shoot_time = GetTime()
--                 inst:ClearBufferedAction()
--                 inst.sg:RemoveStateTag("abouttoattack")
--             end
--         end),

--     },

--     events =
--     {
--         EventHandler("animqueueover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("idle")
--             end
--         end),
--     },

--     onexit = function(inst)
--         if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
--             inst.replica.combat:CancelAttack()
--         end
--     end,

-- })

table.insert(CLIENT_SG, State {
    name = "gale_carry_charge_pst",
    tags = {"busy", "nointerrupt", "gale_carry_charge_pst"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:SetTimeout(2)
    end,

    ontimeout = function(inst) inst.sg:GoToState("idle") end,

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }

})

table.insert(CLIENT_SG, State {
    name = "galeatk_electric_punch",
    tags = {"attack", "notalking", "abouttoattack"},
    onenter = function(inst)
        local target = GaleStateGraphs.ClientAttackEnter(inst)
        if target == false then return end

        local anims = {"atk_werewilba", "atk_2_werewilba"}

        local anim_index = inst.replica.gale_skill_electric_punch:GetAnimIndex()
        local bufferedaction = inst:GetBufferedAction()
        if bufferedaction and bufferedaction.action ~= ACTIONS.ATTACK then
            local equip = inst.replica.inventory:GetEquippedItem(
                              EQUIPSLOTS.HANDS)
            if equip then anim_index = 1 end
        end

        inst.AnimState:PlayAnimation(anims[anim_index])

        inst.sg:SetTimeout(12 * FRAMES)
    end,
    timeline = {
        TimeEvent(6 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/typhon_phantom/whip",
                                        nil, nil, true)
        end), TimeEvent(9 * FRAMES, function(inst)
            inst:ClearBufferedAction()
            inst.sg:RemoveStateTag("abouttoattack")
        end)
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
        -- inst.sg:GoToState("idle", true)
    end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
            inst.replica.combat:CancelAttack()
        end
    end

})

local PISTOL_SERVER_SG, PISTOL_CLIENT_SG =
    GaleStateGraphs.GenerateMultiShootSG_pistol()

SERVER_SG = ConcatArrays(SERVER_SG, PISTOL_SERVER_SG)
CLIENT_SG = ConcatArrays(CLIENT_SG, PISTOL_CLIENT_SG)

for k, v in pairs(SERVER_SG) do AddStategraphState("wilson", v) end

for k, v in pairs(CLIENT_SG) do AddStategraphState("wilson_client", v) end

AddStategraphPostInit("wilson", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate =
        function(inst, action, ...)
            local sg = ServerGetAttackSG(inst, action)
            if sg ~= false then
                return sg or old_ATTACK(inst, action, ...)
            end
        end
end)
AddStategraphPostInit("wilson_client", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate =
        function(inst, action, ...)
            local sg = ClientGetAttackSG(inst, action)
            if sg ~= false then
                return sg or old_ATTACK(inst, action, ...)
            end
        end
end)

AddStategraphPostInit("wilson", function(sg)
    local old_attacked = sg.events["attacked"].fn
    sg.events["attacked"].fn = function(inst, data)
        if not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("charging_attack") then
                return
            elseif inst.sg.currentstate.name == "gale_tired_low_stamina" then
                inst.sg:GoToState("gale_tired_low_stamina_knockback")
                return
            elseif inst.sg.currentstate.name ==
                "gale_tired_low_stamina_knockback" then
                inst.sg:GoToState("gale_tired_low_stamina_knockback")
                return
            elseif inst.sg.currentstate.name ==
                "gale_tired_low_stamina_knockback_pst" then
                inst.sg:GoToState("gale_tired_low_stamina_knockback_pst", 0.42)
                return
            end
        end

        return old_attacked(inst, data)
    end
end)

-- Aoe weapon
AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate =
        function(inst, action)
            local weapon = action.invobject
            if weapon and weapon:HasTag("gale_aoe_spell_weapon") then
                local can_cast = weapon.components.aoetargeting:IsEnabled() and
                                     (weapon.components.rechargeable == nil or
                                         weapon.components.rechargeable:IsCharged())

                if can_cast then
                    -- if weapon:HasTag("gale_crowbar") then
                    --     return "gale_crowbar_superattack"
                    -- else
                    if weapon.prefab == "gale_blaster_katash" then
                        return "galeatk_pistol_remove_attacktag_at_30"
                    elseif weapon.prefab == "gale_sky_striker_blade_fire" then
                        return "gale_fire_dash"
                    elseif weapon.prefab == "athetos_psychostatic_cutter" then
                        return "gale_charge_and_sway"
                    elseif weapon.prefab == "galeboss_katash_blade" then
                        return "gale_lightning_roll_pre"
                    end
                else
                    return
                end
            end
            return old_CASTAOE(inst, action)
        end
end)
AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate =
        function(inst, action)
            local weapon = action.invobject
            if weapon and weapon:HasTag("gale_aoe_spell_weapon") then
                local can_cast = weapon.components.aoetargeting:IsEnabled()

                if can_cast then
                    -- if weapon:HasTag("gale_crowbar") then
                    --     return "gale_crowbar_superattack"
                    -- else
                    if weapon.prefab == "gale_blaster_katash" then
                        return "galeatk_pistol_remove_attacktag_at_30"
                    elseif weapon.prefab == "gale_sky_striker_blade_fire" then
                        inst:PerformPreviewBufferedAction()
                        return
                    elseif weapon.prefab == "athetos_psychostatic_cutter" then
                        inst:PerformPreviewBufferedAction()
                        return
                    elseif weapon.prefab == "galeboss_katash_blade" then
                        inst:PerformPreviewBufferedAction()
                        return
                    end
                else
                    return
                end
            end
            return old_CASTAOE(inst, action)
        end
end)

local function WalkPostInit(self)
    local locomote = self.events["locomote"]
    local old_fn = locomote.fn
    function locomote.fn(inst, data)
        if inst.sg:HasStateTag("charging_attack_pre") then return end
        return old_fn(inst, data)
    end
end

AddStategraphPostInit("wilson", WalkPostInit)
AddStategraphPostInit("wilson_client", WalkPostInit)

AddModRPCHandler("gale_rpc", "gale_weaponcharge_btn",
                 function(inst, control, pressed)
    if inst.components.gale_weaponcharge then
        inst.components.gale_weaponcharge:SetKey(control, pressed)
    end
end)

-- AddModRPCHandler("gale_rpc", "gale_face_point", function(inst, x, y, z, force)
--     local buffer = inst:GetBufferedAction()
--     if force or (buffer and buffer.action == ACTIONS.GALE_FREE_CHARGE) then
--         inst:ForceFacePoint(x, y, z)
--     end
-- end)

AddModRPCHandler("gale_rpc", "update_mouse_position", function(inst, x, z)
    if inst.components.gale_control_key_helper then
        inst.components.gale_control_key_helper:SetMousePosition(
            Vector3(x, 0, z))
    end
end)

AddModRPCHandler("gale_rpc", "update_mouse_entity", function(inst, target)
    if inst.components.gale_control_key_helper then
        inst.components.gale_control_key_helper:SetEntityUnderMouse(target)
    end
end)

AddModRPCHandler("gale_rpc", "update_moving_direct_vector", function(inst, x, z)
    if inst.components.gale_control_key_helper then
        inst.components.gale_control_key_helper:SetMovingDirectVector(Vector3(x,
                                                                              0,
                                                                              z))
    end
end)

local atk_btns = {
    CONTROL_PRIMARY, CONTROL_SECONDARY, CONTROL_ATTACK, -- CONTROL_FORCE_ATTACK,
    CONTROL_CONTROLLER_ATTACK
}

-- c_select(ThePlayer)
TheInput:AddGeneralControlHandler(function(control, pressed)
    if ThePlayer and ThePlayer:HasTag("gale_weaponcharge") then
        if table.contains(atk_btns, control) then
            SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"],
                               control, pressed)
        end

        -- if control == CONTROL_SECONDARY then
        --     if ThePlayer._gale_face_point_task then
        --         ThePlayer._gale_face_point_task:Cancel()
        --         ThePlayer._gale_face_point_task = nil
        --     end
        --     if pressed then
        --         ThePlayer._gale_face_point_task = ThePlayer:DoPeriodicTask(0,function()
        --             local x,y,z = TheInput:GetWorldPosition():Get()
        --             ThePlayer:ForceFacePoint(x,y,z)
        --             SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_face_point"],x,y,z,false)
        --         end)
        --     end
        -- end
    end
end)

------------------------------------------------------------------------------------------------------
-- 注册动作
AddAction("GALE_FREE_CHARGE", "GALE_FREE_CHARGE", function(act)
    if CanUseCharge(act.doer) then
        local weapon = act.invobject or
                           act.doer.components.inventory:GetEquippedItem(
                               EQUIPSLOTS.HANDS)
        if weapon and act.doer.components.gale_weaponcharge then
            local pos =
                act.doer.components.gale_control_key_helper:GetMousePosition()
            local undermouse =
                act.doer.components.gale_control_key_helper:GetEntityUnderMouse()
            act.doer.components.gale_weaponcharge:DoAttack(undermouse, pos)
            return true
        end
    end
end)
ACTIONS.GALE_FREE_CHARGE.priority = -99
ACTIONS.GALE_FREE_CHARGE.customarrivecheck = function() return true end
ACTIONS.GALE_FREE_CHARGE.rmb = true

-- ACTIONS.GALE_FREE_CHARGE.is_relative_to_platform = true
-- ACTIONS.GALE_FREE_CHARGE.rmb = true
-- ACTIONS.GALE_FREE_CHARGE.disable_platform_hopping = true

-- inst, doer, pos, actions, right, target
AddComponentAction("POINT", "gale_chargeable_weapon",
                   function(inst, doer, pos, actions, right, target)
    if right and not doer:HasTag("charging_attack_pre") and CanUseCharge(doer) and
        not doer._just_use_carry_charge then
        table.insert(actions, ACTIONS.GALE_FREE_CHARGE)
    end
end)

AddComponentAction("EQUIPPED", "gale_chargeable_weapon",
                   function(inst, doer, target, actions, right)
    if right and not doer:HasTag("charging_attack_pre") and CanUseCharge(doer) and
        not doer._just_use_carry_charge then
        table.insert(actions, ACTIONS.GALE_FREE_CHARGE)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_FREE_CHARGE,
                                                   function(inst)
    return ServerGetChargeSG(inst) or nil
end))
AddStategraphActionHandler("wilson_client",
                           ActionHandler(ACTIONS.GALE_FREE_CHARGE,
                                         function(inst)
    return ClientGetChargeSG(inst) or nil
end))

local old_ACTIONS_ATTACK_fn = ACTIONS.ATTACK.fn
ACTIONS.ATTACK.fn = function(act, ...)
    if CanUseCharge(act.doer) then
        local pos = (act.target and act.target:GetPosition()) or
                        act:GetActionPoint()
        act.doer.components.gale_weaponcharge:DoAttack(act.target, pos)
        return true
    else
        return old_ACTIONS_ATTACK_fn(act, ...)
    end
end

AddAction("GALE_FREE_SHOOT", "GALE_FREE_SHOOT", function(act)
    -- local pos = (act.pos and act.pos:GetPosition()) or (act.target and act.target:GetPosition()) or nil
    local pos = (act.target and act.target:GetPosition()) or
                    act.doer.components.gale_control_key_helper:GetMousePosition()
    if pos and act.invobject and act.invobject:IsValid() and
        act.invobject.components.equippable and
        act.invobject.components.equippable:IsEquipped() and
        act.invobject.components.inventoryitem and
        act.invobject.components.inventoryitem.owner == act.doer and
        act.invobject.components.gale_blaster_freeshoot then
        -- act.doer:ForceFacePoint(pos)
        return act.invobject.components.gale_blaster_freeshoot:FreeShoot(
                   act.doer, pos)
    end
end)
ACTIONS.GALE_FREE_SHOOT.priority = -99
ACTIONS.GALE_FREE_SHOOT.customarrivecheck = function() return true end
ACTIONS.GALE_FREE_SHOOT.rmb = true

-- inst, doer, pos, actions, right, target
AddComponentAction("POINT", "gale_blaster_freeshoot",
                   function(inst, doer, pos, actions, right, target)
    if right then table.insert(actions, ACTIONS.GALE_FREE_SHOOT) end
end)

AddComponentAction("EQUIPPED", "gale_blaster_freeshoot",
                   function(inst, doer, target, actions, right)
    if right then table.insert(actions, ACTIONS.GALE_FREE_SHOOT) end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_FREE_SHOOT,
                                                   function(inst)
    return "galeatk_quick_pistol"
end))
AddStategraphActionHandler("wilson_client",
                           ActionHandler(ACTIONS.GALE_FREE_SHOOT, function(inst)
    return "galeatk_quick_pistol"
end))

AddComponentPostInit("complexprojectile", function(self)
    local old_Launch = self.Launch
    self.Launch = function(self, targetPos, attacker, owningweapon, ...)
        self.targetpos = targetPos
        return old_Launch(self, targetPos, attacker, owningweapon, ...)
    end
end)

--------------------------------------------------------------------------------------------------
-- Damage Number API
AddClientModRPCHandler("gale_rpc", "popup_number", function(val, x, y, z)
    if ThePlayer and ThePlayer:IsValid() then
        if type(val) == "number" then
            local colour = val > 0 and {0 / 255, 255 / 255, 78 / 255, 1} or
                               {255 / 255, 80 / 255, 40 / 255, 1}
            local burst = math.abs(val) >= 100
            local size = burst and 48 or 32

            -- local str_val = string.format("%.1f")
            if math.abs(val) >= 1 then
                val = math.floor(math.abs(val) + 0.5)
                ThePlayer.HUD:ShowPopupNumber(val, size, Vector3(x, y, z), 40,
                                              colour, burst)
            else
                ThePlayer.HUD:ShowPopupNumber(
                    string.format("%.1f", math.abs(val)), size,
                    Vector3(x, y, z), 40, colour, burst)
            end
        elseif type(val) == "string" then
            ThePlayer.HUD:ShowPopupNumber(val, 32, Vector3(x, y, z), 40,
                                          {0 / 255, 0 / 255, 200 / 255, 1},
                                          false)
        end
    end
end)

AddPlayerPostInit(function(inst)
    -- inst:AddComponent("gale_mouse_position")
    inst:AddComponent("gale_control_key_helper")

    -- local old_ClearBufferedAction = inst.ClearBufferedAction
    -- inst.ClearBufferedAction = function(inst, ...)
    --     print("ClearBufferedAction is used !")
    --     return old_ClearBufferedAction(inst, ...)
    -- end
end)

AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then return inst end

    inst:ListenForEvent("healthdelta", function(inst, data)
        if inst.components.health then
            local overtime = data.overtime
            if overtime then return end
            local max = inst.components.health:GetMaxWithPenalty() or 0
            local apply_amount = (data.newpercent - data.oldpercent) * max
            local data_amount = data.amount
            if apply_amount and data_amount and data_amount ~= 0 then
                -- if math.abs(apply_amount) < 1 then
                --     apply_amount = GaleCommon.KeepNDecimalPlaces(apply_amount,1)
                -- else
                --     apply_amount = GaleCommon.KeepNDecimalPlaces(apply_amount)
                -- end

                if math.abs(apply_amount) <= 0.1 then
                    return -------太小的数字不显示
                end

                local x, y, z = inst:GetPosition():Get()
                for _, v in pairs(AllPlayers) do
                    if v and v:IsValid() and v:IsNear(inst, 40) then
                        SendModRPCToClient(
                            CLIENT_MOD_RPC["gale_rpc"]["popup_number"],
                            v.userid, apply_amount, x, y, z)
                    end
                end
            end
        end
    end)
end)
---------------------------------------------------------------------------------------------------

local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function CheckFuncVal(val, ...)
    local ret = val
    if val and type(val) == "function" then ret = val(...) end
    return ret
end

GLOBAL.GaleModAddKnockbackSG = function(sgname, add_data)
    add_data = add_data or {}
    local knockback_sg = State {
        name = "knockback",
        tags = {"busy", "nomorph", "nodangle"},

        onenter = function(inst, data)
            -- print(inst,"Enter knockback SG !")
            inst:StopBrain()
            ClearStatusAilments(inst)
            if inst.components.rider then
                inst.components.rider:ActualDismount()
            end
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if not data.is_dead then
                inst.AnimState:PlayAnimation(CheckFuncVal(
                                                 add_data.knockback_anim, inst) or
                                                 "hit")
            end

            inst.sg.statemem.hoc_hit = CheckFuncVal(add_data.hoc_hit, inst)
            if inst.sg.statemem.hoc_hit then
                inst.sg.statemem.fx =
                    inst:SpawnChild("gale_enemy_die_smoke_vfx")
            end
            if data ~= nil then
                if data.radius ~= nil and data.knocker ~= nil and
                    data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or
                                     data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or
                                  -.7
                    inst.sg.statemem.speed =
                        (CheckFuncVal(add_data.speed, inst) or
                            (data.strengthmult or 1) * 12) * k
                    inst.sg.statemem.dspeed =
                        CheckFuncVal(add_data.dspeed, inst) or 0

                    inst.sg.statemem.hspeed =
                        inst.sg.statemem.hoc_hit and (data.strengthmult or 1) *
                            20 * math.abs(k) or 0
                    inst.sg.statemem.dhspeed =
                        inst.sg.statemem.hoc_hit and -1.25 or 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed,
                                                 inst.sg.statemem.hspeed, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed,
                                                 inst.sg.statemem.hspeed, 0)
                    end
                end
            end

            -- if add_data.timeout then
            -- 	inst.sg:SetTimeout(add_data.timeout)
            -- end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil and not inst.sg.statemem.sinked then
                inst.sg.statemem.speed =
                    inst.sg.statemem.speed + inst.sg.statemem.dspeed
                inst.sg.statemem.hspeed =
                    inst.sg.statemem.hspeed + inst.sg.statemem.dhspeed

                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed =
                        inst.sg.statemem.dspeed +
                            (CheckFuncVal(add_data.vec_acc, inst) or 0.075)
                else
                    inst.sg.statemem.speed = 0
                end
                inst.Physics:SetMotorVel(
                    inst.sg.statemem.reverse and -inst.sg.statemem.speed or
                        inst.sg.statemem.speed, inst.sg.statemem.hspeed, 0)

                local x, y, z = inst:GetPosition():Get()
                if not inst.components.amphibiouscreature and inst:IsOnOcean() and
                    y <= 0.1 then
                    inst.Transform:SetPosition(x, 0, z)
                    if inst.sg.sg.events["onsink"] and
                        not inst.components.health:IsDead() then
                        inst.sg.statemem.sinked = true
                        inst:PushEvent("onsink", {})
                    else
                        SpawnAt("crab_king_waterspout", inst).Transform:SetScale(
                            1, 0.7, 0.7)
                        inst:Remove()
                    end
                    return
                end
                if inst.sg.statemem.hoc_hit then
                    if y <= 0.1 and inst.sg.statemem.hspeed <= -0.5 then
                        inst.sg.statemem.hspeed = -0.5
                        if inst.AnimState:AnimDone() and
                            not inst.components.health:IsDead() then
                            inst.Transform:SetPosition(x, 0, z)
                            inst.sg:GoToState("idle")
                        end
                        if math.abs(inst.sg.statemem.speed or 0) <= 0.75 then
                            if inst.sg.statemem.fx and
                                inst.sg.statemem.fx:IsValid() then
                                inst.sg.statemem.fx:Remove()
                            end
                            inst.sg.statemem.fx = nil
                        end
                    end
                end
            end

            -- if inst.components.health and inst.components.health:IsDead() then
            --     inst.AnimState:SetHaunted(true)
            -- end
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end)
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst.sg.statemem.hoc_hit then
                    if not inst.components.health:IsDead() then
                        inst.sg:GoToState("idle")
                    end
                end
            end)
        },

        -- ontimeout = function(inst)
        -- 	if not inst.components.health:IsDead() then
        --         inst.sg:GoToState("idle")
        --     end
        -- end,

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then inst.Physics:Stop() end
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
            inst:RestartBrain()
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end
    }
    AddStategraphState(sgname, knockback_sg)

    AddStategraphEvent(sgname, EventHandler("knockback", function(inst, data)
        data.is_dead = inst.components.health:IsDead()
        if data.is_dead and add_data.dont_knockback_ondeath then return end

        inst.sg:GoToState("knockback", data)
    end))

    -- local sg_file = require("stategraphs/SG"..sgname)
    -- if not sg_file.events["knockback"] or add_data.force_overwrite then
    --    	AddStategraphEvent(sgname,EventHandler("knockback", function(inst, data)
    --        	inst.sg:GoToState("knockback", data)
    --    	end))
    -- else
    -- 	print(string.format("[GaleModAddKnockbackSG] %s already has a knockback EventHandler",sgname))
    -- end

    -- AddStategraphPostInit(sgname, function(sg)
    -- 	local knockback_event = sg.events["knockback"]
    -- 	if knockback_event then
    -- 		print(string.format("[GaleModAddKnockbackSG] %s already has a knockback EventHandler",sgname))
    -- 	end
    -- 	if add_data.force_overwrite or not knockback_event then
    -- 		sg.events["knockback"] = event_handler
    -- 	end
    -- end)
end

GaleModAddKnockbackSG("spider", {hoc_hit = true, vec_acc = 0.0075})
-- GaleModAddKnockbackSG("SGtyphon_mimic",{hoc_hit=true,vec_acc = 0.0075})
GaleModAddKnockbackSG("hound", {hoc_hit = true, vec_acc = 0.0075})
GaleModAddKnockbackSG("frog", {
    knockback_anim = "fall_idle",
    hoc_hit = true,
    vec_acc = 0.0075
})
GaleModAddKnockbackSG("squid", {hoc_hit = true, vec_acc = 0.0075})
GaleModAddKnockbackSG("mole", {
    knockback_anim = "stunned_loop",
    hoc_hit = true,
    vec_acc = 0.0075
})

-- GaleModAddKnockbackSG("pig",{
-- 	knockback_anim = function(inst) return inst.prefab == "bunnyman" and "hit" or "smacked" end,
-- 	hoc_hit = function(inst) return inst.prefab == "bunnyman" and true or false end,
-- 	vec_acc = function(inst) return inst.prefab == "bunnyman" and 0.0075 or 0.075 end,
-- })

GaleModAddKnockbackSG("pig", {
    knockback_anim = "smacked",
    hoc_hit = false,
    vec_acc = 0.075
})

GaleModAddKnockbackSG("merm", {hoc_hit = true, vec_acc = 0.0075})
GaleModAddKnockbackSG("werepig", {hoc_hit = true, vec_acc = 0.0075})
GaleModAddKnockbackSG("moonpig", {hoc_hit = true, vec_acc = 0.0075})

GaleModAddKnockbackSG("spiderqueen")
GaleModAddKnockbackSG("leif")

GaleModAddKnockbackSG("beefalo")
GaleModAddKnockbackSG("koalefant", {dont_knockback_ondeath = true})
GaleModAddKnockbackSG("warg", {dont_knockback_ondeath = true})
GaleModAddKnockbackSG("spat")

GaleModAddKnockbackSG("deerclops", {speed = 3, dont_knockback_ondeath = true})
GaleModAddKnockbackSG("bearger", {
    knockback_anim = "standing_hit",
    speed = 3,
    dont_knockback_ondeath = true
})
GaleModAddKnockbackSG("moose", {speed = 6, dont_knockback_ondeath = true})
GaleModAddKnockbackSG("dragonfly", {speed = 3, dont_knockback_ondeath = true})

GaleModAddKnockbackSG("mossling", {
    knockback_anim = "meep",
    hoc_hit = true,
    vec_acc = 0.0075
})

GaleModAddKnockbackSG("bishop")
GaleModAddKnockbackSG("knight")
GaleModAddKnockbackSG("rook")
GaleModAddKnockbackSG("powdermonkey", {
    knockback_anim = "hit",
    hoc_hit = true,
    vec_acc = 0.0075
})
