require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")

local events=
{
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
            inst.sg:GoToState("hit")
        end
    end),

    EventHandler("locomote", function(inst,data)
        -- if inst.sg:HasStateTag("attack") then
        --     inst.Physics:Stop()
        --     return 
        -- end
        if inst.sg:HasStateTag("busy") then
			return
		end

		local is_moving = inst.sg:HasStateTag("moving")
		local should_move = inst.components.locomotor:WantsToMoveForward()

		if is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
            inst.sg:GoToState("idle")
        end
    end),
}

local actionhandlers = {
    ActionHandler(ACTIONS.ATTACK,function(inst, action)
        -- print("Enter ACTIONS.ATTACK,forced:",action.forced)

        inst.sg.mem.localchainattack = not action.forced or nil
        if not (inst.sg:HasStateTag("attack") or inst.components.health:IsDead()) then
            return "attack"
        end

        

        -- inst.sg.mem.localchainattack = not action.forced or nil
        -- if not inst.sg:HasStateTag("attack") and not inst.components.health:IsDead() then
        --     return "attack"
        -- end
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.Physics:Stop()
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst:syncanim("idle_loop", true)
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "deploy",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local duration = 1
            GaleCommon.FadeTo(inst,duration,nil,{
                Vector4(0,0,0,1),
                Vector4(1,1,1,1),
            })

            GaleCommon.FadeTo(inst.base,duration,nil,{
                Vector4(0,0,0,1),
                Vector4(1,1,1,1),
            })

            inst:syncanim("place")
            inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
        end,
        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },


    State{
        name = "hit",
        tags = {"hit","busy"},

        onenter = function(inst) 
            inst.Physics:Stop()
            inst:syncanim("hit") 
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy","abouttoattack","canrotate"},
        onenter = function(inst,data)
            -- if inst.components.combat:InCooldown() then
            --     inst.sg:RemoveStateTag("abouttoattack")
            --     inst:ClearBufferedAction()
            --     inst.sg:GoToState("idle")
            --     return
            -- end

            data = data or {}

            inst:EquipWeapon()

            -- inst:triggerlight()
            local buffaction = inst:GetBufferedAction()
            local target = data.target or (buffaction ~= nil and buffaction.target) or nil
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()

            -- inst.Physics:Stop()
            inst.components.locomotor:StopMoving()
            inst:syncanim("atk")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/charge")

            inst.sg:SetTimeout(math.max(22*FRAMES,inst.AnimState:GetCurrentAnimationTime()))

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
            end
        end,
        timeline=
        {
            TimeEvent(22*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.attacktarget)
                -- inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shoot")
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end

            local buffaction = inst:GetBufferedAction()
            if buffaction and buffaction.action == ACTIONS.ATTACK then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{  
        name = "run",
        tags = {"moving", "running","canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                inst.AnimState:PlayAnimation("idle_loop")
            end

            -- must be small
            inst.sg:SetTimeout(0.1)
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()

            -- local bufferedaction = inst:GetBufferedAction()
            -- if bufferedaction 
            --     and bufferedaction.action == ACTIONS.ATTACK
            --     and bufferedaction.target
            --     and bufferedaction.target:IsValid()
            --     and bufferedaction.distance 
            --     and bufferedaction.distance > 0
            --     and inst:IsNear(bufferedaction.target,bufferedaction.distance)
            --     then
                
            --     inst.sg:GoToState("attack",{
            --         target = bufferedaction.target,
            --     })
            -- end
        end,
        
        timeline=
        {

        },
        
        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },
    
    State{  
        name = "run_stop",
        tags = {"idle"},
        
        onenter = function(inst) 
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            inst.sg:SetTimeout(0.1)
        end,
        
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },    
}

-- CommonStates.AddSimpleWalkStates(states,function(inst)
--     return "idle_loop"
-- end)
-- CommonStates.AddSimpleRunStates(states,function(inst)
--     -- local bufferedaction = inst:GetBufferedAction()
--     -- print("Run for",bufferedaction)
--     return "idle_loop"
-- end)

return StateGraph("SGgale_skill_mimic_eyeturret", states, events, "deploy",actionhandlers)
