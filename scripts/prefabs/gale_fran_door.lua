local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local FRAN_DOOR_SCALE = 1.2

local function LightFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(252 / 255, 251 / 255, 237 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(1)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function SmallLightOverrideFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("gale_fran_door")
    inst.AnimState:SetBuild("gale_fran_door")

    inst.AnimState:HideSymbol("breach_attractor")
    inst.AnimState:HideSymbol("base")
    -- inst.AnimState:HideSymbol("face")

    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetScale(FRAN_DOOR_SCALE, FRAN_DOOR_SCALE, FRAN_DOOR_SCALE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function OnDoorDeploy(inst, pt)
    local door = SpawnAt("gale_fran_door", pt)
    door.Physics:SetCollides(false)
    door.Physics:Teleport(pt.x, 0, pt.z)
    door.Physics:SetCollides(true)
    door.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
    inst:Remove()
end

local function PortalCommonClientFn(inst)
    inst.entity:AddMiniMapEntity()

    MakeObstaclePhysics(inst, 0.7)



    inst.AnimState:HideSymbol("breach_attractor")
    inst.AnimState:HideSymbol("light")
    inst.AnimState:SetScale(FRAN_DOOR_SCALE, FRAN_DOOR_SCALE, FRAN_DOOR_SCALE)
end

local function PortalCommonServerFn(inst)
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("gale_portal")

    inst:SetStateGraph("SGgale_fran_door")

    inst.light_override = inst:SpawnChild("gale_fran_door_light_override")
    -- inst.light_override.Transform:SetPosition(0,0.05,0)

    inst.EnableLight = function(inst, enable)
        if inst.lightfx1 then
            inst.lightfx1:Remove()
            inst.lightfx1 = nil
        end

        if inst.lightfx2 then
            inst.lightfx2:Remove()
            inst.lightfx2 = nil
        end

        inst.light_override:Hide()
        inst.light_override.AnimState:PlayAnimation("idle")

        if enable then
            inst.light_override:Show()
            inst.light_override.AnimState:PlayAnimation("activite", true)
        end
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "gale_fran_door",

        assets = {
            Asset("ANIM", "anim/gale_fran_door.zip"),

            Asset("IMAGE", "images/map_icons/gale_fran_door.tex"), --小地图
            Asset("ATLAS", "images/map_icons/gale_fran_door.xml"),
        },

        bank = "gale_fran_door",
        build = "gale_fran_door",
        anim = "idle",

        clientfn = function(inst)
            PortalCommonClientFn(inst)
            inst.MiniMapEntity:SetIcon("gale_fran_door.tex")
        end,

        serverfn = function(inst)
            PortalCommonServerFn(inst)
            inst:DoTaskInTime(0, function()
                inst.components.gale_portal:AddInstToPortals()
                inst.components.gale_portal:EnableIcon(true)
            end)

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
            inst.components.workable:SetOnFinishCallback(function(inst, hammerer)
                -- inst.components.lootdropper:DropLoot()
                inst.components.lootdropper:SpawnLootPrefab("gale_fran_door_item")

                local collapse_fx = SpawnAt("collapse_big", inst)
                collapse_fx:SetMaterial("metal")

                inst:Remove()
            end)
            -- inst.components.workable:SetOnWorkCallback(onhit)
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "gale_fran_door_lv2",
        tags = { "athetos_type" },
        assets = {
            Asset("ANIM", "anim/gale_fran_door.zip"),

            Asset("IMAGE", "images/map_icons/gale_fran_door_lv2.tex"), --小地图
            Asset("ATLAS", "images/map_icons/gale_fran_door_lv2.xml"),
        },

        bank = "gale_fran_door",
        build = "gale_fran_door",
        anim = "idle",

        clientfn = function(inst)
            PortalCommonClientFn(inst)

            inst.MiniMapEntity:SetIcon("gale_fran_door_lv2.tex")
            inst.AnimState:ShowSymbol("breach_attractor")

            local c = 0.6
            inst.AnimState:SetSymbolMultColour("breach_attractor", c, c, c, 1)
        end,

        serverfn = function(inst)
            PortalCommonServerFn(inst)

            inst.last_glitch_time = GetTime()


            inst.OnEntityWake = function(inst)
                inst.SoundEmitter:PlaySound("gale_sfx/fran_door/MemoryTrasher", "glitch_sound")
            end

            inst.OnEntitySleep = function(inst)
                inst.SoundEmitter:KillSound("glitch_sound")
            end

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
            inst.components.workable:SetOnFinishCallback(function(inst, hammerer)
                local collapse_fx = SpawnAt("collapse_big", inst)
                collapse_fx:SetMaterial("metal")

                inst:Remove()
            end)

            inst.components.workable:SetOnWorkCallback(function(inst)
                inst.components.workable:SetWorkLeft(3)
                inst.SoundEmitter:PlaySound("gale_sfx/fran_door/DroneWound")
                inst.sg:GoToState("hit_glitch")
            end)


            inst:DoPeriodicTask(5, function()
                if inst.sg:HasStateTag("glitch") then
                    return
                end

                if inst.SoundEmitter:PlayingSound("shocked") then
                    inst.SoundEmitter:KillSound("shocked")
                end

                inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod", "shocked")
                -- inst.SoundEmitter:SetVolume("shocked", 0.5)

                local fx = inst:SpawnChild("cracklehitfx")
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "breach_attractor", 0, 0, 0)

                local s = 0.4
                fx.Transform:SetScale(s, s, s)
                fx.persists = false

                fx.AnimState:PlayAnimation("crackle_loop", true)
                fx.AnimState:SetTime(math.random())
                fx.AnimState:SetAddColour(0 / 255, 0 / 255, 255 / 255, 1)
                fx.AnimState:SetLightOverride(1)
                fx.AnimState:SetDeltaTimeMultiplier(1.3)

                fx:DoTaskInTime(0.7, fx.Remove)

                inst.elec_fx = fx
            end)
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_fran_door_flash_fx",

        assets = {
            Asset("ANIM", "anim/gale_fran_door.zip"),
        },

        bank = "gale_fran_door",
        build = "gale_fran_door",
        anim = "flash_fx",

        animover_remove = false,

        clientfn = function(inst)
            local s = 3
            inst.AnimState:SetScale(s, s, s)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetMultColour(1, 1, 1, 0.1)
            -- inst.AnimState:SetFinalOffset(1)
        end,

        serverfn = function(inst)
            -- inst.FadeOut = function(inst,duration)
            --     GaleCommon.FadeTo(inst,duration or 2,{
            --         Vector3(0.8,0.8,0.8),
            --         Vector3(0.4,0.4,0.4),
            --     },{
            --         Vector4(1,1,1,1),
            --         Vector4(0,0,0,0),
            --     },nil,function(fx)
            --         fx:Remove()
            --     end)
            -- end
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "gale_fran_door_item",

        assets = {
            Asset("ANIM", "anim/gale_fran_door.zip"),

            Asset("IMAGE", "images/inventoryimages/gale_fran_door_item.tex"),
            Asset("ATLAS", "images/inventoryimages/gale_fran_door_item.xml"),
        },

        inventoryitem_data = {
            use_gale_item_desc = true,
        },

        bank = "gale_fran_door",
        build = "gale_fran_door",
        anim = "item_lv1",

        tags = { "portableitem" },

        clientfn = function(inst)
            -- inst:SetPrefabNameOverride("gale_fran_door")
        end,

        serverfn = function(inst)
            inst:AddComponent("deployable")
            inst.components.deployable.ondeploy = OnDoorDeploy
        end,
    }),
    -- MakePlacer("gale_fran_door_placer", "gale_fran_door", "gale_fran_door", "idle", nil, nil, nil, nil, nil, nil,
    --            function(inst)
    --                inst.AnimState:HideSymbol("breach_attractor")
    --                inst.AnimState:HideSymbol("light")
    --            end),
    MakePlacer("gale_fran_door_item_placer", "gale_fran_door", "gale_fran_door", "idle", nil, nil, nil, nil, nil, nil,
               function(inst)
                   inst.AnimState:HideSymbol("breach_attractor")
                   inst.AnimState:HideSymbol("light")
               end),
    Prefab("gale_fran_door_light", LightFn),
    Prefab("gale_fran_door_light_override", SmallLightOverrideFn)
