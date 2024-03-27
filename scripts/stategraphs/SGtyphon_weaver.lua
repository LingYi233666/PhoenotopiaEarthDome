require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")


local actionhandlers = {
    ActionHandler(ACTIONS.TYPHON_WEAVER_CREATE_PHANTOM, "create_phantom"),
}


local events = {
    CommonHandlers.OnLocomote(true, true),
    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),

    CommonHandlers.OnDeath(),

    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and not data.redirected then
            inst.sg:GoToState("hit")
        end
    end),


}

local states = {
    State {
        name = "appear",
        tags = { "busy", },


        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("appear")

            -- inst.SoundEmitter:PlaySound(inst.sounds.evade, "dodge")
        end,

        timeline = {
            -- TimeEvent(4 * FRAMES, function(inst)
            --     inst.Physics:SetMotorVel(-20, 0, 0)
            -- end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)

        end,
    },

    State {
        name = "disappear",
        tags = { "busy", },


        onenter = function(inst, targetpos)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("disappear")

            -- inst.SoundEmitter:PlaySound(inst.sounds.disappear)
            if targetpos then
                inst.sg.statemem.targetpos = targetpos
            end
        end,

        timeline = {
            TimeEvent(10 * FRAMES, function(inst)
                inst.components.health:SetInvincible(true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.targetpos then
                    inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                end
                inst.sg:GoToState("appear")
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound(inst.sounds.hit)
        end,

        timeline = {

        },

        events =
        {
            EventHandler("animover", function(inst)
                local midpt = inst:GetPosition()
                local offset = FindWalkableOffset(midpt,
                                                  math.random() * TWOPI,
                                                  GetRandomMinMax(1, 10),
                                                  33,
                                                  nil,
                                                  false,
                                                  nil,
                                                  true,
                                                  true)
                    or Vector3(0, 0, 0)
                inst.sg:GoToState("disappear", midpt + offset)
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("disappear")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end,
    },

    State {
        name = "recover_shield",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")


            inst.SoundEmitter:PlaySound(inst.sounds.attack_pre)
        end,

        timeline = {
            TimeEvent(22 * FRAMES, function(inst)
                inst.shield_amout = 200
                inst:SpawnShieldFX()
                inst:CheckShieldShrine()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "create_phantom",
        tags = { "busy" },

        onenter = function(inst)
            local target = inst:GetBufferedAction() and inst:GetBufferedAction().target
            if not (target and target:IsValid()) then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end

            inst:ForceFacePoint(target:GetPosition())

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")


            inst.sg.statemem.carry_fx = inst:SpawnChild("typhon_weaver_create_phantom_vfx")
            inst.sg.statemem.carry_fx.entity:AddFollower()
            inst.sg.statemem.carry_fx.Follower:FollowSymbol(inst.GUID, "face", 0, 0, 0)

            inst.sg.statemem.target = target


            inst.SoundEmitter:PlaySound(inst.sounds.create_phantom2)

            inst.sg:SetTimeout(120 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg.statemem.loop_anim_task = inst:DoPeriodicTask(23 * FRAMES, function()
                    inst.AnimState:PlayAnimation("taunt")
                    inst.AnimState:SetTime(5 * FRAMES)
                end)
            end),

            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.tmp_fx = inst.sg.statemem.target:SpawnChild("typhon_phantom_spawn_smoke_vfx")
                end
            end),

            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.create_phantom3)
            end),

            TimeEvent(40 * FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    local pt = inst.sg.statemem.target:GetPosition()
                    local name = inst.sg.statemem.target.prefab == "skeleton_player" and
                        inst.sg.statemem.target.playername or nil
                    inst.sg.statemem.target:Remove()


                    local phantom = SpawnAt("typhon_phantom", pt)
                    phantom.sg:GoToState("spawn", {
                        weaver = inst,
                    })

                    if name then
                        phantom.components.named:SetName(name)
                    end
                    SpawnAt("statue_transition_2", pt, { 1.3, 1.3, 1.3 })
                    -- for i = 1, 4 do
                    --     local offset = Vector3(UnitRand() * 0.5, 0, UnitRand() * 0.5)
                    --     SpawnAt("galeboss_ruinforce_projectile_dark_hitsplit", phantom, nil, offset)
                    -- end

                    -- local fx = SpawnAt("galeboss_ruinforce_projectile_dark_hitsplit", phantom, { 1.5, 1.3, 1 })
                    -- fx.AnimState:SetMultColour(0, 0, 0, 1)
                    -- phantom.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/waterspout")

                    inst.sg.statemem.phantom = phantom

                    inst:PerformBufferedAction()

                    inst.components.timer:StartTimer("create_phantom_cd", 600)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.loop_anim_task then
                inst.sg.statemem.loop_anim_task:Cancel()
            end

            if inst.sg.statemem.carry_fx and inst.sg.statemem.carry_fx:IsValid() then
                inst.sg.statemem.carry_fx:Remove()
            end

            if inst.sg.statemem.tmp_fx and inst.sg.statemem.tmp_fx:IsValid() then
                inst.sg.statemem.tmp_fx:Remove()
            end
        end,
    },

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target

            inst.SoundEmitter:PlaySound(inst.sounds.attack_pre)
        end,

        timeline = {
            TimeEvent(16 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
            end),
            TimeEvent(22 * FRAMES, function(inst)
                local offset_fn = CreateDiscEmitter(0.5)
                for i = 1, 4 do
                    inst:DoTaskInTime((i - 1) * 3 * FRAMES, function()
                        if not inst.components.health:IsDead() then
                            -- local target = (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) and
                            --     inst.sg.statemem.target
                            local x, z = offset_fn()
                            local a = math.random() * TWOPI
                            local speed = GetRandomMinMax(2, 3)
                            local vel = Vector3(math.cos(a) * speed, speed * 3 + math.random(), math.sin(a) * speed)
                            local poop = SpawnAt("typhon_cystoid", inst, nil, Vector3(x, GetRandomMinMax(2, 2.5), z))
                            poop.sg:GoToState("fall", vel)

                            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                                poop.manual_select_target = inst.sg.statemem.target
                            end
                            -- poop.components.follower
                            -- poop.components.follower:SetLeader(inst)
                            poop.SoundEmitter:PlaySound(poop.sounds.alert)
                        end
                    end)
                end
            end),
        },

        onexit = function(inst)

        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    }
}

CommonStates.AddIdle(states)

CommonStates.AddWalkStates(states, {
                               starttimeline = {
                               },

                               walktimeline = {
                               },

                               endtimeline = {
                               },
                           },
                           {
                               startrun = "walk_pre",
                               run = "walk_loop",
                               stoprun = "walk_pst",
                           })

local function AnimSpeedUp1p5(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1.5)
end

local function AnimSpeedUp3(inst)
    inst.AnimState:SetDeltaTimeMultiplier(3)
end

local function AnimSpeedDown(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1)
end

CommonStates.AddRunStates(states, {
                              starttimeline = {
                              },

                              runtimeline = {
                              },
                          },
                          {
                              startrun = "walk_pre",
                              run = "walk_loop",
                              stoprun = "walk_pst",
                          }, nil, nil,
                          {
                              --   startonenter = AnimSpeedUp1p5,
                              startonexit = AnimSpeedDown,

                              --   runonenter = AnimSpeedUp1p5,
                              runonexit = AnimSpeedDown,
                          })

return StateGraph("SGtyphon_weaver", states, events, "idle", actionhandlers)
