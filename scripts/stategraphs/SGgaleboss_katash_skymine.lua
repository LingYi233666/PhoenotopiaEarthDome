require("stategraphs/commonstates")
local GaleCommon = require("util/gale_common")


local actionhandlers = {}


local events = {
    EventHandler("newstate", function(inst, data)
        if inst.sg:HasStateTag("fansound") and not inst.SoundEmitter:PlayingSound("fansound") then
            inst.SoundEmitter:PlaySound("", "fansound")
        elseif not inst.sg:HasStateTag("fansound") and inst.SoundEmitter:PlayingSound("fansound") then
            inst.SoundEmitter:KillSound("fansound")
        end
    end),

    EventHandler("death", function(inst, data)
        if inst.directly_explode then
            inst.sg:GoToState("death", data)
        elseif not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death_delay", data)
        end
    end),

    EventHandler("attacked", function(inst, data)
        -- if not inst.sg:HasStateTag("dead") then
        --     inst.sg:GoToState("death_delay", data)
        -- end
        inst.components.combat:SetTarget(data.target)
    end),
}


local states = {
    State {
        name = "idle",
        tags = { "idle", "fansound" },

        onenter = function(inst)
            inst.Physics:Stop()
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
                inst.sg:GoToState("turn_on")
            end),
        },
    },

    State {
        name = "turn_on",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("turn_on")
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
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("turn_off_pre")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst:PushEvent("on_landed")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("turn_off_idle")
            end),
        },
    },

    State {
        name = "chasing",
        tags = { "busy", "abouttoattack", "attack", "fansound" },

        onenter = function(inst)
            inst.sg.statemem.giveup_cd = GetRandomMinMax(3, 5)
            inst.sg.statemem.lost_target_time = nil

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
        end,

        ontimeout = function(inst)
            inst.directly_explode = true
            inst.components.health:Kill()
        end,

        events =
        {
            -- EventHandler("animover", function(inst)
            --     inst.sg:GoToState("death")
            -- end),
        },
    },

    State {
        name = "death_delay",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
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
            inst.DynamicShadow:Enable(false)
            inst:Hide()

            local s = 0.66
            local explo = SpawnAt("gale_bomb_projectile_explode", inst, { s, s, s })

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
                end
            )

            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end
    },
}






return StateGraph("SGgaleboss_katash_skymine", states, events, "turn_off_idle", actionhandlers)
