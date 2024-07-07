local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    -- CommonHandlers.OnLocomote(true, false),
    -- CommonHandlers.OnDeath(),
    -- CommonHandlers.OnAttacked(),
    EventHandler("minhealth", function(inst, data)
        if not inst.sg:HasStateTag("defeated") then
            inst.sg:GoToState("defeated")
        end
    end),
}

local function SetVel(inst, vel)
    local predict_pos = inst:GetPosition() + vel
    local lx, ly, lz = inst.entity:WorldToLocalSpace(predict_pos.x, 0, predict_pos.z)
    inst.Physics:SetMotorVel(lx, 0, lz)
end

local PUNCH_LOOP_ANIM_SPEED = 2.0

local states = {
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
        tags = { "attack", "busy", "abouttoattack" },

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
                inst:ForceFacePoint(target:GetPosition())

                local cur_vel = Vector3(inst.Physics:GetVelocity())
                local towards = (target:GetPosition() - inst:GetPosition()):GetNormalized()
                local dist = (target:GetPosition() - inst:GetPosition()):Length()
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
}


CommonStates.AddIdle(states)

return StateGraph("SGgaleboss_katash_2", states, events, "idle")
