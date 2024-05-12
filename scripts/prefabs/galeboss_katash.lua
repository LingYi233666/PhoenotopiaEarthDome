local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM", "anim/galeboss_katash.zip"),
}

SetSharedLootTable("galeboss_katash", {
    { "gale_blaster_katash_blueprint",   1.00 },
    { "gale_blaster_katash_blueprint",   1.00 },
    { "galeboss_katash_blade_blueprint", 1.00 },
    { "galeboss_katash_blade_blueprint", 1.00 },
})




local function SelectTargetFn(inst)
    return FindEntity(inst, 20,
                      function(guy)
                          return guy ~= inst
                              and inst.components.combat:CanTarget(guy)
                              and (
                                  guy.components.combat:TargetIs(inst)
                                  or inst:IsNear(guy, 15)
                              )
                      end,
                      { "_combat", "_health" },
                      { "INLIMBO" }
    )
end

local function KeepTargetFn(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and inst:IsNear(target, 35)
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil

    if attacker ~= nil then
        inst.components.combat:SetTarget(attacker)
    end
end

local function OnDeath(inst)
    inst:EnableStunFX(false)
end

local function OnTimerDone(inst, data)
    if data.name == "stun" then
        inst:EnableStunFX(false)
    end
end

-- Begin of attack and skills
local function LaunchFanProjectiles(inst, target_pos)
    inst.last_shoot_scale = inst.last_shoot_scale or 1

    inst:ForceFacePoint(target_pos)

    local inst_pos = inst:GetPosition()

    local face_vec = (target_pos - inst_pos):GetNormalized()
    local cross_vec = face_vec:Cross(Vector3(0, 1, 0)):GetNormalized()

    SpawnAt("gale_hand_shoot_fx", inst).Transform:SetRotation(inst.Transform:GetRotation())

    inst.SoundEmitter:PlaySound(inst.sounds.shoot)
    local thread = inst:StartThread(function()
        local start_angle = -45 / 2 * inst.last_shoot_scale
        local stop_angle = 45 / 2 * inst.last_shoot_scale
        local delta = (math.abs(start_angle) + math.abs(stop_angle)) / 4 * inst.last_shoot_scale
        for i = start_angle, stop_angle, delta do
            local tar_pos = inst_pos + face_vec + cross_vec * math.tan(i * DEGREES)
            local proj = SpawnAt("gale_blaster_katash_projectile", inst)

            -- proj.surge_count = inst.components.gale_blaster_charge:GetSurge()
            proj.components.complexprojectile:Launch(tar_pos, inst)
            proj:Hide()
            Sleep(0)
        end
        inst.last_shoot_scale = -inst.last_shoot_scale
    end)

    return thread
end

local function LaunchBigProjectiles(inst, target_pos)
    inst:ForceFacePoint(target_pos)

    local proj = SpawnAt("gale_blaster_katash_projectile_super", inst)

    proj.bonus_damage = 50
    proj.components.complexprojectile:Launch(target_pos, inst)
    proj:Hide()

    inst.SoundEmitter:PlaySound(inst.sounds.shoot_bigball)

    SpawnAt("gale_hand_shoot_fx", inst).Transform:SetRotation(inst.Transform:GetRotation())
end


local function CreateSpinTask(inst)
    local flag = GetRandomItem({ -1, 1 })

    local task = inst:StartThread(function()
        local midpos = inst:GetPosition()
        local cur_deg = math.random(360)
        local shoot_deg = math.random(360)
        local tar_dist = 15
        local last_shoot_time = GetTime()
        local target = inst.components.combat.target
        if target then
            -- cur_deg = GaleCommon.GetFaceAngle(target, inst)
            -- shoot_deg = -GaleCommon.GetFaceAngle(inst, target)
            -- cur_deg = inst:GetAngleToPoint(target:GetPosition()) + 180
            local dp = target:GetPosition() - inst:GetPosition()
            cur_deg = math.atan2(dp.z, dp.x) * RADIANS + 180
            shoot_deg = math.atan2(dp.z, dp.x) * RADIANS
            tar_dist = math.clamp(math.sqrt(inst:GetDistanceSqToInst(target)), 5, 15)
        end




        while true do
            target = inst.components.combat.target
            if target and target:IsValid() then
                midpos = target:GetPosition()
            else
                inst.components.combat:TryRetarget()
                target = inst.components.combat.target


                if target then
                    tar_dist = math.clamp(math.sqrt(inst:GetDistanceSqToInst(target)), 5, 15)
                end
            end


            local target_offset = Vector3(math.cos(cur_deg * DEGREES), 0, math.sin(cur_deg * DEGREES)) * tar_dist
            local target_pos = midpos + target_offset
            local cur_dist = (midpos - inst:GetPosition()):Length()

            if cur_dist <= tar_dist then
                tar_dist = math.max(tar_dist - 5 * FRAMES, 5)
            end

            cur_deg = cur_deg + 90 * FRAMES * flag

            -- SpawnAt("gale_weaponsparks",inst).AnimState:PlayAnimation("hit_3")
            inst:ForceFacePoint(target_pos)
            if (target_pos - inst:GetPosition()):Length() <= 4 then
                inst.Physics:SetMotorVel(6, 0, 0)
            else
                inst.Physics:SetMotorVel(20, 0, 0)
            end


            if GetTime() - last_shoot_time >= 3 * FRAMES then
                local offset = Vector3(math.cos(shoot_deg * DEGREES), 0, math.sin(shoot_deg * DEGREES))
                local proj = SpawnAt("gale_blaster_katash_projectile", inst)

                -- proj.surge_count = inst.components.gale_blaster_charge:GetSurge()
                proj.components.complexprojectile:Launch(inst:GetPosition() + offset, inst)
                proj:Hide()

                inst.SoundEmitter:PlaySound(inst.sounds.shoot2)

                shoot_deg = shoot_deg + flag * 30

                last_shoot_time = GetTime()
            end


            Sleep(0)
        end
    end)

    return task
end

local function EnableStunFX(inst, enable)
    local duration = 0.33

    if enable and not inst.stun_fx then
        inst.stun_fx = inst:SpawnChild("gale_stunned_loop_fx")
        inst.stun_fx.Follower:FollowSymbol(inst.GUID, "headbase", 0, 50, 0)
        GaleCommon.FadeTo(inst.stun_fx, duration, nil, {
            Vector4(0, 0, 0, 0),
            Vector4(1, 1, 1, 1),
        })
    elseif not enable and inst.stun_fx then
        local fx = inst.stun_fx
        GaleCommon.FadeTo(fx, duration, nil, {
                              Vector4(1, 1, 1, 1),
                              Vector4(0, 0, 0, 0),
                          }, nil, function()
                              fx:Remove()
                          end)
        fx:DoTaskInTime(duration, fx.Remove)
        inst.stun_fx = nil
    end
end

local function CreateTeleportTask(inst, pos, duration, callback)
    local cur_time = FRAMES
    local ori_pos = inst:GetPosition()
    local dp = pos - ori_pos
    local flag = true

    return inst:DoPeriodicTask(0, function()
        if not flag then
            return
        end

        if cur_time >= duration then
            flag = false
        end

        local pos_list = {}
        local cur_pos = inst:GetPosition()
        local new_pos = ori_pos + dp * Remap(cur_time, 0, duration, 0, 1)

        local delta_pos = new_pos - cur_pos
        local delta_pos_norm = delta_pos:GetNormalized()
        local dist = delta_pos:Length()

        for i = 0, dist, 0.5 do
            table.insert(pos_list, cur_pos + delta_pos_norm * i)
        end
        table.insert(pos_list, new_pos)

        for _, pt in pairs(pos_list) do
            inst.Transform:SetPosition(pt:Get())
            local percent = (pt - ori_pos):Length() / dp:Length()
            if callback then
                local feedback = callback(inst, percent)
                if feedback == false then
                    flag = false
                    return
                end
            end
        end

        cur_time = math.min(cur_time + FRAMES, duration)
    end)
end

local function GenerateDashPosList(inst, target)
    local mypos = inst:GetPosition()
    local targetpos = target:GetPosition()
    local distsq_thres = 8 * 8
    local offset = FindWalkableOffset(targetpos, math.random() * TWOPI, 7, 66, nil, false, function(pp)
                                          if (pp - mypos):LengthSq() < distsq_thres then
                                              return false
                                          end



                                          if TheWorld.Map:IsOceanAtPoint(pp.x, 0, pp.z, true) then
                                              return false
                                          end

                                          local cur_offset = pp - targetpos

                                          local p2 = targetpos - cur_offset

                                          if TheWorld.Map:IsOceanAtPoint(p2.x, 0, p2.z, true) then
                                              return false
                                          end

                                          return true
                                      end, false, true)

    if offset == nil then
        return
    end

    local start_pos = targetpos + offset
    local final_pos = targetpos - offset

    return start_pos, final_pos
end

local function AOEAttackAndStealFood(inst, radius, damage, ignore_victims, stealing)
    local steal_food_victim_tab = {}
    local function TempCallback(_, data)
        if data.redirected == nil
            and data.target.components.inventory then
            local steal_foods = data.target.components.inventory:FindItems(function(item)
                return not item:HasTag("nosteal") and inst.components.eater:CanEat(item)
            end)

            table.sort(steal_foods, function(a, b)
                return a.components.edible:GetHealth(inst) > b.components.edible:GetHealth(inst)
                    or a.components.edible:GetSanity(inst) > b.components.edible:GetSanity(inst)
                    or a.components.edible:GetHunger(inst) > b.components.edible:GetHunger(inst)
            end)

            if steal_foods and #steal_foods > 0 then
                table.insert(steal_food_victim_tab, {
                    data.target, steal_foods[1]
                })
            end
        end
    end

    if stealing then
        inst:ListenForEvent("onhitother", TempCallback)
    end

    local targets = GaleCommon.AoeGetAttacked(inst, inst:GetPosition(), radius, damage,
                                              function(inst, other)
                                                  return inst.components.combat and
                                                      inst.components.combat:CanTarget(other) and
                                                      not inst.components.combat:IsAlly(other) and
                                                      ignore_victims[other] == nil
                                              end)

    if stealing then
        inst:RemoveEventCallback("onhitother", TempCallback)
    end

    -- print("len steal_food_victim_tab =",#steal_food_victim_tab)
    for _, v in pairs(steal_food_victim_tab) do
        if table.contains(targets, v[1]) then
            return targets, v[1], v[2]
        end
    end

    return targets
end

local function EnableBladeAnim(inst, enable)
    if inst.swapanim_ent and inst.swapanim_ent:IsValid() then
        inst.swapanim_ent:Remove()
    end
    inst.swapanim_ent = nil

    if enable then
        inst.AnimState:ClearOverrideSymbol("swap_object")

        inst.swapanim_ent = inst:SpawnChild("galeboss_katash_blade_swapanims")
        inst.swapanim_ent.entity:AddFollower()
        inst.swapanim_ent.Follower:FollowSymbol(inst.GUID, "swap_object", nil, nil, nil, true, nil, 0, 8)
        inst.swapanim_ent.components.highlightchild:SetOwner(inst)
        if inst.components.colouradder ~= nil then
            inst.components.colouradder:AttachChild(inst.swapanim_ent)
        end
    else
        inst.AnimState:OverrideSymbol("swap_object", "swap_gale_blaster_katash", "swap_gale_blaster_katash")
    end
end


-- End of attack and skills


local function OnLoad(inst, data)
    inst:SetMusicLevel(2)
end

local function KatashClientFn(inst)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.5, .75)

    MakeCharacterPhysics(inst, 50, .5)

    inst.Transform:SetFourFaced()

    -- inst.AnimState:AddOverrideBuild("player_pistol")
    -- inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")


    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:OverrideSymbol("swap_object", "swap_gale_blaster_katash", "swap_gale_blaster_katash")

    -- inst.AnimState:Hide("ARM_carry")
    -- inst.AnimState:Show("ARM_normal")

    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    GaleCommon.AddEpicBGM(inst, "galeboss_katash")


    -------------------------------------------------------------------------
    inst:AddComponent("talker")
    -- inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT
    -- inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
    -- inst.components.talker.offset = Vector3(0, -700, 0)
    -- inst.components.talker.symbol = "fossil_chest"
    inst.components.talker:MakeChatter()

    inst:AddComponent("npc_talker")

    inst:AddComponent("frostybreather")
    inst.components.frostybreather:SetOffset(0.3, 1.15, 0)
end

local function KatashServerFn(inst)
    inst.LaunchFanProjectiles = LaunchFanProjectiles
    inst.LaunchBigProjectiles = LaunchBigProjectiles
    inst.CreateSpinTask = CreateSpinTask
    inst.EnableStunFX = EnableStunFX
    inst.CreateTeleportTask = CreateTeleportTask
    inst.GenerateDashPosList = GenerateDashPosList
    inst.AOEAttackAndStealFood = AOEAttackAndStealFood
    inst.EnableBladeAnim = EnableBladeAnim

    inst.OnLoad = OnLoad



    inst:AddComponent("timer")

    inst:AddComponent("knownlocations")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(2250)
    inst.components.health:SetMinHealth(1)

    inst:AddComponent("combat")
    -- inst.components.combat.playerdamagepercent = 0.5
    inst.components.combat:SetRange(15)
    inst.components.combat:SetDefaultDamage(20)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(1, SelectTargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)


    inst:AddComponent("eater")
    inst.components.eater:SetAbsorptionModifiers(3, 1, 1)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("galeboss_katash")


    inst:SetStateGraph("SGgaleboss_katash")

    local brain = require("brains/galeboss_katashbrain")
    inst:SetBrain(brain)

    inst.sounds = {
        teleport = "gale_sfx/battle/galeboss_katash/teleport",
        talk = "gale_sfx/battle/galeboss_katash/hurt",
        hit = "gale_sfx/battle/galeboss_katash/hurt",
        shoot = "gale_sfx/battle/kobold_shotty",
        shoot_bigball = "gale_sfx/battle/p1_katash_gun2",
        shoot2 = "gale_sfx/battle/p1_katash_gun",
        dash_pre = "gale_sfx/battle/galeboss_katash/unsheathe",
        dash = "gale_sfx/battle/galeboss_katash/slash",
        laugh = "gale_sfx/battle/galeboss_katash/laugh",
        laugh_echo = "gale_sfx/battle/galeboss_katash/laugh_echo",
        eat_good = "gale_sfx/battle/galeboss_katash/good_food",
        eat_bad = "gale_sfx/battle/galeboss_katash/bad_food",
        defeat = "gale_sfx/battle/galeboss_defeat/boss_explode_clean",
        superjump = "gale_sfx/battle/galeboss_errorbot/teleport",
    }

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("timerdone", OnTimerDone)
end


return GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_katash",
        assets = assets,

        bank = "wilson",
        build = "galeboss_katash",
        anim = "idle",

        tags = { "epic", "hostile", "character", "scarytoprey" },

        clientfn = KatashClientFn,
        serverfn = KatashServerFn,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "galeboss_katash_shadow",

        assets = assets,
        bank = "wilson",
        build = "galeboss_katash",

        animover_remove = false,

        lightoverride = 1,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.Transform:SetFourFaced()

            -- inst.AnimState:AddOverrideBuild("player_pistol")
            -- inst.AnimState:AddOverrideBuild("player_actions_roll")
            inst.AnimState:AddOverrideBuild("player_lunge")
            inst.AnimState:AddOverrideBuild("player_attack_leap")
            inst.AnimState:AddOverrideBuild("player_superjump")
            inst.AnimState:AddOverrideBuild("player_multithrust")
            inst.AnimState:AddOverrideBuild("player_parryblock")


            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", "swap_gale_blaster_katash", "swap_gale_blaster_katash")

            inst.AnimState:Show("HEAD")
            inst.AnimState:Hide("HEAD_HAT")
        end,
    })
