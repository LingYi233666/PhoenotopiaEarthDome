require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")


local events=
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),

    EventHandler("disappear",function(inst)
        if not inst.components.health:IsDead() then
            inst:StopBrain()
            inst.sg:GoToState("despawn")
        end
    end)
}

local actionhandlers = {
    ActionHandler(ACTIONS.HARVEST, "eat_enter"),
    ActionHandler(ACTIONS.PICK, "eat_enter"),
    ActionHandler(ACTIONS.PICKUP, "eat_enter"),
    ActionHandler(ACTIONS.MURDER, "action"),
    ActionHandler(ACTIONS.GIVE, "action"),
    ActionHandler(ACTIONS.DROP, "action"),
}

local states= {
    State{
        name = "alert",
        tags = {"idle","canrotate"},

        onenter = function(inst,force)
            if force or not inst.AnimState:IsCurrentAnimation("lookat") then
                inst.AnimState:PlayAnimation("lookat")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.AnimState:AnimDone() then
                    if inst.components.combat.target then
                        inst.sg:GoToState("alert",true) 
                    else 
                        inst.sg:GoToState("idle") 
                    end
                end
                
            end),
        },

    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()

            inst.sg.statemem.target = target
        end,

        timeline = {
            TimeEvent(14*FRAMES, function(inst) 
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target and
                    distsq(inst.components.combat.target:GetPosition(),inst:GetPosition()) <=
                    inst.components.combat:CalcAttackRangeSq(inst.components.combat.target) then

                    inst.sg:GoToState("attack")
                else
                    inst.sg:GoToState("alert")
                end
            end),
        },
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("spawn")
            inst.AnimState:PushAnimation("idle", true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_emerge")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

    },

    State{
        name = "despawn",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("despawn")
            RemovePhysicsColliders(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_retract")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end)
        },
    },

    State{
        name = "eat_enter",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst)
                local target = inst:GetBufferedAction().target
                if target then
                    if not target:HasTag("prey") and target.components.combat then
                        target:PushEvent("attacked", { attacker = inst, damage = 0 })
                    end
                    target:PushEvent("ontrapped")
                end
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
            end ), --take food
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "action",
        tags = {"busy", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
            end ), 
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "dropitem",
        tags = {"busy", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                local item = inst.components.inventory:GetItemInSlot(1)
                local item_dropped = inst.components.inventory:DropItem(
                    item,
                    true,
                    true,
                    inst:GetPosition()
                )
                if item_dropped then
                    item_dropped.Physics:Stop()

                    local speed = GetRandomMinMax(6,9)
                    local angle = math.random() * 2 * PI

                    local vx = speed * math.cos(angle)
                    local vy = GetRandomMinMax(6,7)
                    local vz = -speed * math.sin(angle)

                    item_dropped.Physics:SetVel(vx,vy,vz)
                end
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
                -- "dontstarve/impacts/impact_"
            end ), 
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },
}

CommonStates.AddIdle(states,nil,"idle")
CommonStates.AddHitState(states)
CommonStates.AddDeathState(states,{
    TimeEvent(0,function (inst)
        RemovePhysicsColliders(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_retract")
    end)
},"despawn")


return StateGraph("SGgaleboss_dragon_snare_babyplant", states, events, "idle",actionhandlers)
