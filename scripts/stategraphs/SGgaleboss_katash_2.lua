local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    -- CommonHandlers.OnLocomote(true, false),
    -- CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
    EventHandler("minhealth", function(inst, data)
        if not inst.sg:HasStateTag("knockback") and inst.mind_controled then
            inst.sg:GoToState("knockback_stage1")
        end
    end),
}

local function SetVel(inst, vel)
    local predict_pos = inst:GetPosition() + vel
    local lx, ly, lz = inst.entity:WorldToLocalSpace(predict_pos.x, 0, predict_pos.z)
    inst.Physics:SetMotorVel(lx, 0, lz)
end

local function VelUpdatePunchLoop(inst, target_pos)
    inst:ForceFacePoint(target_pos)

    local cur_vel = Vector3(inst.Physics:GetVelocity())
    local towards = (target_pos - inst:GetPosition()):GetNormalized()
    local dist = (target_pos - inst:GetPosition()):Length()
    local acc = Remap(math.clamp(dist, 1, 8), 1, 8, 20, 15)

    if GetTime() - (inst.components.combat.lastwasattackedtime or 0) <= 0.3 then
        acc = acc * 0.1
    end

    local next_vel = cur_vel + towards * FRAMES * acc

    if next_vel:Dot(towards) > 0 then
        if next_vel:Length() >= 6 then
            next_vel = next_vel:GetNormalized() * 6
        end
    else
        if next_vel:Length() >= 6 then
            next_vel = next_vel:GetNormalized() * 6
        end
    end

    SetVel(inst, next_vel)
end

local function UpbodyDoAttack(inst)
    local victims = GaleCommon.AoeDoAttack(inst, inst:GetPosition(), inst.components.combat:GetHitRange(),
        nil,
        function(inst, v)
            local tar_deg = GaleCommon.GetFaceAngle(inst, v)
            local face_angle = 90
            return inst.components.combat:CanTarget(v) and
                tar_deg >= -face_angle / 2 and
                tar_deg <= face_angle / 2
        end)

    for k, v in pairs(victims) do
        if v.components.sanity and not IsEntityDead(v, true) then
            v.components.sanity:DoDelta(-1, true)
        end
    end
end

local PUNCH_LOOP_ANIM_SPEED = 2.0
local LEAP_DURATION = 13 * FRAMES

local idle_anims = {
    -- { "idle_groggy_pre", "idle_groggy" },
    { "idle_lunacy_pre", "idle_lunacy_loop" },
}

local states = {
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim_list

            if inst.mind_controled then
                anim_list = idle_anims[math.random(1, #idle_anims)]
            else
                anim_list = { "idle_groggy_pre", "idle_groggy" }
            end

            if pushanim then
                for k, v in pairs(anim_list) do
                    inst.AnimState:PushAnimation(v, k == #anim_list)
                end
            else
                inst.AnimState:PlayAnimation(anim_list[1], #anim_list == 1)
                for k, v in pairs(anim_list) do
                    if k > 1 then
                        inst.AnimState:PushAnimation(v, k == #anim_list)
                    end
                end
            end
        end,

        timeline = {},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    -- Only for up body
    State {
        name = "upbody_punch_loop",
        tags = {},

        onenter = function(inst, index)
            index = index or math.random(1, 2)
            local anims = {
                "atk_werewilba",
                "atk_2_werewilba",
            }

            inst.AnimState:PlayAnimation(anims[index])
            inst.sg.statemem.cur_index = index
            inst.sg.statemem.next_index = (index == 2) and 1 or 2

            inst.sg:SetTimeout(14 * FRAMES / PUNCH_LOOP_ANIM_SPEED)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

            inst.AnimState:SetDeltaTimeMultiplier(PUNCH_LOOP_ANIM_SPEED)
        end,

        timeline = {
            TimeEvent(2 * FRAMES / PUNCH_LOOP_ANIM_SPEED, function(inst)
                inst:SpawnChild("galeboss_katash_2_punch_fx"):SetAnim(inst.sg.statemem.cur_index)
            end),

            TimeEvent(6 * FRAMES / PUNCH_LOOP_ANIM_SPEED, function(inst)
                -- TODO: Play some fancy attack sfx here
                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/typhon_phantom/whip")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),

            TimeEvent(9 * FRAMES / PUNCH_LOOP_ANIM_SPEED, function(inst)
                local parent = inst.entity:GetParent()
                if parent then
                    parent:PushEvent("upbody_doattack")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("upbody_punch_loop", inst.sg.statemem.next_index)
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("upbody_punch_loop", inst.sg.statemem.next_index)
            end),
        },
    },

    State {
        name = "punch_loop",
        tags = { "attack", "busy", "abouttoattack", },

        onenter = function(inst, data)
            data = data or {}

            inst.sg.statemem.up_body = inst:EnableUpBody(true)
            inst.sg.statemem.up_body.sg:GoToState("upbody_punch_loop")
            -- inst.sg.statemem.

            inst.AnimState:PlayAnimation("idle_walk_pre")
            inst.AnimState:PushAnimation("idle_walk", true)

            inst.sg:SetTimeout(data.timeout or 15)

            inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)
            inst.AnimState:SetDeltaTimeMultiplier(2)
        end,

        onupdate = function(inst)
            local target = inst.components.combat.target
            if target then
                VelUpdatePunchLoop(inst, target:GetPosition())
            else
                inst.AnimState:PlayAnimation("idle_walk_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("idle_walk_pst")
            inst.sg:GoToState("idle", true)
        end,

        timeline = {

        },

        onexit = function(inst)
            inst:EnableUpBody(false)
            inst.Physics:Stop()
            inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.ALWAYS)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("upbody_doattack", function(inst)
                UpbodyDoAttack(inst)
                inst.sg:RemoveStateTag("abouttoattack")
            end),

            EventHandler("attacked", function(inst, data)
                if data.attacker then
                    local towards = (data.attacker:GetPosition() - inst:GetPosition()):GetNormalized()
                    inst.Physics:Stop()
                    SetVel(inst, -towards * Remap(math.clamp(data.damage, 1, 68), 1, 100, 1, 8))
                end
            end),
        },
    },

    State {
        name = "attack_leap",
        tags = { "busy", "attack", "abouttoattack", },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst:EnableBladeAnim(true)

            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.AnimState:PushAnimation("atk_leap_lag", true)

            inst.sg.statemem.target_pos    = data.target_pos
            inst.sg.statemem.count         = data.count or 1
            inst.sg.statemem.arrived_dests = data.arrived_dests or {}

            inst:ForceFacePoint(data.target_pos)

            inst.sg:SetTimeout(40 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.count = inst.sg.statemem.count - 1
            table.insert(inst.sg.statemem.arrived_dests, inst.sg.statemem.target_pos)


            local target_pos = inst:SelectLeapDestination(inst.sg.statemem.arrived_dests)


            if target_pos then
                inst.sg:GoToState("attack_leap", {
                    target_pos = target_pos,
                    count = inst.sg.statemem.count,
                    arrived_dests = inst.sg.statemem.arrived_dests,
                })
            else
                inst.sg:GoToState("idle", true)
            end
        end,

        timeline = {
            TimeEvent(20 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("atk_leap")
                inst.AnimState:PushAnimation("idle_groggy_pre", false)
                inst.AnimState:PushAnimation("idle_groggy")

                local speed = (inst:GetPosition() - inst.sg.statemem.target_pos):Length() / LEAP_DURATION

                inst.Physics:SetMotorVel(speed, 0, 0)
            end),

            TimeEvent(20 * FRAMES + LEAP_DURATION, function(inst)
                inst.Physics:Stop()

                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
                -- TODO: Do attack
                -- TODO: Spawn splash rocks

                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        events =
        {

        },

        onexit = function(inst)
            inst:EnableBladeAnim(false)
        end,
    },

    State {
        name = "attack_throw",
        tags = { "busy", "attack", "abouttoattack", },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", "swap_athetos_grenade_elec", "swap_athstos_grenade_elec")

            inst.AnimState:PlayAnimation("throw_pre")

            inst.sg.statemem.target_pos   = data.target_pos
            inst.sg.statemem.count        = data.count or 1
            inst.sg.statemem.damage_taken = data.damage_taken or 0

            if inst.sg.statemem.target_pos == nil then
                local target = inst.components.combat.target
                inst.sg.statemem.target_pos = target and target:GetPosition()
            end

            if inst.sg.statemem.target_pos == nil then
                inst.sg:GoToState("idle")
                return
            end


            inst:ForceFacePoint(data.target_pos)

            inst.sg:SetTimeout(26 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.count = inst.sg.statemem.count - 1

            local target = inst.components.combat.target
            if inst.sg.statemem.count > 0 and target then
                inst.sg:GoToState("attack_throw", {
                    target_pos = target:GetPosition(),
                    count = inst.sg.statemem.count,
                    damage_taken = inst.sg.statemem.damage_taken,
                })
            else
                inst.sg:GoToState("idle", true)
            end
        end,

        timeline = {
            TimeEvent(16 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("throw")
                inst.AnimState:PushAnimation("idle_groggy_pre", false)
                inst.AnimState:PushAnimation("idle_groggy")
            end),

            TimeEvent(20 * FRAMES, function(inst)
                local proj = SpawnAt("athetos_grenade_elec", inst)
                proj.components.complexprojectile:SetHorizontalSpeed(25)
                proj.components.complexprojectile:SetGravity(-50)
                proj.components.complexprojectile:Launch(inst.sg.statemem.target_pos, inst)

                -- inst.AnimState:ClearOverrideSymbol("swap_object")

                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        events =
        {
            EventHandler("attacked", function(inst, data)
                inst.sg.statemem.damage_taken = inst.sg.statemem.damage_taken + data.damage
                if inst.sg.statemem.damage_taken >= 100 then
                    -- Too much damage cause katash drop his electric grenade
                    inst.sg:GoToState("attacked_drop_grenade")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            inst.AnimState:ClearOverrideSymbol("swap_object")
        end,
    },

    State {
        name = "attacked_drop_grenade",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("idle_groggy_pre", false)
            inst.AnimState:PushAnimation("idle_groggy", true)

            inst.SoundEmitter:PlaySound(inst.sounds.slip)

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                local proj = SpawnAt("athetos_grenade_elec", inst, nil, Vector3(0, 0.3, 0))
                proj.Physics:SetVel(0, 5, 0)
                proj:ExplodeCountdown(0.8)
            end),
        },
    },

    State {
        name = "knockback_stage1",
        tags = { "busy", "knockback" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local lastattacker = inst.components.combat.lastattacker

            if lastattacker then
                inst:ForceFacePoint(lastattacker:GetPosition())
            end

            inst.AnimState:SetMultColour(1, 0, 0, 1)

            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound(inst.sounds.knockback_stage1)

            inst.sg.statemem.speed = 16
            inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)

            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > 0 then
                inst.sg.statemem.speed = math.max(0, inst.sg.statemem.speed - FRAMES * 16)
                inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
            else
                inst.Physics:Stop()
            end
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                local p = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
                inst.AnimState:SetPercent("hit", p)
            end),

            TimeEvent(60 * FRAMES, function(inst)
                inst.sg:GoToState("knockback_stage2")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)

            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            inst.AnimState:SetMultColour(1, 1, 1, 1)
        end,
    },

    State {
        name = "knockback_stage2",
        tags = { "busy", "knockback" },

        onenter = function(inst)
            -- Katash temporary escape from telepath and become free
            -- TODO: Unlink katash and telepath
            -- TODO: Brain should do nothing if katash is temporary free
            inst:EnableMindControledParam(false)
            inst:AddTag("temporary_freedom")
            inst.components.timer:StartTimer("mind_controled_again", math.random(10, 15))
            inst.components.combat:DropTarget()

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("knockback_high")
            inst.SoundEmitter:PlaySound(inst.sounds.knockback_stage2)

            inst.sg.statemem.speed = 16
            inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
        end,


        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                inst.Physics:Stop()
            end),

            TimeEvent(33 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("wakeup")
                inst.AnimState:SetTime(10 * FRAMES)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:IsCurrentAnimation("wakeup") then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },

    State {
        name = "mind_controled_again",
        tags = { "busy", },

        onenter = function(inst)
            print(inst, "will be mind-controled by telepath again !")
            inst.Physics:Stop()

            inst.sg:SetTimeout(3)
        end,


        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,


        timeline = {
            TimeEvent(8 * FRAMES, function(inst)

            end),

            TimeEvent(33 * FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("animover", function(inst)

            end),
        },

        onexit = function(inst)
            inst:RemoveTag("temporary_freedom")
        end,
    },
}

CommonStates.AddHitState(states)

return StateGraph("SGgaleboss_katash_2", states, events, "idle")
