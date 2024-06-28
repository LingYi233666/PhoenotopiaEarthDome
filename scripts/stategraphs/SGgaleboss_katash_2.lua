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

            inst.sg.statemem.next_index = (index == 2) and 1 or 2
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                -- TODO: Play some fancy attack sfx here
                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/typhon_phantom/whip")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                local parent = inst.entity:GetParent()
                if parent then
                    -- TODO: parent do attack here
                    parent:PushEvent("upbody_doattack")
                end
            end),
        },

        onexit = function(inst)

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
        tags = {},

        onenter = function(inst, index)
            inst.sg.statemem.up_body = inst:EnableUpBody(true)
            inst.sg.statemem.up_body.sg:GoToState("upbody_punch_loop")

            inst.AnimState:PlayAnimation("run", true)
        end,

        timeline = {

        },

        onexit = function(inst)
            inst:EnableUpBody(false)
        end,

        events =
        {
            EventHandler("upbody_doattack", function(inst)
                -- local tar_deg = GaleCommon.GetFaceAngle(inst, attacker)
            end),
        },
    },
}


CommonStates.AddIdle(states)

return StateGraph("SGgaleboss_katash_2", states, events, "idle")
