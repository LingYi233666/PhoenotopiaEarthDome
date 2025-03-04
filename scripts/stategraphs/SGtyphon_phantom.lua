require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")

local actionhandlers = {

}

local events = {
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnHop(),
}

local function DoShoutting(inst, data)
    data = data or {}
    local offset = data.offset or Vector3(0, 0, 0)
    local period = data.period or (10 / 3 * FRAMES)
    local shoutfx = data.shoutfx or "gale_scream_ring_fx"
    local shoutsound = data.shoutsound or ""
    local maxtime = data.maxtime or 3

    if data.enterfn then
        data.enterfn(inst)
    end

    for i = 0, maxtime, period do
        inst:DoTaskInTime(i, function()
            ShakeAllCameras(CAMERASHAKE.VERTICAL, period, .025, 1.25, inst, 40)
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

-- local DoRunSounds = function(inst)
--     if inst.sg.mem.footsteps > 3 then
--         PlayFootstep(inst, .6, true)
--     else
--         inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
--         PlayFootstep(inst, 1, true)
--     end
-- end

local function ProjectCanHit(proj, attacker, target)
    return attacker:CanTarget(target)
end

local idle_anims = {
    { "idle_groggy_pre", "idle_groggy" },
    { "idle_lunacy_pre", "idle_lunacy_loop" },
}

local states = {
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim_list = idle_anims[math.random(1, #idle_anims)]
            local pre_anim, loop_anim = anim_list[1], anim_list[2]

            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(loop_anim, true)
            else
                if inst.AnimState:IsCurrentAnimation(loop_anim) then
                    inst.AnimState:PushAnimation(loop_anim, true)
                else
                    inst.AnimState:PlayAnimation(pre_anim, false)
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

    State {
        name = "spawn",
        tags = { "busy", "spawn" },

        onenter = function(inst, data)
            data = data or {}

            -- inst.AnimState:SetDeltaTimeMultiplier(0.4)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.AnimState:PlayAnimation("amulet_rebirth")

            inst.components.health:SetInvincible(true)

            inst.spike_vfx.Follower:FollowSymbol(inst.GUID, "torso", 20, 0, 0)

            inst.sg.statemem.fx = inst:SpawnChild("typhon_phantom_spawn_smoke_vfx")
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "torso", 0, 0, 0)

            inst.sg.statemem.weaver = data.weaver
        end,

        onupdate = function(inst)
            local t = inst.sg:GetTimeInState()
            if t <= 30 * FRAMES then
                local c = Remap(t, 0, 30 * FRAMES, 1, 0)
                inst.AnimState:SetMultColour(c, c, c, 1)
            else
                inst.AnimState:SetMultColour(0, 0, 0, 1)
            end
        end,

        timeline = {
            -- Raise ~
            TimeEvent(0, function(inst)

            end),
            -- Deng !!!!
            TimeEvent(60 * FRAMES, function(inst)
                local fx = inst:SpawnChild("galeboss_explode_vfx_shadow_oneshoot")
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "torso", 0, 0, 0)
                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/explosion_4_wet")
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_poof")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),

            EventHandler("interrupt", function(inst)

            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.AnimState:SetMultColour(0, 0, 0, 1)
            if inst.sg.statemem.fx then
                inst.sg.statemem.fx:Remove()
            end
            inst.spike_vfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, -40, 0)
        end
    },

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst:EnableUpperBody(false)

            inst.components.locomotor:StopMoving()
            if target then
                inst:ForceFacePoint(target:GetPosition())
            end

            local anims = {
                "atk_werewilba",
                "atk_2_werewilba",
            }

            inst.AnimState:PlayAnimation(anims[math.random(1, #anims)])
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.whip)
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst:GetBufferedAction() then
                    inst:PerformBufferedAction()
                else
                    inst.components.combat:DoAttack(inst.sg.statemem.target)
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

    State {
        name = "evade",
        -- "noattack",
        tags = { "busy", "evade", },


        onenter = function(inst, data)
            inst:EnableUpperBody(false)

            inst:StopBrain()

            if data.target_pos then
                inst:ForceFacePoint(data.target_pos)
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("gale_speedrun_loop", true)

            inst:ForceFacePoint(data.target_pos:Get())
            inst.Physics:SetMotorVelOverride(25, 0, 0)


            inst.sg.statemem.missfxs = {}
            inst.sg.statemem.attack_target = data.attack_target

            local vfx = SpawnPrefab("gale_shadow_dodge_vfx")
            vfx.entity:SetParent(inst.entity)
            vfx.entity:AddFollower()
            vfx.Follower:FollowSymbol(inst.GUID, "torso", 0, -65, 0)
            table.insert(inst.sg.statemem.missfxs, vfx)

            local vfx2 = SpawnPrefab("gale_shadow_dodge_vfx")
            vfx2.entity:SetParent(inst.entity)
            vfx2.entity:AddFollower()
            vfx2.Follower:FollowSymbol(inst.GUID, "torso", 0, -125, 0)
            table.insert(inst.sg.statemem.missfxs, vfx2)

            local vfx3 = SpawnPrefab("gale_shadow_dodge_vfx")
            vfx3.entity:SetParent(inst.entity)
            vfx3.entity:AddFollower()
            vfx3.Follower:FollowSymbol(inst.GUID, "torso", 0, -180, 0)
            table.insert(inst.sg.statemem.missfxs, vfx3)

            inst.SoundEmitter:PlaySound(inst.sounds.evade)

            inst.sg:SetTimeout(data.timeout or 0.33)
            GaleCommon.ToggleOffPhysics(inst)

            inst.components.health:SetInvincible(true)
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVelOverride(25, 0, 0)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.attack_target
                and inst.sg.statemem.attack_target:IsValid()
                and inst:IsNear(inst.sg.statemem.attack_target, inst.components.combat.hitrange) then
                inst.components.combat:ResetCooldown()
                inst.sg:GoToState("attack", inst.sg.statemem.attack_target)
            else
                inst.sg:GoToState("idle", "gale_speedrun_pst")
            end
        end,

        timeline = {
            TimeEvent(11 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            inst.Physics:Stop()

            for k, v in pairs(inst.sg.statemem.missfxs) do
                if v and v:IsValid() then
                    v:Remove()
                end
            end


            GaleCommon.ToggleOnPhysics(inst)

            inst:RestartBrain()
            inst.components.health:SetInvincible(false)
        end,
    },

    -- Note the inst here is upperbody
    State {
        name = "upperbody_kinetic_blast",
        tags = { "busy", "kinetic_blast" },

        onenter = function(inst, target)
            local target_pos = target:GetPosition()
            local parent = inst.entity:GetParent()

            -- inst:ForceFacePoint(target_pos)
            inst:UpperBodyFacePoint(target_pos)

            inst.AnimState:PlayAnimation("hand_shoot")

            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")

            inst.sg.statemem.target = target
            inst.sg.statemem.target_pos = target_pos

            local carry_fx = parent:SpawnChild("gale_skill_kinetic_blast_carry_vfx")
            carry_fx.entity:AddFollower()
            carry_fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)
            carry_fx:ListenForEvent("onremove", function()
                carry_fx:Remove()
            end, inst)
            inst.sg.statemem.carry_fx = carry_fx


            parent.SoundEmitter:PlaySound(parent.sounds.launch_pre)
        end,

        onupdate = function(inst)
            -- inst:ForceFacePoint(inst.sg.statemem.target_pos)
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                inst.sg.statemem.target_pos = inst.sg.statemem.target:GetPosition()
            end
            inst:UpperBodyFacePoint(inst.sg.statemem.target_pos)
        end,

        timeline = {
            TimeEvent(15 * FRAMES, function(inst)
                local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
                inst.AnimState:SetPercent("hand_shoot", percent)
            end),

            TimeEvent(25 * FRAMES, function(inst)
                local parent = inst.entity:GetParent()
                local anim_time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("hand_shoot")
                inst.AnimState:SetTime(anim_time)

                if inst.sg.statemem.carry_fx then
                    inst.sg.statemem.carry_fx:Remove()
                    inst.sg.statemem.carry_fx = nil
                end

                local vfx = parent:SpawnChild("gale_skill_kinetic_blast_launch_vfx")
                vfx.entity:AddFollower()
                vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)
                vfx:DoTaskInTime(1, vfx.Remove)

                inst.AnimState:Resume()

                local proj = SpawnAt("gale_skill_kinetic_blast_projectile", parent)
                proj.damages = { 50, 75 }
                proj.can_trigger_fn = ProjectCanHit
                proj.can_hit_fn = ProjectCanHit
                proj.components.complexprojectile:Launch(inst.sg.statemem.target_pos, parent)

                ShakeAllCameras(CAMERASHAKE.FULL, .35, .01, 0.25, parent, 33)

                parent.SoundEmitter:PlaySound(parent.sounds.launch)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("upper_body_lookat_target", inst.sg.statemem.target)
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.carry_fx then
                inst.sg.statemem.carry_fx:Remove()
                inst.sg.statemem.carry_fx = nil
            end

            -- local parent = inst.entity:GetParent()
            -- parent:EnableUpperBody(false)

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        end,
    },

    State {
        name = "upper_body_lookat_target",
        tags = { "busy" },

        onenter = function(inst, target)
            local anim_list = idle_anims[math.random(1, #idle_anims)]
            local pre_anim, loop_anim = anim_list[1], anim_list[2]


            if inst.AnimState:IsCurrentAnimation(loop_anim) then
                inst.AnimState:PushAnimation(loop_anim, true)
            else
                inst.AnimState:PlayAnimation(pre_anim, false)
                inst.AnimState:PushAnimation(loop_anim, true)
            end

            inst.sg.statemem.target = target
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if target and target:IsValid() then
                inst:UpperBodyFacePoint(target:GetPosition())
            else
                local parent = inst.entity:GetParent()
                parent:EnableUpperBody(false)
            end
        end,
    },


    State {
        name = "kinetic_blast",
        tags = { "busy", "attack", "kinetic_blast" },

        onenter = function(inst, target_pos)
            inst:EnableUpperBody(false)

            inst.components.locomotor:Stop()

            inst:ForceFacePoint(target_pos:Get())

            inst.AnimState:PlayAnimation("hand_shoot")

            inst.sg.statemem.target_pos = target_pos
            inst.sg.statemem.carry_fx = inst:SpawnChild("gale_skill_kinetic_blast_carry_vfx")
            inst.sg.statemem.carry_fx.entity:AddFollower()
            inst.sg.statemem.carry_fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)

            -- inst.SoundEmitter:PlaySound("gale_sfx/skill/launch_pre")
            inst.SoundEmitter:PlaySound(inst.sounds.launch_pre)

            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
        end,

        timeline = {
            TimeEvent(15 * FRAMES, function(inst)
                -- inst.AnimState:Pause()
                local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
                inst.AnimState:SetPercent("hand_shoot", percent)
            end),

            TimeEvent(25 * FRAMES, function(inst)
                local anim_time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("hand_shoot")
                inst.AnimState:SetTime(anim_time)

                if inst.sg.statemem.carry_fx then
                    inst.sg.statemem.carry_fx:Remove()
                    inst.sg.statemem.carry_fx = nil
                end

                local vfx = inst:SpawnChild("gale_skill_kinetic_blast_launch_vfx")
                vfx.entity:AddFollower()
                vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0)
                vfx:DoTaskInTime(1, vfx.Remove)

                inst.AnimState:Resume()

                local proj = SpawnAt("gale_skill_kinetic_blast_projectile", inst)
                -- proj.damages = { 50, 75 }
                proj.can_trigger_fn = ProjectCanHit
                proj.can_hit_fn = ProjectCanHit
                proj.components.complexprojectile:Launch(inst.sg.statemem.target_pos, inst)

                ShakeAllCameras(CAMERASHAKE.FULL, .35, .01, 0.25, inst, 33)

                -- inst.SoundEmitter:PlaySound("gale_sfx/skill/launch2")
                inst.SoundEmitter:PlaySound(inst.sounds.launch)
                -- inst.SoundEmitter:KillSound("cast")
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },

        onexit = function(inst)
            inst.AnimState:Resume()

            if inst.sg.statemem.carry_fx then
                inst.sg.statemem.carry_fx:Remove()
                inst.sg.statemem.carry_fx = nil
            end

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        end,
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst:EnableUpperBody(false)

            inst:AddTag("attacked")
            inst.components.locomotor:StopMoving()

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


    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst:EnableUpperBody(false)

            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.AnimState:PlayAnimation("death")

            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end,



        timeline = {

        },

        onexit = function(inst)

        end,
    },
}


CommonStates.AddWalkStates(states, {
    walktimeline = {
        --groggy
        TimeEvent(1 * FRAMES, function(inst)
            PlayFootstep(inst, 1, true)
        end),
        TimeEvent(12 * FRAMES, function(inst)
            PlayFootstep(inst, 1, true)
        end),
    },
}, {
    --    startwalk = "walk_pre",
    --    -- walk = function() return GetRandomItem({"walk","walk2"}) end,
    --    walk = "walk",
    --    stopwalk = "walk_pst",
    --    startwalk = "idle_walk_pre",
    --    walk = "idle_walk",
    --    stopwalk = "idle_walk_pst",

    startwalk = "careful_walk_pre",
    walk = "careful_walk",
    stopwalk = "careful_walk_pst",


})

local function AnimSpeedUp(inst)
    inst:EnableUpperBody(false)
    inst.AnimState:SetDeltaTimeMultiplier(2)
end

local function AnimSpeedDown(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1)
end

CommonStates.AddRunStates(states, {
        runtimeline = {
            --groggy
            TimeEvent(1 * FRAMES, function(inst)
                PlayFootstep(inst, 1, true)
            end),
            TimeEvent(8 * FRAMES, function(inst)
                PlayFootstep(inst, 1, true)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                PlayFootstep(inst, 1, true)
            end),
        },
    }, {
        -- startrun = "run_werewilba_pre",
        -- run = "run_werewilba_loop",
        -- stoprun = "run_werewilba_pst",

        --   startrun = "run_pre",
        --   run = "run",
        --   stoprun = "run_pst",
        --   startrun = "idle_walk_pre",
        --   run = "idle_walk",
        --   stoprun = "idle_walk_pst",

        startrun = "careful_walk_pre",
        run = "careful_walk",
        stoprun = "careful_walk_pst",
    },
    true,
    nil, {
        startonenter = AnimSpeedUp,
        startonexit = AnimSpeedDown,
        runonenter = AnimSpeedUp,
        runonexit = AnimSpeedDown,
        endonenter = AnimSpeedUp,
        endonexit = AnimSpeedDown,
    })

local hop_timelines =
{
    hop_loop =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
        end),
    },
}

CommonStates.AddHopStates(states, false, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst" },
    hop_timelines)
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("SGtyphon_phantom", states, events, "idle", actionhandlers)
