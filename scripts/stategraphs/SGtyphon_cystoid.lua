require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")


local actionhandlers = {
    ActionHandler(ACTIONS.TYPHON_CYSTOID_ATTACK, "attack"),
}


local events = {
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnHop(),


    EventHandler("death", function(inst, data)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death_delay", data)
        end
    end),

    EventHandler("attacked", function(inst, data)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death_delay", data)
        end
    end),
}


local states = {
    State {
        name = "death_delay",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound(inst.sounds.land)
            inst.SoundEmitter:PlaySound(inst.sounds.alert)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("death")
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst:Hide()

            local s = 0.66
            local explo = SpawnAt("gale_bomb_projectile_explode", inst, { s, s, s })
            local offsetfn = CreateDiscEmitter(0.33)
            for i = 1, 4 do
                local x, z = offsetfn()
                SpawnAt("typhon_cystoid_land_fx", inst, { 1, 1, 1 }, Vector3(x, 0, z))
            end

            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.2, inst, 20)



            local min_dist = 0.5
            local max_dist = inst.components.combat:GetHitRange()

            GaleCommon.AoeForEach(
                inst,
                inst:GetPosition(),
                max_dist,
                nil,
                { "INLIMBO" },
                { "_combat", "_inventoryitem" },
                function(attacker, v)
                    if attacker.components.combat:CanHitTarget(v) then
                        attacker.components.combat:DoAttack(v)
                    elseif v.components.inventoryitem then
                        local dist = math.clamp(math.sqrt(v:GetDistanceSqToInst(attacker)), min_dist, max_dist)
                        GaleCommon.LaunchItem(v, attacker, Remap(dist, min_dist, max_dist, 4, 2))
                    end
                end,
                function(inst, v)
                    local is_combat = inst.components.combat:CanHitTarget(v)
                    local is_inventory = v.components.inventoryitem
                    return v and v:IsValid()
                        and (is_combat or is_inventory)
                        and inst:CanAttack(v)
                end
            )

            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.SoundEmitter:PlaySound(inst.sounds.explode)

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end
    },

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target

            inst.SoundEmitter:PlaySound(inst.sounds.explode_pre, "explode_pre")

            inst.sg:SetTimeout(math.random(13, 20) * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("death")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("explode_pre")
        end,
    },

    State {
        name = "fall",
        tags = { "busy" },
        onenter = function(inst, vel)
            inst.Physics:SetDamping(0)
            inst.Physics:SetVel(vel:Get())
            inst.AnimState:PlayAnimation("walk_loop", true)
        end,

        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y <= .1 then
                pt.y = 0

                -- TODO: 20% of the time, they should explode on impact!

                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x, pt.y, pt.z)
                inst.SoundEmitter:PlaySound(inst.sounds.land)
                inst.sg:GoToState("idle")

                local s = 1.6
                SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
            end
        end,
    },
}

CommonStates.AddIdle(states, nil, "idle")

CommonStates.AddWalkStates(states, {
                               starttimeline = {

                               },

                               walktimeline = {
                                   TimeEvent(0 * FRAMES, function(inst)
                                       inst.SoundEmitter:PlaySound(inst.sounds.land)
                                       local s = 1.6
                                       SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                   end),

                                   --    TimeEvent(10 * FRAMES, function(inst)
                                   --        inst.SoundEmitter:PlaySound(inst.sounds.land)
                                   --        local s = 2
                                   --        SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                   --    end),

                                   TimeEvent(20 * FRAMES, function(inst)
                                       inst.SoundEmitter:PlaySound(inst.sounds.land)
                                       local s = 1.6
                                       SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                   end),

                                   --    TimeEvent(30 * FRAMES, function(inst)
                                   --        inst.SoundEmitter:PlaySound(inst.sounds.land)
                                   --        local s = 2
                                   --        SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                   --    end),
                               },

                               endtimeline = {
                               },
                           },
                           {
                               startrun = "walk_pre",
                               run = "walk_loop",
                               stoprun = "walk_pst",
                           })



CommonStates.AddRunStates(states, {
                              starttimeline = {
                              },

                              runtimeline = {
                                  TimeEvent(0 * FRAMES, function(inst)
                                      inst.SoundEmitter:PlaySound(inst.sounds.land)
                                      local s = 2
                                      SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                  end),
                                  TimeEvent(16 * FRAMES, function(inst)
                                      inst.SoundEmitter:PlaySound(inst.sounds.land)
                                      local s = 2
                                      SpawnAt("typhon_cystoid_land_fx", inst, { s, s, s })
                                  end),
                              },
                          },
                          {
                              startrun = "walk_pre",
                              run = "bounce",
                              stoprun = "walk_pst",
                          })

CommonStates.AddHopStates(states, false, { pre = "walk_pre", loop = "bounce", pst = "walk_pst" })


return StateGraph("SGtyphon_cystoid", states, events, "idle", actionhandlers)
