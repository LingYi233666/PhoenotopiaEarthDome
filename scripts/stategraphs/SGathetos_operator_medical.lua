require("stategraphs/commonstates")


local actionhandlers = {

}

local events = {
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
}

local function HealingTimelineWrap(base_time, timeconsume_set)
    local addition_timeline = {
        TimeEvent(base_time, function(inst)
            if inst.sg.statemem.timeconsume ~= timeconsume_set then
                return
            end

            local target = inst.sg.statemem.target
            if target and target:IsValid() and not IsEntityDeadOrGhost(target, true) then
                inst:DoHeal(target)
                inst.healed_players[target] = true
                inst.sg.statemem.healing_success = true
                inst.components.timer:StartTimer("heal_cd", 30)
                inst.SoundEmitter:PlaySound(inst.sounds.healing_success)

                local fx = SpawnAt("gale_laser_explosion", target)
                fx.Transform:SetScale(0.6, 0.6, 0.6)
                fx.AnimState:SetFinalOffset(1)
            end
        end),

        TimeEvent(base_time + 10 * FRAMES, function(inst)
            if inst.sg.statemem.timeconsume ~= timeconsume_set then
                return
            end

            if inst.sg.statemem.fx then
                inst.sg.statemem.fx:Remove()
                inst.sg.statemem.fx = nil
            end
            inst.SoundEmitter:KillSound("scan")

            if not inst.sg.statemem.healing_success then
                inst.sg:GoToState("idle", true)
            end
        end),

        TimeEvent(base_time + 20 * FRAMES, function(inst)
            if inst.sg.statemem.timeconsume ~= timeconsume_set then
                return
            end

            inst:DoTalk("HEAL_SUCCESS")
        end),

        TimeEvent(base_time + 70 * FRAMES, function(inst)
            if inst.sg.statemem.timeconsume ~= timeconsume_set then
                return
            end

            inst:DoTalk("AFTER_HEALING")
        end),
    }

    return addition_timeline
end


local scanandheal_timeline = {
    TimeEvent(0 * FRAMES, function(inst)
        local fx = inst:SpawnChild("athetos_operator_medical_scan_vfx")
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "drone", 0, 0, 0)

        inst.sg.statemem.fx = fx

        inst.SoundEmitter:PlaySound(inst.sounds.scan, "scan")
        inst:DoTalk("DIAGNOSING")
    end),

    TimeEvent(33 * FRAMES, function(inst)
        local target = inst.sg.statemem.target
        if target and target:IsValid() and not IsEntityDeadOrGhost(target, true) then
            local index, can_handle = inst:GetDiagResultIndex(target)
            local index2 = inst:DoTalk(index)

            inst.sg.statemem.can_handle = can_handle

            if index == "NO_TRAUMA" then
                inst.healed_players[target] = true
            end

            if index2 == "ROUGH_DAY" then
                inst.sg.statemem.timeconsume = 1
            elseif index == "DIAG_RESULT_BURN"
            -- or index == "DIAG_RESULT_MANY_TRAUMA"
            then
                inst.sg.statemem.timeconsume = 3
            elseif index == "DIAG_RESULT_FRACTURE"
                or index == "DIAG_RESULT_RADIATION"
                or index2 == "BLEED2"
                or index == "DIAG_RESULT_CONCUSSION" then
                inst.sg.statemem.timeconsume = 4
            end
        else
            inst.sg.statemem.can_handle = false
        end
    end),

    TimeEvent(75 * FRAMES, function(inst)
        if not inst.sg.statemem.can_handle then
            inst.sg:GoToState("idle")
        end
    end),
}

ConcatArrays(scanandheal_timeline, HealingTimelineWrap(70 * FRAMES, 1))
ConcatArrays(scanandheal_timeline, HealingTimelineWrap(170 * FRAMES, 2))
ConcatArrays(scanandheal_timeline, HealingTimelineWrap(195 * FRAMES, 3))
ConcatArrays(scanandheal_timeline, HealingTimelineWrap(220 * FRAMES, 4))



local states = {
    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("hit", true)
            RemovePhysicsColliders(inst)

            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end,

        timeline = {
            TimeEvent(22 * FRAMES, function(inst)
                local explo = SpawnAt("gale_bomb_projectile_explode", inst, { 1.5, 1.5, 1.5 }, Vector3(0, 1, 0))
                explo:SpawnChild("gale_normal_explode_vfx")

                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/zombot/p1_zombot_shutoff")
                -- inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
                inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
                ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)

                inst.components.lootdropper:DropLoot(inst:GetPosition() + Vector3(0, 1, 0))

                inst.Light:Enable(false)
                inst.DynamicShadow:Enable(false)
                inst:Hide()
            end),
        },
    },

    State {
        name = "repair_done",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("repair_done")
        end,

        timeline = {
            TimeEvent(10 * FRAMES, function(inst)
                inst:DoTalk("ALL_SYSTEM_OPERATIONAL")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "chat",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.target

            inst:DoTalk("CHAT")

            inst.AnimState:PushAnimation("idle")

            inst.sg:SetTimeout(data.duration or 3)
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if target and target:IsValid() and target:IsNear(inst, 12) then
                inst:ForceFacePoint(target:GetPosition())
            else
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            -- if inst.SoundEmitter:PlayingSound("talking") then
            --     inst.SoundEmitter:KillSound("talking")
            -- end
        end
    },

    State {
        name = "greeting",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.target

            inst:DoTalk("SEE_PLAYER", inst.sg.statemem.target)

            inst.AnimState:PushAnimation("idle")


            inst.sg:SetTimeout(data.duration or 3)
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if target and target:IsValid() and target:IsNear(inst, 12) then
                inst:ForceFacePoint(target:GetPosition())
            else
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            -- if inst.SoundEmitter:PlayingSound("talking") then
            --     inst.SoundEmitter:KillSound("talking")
            -- end
        end
    },

    -- c_select().sg:GoToState("scanandheal",ThePlayer)
    State {
        name = "scanandheal",
        tags = { "busy", },

        onenter = function(inst, target)
            if not target then
                inst.sg:GoToState("idle")
                return
            end

            inst:ForceFacePoint(target:GetPosition())

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle", true)

            inst.sg.statemem.target = target
            inst.sg.statemem.can_handle = true
            inst.sg.statemem.timeconsume = 2

            inst.sg:SetTimeout(12)
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if target and target:IsValid() and not IsEntityDeadOrGhost(target, true) then
                inst:ForceFacePoint(target:GetPosition())
                if not target:IsNear(inst, 5) then
                    if inst.sg.statemem.can_handle and not inst.sg.statemem.healing_success then
                        inst:DoTalk("HOLD_STILL")
                    end
                    inst.sg:GoToState("idle")
                end
            end
        end,

        timeline = scanandheal_timeline,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.fx then
                inst.sg.statemem.fx:Remove()
            end

            inst.SoundEmitter:KillSound("scan")
        end,
    },
}

CommonStates.AddIdle(states, nil, "idle", {
    TimeEvent(0, function(inst)
        inst.AnimState:PushAnimation("idle", true)
    end)
})
CommonStates.AddHitState(states, {
    TimeEvent(0, function(inst)
        inst.sg:AddStateTag("caninterrupt")
    end)
})
CommonStates.AddWalkStates(states, nil, {
    startwalk = "idle",
    walk = "idle",
    stopwalk = "idle",
})
CommonStates.AddRunStates(states, nil, {
    startrun = "idle",
    run = "idle",
    stoprun = "idle",
})


return StateGraph("SGathetos_operator_medical", states, events, "idle", actionhandlers)
