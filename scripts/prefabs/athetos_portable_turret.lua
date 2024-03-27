local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local Rectangle = require("util/rectangle")

local PIDController = require("util/pid_controller")

local brain = require("brains.athetos_portable_turret_brain")

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



local function CheckClientSideRotation(inst)
    if TheCamera == nil or ThePlayer == nil then
        return
    end

    local rotation = inst:GetRotation()
    -- local rotation = inst._rotation:value()
    local camera_angle = TheCamera:GetHeadingTarget()



    local anim_rotation = -rotation - camera_angle - 90
    -- local anim_rotation = camera_angle - 90 - rotation

    -- if anim_rotation > 360 then
    --     local seg = math.floor(anim_rotation / 360)
    --     anim_rotation = anim_rotation - seg * 360
    -- end

    -- if anim_rotation < 0 then
    --     local seg = math.ceil(-anim_rotation / 360)
    --     anim_rotation = anim_rotation + seg * 360
    -- end

    anim_rotation = SuitDegree(anim_rotation)

    -- if anim_rotation > 360 then
    --     anim_rotation = anim_rotation - 360
    -- end

    -- if anim_rotation < 0 then
    --     anim_rotation = anim_rotation + 360
    -- end

    local dist = 12

    inst.laser_line._offset_x:set(math.cos(-rotation * DEGREES) * dist)
    inst.laser_line._offset_z:set(math.sin(-rotation * DEGREES) * dist)

    if anim_rotation >= 0 and anim_rotation < 180 then
        -- inst.AnimState:SetPercent("upward",anim_rotation / 180)
        inst.eye_down:Hide()
        inst.eye_up:Show()
        inst.eye_up.AnimState:SetPercent("upward", anim_rotation / 180)

        inst.laser_line.Follower:FollowSymbol(inst.eye_up.GUID, "eye", 0, 0, -0.02)

        inst.eye = "up"
    elseif anim_rotation >= 180 and anim_rotation < 360 then
        -- inst.AnimState:SetPercent("downward",(anim_rotation - 180) / 180)
        inst.eye_up:Hide()
        inst.eye_down:Show()
        inst.eye_down.AnimState:SetPercent("downward", (anim_rotation - 180) / 180)

        inst.laser_line.Follower:FollowSymbol(inst.eye_down.GUID, "eye", 0, 0, 0.02)

        inst.eye = "down"
    end


    -- print("My rotation =",rotation,"camera_angle =",camera_angle,"anim_rotation =",anim_rotation)
end

local function CreateLockToTargetTask(inst, callback)
    return inst:DoPeriodicTask(0, function()
        -- local target = inst.components.combat.target or inst.scan_target

        if inst.target_pos == nil then
            return
        end

        local myrotation = inst:GetRotation()
        local tarrotation = inst:GetAngleToPoint(inst.target_pos)
        local delta_rotation = SuitDegree(tarrotation - myrotation)

        if delta_rotation > 180 then
            delta_rotation = delta_rotation - 360
        elseif delta_rotation < -180 then
            delta_rotation = delta_rotation + 360
        end

        if math.abs(delta_rotation) < 1 then
            inst.rotate_speed = 0
            inst.Transform:SetRotation(tarrotation)
        else
            -- local mspeed = inst.max_rotate_speed
            -- inst.rotate_speed = math.clamp(inst.pid_controller:Output(delta_rotation),-mspeed,mspeed)
            inst.rotate_speed = inst.pid_controller:Output(delta_rotation)

            inst.Transform:SetRotation(inst.Transform:GetRotation() + inst.rotate_speed * FRAMES)
        end

        local delta_degree = SuitDegree(tarrotation - inst:GetRotation())

        -- Play turn sfx
        if delta_degree > 1 and delta_degree < 359 then
            if not inst.SoundEmitter:PlayingSound("turn_loop") then
                inst.SoundEmitter:PlaySound(inst.sounds.turn, "turn_loop")
            end
        else
            if inst.SoundEmitter:PlayingSound("turn_loop") then
                inst.SoundEmitter:KillSound("turn_loop")
            end
        end

        if callback then
            callback(inst, delta_degree)
        end
    end)
end

local function DoTalkSound(inst, dtype)
    if inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:KillSound("talk")
    end
    inst.SoundEmitter:PlaySound(inst.sounds["talk_" .. dtype], "talk")
end



local function SelectTarget(inst)
    local x, y, z = inst:GetPosition():Get()
    local ents = TheSim:FindEntities(x, y, z, 15, { "_combat", "_health" }, { "playerghost" })

    local scan_target, attack_target, other_turrets = nil, nil, {}

    for k, v in pairs(ents) do
        if v ~= inst and v.prefab == inst.prefab then
            table.insert(other_turrets, v)
        end
        if v ~= inst and v.prefab ~= inst.prefab and not IsEntityDead(v) then
            if inst.components.combat:CanTarget(v) and not inst.components.combat:IsAlly(v) then
                if GaleCommon.IsTyphonTarget(v) then
                    attack_target = v
                elseif not v:HasTag("player") then
                    if v.components.combat:TargetIs(inst) then
                        attack_target = v
                    elseif v.components.combat.target
                        and v.components.combat.target:HasTag("player")
                        and not GaleCommon.IsTyphonTarget(v.components.combat.target) then
                        attack_target = v
                    elseif v:HasTag("monster") or v:HasTag("hostile") then
                        attack_target = v
                    else
                        for _, player in pairs(AllPlayers) do
                            if player.components.combat:TargetIs(v) then
                                attack_target = v
                            end
                        end
                    end
                end
            end

            if attack_target then
                break
            end

            if v:HasTag("player") and inst.scaned_targets[v] == nil then
                local old_typhon_num = -1
                local new_typhon_num = 0
                if scan_target and scan_target.components.gale_skiller then
                    old_typhon_num = scan_target.components.gale_skiller:GetTyphonSkillNum()
                end

                if v.components.gale_skiller then
                    new_typhon_num = v.components.gale_skiller:GetTyphonSkillNum()
                end

                if new_typhon_num > old_typhon_num then
                    scan_target = v
                end
            end
        end
    end



    return scan_target, attack_target, other_turrets
end

local function DoFireFX(inst)
    local fx = GaleEntity.CreateClientAnim({
        bank = "deer_fire_charge",
        build = "deer_fire_charge",
        anim = "blast",
        lightoverride = 1,
    })
    fx.AnimState:SetScale(0.25, 0.25, 0.25)
    fx:ListenForEvent("animover", fx.Remove)
    fx.entity:AddFollower()

    if inst.eye == "up" then
        fx.Follower:FollowSymbol(inst.eye_up.GUID, "eye", 0, 0, -0.02)
    elseif inst.eye == "down" then
        fx.Follower:FollowSymbol(inst.eye_down.GUID, "eye", 0, 0, 0.02)
    end
end

local function CalcSanityAura(inst)
    return (inst.sg:HasStateTag("sing") and TUNING.SANITYAURA_LARGE) or 0
end

local function OnDismantle(inst)
    local function callback(it)
        if it.AnimState:IsCurrentAnimation("change_to_item") then
            SpawnAt("small_puff", it)
            it.AnimState:PlayAnimation("item")
            it.components.inventoryitem.canbepickedup = true
            it:RemoveEventCallback("animover", callback)
        end
    end
    local item = SpawnAt("athetos_portable_turret_item", inst)
    item.AnimState:PlayAnimation("change_to_item")
    item:ListenForEvent("animover", callback)
    item.components.inventoryitem.canbepickedup = false

    item.components.finiteuses:SetPercent(inst.components.health:GetPercent())
    if inst.components.timer:TimerExists("sing_cooldown") then
        item.components.timer:StartTimer("sing_cooldown", inst.components.timer:GetTimeLeft("sing_cooldown"))
    end
    inst:Remove()
end

local function ProjectileGetDamageFn(inst, attacker, target)
    local min_damage = 30
    local max_damage = 42
    local min_dist = 5
    local max_dist = 10

    local dist = (inst:GetPosition() - inst.start_pos):Length()

    if dist <= min_dist then
        return max_damage
    elseif dist <= max_dist then
        return Remap(dist, min_dist, max_dist, max_damage, min_damage)
    else
        return min_damage
    end
end

local function ProjectileOnUpdate(inst)
    inst.max_range = inst.max_range or 15
    inst.start_pos = inst.start_pos or inst:GetPosition()

    local dist_moved = (inst:GetPosition() - inst.start_pos):Length()
    if dist_moved >= inst.max_range then
        inst.components.complexprojectile:Hit()
        return true
    else
        if dist_moved >= 0.66 then
            inst:Show()
        else
            inst:Hide()
        end
    end

    if inst.entity:IsVisible() and not inst.tail then
        inst.tail = inst:SpawnChild("msf_ammo_9mm_pistol_projectile_tail_vfx")
        inst.tail.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
    end

    if inst.entity:IsVisible() and not inst.arrow then
        inst.arrow = inst:SpawnChild("msf_ammo_9mm_pistol_projectile_arrow")
        inst.arrow.entity:AddFollower()
        inst.arrow.Follower:FollowSymbol(inst.GUID, "glow", 0, 0, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


    local attacker = inst.components.complexprojectile.attacker
    if not (attacker and attacker:IsValid() and not IsEntityDead(attacker)) then
        inst.components.complexprojectile:Hit()
    else
        local x, y, z = inst.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x, y, z, 1.5, { "_combat", "_health" }, { "INLIMBO" })
        for k, v in pairs(ents) do
            if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
                local tx, ty, tz = inst.entity:WorldToLocalSpace(v:GetPosition():Get())
                -- local tar_pos = Vector3(tx,ty,tz)
                -- local dist = math.max(0.001,tar_pos:Length() - v:GetPhysicsRadius(0))

                -- tx,ty,tz = (tar_pos:GetNormalized() * dist):Get()

                if tx >= -0.4 and tz >= -0.66 and tz <= 0.66 then
                    inst.components.complexprojectile:Hit(v)
                    break
                end
            end
        end
    end


    return true
end

local function ProjectileOnHit(inst, attacker, target)
    if target and attacker and attacker:IsValid() and attacker.components.combat then
        attacker.components.combat:DoAttack(target, inst, inst, nil, nil, 99999)
    end

    SpawnAt("gale_hit_spark_yellow_fx", inst)

    inst:Remove()
end


local colour_index_map = {
    -- normal is green
    { 0, 1, 0, 1 },

    -- warning is yellow
    { 1, 1, 0, 1 },

    -- attack is red
    { 1, 0, 0, 1 },

    -- deploy is empty
    { 0, 0, 0, 0 },
}

local function OnTurretDeploy(inst, pt)
    local turret = SpawnAt("athetos_portable_turret", pt)
    turret.sg:GoToState("deploy")
    turret.components.health:SetPercent(inst.components.finiteuses:GetPercent())
    turret.Physics:SetCollides(false)
    turret.Physics:Teleport(pt.x, 0, pt.z)
    turret.Physics:SetCollides(true)
    turret.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
    if inst.components.timer:TimerExists("sing_cooldown") then
        turret.components.timer:StartTimer("sing_cooldown", inst.components.timer:GetTimeLeft("sing_cooldown"))
    end
    inst:Remove()
end

local function TurretCommonClientFn(inst)
    MakeSmallObstaclePhysics(inst, 0.3, 0.5)

    inst.Transform:SetScale(1.15, 1.15, 1.15)


    inst._client_fire_event = net_event(inst.GUID, "clientfiredirty")
    inst._client_eye_colour = net_tinybyte(inst.GUID, "inst._client_eye_colour", "eyecolourdirty")

    if not TheNet:IsDedicated() then
        inst.eye_up = GaleEntity.CreateClientAnim({
            bank = "athetos_portable_turret",
            build = "athetos_portable_turret",
        })

        inst.eye_up:AddComponent("highlightchild")
        inst.eye_up.components.highlightchild:SetOwner(inst)

        inst.eye_up.AnimState:HideSymbol("main")
        inst.eye_up.AnimState:SetLightOverride(1)

        inst.eye_up.entity:AddFollower()
        inst.eye_up.Follower:FollowSymbol(inst.GUID, "main_up", nil, nil, nil, true)

        inst:AddChild(inst.eye_up)

        ------------------------------------------------------------------------------

        inst.eye_down = GaleEntity.CreateClientAnim({
            bank = "athetos_portable_turret",
            build = "athetos_portable_turret",
        })

        inst.eye_down:AddComponent("highlightchild")
        inst.eye_down.components.highlightchild:SetOwner(inst)

        inst.eye_down.AnimState:HideSymbol("main")
        inst.eye_down.AnimState:SetLightOverride(1)

        inst.eye_down.entity:AddFollower()
        inst.eye_down.Follower:FollowSymbol(inst.GUID, "main", nil, nil, nil, true)

        inst:AddChild(inst.eye_down)


        ------------------------------------------------------------------------------

        inst.laser_line = inst:SpawnChild("athetos_portable_turret_lines_vfx")
        inst.laser_line.entity:AddFollower()

        ------------------------------------------------------------------------------

        inst._check_rotation_task = inst:DoPeriodicTask(0, CheckClientSideRotation)
        inst:ListenForEvent("clientfiredirty", DoFireFX)
        inst:ListenForEvent("eyecolourdirty", function()
            local val = inst._client_eye_colour:value()
            if val and colour_index_map[val] ~= nil then
                if val == 4 then
                    -- inst.eye_down:Hide()
                    -- inst.eye_up:Hide()
                    inst.laser_line:Hide()
                else
                    -- inst.eye_down:Show()
                    -- inst.eye_up:Show()
                    inst.laser_line:Show()
                end

                inst.eye_down.AnimState:SetAddColour(
                    colour_index_map[val][1],
                    colour_index_map[val][2],
                    colour_index_map[val][3],
                    colour_index_map[val][4]
                )

                inst.eye_up.AnimState:SetAddColour(
                    colour_index_map[val][1],
                    colour_index_map[val][2],
                    colour_index_map[val][3],
                    colour_index_map[val][4]
                )

                inst.laser_line:SetColourIndex(val)
            end
        end)
    end
end

local function TurretCommonServerFn(inst)

end

return GaleEntity.CreateNormalEntity({
        prefabname = "athetos_portable_turret",
        assets = {
            Asset("ANIM", "anim/athetos_portable_turret.zip"),
        },

        bank = "athetos_portable_turret",
        build = "athetos_portable_turret",
        anim = "idle",

        tags = { "crazy", "athetos_portable_turret" },

        clientfn = function(inst)
            MakeSmallObstaclePhysics(inst, 0.3, 0.5)

            inst.Transform:SetScale(1.15, 1.15, 1.15)


            inst._client_fire_event = net_event(inst.GUID, "clientfiredirty")
            inst._client_death_event = net_event(inst.GUID, "client_death")
            inst._client_eye_colour = net_tinybyte(inst.GUID, "inst._client_eye_colour", "eyecolourdirty")

            if not TheNet:IsDedicated() then
                inst.eye_up = GaleEntity.CreateClientAnim({
                    bank = "athetos_portable_turret",
                    build = "athetos_portable_turret",
                })

                inst.eye_up:AddComponent("highlightchild")
                inst.eye_up.components.highlightchild:SetOwner(inst)

                inst.eye_up.AnimState:HideSymbol("main")
                inst.eye_up.AnimState:SetLightOverride(1)

                inst.eye_up.entity:AddFollower()
                inst.eye_up.Follower:FollowSymbol(inst.GUID, "main_up", nil, nil, nil, true)

                -- inst.eye_up.AnimState:SetFinalOffset(-1)

                inst:AddChild(inst.eye_up)

                ------------------------------------------------------------------------------

                inst.eye_down = GaleEntity.CreateClientAnim({
                    bank = "athetos_portable_turret",
                    build = "athetos_portable_turret",
                })

                inst.eye_down:AddComponent("highlightchild")
                inst.eye_down.components.highlightchild:SetOwner(inst)

                inst.eye_down.AnimState:HideSymbol("main")
                inst.eye_down.AnimState:SetLightOverride(1)

                inst.eye_down.entity:AddFollower()
                inst.eye_down.Follower:FollowSymbol(inst.GUID, "main", nil, nil, nil, true)

                inst:AddChild(inst.eye_down)



                ------------------------------------------------------------------------------

                inst.laser_line = inst:SpawnChild("athetos_portable_turret_lines_vfx")
                inst.laser_line.entity:AddFollower()

                ------------------------------------------------------------------------------

                inst._check_rotation_task = inst:DoPeriodicTask(0, CheckClientSideRotation)
                inst:ListenForEvent("clientfiredirty", DoFireFX)
                inst:ListenForEvent("eyecolourdirty", function()
                    local val = inst._client_eye_colour:value()
                    if val and colour_index_map[val] ~= nil then
                        if val == 4 then
                            -- inst.eye_down:Hide()
                            -- inst.eye_up:Hide()
                            inst.laser_line:Hide()
                        else
                            -- inst.eye_down:Show()
                            -- inst.eye_up:Show()
                            inst.laser_line:Show()
                        end

                        inst.eye_down.AnimState:SetAddColour(
                            colour_index_map[val][1],
                            colour_index_map[val][2],
                            colour_index_map[val][3],
                            colour_index_map[val][4]
                        )

                        inst.eye_up.AnimState:SetAddColour(
                            colour_index_map[val][1],
                            colour_index_map[val][2],
                            colour_index_map[val][3],
                            colour_index_map[val][4]
                        )

                        inst.laser_line:SetColourIndex(val)
                    end
                end)

                inst:ListenForEvent("client_death", function()
                    inst._check_rotation_task:Cancel()
                    inst.eye_up:Remove()
                    inst.eye_down:Remove()
                    inst.laser_line:Remove()
                end)
            end

            inst:AddComponent("talker")
            inst.components.talker.fontsize = 33
            inst.components.talker.font = TALKINGFONT
            -- inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
            inst.components.talker.offset = Vector3(0, -300, 0)
            -- inst.components.talker.symbol = "fossil_chest"
            inst.components.talker:MakeChatter()
        end,

        serverfn = function(inst)
            -- c_select().pid_controller.ki = 0.1
            inst.rotate_speed = 0
            inst.max_rotate_speed = 180
            inst.pid_controller = PIDController(1, 0.1, 0.05)

            inst.scaned_targets = {}
            inst.lights = {}



            inst.CreateLockToTargetTask = CreateLockToTargetTask
            inst.SelectTarget = SelectTarget
            inst.DoTalkSound = DoTalkSound


            inst:AddComponent("timer")

            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aurafn = CalcSanityAura
            inst.components.sanityaura.max_distsq = 225

            inst:AddComponent("inspectable")

            inst:AddComponent("portablestructure")
            inst.components.portablestructure:SetOnDismantleFn(OnDismantle)


            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(400)
            inst.components.health.fadeouttime = 6


            inst:AddComponent("combat")
            inst.components.combat.playerdamagepercent = 0.33
            inst.components.combat:SetRange(15)
            inst.components.combat:SetDefaultDamage(0)
            inst.components.combat:SetAttackPeriod(0.2)
            inst.components.combat:SetHurtSound("gale_sfx/battle/hit_metal")
            inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)


            inst:AddComponent("lootdropper")

            inst:SetStateGraph("SGathetos_portable_turret")
            inst:SetBrain(brain)



            inst.sounds = {
                deploy = "gale_sfx/battle/athetos_portable_turret/turret_on",
                shoot = "gale_sfx/battle/athetos_portable_turret/turret_shot",
                -- talk = "gale_sfx/battle/athetos_portable_turret/talk",
                turn = "gale_sfx/battle/athetos_portable_turret/turret_whir_loop",
                talk_idle = "gale_sfx/battle/athetos_portable_turret/talk_idle",
                talk_scan = "gale_sfx/battle/athetos_portable_turret/talk_scan",
                talk_attack = "gale_sfx/battle/athetos_portable_turret/talk_attack",
                sing = "gale_bgm/bgm/turret_wife_serenade",
            }



            inst:ListenForEvent("death", function()
                inst._client_death_event:push()
            end)

            GaleCondition.AddCondition(inst, "condition_metallic")
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_portable_turret_item",
        assets = {
            Asset("ANIM", "anim/athetos_portable_turret.zip"),
            Asset("IMAGE", "images/inventoryimages/athetos_portable_turret_item.tex"),
            Asset("ATLAS", "images/inventoryimages/athetos_portable_turret_item.xml"),
        },
        tags = { "portableitem" },

        bank = "athetos_portable_turret",
        build = "athetos_portable_turret",
        anim = "item",

        inventoryitem_data = {
            -- imagename = "msf_silencer_pistol",
            -- atlasname = "msf_silencer_pistol",
            use_gale_item_desc = true,
        },

        finiteuses_data = {
            maxuse = 400,
        },

        clientfn = function(inst)
            inst:SetPrefabNameOverride("athetos_portable_turret")
        end,

        serverfn = function(inst)
            inst:AddComponent("timer")

            inst:AddComponent("deployable")
            inst.components.deployable.ondeploy = OnTurretDeploy
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "athetos_portable_turret_projectile",
        assets = {
            Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
        },
        tags = { "NOCLICK" },

        bank = "projectile",
        build = "staff_projectile",
        anim = "fire_spin_loop",
        loop_anim = true,

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.AnimState:SetMultColour(0, 0, 0, 0)
        end,

        serverfn = function(inst)
            inst.Physics:SetCollisionCallback(function(inst, other)
                if other and other.prefab == "gale_polygon_physics" and not inst.collide then
                    inst.collide = true
                    inst.components.complexprojectile:Hit(other)
                end
            end)

            inst:AddComponent("weapon")
            inst.components.weapon:SetDamage(ProjectileGetDamageFn)

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile:SetHorizontalSpeed(34)
            inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
            inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "athetos_portable_turret_deathpart",
        assets = {
            Asset("ANIM", "anim/athetos_portable_turret.zip"),
        },


        bank = "athetos_portable_turret",
        build = "athetos_portable_turret",
        anim = "depart_fly",

        loop_anim = true,
        animover_remove = false,

        clientfn = function(inst)
            inst.Transform:SetTwoFaced()

            MakeInventoryPhysics(inst)

            inst.entity:AddDynamicShadow()

            inst.DynamicShadow:SetSize(0.75, 0.5)
            inst.DynamicShadow:Enable(true)
        end,

        serverfn = function(inst)
            -- inst.task = inst:DoPeriodicTask(0)
            -- inst.AnimState:SetDeltaTimeMultiplier(GetRandomMinMax(1,2))

            inst.StartFX = function(inst, index)
                inst.AnimState:OverrideSymbol("depart1", "athetos_portable_turret", "depart" .. tostring(index))
                inst.task = inst:DoPeriodicTask(0, function()
                                                    local x, y, z = inst:GetPosition():Get()
                                                    local vx, vy, vz = inst.Physics:GetMotorVel()
                                                    if y < 0.05 then
                                                        if ShouldEntitySink(inst, true) then
                                                            SinkEntity(inst)
                                                        elseif vy <= 0 then
                                                            inst.task:Cancel()

                                                            -- inst.Transform:SetPosition(x,0,z)
                                                            -- inst.Physics:Stop()
                                                            inst.AnimState:Pause()

                                                            inst:DoTaskInTime(GetRandomMinMax(2, 3), ErodeAway)
                                                        end
                                                    end
                                                end, FRAMES)

                inst:DoTaskInTime(10, function()
                    if inst.task then
                        ErodeAway(inst)
                    end
                end)
            end
        end,
    }),
    MakePlacer("athetos_portable_turret_item_placer", "athetos_portable_turret", "athetos_portable_turret", "idle", nil,
               nil, nil, 1.15)
