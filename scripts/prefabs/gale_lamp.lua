local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local containers = require("containers")


containers.params.gale_lamp =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

local assets = {
    Asset("ANIM", "anim/gale_lamp.zip"),

    Asset("IMAGE", "images/inventoryimages/gale_lamp.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_lamp.xml"),

    Asset("IMAGE", "images/inventoryimages/gale_lamp_light.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_lamp_light.xml"),
}

local function onopen(inst)
    -- inst.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/container_open")
end

local function onclose(inst)
    -- inst.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/container_close")
end

local firelevels =
{
    { anim = "fire", radius = 0.5, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
    { anim = "fire", radius = 0.6, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
    { anim = "fire", radius = 0.8, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
    { anim = "fire", radius = 1.1, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
    { anim = "fire", radius = 1.3, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
    { anim = "fire", radius = 1.5, intensity = .8, falloff = .33, colour = { 255 / 255, 255 / 255, 192 / 255 }, },
}

local function UpdateLightOwner(inst)
    if inst.light_fx == nil then
        return
    end

    local owner = inst.components.inventoryitem:GetGrandOwner()


    if owner == nil then
        inst:AddChild(inst.light_fx)
        inst.light_fx.Follower:FollowSymbol(inst.GUID, "light", 0, 0, 0)

        -- print(inst,"On ground!")
    elseif owner:HasTag("player") then
        inst.light_fx.Follower:StopFollowing()
        owner:AddChild(inst.light_fx)


        -- print(inst,"Into a player")
    else
        inst.light_fx.Follower:StopFollowing()
        owner:AddChild(inst.light_fx)

        -- print(inst,"Into a container ?")
    end
end

local function RandomTimeFnWrapper(a, b)
    return function()
        return GetRandomMinMax(a, b)
    end
end

local function GlitchOnWetInterface(inst, next_time_fn, not_drain)
    local glitch_percent = inst.components.inventoryitem:GetMoisture() / TUNING.MOISTURE_WET_THRESHOLD
    if glitch_percent > math.random() then
        local delta = -GetRandomMinMax(8, 10) * glitch_percent
        if not_drain then
            delta = math.max(delta, -inst.components.fueled.currentfuel)
        end
        inst.components.fueled:DoDelta(delta)

        local source = inst.components.inventoryitem:GetGrandOwner() or inst
        SpawnAt("sparks", source)

        local source_pt = source:GetPosition()
        local ents = TheSim:FindEntities(source_pt.x, source_pt.y, source_pt.z, 1.5, { "campfire" }, { "INLIMBO" })
        for k, v in pairs(ents) do
            if v.components.fueled and v.components.fueled.currentfuel < 15 then
                v.components.fueled:DoDelta(GetRandomMinMax(5, 15))
            end
        end
    end
    if next_time_fn then
        inst.glitch_on_wet_task = inst:DoTaskInTime(FunctionOrValue(next_time_fn, inst), GlitchOnWetInterface,
                                                    next_time_fn)
    end
end


return GaleEntity.CreateNormalInventoryItem({
        prefabname = "gale_lamp",
        assets = assets,

        bank = "gale_lamp",
        build = "gale_lamp",
        anim = "idle_2_off",

        inventoryitem_data = {
            -- imagename = "lantern",
            -- atlasname_override = "images/inventoryimages.xml",
            use_gale_item_desc = true,
        },

        clientfn = function(inst)
            inst.entity:AddDynamicShadow()
            inst.DynamicShadow:SetSize(1.3, 0.9)
        end,

        serverfn = function(inst)
            inst:AddComponent("fueled")
            inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * 0.33)
            inst.components.fueled:SetDepletedFn(function()
                inst.SoundEmitter:PlaySound("gale_sfx/lamp/p1_lamp_switch")
            end)
            -- inst.components.fueled:SetUpdateFn(onupdatefueled)
            -- inst.components.fueled:SetTakeFuelFn(ontakefuel)
            -- inst.components.fueled:SetFirstPeriod(0.5,1 / 60)
            inst.components.fueled:SetSections(6)
            inst.components.fueled.accepting = false

            inst:AddComponent("container")
            inst.components.container:WidgetSetup("gale_lamp", containers.params.gale_lamp)
            inst.components.container.onopenfn = onopen
            inst.components.container.onclosefn = onclose
            inst.components.container.skipclosesnd = true
            inst.components.container.skipopensnd = true

            inst:ListenForEvent("percentusedchange", function(inst, data)
                if data.percent > 0 then
                    if not inst.components.fueled.consuming then
                        inst.components.fueled:StartConsuming()
                    end

                    if inst.light_fx == nil then
                        inst.light_fx = SpawnPrefab("gale_lamp_light")
                        inst.light_fx.entity:AddFollower()
                        UpdateLightOwner(inst)
                    end



                    inst.light_fx.components.firefx:SetLevel(inst.components.fueled:GetCurrentSection())
                    inst.light_fx.components.firefx:SetPercentInLevel(inst.components.fueled:GetSectionPercent())

                    inst.AnimState:SetPercent("idle_2_on", inst.components.fueled:GetPercent())

                    inst.components.inventoryitem.atlasname = "images/inventoryimages/gale_lamp_light.xml"
                    inst.components.inventoryitem:ChangeImageName("gale_lamp_light")

                    if inst.glitch_on_wet_task == nil then
                        -- print("Trigger GlitchOnWetInterface", data.percent)
                        GlitchOnWetInterface(inst, RandomTimeFnWrapper(3, 5), true)
                    end
                else
                    if inst.light_fx then
                        inst.light_fx:Remove()
                        inst.light_fx = nil
                    end

                    inst.AnimState:PlayAnimation("idle_2_off")

                    inst.components.inventoryitem.atlasname = "images/inventoryimages/gale_lamp.xml"
                    inst.components.inventoryitem:ChangeImageName("gale_lamp")
                    if inst.glitch_on_wet_task then
                        inst.glitch_on_wet_task:Cancel()
                        inst.glitch_on_wet_task = nil
                    end
                end
            end)

            inst:DoTaskInTime(FRAMES, function()
                if inst.components.fueled:GetPercent() > 0 then
                    inst.components.fueled:DoDelta(0)
                end
            end)

            inst:ListenForEvent("onputininventory", UpdateLightOwner)
            inst:ListenForEvent("ondropped", UpdateLightOwner)
        end,
    }),
    GaleEntity.CreateNormalFx({
        -- gale_lamp_light only afford Light,it dosen't have a anim
        prefabname = "gale_lamp_light",
        assets = assets,

        bank = "gale_lamp",
        build = "gale_lamp",
        anim = "fire",

        persists = true,
        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:HideSymbol("light")
        end,

        serverfn = function(inst)
            inst:AddComponent("firefx")
            inst.components.firefx.levels = firelevels
            inst.components.firefx.usedayparamforsound = false
            inst.components.firefx.playignitesound = false
            inst.components.firefx:SetLevel(1)
        end,

    })