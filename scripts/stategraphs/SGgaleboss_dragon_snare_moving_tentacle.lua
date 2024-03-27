require("stategraphs/commonstates")

-- local GaleCommon = require("util/gale_common")


local events=
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnLocomote(true,false),

    EventHandler("disappear",function(inst)
        if not inst.components.health:IsDead() then
            inst.persists = false
            inst.should_disappear = true
            if inst.sg:HasStateTag("attack_dash") then
                inst.sg.statemem.stop_time = GetTime()
            end
            -- if not inst.sg:HasStateTag("invisible") then
            --     inst.sg:GoToState("disappear")
            -- else 
            --     inst:Remove()
            -- end
        end
    end)
}

local actionhandlers = {

}

local states= {
    -- idle underground
    State{
        name = "idle",
        tags = { "idle", "canrotate","invisible" },

        onenter = function(inst,pushanim)

            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle", false)
            elseif not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle")
            end
        end,


        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.should_disappear then
                        SpawnAt("gale_underground_dirt_fx",inst).AnimState:SetTime(10 * FRAMES)
                        inst:Remove()
                    else 
                        inst.sg:GoToState("idle")
                    end
                    
                end
            end),
        },
    },

    -- c_spawn("galeboss_dragon_snare_moving_tentacle").sg:GoToState("spawn")
    State{
        name = "spawn",
        tags = { "busy","invisible" },

        onenter = function(inst,data)
            data = data or {}

            inst:Hide()
            inst.components.health:SetInvincible(true)

            inst.SoundEmitter:PlaySound("gale_sfx/battle/tentacle/dung_defender_underground_move_loop","spawn")

            inst.sg.statemem.hill = SpawnAt("gale_underground_dirt_fx",inst)
            inst.sg.statemem.dynamic_dirt = SpawnAt("gale_groundpound_fx_dynamic",inst) 
            -- inst.sg.statemem.hill.AnimState:SetPercent("move",0.5)
            -- inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.25,function()
            --     ShakeAllCameras(CAMERASHAKE.FULL, .33, .02, 0.12, inst, 15)
            -- end)

            inst.sg:SetTimeout(data.duration or GetRandomMinMax(1.5,2))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("attack",{reset_cooldown = true})        
        end,

        timeline = {
            TimeEvent(10 * FRAMES,function(inst)
                if inst.sg.statemem.hill and inst.sg.statemem.hill:IsValid() then
                    inst.sg.statemem.hill.AnimState:Pause()
                end
            end)
        },

        onexit = function(inst)
            inst:Show()
            inst.components.health:SetInvincible(false)
            inst.SoundEmitter:KillSound("spawn")
            if inst.sg.statemem.hill and inst.sg.statemem.hill:IsValid() then
                inst.sg.statemem.hill:Remove()
            end
            if inst.sg.statemem.dynamic_dirt and inst.sg.statemem.dynamic_dirt:IsValid() then
                inst.sg.statemem.dynamic_dirt:Remove()
            end
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
            end
        end,
    },

    -- after_attack atk_idle
    State{
        name = "after_attack",
        tags = { "busy", "canrotate","should_physics"},

        onenter = function(inst,data)
            data = data or {}

            inst.AnimState:PlayAnimation("atk_idle",true)

            inst.sg:SetTimeout(data.duration or 2)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("into_underground")
        end,
    },

    -- into_underground atk_pst
    State{
        name = "into_underground",
        tags = { "busy","should_physics"},

        onenter = function(inst,data)
            data = data or {}
            inst.AnimState:PlayAnimation("atk_pst")
            if data.speed then
                inst.AnimState:SetDeltaTimeMultiplier(data.speed)
            end
            inst.components.locomotor:Stop()
            inst.Physics:Stop()
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.should_disappear then
                        SpawnAt("gale_underground_dirt_fx",inst).AnimState:SetTime(10 * FRAMES)
                        inst:Remove()
                    else 
                        inst.sg:GoToState("idle")
                    end 
                end
            end),
        },
    },

    -- attack atk_pre
    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst,data)
            data = data or {}

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk_pre")
            inst.components.combat:StartAttack()

            inst.AnimState:SetDeltaTimeMultiplier(3)

            inst.sg.statemem.reset_cooldown = data.reset_cooldown
        end,

        timeline = {
            TimeEvent(6 * FRAMES,function(inst)
                local fx = SpawnAt("galeboss_dragon_snare_sand_splash_fx",inst)
                fx.AnimState:SetScale(0.66,2,1)
                fx.AnimState:SetDeltaTimeMultiplier(2)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/tentacle/enm_beholder_tentaclepop")

                inst.sg:AddStateTag("should_physics")
                inst:CheckSG()
            end),
            TimeEvent(7 * FRAMES,function(inst)
                inst.components.combat:DoAreaAttack(inst,
                                         inst.components.combat.areahitrange, 
                                         nil, 
                                         nil, 
                                         nil, 
                                        {"INLIMBO","galeboss_dragon_snare","galeboss_dragon_snare_token"})
            end)
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg.statemem.reset_cooldown then
                inst.components.combat:ResetCooldown()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    -- inst.sg:GoToState("after_attack",{duration = 1})
                    inst.sg:GoToState("into_underground")
                end
            end),
        },
    },

    -- hit
    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("into_underground",{speed = 1.6})
                end
            end),
        },
    },


    State{
        name = "attack_dash",
        tags = { "attack", "busy","attack_dash","should_physics" },

        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("atk_loop")
            -- inst.AnimState:SetDeltaTimeMultiplier(1.5)
            inst.Physics:SetMotorVel(8,0,0)

            inst.sg.statemem.stop_time = data.stop_time
            inst.sg.statemem.start_pos = data.start_pos
            inst.sg.statemem.max_dist = data.max_dist
            if data.face_pos then
                inst:ForceFacePoint(data.face_pos:Get())
            end
            if data.fx then
                local fx = SpawnAt("galeboss_dragon_snare_sand_splash_fx",inst)
                fx.AnimState:SetScale(0.66,2,1)
                fx.AnimState:SetDeltaTimeMultiplier(1.5)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/tentacle/enm_beholder_tentaclepop")
            end
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVel(8,0,0)
        end,

        timeline = {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
			TimeEvent(7*FRAMES, function(inst) 
                inst.components.combat:DoAreaAttack(inst,4,nil,nil,nil,{"INLIMBO","galeboss_dragon_snare","galeboss_dragon_snare_token"})
            end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
            TimeEvent(17*FRAMES, function(inst) 
                inst.components.combat:DoAreaAttack(inst,4,nil,nil,nil,{"INLIMBO","galeboss_dragon_snare","galeboss_dragon_snare_token"})
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if GetTime() >= inst.sg.statemem.stop_time
                        or (
                            inst.sg.statemem.start_pos 
                             and inst.sg.statemem.max_dist
                             and (inst:GetPosition()-inst.sg.statemem.start_pos):Length() > inst.sg.statemem.max_dist
                        ) then
                        inst.sg:GoToState("into_underground")
                    else 
                        inst.sg:GoToState("attack_dash",{
                            stop_time = inst.sg.statemem.stop_time,
                            start_pos = inst.sg.statemem.start_pos,
                            max_dist = inst.sg.statemem.max_dist,
                        })
                    end
                end
            end),
        },
    },

    -- attack_dash_prepare
    State{
        name = "attack_dash_prepare",
        tags = { "busy","attack_dash_prepare","dash_prepare_moving","should_physics" },

        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_loop",true)

            inst.sg.statemem.prepare_pos = data.prepare_pos
            inst.sg.statemem.prepare_time = data.prepare_time
            inst.sg.statemem.start_prepare_time = GetTime()
            inst.sg.statemem.dash_data_fn = data.dash_data_fn
        end,

        onupdate = function(inst)
            inst:ForceFacePoint(inst.sg.statemem.prepare_pos:Get())
            
            if (inst:GetPosition() - inst.sg.statemem.prepare_pos):Length() <= 1 then
                if not inst.AnimState:IsCurrentAnimation("breach_pst") then
                    inst.AnimState:PlayAnimation("breach_pst")

                    inst.sg:RemoveStateTag("dash_prepare_moving")
                    inst:CheckSG()
                end
                inst.Physics:Stop()
            else 
                inst.Physics:SetMotorVel(12,0,0)
            end

            if (GetTime() - inst.sg.statemem.start_prepare_time) >= inst.sg.statemem.prepare_time then
                inst.Physics:Stop()
                if not inst.should_disappear and inst.components.combat.target then
                    inst.sg:GoToState("attack_dash",inst.sg.statemem.dash_data_fn(inst))
                else 
                    inst.sg:GoToState("attack")
                end
            end
        end,

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },
}

-- CommonStates.AddWalkStates(states,nil,{
--     startrun = "breach_pre",
--     run = "breach_loop",
--     stoprun = "breach_pst",
-- })

CommonStates.AddRunStates(states,nil,{
    startrun = "breach_pre",
    run = "breach_loop",
    stoprun = "breach_pst",
})

CommonStates.AddDeathState(states)


return StateGraph("SGgaleboss_dragon_snare_moving_tentacle", states, events, "idle",actionhandlers)
