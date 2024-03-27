require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")


local actionhandlers = {
    ActionHandler(ACTIONS.PICKUP,
                  function(inst, action)
                      return "pickup_and_consume"
                  end),
    ActionHandler(ACTIONS.HAMMER, "attack"),
}


local events = {
    CommonHandlers.OnLocomote(true, true),
    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),
    CommonHandlers.OnHop(),

    CommonHandlers.OnDeath(),
    -- CommonHandlers.OnAttacked(),
    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("rankup") then
                inst.sg:GoToState("hit", true)
            else
                if not inst.sg:HasStateTag("no_stun") then
                    inst.sg:GoToState("hit")
                end
            end
        end
    end),

    EventHandler("knockback", function(inst, data)
        data.is_dead = inst.components.health:IsDead()

        inst.sg:GoToState("knockback", data)
    end),
}

local function AnimSpeedUp1p5(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1.5)
end

local function AnimSpeedUp3(inst)
    inst.AnimState:SetDeltaTimeMultiplier(3)
end

local function AnimSpeedDown(inst)
    inst.AnimState:SetDeltaTimeMultiplier(1)
end

local function GetMultiplyTimeline()
    local timeline = {}

    local inverse = false
    for i = 0, 20 do
        if inverse then
            table.insert(timeline, TimeEvent(i * 3 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "mutate_pst", false, 335 / 834, 2)
            end))
        else
            table.insert(timeline, TimeEvent(i * 3 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("mutate_pst")
                inst.AnimState:SetTime(5 * FRAMES)
            end))
        end
        inverse = not inverse
    end

    return timeline
end

local states = {
    State {
        name = "multiply",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            -- inst.AnimState:SetBank("spider_moon")
            -- inst.AnimState:PlayAnimation("hide")
            -- inst.AnimState:PushAnimation("hide_loop",true)
            inst.SoundEmitter:PlaySound(inst.sounds.multiply)
            inst.AnimState:SetDeltaTimeMultiplier(2)

            inst.sg.statemem.fx = inst:SpawnChild("typhon_mimic_multiply_vfx")
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "body", 0, 15, 0)

            inst.sg:SetTimeout(1.3 + math.random() * 0.5)
        end,

        ontimeout = function(inst)
            -- local old_hunger = inst.components.hunger.current
            -- inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.components.hunger:SetPercent(0)
            local already_set = {}
            for i = 1, 3 do
                local offset = FindWalkableOffset(inst:GetPosition(),
                                                  math.random() * 2 * PI,
                                                  1,
                                                  33,
                                                  nil,
                                                  false,
                                                  function(pt)
                                                      for _, v in pairs(already_set) do
                                                          if (pt - v):Length() < 1 then
                                                              return false
                                                          end
                                                      end
                                                      return true
                                                  end)
                local ent = SpawnAt("typhon_mimic", inst, nil, offset)
                if offset then
                    table.insert(already_set, offset)
                end
                -- if not ent.sg:HasStateTag("busy") then
                ent.sg:GoToState("taunt")
                -- end
            end
            inst:SpawnChild("condition_dread_fx")
            inst:SetLevel(inst.level + 1)
            inst.sg:GoToState("hit")
        end,

        timeline = GetMultiplyTimeline(),

        onexit = function(inst)
            -- inst.AnimState:SetBank("spider")
            inst.AnimState:SetDeltaTimeMultiplier(1)
            GaleCommon.ClearBackAnimation(inst)
            if inst.sg.statemem.fx then
                inst.sg.statemem.fx:Remove()
            end
        end,
    },

    State {
        name = "rankup",
        tags = { "busy", "rankup" },

        onenter = function(inst)
            inst.AnimState:SetBank("typhon_mimic")

            inst.Physics:Stop()
            -- inst.AnimState:SetBank("spider_moon")
            inst.AnimState:PlayAnimation("interract_pre")
            inst.AnimState:PushAnimation("interract_loop", true)
            -- inst.SoundEmitter:PlaySound(inst.sounds.multiply)
            -- inst.AnimState:SetDeltaTimeMultiplier(2)

            inst:StopBrain()
        end,

        onupdate = function(inst)
            local x, y, z = inst:GetPosition():Get()
            local mimic_nearvy_cnt = 0
            for _, v in pairs(TheSim:FindEntities(x, y, z, 15, { "typhon" }, {
                "INLIMBO" })) do
                if v ~= inst and v.prefab == "typhon_mimic" then
                    mimic_nearvy_cnt = mimic_nearvy_cnt + 1
                    if not v.components.health:IsDead() then
                        v.components.combat:SuggestTarget(inst)
                    end
                end
            end

            if mimic_nearvy_cnt == 0 then
                inst.rankup_process = false
                inst.sg:GoToState("idle", "cower_pst")
            end
        end,

        onexit = function(inst)
            inst:RestartBrain()
            inst.AnimState:SetBank("spider")
        end,
    },

    State {
        name = "pickup_and_consume",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.AnimState:PushAnimation("eat_loop", true)
            inst.SoundEmitter:PlaySound(inst.sounds.eat, "eating")


            inst.sg:SetTimeout(1 + math.random())
        end,

        timeline = {
            TimeEvent(15 * FRAMES, function(inst)
                local bufferedaction = inst:GetBufferedAction()
                local target = bufferedaction and bufferedaction.target
                if target and target.components.stackable then
                    inst:GetBufferedAction().target = target.components.stackable:Get()
                end

                inst:PerformBufferedAction()

                local item = inst.components.inventory:GetItemInSlot(1)
                if item then
                    local stack_mult = item.components.stackable and item.components.stackable:StackSize() or 1
                    if inst.components.eater:CanEat(item) then
                        inst.components.eater:Eat(item)
                    else
                        local p1, p2, _ = inst.components.eater.custom_stats_mod_fn(inst, nil, nil, nil, item)
                        if p1 == nil and p2 == nil then
                            inst.components.inventory:DropItem(item)
                        else
                            inst.components.health:DoDelta(p1 * stack_mult, nil, item.prefab)
                            inst.components.hunger:DoDelta(p2 * stack_mult)
                            item:Remove()
                        end
                    end
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "eat_pst")
        end,

        events =
        {
            -- EventHandler("animover", function(inst)

            -- end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
        end,
    },

    State {
        name = "evade",
        tags = { "busy", "evade", "no_stun" },


        onenter = function(inst, facepoint)
            inst:StopBrain()

            if facepoint then
                inst:ForceFacePoint(facepoint)
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("evade")


            inst.SoundEmitter:PlaySound(inst.sounds.evade, "dodge")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(-20, 0, 0)
            end),

            TimeEvent(11 * FRAMES, function(inst)
                inst.Physics:Stop()
                inst.SoundEmitter:KillSound("dodge")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            inst.components.combat:ResetCooldown()

            inst.SoundEmitter:KillSound("dodge")

            inst:RestartBrain()
        end,
    },


    State {
        name = "attack_leap",
        tags = { "attack", "canrotate", "busy", "jumping", "no_stun" },

        onenter = function(inst, target)
            inst:StopBrain()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("warrior_atk")

            if target then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target:GetPosition())
            end
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst:RestartBrain()
        end,

        timeline =
        {
            -- TimeEvent(0*FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound(inst.sounds.attack)
            -- end),
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack_jump)
            end),
            TimeEvent(8 * FRAMES, function(inst) inst.Physics:SetMotorVel(20, 0, 0) end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
            end),
            TimeEvent(19 * FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(20 * FRAMES,
                      function(inst)
                          inst.components.locomotor:Stop()
                      end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(math.random() < 0.1 and "taunt" or "idle")
            end),
        },
    },

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target
        end,

        timeline = {
            TimeEvent(0, AnimSpeedUp1p5),
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst:GetBufferedAction() then
                    inst:PerformBufferedAction()
                else
                    inst.components.combat:DoAttack(inst.sg.statemem.target)
                end
            end),
        },

        onexit = function(inst)
            AnimSpeedDown(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(inst.sounds.taunt)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst, rankup)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound(inst.sounds.hit)

            inst.sg.statemem.rankup = rankup
        end,

        timeline = {

        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.rankup then
                    inst.sg:GoToState("rankup")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.SoundEmitter:PlaySound(inst.sounds.death)
            if inst.higher_vfx then
                inst.higher_vfx:Remove()
                inst.higher_vfx = nil
            end
        end,

        timeline = {
            TimeEvent(66 * FRAMES, function(inst)
                if inst.rankup_process then
                    -- SpawnAt("typhon_weaver", inst).sg:GoToState("appear")
                    inst.sg:GoToState("death_become_weaver")
                else
                    ErodeAway(inst)
                end
            end),

        },


        onexit = function(inst)
            if not inst.rankup_process then
                inst:DoTaskInTime(2, ErodeAway)
            end
        end,
    },

    State {
        name = "death_become_weaver",
        tags = { "busy" },

        onenter = function(inst, quick)
            inst.components.locomotor:StopMoving()

            inst.sg.statemem.quick = quick

            if not quick then
                inst.AnimState:SetBank("typhon_mimic")
                inst.AnimState:PlayAnimation("review")
                inst.SoundEmitter:PlaySound(inst.sounds.rankup, "rankup")
            end
        end,

        timeline = {
            TimeEvent(33 * FRAMES, function(inst)
                if not inst.sg.statemem.quick then
                    inst.SoundEmitter:PlaySound(inst.sounds.idle)
                end
            end),

            TimeEvent(47 * FRAMES, function(inst)
                if not inst.sg.statemem.quick then
                    SpawnAt("typhon_mimic_rankup_splash", inst, { 1.1, 1.1, 1.1 })
                end
            end),

            TimeEvent(50 * FRAMES, function(inst)
                if not inst.sg.statemem.quick then
                    inst:Hide()
                end
            end),

            TimeEvent(66 * FRAMES, function(inst)
                if not inst.sg.statemem.quick then
                    local weaver = SpawnAt("typhon_weaver", inst)
                    weaver.sg:GoToState("appear")
                    weaver.SoundEmitter:PlaySound(weaver.sounds.attack_pre)
                    inst:Remove()
                end
            end),


            TimeEvent(0 * FRAMES, function(inst)
                if inst.sg.statemem.quick then
                    SpawnAt("typhon_mimic_rankup_splash", inst, { 1.1, 1.1, 1.1 })
                    inst:Hide()
                end
            end),

            TimeEvent(19 * FRAMES, function(inst)
                if inst.sg.statemem.quick then
                    local weaver = SpawnAt("typhon_weaver", inst)
                    weaver.sg:GoToState("appear")
                    weaver.SoundEmitter:PlaySound(weaver.sounds.attack_pre)
                    inst:Remove()
                end
            end),
        },
    },

    State {
        name = "knockback",
        tags = { "busy", "nomorph", "nodangle" },

        onenter = function(inst, data)
            -- print(inst,"Enter knockback SG !")
            inst:StopBrain()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if not data.is_dead then
                inst.AnimState:PlayAnimation("hit")
            end

            inst.sg.statemem.hoc_hit = true
            inst.sg.statemem.fx = inst:SpawnChild("gale_enemy_die_smoke_vfx")

            if data ~= nil then
                if data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or
                        data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 12 * k
                    inst.sg.statemem.dspeed = 0



                    inst.sg.statemem.hspeed = inst.sg.statemem.hoc_hit and (data.strengthmult or 1) * 20 * math.abs(k) or
                        0
                    inst.sg.statemem.dhspeed = inst.sg.statemem.hoc_hit and -1.25 or 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, inst.sg.statemem.hspeed, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, inst.sg.statemem.hspeed, 0)
                    end
                end
            end

            -- if add_data.timeout then
            -- 	inst.sg:SetTimeout(add_data.timeout)
            -- end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil and not inst.sg.statemem.sinked then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                inst.sg.statemem.hspeed = inst.sg.statemem.hspeed + inst.sg.statemem.dhspeed

                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + 0.0075
                else
                    inst.sg.statemem.speed = 0
                end
                inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed,
                                         inst.sg.statemem.hspeed, 0)

                local x, y, z = inst:GetPosition():Get()
                if not inst.components.amphibiouscreature and inst:IsOnOcean() and y <= 0.1 then
                    inst.Transform:SetPosition(x, 0, z)
                    if inst.sg.sg.events["onsink"] and not inst.components.health:IsDead() then
                        inst.sg.statemem.sinked = true
                        inst:PushEvent("onsink", {})
                    else
                        SpawnAt("crab_king_waterspout", inst).Transform:SetScale(1, 0.7, 0.7)
                        inst:Remove()
                    end
                    return
                end
                if inst.sg.statemem.hoc_hit then
                    if y <= 0.1 and inst.sg.statemem.hspeed <= -0.5 then
                        inst.sg.statemem.hspeed = -0.5
                        inst.Transform:SetPosition(x, 0, z)
                        if inst.components.health:IsDead() then
                            if inst.rankup_process then
                                inst.sg:GoToState("death_become_weaver", true)
                            end
                        else
                            inst.sg:GoToState("idle")
                        end
                        if math.abs(inst.sg.statemem.speed or 0) <= 0.75 then
                            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                                inst.sg.statemem.fx:Remove()
                            end
                            inst.sg.statemem.fx = nil
                        end
                    end
                end
            end

            -- if inst.components.health and inst.components.health:IsDead() then
            --     inst.AnimState:SetHaunted(true)
            -- end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
            inst:RestartBrain()
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end,
    },


    State {
        name = "gale_mimicing",
        tags = { "busy", "mimicing" },

        onenter = function(inst, data)
            if not data.target then
                inst.sg:GoToState("idle")
            else
                RemovePhysicsColliders(inst)
                -- inst:StopBrain()
                inst.Physics:Stop()
                -- inst.SoundEmitter:PlaySound(inst.sounds.taunt)
                SpawnAt("statue_transition_2", inst)
                inst.components.gale_skill_mimic:Start(data.target)

                inst.sg.statemem.check_cd = GetRandomMinMax(3, 5)

                inst.components.hunger.burnratemodifiers:SetModifier(inst, 1e-5, "mimicing")
            end
        end,

        onupdate = function(inst)
            inst.sg.statemem.check_cd = inst.sg.statemem.check_cd - FRAMES
            if inst.sg.statemem.check_cd <= 0 then
                if inst:GetBufferedAction() then
                    inst.sg:GoToState("idle")
                else
                    local target = inst.components.combat.target

                    if target then
                        if target:IsNear(inst, inst.components.combat.attackrange) then
                            inst.sg:GoToState("attack", target)
                        elseif target:IsNear(inst, 6) then
                            inst.sg:GoToState("attack_leap", target)
                        end
                    end
                end


                inst.sg.statemem.check_cd = GetRandomMinMax(1, 2)
            end
        end,

        onexit = function(inst)
            -- inst:RestartBrain()
            ChangeToCharacterPhysics(inst, 10, .5)
            if inst.components.gale_skill_mimic:IsMimic() then
                SpawnAt("statue_transition_2", inst)
                inst.components.gale_skill_mimic:Stop()
            end
            inst.components.hunger.burnratemodifiers:RemoveModifier(inst, "mimicing")
        end,
    },


    State {
        name = "gale_mimicing_pst",
        tags = { "busy", },

        onenter = function(inst)
            inst:RestartBrain()
            SpawnAt("statue_transition_2", inst)
            inst.sg:GoToState("idle")
        end,
    },
}


CommonStates.AddIdle(states, nil, "idle", {
    TimeEvent(0 * FRAMES, function(inst)
        if inst.components.gale_magic then
            inst.components.gale_magic:SetPercent(1.0)
        end

        if inst.level < 4 then
            if inst.components.combat.target == nil and inst.components.hunger:GetPercent() >= 0.95 then
                inst.sg:GoToState("multiply")
            end
        else
            -- TODO:拟态升格为编织魔
        end
    end),
})

CommonStates.AddWalkStates(states, {
                               starttimeline = {
                                   TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                               },

                               walktimeline = {
                                   TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                   TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                   TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                   TimeEvent(12 * FRAMES,
                                             function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                               },

                               endtimeline = {
                                   TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                               },
                           },
                           {
                               startrun = "walk_pre",
                               run = "walk_loop",
                               stoprun = "idle",
                           })



CommonStates.AddRunStates(states, {
                              starttimeline = {
                                  TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                              },

                              runtimeline = {
                                  TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                                  TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
                              },
                          },
                          {
                              startrun = "walk_pre",
                              run = "walk_loop",
                              stoprun = "idle",
                          }, nil, nil,
                          {
                              startonenter = AnimSpeedUp3,
                              startonexit = AnimSpeedDown,

                              runonenter = AnimSpeedUp3,
                              runonexit = AnimSpeedDown,
                          })


-- CommonStates.AddHitState(states)

-- CommonStates.AddCombatStates(states, {
--                                  attacktimeline = {
--                                      TimeEvent(0, AnimSpeedUp1p5),
--                                      TimeEvent(4 * FRAMES,
--                                                function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
--                                      -- TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/attack_grunt") end),
--                                      TimeEvent(17 * FRAMES, function(inst)
--                                          if inst:GetBufferedAction() then
--                                              inst:PerformBufferedAction()
--                                          else
--                                              inst.components.combat:DoAttack(inst.sg.statemem.target)
--                                          end
--                                      end),
--                                  },

--                                  deathtimeline = {
--                                      TimeEvent(0 * FRAMES,
--                                                function(inst)
--                                                    inst.SoundEmitter:PlaySound(inst.sounds.death)
--                                                    if inst.higher_vfx then
--                                                        inst.higher_vfx:Remove()
--                                                        inst.higher_vfx = nil
--                                                    end
--                                                end),
--                                  },
--                              }, nil,
--                              {
--                                  attackexit = AnimSpeedDown,
--                              })

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, false, { pre = "boat_jump_pre", loop = "boat_jump", pst = "boat_jump_pst" })
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("SGtyphon_mimic", states, events, "idle", actionhandlers)
