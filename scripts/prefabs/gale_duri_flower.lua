local GaleEntity = require("util/gale_entity")

local assets =
{
    Asset("ANIM", "anim/gale_duri_flower.zip"),
    Asset("IMAGE", "images/inventoryimages/gale_duri_flower_petal.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_duri_flower_petal.xml"),
}

local function onpickedfn(inst, picker)
    local pos = inst:GetPosition()

    if picker ~= nil then
        if picker.components.sanity ~= nil and not picker:HasTag("plantkin") then
            picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
        end
    end

    TheWorld:PushEvent("plantkilled", { doer = picker, pos = pos }) --this event is pushed in other places too
end


local FINDLIGHT_MUST_TAGS = { "daylight", "lightsource" }
local function DieInDarkness(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.DAYLIGHT_SEARCH_RANGE, FINDLIGHT_MUST_TAGS)
    for i, v in ipairs(ents) do
        local lightrad = v.Light:GetCalculatedRadius() * .7
        if v:GetDistanceSqToPoint(x, y, z) < lightrad * lightrad then
            --found light
            return
        end
    end

    ReplacePrefab(inst, "flower_withered")
end

local function OnIsCaveDay(inst, isday)
    if isday then
        inst:DoTaskInTime(5.0 + math.random() * 5.0, DieInDarkness)
    end
end

local function PetalOnHaunt(inst, haunter)
    local success_percent = TUNING.HAUNT_CHANCE_VERYRARE * inst.components.stackable:StackSize()

    if math.random() <= success_percent then
        SpawnAt("small_puff", inst)

        local heart = SpawnAt("reviver", inst)
        heart.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(),
            inst.components.inventoryitem:IsWet())
        heart:PushEvent("spawnedfromhaunt", { haunter = haunter, oldPrefab = inst })
        inst:PushEvent("despawnedfromhaunt", { haunter = haunter, newPrefab = heart })

        -- Why didn't just remove it ?
        inst.persists = false
        inst.entity:Hide()
        inst:DoTaskInTime(0, inst.Remove)

        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL

        return true
    end
    return false
end


return GaleEntity.CreateNormalEntity({
        prefabname = "gale_duri_flower",
        assets = assets,

        bank = "gale_duri_flower",
        build = "gale_duri_flower",
        anim = "idle",

        tags = { "flower", "cattoy" },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("inspectable")

            inst:AddComponent("pickable")
            inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
            inst.components.pickable:SetUp("gale_duri_flower_petal", 10)
            inst.components.pickable.onpickedfn = onpickedfn
            inst.components.pickable.remove_when_picked = true
            inst.components.pickable.quickpick = true
            inst.components.pickable.wildfirestarter = true

            MakeSmallBurnable(inst)
            MakeSmallPropagator(inst)
            AddToRegrowthManager(inst)

            inst:AddComponent("halloweenmoonmutable")
            inst.components.halloweenmoonmutable:SetPrefabMutated("moonbutterfly_sapling")

            if TheWorld:HasTag("cave") then
                inst:WatchWorldState("iscaveday", OnIsCaveDay)
            end

            MakeHauntableChangePrefab(inst, "flower_evil")
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "gale_duri_flower_petal",
        assets = assets,

        bank = "gale_duri_flower",
        build = "gale_duri_flower",
        anim = "idle_petal",

        tags = {
            "cattoy",
            -- "vasedecoration",
        },

        inventoryitem_data = {
            floatable_param = {},
            use_gale_item_desc = true,
        },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

            inst:AddComponent("tradable")

            -- inst:AddComponent("vasedecoration")

            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

            MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
            MakeSmallPropagator(inst)

            inst:AddComponent("edible")
            inst.components.edible.healthvalue = TUNING.HEALING_TINY
            inst.components.edible.hungervalue = TUNING.CALORIES_TINY / 4
            inst.components.edible.foodtype = FOODTYPE.VEGGIE

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"

            MakeHauntableLaunchAndPerish(inst)
            AddHauntableCustomReaction(inst, PetalOnHaunt, false, true, false)
        end,
    })
