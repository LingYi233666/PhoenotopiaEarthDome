-- local DEFAULT_TIP_FN = {
--     WITH_DURATION = function(inst,tip_data)
--         local time_remain = tip_data.time_remain
--         if time_remain == nil or time_remain < 0 then
--             time_remain = "-"
--         end
--         return string.format("剩余时间:%s秒",tostring(time_remain))
--     end,
-- }

local GaleConditionUtil = require "util/gale_conditions"
local GaleCommon = require "util/gale_common"

local function IsInBattle(target)
    return GaleConditionUtil.GetCondition(target, "condition_inbattle") ~= nil
end

local function BuffDescFormat(inst, ...)
    return string.format(STRINGS.GALE_BUFF_DESC[string.upper(inst.prefab)].DYNAMIC, ...)
end

local data_lists = {
    condition_inbattle = {
        OnAttached = function(inst, target)
            target:PushEvent("battlestate_change", { state = "start" })
            if not target:HasTag("player") then
                inst:SetCanShow(false)
            end
        end,
        OnDetached = function(inst, target)
            target:PushEvent("battlestate_change", { state = "over" })
        end,
        OnExtended = function(inst, target)
            target:PushEvent("battlestate_change", { state = "continue" })
        end,
        addition_tip_fn = function(inst, tip_data)
            -- print("combat addition_tip_fn:",tip_data.target,tip_data.time_remain)
            -- ThePlayer.components.combat:GetAttacked(ThePlayer,1)
            -- if not (tip_data.target.name and tip_data.time_remain) then
            --     print("battle nil error")
            --     print("tip_data.target = [",tip_data.target,"]")
            --     print("tip_data.target.name = [",tip_data.target.name,"]")
            --     print("tip_data.time_remain = [",tip_data.time_remain,"]")
            --     print("tip_data.stacks = [",tip_data.stacks,"]")
            --     print("tip_data.max_stacks = [",tip_data.max_stacks,"]")
            --     print("tip_data.duration = [",tip_data.duration,"]")
            -- end
            return BuffDescFormat(inst, tip_data.target.name or "", tip_data.time_remain)
        end,
        duration = 10,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
        max_stacks = 1,
        keepondespawn = false,
    },

    -- condition_lullaby = {
    --     OnAttached = function(inst,target)
    --         -- inst:SetCanShow(false)
    --         target.components.gale_stamina.recoverrate_multipliers:SetModifier(inst,1.5,inst.prefab)
    --         -- target.components.locomotor:SetExternalSpeedMultiplier(inst,inst.prefab,1.2)
    --     end,
    --     OnDetached = function(inst,target)
    --         -- target.components.locomotor:RemoveExternalSpeedMultiplier(inst,inst.prefab)
    --         target.components.gale_stamina.recoverrate_multipliers:RemoveModifier(inst,inst.prefab)
    --     end,
    --     OnStackChange = function(inst,target,new_stack,old_stack)

    --     end,
    --     addition_tip_fn = function(inst,tip_data)
    --         return BuffDescFormat(inst,tip_data.time_remain)
    --     end,
    --     dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
    --     keepondespawn = true,
    --     max_stacks = 1,
    --     duration = 60,
    -- },

    condition_power = {
        OnAttached = function(inst, target)
            -- if IsInBattle(target) then

            -- else
            --     print("[condition_power] Try add power without battle,remove self...")
            --     GaleConditionUtil.RemoveConditionAll(target,inst.prefab)
            -- end

            inst._on_target_battle_change = function(target, data)
                local state = data.state
                if state == "over" then
                    GaleConditionUtil.RemoveConditionAll(target, inst.prefab)
                end
            end

            inst:ListenForEvent("battlestate_change", inst._on_target_battle_change, target)
        end,
        OnDetached = function(inst, target)
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst, inst.prefab)
            if inst._on_target_battle_change then
                inst:RemoveEventCallback("battlestate_change", inst._on_target_battle_change, target)
            end
            inst._on_target_battle_change = nil
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)
            -- TODO:播放力量特效
            if new_stack >= old_stack then
                target:SpawnChild("condition_power_fx")
            end
            -- end of TODO
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 1 + new_stack * 0.05, inst.prefab)
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.stacks * 5)
        end,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
        keepondespawn = false,
    },

    condition_gale_boon = {
        OnAttached = function(inst, target)
            inst._on_target_battle_change = function(target, data)
                local state = data.state
                if state == "start" then
                    GaleConditionUtil.AddCondition(target, "condition_power", inst.condition_data.stacks)
                end
            end

            inst:ListenForEvent("battlestate_change", inst._on_target_battle_change, target)
        end,
        OnDetached = function(inst, target)
            -- print("condition_gale_boon OnDetached.")
            GaleConditionUtil.RemoveCondition(target, "condition_power", inst.condition_data.stacks)
            inst:RemoveEventCallback("battlestate_change", inst._on_target_battle_change, target)
            inst._on_target_battle_change = nil
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.stacks)
        end,
        dtype = STRINGS.GALE_BUFF_DTYPE.PASSIVE,
        keepondisabled = true,
        keepondespawn = false,
    },

    condition_metallic = {
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.stacks)
        end,
        max_stacks = 1,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
        immune_debuffs = {
            "condition_bleed",
            "condition_wound",
        },
        keepondespawn = false,
    },

    condition_wound = {
        OnDetached = function(inst, target)
            target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst, inst.prefab)
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)
            -- TODO:播放重伤特效
            if new_stack >= old_stack then
                target:SpawnChild("condition_wound_fx")
            end
            -- end of TODO
            target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 1 + new_stack * 0.05, inst.prefab)
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.stacks * 5, tip_data.time_remain)
        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 12)
                GaleConditionUtil.RemoveCondition(target, inst.prefab, 1)
            end
        end,
        duration = 12,
        dtype = STRINGS.GALE_BUFF_DTYPE.DEBUFF,
    },

    condition_impair = {
        OnDetached = function(inst, target)
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst, inst.prefab)
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)
            -- TODO:播放致残特效
            if new_stack >= old_stack then
                target:SpawnChild("condition_impair_fx")
            end
            -- end of TODO
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 1 - 0.33, inst.prefab)
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.time_remain)
        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 10)
                GaleConditionUtil.RemoveCondition(target, inst.prefab, 1)
            end
        end,
        duration = 10,
        dtype = STRINGS.GALE_BUFF_DTYPE.DEBUFF,
    },

    condition_bleed = {
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.time_remain, tip_data.stacks)
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)
            -- TODO:播放出血特效
            if new_stack >= old_stack then
                target:SpawnChild("condition_bleed_fx_small")
            end
            -- end of TODO
        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                target:SpawnChild("condition_bleed_fx")
                inst.components.timer:StartTimer("regenover", 10)
                if target.components.health then
                    target.components.health:DoDelta(-inst.condition_data.stacks, nil, inst.prefab, nil, nil, true)
                    target:PushEvent("attacked", { attacker = inst, damage = 0, })
                end
                GaleConditionUtil.RemoveCondition(target, inst.prefab, math.ceil(inst.condition_data.stacks / 2))
            end
        end,
        duration = 10,
        no_timer_extended = true,
        dtype = STRINGS.GALE_BUFF_DTYPE.DEBUFF,
    },
    -- c_condition("condition_mending")
    condition_mending = {
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.time_remain)
        end,
        OnAttached = function(inst, target)
            inst.rescue_task = inst:DoPeriodicTask(1, function()
                if target.components.health and target.components.health:IsHurt() and not GaleCommon.IsTruelyDead(target) then
                    target.components.health:DoDelta(GetRandomMinMax(0.75, 1), true, inst.prefab)
                    GaleConditionUtil.RemoveCondition(target, inst.prefab, 1)
                end
            end)
        end,
        OnDetached = function(inst, target)
            if inst.rescue_task then
                inst.rescue_task:Cancel()
                inst.rescue_task = nil
            end
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)

        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 12)
                GaleConditionUtil.RemoveCondition(target, inst.prefab, 1)
            end
        end,
        duration = 12,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
    },

    condition_carry_charge = {
        assets = {},
        OnAttached = function(inst, target)
            inst:SetCanShow(false)
            target:AddTag("gale_skill_carry_charge_trigger")

            -- target.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge_carry")
            -- target.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge_carry")

            -- inst._on_owner_new_state = function(owner,data)
            --     if owner.sg:HasStateTag("charging_attack_pre") then
            --         owner.components.gale_weaponcharge:Complete()
            --         GaleConditionUtil.RemoveCondition(target,inst.prefab)
            --     end
            -- end
            -- inst:ListenForEvent("newstate",inst._on_owner_new_state,target)


            inst.vfx = target:SpawnChild("gale_carry_charge_vfx")
        end,
        OnDetached = function(inst, target)
            target:RemoveTag("gale_skill_carry_charge_trigger")
            if inst.vfx then
                inst.vfx:Remove()
                inst.vfx = nil
            end
            -- inst:RemoveEventCallback("newstate",inst._on_owner_new_state,target)
        end,
        addition_tip_fn = function(inst, tip_data)
            return "condition_carry_charge"
        end,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
        keepondespawn = false,
        max_stacks = 1,
    },

    condition_dread = {
        OnAttached = function(inst, target)

        end,
        OnDetached = function(inst, target)

        end,
        OnStackChange = function(inst, target, new_stack, old_stack)
            if new_stack >= 100 then
                if not IsEntityDeadOrGhost(target, true) then
                    target:SpawnChild("condition_dread_fx")
                    -- target.components.health:Kill()
                    target.components.health:DoDelta(-target.components.health.currenthealth, nil, inst.prefab, nil, nil,
                        true)
                end
            end
            -- If dead,it will be removed automatically
            -- GaleConditionUtil.RemoveConditionAll(target,inst.prefab)
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst, tip_data.target.name or "")
        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 1)
                GaleConditionUtil.RemoveCondition(target, inst.prefab)
            end
        end,
        duration = 1,
        dtype = STRINGS.GALE_BUFF_DTYPE.DEBUFF,
        keepondespawn = true,
        max_stacks = 100,
    },

    -- BLOATED
    condition_bloated = {
        assets = {

        },
        OnAttached = function(inst, target)
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 0.9, inst.prefab)
            target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 1.1, inst.prefab)
            target.components.locomotor:SetExternalSpeedMultiplier(inst, inst.prefab, 0.8)
        end,
        OnDetached = function(inst, target)
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst, inst.prefab)
            target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst, inst.prefab)
            target.components.locomotor:RemoveExternalSpeedMultiplier(inst, inst.prefab)
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst)
        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 1)
                GaleConditionUtil.RemoveCondition(target, inst.prefab)
            end
        end,
        duration = 1,
        dtype = STRINGS.GALE_BUFF_DTYPE.DEBUFF,
        keepondespawn = true,
    },

    condition_stamina_recover = {
        OnAttached = function(inst, target)
            target.components.gale_stamina.recoverrate_multipliers:SetModifier(inst, 2, inst.prefab)
            target.components.gale_stamina.pausetimerate_multipliers:SetModifier(inst, 0.33, inst.prefab)
        end,
        OnDetached = function(inst, target)
            target.components.gale_stamina.recoverrate_multipliers:RemoveModifier(inst, inst.prefab)
            target.components.gale_stamina.pausetimerate_multipliers:RemoveModifier(inst, inst.prefab)
        end,
        OnStackChange = function(inst, target, new_stack, old_stack)

        end,
        OnTimerDone = function(inst, data)
            if data.name == "regenover" then
                local target = inst.components.debuff.target
                inst.components.timer:StartTimer("regenover", 1)
                GaleConditionUtil.RemoveCondition(target, inst.prefab, 1)
            end
        end,
        addition_tip_fn = function(inst, tip_data)
            return BuffDescFormat(inst)
        end,
        dtype = STRINGS.GALE_BUFF_DTYPE.BUFF,
        keepondespawn = true,
        max_stacks = 999,
        duration = 1,
    },
}



local function NormalConditionFn(data)
    local function UpdateDebuffUI(inst, target)
        local tip_data = {
            target = target,
            stacks = inst.condition_data.stacks,
            max_stacks = inst.condition_data.max_stacks,
            time_remain = inst.components.timer:GetTimeLeft("regenover"),
            duration = data.duration
        }
        inst.condition_data.addition_tip = inst.condition_data.addition_tip_fn(inst, tip_data)

        if inst.condition_data.shown then
            if target:HasTag("player") then
                SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["update_buff"], target.userid,
                    inst.prefab,
                    inst.condition_data.stacks,
                    inst.condition_data.buff_name,
                    inst.condition_data.addition_tip,
                    inst.condition_data.image_name,
                    inst.condition_data.dtype
                )
            end
        end
    end

    local function WrapedOnAttached(inst, target)
        -- print(inst,"OnAttached",target)
        if data.OnAttached then
            data.OnAttached(inst, target)
        end
        target:AddChild(inst)
        inst.Transform:SetPosition(0, 0, 0)


        -- 清除自己免疫的debuff
        for k, v in pairs(inst.condition_data.immune_debuffs) do
            if target.components.debuffable:GetDebuff(v) ~= nil then
                GaleConditionUtil.RemoveConditionAll(target, v)
            end
        end


        inst.AddToUiTask = inst:DoTaskInTime(0, function()
            UpdateDebuffUI(inst, target)
        end)


        inst.UpdateUiTask = inst:DoPeriodicTask(0.33, function()
            UpdateDebuffUI(inst, target)
        end)
    end

    local function WrapedOnDetached(inst, target)
        -- print(inst,"OnDetached",target)
        if data.OnDetached then
            data.OnDetached(inst, target)
        end
        if inst.AddToUiTask then
            inst.AddToUiTask:Cancel()
            inst.AddToUiTask = nil
        end
        if inst.UpdateUiTask then
            inst.UpdateUiTask:Cancel()
            inst.UpdateUiTask = nil
        end

        if inst.components.timer:TimerExists("regenover") then
            inst.components.timer:StopTimer("regenover")
        end

        if target:HasTag("player") then
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["remove_buff"], target.userid, inst.prefab)
        end
        inst:Remove()
    end

    local function WrapedOnExtended(inst, target)
        -- print(inst,"OnExtended",target)
        if data.OnExtended then
            data.OnExtended(inst, target)
        end
        if inst.components.timer:TimerExists("regenover") and not data.no_timer_extended then
            inst.components.timer:StopTimer("regenover")
            inst.components.timer:StartTimer("regenover", data.duration)
        end
    end

    local function SetStacks(inst, stacks)
        local old_stack = inst.condition_data.stacks
        inst.condition_data.stacks = math.min(stacks, inst.condition_data.max_stacks)
        if data.OnStackChange then
            -- inst,target,new_stack,old_stack
            data.OnStackChange(inst, inst.components.debuff.target, inst.condition_data.stacks, old_stack)
        end
    end

    local function SetCanShow(inst, enable)
        local old_can_show = inst.condition_data.shown
        inst.condition_data.shown = enable

        local target = inst.components.debuff.target
        if old_can_show and not enable then
            if target and target:HasTag("player") then
                SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["remove_buff"], target.userid, inst.prefab)
            end
        elseif not old_can_show and enable then

        end
    end

    local function OnSave(inst, data)
        data.stacks = inst.condition_data.stacks
    end

    local function OnLoad(inst, data)
        if data then
            if data.stacks then
                inst.condition_data.stacks = data.stacks
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)

            return inst
        end

        inst.entity:AddTransform()

        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false


        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOBLOCK")
        inst:AddTag("NOCLICK")
        inst:AddTag("gale_condition")

        inst.condition_data = {
            shown = true,
            stacks = 1,
            dtype = data.dtype,
            max_stacks = data.max_stacks or 99,
            buff_name = data.buff_name or STRINGS.NAMES[string.upper(data.prefab_name)] or "Unknown Condition Name",
            addition_tip_fn = data.addition_tip_fn or function() return "Unknown Condition Tip" end,
            image_name = data.image_name or data.prefab_name,
            addition_tip = nil,
            immune_debuffs = data.immune_debuffs or {}
        }

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(WrapedOnAttached)
        inst.components.debuff:SetDetachedFn(WrapedOnDetached)
        inst.components.debuff:SetExtendedFn(WrapedOnExtended)
        inst.components.debuff.keepondisabled = data.keepondisabled
        if data.keepondespawn == nil or data.keepondespawn == true then
            inst.components.debuff.keepondespawn = true
        else
            inst.components.debuff.keepondespawn = false
        end

        inst:AddComponent("timer")

        if data.duration then
            inst.components.timer:StartTimer("regenover", data.duration)
        end


        data.OnTimerDone = data.OnTimerDone or function(self, data)
            if data.name == "regenover" then
                self.components.debuff:Stop()
            end
        end
        inst:ListenForEvent("timerdone", data.OnTimerDone)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.SetStacks = SetStacks
        inst.SetCanShow = SetCanShow

        if data.shown ~= nil then
            inst:SetCanShow(data.shown)
        end

        return inst
    end

    return fn
end

local ents = {}
local assets = {}

for prefab_name, data in pairs(data_lists) do
    if data.assets then
        for k, v in pairs(data.assets) do
            table.insert(assets, v)
        end
    else
        table.insert(assets, Asset("ATLAS", "images/ui/bufficons/" .. prefab_name .. ".xml"))
        table.insert(assets, Asset("IMAGE", "images/ui/bufficons/" .. prefab_name .. ".tex"))
    end
end

for prefab_name, data in pairs(data_lists) do
    data.prefab_name = prefab_name
    table.insert(ents, Prefab(prefab_name, NormalConditionFn(data), assets))
end

return unpack(ents)
