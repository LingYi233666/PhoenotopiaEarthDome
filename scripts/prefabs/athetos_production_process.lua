require "recipes"

local GaleEntity = require("util/gale_entity")

local assets =
{
    Asset("ANIM", "anim/blueprint.zip"),
    Asset("ANIM", "anim/blueprint_rare.zip"),
    Asset("INV_IMAGE", "blueprint"),
    Asset("INV_IMAGE", "blueprint_rare"),
}

local function OnLoad(inst, data)
    if data ~= nil then
        if data.product ~= nil then
            inst.product = data.product
            inst.components.named:SetName((STRINGS.NAMES[string.upper(inst.product)] or STRINGS.NAMES.UNKNOWN) ..
                " " .. STRINGS.NAMES.ATHETOS_PRODUCTION_PROCESS)

            local prefabname = "athetos_production_process_" .. data.product
            local desc_tab = STRINGS.GALE_ITEM_DESC[prefabname:upper()]
            if desc_tab and desc_tab.SIMPLE then
                inst.components.gale_item_desc:SetSimpleDesc(desc_tab.SIMPLE)
            end

            if desc_tab and desc_tab.COMPLEX then
                inst.components.gale_item_desc:SetComplexDesc(desc_tab.COMPLEX)
            end
        end
        if data.plans ~= nil then
            inst.plans = data.plans
            inst.components.athetos_production_process:SetRecipes(inst.plans)
        end
    end
end

local function OnSave(inst, data)
    data.product = inst.product
    data.plans = inst.plans
end


local function OnTeach(inst, learner)
    for _, v in pairs(inst.components.athetos_production_process.recipes) do
        -- learner:PushEvent("learnrecipe", { teacher = inst, recipe = v })
        SendRPCToClient(CLIENT_RPC.LearnBuilderRecipe, learner.userid, v)
        break
    end

    SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["play_clientside_sound"], learner.userid,
        "gale_sfx/other/athetos_production_process_unlock", true, true)
end

local function CanBlueprintSpecificRecipe(recipe)
    --Exclude crafting station and character specific
    if recipe.nounlock or recipe.builder_tag ~= nil then
        return false
    end
    for k, v in pairs(recipe.level) do
        if v > 0 then
            return true
        end
    end
    --Exclude TECH.NONE
    return false
end

local function CreateProductionProcess(product, plans)
    local prefabname = product ~= nil and ("athetos_production_process_" .. product) or "athetos_production_process"

    return GaleEntity.CreateNormalInventoryItem({
        prefabname = prefabname,

        assets = assets,



        bank = "blueprint_rare",
        build = "blueprint_rare",
        anim = "idle",


        inventoryitem_data = {
            imagename = "blueprint_rare",
            atlasname_override = "images/inventoryimages1.xml",
            floatable_param = { "med", nil, 0.75 },
            use_gale_item_desc = true,
        },

        clientfn = function(inst)
            inst:SetPrefabName("athetos_production_process")
        end,

        serverfn = function(inst)
            inst.OnLoad = OnLoad
            inst.OnSave = OnSave

            inst:AddComponent("erasablepaper")


            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

            inst:AddComponent("named")

            inst:AddComponent("athetos_production_process")
            inst.components.athetos_production_process.onteach = OnTeach

            if plans ~= nil then
                inst.product = product
                inst.plans = plans

                inst.components.athetos_production_process:SetRecipes(inst.plans)

                inst.components.named:SetName((STRINGS.NAMES[string.upper(inst.product)] or STRINGS.NAMES.UNKNOWN) ..
                    " " .. STRINGS.NAMES.ATHETOS_PRODUCTION_PROCESS)

                local desc_tab = STRINGS.GALE_ITEM_DESC[prefabname:upper()]
                if desc_tab and desc_tab.SIMPLE then
                    inst.components.gale_item_desc:SetSimpleDesc(desc_tab.SIMPLE)
                end

                if desc_tab and desc_tab.COMPLEX then
                    inst.components.gale_item_desc:SetComplexDesc(desc_tab.COMPLEX)
                end
            end
        end,
    })
end

local prefabs = {
    CreateProductionProcess(),
}
local force_include_recipes = {
    "gale_fran_door_item",
}
local force_exclude_recipes = {
    "athetos_amulet_berserker_fixed", "athetos_amulet_berserker"
}

local recipe_map = {
    -- product = {
    --     plan_name1,
    --     plan_name2,
    -- }

    -- gale_fran_door_item = {
    --     "gale_fran_door_item",
    -- },

}
for k, v in pairs(AllRecipes) do
    if (k:find("athetos_") or k:find("msf_") or table.contains(force_include_recipes, k))
        and not table.contains(force_exclude_recipes, k)
        and CanBlueprintSpecificRecipe(v) then
        local product = v.product
        if recipe_map[product] == nil then
            recipe_map[product] = {}
        end

        table.insert(recipe_map[product], v.name)
    end
end

for product, plans in pairs(recipe_map) do
    table.insert(prefabs, CreateProductionProcess(product, plans))
end

-- for k, v in pairs(AllRecipes) do
--     if (k:find("athetos_") or k:find("msf_") or table.contains(force_include_recipes,k)) and CanBlueprintSpecificRecipe(v) then
--         -- table.insert(prefabs, Prefab(string.lower(k or "NONAME").."_blueprint", MakeSpecificBlueprint(k), assets))
--         table.insert(prefabs,CreateProductionProcess(k))
--     end
-- end

return unpack(prefabs)
