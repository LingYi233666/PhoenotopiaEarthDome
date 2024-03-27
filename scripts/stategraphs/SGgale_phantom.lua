require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
}

local function DoShoutting(inst,data)
    data = data or {}
    local offset = data.offset or Vector3(0,0,0)
    local period = data.period or (10/3 * FRAMES)
    local shoutfx = data.shoutfx or "gale_scream_ring_fx"
    local shoutsound = data.shoutsound or ""
    local maxtime = data.maxtime or 3

    if data.enterfn then
        data.enterfn(inst)
    end

    for i=0,maxtime,period do 
        inst:DoTaskInTime(i,function()
            ShakeAllCameras(CAMERASHAKE.VERTICAL,period, .025, 1.25, inst, 40)
            inst:SpawnChild(shoutfx).Transform:SetPosition(offset:Get())
            if i == period then 
                inst.SoundEmitter:PlaySound(shoutsound)
            end
            if data.updatefn then
                data.updatefn(inst)
            end 
        end)
    end

    if data.exitfn then
        data.exitfn(inst)
    end
end

local idle_anims = {
    {"idle_groggy_pre","idle_groggy"},
    {"idle_lunacy_pre","idle_lunacy_loop"},
}

local states = {
    State{
        name = "reborn",
        tags = { "busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("death_reverse")

            local emrge_vfx = inst:SpawnChild("gale_shadow_emerge_vfx")
            emrge_vfx._emit_point:set(false)
            emrge_vfx._emit_final_smoke:set(true)

            inst.SoundEmitter:PlaySound("gale_sfx/skill/misc_rumble_impact")

            inst:AddTag("reborning")
        end,


        timeline =
        {
            
        },

        events =
        {
            EventHandler("animover", function(inst)
                -- inst.sg:GoToState("roar")
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("reborning")
        end,
    },

    State{
        name = "roar",
        tags = { "busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emote_angry")

            -- inst.shake_task = inst:DoPeriodicTask()
            inst:AddTag("reborning")
        end,


        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("gale_sfx/battle/phantom/hollow_knight_scream_v1","roar")

                DoShoutting(inst,{
                    maxtime = 2,
                    period = 5 * FRAMES,
                    offset = Vector3(0,0.5,0),
                    shoutfx = "gale_scream_ring_black_fx",
                })
            end),   

            TimeEvent(10*FRAMES, function(inst) 
                inst.AnimState:Pause()
            end),   

            TimeEvent(80*FRAMES, function(inst) 
                inst.AnimState:Resume()
            end),   
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.AnimState:Resume()
            inst.SoundEmitter:KillSound("roar")
            inst:RemoveTag("reborning")
        end,
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim_list = idle_anims[math.random(1,#idle_anims)]
            local pre_anim,loop_anim = anim_list[1],anim_list[2]

            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(loop_anim, true)
            else
                if inst.AnimState:IsCurrentAnimation(loop_anim) then
                    inst.AnimState:PushAnimation(loop_anim, true)
                else 
                    inst.AnimState:PlayAnimation(pre_anim,false)
                    inst.AnimState:PushAnimation(loop_anim, true)
                end
                
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

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            target = target or inst.components.combat.target 

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anims = {
                "atk_werewilba",
                "atk_2_werewilba",
            }

            inst.AnimState:PlayAnimation(anims[math.random(1,#anims)])
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target
        end,

        timeline = {
            TimeEvent(9 * FRAMES, function(inst)
                -- inst:PerformBufferedAction()
                -- if inst.components.combat.target then 
				-- 	inst.components.combat:DoAreaAttack(inst.components.combat.target,1.2, 
				-- 		inst.components.combat:GetWeapon(), nil, nil, { "INLIMBO" ,"companion"})
				-- end 
                if inst.sg.statemem.target then 
                    inst.components.combat:DoAttack(inst.sg.statemem.target)
					inst.components.combat:DoAreaAttack(inst.sg.statemem.target,1.2, 
						nil, function(target,inst)
                            local leader = inst.components.follower:GetLeader()
                            return leader and target ~= leader and not (leader.components.combat and leader.components.combat:IsAlly(target))
                        end, nil, { "INLIMBO"})
				end 
            end),
        },

        onexit = function(inst)

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

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst:AddTag("attacked")
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("hit")

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

        onexit = function(inst)
            inst:RemoveTag("attacked")
        end,
    },


    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst:AddTag("death")

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("hit")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.AnimState:ClearOverrideSymbol("headbase")

            -- local explofx = inst:SpawnChild("gale_shadow_emerge_vfx")
            -- explofx._emit_point:set(false)
            -- explofx._emit_final_smoke:set(true)

            local explofx = inst:SpawnChild("gale_dark_explode_vfx")


            inst.sg.statemem.speed = -15
            inst.sg.statemem.last_pos = inst:GetPosition()
            inst.sg.statemem.last_pos_splash = inst:GetPosition()

            inst.SoundEmitter:PlaySound("gale_sfx/battle/phantom/boss_explode_clean")

            inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)

            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
        end,

        onupdate = function(inst)
            if not inst.sg.statemem.should_stop then
                inst.sg.statemem.speed = inst.sg.statemem.speed + FRAMES * 33

                if inst.sg.statemem.speed >= 0 then
                    inst.sg.statemem.speed = 0
                end
                inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
            else 
                inst.Physics:Stop() 
            end

            if (inst:GetPosition() - inst.sg.statemem.last_pos):Length() >= 0.33 then
                for i = 1,1 do
                    local rad = math.random() * PI * 2
                    local offset = Vector3(math.cos(rad),0,math.sin(rad)) * GetRandomMinMax(0,0.66)
                    local fx = SpawnAt("gale_skill_phantom_create_puddle",inst:GetPosition() + offset)

                    fx:DoTaskInTime(GetRandomMinMax(4,6),function()
                        fx:ResumeAnim()
                    end)
                end
                inst.sg.statemem.last_pos = inst:GetPosition()
            end

            if (inst:GetPosition() - inst.sg.statemem.last_pos_splash):Length() >= 0.33 then
                for i = 1,4 do
                    local rad = math.random() * PI * 2
                    local offset = Vector3(math.cos(rad),0,math.sin(rad)) * GetRandomMinMax(0,0.66)
                    SpawnAt("gale_skill_phantom_create_splash",inst:GetPosition() + offset)
                end
                
                inst.sg.statemem.last_pos_splash = inst:GetPosition()
            end
        end,

        timeline = {
            TimeEvent(5 * FRAMES, function(inst) 
                inst.AnimState:Pause()
            end),
            TimeEvent(25 * FRAMES, function(inst) 
                inst.AnimState:Resume()
                inst.AnimState:SetPercent("death",0.26)

                inst.sg.statemem.should_stop = true 
                inst.Physics:Stop() 

                local explofx = inst:SpawnChild("gale_shadow_emerge_vfx")
                explofx._emit_point:set(false)
                explofx._emit_final_smoke:set(true)

                
                inst.sg.statemem.outer_fx = SpawnPrefab("gale_shadow_emerge_vfx")
                inst.sg.statemem.outer_fx.entity:AddFollower()
                inst.sg.statemem.outer_fx.Follower:FollowSymbol(inst.GUID,"headbase",0,0,0)

                inst.sg.statemem.outer_fx._emit_point:set(false)
                inst.sg.statemem.outer_fx._emit_final_smoke:set(false)
                inst.sg.statemem.outer_fx._emit_outer:set(true)

                
                inst.SoundEmitter:PlaySound("gale_sfx/battle/phantom/explosion_4_wet")
                inst.SoundEmitter:PlaySound("gale_sfx/skill/misc_rumble_loop","outer")

                inst:StartThread(function()
                    while true do
                        local r,g,b,a = inst.AnimState:GetMultColour()

                        r = r + 1/6 * FRAMES
                        g = g + 1/6 * FRAMES
                        b = b + 1/6 * FRAMES


                        inst.AnimState:SetMultColour(r,g,b,a)

                        if r >= 1 then
                            break
                        end
                        Sleep(0)
                    end
                end)

                inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.5,function()
                    ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, 0.5, inst, 40)
                end)

                ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
            end),

            TimeEvent(90 * FRAMES, function(inst) 
                inst.SoundEmitter:KillSound("outer")
                inst.sg.statemem.outer_fx._emit_outer:set(false)
            end),

            TimeEvent(128 * FRAMES, function(inst) 
                SpawnAt("collapse_small",inst)
                inst:Hide()
            end),

            TimeEvent(200 * FRAMES, function(inst) 
                inst:Remove()
            end),
        },

        onexit = function(inst)
            inst:Remove()
        end,
    },
}


CommonStates.AddWalkStates(states,{

},{
    startwalk = "idle_walk_pre",
    walk = "idle_walk",
    stopwalk = "idle_walk_pst",
})

local function SpeedUp(inst)
    inst.AnimState:SetDeltaTimeMultiplier(2.5)
end

local function SpeedDown(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1)
end

CommonStates.AddRunStates(states,{

},{
    -- startrun = "run_werewilba_pre",
    -- run = "run_werewilba_loop",
    -- stoprun = "run_werewilba_pst",

    startrun = "idle_walk_pre",
    run = "idle_walk",
    stoprun = "idle_walk_pst",
},
true,
nil,{
    startonenter = SpeedUp,
    startonexit = SpeedDown,
    runonenter = SpeedUp,
    runonexit = SpeedDown,
    endonenter = SpeedUp,
    endonexit = SpeedDown,
})

CommonStates.AddHitState(states)


return StateGraph("SGgale_phantom", states, events, "idle", actionhandlers)