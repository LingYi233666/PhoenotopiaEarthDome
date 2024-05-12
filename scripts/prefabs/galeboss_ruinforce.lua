local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")
local brain = require("brains/galeboss_ruinforcebrain")



SetSharedLootTable("galeboss_ruinforce",
                   {
                       { "galeboss_ruinforce_core",                      1.00 },

                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },
                       { "gears",                                        1.00 },


                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },
                       { "trinket_6",                                    1.00 },

                       { "galeboss_ruinforce_projectile_dark_paracurve", 1.00 },
                       { "galeboss_ruinforce_projectile_dark_paracurve", 1.00 },
                       { "galeboss_ruinforce_projectile_dark_paracurve", 1.00 },
                       { "galeboss_ruinforce_projectile_dark_paracurve", 1.00 },
                       { "galeboss_ruinforce_projectile_dark_paracurve", 1.00 },
                   })

local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 20
    return FindEntity(
        inst,
        30,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and (guy.components.combat:TargetIs(inst) or
                    guy:IsNear(inst, range)
                )
                and not GaleCommon.IsShadowCreature(guy)
        end,
        { "_combat", "_health", },
        { "prey", "smallcreature", "INLIMBO" },
        { "character", "largecreature" }
    )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnAttacked(inst, data)
    if inst.phase == 2 then
        inst.damage_taken_before_roar = inst.damage_taken_before_roar + data.damage
    end

    inst.components.combat:SetTarget(data.attacker)
end

local function oncollapse(inst, other)
    if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
end

local function oncollide(inst, other)
    if other ~= nil and
        (other:HasTag("tree") or other:HasTag("boulder")) and --HasTag implies IsValid
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 then
        inst:DoTaskInTime(2 * FRAMES, oncollapse, other)
    end
end


local function CreateHeadOnHand()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    local s = 1.65
    inst.Transform:SetScale(s, s, s)
    inst.Transform:SetFourFaced()


    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("galeboss_ruinforce_head")
    inst.AnimState:SetBuild("galeboss_ruinforce_head")

    inst.AnimState:PlayAnimation("head")

    inst:AddComponent("highlightchild")

    return inst
end



return GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_ruinforce",
        assets = {

            Asset("ANIM", "anim/galeboss_ruinforce_head.zip"),
            Asset("ANIM", "anim/galeboss_ruinforce.zip"),


            Asset("ANIM", "anim/deerclops_basic.zip"),
            Asset("ANIM", "anim/deerclops_actions.zip"),
            Asset("ANIM", "anim/deerclops_build.zip"),
            Asset("ANIM", "anim/deerclops_yule.zip"),

            Asset("ANIM", "anim/deerclops_mutation_anims.zip"),
            Asset("ANIM", "anim/deerclopsfalling.zip"),

            Asset("SOUND", "sound/deerclops.fsb"),
        },

        tags = {
            "epic", "monster", "hostile", "scarytoprey", "largecreature", "typhon", "shadow_aligned",
        },

        bank = "deerclops",
        build = "deerclops_yule",

        clientfn = function(inst)
            inst.entity:AddDynamicShadow()
            inst.entity:AddLight()

            inst.Light:SetIntensity(.6)
            inst.Light:SetRadius(8)
            inst.Light:SetFalloff(3)
            inst.Light:SetColour(1, 0, 0)
            -- inst.Light:EnableClientModulation(true)
            inst.Light:Enable(true)


            MakeGiantCharacterPhysics(inst, 1000, .5)

            local s = 1.65
            inst.Transform:SetScale(s, s, s)
            inst.DynamicShadow:SetSize(6, 3.5)
            inst.Transform:SetFourFaced()

            inst.AnimState:AddOverrideBuild("galeboss_ruinforce")

            inst.AnimState:HideSymbol("yule_fx_star")
            inst.AnimState:HideSymbol("yule_fx_circ")
            inst.AnimState:HideSymbol("yule_fx_streak")
            inst.AnimState:HideSymbol("yule_fx_trail")
            inst.AnimState:HideSymbol("yule_new_light")
            inst.AnimState:HideSymbol("yule_new_line")

            inst.AnimState:HideSymbol("deerclops_antler")
            inst.AnimState:HideSymbol("deerclops_antler_yule")
            inst.AnimState:HideSymbol("deerclops_ear")
            inst.AnimState:HideSymbol("deerclops_head_neutral")
            inst.AnimState:HideSymbol("beefalo_furpatch")

            for i = 1, 4 do
                inst.AnimState:SetSymbolMultColour("ice_spike" .. i, 255 / 255, 29 / 255, 9 / 255, 1)
                -- inst.AnimState:HideSymbol("ice_spike" .. i)
            end

            inst._beheaded_enable = net_bool(inst.GUID, "inst._beheaded_enable", "beheadeddirty")
            inst._beheaded_smoke_vfx_enable = net_bool(inst.GUID, "inst._beheaded_smoke_vfx_enable",
                                                       "beheaded_smoke_vfx_dirty")

            GaleCommon.AddEpicBGM(inst, "galeboss_ruinforce")


            if not TheNet:IsDedicated() then
                inst.beheaded_smoke_vfx = nil

                -- local mg=c_findnext("galeboss_ruinforce") mg.head_on_hand.Follower:FollowSymbol(mg.GUID,"deerclops_hand",0,0,0)
                inst.eyeflame1 = inst:SpawnChild("galeboss_ruinforce_eyeflame_vfx")
                inst.eyeflame2 = inst:SpawnChild("galeboss_ruinforce_eyeflame_vfx")

                -- inst.eyeflame1.entity:SetParent(inst.entity)
                -- inst.eyeflame2.entity:SetParent(inst.entity)

                inst.eyeflame1.Follower:FollowSymbol(inst.GUID, "deerclops_head", 0, 0, 0)
                inst.eyeflame2.Follower:FollowSymbol(inst.GUID, "deerclops_head", 0, 0, 0)

                inst:DoPeriodicTask(0, function()
                    local val = inst._beheaded_enable:value()
                    if val or inst.replica.health:IsDead() then
                        inst.eyeflame1.no_emit = true
                        inst.eyeflame2.no_emit = true
                    else
                        local facing = inst.AnimState:GetCurrentFacing()
                        if facing == FACING_RIGHT or facing == FACING_LEFT then
                            if inst.AnimState:IsCurrentAnimation("atk") then
                                inst.eyeflame1.Follower:FollowSymbol(inst.GUID, "deerclops_head", 75, 10, 0.1)
                            else
                                inst.eyeflame1.Follower:FollowSymbol(inst.GUID, "deerclops_head", 32, -31, 0.1)
                            end

                            inst.eyeflame1.no_emit = false
                            inst.eyeflame2.no_emit = true
                        elseif facing == FACING_UP then
                            inst.eyeflame1.no_emit = true
                            inst.eyeflame2.no_emit = true
                        elseif facing == FACING_DOWN then
                            inst.eyeflame1.Follower:FollowSymbol(inst.GUID, "deerclops_head", 61, 10, 0.1)
                            inst.eyeflame2.Follower:FollowSymbol(inst.GUID, "deerclops_head", -44, 11, 0.1)

                            inst.eyeflame1.no_emit = false
                            inst.eyeflame2.no_emit = false
                        end
                    end
                end)

                inst:ListenForEvent("beheadeddirty", function()
                    local val = inst._beheaded_enable:value()

                    if val then
                        inst.head_on_hand = CreateHeadOnHand()
                        inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 0, 0, 0)
                        inst.head_on_hand.components.highlightchild:SetOwner(inst)

                        inst.head_on_hand:DoPeriodicTask(0, function()
                            inst.head_on_hand:ForceFacePoint(GaleCommon.GetFaceVector(inst):Get())

                            local facing = inst.AnimState:GetCurrentFacing()
                            if facing == FACING_RIGHT then
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 50, 0, -0.1)
                            elseif facing == FACING_UP then
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 0, 0, -0.1)
                            elseif facing == FACING_LEFT then
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 50, 0, -0.1)
                            elseif facing == FACING_DOWN then
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 80, 10, 0.1)
                            end
                            if inst.AnimState:IsCurrentAnimation("fortresscast_pre")
                                or inst.AnimState:IsCurrentAnimation("fortresscast_loop")
                                or inst.AnimState:IsCurrentAnimation("falling_loop")
                                or inst.AnimState:IsCurrentAnimation("fallattack") then
                                -- inst.head_on_hand.Transform:SetNoFaced()
                                inst.head_on_hand.AnimState:PlayAnimation("test_head")
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 80, 10, 0.1)
                            elseif inst.AnimState:IsCurrentAnimation("taunt") then
                                if inst.AnimState:GetCurrentAnimationTime() >= 15 * FRAMES then
                                    inst.head_on_hand.AnimState:PlayAnimation("roar")
                                else
                                    inst.head_on_hand.AnimState:PlayAnimation("test_head")
                                end
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 80, 10, 0.1)
                            elseif inst.AnimState:IsCurrentAnimation("struggle_pre") then
                                inst.head_on_hand.AnimState:PlayAnimation("test_head")
                                if inst.AnimState:GetCurrentAnimationTime() >= 8 * FRAMES then
                                    inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 210, 70, 0.1)
                                end
                            elseif inst.AnimState:IsCurrentAnimation("struggle_loop") then
                                inst.head_on_hand.AnimState:PlayAnimation("roar")
                                inst.head_on_hand.Follower:FollowSymbol(inst.GUID, "deerclops_hand", 210, 70, 0.1)
                            else
                                -- inst.head_on_hand.Transform:SetFourFaced()
                                inst.head_on_hand.AnimState:PlayAnimation("head")
                            end
                        end)
                    elseif inst.head_on_hand and inst.head_on_hand:IsValid() then
                        inst.head_on_hand:Remove()
                        inst.head_on_hand = nil
                    end
                end)

                inst:ListenForEvent("beheaded_smoke_vfx_dirty", function()
                    local enable = inst._beheaded_smoke_vfx_enable:value()
                    if enable and not inst.beheaded_smoke_vfx then
                        inst.beheaded_smoke_vfx = inst:SpawnChild("galeboss_ruinforce_beheaded_smoke_vfx")
                        -- inst.beheaded_smoke_vfx.entity:SetParent(inst.entity)
                        inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, 0, 0)
                        inst.beheaded_smoke_vfx:DoPeriodicTask(0, function()
                            local facing = inst.AnimState:GetCurrentFacing()
                            if inst.AnimState:IsCurrentAnimation("fortresscast_pre")
                                or inst.AnimState:IsCurrentAnimation("fortresscast_loop")
                                or inst.AnimState:IsCurrentAnimation("falling_loop")
                                or inst.AnimState:IsCurrentAnimation("fallattack")
                                or inst.AnimState:IsCurrentAnimation("taunt")
                                or inst.AnimState:IsCurrentAnimation("death")
                                or inst.AnimState:IsCurrentAnimation("struggle_pre")
                                or inst.AnimState:IsCurrentAnimation("struggle_loop")
                                or inst.AnimState:IsCurrentAnimation("struggle_pst") then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 35, 10, 0.01)
                                return
                            end


                            if facing == FACING_RIGHT or facing == FACING_LEFT then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 90, -118, 0.01)
                            elseif facing == FACING_UP then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -150, -0.01)
                            elseif facing == FACING_DOWN then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 30, 10, 0.01)
                            elseif facing == FACING_UPRIGHT or facing == FACING_UPLEFT then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 0, -150, -0.01)
                            elseif facing == FACING_DOWNRIGHT or facing == FACING_DOWNLEFT then
                                inst.beheaded_smoke_vfx.Follower:FollowSymbol(inst.GUID, "deerclops_body", 30, 10, 0.01)
                            end
                        end)
                    elseif not enable and inst.beheaded_smoke_vfx then
                        inst.beheaded_smoke_vfx:Remove()
                        inst.beheaded_smoke_vfx = nil
                    end
                end)

                inst:ListenForEvent("onremove", function()
                    if inst.head_on_hand and inst.head_on_hand:IsValid() then
                        inst.head_on_hand:Remove()
                        inst.head_on_hand = nil
                    end
                end)
            end
        end,

        serverfn = function(inst)
            inst.Physics:SetCollisionCallback(oncollide)

            --------------------- Extra params --------------------------------
            -- Phase Setting:
            -- Phase 0:New spawned,not roar yet,no BGM
            -- Phase 1:Normal,BGM normal
            -- Phase 2:Beheaded,BGM excitied
            inst.phase = 0

            inst.footprinter = inst:SpawnChild("galeboss_ruinforce_footprinter")
            inst.handelec_fx = inst:SpawnChild("galeboss_ruinforce_handelec_fx")


            inst.miss_target_count = 0
            inst.damage_taken_before_roar = 0

            inst.LastLaserTime = GetTime()
            inst.LastSuperJumpTime = GetTime()

            -- c_findnext("galeboss_ruinforce"):EnableBeHeaded(true)
            inst.EnableBeHeaded = function(inst, enable)
                inst._beheaded_enable:set(enable)
            end

            inst.EnableBeheadedSmoke = function(inst, enable)
                inst._beheaded_smoke_vfx_enable:set(enable)
            end

            inst.TurnLight = function(inst, target_rad, speed)
                if inst.TurnLightTask then
                    inst.TurnLightTask:Cancel()
                    inst.TurnLightTask = nil
                end

                -- local max_rad = 8
                -- local min_rad = 3.5
                -- -- Turn on
                -- if enable then
                --     inst.TurnLightTask = inst:DoPeriodicTask(0,function()
                --         local rad = inst.Light:GetRadius()
                --         rad = math.min(max_rad,rad + FRAMES * 4)
                --         inst.Light:SetRadius(rad)
                --         if rad >= max_rad then
                --             inst.TurnLightTask:Cancel()
                --             inst.TurnLightTask = nil
                --         end
                --     end)
                -- else
                --     -- turn off
                --     inst.TurnLightTask = inst:DoPeriodicTask(0,function()
                --         local rad = inst.Light:GetRadius()
                --         rad = math.max(min_rad,rad - FRAMES * 4)
                --         inst.Light:SetRadius(rad)
                --         if rad <= min_rad then
                --             inst.TurnLightTask:Cancel()
                --             inst.TurnLightTask = nil
                --         end
                --     end)
                -- end

                inst.TurnLightTask = inst:DoPeriodicTask(0, function()
                    local rad = inst.Light:GetRadius()
                    local delta = target_rad - rad


                    if delta > 0 then
                        rad = math.min(target_rad, rad + speed)
                    else
                        rad = math.max(target_rad, rad - speed)
                    end

                    inst.Light:SetRadius(rad)
                    if math.abs(target_rad - rad) <= 0.01 then
                        inst.Light:SetRadius(target_rad)
                        inst.TurnLightTask:Cancel()
                        inst.TurnLightTask = nil
                    end
                end)
            end
            -------------------------------------------------------------------

            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aurafn = function(inst, observer)
                if inst.components.health:IsDead() then
                    return -TUNING.SANITYAURA_MED
                end

                if inst.phase <= 1 then
                    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_LARGE or -TUNING.SANITYAURA_MED
                end

                return -TUNING.SANITYAURA_HUGE
            end


            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(16000)
            inst.components.health:SetCurrentHealth(1000)
            inst.components.health.nofadeout = true

            inst:AddComponent("combat")
            inst.components.combat:SetDefaultDamage(150)
            inst.components.combat.playerdamagepercent = 0.5
            inst.components.combat:SetRange(8, 10)
            inst.components.combat.hiteffectsymbol = "deerclops_body"
            inst.components.combat:SetAttackPeriod(4)
            inst.components.combat:SetRetargetFunction(1, RetargetFn)
            inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
            inst.components.combat:SetHurtSound("dontstarve/creatures/lava_arena/turtillus/shell_impact")

            inst:AddComponent("locomotor")
            inst.components.locomotor.walkspeed = 3

            inst:AddComponent("explosiveresist")

            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("galeboss_ruinforce")
            inst.components.lootdropper.min_speed = 0
            inst.components.lootdropper.max_speed = 12
            inst.components.lootdropper.y_speed = 25
            inst.components.lootdropper.y_speed_variance = 5

            inst:AddComponent("inspectable")
            inst.components.inspectable.getstatus = function(inst)
                local phase = inst.phase or 0
                if phase == 0 then
                    phase = 1
                end
                local result = "PHASE_" .. phase
                if inst.components.health:IsDead() then
                    result = result .. "_DEAD"
                end

                return result
            end

            inst:SetStateGraph("SGgaleboss_ruinforce")
            inst:SetBrain(brain)

            inst.OnSave = function(inst, data)
                data.phase = inst.phase
            end

            inst.OnLoad = function(inst, data)
                if data ~= nil then
                    if data.phase ~= nil then
                        inst.phase = data.phase
                    end
                end

                if inst.phase == 0 then
                    inst.phase = 1
                end

                if inst.phase == 1 then
                    inst:SetMusicLevel(2)
                elseif inst.phase == 2 then
                    inst:SetMusicLevel(3)
                    inst.AnimState:HideSymbol("deerclops_head")
                    inst:EnableBeHeaded(true)
                    inst:EnableBeheadedSmoke(true)
                else
                    inst:SetMusicLevel(1)
                end
            end




            inst:ListenForEvent("attacked", OnAttacked)
            inst:ListenForEvent("onmissother", function()
                inst.miss_target_count = inst.miss_target_count + 1
            end)
            inst:ListenForEvent("onremove", function()
                inst:EnableBeHeaded(false)
            end)
            inst:ListenForEvent("loot_prefab_spawned", function(inst, data)
                if data.loot.prefab == "galeboss_ruinforce_projectile_dark_paracurve" then
                    data.loot.components.complexprojectile.attacker = inst
                    data.loot.task = data.loot:DoPeriodicTask(0, function()
                        local x, y, z = data.loot.Transform:GetWorldPosition()
                        if y <= 0.05 then
                            for i = 1, GetRandomMinMax(3, 5) do
                                SpawnAt("nightmarefuel", data.loot, nil, Vector3(UnitRand(), 0, UnitRand()))
                            end
                            data.loot.components.complexprojectile:Hit()
                            data.loot.task:Cancel()
                            data.loot.task = nil
                        end
                    end)
                else
                    local vfx = data.loot:SpawnChild("gale_enemy_die_smoke_vfx")
                    vfx._emit_id:set(1)

                    data.loot.task = data.loot:DoPeriodicTask(0, function()
                        local speed = data.loot.Physics:GetMotorSpeed()
                        local x, y, z = data.loot.Transform:GetWorldPosition()
                        if y <= 0.05 then
                            vfx:Remove()
                            data.loot.task:Cancel()
                            data.loot.task = nil
                        end
                    end)

                    if data.loot.prefab == "galeboss_ruinforce_core" then
                        local ox, _, oz = inst.Transform:GetWorldPosition()
                        local _, ly, _ = data.loot.Transform:GetWorldPosition()

                        data.loot.components.inventoryitem:DoDropPhysics(ox, ly, oz, true)
                    end
                end
            end)

            GaleCondition.AddCondition(inst, "condition_metallic")


            inst.sounds = {
                attack = "gale_sfx/battle/galeboss_ruinforce/attack",
                attack2 = "gale_sfx/battle/galeboss_ruinforce/attack2",
                elec_pre = "gale_sfx/battle/galeboss_ruinforce/elec_pre",
                elec = "gale_sfx/battle/galeboss_ruinforce/elec",
                hit = "gale_sfx/battle/galeboss_ruinforce/hurt",
                death = "gale_sfx/battle/galeboss_ruinforce/death",

                move_pre1 = "gale_sfx/battle/galeboss_ruinforce/move_pre1",
                move_pre2 = "gale_sfx/battle/galeboss_ruinforce/move_pre2",
                step = "gale_sfx/battle/galeboss_ruinforce/step",

                roar_pre = "gale_sfx/battle/galeboss_ruinforce/taunt_pre",
                roar = "gale_sfx/battle/galeboss_ruinforce/taunt",

                superjump = "gale_sfx/battle/galeboss_ruinforce/superjump",
                superland_warning = "gale_sfx/battle/galeboss_ruinforce/warning",
                superland = "gale_sfx/battle/galeboss_ruinforce/superland",

            }
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_ruinforce_head_drop_top",
        assets = {
            Asset("ANIM", "anim/galeboss_ruinforce_head.zip"),
        },

        bank = "galeboss_ruinforce_head",
        build = "galeboss_ruinforce_head",
        anim = "drop_top",

        persists = false,

        clientfn = function(inst)
            local s = 0.9
            inst.Transform:SetScale(s, s, s)

            inst:AddComponent("highlightchild")
        end
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_ruinforce_depart",
        assets = {
            Asset("ANIM", "anim/galeboss_ruinforce.zip"),
        },

        bank = "galeboss_ruinforce",
        build = "galeboss_ruinforce",
        anim = "depart",

        tags = {
            "NOCLICK",
        },

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
        end,

        serverfn = function(inst)

        end,
    })
