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

        if not inst.entity:CanPredictMovement() then
            if not inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle")
            end
        elseif is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run_start")
        end
    end),
}

local TIMEOUT = 2

local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.entity:SetIsPredictingMovement(false)

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            if pushanim == "cancel" then
                return
            elseif pushanim == "noanim" then
                inst.sg:SetTimeout(TIMEOUT)
                return
            end

            if pushanim then
                inst.AnimState:PushAnimation(inst.idle_anim, true)
            else
                inst.AnimState:PlayAnimation(inst.idle_anim, true)
            end
        end,

        ontimeout = function(inst)
            if inst.bufferedaction ~= nil and inst.bufferedaction.ispreviewing then
                inst:ClearBufferedAction()
            end
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(inst.run_anim)
            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation(inst.run_anim) then
                inst.AnimState:PlayAnimation(inst.run_anim, true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            
        },

        events =
        {
            
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.run_anim)
        end,

        timeline =
        {

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

}



return StateGraph("SGgale_skill_mimic_target_client", states, events, "idle")