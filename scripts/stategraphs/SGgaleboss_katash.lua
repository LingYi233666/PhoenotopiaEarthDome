local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),

    EventHandler("minhealth", function(inst, data)
        if not inst.sg:HasStateTag("defeated") then
            inst.sg:GoToState("defeated")
        end
    end),

    EventHandler("attacked", function(inst, data)
        if IsEntityDead(inst, true) then
            return
        end
        if not inst.sg:HasStateTag("busy")
            or inst.sg:HasStateTag("caninterrupt")
            or inst.sg:HasStateTag("frozen") then
            inst.sg:GoToState("hit")
        elseif inst.sg:HasStateTag("stunned") then
            inst:PushEvent("stunned_hit")
        end
    end),
}

local function SetVel(inst, vel)
    local predict_pos = inst:GetPosition() + vel
    local lx, ly, lz = inst.entity:WorldToLocalSpace(predict_pos.x, 0, predict_pos.z)
    inst.Physics:SetMotorVel(lx, 0, lz)
end


-- c_spawn("galeboss_katash").sg:GoToState("intro_teleportin",{target=ThePlayer})
local states = {
    State {
        name = "intro_teleportin",
        tags = { "busy", },

        onenter = function(inst, data)
            inst:SetMusicLevel(1)
            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(true)

            -- inst.AnimState:PlayAnimation("pickup")
            -- inst.AnimState:PushAnimation("pickup_pst", false)
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.AnimState:PushAnimation("idle_loop", true)

            inst.sg.statemem.target = data.target
            inst.sg.statemem.from_pos = data.from_pos
            inst.sg.statemem.to_pos = data.to_pos or inst:GetPosition()

            if inst.sg.statemem.from_pos == nil then
                local offset = FindWalkableOffset(
                    inst.sg.statemem.to_pos,
                    math.random() * TWOPI,
                    20,
                    15,
                    nil,
                    false,
                    nil,
                    true,
                    true
                )

                if offset then
                    inst.sg.statemem.from_pos = inst.sg.statemem.to_pos + offset
                end
            end

            assert(inst.sg.statemem.from_pos ~= nil, "inst.sg.statemem.from_pos is nil !!!")

            local speed_base = (inst.sg.statemem.to_pos - inst.sg.statemem.from_pos):GetNormalized()
            inst.Transform:SetPosition(inst.sg.statemem.from_pos:Get())

            local dp = inst.sg.statemem.from_pos - inst.sg.statemem.to_pos
            local angle = math.atan2(dp.z, -dp.x)
            inst.Transform:SetRotation(angle * RADIANS)

            inst.sg.statemem.task = inst:CreateTeleportTask(
                inst.sg.statemem.to_pos,
                0.1, function(inst, percent)
                    if inst.sg.statemem.last_shadow_pt == nil
                        or (inst:GetPosition() - inst.sg.statemem.last_shadow_pt):Length() >= 1.5 then
                        local anim_data = GaleCommon.GetAnim(inst)
                        local shadow = SpawnAt("galeboss_katash_shadow", inst)
                        shadow.Transform:SetRotation(inst.Transform:GetRotation())
                        shadow.AnimState:SetPercent(anim_data.anim, anim_data.percent)
                        shadow.Physics:SetVel((speed_base * 12 * (1 - percent)):Get())
                        GaleCommon.FadeTo(shadow, FRAMES * 7, nil,
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 0.66), Vector4(0, 0, 0, 0) },
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 1), Vector4(0, 0, 0, 0) },
                                          shadow.Remove)

                        inst.sg.statemem.last_shadow_pt = inst:GetPosition()
                    end

                    if percent >= 1 then
                        inst.AnimState:SetMultColour(1, 1, 1, 1)
                        inst.AnimState:SetAddColour(0, 0, 0, 0)
                    end
                end
            )

            inst.SoundEmitter:PlaySound(inst.sounds.teleport)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                inst.sg:GoToState("intro_talkto", {
                    target = inst.sg.statemem.target
                })
            else
                inst:SetMusicLevel(2)
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "intro_talkto",
        tags = { "busy", "talking", },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst:ForceFacePoint(data.target:GetPosition())

            inst.sg.statemem.target = data.target
            if data.target:HasTag("gale") then
                inst.sg.statemem.meet_gale = true
                inst.sg.statemem.lines = STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.INTRO_GALE
            else
                inst.sg.statemem.meet_gale = false
                inst.sg.statemem.lines = STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.INTRO_OTHER
            end

            inst.components.npc_talker:Say(
                inst.sg.statemem.lines,
                true
            )
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.target:GetPosition())
            end
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()

                    if inst.sg.statemem.meet_gale then
                        inst.AnimState:PlayAnimation("emoteXL_angry")
                        inst.AnimState:PushAnimation("idle_loop", true)
                        inst.SoundEmitter:PlaySound(inst.sounds.talk)
                    else
                        inst.AnimState:PlayAnimation("emote_laugh")
                        inst.AnimState:PushAnimation("idle_loop", true)
                        inst.SoundEmitter:PlaySound(inst.sounds.laugh)
                    end
                end
            end),

            TimeEvent(2.5, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()

                    if inst.sg.statemem.meet_gale then
                        inst.AnimState:PlayAnimation("emote_fistshake")
                        -- inst.AnimState:PushAnimation("idle_loop",true)
                        inst.SoundEmitter:PlaySound(inst.sounds.talk)

                        inst.sg.statemem.should_exit = true
                    else
                        inst.AnimState:PlayAnimation("dial_loop")
                        inst.AnimState:PlayAnimation("idle_loop", true)
                        inst.SoundEmitter:PlaySound(inst.sounds.talk)
                    end
                end
            end),

            TimeEvent(5, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()

                    if inst.sg.statemem.meet_gale then
                        inst.SoundEmitter:PlaySound(inst.sounds.talk)
                        inst.sg:GoToState("idle")
                    else
                        inst.AnimState:PlayAnimation("emote_fistshake")
                        inst.SoundEmitter:PlaySound(inst.sounds.talk)

                        inst.sg.statemem.should_exit = true
                    end
                end
            end),


        },

        events =
        {
            -- EventHandler("donetalking", function(inst)
            --     if not inst.sg.statemem.should_exit
            --         and  not inst.AnimState:IsCurrentAnimation("idle_loop") then
            --         inst.AnimState:PlayAnimation("idle_loop",true)
            --     end
            -- end),

            EventHandler("attacked", function(inst, data)
                inst.sg.statemem.target = data.target
                inst:DoTaskInTime(0.33, function()
                    inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.INTRO_INTERRUPT))
                    inst.SoundEmitter:PlaySound(inst.sounds.talk)
                end)
                inst.sg:GoToState("hit")
            end),

            EventHandler("animover", function(inst)
                if inst.sg.statemem.should_exit then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:SetMusicLevel(2)
            inst.components.npc_talker:resetqueue()
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                inst.components.combat:SetTarget(inst.sg.statemem.target)
            end
        end,
    },

    State {
        name = "defeated",
        tags = { "busy", "defeated" },

        onenter = function(inst)
            -- Shard_SyncBossDefeated("galeboss_katash")
            TheWorld:PushEvent("forest_katash_defeated")

            inst.persists = false

            inst:StopBrain()
            inst:SetMusicLevel(3)
            inst.components.locomotor:Stop()

            local lastattacker = inst.components.combat.lastattacker

            if lastattacker then
                inst:ForceFacePoint(lastattacker:GetPosition())
            end

            inst.AnimState:PlayAnimation("knockback_high")
            -- inst.AnimState:PushAnimation("buck_pst", false)

            inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.SoundEmitter:PlaySound(inst.sounds.defeat)

            if inst.components.lootdropper then
                inst.components.lootdropper:DropLoot()
            end

            -- inst:SpawnChild("gale_normal_explode_vfx")
            inst:SpawnChild("gale_fire_explode_vfx")

            inst.Physics:SetMotorVel(-16, 0, 0)

            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                inst.Physics:Stop()
            end),

            TimeEvent(33 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("wakeup")
                inst.AnimState:SetTime(10 * FRAMES)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:IsCurrentAnimation("wakeup") then
                    inst.sg:GoToState("talk_before_escape")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },

    State {
        name = "talk_before_escape",
        tags = { "busy", "talking", "defeated" },

        onenter = function(inst)
            local lastattacker = inst.components.combat.lastattacker

            if lastattacker then
                inst:ForceFacePoint(lastattacker:GetPosition())
            end

            inst.AnimState:PlayAnimation("idle_groggy01_pre")
            inst.AnimState:PushAnimation("idle_groggy01_loop", true)

            inst.components.npc_talker:Say(
                STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.ESCAPE,
                true
            )

            inst.sg.statemem.face_attacker = true
            inst.sg.statemem.lastattacker = lastattacker

            inst.sg:SetTimeout(10)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.face_attacker and inst.sg.statemem.lastattacker and inst.sg.statemem.lastattacker:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.lastattacker:GetPosition())
            end
        end,

        ontimeout = function(inst)
            inst.sg.statemem.face_attacker = false
            inst.sg:GoToState("escape")
        end,

        timeline = {
            TimeEvent(2.5, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()
                    inst.SoundEmitter:PlaySound(inst.sounds.talk)
                end
            end),

            TimeEvent(5, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()
                    inst.SoundEmitter:PlaySound(inst.sounds.talk)
                end
            end),

            TimeEvent(7.5, function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()
                    inst.SoundEmitter:PlaySound(inst.sounds.talk)
                end
            end),
        },

        onexit = function(inst)
            inst.components.npc_talker:resetqueue()
        end,
    },

    State {
        name = "escape",
        tags = { "busy", "defeated" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.AnimState:PushAnimation("superjump_lag", false)
        end,

        timeline = {
            TimeEvent(20 * FRAMES, function(inst)
                inst.sg.statemem.should_hide = true

                inst.AnimState:PlayAnimation("superjump")
                GaleCommon.ToggleOffPhysics(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.superjump)
                inst.SoundEmitter:PlaySound(inst.sounds.laugh_echo)

                inst.DynamicShadow:Enable(false)
            end),

            TimeEvent(66 * FRAMES, function(inst)
                inst:SetMusicLevel(4)
            end),

            TimeEvent(120 * FRAMES, function(inst)
                inst:Remove()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.sg.statemem.should_hide then
                    inst:Hide()
                end
            end),
        },

        onexit = function(inst)
            inst:Remove()
        end,

    },


    State {
        name = "attack_bigball",
        tags = { "busy", "attack", },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hand_shoot")

            inst.sg.statemem.count = data.count or 4
            inst.sg.statemem.lock = (data.lock == nil) and true or data.lock
            inst.sg.statemem.target = data.target

            -- if inst.sg.statemem.target == nil then
            --     inst.sg:GoToState("idle")
            -- end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.lock and inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                inst:ForceFacePoint(inst.sg.statemem.target:GetPosition():Get())
            end
        end,

        timeline = {
            TimeEvent(15 * FRAMES, function(inst)
                -- Anim pause
                local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
                inst.AnimState:SetPercent("hand_shoot", percent)
            end),
            TimeEvent(20 * FRAMES, function(inst)
                inst.sg.statemem.lock = false
            end),
            TimeEvent(25 * FRAMES, function(inst)
                -- Anim resume
                local anim_time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("hand_shoot")
                inst.AnimState:SetTime(anim_time)
            end),
            TimeEvent(27 * FRAMES, function(inst)
                local pos = (inst:GetPosition() + GaleCommon.GetFaceVector(inst))

                inst:LaunchBigProjectiles(pos)

                inst.sg:AddStateTag("canchangetodash")
            end),
        },

        onexit = function(inst)

        end,

        events =
        {
            EventHandler("attacked", function(inst, data)
                if data.damage and data.damage >= 100 and not data.redirected then
                    inst.sg.statemem.count = 0
                    -- inst.components.timer:StopTimer("dash_attack")
                    inst.sg:GoToState("hit")
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local target = inst.sg.statemem.target
                    inst.sg.statemem.count = inst.sg.statemem.count - 1
                    if target and target:IsValid()
                        and not IsEntityDeadOrGhost(target, true)
                        and inst.sg.statemem.count > 0 then
                        inst.sg:GoToState("attack_bigball", {
                            count = inst.sg.statemem.count,
                            target = target,
                            lock = true,
                        })
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State {
        name = "attack_spin",
        tags = { "busy", "attack" },

        onenter = function(inst, data)
            inst:StopBrain()
            -- inst.Physics:Stop()
            inst.components.locomotor:Stop()
            -- inst.AnimState:PlayAnimation("atk_leap_pre")
            -- inst.AnimState:PushAnimation("atk_leap_lag",true)

            inst.AnimState:PlayAnimation("chop_pre")
            inst.AnimState:PushAnimation("chop_lag", true)

            inst.sg.statemem.targetpos = data.targetpos

            inst:ForceFacePoint(inst.sg.statemem.targetpos)

            inst.sg:SetTimeout(120 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("stun", {
                duration = GetRandomMinMax(2.5, 3)
            })
        end,

        timeline = {
            TimeEvent(25 * FRAMES, function(inst)
                inst.AnimState:SetBank("tornado")
                inst.AnimState:SetBuild("tornado")
                inst.AnimState:PlayAnimation("tornado_loop", true)

                -- TODO:Add spin sfx
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spin")
                inst.SoundEmitter:SetVolume("spin", 0.33)

                inst.sg.statemem.task = inst:CreateSpinTask()
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetBank("wilson")
            inst.AnimState:SetBuild("galeboss_katash")
            if inst.sg.statemem.task then
                KillThread(inst.sg.statemem.task)
            end
            inst.SoundEmitter:KillSound("spin")
            inst.Physics:Stop()
            inst:RestartBrain()
        end,

        events =
        {
            EventHandler("attacked", function(inst, data)

            end),
        },
    },

    State {
        name = "stun",
        tags = { "busy", "stunned" },

        onenter = function(inst, data)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("idle_groggy01_pre")

            inst.components.timer:StartTimer("stun", data.duration)

            inst:EnableStunFX(true)
            -- inst:StopBrain()
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("stunned_hit", function(inst)
                inst.sg:GoToState("stun_hit")
            end),
            EventHandler("animover", function(inst) inst.sg:GoToState("stun_loop") end),
        },
    },

    State {
        name = "stun_loop",
        tags = { "busy", "stunned" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_groggy01_loop")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("stunned_hit", function(inst) inst.sg:GoToState("stun_hit") end),
            EventHandler("animover", function(inst)
                if inst.components.timer:TimerExists("stun") then
                    inst.sg:GoToState("stun_loop")
                else
                    inst.sg:GoToState("idle", "idle_groggy01_pst")
                end
            end),
        },
    },

    State {
        name = "stun_hit",
        tags = { "busy", "stunned" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.timer:TimerExists("stun") then
                    inst.sg:GoToState("stun_loop")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "attack_dash_pre",
        tags = { "busy", "attack" },

        onenter = function(inst, data)
            inst.Transform:SetEightFaced()
            inst.components.locomotor:Stop()

            inst.AnimState:SetDeltaTimeMultiplier(0.9)

            -- inst.AnimState:PlayAnimation("atk_pre")
            -- inst.AnimState:PushAnimation("atk_lag",false)

            inst:EnableBladeAnim(true)

            inst.AnimState:PlayAnimation("multithrust")
            inst.SoundEmitter:PlaySound(inst.sounds.dash_pre)

            inst.AnimState:SetMultColour(77 / 255, 0 / 255, 205 / 255, 1)
            inst.AnimState:SetAddColour(77 / 255, 0 / 255, 205 / 255, 1)

            local speed_base = (data.start_pos - inst:GetPosition()):GetNormalized()

            inst.sg.statemem.last_shadow_pt = nil
            inst.sg.statemem.start_pos = data.start_pos
            inst.sg.statemem.target_pos = data.target_pos
            inst.sg.statemem.count = data.count
            inst.sg.statemem.task = inst:CreateTeleportTask(
                data.start_pos,
                0.1, function(inst, percent)
                    if inst.sg.statemem.last_shadow_pt == nil
                        or (inst:GetPosition() - inst.sg.statemem.last_shadow_pt):Length() >= 1.5 then
                        local anim_data = GaleCommon.GetAnim(inst)
                        local shadow = SpawnAt("galeboss_katash_shadow", inst)
                        shadow.Transform:SetEightFaced()
                        shadow.Transform:SetRotation(inst.Transform:GetRotation())
                        shadow.AnimState:SetPercent(anim_data.anim, anim_data.percent)
                        shadow.Physics:SetVel((speed_base * 12 * (1 - percent)):Get())
                        GaleCommon.FadeTo(shadow, FRAMES * 7, nil,
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 0.66), Vector4(0, 0, 0, 0) },
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 1), Vector4(0, 0, 0, 0) },
                                          shadow.Remove)

                        inst.sg.statemem.last_shadow_pt = inst:GetPosition()
                    end

                    if percent >= 1 then
                        inst.AnimState:SetDeltaTimeMultiplier(1)

                        inst.AnimState:SetMultColour(1, 1, 1, 1)
                        inst.AnimState:SetAddColour(0, 0, 0, 0)
                    end
                end
            )

            local dp = data.start_pos - data.target_pos
            local angle = math.atan2(dp.z, -dp.x)
            inst.Transform:SetRotation(angle * RADIANS)

            inst.sg:SetTimeout(0.66)
        end,

        timeline = {
            TimeEvent(0.26, function(inst)
                -- inst.SoundEmitter:PlaySound(inst.sounds.dash)
                local anim_data = GaleCommon.GetAnim(inst)
                inst.AnimState:SetPercent("multithrust", anim_data.percent)
            end),
            TimeEvent(0.4, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.dash)
            end),
        },

        ontimeout = function(inst)
            inst.Transform:SetPosition(inst.sg.statemem.start_pos:Get())
            -- inst:ForceFacePoint(inst.sg.statemem.target_pos)
            inst.sg:GoToState("attack_dash", {
                target_pos = inst.sg.statemem.target_pos,
                count = inst.sg.statemem.count,
            })
        end,

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.AnimState:SetAddColour(0, 0, 0, 0)

            inst:EnableBladeAnim(false)

            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil
            end
        end,
    },

    State {
        name = "attack_dash",
        tags = { "busy", "attack" },

        onenter = function(inst, data)
            inst.Transform:SetEightFaced()
            inst.components.locomotor:Stop()

            inst.AnimState:SetDeltaTimeMultiplier(1)


            inst:EnableBladeAnim(true)

            local time = inst.AnimState:GetCurrentAnimationTime()
            inst.AnimState:PlayAnimation("multithrust")
            inst.AnimState:SetTime(time + 10 * FRAMES)

            inst.AnimState:SetMultColour(77 / 255, 0 / 255, 205 / 255, 1)
            inst.AnimState:SetAddColour(77 / 255, 0 / 255, 205 / 255, 1)

            local speed_base = (data.target_pos - inst:GetPosition()):GetNormalized()

            inst.sg.statemem.last_shadow_pt = nil
            inst.sg.statemem.hitted_targets = {}
            inst.sg.statemem.target_pos = data.target_pos
            inst.sg.statemem.count = data.count
            inst.sg.statemem.steal_victim = nil
            inst.sg.statemem.steal_food = nil
            inst.sg.statemem.task = inst:CreateTeleportTask(
                data.target_pos,
                0.1, function(inst, percent)
                    if inst.sg.statemem.last_shadow_pt == nil
                        or (inst:GetPosition() - inst.sg.statemem.last_shadow_pt):Length() >= 1.5 then
                        local anim_data = GaleCommon.GetAnim(inst)
                        local shadow = SpawnAt("galeboss_katash_shadow", inst)
                        shadow.Transform:SetEightFaced()
                        shadow.Transform:SetRotation(inst.Transform:GetRotation())
                        shadow.AnimState:SetPercent(anim_data.anim, anim_data.percent)
                        shadow.Physics:SetVel((speed_base * 12 * (1 - percent)):Get())
                        GaleCommon.FadeTo(shadow, FRAMES * 7, nil,
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 0.66), Vector4(0, 0, 0, 0) },
                                          { Vector4(77 / 255, 0 / 255, 205 / 255, 0.66), Vector4(0, 0, 0, 0) },
                                          shadow.Remove)

                        inst.sg.statemem.last_shadow_pt = inst:GetPosition()
                    end



                    local damage = function() return GetRandomMinMax(20, 30), nil, "electric" end
                    local stealing = inst.sg.statemem.steal_victim == nil
                        and inst.sg.statemem.steal_food == nil
                    local targets, steal_victim, steal_food = inst:AOEAttackAndStealFood(2, damage,
                                                                                         inst.sg.statemem.hitted_targets,
                                                                                         stealing)

                    for _, v in pairs(targets) do
                        inst.sg.statemem.hitted_targets[v] = true
                    end

                    if stealing and steal_victim and steal_food then
                        if steal_food.components.stackable then
                            steal_food = steal_food.components.stackable:Get()
                        end

                        local fx = SpawnAt("hammer_mjolnir_cracklebase", steal_victim, { 0.9, 0.9, 0.9 })
                        fx.AnimState:SetDeltaTimeMultiplier(0.66)
                        fx.AnimState:SetLightOverride(1)
                        fx.AnimState:SetAddColour(0 / 255, 138 / 255, 255 / 255, 1)
                        fx:ListenForEvent("animover", fx.Remove)

                        steal_victim:DoTaskInTime(15 * FRAMES, function()
                            -- if steal_victim.components.grogginess then
                            --     -- Make target knockout
                            --     steal_victim.components.grogginess:AddGrogginess(
                            --         steal_victim.components.grogginess:GetResistance(), 1)

                            --     -- steal_victim.components.grogginess:ComeTo()

                            --     -- steal_victim.components.grogginess:SubtractGrogginess(
                            --     --     steal_victim.components.grogginess:GetResistance() - FRAMES)
                            -- end
                            if steal_victim:HasTag("character") then
                                local animfx = SpawnAt("hammer_mjolnir_crackle", steal_victim, { 0.9, 0.7, 0.7 })
                                animfx.AnimState:SetAddColour(50 / 255, 169 / 255, 255 / 255, 1)
                                animfx.AnimState:HideSymbol("lightning_land")
                                animfx.AnimState:HideSymbol("droplet")
                                animfx.AnimState:SetLightOverride(1)
                                animfx.persists = false
                                animfx:ListenForEvent("animover", animfx.Remove)

                                steal_victim:PushEvent("attacked", { attacker = inst, damage = 0 })
                                steal_victim:PushEvent("knockback", { knocker = inst, radius = 8 })
                            end
                        end)


                        inst.sg.statemem.steal_victim = steal_victim
                        inst.sg.statemem.steal_food = steal_food
                        -- inst.SoundEmitter:PlaySound(inst.sounds.laugh)
                        inst.components.inventory:GiveItem(inst.sg.statemem.steal_food)

                        if steal_victim:HasTag("player") and steal_victim.userid then
                            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], steal_victim.userid,
                                               string.format(STRINGS.GALE_UI.ANNOUNCE_GALEBOSS_KATASH_STEAL_FOOD,
                                                             steal_food:GetDisplayName(),
                                                             inst:GetDisplayName())

                            )

                            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["play_clientside_sound"], steal_victim.userid,
                                               "gale_sfx/cooking/item_stolen", true, true)
                        end

                        print(inst, "steal", steal_food, "from", steal_victim)
                    end


                    if percent >= 1 then
                        inst.AnimState:SetDeltaTimeMultiplier(1)
                        inst.AnimState:SetMultColour(1, 1, 1, 1)
                        inst.AnimState:SetAddColour(0, 0, 0, 0)
                    end
                end
            )

            inst.sg:SetTimeout(0.66)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.count = inst.sg.statemem.count - 1
            if inst.sg.statemem.steal_victim and inst.sg.statemem.steal_food then
                inst.sg:GoToState("laugh_steal_food")
            elseif inst.components.combat.target == nil or inst.sg.statemem.count <= 0 then
                inst.sg:GoToState("idle", true)
            else
                -- inst.sg.statemem.count
                local start_pos, final_pos = inst:GenerateDashPosList(inst.components.combat.target)
                if start_pos == nil or final_pos == nil then
                    inst.sg:GoToState("idle", true)
                else
                    inst.sg:GoToState("attack_dash_pre", {
                        start_pos = start_pos,
                        target_pos = final_pos,
                        count = inst.sg.statemem.count,
                    })
                end
            end
        end,

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.AnimState:SetAddColour(0, 0, 0, 0)

            inst:EnableBladeAnim(false)

            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil
            end
        end,
    },

    State {
        name = "attack_throw",
        tags = { "busy", "attack", "abouttoattack", },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:OverrideSymbol("swap_object", "swap_athetos_grenade_elec", "swap_athstos_grenade_elec")

            inst.AnimState:PlayAnimation("throw_pre")
            inst.AnimState:PushAnimation("throw", false)

            inst.sg.statemem.target_pos = data.target_pos

            inst:ForceFacePoint(data.target_pos)

            inst.sg:SetTimeout(11 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        timeline = {
            TimeEvent(7 * FRAMES, function(inst)
                -- throw
                local proj = SpawnAt("athetos_grenade_elec", inst)
                proj.components.complexprojectile:SetHorizontalSpeed(25)
                proj.components.complexprojectile:SetGravity(-50)
                proj.components.complexprojectile:Launch(inst.sg.statemem.target_pos, inst)

                inst.sg:AddStateTag("canchangetodash")
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:OverrideSymbol("swap_object", "swap_gale_blaster_katash", "swap_gale_blaster_katash")
        end,
    },

    State {
        name = "lightning_roll_pre",
        tags = { "busy", "abouttoattack" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("emote_fistshake")

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_katash/howl")

            inst.sg.statemem.target = data.target or inst.components.combat.target


            inst:EnableBladeAnim(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if not (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) then
                    inst.sg.statemem.target = inst.components.combat.target
                end
                inst.sg:GoToState("lightning_roll", {
                    target = inst.sg.statemem.target,
                })
            end),
        },

        onexit = function(inst)
            inst:EnableBladeAnim(false)
        end,
    },

    State {
        name = "lightning_roll",
        tags = { "busy", "attack" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)

            inst:EnableBladeAnim(true)

            inst.AnimState:PlayAnimation("fangun_pre")
            inst.AnimState:PushAnimation("fangun_loop", true)

            inst.sg.statemem.fxs = {}
            inst.sg.statemem.hitted_targst = {}
            inst.sg.statemem.target = data.target

            local s = 0.6
            local fx_num = 3
            for i = 1, fx_num do
                local fx = inst:SpawnChild("cracklehitfx")
                fx.Transform:SetScale(s, s, s)
                fx.persists = false

                fx.AnimState:PlayAnimation("crackle_loop")
                fx.AnimState:SetTime((i - 1) * fx.AnimState:GetCurrentAnimationLength() / fx_num)
                fx.AnimState:SetAddColour(0 / 255, 0 / 255, 255 / 255, 1)

                fx:ListenForEvent("animover", function()
                    if fx.perish then
                        fx:Remove()
                    else
                        fx.AnimState:PlayAnimation("crackle_loop")
                    end
                end)

                table.insert(inst.sg.statemem.fxs, fx)
            end

            -- inst.components.locomotor:SetExternalSpeedMultiplier(inst, "lightning_roll", 0.8)


            inst.SoundEmitter:PlaySound("gale_sfx/battle/static_shocked", "static_shocked")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/ElectricalBuzzLoop", "ElectricalBuzzLoop")


            inst.sg:SetTimeout(10)

            inst:StopBrain()
        end,

        onupdate = function(inst)
            if not (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) then
                inst.sg.statemem.target = inst.components.combat.target
            end

            if not (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) then
                inst.AnimState:PlayAnimation("fangun_pst")
                inst.sg:GoToState("idle", true)
                return
            end

            -- inst.sg.statemem.hitted_targst
            local victims =
                GaleCommon.AoeDoAttack(inst, inst:GetPosition(), inst:GetPhysicsRadius(0) + 2, function(inst, other)
                                           local weapon, projectile, stimuli, instancemult, ignorehitrange
                                           instancemult = 0.2
                                           ignorehitrange = true

                                           instancemult = instancemult *
                                               math.clamp(other:GetPhysicsRadius(0) + 0.5, 1, 3)
                                           if other:HasTag("largecreature") then
                                               instancemult = instancemult * 1.2
                                           end

                                           --  stimuli = "electric"

                                           return weapon, projectile, stimuli, instancemult, ignorehitrange
                                       end, function(inst, other)
                                           return inst.components.combat and inst.components.combat:CanTarget(other) and
                                               not inst.components.combat:IsAlly(other) and
                                               (GetTime() - (inst.sg.statemem.hitted_targst[other] or 0) > 0.1)
                                       end)

            for k, v in pairs(victims) do
                inst.sg.statemem.hitted_targst[v] = GetTime()
            end
            -- if dir ~= nil then
            --     inst:ForceFacePoint(inst:GetPosition() + dir)
            -- end


            local target = inst.sg.statemem.target

            inst:ForceFacePoint(target:GetPosition())

            local cur_vel = Vector3(inst.Physics:GetVelocity())
            local towards = (target:GetPosition() - inst:GetPosition()):GetNormalized()
            local dist = (target:GetPosition() - inst:GetPosition()):Length()
            local speed = Remap(math.clamp(dist, 1, 8), 1, 8, 25, 15)

            if GetTime() - (inst.components.combat.lastwasattackedtime or 0) <= 1 then
                speed = speed * 0.1
            end

            local next_vel = cur_vel + towards * FRAMES * speed

            if next_vel:Dot(towards) > 0 then
                if next_vel:Length() >= 8 then
                    next_vel = next_vel:GetNormalized() * 8
                end
            else
                if next_vel:Length() >= 8 then
                    next_vel = next_vel:GetNormalized() * 8
                end
            end

            SetVel(inst, next_vel)
        end,


        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("fangun_pst")
            inst.sg:GoToState("idle", true)
        end,

        timeline =
        {

        },

        events =
        {
            EventHandler("attacked", function(inst, data)
                if data.attacker then
                    local towards = (data.attacker:GetPosition() - inst:GetPosition()):GetNormalized()
                    inst.Physics:Stop()
                    SetVel(inst, -towards * Remap(math.clamp(data.damage, 1, 100), 1, 100, 3, 10))
                end
            end),
        },


        onexit = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("static_shocked")
            inst.SoundEmitter:KillSound("ElectricalBuzzLoop")

            -- inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "lightning_roll")
            inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.ALWAYS)


            inst:EnableBladeAnim(false)

            for _, v in pairs(inst.sg.statemem.fxs) do
                v.perish = true
            end

            inst:RestartBrain()
        end,
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("emote_laugh")
            inst.SoundEmitter:PlaySound(inst.sounds.laugh)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "laugh_steal_food",
        tags = { "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("emote_laugh")

            inst.SoundEmitter:PlaySound(inst.sounds.laugh)

            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.STEAL))
        end,

        timeline =
        {

            TimeEvent(0 * FRAMES, function(inst)

            end),

        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("eat")
                end
            end),

            EventHandler("attacked", function(inst, data)
                if IsEntityDead(inst, true) then
                    return
                end

                if data.damage and data.damage >= 20 then
                    inst.sg.statemem.food = nil
                    local item = inst.components.inventory:GetItemInSlot(1)
                    if item then
                        inst.components.inventory:DropItem(item, true, true)
                    end

                    inst.sg:GoToState("hit")
                end
            end),
        },
    },


    State {
        name = "eat",
        tags = { "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local food = inst.components.inventory:GetItemInSlot(1)

            if food == nil then
                inst.sg:GoToState("idle")
                return
            elseif not inst.components.eater:CanEat(food) then
                inst.components.inventory:DropItem(food, true, true)
                inst.sg:GoToState("idle")
                return
            end

            inst.sg.statemem.food = food
            inst.sg.statemem.quickeat = food.components.edible.foodtype ~= FOODTYPE.MEAT
            inst.sg.statemem.good_food = true

            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")

            if inst.sg.statemem.quickeat then
                inst.AnimState:PlayAnimation("quick_eat_pre")
                inst.AnimState:PushAnimation("quick_eat", false)
            else
                inst.AnimState:PlayAnimation("eat_pre")
                inst.AnimState:PushAnimation("eat", false)
            end
        end,

        timeline =
        {

            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.quickeat and inst.sg.statemem.food then
                    local old_health = inst.components.health.currenthealth
                    inst.components.eater:Eat(inst.sg.statemem.food)
                    -- inst.sg:RemoveStateTag("busy")
                    local new_health = inst.components.health.currenthealth

                    inst.sg.statemem.good_food = new_health >= old_health
                end
            end),


            TimeEvent(28 * FRAMES, function(inst)
                if not inst.sg.statemem.quickeat and inst.sg.statemem.food then
                    local old_health = inst.components.health.currenthealth
                    inst.components.eater:Eat(inst.sg.statemem.food)
                    local new_health = inst.components.health.currenthealth

                    inst.sg.statemem.good_food = new_health >= old_health
                end
            end),

            TimeEvent(50 * FRAMES, function(inst)
                if not inst.sg.statemem.quickeat then
                    -- inst.sg:RemoveStateTag("busy")
                    if not inst.sg.statemem.good_food then
                        inst.sg:GoToState("eat_bad_food_disgusting")
                    end
                end
            end),

            TimeEvent(70 * FRAMES, function(inst)
                if not inst.sg.statemem.quickeat then
                    inst.SoundEmitter:KillSound("eating")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.good_food then
                        inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.EAT_GOOD))
                        inst.SoundEmitter:PlaySound(inst.sounds.eat_good)
                        inst.sg:GoToState("idle")
                    else
                        inst.sg:GoToState("eat_bad_food_disgusting")
                    end
                end
            end),

            EventHandler("attacked", function(inst, data)
                if IsEntityDead(inst, true) then
                    return
                end

                if data.damage and data.damage >= 20 then
                    inst.sg.statemem.food = nil
                    local item = inst.components.inventory:GetItemInSlot(1)
                    if item then
                        inst.components.inventory:DropItem(item, true, true)
                    end

                    inst.sg:GoToState("hit")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
        end,
    },

    State {
        name = "eat_bad_food_disgusting",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")

            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH.EAT_BAD))

            inst.SoundEmitter:PlaySound(inst.sounds.eat_bad)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


}


CommonStates.AddIdle(states)
CommonStates.AddRunStates(states, {
    starttimeline = {
        TimeEvent(4 * FRAMES, PlayFootstep),
    },
    runtimeline = {
        TimeEvent(7 * FRAMES, PlayFootstep),
        TimeEvent(15 * FRAMES, PlayFootstep),
    },
    endtimeline = {

    },
})
-- CommonStates.AddWalkStates(states,nil,{
--     startwalk = "careful_walk_pre",
--     walk = "careful_walk",
--     stopwalk = "careful_walk_pst",
-- })
CommonStates.AddCombatStates(states, {
                                 -- hittimeline =
                                 -- {
                                 --     TimeEvent(0*FRAMES, function(inst)

                                 --     end),
                                 -- },

                                 attacktimeline =
                                 {

                                     TimeEvent(0 * FRAMES, function(inst)
                                         local target = inst.components.combat.target
                                         inst.sg.statemem.targetpos = target and target:GetPosition() or
                                             (inst:GetPosition() + GaleCommon.GetFaceVector(inst))
                                     end),

                                     TimeEvent(17 * FRAMES, function(inst)
                                         -- inst.components.combat:DoAttack(inst.sg.statemem.target)


                                         inst:LaunchFanProjectiles(inst.sg.statemem.targetpos)

                                         inst.sg:AddStateTag("canchangetodash")

                                         -- inst.sg:RemoveStateTag("abouttoattack")
                                     end),
                                     TimeEvent(20 * FRAMES, function(inst)
                                         -- inst.sg:RemoveStateTag("attack")
                                     end),
                                 },
                             },
                             {
                                 attack = "hand_shoot",
                             }
)

return StateGraph("SGgaleboss_katash", states, events, "idle")
