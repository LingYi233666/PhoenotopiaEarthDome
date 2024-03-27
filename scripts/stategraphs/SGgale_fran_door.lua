require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")

local events =
{
    EventHandler("gale_portal_activite", function(inst, data)
        if data.sound then
            inst.SoundEmitter:PlaySound("gale_sfx/fran_door/teleport")
        end

        if inst.sg:HasStateTag("activite") then
            inst.sg.statemem.time_remain = math.max(data.time_remain, inst.sg.statemem.time_remain)
        else
            inst.sg:GoToState("activite", {
                time_remain = data.time_remain
            })
        end
    end)
}

local actionhandlers = {

}

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim = "idle"

            --pushanim could be bool or string?
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
                    if inst:HasTag("athetos_type")
                        and (inst.last_glitch_time == nil or GetTime() - inst.last_glitch_time >= 5) then
                        if math.random() < 0.33 then
                            inst.last_glitch_time = GetTime()
                            inst.sg:GoToState("idle_glitch")
                        else
                            inst.last_glitch_time = GetTime() - 2
                            inst.sg:GoToState("idle")
                        end
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State {
        name = "idle_glitch",
        tags = { "idle", "glitch" },

        onenter = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomMinMax(1, 1.25))
            inst.AnimState:PlayAnimation("idle_glitch")
            -- inst.AnimState:SetLightOverride(1)
            inst:AddTag("NOCLICK")

            if inst.SoundEmitter:PlayingSound("shocked") then
                inst.SoundEmitter:KillSound("shocked")
            end

            if inst.elec_fx and inst.elec_fx:IsValid() then
                inst.elec_fx:Remove()
            end
            inst.elec_fx = nil
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            -- inst.AnimState:SetLightOverride(0)
            inst:RemoveTag("NOCLICK")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "hit_glitch",
        tags = { "hit", "glitch" },

        onenter = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomMinMax(1, 1.25))
            inst.AnimState:PlayAnimation("idle_glitch")
            inst.AnimState:SetTime(GetRandomMinMax(0.3, 1.5))
            inst.AnimState:Pause()
            inst.sg:SetTimeout(GetRandomMinMax(1, 2))
            inst:AddTag("NOCLICK")

            if inst.SoundEmitter:PlayingSound("shocked") then
                inst.SoundEmitter:KillSound("shocked")
            end

            if inst.elec_fx and inst.elec_fx:IsValid() then
                inst.elec_fx:Remove()
            end
            inst.elec_fx = nil
        end,

        ontimeout = function(inst)
            inst.AnimState:Resume()
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst:RemoveTag("NOCLICK")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "activite",
        tags = { "busy", "activite" },

        onenter = function(inst, data)
            -- inst.Light:Enable(true)
            inst:EnableLight(true)

            inst.AnimState:HideSymbol("face")

            inst.AnimState:SetDeltaTimeMultiplier(1.15)

            inst.AnimState:PlayAnimation("activite", true)


            inst.sg.statemem.time_remain = data.time_remain
        end,

        onupdate = function(inst)
            if inst.sg.statemem.time_remain == nil then
                inst.sg:GoToState("idle")
            else
                inst.sg.statemem.time_remain = inst.sg.statemem.time_remain - FRAMES

                if inst.sg.statemem.time_remain <= 0 then
                    inst.sg:GoToState("idle")
                end
            end
        end,

        onexit = function(inst)
            -- inst.Light:Enable(false)
            inst.AnimState:ShowSymbol("face")
            inst:EnableLight(false)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    },
}


return StateGraph("SGgale_fran_door", states, events, "idle", actionhandlers)
