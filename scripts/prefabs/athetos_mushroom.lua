local GaleEntity = require("util/gale_entity")

-- c_select().AnimState:PlayAnimation("open_green")
-- c_select().AnimState:PlayAnimation("close_green")
-- c_select().AnimState:PlayAnimation("picked")
-- c_select().components.pickable:Regen()
-- TheWorld:PushEvent("ms_setmoonphase", {moonphase = "new", iswaxing = true})

local assets = {
    Asset("ANIM", "anim/athetos_mushroom.zip"),
    Asset("ANIM", "anim/athetos_mushroom_dirty.zip"),


    Asset("IMAGE", "images/inventoryimages/athetos_mushroom_cap.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_mushroom_cap.xml"),

    Asset("IMAGE", "images/inventoryimages/athetos_mushroom_cap_dirty.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_mushroom_cap_dirty.xml"),

    Asset("IMAGE", "images/inventoryimages/athetos_mushroom_cap_cooked.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_mushroom_cap_cooked.xml"),




}

local GOOD_PRODUCT = "athetos_mushroom_cap"
local QUICK_GROWTH_PRODUCT = "athetos_mushroom_cap_dirty"
local BAD_PRODUCT = "spoiled_food"

local function MushroomOpen(inst, delay)
    if inst.growtask then
        inst.growtask:Cancel()
    end
    inst.growtask = nil

    if delay and delay >= 0 then
        inst.growtask = inst:DoTaskInTime(delay, MushroomOpen)
    else
        if delay and delay < 0 then
            inst.AnimState:PlayAnimation("green")
        else
            inst.AnimState:PlayAnimation("open_inground")
            inst.AnimState:PushAnimation("open_green", false)
            inst.AnimState:PushAnimation("green", false)

            inst.SoundEmitter:PlaySound("dontstarve/common/mushroom_up")
        end

        inst.components.pickable.caninteractwith = true
    end
end

local function MushroomClose(inst, delay)
    if inst.growtask then
        inst.growtask:Cancel()
    end
    inst.growtask = nil

    if delay and delay >= 0 then
        inst.growtask = inst:DoTaskInTime(delay, MushroomClose)
    else
        if delay and delay < 0 then
            inst.AnimState:PlayAnimation("inground")
        else
            inst.AnimState:PlayAnimation("close_green")
            inst.AnimState:PushAnimation("inground", false)
            inst:DoTaskInTime(0.25, function()
                inst.SoundEmitter:PlaySound("dontstarve/common/mushroom_down")
            end)
        end

        inst.components.pickable.caninteractwith = false
    end
end

local function CheckOpenAndPicked(inst, open_delay, close_delay)
    if inst.components.pickable:CanBePicked() then
        if TheWorld.state.isnewmoon then
            MushroomOpen(inst, open_delay ~= nil and FunctionOrValue(open_delay, inst) or nil)
        else
            MushroomClose(inst, close_delay ~= nil and FunctionOrValue(close_delay, inst) or nil)
        end
    else
        inst.AnimState:PlayAnimation("picked")
    end

    if inst.grow_too_quick then
        -- inst.AnimState:SetMultColour(0.4,0.4,0.4,1)
        inst.AnimState:OverrideSymbol("mushroom_pieces", "athetos_mushroom_dirty", "mushroom_pieces")
        inst.components.pickable:ChangeProduct(QUICK_GROWTH_PRODUCT)
    else
        -- inst.AnimState:SetMultColour(1,1,1,1)
        inst.AnimState:ClearOverrideSymbol("mushroom_pieces")
        inst.components.pickable:ChangeProduct(GOOD_PRODUCT)
    end
end

local function OnPickedFn(inst)
    if inst.growtask then
        inst.growtask:Cancel()
    end
    inst.growtask = nil

    inst.grow_too_quick = false

    inst.AnimState:PlayAnimation("picked")
    inst.AnimState:ClearOverrideSymbol("mushroom_pieces")
    -- inst.AnimState:SetMultColour(1,1,1,1)
end

local function OnRegenFn(inst)
    if inst.components.pickable.targettime and GetTime() < inst.components.pickable.targettime - 5 then
        print("Oppos,the mushroom grow too quick")
        inst.grow_too_quick = true
    else
        inst.grow_too_quick = false
    end

    CheckOpenAndPicked(inst, GetRandomMinMax(0.5, 3), -1)
end

local function MakeEmptyFn(inst)
    inst.grow_too_quick = false

    inst.AnimState:PlayAnimation("picked")
    inst.AnimState:ClearOverrideSymbol("mushroom_pieces")
    -- inst.AnimState:SetMultColour(1,1,1,1)
end

local function GetStatus(inst)
    return inst.grow_too_quick and "GROW_TOO_FAST" or nil
end

local function OnSave(inst, data)
    data.grow_too_quick = inst.grow_too_quick
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.grow_too_quick ~= nil then
            inst.grow_too_quick = data.grow_too_quick
        end
    end

    CheckOpenAndPicked(inst, -1, -1)
end

return GaleEntity.CreateNormalEntity({
        prefabname = "athetos_mushroom",

        assets = assets,

        bank = "mushrooms",
        build = "athetos_mushroom",
        anim = "open_green",

        tags = { "silviculture" },

        clientfn = function(inst)
            inst.AnimState:SetRayTestOnBB(true)
        end,

        serverfn = function(inst)
            inst.grow_too_quick = false

            inst.OnSave = OnSave
            inst.OnLoad = OnLoad

            inst:AddComponent("inspectable")
            inst.components.inspectable.getstatus = GetStatus

            inst:AddComponent("pickable")
            inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
            -- inst.components.pickable:SetUp(GOOD_PRODUCT, 15)
            inst.components.pickable:SetUp(GOOD_PRODUCT, TUNING.TOTAL_DAY_TIME * 7)
            inst.components.pickable.onpickedfn = OnPickedFn
            inst.components.pickable.onregenfn = OnRegenFn
            inst.components.pickable.makeemptyfn = MakeEmptyFn

            inst:AddComponent("lootdropper")

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(function(inst, chopper)
                if inst.components.pickable:CanBePicked() then
                    inst.components.lootdropper:SpawnLootPrefab(BAD_PRODUCT)
                end

                inst:Remove()
            end)
            inst.components.workable:SetWorkLeft(1)


            -- Init state when spawned
            CheckOpenAndPicked(inst, -1, -1)

            inst:WatchWorldState("isnewmoon", function()
                CheckOpenAndPicked(inst, GetRandomMinMax(0.5, 3), GetRandomMinMax(0.5, 3))
            end)

            MakeSmallBurnable(inst)
            MakeSmallPropagator(inst)
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_mushroom_cap",
        assets = assets,

        bank = "mushrooms",
        build = "athetos_mushroom",
        anim = "green_cap",

        tags = {
            -- "cookable",
            "mushroom",
            "gale_skill_learning_item"
        },

        inventoryitem_data = {
            floatable_param = { "small", 0.1, 0.88 },
            use_gale_item_desc = true,
        },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM


            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

            -- inst:AddComponent("tradable")

            -- inst:AddComponent("cookable")
            -- inst.components.cookable.product = "athetos_mushroom_cap_cooked"

            MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
            MakeSmallPropagator(inst)
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_mushroom_cap_dirty",
        assets = assets,

        bank = "mushrooms",
        build = "athetos_mushroom_dirty",
        anim = "green_cap",

        tags = {
            "mushroom",
            "show_spoilage",
        },

        inventoryitem_data = {
            floatable_param = { "small", 0.1, 0.88 },
            use_gale_item_desc = true,
        },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"

            MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
            MakeSmallPropagator(inst)
        end,
    }),
    GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_mushroom_cap_cooked",
        assets = assets,

        bank = "mushrooms",
        build = "athetos_mushroom",
        anim = "green_cap_cooked",

        inventoryitem_data = {
            floatable_param = { "small", 0.05, 0.9 },
            use_gale_item_desc = true,
        },

        clientfn = function(inst)

        end,

        serverfn = function(inst)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

            inst:AddComponent("tradable")

            inst:AddComponent("edible")
            inst.components.edible.healthvalue = TUNING.HEALING_MED
            inst.components.edible.hungervalue = TUNING.CALORIES_MED
            inst.components.edible.sanityvalue = TUNING.SANITY_MED
            inst.components.edible.foodtype = FOODTYPE.VEGGIE

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"

            MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
            MakeSmallPropagator(inst)
        end,
    })
