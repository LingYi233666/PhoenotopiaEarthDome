require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")

local events=
{
    EventHandler("gale_portal_activite",function(inst,data)
        
    end)
}


local states=
{
    State{
        name = "opening",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local anim = inst.style.."_door_opening_"..inst.direction
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline = {

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
    State{
        name = "closing",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local anim = inst.style.."_door_closing_"..inst.direction
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline = {

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
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            local anim = inst.components.teleporter:IsActive() and "open" or "close"

            anim = inst.style.."_door_"..anim.."_"..inst.direction

            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(anim)
            else
                inst.AnimState:PlayAnimation(anim)
            end
        end,

        timeline = {

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

return StateGraph("SGgale_house_door", states, events, "idle")
