local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
}

local function SuitDegree(deg)
    if deg > 360 then
        local seg = math.floor(deg / 360)
        deg = deg - seg * 360
    end

    if deg < 0 then
        local seg = math.ceil(-deg / 360)
        deg = deg + seg * 360
    end

    return deg
end

local function DistPointToLine(pt, line_a, line_b)
    return ((pt - line_a):Cross(pt - line_b)):Length() / (pt - line_b):Length()
end


local function FindFriendlyOnFireline(inst, target_pos, maxcount)
    local results = {}
    local projectile_hitrange = 1.5 + 0.5
    local my_pos = inst:GetPosition()
    local my_rotation = inst:GetRotation()

    local x, y, z = my_pos:Get()
    local search_dist = (target_pos - my_pos):Length()
    local ents = TheSim:FindEntities(x, y, z, search_dist, { "_combat", "_health" }, { "INLIMBO", "playerghost" },
                                     { "player", "friendly", "athetos_portable_turret", "companion" })
    for _, v in pairs(ents) do
        if v ~= inst and not GaleCommon.IsTyphonTarget(v) then
            local delta_rotation = SuitDegree(my_rotation - inst:GetAngleToPoint(v:GetPosition()))
            if (delta_rotation >= 0 and delta_rotation < 90) or (delta_rotation > 270 and delta_rotation <= 360) then
                if not IsEntityDead(v, true)
                    and DistPointToLine(v:GetPosition(), my_pos, target_pos) <= projectile_hitrange then
                    table.insert(results, v)
                end
            end
            if #results >= maxcount then
                break
            end
        end
    end

    return results
end


local function AttackRotateCb(inst, delta_rotation)
    local target = inst.components.combat.target
    local DR = 3
    if target and target:IsValid()
        and not IsEntityDead(target)
        and inst:IsNear(target, inst.components.combat.hitrange)
        and not inst.components.combat:InCooldown()
        and (delta_rotation < DR or delta_rotation > (360 - DR)) then
        local friendly_on_fireline = FindFriendlyOnFireline(inst, target:GetPosition(), 1)

        if #friendly_on_fireline > 0 then
            if inst.last_say_ally_fireline_time == nil or GetTime() - inst.last_say_ally_fireline_time > 5 then
                inst:DoTalkSound("idle")
                inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.FIND_FIRELINE_ALLY)
                inst.last_say_ally_fireline_time = GetTime()
            end
        else
            inst.components.combat:StartAttack()
            inst._client_fire_event:push()
            local proj = SpawnAt("athetos_portable_turret_projectile", inst)
            proj.max_range = inst.components.combat.hitrange + GetRandomMinMax(-1, 1)
            proj.components.complexprojectile:Launch(inst:GetPosition() + GaleCommon.GetFaceVector(inst), inst, proj)
            proj:Hide()

            inst.SoundEmitter:PlaySound(inst.sounds.shoot)
        end
    end
end



local function GenerateRGBColours()
    local colour_set = {
        -- 4 seconds
        -- Vector3(0/255, 180/255, 255/255),
        -- Vector3(240/255, 230/255, 100/255),
        -- Vector3(251/255, 30/255, 30/255),
        Vector3(255 / 255, 0, 0),
        Vector3(255 / 255, 165 / 255, 0),
        Vector3(255 / 255, 255 / 255, 0),
        Vector3(0 / 255, 255 / 255, 0),
        Vector3(0 / 255, 255 / 255, 255 / 255),
        Vector3(0 / 255, 0 / 255, 255 / 255),
        Vector3(139 / 255, 0 / 255, 255 / 255),
    }

    local result = {

    }

    -- for i=0,12 / FRAMES do

    -- end
    for i = 1, #colour_set do
        local cur_colour = colour_set[i]
        local next_colour = i < #colour_set and colour_set[i + 1] or colour_set[1]
        local delta_colour = next_colour - cur_colour

        local max_j = 4 / FRAMES
        for j = 0, max_j do
            local gen_colour = cur_colour + delta_colour * (j / max_j)
            table.insert(result, gen_colour)
        end
    end

    return result
end

local sing_light_colours = GenerateRGBColours()

local states = {
    State {
        name = "deploy",
        tags = { "busy", },

        onenter = function(inst)
            inst._client_eye_colour:set(4)
            GaleCommon.PlayBackAnimation(inst, "change_to_item", false, nil, 0.66)

            inst:DoTalkSound("idle")
            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.DEPLOY))
        end,


        events =
        {
            EventHandler("back_animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            GaleCommon.ClearBackAnimation(inst)
        end,
    },

    State {
        name = "sing",
        tags = { "sing", "caninterrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")

            inst.sg.statemem.index = 1
            inst.sg:SetTimeout(105 --[[seconds]])

            inst.SoundEmitter:KillSound("turn_loop")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        onupdate = function(inst)
            inst.Light:SetColour(sing_light_colours[math.floor(inst.sg.statemem.index)]:Get())
            inst.sg.statemem.index = inst.sg.statemem.index + 1
            if inst.sg.statemem.index > #sing_light_colours then
                inst.sg.statemem.index = 1
            end
        end,

        timeline = {
            TimeEvent(0, function(inst)
                inst:DoTalkSound("idle")
                inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.SING[1])
            end),


            TimeEvent(66 * FRAMES, function(inst)
                inst:DoTalkSound("idle")
                inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.SING[2])
            end),

            TimeEvent(120 * FRAMES, function(inst)
                inst.Light:Enable(true)
                inst._client_eye_colour:set(4)
            end),

            TimeEvent(180 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("song", true)
                inst.SoundEmitter:PlaySound(inst.sounds.sing, "sing")

                inst.sg.statemem.task = inst:DoPeriodicTask(1, function()
                    SpawnAt("wx78_musicbox_fx", inst)
                end)
            end),
        },

        onexit = function(inst)
            -- GaleCommon.ClearBackAnimation(inst)
            inst.Light:Enable(false)
            inst.SoundEmitter:KillSound("sing")
            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
            end
        end,
    },

    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst._client_eye_colour:set(1)
            --pushanim could be bool or string?
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end

            local cur_rotate = inst.Transform:GetRotation()
            inst.target_pos = inst:GetPosition() + Vector3FromTheta(math.random() * TWOPI, 0.1)
            inst.sg.statemem.task = inst:CreateLockToTargetTask()

            inst.sg:SetTimeout(GetRandomMinMax(4, 4.5))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        timeline = {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.last_chat_time == nil or GetTime() - inst.last_chat_time >= GetRandomMinMax(8, 12) then
                    inst:DoTalkSound("idle")
                    inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.IDLE
                        .SIMPLE))

                    inst.last_chat_time = GetTime()
                end
            end),
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
            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
            end
        end,
    },

    State {
        name = "attack",
        tags = { "busy", "attack", "caninterrupt" },

        onenter = function(inst, target)
            inst._client_eye_colour:set(3)

            inst.pid_controller.kp = 10
            inst.target_pos = target:GetPosition()

            inst.components.combat:SetTarget(target)


            inst.sg.statemem.task = inst:CreateLockToTargetTask(AttackRotateCb)
            inst.sg.statemem.stopfire_time = nil
        end,

        onupdate = function(inst)
            local target = inst.components.combat.target

            if target and target:IsValid() and not IsEntityDead(target) and inst:IsNear(target, inst.components.combat.hitrange) then
                inst.target_pos = target:GetPosition()
                inst.sg.statemem.stopfire_time = nil
            else
                inst.components.combat:SetTarget(nil)

                if inst.sg.statemem.stopfire_time == nil then
                    inst.sg.statemem.stopfire_time = GetTime()
                end
                if inst.sg.statemem.task then
                    inst.sg.statemem.task:Cancel()
                end

                if GetTime() - inst.sg.statemem.stopfire_time > 2 then
                    inst.sg:GoToState("idle")
                else
                    local scan_target, attack_target, other_turrets = inst:SelectTarget()
                    if attack_target then
                        inst.sg:GoToState("attack", attack_target)
                    end
                end
            end
        end,

        timeline = {

        },

        onexit = function(inst)
            inst.pid_controller.kp = 1
            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
            end
            inst.components.combat:SetTarget(nil)
        end,
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")

            RemovePhysicsColliders(inst)

            local explo = SpawnAt("gale_bomb_projectile_explode", inst)
            explo.Transform:SetScale(1.5, 1.5, 1.5)
            explo:SpawnChild("gale_normal_explode_vfx")

            inst.components.lootdropper:DropLoot(inst:GetPosition())

            local start_rad = math.random() * TWOPI
            for i = 1, 8 do
                local fx = SpawnAt("athetos_portable_turret_deathpart", inst, nil, Vector3(0, 0.1, 0))
                local vel = Vector3FromTheta(Remap(i, 1, 8, 0, TWOPI) + start_rad + GetRandomMinMax(-PI / 9, PI / 9),
                                             GetRandomMinMax(1, 3))
                vel.y = GetRandomMinMax(18, 22)
                fx:ForceFacePoint(inst:GetPosition() + vel)
                fx.Physics:SetVel(vel:Get())
                fx:StartFX(i)
            end

            inst.SoundEmitter:PlaySound("gale_sfx/battle/zombot/p1_zombot_shutoff")
            inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
            ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)
        end,

        timeline = {

        },
    },


    State {
        name = "idle_scan_target",
        tags = { "idle", "canrotate", "scan_target" },

        onenter = function(inst, data)
            inst.pid_controller.kp = 10
            inst._client_eye_colour:set(2)


            inst.sg.statemem.talk = (data.talk == nil and true) or data.talk
            inst.sg.statemem.target = data.target

            inst.sg:SetTimeout(data.duration or GetRandomMinMax(3, 3.5))

            inst.sg.statemem.task = inst:CreateLockToTargetTask()

            if inst.sg.statemem.talk then
                inst:DoTalkSound("scan")
                inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.SCAN.START)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        onupdate = function(inst)
            local target = inst.sg.statemem.target

            if target and target:IsValid() and not IsEntityDead(target) and inst:IsNear(target, inst.components.combat.hitrange) then
                inst.target_pos = target:GetPosition()
            else
                inst.sg.statemem.target = nil

                if inst.sg.statemem.task then
                    inst.sg.statemem.task:Cancel()
                end
            end
        end,

        timeline = {
            TimeEvent(66 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target then
                    local num_typhon_skill = target.components.gale_skiller
                        and target.components.gale_skiller:GetTyphonSkillNum()
                        or 0
                    if num_typhon_skill <= 0 then
                        if inst.sg.statemem.talk then
                            inst:DoTalkSound("idle")
                            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET
                                .SCAN.RESULT.OK))
                        end
                    elseif num_typhon_skill == 1 then
                        if inst.sg.statemem.talk then
                            inst:DoTalkSound("idle")
                            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET
                                .SCAN.RESULT.TYPHON_1))
                        end
                    elseif num_typhon_skill == 2 then
                        if inst.sg.statemem.talk then
                            inst:DoTalkSound("scan")
                            inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.SCAN.RESULT
                                .TYPHON_2)
                        end

                        inst.sg:GoToState("idle_scan_target", {
                            talk = false,
                            target = target,
                        })
                    else
                        inst:DoTalkSound("attack")
                        inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.COMBAT
                            .TYPHON_3))
                        inst.sg:GoToState("attack", target)
                    end
                end
            end),
        },

        onexit = function(inst)
            inst.pid_controller.kp = 1
            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
            end
        end,
    },
}

CommonStates.AddHitState(states)

return StateGraph("SGathetos_portable_turret", states, events, "idle")
