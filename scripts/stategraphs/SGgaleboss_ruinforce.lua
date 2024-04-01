local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(),


    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            if inst.miss_target_count
                and inst.miss_target_count >= math.random(2, 3)
                and data.target
                and inst:IsNear(data.target, 8)
                and inst.phase >= 2 then
                inst.miss_target_count = 0
                inst.sg:GoToState("attack_double")
            else
                inst.sg:GoToState("attack")
            end
        end
    end),

    EventHandler("death", function(inst, data)
        inst:SetMusicLevel(1)
        if inst.phase < 2 then
            inst.sg:GoToState("beheaded")
        else
            inst.sg:GoToState("exploding")
        end
    end),
}

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
}

local function RuinforceMovePre1(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
end

-- local function RuinforceMovePre2(inst)
--     inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
-- end

local function RuinforceFootstep(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.step)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 1, inst, 40)
end


local function DoShoutting(inst, data)
    data = data or {}
    local offset = data.offset or Vector3(0, 0, 0)
    local period = data.period or (10 / 3 * FRAMES)
    local shoutfx = data.shoutfx or "gale_scream_ring_fx"
    local shoutsound = data.shoutsound or ""
    local maxtime = data.maxtime or 3
    local symbol = data.symbol or "deerclops_head"

    if data.enterfn then
        data.enterfn(inst)
    end

    for i = 0, maxtime, period do
        inst:DoTaskInTime(i, function()
            ShakeAllCameras(CAMERASHAKE.FULL, period, .025, 1.25, inst, 40)
            local fx = SpawnPrefab(shoutfx)
            if not fx.Follower then
                fx.entity:AddFollower()
            end
            fx.Follower:FollowSymbol(inst.GUID, symbol, offset:Get())
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


local SPIKE_SPAWNTIME = 0.25

local function DoSpawnAttackSpike(inst, x, z, level, attack_hit_targets)
    -- local fx = SpawnAt("icespike_fx_"..tostring(math.random(1, 4)),Vector3(x, 0, z))

    local fx = SpawnAt("gale_groundhit_fx", Vector3(x, 0, z), { 1.2, 1.2, 1.2 })
    fx:DoPlayAnim(level, {
        "particle_3",
        "particle_4",
        "innerrock",
    })
    fx.SoundEmitter:PlaySound("gale_sfx/battle/stomp_char" .. tostring(math.random(2, 3)))


    GaleCommon.AoeDestroyWorkableStuff(inst, Vector3(x, 0, z), 1.5, 4)


    local hitted_ents = GaleCommon.AoeDoAttack(inst,
                                               Vector3(x, 0, z),
                                               1.5,
                                               {
                                                   ignorehitrange = true,
                                               },
                                               function(inst, other)
                                                   -- Should not attack shadow creatures,unless they attack me
                                                   if GaleCommon.IsShadowCreature(other) and not (inst.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(inst))) then
                                                       return false
                                                   end
                                                   return not attack_hit_targets[other.GUID]
                                                       and inst.components.combat:CanTarget(other)
                                                       and not inst.components.combat:IsAlly(other)
                                               end
    )
    for k, ent in pairs(hitted_ents) do
        attack_hit_targets[ent.GUID] = true
    end
end


local function SpawnAttackFx(inst)
    local attack_hit_targets = {}
    local AOEarc = 35
    local hitrange = inst.components.combat.hitrange

    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation()

    local num = 3
    for i = 1, num do
        local newarc = 180 - AOEarc
        local theta = inst.Transform:GetRotation() * DEGREES
        local radius = hitrange - ((hitrange / num) * i)
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        inst:DoTaskInTime(math.random() * .25, DoSpawnAttackSpike, x + offset.x, z + offset.z, 1, attack_hit_targets)
    end

    for i = math.random(12, 17), 1, -1 do
        local theta = (angle + math.random(AOEarc * 2) - AOEarc) * DEGREES
        local radius = hitrange * math.sqrt(math.random())
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
        inst:DoTaskInTime(math.random() * SPIKE_SPAWNTIME, DoSpawnAttackSpike, x + offset.x, z + offset.z, 2,
                          attack_hit_targets)
    end

    if inst._check_attack_spikeshit_task ~= nil then
        inst._check_attack_spikeshit_task:Cancel()
    end
    inst._check_attack_spikeshit_task = inst:DoTaskInTime(SPIKE_SPAWNTIME + FRAMES, function()
        local miss_target = true
        for ent, bool in pairs(attack_hit_targets) do
            if bool then
                miss_target = false
                break
            end
        end

        if miss_target then
            inst:PushEvent("onmissother") -- for ChaseAndAttack
        end

        if inst._check_attack_spikeshit_task ~= nil then
            inst._check_attack_spikeshit_task:Cancel()
            inst._check_attack_spikeshit_task = nil
        end
    end)
end

local function BallAttack(inst, pos)
    local proj = SpawnAt("galeboss_errorbot_redball", inst)
    proj.hit_ground = true
    proj.components.complexprojectile.horizontalSpeed = 30
    proj.components.complexprojectile:SetLaunchOffset(Vector3(4, 5.5, 0))
    proj.components.complexprojectile:Launch(pos, inst)
    proj._usetail:set(true)
    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/enm_tp")
end

local function LaunchDarkBall(inst, pos)
    local proj = SpawnAt("galeboss_ruinforce_projectile_dark", inst)
    proj.components.complexprojectile:Launch(pos, inst)
    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/enm_tp")
end





local function LaunchItem(inst, target, item)
    if item.Physics ~= nil and item.Physics:IsActive() then
        local x, y, z = item.Transform:GetWorldPosition()
        item.Physics:Teleport(x, .1, z)

        x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = math.atan2(z1 - z, x1 - x) + (math.random() * 20 - 10) * DEGREES
        local speed = 5 + math.random() * 2
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end

local depart_list = {

}

local function LaunchDepart(inst)
    -- galeboss_ruinforce_depart
end

-- c_findnext("galeboss_ruinforce").sg:GoToState("roar")
-- c_spawn("galeboss_ruinforce").sg:GoToState("roar")

local states = {
    -- roar
    State {
        name = "roar",
        tags = { "busy", },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            inst.sg.statemem.loop_taunt = false
        end,


        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.roar_pre)
            end),


            TimeEvent(15 * FRAMES, function(inst)
                -- local down_pos = galetestmen.down_pos or Vector3(0,0,0)
                inst.SoundEmitter:PlaySound(inst.sounds.roar)
                DoShoutting(inst, {
                    maxtime = 2,
                    period = 3 * FRAMES,
                    offset = inst._beheaded_enable:value() and Vector3(70, 0, 0) or Vector3(0, 80, 0),
                    symbol = inst._beheaded_enable:value() and "deerclops_hand" or "deerclops_head",
                    -- shoutfx = "gale_scream_ring_black_fx",
                    updatefn = function(inst)
                        -- GaleCommon.AoeGetAttacked(inst,inst:GetPosition(),10,GetRandomMinMax(1,2))
                        GaleCommon.AoeForEach(inst, inst:GetPosition(), 10, { "_combat", "_health" }, { "INLIMBO" }, nil,
                                              function(attacker, other)
                                                  if not other:HasTag("epic") then
                                                      GaleCondition.AddCondition(other, "condition_dread", 3)
                                                  end

                                                  other.components.combat:GetAttacked(attacker, GetRandomMinMax(1, 2))
                                              end, function(attacker, other)
                                                  -- Should not attack shadow creatures,unless they attack me
                                                  if GaleCommon.IsShadowCreature(other) and not (inst.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(inst))) then
                                                      return false
                                                  end
                                                  return (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other))
                                              end)
                    end,
                })
            end),

            TimeEvent(30 * FRAMES, function(inst)
                inst.sg.statemem.loop_taunt = true
                if inst.phase == 0 or inst.phase == 1 then
                    inst.phase = inst.phase + 1
                end
                inst:SetMusicLevel(inst.phase + 1)
            end),

            TimeEvent(30 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("taunt")
                inst.AnimState:SetTime(30 * FRAMES)
            end),

            TimeEvent(36 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "taunt", false, 1.2 / 1.734)
            end),

            TimeEvent(42 * FRAMES, function(inst)
                GaleCommon.ClearBackAnimation(inst)
                inst.AnimState:PlayAnimation("taunt")
                inst.AnimState:SetTime(30 * FRAMES)
            end),

            TimeEvent(48 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "taunt", false, 1.2 / 1.734)
            end),

            TimeEvent(54 * FRAMES, function(inst)
                GaleCommon.ClearBackAnimation(inst)
                inst.AnimState:PlayAnimation("taunt")
                inst.AnimState:SetTime(30 * FRAMES)
            end),

            TimeEvent(60 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "taunt", false, 1.2 / 1.734)
            end),

            TimeEvent(66 * FRAMES, function(inst)
                GaleCommon.ClearBackAnimation(inst)
                inst.AnimState:PlayAnimation("taunt")
                inst.AnimState:SetTime(30 * FRAMES)
            end),

            TimeEvent(72 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "taunt", false, 1.2 / 1.734)
            end),

            TimeEvent(78 * FRAMES, function(inst)
                inst.sg.statemem.loop_taunt = false
                GaleCommon.ClearBackAnimation(inst)
                inst.AnimState:PlayAnimation("taunt")
                inst.AnimState:SetTime(30 * FRAMES)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.loop_taunt then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            GaleCommon.ClearBackAnimation(inst)
        end,
    },

    -- c_findnext("galeboss_ruinforce").sg:GoToState("roar2")
    State {
        name = "roar2",
        tags = { "busy", },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("struggle_pre")
            inst.AnimState:PushAnimation("struggle_loop", true)

            inst.sg:SetTimeout(2 + 15 * FRAMES)
        end,

        ontimeout = function(inst)
            -- inst.AnimState:HideSymbol("deerclops_head")
            -- inst:EnableBeHeaded(true)

            inst.AnimState:PlayAnimation("struggle_pst")
        end,


        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.roar_pre)
            end),

            TimeEvent(10 * FRAMES, function(inst)
                -- inst.AnimState:OverrideSymbol("deerclops_head","galeboss_ruinforce_head","deerclops_head")
                -- inst.AnimState:ShowSymbol("deerclops_head")
                -- inst:EnableBeHeaded(false)
            end),


            TimeEvent(15 * FRAMES, function(inst)
                -- local down_pos = galetestmen.down_pos or Vector3(0,0,0)
                inst.SoundEmitter:PlaySound(inst.sounds.roar)
                DoShoutting(inst, {
                    maxtime = 2,
                    period = 3 * FRAMES,
                    offset = Vector3(210, 70, 0),
                    symbol = "deerclops_hand",
                    -- shoutfx = "gale_scream_ring_black_fx",
                    updatefn = function(inst)
                        -- GaleCommon.AoeGetAttacked(inst,inst:GetPosition(),10,GetRandomMinMax(1,2))
                        GaleCommon.AoeForEach(inst, inst:GetPosition(), 10, { "_combat", "_health" }, { "INLIMBO" }, nil,
                                              function(attacker, other)
                                                  if not other:HasTag("epic") then
                                                      GaleCondition.AddCondition(other, "condition_dread", 3)
                                                  end

                                                  other.components.combat:GetAttacked(attacker, GetRandomMinMax(1, 2))
                                              end, function(attacker, other)
                                                  -- Should not attack shadow creatures,unless they attack me
                                                  if GaleCommon.IsShadowCreature(other) and not (inst.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(inst))) then
                                                      return false
                                                  end
                                                  return (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other))
                                              end)
                    end,
                })
            end),

        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:IsCurrentAnimation("struggle_pst") then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            -- inst.AnimState:OverrideSymbol("deerclops_head","galeboss_ruinforce","deerclops_head")
            -- inst.AnimState:HideSymbol("deerclops_head")
            -- inst:EnableBeHeaded(true)
        end,
    },

    State {
        name = "beheaded",
        tags = { "busy", },

        onenter = function(inst)
            inst.Transform:SetNoFaced()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("death")


            inst.sg.statemem.height = 3.5
            inst.dropped_top_head = inst:SpawnChild("galeboss_ruinforce_head_drop_top")
            inst.dropped_top_head.components.highlightchild:SetOwner(inst)

            inst.components.health:SetInvincible(true)

            -- (Nope) Head should drop from Pixel (-299,-292) to (-260,0)
            -- (Nope) Head should drop from Pixel (26,-552) to (-260,0)
        end,


        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                -- inst:SpawnChild("galeboss_explode_fx_start").Transform:SetPosition(0,inst.sg.statemem.height,0)
                local hitfx = SpawnPrefab("galeboss_explode_vfx_shadow_oneshoot")
                hitfx.entity:SetParent(inst.entity)
                hitfx.entity:AddFollower()
                hitfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

                local hitfx2 = SpawnPrefab("gale_fire_explode_vfx")
                hitfx2.entity:SetParent(inst.entity)
                hitfx2.entity:AddFollower()
                hitfx2.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

                inst.AnimState:HideSymbol("deerclops_head")

                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_final_hit")

                ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, 1.5, inst, 40)

                inst:EnableBeheadedSmoke(true)
            end),

            TimeEvent(8 * FRAMES, function(inst)
                inst.AnimState:Pause()
            end),

            TimeEvent(30 * FRAMES, function(inst)
                inst.sg.statemem.loopfx = SpawnPrefab("galeboss_explode_vfx_shadow_loop")
                inst.sg.statemem.loopfx.entity:SetParent(inst.entity)
                inst.sg.statemem.loopfx.entity:AddFollower()
                inst.sg.statemem.loopfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_gushing")
                inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.2, function()
                    ShakeAllCameras(CAMERASHAKE.FULL, .33, .03, 0.5, inst, 40)
                end)
            end),

            TimeEvent(120 * FRAMES, function(inst)
                inst.sg.statemem.loopfx:Remove()
                if inst.sg.statemem.shake_task then
                    inst.sg.statemem.shake_task:Cancel()
                    inst.sg.statemem.shake_task = nil
                end
            end),

            TimeEvent(130 * FRAMES, function(inst)
                inst.AnimState:Resume()
            end),

            TimeEvent(150 * FRAMES, function(inst)
                -- inst:SpawnChild("galeboss_explode_fx_start").Transform:SetPosition(0,inst.sg.statemem.height,0)
                -- inst:SpawnChild("galeboss_explode_fx_final").Transform:SetPosition(0,inst.sg.statemem.height,0)
                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_explode")

                local hitfx = SpawnPrefab("galeboss_explode_vfx_shadow_oneshoot")
                hitfx.entity:SetParent(inst.entity)
                hitfx.entity:AddFollower()
                hitfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

                local hitfx2 = SpawnPrefab("gale_fire_explode_vfx")
                hitfx2.entity:SetParent(inst.entity)
                hitfx2.entity:AddFollower()
                hitfx2.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_explode")

                ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, 1.5, inst, 40)
                TheWorld:PushEvent("screenflash", .5)
                inst:TurnLight(3.5, 4 * FRAMES)
                inst:EnableBeheadedSmoke(false)
            end),



            TimeEvent(172 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.superland)

                local sinkhole = SpawnAt("antlion_sinkhole", inst)
                sinkhole:PushEvent("startrepair", { num_stages = 1, time = 20 })

                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, 40)
            end),


            TimeEvent(380 * FRAMES, function(inst)
                inst:TurnLight(8, 4 * FRAMES)
            end),
            TimeEvent(400 * FRAMES, function(inst)
                GaleCommon.PlayBackAnimation(inst, "death")
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
            end),

            TimeEvent(418 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
                inst:EnableBeheadedSmoke(true)
            end),


            TimeEvent(424 * FRAMES, function(inst)
                local function IsValidTarget(tar)
                    return tar
                        and tar:IsValid()
                        and tar.components.combat
                        and tar.components.health
                        and not tar.components.health:IsDead()
                end
                local revenge_target = nil

                local target = inst.components.combat.target
                if IsValidTarget(target) then
                    revenge_target = target
                end

                if not revenge_target then
                    local lastattacker = inst.components.combat.lastattacker
                    if IsValidTarget(lastattacker) then
                        revenge_target = lastattacker
                    end
                end

                if not revenge_target then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local player = FindClosestPlayerInRange(x, y, z, 40, true)
                    if IsValidTarget(player) then
                        revenge_target = player
                    end
                end

                if revenge_target then
                    inst.components.combat:SuggestTarget(revenge_target)
                end

                inst.sg:GoToState("superjump", {
                    pick_up_head = true,
                    target_pos = revenge_target and revenge_target:GetPosition(),
                })
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            GaleCommon.ClearBackAnimation(inst)
            if inst.sg.statemem.loopfx then
                inst.sg.statemem.loopfx:Remove()
            end
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
            end
            inst.components.health:SetCurrentHealth(3000)
            inst.components.health:SetInvincible(false)
        end,
    },

    -- exploding
    State {
        name = "exploding",
        tags = { "busy", },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_final_hit")

            local hitfx = SpawnPrefab("galeboss_explode_vfx_shadow_oneshoot")
            hitfx.entity:SetParent(inst.entity)
            hitfx.entity:AddFollower()
            hitfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -10, 0.01)

            inst:TurnLight(8, 12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(45 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.death)
                inst.sg.statemem.anim_task = inst:DoPeriodicTask(0.3, function()
                    local rot = math.random() * 2 * PI
                    local rad = math.random() * 2
                    local height = GetRandomMinMax(2, 5)
                    local pos = Vector3(rad * math.cos(rot), height, rad * math.sin(rot))

                    local explo = inst:SpawnChild("gale_bomb_projectile_explode")
                    explo.AnimState:SetScale(0.7, 0.7, 0.7)
                    explo.Transform:SetPosition(pos:Get())
                    explo:SpawnChild("gale_normal_explode_vfx")

                    if not inst.AnimState:IsCurrentAnimation("hit") or inst.AnimState:GetCurrentAnimationTime() >= 8 * FRAMES then
                        inst.AnimState:PlayAnimation("hit")
                    end
                    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)

                    inst.SoundEmitter:PlaySound("gale_sfx/battle/explosion_4_wet_original")
                end)
            end),

            TimeEvent(80 * FRAMES, function(inst)
                inst.sg.statemem.sound_thread = inst:StartThread(function()
                    local period = 0.3
                    local pitch = 0
                    while true do
                        inst.SoundEmitter:PlaySoundWithParams("gale_sfx/battle/galeboss_ruinforce/death_loop",
                                                              { pitch = pitch })

                        period = period + 0.075
                        pitch = pitch + 1 / 11
                        Sleep(period)
                    end
                end)
            end),


            TimeEvent(440 * FRAMES, function(inst)
                if inst.sg.statemem.anim_task then
                    inst.sg.statemem.anim_task:Cancel()
                    inst.sg.statemem.anim_task = nil
                end
            end),


            TimeEvent(476 * FRAMES, function(inst)
                if inst.sg.statemem.anim_task then
                    inst.sg.statemem.anim_task:Cancel()
                    inst.sg.statemem.anim_task = nil
                end
                if inst.sg.statemem.sound_thread then
                    KillThread(inst.sg.statemem.sound_thread)
                    inst.sg.statemem.sound_thread = nil
                end

                -- Do Big Explode here
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/big_explosion")

                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, 40)
                TheWorld:PushEvent("screenflash", .5)

                local hitfx = SpawnPrefab("galeboss_explode_vfx_shadow_oneshoot")
                hitfx.entity:SetParent(inst.entity)
                hitfx.entity:AddFollower()
                hitfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, 0, 0.01)

                -- local start_rot = math.random() * 2 * PI
                -- for i = 1,3 do
                --     local launch_rot = start_rot + (i - 1) * 2 * PI / 3 + UnitRand() * PI / 6
                --     local rad = GetRandomMinMax(10,15)
                --     local offset = Vector3(math.cos(launch_rot),0,math.sin(launch_rot)) * rad

                --     local proj = SpawnAt("galeboss_ruinforce_projectile_dark_paracurve",inst)
                --     proj.components.complexprojectile:SetLaunchOffset(Vector3(0,4,0))
                --     proj.components.complexprojectile:Launch(offset + inst:GetPosition(),inst)
                -- end

                -- for i = 1,10 do
                --     local rot = math.random() * 2 * PI
                --     local rad = math.random()
                --     local offset = Vector3(math.cos(rot),0,math.sin(rot)) * rad
                --     offset.y = GetRandomMinMax(4,9)

                --     local offset_norm = offset:GetNormalized()
                --     offset_norm.y = 0

                --     local item = math.random() < 0.5 and SpawnAt("gears",inst,nil,offset) or SpawnAt("trinket_6",inst,nil,offset)

                --     local speed = offset_norm * GetRandomMinMax(8,10)
                --     speed.y = GetRandomMinMax(6,12)
                --     item.Physics:SetVel(speed.x,speed.y,speed.z)
                -- end


                inst.components.lootdropper:DropLoot(inst:GetPosition() + Vector3(0, 6, 0))

                -- inst.AnimState
                -- inst.sg:GoToState("death")

                inst:EnableBeheadedSmoke(false)

                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(37 * FRAMES)

                inst:TurnLight(0, 4 * FRAMES)
            end),

            -- 476 + 15 FRAMES
            TimeEvent(491 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.superland)

                local sinkhole = SpawnAt("antlion_sinkhole", inst)
                sinkhole:PushEvent("startrepair", { num_stages = 1, time = 20 })

                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, 40)
            end),

            TimeEvent(560 * FRAMES, function(inst)
                inst:SetMusicLevel(4)
            end),

            TimeEvent(800 * FRAMES, function(inst)
                ErodeAway(inst)
            end),
        },
    },

    -- superjump
    State {
        name = "superjump",
        tags = { "busy" },

        onenter = function(inst, data)
            data = data or {}
            inst.Transform:SetNoFaced()

            inst:StopBrain()
            inst.components.locomotor:Stop()
            inst.Physics:Stop()


            for i = 1, 4 do
                inst.AnimState:HideSymbol("ice_spike" .. i)
            end

            inst.AnimState:PlayAnimation("fortresscast_pre")
            inst.AnimState:PushAnimation("fortresscast_loop", true)

            inst.sg.statemem.warning = data.warning
            inst.sg.statemem.target_pos = data.target_pos
            inst.sg.statemem.pick_up_head = data.pick_up_head

            inst.sg:SetTimeout(2.5)
        end,

        ontimeout = function(inst)
            local target = inst.components.combat.target

            local pos = inst.sg.statemem.target_pos or (target or inst):GetPosition()

            if inst.sg.statemem.warning then
                inst.sg:GoToState("superland_warning", {
                    pos = pos,
                    duration = 1.5,
                })
            else
                inst.sg:GoToState("superland", pos)
            end
        end,


        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
            end),

            TimeEvent(18 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.step)
                -- inst.AnimState:Pause()
                ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, 40)



                inst.footprinter:TriggerStep("superjump")

                GaleCommon.AoeDestroyWorkableStuff(inst, nil, 4.5, 10)
                GaleCommon.AoeGetAttacked(inst, nil, 4.5, function()
                    return GetRandomMinMax(75, 125)
                end)

                if inst.sg.statemem.pick_up_head then
                    inst:EnableBeHeaded(true)
                    if inst.dropped_top_head then
                        inst.dropped_top_head:Remove()
                    end
                end
            end),

            TimeEvent(33 * FRAMES, function(inst)
                inst.components.health:SetInvincible(true)
                inst.SoundEmitter:PlaySound(inst.sounds.superjump)
                inst.AnimState:Resume()
                GaleCommon.PlayBackAnimation(inst, "fortresscast_pre", false, 0.5)


                -- inst.AnimState:PlayAnimation("falling_loop",true)

                inst.footprinter:TriggerStep("superland")

                SpawnAt("groundpoundring_fx", inst, { 0.8, 0.8, 0.8 })

                local sinkhole = SpawnAt("antlion_sinkhole", inst)
                sinkhole:PushEvent("startrepair", { num_stages = 1, time = 10 })
                sinkhole.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre2")

                local offsetFn = CreateSphereEmitter(2.5)
                for i = 1, GetRandomMinMax(6, 8) do
                    local offset = Vector3(offsetFn())
                    offset.y = 0
                    local fx = SpawnAt("gale_groundhit_fx", inst, { 1.3, 1.3, 1.3 }, offset)
                    fx:DoPlayAnim(2, {
                        "particle_3",
                        "particle_4",
                        "innerrock",
                    })
                end

                GaleCommon.AoeDestroyWorkableStuff(inst, nil, 4, 5)
                GaleCommon.AoeGetAttacked(inst, nil, 4, function()
                    return GetRandomMinMax(50, 75)
                end)



                inst.Physics:SetMotorVel(0, 36, 0)
                inst.sg.statemem.fly_task = inst:DoPeriodicTask(0, function()
                    inst.Physics:SetMotorVel(0, 36, 0)
                end)
                ShakeAllCameras(CAMERASHAKE.FULL, .6, .03, 1.4, inst, 40)

                inst:TurnLight(0, 12 * FRAMES)
            end),

            TimeEvent(41 * FRAMES, function(inst)
                GaleCommon.ClearBackAnimation(inst)
                inst.AnimState:Pause()

                local target = inst.components.combat.target
                if target and inst.sg.statemem.target_pos == nil then
                    inst.sg.statemem.target_pos = target:GetPosition()
                end
            end),

            TimeEvent(50 * FRAMES, function(inst)
                -- GaleCommon.ClearBackAnimation(inst)
                inst:Hide()
                inst.Physics:Stop()

                if inst.sg.statemem.fly_task then
                    inst.sg.statemem.fly_task:Cancel()
                    inst.sg.statemem.fly_task = nil
                end

                GaleCommon.ToggleOffPhysics(inst)
            end),


        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            inst:Show()
            inst.AnimState:Resume()
            GaleCommon.ClearBackAnimation(inst)
            GaleCommon.ToggleOnPhysics(inst)
            inst.Physics:Stop()
            for i = 1, 4 do
                inst.AnimState:ShowSymbol("ice_spike" .. i)
            end
            inst.components.health:SetInvincible(false)
            if inst.sg.statemem.fly_task then
                inst.sg.statemem.fly_task:Cancel()
                inst.sg.statemem.fly_task = nil
            end
        end,
    },

    -- superland_warning
    State {
        name = "superland_warning",
        tags = { "busy" },

        onenter = function(inst, data)
            inst:Hide()
            inst.Physics:Stop()


            inst.sg.statemem.target_pos = data.pos
            inst.sg.statemem.fx = SpawnAt("galeboss_ruinforce_superjump_warning", data.pos)
            inst.sg.statemem.fx.SoundEmitter:PlaySound(inst.sounds.superland_warning, "superland_warning")


            GaleCommon.ToggleOffPhysics(inst)

            inst.sg:SetTimeout(data.duration or 1.5)
        end,

        ontimeout = function(inst)
            local pos = inst.sg.statemem.target_pos or inst:GetPosition()

            inst.sg:GoToState("superland", pos)
        end,

        onexit = function(inst)
            inst:Show()
            GaleCommon.ToggleOnPhysics(inst)

            if inst.sg.statemem.fx then
                local fx = inst.sg.statemem.fx
                fx:DoTaskInTime(1, function()
                    fx.SoundEmitter:KillSound("superland_warning")
                    fx:KillFX()
                end)
            end

            -- inst.SoundEmitter:KillSound("superland_warning")
        end,
    },

    -- superland
    State {
        name = "superland",
        tags = { "busy" },

        onenter = function(inst, pos)
            inst:TurnLight(8, 45 * FRAMES)

            inst.Transform:SetNoFaced()
            inst:Show()

            inst.Transform:SetPosition(pos.x, 18, pos.z)

            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("falling_loop", true)

            inst.Physics:SetMotorVel(0, -42, 0)

            GaleCommon.ToggleOffPhysics(inst)
        end,

        onupdate = function(inst)
            local x, y, z = inst:GetPosition():Get()

            inst.Physics:SetMotorVel(0, -42, 0)

            if y < 11.2 then
                inst.sg:GoToState("superland_pst")
            end
        end,

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            GaleCommon.ToggleOnPhysics(inst)
        end,
    },

    -- superland_pst
    State {
        name = "superland_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.Transform:SetNoFaced()
            inst.AnimState:PlayAnimation("fallattack")

            inst.Physics:SetMotorVel(0, -42, 0)

            GaleCommon.ToggleOffPhysics(inst)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                local x, y, z = inst:GetPosition():Get()
                inst.Transform:SetPosition(x, 0, z)

                inst.SoundEmitter:PlaySound(inst.sounds.superland)
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .03, 1.3, inst, 40)

                SpawnAt("groundpoundring_fx", inst)

                local sinkhole = SpawnAt("antlion_sinkhole", inst)
                sinkhole:PushEvent("startrepair", { num_stages = 1, time = 20 })

                local offsetFn = CreateSphereEmitter(3)
                for i = 1, GetRandomMinMax(8, 10) do
                    local offset = Vector3(offsetFn())
                    offset.y = 0
                    local fx = SpawnAt("gale_groundhit_fx", inst, { 1.3, 1.3, 1.3 }, offset)
                    fx:DoPlayAnim(2, {
                        "particle_3",
                        "particle_4",
                        "innerrock",
                    })
                end


                inst.footprinter:TriggerStep("superland")

                GaleCommon.ToggleOnPhysics(inst)
                GaleCommon.AoeDestroyWorkableStuff(inst, nil, 5, 20)
                GaleCommon.AoeGetAttacked(inst, nil, 5, function()
                    return GetRandomMinMax(250, 300)
                end)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.phase < 2 then
                    inst.sg:GoToState("roar")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RestartBrain()
            inst.Transform:SetFourFaced()
            GaleCommon.ToggleOnPhysics(inst)
        end,

    },

    -- attack_laser
    -- c_findnext("galeboss_ruinforce").sg:GoToState("attack_laser")
    State {
        name = "attack_laser",
        tags = { "busy", "attack", "abouttoattack" },

        onenter = function(inst, pos_list)
            inst.components.locomotor:Stop()
            inst.Physics:Stop()

            inst.Transform:SetEightFaced()

            inst.AnimState:PlayAnimation("atk2")

            inst.sg.statemem.pos_list = pos_list or {}
            if inst.components.combat.target then
                local targetpos = inst.components.combat.target:GetPosition()

                inst:ForceFacePoint(targetpos:Get())

                if #inst.sg.statemem.pos_list <= 0 then
                    local offsetFn = CreateSphereEmitter(5)
                    table.insert(inst.sg.statemem.pos_list, targetpos)
                    for i = 1, math.random(2, 3) do
                        local offset = Vector3(offsetFn())
                        table.insert(inst.sg.statemem.pos_list, targetpos + offset)
                    end
                end
            end
            -- inst:EnableBeheadedSmoke(false)
        end,



        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/charge")
            end),

            TimeEvent(1 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
            end),

            TimeEvent(4 * FRAMES, function(inst)
                -- RuinforceFootstep(inst)
            end),

            TimeEvent(6 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .2, .02, .5, inst, 40)
            end),

            TimeEvent(19 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/laser")
                if #inst.sg.statemem.pos_list > 0 then
                    local pos = table.remove(inst.sg.statemem.pos_list, 1)
                    LaunchDarkBall(inst, pos)
                end
            end),

            TimeEvent(23 * FRAMES, function(inst)
                if #inst.sg.statemem.pos_list > 0 then
                    local pos = table.remove(inst.sg.statemem.pos_list, 1)
                    LaunchDarkBall(inst, pos)
                end
            end),

            TimeEvent(27 * FRAMES, function(inst)
                if #inst.sg.statemem.pos_list > 0 then
                    local pos = table.remove(inst.sg.statemem.pos_list, 1)
                    LaunchDarkBall(inst, pos)
                end
            end),

            TimeEvent(31 * FRAMES, function(inst)
                for _, pos in pairs(inst.sg.statemem.pos_list) do
                    LaunchDarkBall(inst, pos)
                end
            end),

            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr", nil, .5)
            end),

            TimeEvent(41 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/step", nil, .7)
            end),

            TimeEvent(43 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .3, .02, .7, inst, 40)
                -- inst:EnableBeheadedSmoke(inst.phase == 2)
            end),

        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            -- inst:EnableBeheadedSmoke(inst.phase == 2)
        end,
    },

    -- attack_double
    -- c_findnext("galeboss_ruinforce").sg:GoToState("attack_double")
    State {
        name = "attack_double",
        tags = { "busy", "attack", "abouttoattack" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.Transform:SetEightFaced()

            inst.AnimState:PlayAnimation("uppercut")
            inst.components.combat:StartAttack()

            if inst.components.combat.target then
                local targetpos = inst.components.combat.target:GetPosition()

                inst:ForceFacePoint(targetpos:Get())
            end

            inst.handelec_fx:Enable(0.33)
        end,



        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
                inst.SoundEmitter:PlaySound(inst.sounds.attack2)
                inst.SoundEmitter:PlaySound(inst.sounds.elec_pre)
            end),

            TimeEvent(29 * FRAMES, function(inst)
                if inst.components.combat.target then
                    local targetpos = inst.components.combat.target:GetPosition()
                    inst:ForceFacePoint(targetpos:Get())
                end
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
                inst.SoundEmitter:PlaySound(inst.sounds.elec)
                -- inst.handelec_fx:Enable(0.25)
            end),

            TimeEvent(33 * FRAMES, function(inst)
                GaleCommon.AoeDoAttack(inst,
                                       inst:GetPosition(),
                                       8,
                                       {
                                           ignorehitrange = false,
                                           instancemult = 0.5,
                                           stimuli = "electric",
                                       },
                                       function(inst, other)
                                           -- Should not attack shadow creatures,unless they attack me
                                           if GaleCommon.IsShadowCreature(other) and not (inst.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(inst))) then
                                               return false
                                           end

                                           return inst.components.combat:CanTarget(other)
                                               and not inst.components.combat:IsAlly(other)
                                               and GaleCommon.GetFaceAngle(inst, other) <= 45
                                       end
                )
                local face_vec = GaleCommon.GetFaceVector(inst)
                SpawnAt("lightning", inst, nil, face_vec * 4)

                ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, 40)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
            end),

            TimeEvent(40 * FRAMES, function(inst)
                if inst.components.combat.target then
                    local targetpos = inst.components.combat.target:GetPosition()
                    inst:ForceFacePoint(targetpos:Get())
                end

                local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
                GaleCommon.PlayBackAnimation(inst, "uppercut", false, percent, 1.75)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre1)
                inst.SoundEmitter:PlaySound(inst.sounds.elec)
            end),

            TimeEvent(44 * FRAMES, function(inst)
                if inst.components.combat.target then
                    local targetpos = inst.components.combat.target:GetPosition()

                    inst:ForceFacePoint(targetpos:Get())
                end

                GaleCommon.AoeDoAttack(inst,
                                       inst:GetPosition(),
                                       8,
                                       {
                                           ignorehitrange = false,
                                           instancemult = 0.4,
                                           stimuli = "electric",
                                       },
                                       function(inst, other)
                                           -- Should not attack shadow creatures,unless they attack me
                                           if GaleCommon.IsShadowCreature(other) and not (inst.components.combat:TargetIs(other) or (other.components.combat and other.components.combat:TargetIs(inst))) then
                                               return false
                                           end

                                           return inst.components.combat
                                               and inst.components.combat:CanTarget(other)
                                               and not inst.components.combat:IsAlly(other)
                                               and GaleCommon.GetFaceAngle(inst, other) <= 45
                                       end
                )
                local face_vec = GaleCommon.GetFaceVector(inst)
                SpawnAt("lightning", inst, nil, face_vec * 5)

                ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, 40)
                inst.SoundEmitter:PlaySound(inst.sounds.move_pre2)
            end),


        },

        events =
        {
            EventHandler("onhitother", function(inst, data)
                if data.target ~= nil
                    and data.target.components.inventory ~= nil
                    and not data.target:HasTag("stronggrip") then
                    local equipped_items = {}

                    for k, v in pairs(EQUIPSLOTS) do
                        local item = data.target.components.inventory:GetEquippedItem(v)
                        if item then
                            table.insert(equipped_items, item)
                        end
                    end

                    equipped_items = shuffleArray(equipped_items)

                    for i = 1, math.min(2, #equipped_items) do
                        data.target.components.inventory:DropItem(equipped_items[i])
                        LaunchItem(inst, data.target, equipped_items[i])
                    end

                    SpawnAt("lightning", data.target)
                end
            end),

            EventHandler("back_animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            GaleCommon.ClearBackAnimation(inst)
            inst.Transform:SetFourFaced()
            inst.handelec_fx:Enable(-1)
        end,
    },
}

CommonStates.AddIdle(states)
CommonStates.AddCombatStates(states, {
                                 attacktimeline = {
                                     TimeEvent(0 * FRAMES, function(inst)
                                         inst.SoundEmitter:PlaySound(inst.sounds.attack)
                                         inst.SoundEmitter:PlaySound(inst.sounds.attack2, "attack2")
                                         RuinforceMovePre1(inst)
                                     end),
                                     TimeEvent(4 * FRAMES, function(inst)
                                         -- RuinforceMovePre2(inst)
                                     end),
                                     TimeEvent(29 * FRAMES, function(inst)
                                         inst.SoundEmitter:KillSound("attack2")
                                     end),
                                     TimeEvent(32 * FRAMES, function(inst)
                                         SpawnAttackFx(inst)
                                     end),


                                     TimeEvent(35 * FRAMES, function(inst)
                                         -- inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/swipe")
                                         inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                                         -- inst.components.combat:DoAttack(inst.sg.statemem.target)
                                         if inst.bufferedaction ~= nil and inst.bufferedaction.action == ACTIONS.HAMMER then
                                             inst:PerformBufferedAction()
                                         end
                                         ShakeAllCameras(CAMERASHAKE.FULL, .5, .025, 1.25, inst, 40)
                                     end),
                                     TimeEvent(36 * FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
                                 },

                                 -- deathtimeline = {
                                 --     TimeEvent(0 * FRAMES, function(inst)
                                 --         -- inst.SoundEmitter:PlaySound(inst.sounds.death)
                                 --         inst:EnableBeheadedSmoke(false)
                                 --         inst.AnimState:SetTime(37 * FRAMES)
                                 --     end),
                                 -- },
                             }, {

                             }, {

                             })

CommonStates.AddWalkStates(states, {
    starttimeline =
    {
        TimeEvent(1 * FRAMES, RuinforceMovePre1),
        -- TimeEvent(4 * FRAMES, RuinforceMovePre2),
        TimeEvent(7 * FRAMES, function(inst)
            RuinforceFootstep(inst)
            inst.footprinter:TriggerStep()
        end),
    },
    walktimeline =
    {
        TimeEvent(1 * FRAMES, RuinforceMovePre1),
        -- TimeEvent(4 * FRAMES, RuinforceMovePre2),
        TimeEvent(25 * FRAMES, function(inst)
            RuinforceFootstep(inst)
            inst.footprinter:TriggerStep()
        end),

        TimeEvent(26 * FRAMES, RuinforceMovePre1),
        -- TimeEvent(30 * FRAMES, RuinforceMovePre2),
        TimeEvent(44 * FRAMES, function(inst)
            RuinforceFootstep(inst)
            inst.footprinter:TriggerStep()
        end),
    },
    endtimeline =
    {
        TimeEvent(1 * FRAMES, RuinforceMovePre1),
        TimeEvent(5 * FRAMES, function(inst)
            RuinforceFootstep(inst)
            inst.footprinter:TriggerStep()
        end),
    },
})

return StateGraph("SGgaleboss_ruinforce", states, events, "idle", actionhandlers)
