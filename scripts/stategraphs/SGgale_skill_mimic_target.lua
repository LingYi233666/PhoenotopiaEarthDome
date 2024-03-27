local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local events =
{
    EventHandler("locomote", function(inst)
        if (inst.sg:HasStateTag("busy") or inst:HasTag("busy")) and (inst:HasTag("jumping") and inst.sg:HasStateTag("jumping")) then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run_start")
        end
    end),
}

local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim = inst.idle_anim or "idle"

            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end
        end,


        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

-- CommonStates.AddIdle(states,nil,function(inst)
--     return inst.idle_anim or "idle"
-- end)
CommonStates.AddSimpleWalkStates(states,function(inst)
    return inst.walk_anim or "idle"
end)
CommonStates.AddSimpleRunStates(states,function(inst)
    return inst.run_anim or "idle"
end)

return StateGraph("SGgale_skill_mimic_target", states, events, "idle")