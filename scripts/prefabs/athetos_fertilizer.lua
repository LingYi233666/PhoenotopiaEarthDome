local GaleEntity = require("util/gale_entity")

local MUSHROOM_PREFABS = {
    "red_mushroom",
    "green_mushroom",
    "blue_mushroom",
}

local function CreateTags()
    local tags = {}

    for _, v in pairs(MUSHROOM_PREFABS) do
        table.insert(tags, v .. "_targeter")
    end

    return tags
end

local function OnUseFn(inst, target, doer)
    if table.contains(MUSHROOM_PREFABS, target.prefab) then
        local grow_finished = target.components.pickable and target.components.pickable:CanBePicked()
        local tarpos = target:GetPosition()

        target:Remove()

        local new_mushroom = SpawnAt("athetos_mushroom", tarpos)
        new_mushroom.components.pickable:MakeEmpty()

        SpawnAt("statue_transition_2", tarpos)

        -- if not grow_finished then
        --     new_mushroom.components.pickable:MakeEmpty()
        -- end

        -- if inst.components.stackable ~= nil then
        --     inst.components.stackable:Get():Remove()
        -- else
        --     inst:Remove()
        -- end

        inst:Remove()

        return true
    end


    return false
end

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "athetos_fertilizer",
    assets = {
        Asset("ANIM", "anim/athetos_fertilizer.zip"),

        Asset("IMAGE", "images/inventoryimages/athetos_fertilizer.tex"),
        Asset("ATLAS", "images/inventoryimages/athetos_fertilizer.xml"),
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },



    bank = "athetos_fertilizer",
    build = "athetos_fertilizer",
    anim = "idle",

    tags = CreateTags(),

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst:AddComponent("fertilizer")
        inst.components.fertilizer.fertilizervalue = TUNING.TOTAL_DAY_TIME * 7
        inst.components.fertilizer.soil_cycles = 20
        inst.components.fertilizer:SetNutrients({ 48, 64, 48 })

        inst:AddComponent("useabletargeteditem")
        inst.components.useabletargeteditem:SetOnUseFn(OnUseFn)
    end,
})
