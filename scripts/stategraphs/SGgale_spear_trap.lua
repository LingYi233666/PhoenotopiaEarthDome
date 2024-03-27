local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")



local events = {
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
}


local states = {
    State{
        name = "idle",
        tags = {"idle"},

        onenter = function(inst)
            local anim = inst.triggered and "idle_extend" or "idle_retract"
            inst.AnimState:PlayAnimation(anim,true)

            if not inst.triggered then
                inst.sg:AddStateTag("invisible")
            end

            inst.Physics:SetActive(inst.triggered)
            inst.components.health:SetInvincible(not inst.triggered)
        end,

        onexit = function(inst)
            inst.Physics:SetActive(false)
            inst.components.health:SetInvincible(false)
        end,
    },

    State{
        name = "extending",
        tags = {"busy"},

        onenter = function(inst)
            inst.triggered = true 
            
            
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/turtillus/attack_pre")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/turtillus/attack1a")
            end),
            TimeEvent(3*FRAMES, function(inst) 
                
                inst.AnimState:PlayAnimation("extending")
                inst.sg.statemem.can_go = true 
            end),

            
            TimeEvent(6*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/turtillus/attack1b")
                
            end),

            TimeEvent(7*FRAMES, function(inst) 
                inst.Physics:SetActive(true)
                
            end),

            
            TimeEvent(8*FRAMES, function(inst) 
                inst.components.combat:DoAreaAttack(inst,
                        inst.components.combat.areahitrange, 
						nil, 
                        nil, 
                        "electric", 
                        { "INLIMBO"})
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.can_go then
                    inst.sg:GoToState("idle")
                end
                
            end),
        },
    },

    State{
        name = "retracting",
        tags = {"busy"},

        onenter = function(inst)
            inst.triggered = false 
            inst.AnimState:PlayAnimation("retracting")
            inst.Physics:SetActive(false)
        end,

        timeline = {
            -- inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
            TimeEvent(3*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/turtillus/shell_impact")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tag = {"busy","dead"},

        onenter = function(inst)
            inst.sg.statemem.burnt = inst.components.burnable and inst.components.burnable:IsBurning()
            if inst.sg.statemem.burnt then
                inst.AnimState:SetMultColour(0,0,0,1)
            else 
                
            end
            inst.AnimState:PlayAnimation("breaking")
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal",nil,0.4)
            inst.Physics:SetActive(false)
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) 
                
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.burnt then
                    SpawnAt("gale_spear_trap_burnt",inst)
                else 
                    SpawnAt("gale_spear_trap_broken",inst)
                end

                inst:Remove()
                
            end),
        },
    }
}


CommonStates.AddHitState(states,{

})

return StateGraph("SGgale_spear_trap", states, events, "idle")