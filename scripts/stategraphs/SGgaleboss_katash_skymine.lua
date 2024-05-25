require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")


local actionhandlers = {}


local events = {
    EventHandler("newstate", function(inst, data)
        if inst.sg:HasStateTag("fansound") and not inst.SoundEmitter:PlayingSound("fansound") then
            inst.SoundEmitter:PlaySound(inst.sounds.spin, "fansound")
        elseif not inst.sg:HasStateTag("fansound") and inst.SoundEmitter:PlayingSound("fansound") then
            inst.SoundEmitter:KillSound("fansound")
        end
    end),

    EventHandler("death", function(inst, data)
        if inst.directly_explode and not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death", data)
        elseif not inst.sg:HasStateTag("dead") then
            if inst.sg:HasStateTag("fansound") then
                inst.AnimState:SetDeltaTimeMultiplier(6)
                inst.AnimState:PlayAnimation("success", true)
            end
            inst.sg:GoToState("death_delay", data)
        end

        -- if not inst.sg:HasStateTag("dead") then
        --     inst.sg:GoToState("death", data)
        -- end
    end),

    EventHandler("attacked", function(inst, data)
        if data.attacker then
            local towards = (data.attacker:GetPosition() - inst:GetPosition()):GetNormalized()
            inst.Physics:Stop()
            inst:AddVelocity(-towards * Remap(math.clamp(data.damage, 1, 100), 1, 100, 3, 10))
            -- inst:AddVelocity(-towards * 6)
        end
    end),
}


local states = {
    State {
        name = "idle",
        tags = { "idle", "fansound" },

        onenter = function(inst)
            -- inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)

            inst.sg:SetTimeout(math.random(15, 20) * FRAMES)
        end,

        ontimeout = function(inst)
            if inst.components.combat.target then
                inst.sg:GoToState("chasing")
            else
                inst.sg:GoToState("turn_off")
            end
        end,

        timeline = {
            -- TimeEvent(0 * FRAMES, function(inst)

            -- end),
        },
    },

    State {
        name = "turn_off_idle",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("turn_off_idle", true)
        end,

        events =
        {
            EventHandler("newcombattarget", function(inst)
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("turn_on")
                end
            end),

            EventHandler("attacked", function(inst, data)
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("turn_on")
                end
            end),
        },
    },

    State {
        name = "turn_on",
        tags = { "busy", "fansound" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("turn_on")

            inst.SoundEmitter:PlaySound(inst.sounds.turn_on)
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                -- Since this is the scanner's deploy state, pushing on_landed on the first frame
                -- can cause bad behaviour if 0,0,0 is an ocean position.
                inst:PushEvent("on_landed")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst:PushEvent("on_no_longer_landed")
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
        name = "turn_off",
        tags = { "busy" },

        onenter = function(inst)
            local vx, vy, vz = inst.Physics:GetVelocity()

            if Vector3(vx, vy, vz):Length() > 0.01 then
                inst.AnimState:PlayAnimation("walk_pst")
                inst.AnimState:PushAnimation("turn_off_pre", false)
            else
                inst.AnimState:PlayAnimation("turn_off_pre")
            end

            inst.Physics:Stop()

            inst.SoundEmitter:PlaySound(inst.sounds.turn_off)
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst:PushEvent("on_landed")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("turn_off_idle")
                end
            end),
        },
    },

    State {
        name = "chasing",
        tags = { "fansound" },

        onenter = function(inst)
            inst.sg.statemem.giveup_cd = GetRandomMinMax(0, 1)
            inst.sg.statemem.lost_target_time = nil

            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop", true)


            inst.sg:SetTimeout(10)
        end,

        onupdate = function(inst)
            local target = inst.components.combat.target
            if target == nil then
                if inst.sg.statemem.lost_target_time == nil then
                    inst.sg.statemem.lost_target_time = GetTime()
                end

                if GetTime() - inst.sg.statemem.lost_target_time > inst.sg.statemem.giveup_cd then
                    inst.sg:GoToState("turn_off")
                end
                return
            end

            inst.sg.statemem.lost_target_time = nil

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

            inst:SetVel(next_vel)

            -- local predict_pos = inst:GetPosition() + next_vel
            -- local lx, ly, lz = inst.entity:WorldToLocalSpace(predict_pos.x, 0, predict_pos.z)
            -- inst.Physics:SetMotorVel(lx, 0, lz)




            if inst.components.combat:CanAttack(target) then
                inst.directly_explode = true
                -- inst.components.health:Kill()
                inst.sg:GoToState("death")
            end
        end,

        ontimeout = function(inst)
            local target = inst.components.combat.target
            if target == nil then
                inst.sg:GoToState("turn_off")
            else
                inst.directly_explode = true
                -- inst.components.health:Kill()
                inst.sg:GoToState("death")
            end
        end,

        timeline = {
            TimeEvent(1, function(inst)
                inst:EnableBeep(0.4)
            end),

            TimeEvent(4.5, function(inst)
                inst:EnableBeep(0.25)
            end),

            TimeEvent(8, function(inst)
                inst:EnableBeep(0.15)
            end),
        },

        events =
        {

        },

        onexit = function(inst)
            inst:EnableBeep(false)
        end,
    },

    State {
        name = "death_delay",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.fail)
            inst.sg:SetTimeout(30 * FRAMES)

            inst.sg.statemem.fx = inst:SpawnChild("gale_enemy_die_smoke_vfx")
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0)
        end,

        onupdate = function(inst)
            local vel = Vector3(inst.Physics:GetMotorVel())
            vel = vel:GetNormalized() * math.max(vel:Length() - FRAMES * 3, 0)
            inst.Physics:SetMotorVel(vel.x, 0, vel.z)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("death")
        end,

        onexit = function(inst)
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
        end
    },

    State {
        name = "death",
        tags = { "busy", "dead", "invisible" },

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            inst.AnimState:SetMultColour(0, 0, 0, 0)
            inst.AnimState:Pause()

            local s = 1.0
            local explo = inst:SpawnChild("gale_bomb_projectile_explode")
            explo.Transform:SetScale(s, s, s)
            explo.entity:AddFollower()
            explo.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0)

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
                    if attacker.components.combat:CanHitTarget(v)
                        and attacker.components.combat:IsValidTarget(v) then
                        attacker.components.combat:DoAttack(v)
                        v:PushEvent("knockback", { knocker = attacker, radius = 4 })
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
                end
            )

            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.sg:SetTimeout(1)

            inst.SoundEmitter:PlaySound(inst.sounds.explo)

            inst.components.health:SetInvincible(true)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end
    },
}






return StateGraph("SGgaleboss_katash_skymine", states, events, "turn_off_idle", actionhandlers)
