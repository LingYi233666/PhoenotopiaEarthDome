require("stategraphs/commonstates")


local actionhandlers = {

}

local events = {
    CommonHandlers.OnDeath(),
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end

        if not inst.components.locomotor:WantsToMoveForward() then
            if inst.sg:HasStateTag("creepping") then
                inst.sg:GoToState("funny_idle")
            end
        else
            if not inst.sg:HasStateTag("creepping") then
                inst.sg:GoToState("creep")
            end
        end
    end),
    EventHandler("attacked",
                 function(inst, data)
                     if not inst.components.health:IsDead() then
                         inst.sg:GoToState("funny_idle")
                     end
                 end)
}



local states = {
    State {
        name = "funny_idle",
        tags = { "busy", },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()


            inst.AnimState:PlayAnimation("idle_flash_" .. math.random(1, 2), true)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/athetos_iron_slug/funny_idle", "di")

            local oneshot = inst.AnimState:GetCurrentAnimationLength()

            inst.sg:SetTimeout(oneshot * math.random(3, 5))
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("di")
        end,
    },

    State {
        name = "creep",
        tags = { "moving", "canrotate", "creepping" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("walk")
        end,


        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },


        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            RemovePhysicsColliders(inst)

            local explo = SpawnAt("gale_bomb_projectile_explode", inst, { 1.5, 1.5, 1.5 }, Vector3(0, 1, 0))
            explo:SpawnChild("gale_normal_explode_vfx")

            inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/zombot/p1_zombot_shutoff")
            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)
            inst.components.lootdropper:DropLoot(inst:GetPosition() + Vector3(0, 1, 0))
            inst.DynamicShadow:Enable(false)
            inst:Hide()
        end,

        timeline = {

        },
    },

    State {
        name = "fall",
        tags = { "busy", "fall" },
        onenter = function(inst)
            inst.Physics:SetDamping(0)
            inst.AnimState:PlayAnimation("idle", true)
            inst.DynamicShadow:Enable(false)
        end,

        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
            end

            if pt.y <= .1 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x, pt.y, pt.z)
                inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("idle")
            end
        end,
    },
}

CommonStates.AddIdle(states, "funny_idle", "idle")

return StateGraph("SGathetos_iron_slug", states, events, "idle", actionhandlers)
