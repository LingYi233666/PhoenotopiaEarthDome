local GaleCondition = require("util/gale_conditions")

local function GetNum(params, ...)
    local result = 0

    for _, val in pairs({ ... }) do
        if type(val) == "string" then
            result = result + (params[val] or 0)
        elseif type(val) == "table" then
            for _, v in pairs(val) do
                result = result + (params[v] or 0)
            end
        end
    end

    return result
end

-- For foods can't be cooked,but can get by other ways
local function CantCookTestFn()
    return false
end

local function CookTime(t)
    -- Quick cook debug
    -- return 2 * FRAMES / 20.0

    return t / 20.0
end


-- 1 cooktime = 20 seconds
-- oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_SWAP_HEALTH_AND_SANITY,
-- potlevel = "low",
-- unlock = {"meat","meat","snake_bone","snake_bone"},
local foods = {
    gale_ckptfood_ancient_ration2 = {
        test = CantCookTestFn,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDLARGE,
        hunger = TUNING.CALORIES_HUGE,
        perishtime = nil,
        sanity = TUNING.SANITY_TINY,
        cooktime = nil,
        floater = { nil, 0.1 },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.3, 1.3, 1.3)
        end,
    },

    gale_ckptfood_astro_lunch = {
        test = function(cooker, names, tags)
            return GetNum(tags, "meat") >= 2
                and GetNum(tags, "monster") <= 0
                and GetNum(tags, "egg") >= 1
                and GetNum(names, "corn", "corn_cooked") >= 1
        end,
        priority = 15,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_HUGE + 25,
        perishtime = TUNING.PERISH_PRESERVED,
        sanity = TUNING.SANITY_SMALL,
        cooktime = CookTime(50),
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "meat", 2 }, { "bird_egg", 1 }, { "corn", 1 } } },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.2, 1.2, 1.2)
        end,
    },

    gale_ckptfood_blue_lobster_special = {
        test = function(cooker, names, tags)
            return GetNum(names, "wobster_sheller_land") >= 1
                and GetNum(names, "asparagus", "asparagus_cooked") >= 1
                and GetNum(names, "onion", "onion_cooked") >= 1
                and GetNum(names, "potato", "potato_cooked") >= 1
        end,
        priority = 35,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE * 2,
        hunger = TUNING.CALORIES_HUGE,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_HUGE * 1.25,
        cooktime = CookTime(36),
        potlevel = "med",
        floater = { "med", 0.05, { 0.65, 0.6, 0.65 } },
        card_def = { ingredients = { { "wobster_sheller_land", 1 }, { "asparagus", 1 }, { "onion", 1 }, { "potato", 1 } } },
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_AND_RECOVER_STAMINA_OVER_TIME,
        oneatenfn = function(inst, eater)
            local max_power = 4
            local cur_power = GaleCondition.GetConditionStacks(eater, "condition_power")
            local delta_power = max_power - cur_power
            if delta_power > 0 then
                GaleCondition.AddCondition(eater, "condition_power", math.min(2, delta_power))
            end

            if eater.components.gale_stamina then
                local cur_stack = GaleCondition.GetConditionStacks(eater, "condition_stamina_recover")
                local max_stack = 45
                if cur_stack < max_stack then
                    GaleCondition.AddCondition(eater, "condition_stamina_recover", max_stack - cur_stack)
                end
            end
        end,
        extrafn = function(inst)
            inst.AnimState:SetScale(1.1, 1.1, 1.1)
        end,
    },

    gale_ckptfood_calory_slush2 = {
        test = function(cooker, names, tags)
            return GetNum(tags, "veggie") >= 1
                and GetNum(tags, "fruit") >= 1
                and GetNum(tags, "frozen") >= 1
                and GetNum(tags, "inedible") <= 0
        end,
        priority = 10,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_SMALL,
        cooktime = CookTime(10),
        potlevel = "low",
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "berries_juicy", 2 }, { "ice", 1 }, { "carrot", 1 } } },
    },

    gale_ckptfood_canned_beans = {
        test = CantCookTestFn,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = nil,
        sanity = TUNING.SANITY_TINY,
        cooktime = nil,
        floater = { nil, 0.1 },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.2, 1.2, 1.2)
        end,
    },

    gale_ckptfood_honey_brew = {
        test = function(cooker, names, tags)
            return GetNum(tags, "fruit") >= 1
                and GetNum(tags, "sweetener") >= 2
                and GetNum(tags, "inedible") <= 0
        end,
        priority = 10,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_MEDSMALL,
        perishtime = TUNING.PERISH_FAST,
        sanity = TUNING.SANITY_MED,
        cooktime = CookTime(15),
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA_OVER_TIME,
        oneatenfn = function(inst, eater)
            if eater.components.gale_stamina then
                local cur_stack = GaleCondition.GetConditionStacks(eater, "condition_stamina_recover")
                local max_stack = 75
                if cur_stack < max_stack then
                    GaleCondition.AddCondition(eater, "condition_stamina_recover", max_stack - cur_stack)
                end
            end
        end,
        potlevel = "low",
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "berries", 2 }, { "honey", 2 } } },
    },

    gale_ckptfood_house_soup = {
        test = function(cooker, names, tags)
            return GetNum(tags, "veggie") >= 2
                and GetNum(names, "drumstick", "drumstick_cooked") >= 1
                and GetNum(tags, "inedible") <= 0
                and GetNum(tags, "fruit") <= 0
            -- and GetNum(tags,"meat") >= 0.5
        end,
        priority = 10,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_HUGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = CookTime(35),
        potlevel = "low",
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "carrot", 1 }, { "cactus_meat", 1 }, { "eggplant", 1 }, { "drumstick", 1 } } },
    },

    gale_ckptfood_miranda = {
        test = CantCookTestFn,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_SMALL,
        perishtime = nil,
        sanity = TUNING.SANITY_MEDLARGE,
        cooktime = nil,
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA_OVER_TIME,
        oneatenfn = function(inst, eater)
            if eater.components.gale_stamina then
                local cur_stack = GaleCondition.GetConditionStacks(eater, "condition_stamina_recover")
                local max_stack = 30
                if cur_stack < max_stack then
                    GaleCondition.AddCondition(eater, "condition_stamina_recover", max_stack - cur_stack)
                end
            end
        end,
        floater = { nil, 0.1 },
    },

    gale_ckptfood_nutri_food = {
        test = CantCookTestFn,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_SMALL,
        perishtime = nil,
        sanity = TUNING.SANITY_TINY,
        cooktime = nil,
        floater = { nil, 0.1 },

        -- OnPutInInventory = function(inst, owner)
        --     if owner ~= nil and owner:IsValid() then
        --         owner:PushEvent("learncookbookstats", "gale_ckptfood_nutri_meal")
        --     end
        -- end,
        extrafn = function(inst)
            inst:AddComponent("cookable")
            inst.components.cookable.product = "gale_ckptfood_nutri_meal"
            -- inst.components.cookable:SetOnCookedFn(function(inst, cooker, chef)
            --     chef:PushEvent("learncookbookrecipe", {product = "gale_ckptfood_nutri_meal", ingredients = {"gale_ckptfood_nutri_food"}})
            -- end)
        end,
    },

    gale_ckptfood_nutri_meal = {
        test = CantCookTestFn,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MEDSMALL,
        hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_SUPERFAST,
        sanity = TUNING.SANITY_SMALL,
        cooktime = nil,
        floater = { nil, 0.1 },
    },

    gale_ckptfood_potato_lunch = {
        test = function(cooker, names, tags)
            return GetNum(names, "potato", "potato_cooked") >= 2
                and GetNum(tags, "meat") >= 1
                and GetNum(tags, "monster") <= 0
        end,
        priority = 11,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDSMALL,
        hunger = TUNING.CALORIES_HUGE + 15,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = CookTime(40),
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "potato", 2 }, { "meat", 1 }, { "smallmeat", 1 } } },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.2, 1.2, 1.2)
        end,
    },

    gale_ckptfood_pulled_pork_lunch = {
        test = function(cooker, names, tags)
            return GetNum(names, "pepper", "pepper_cooked") >= 1
                and GetNum(tags, "meat") >= 3
                and GetNum(tags, "monster") <= 0
        end,
        priority = 12,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDSMALL,
        hunger = TUNING.CALORIES_MOREHUGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = CookTime(70),
        potlevel = "high",
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "meat", 3 }, { "pepper", 1 } } },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.1, 1.1, 1.1)
        end,
    },

    gale_ckptfood_rolled_omelet = {
        test = function(cooker, names, tags)
            return GetNum(tags, "egg") >= 3
                and GetNum(tags, "veggie") >= 1
                and GetNum(tags, "inedible") <= 0
        end,
        priority = 5,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDSMALL,
        hunger = TUNING.CALORIES_LARGE + 5,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = CookTime(15),
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "bird_egg", 3 }, { "onion", 1 } } },
    },

    gale_ckptfood_spicy_noodles = {
        test = function(cooker, names, tags)
            return GetNum(tags, "egg") >= 1
                and GetNum(names, "pepper", "pepper_cooked") >= 1
                and GetNum(names, "red_cap", "blue_cap", "green_cap", "red_cap_cooked", "blue_cap_cooked",
                    "green_cap_cooked") >= 1
                and GetNum(names, "corn") >= 1
                and GetNum(tags, "fruit") <= 0
                and GetNum(tags, "sweetener") <= 0
                and GetNum(tags, "inedible") <= 0
        end,
        priority = 10,
        foodtype = FOODTYPE.MEAT,
        health = 0,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = CookTime(25),
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_WITH_THRESHOLD,
        oneatenfn = function(inst, eater)
            local max_power = 3
            local cur_power = GaleCondition.GetConditionStacks(eater, "condition_power")
            local delta_power = max_power - cur_power
            if delta_power > 0 then
                GaleCondition.AddCondition(eater, "condition_power", math.min(2, delta_power))
            end
        end,
        potlevel = "low",
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "bird_egg", 1 }, { "pepper", 1 }, { "red_cap_cooked", 1 }, { "corn", 1 } } },
        extrafn = function(inst)
            inst.AnimState:SetScale(1.3, 1.3, 1.3)
        end,
    },

    gale_ckptfood_honey_drop = {
        test = function(cooker, names, tags)
            return GetNum(tags, "sweetener") >= 4
                and GetNum(tags, "inedible") <= 0
                and GetNum(tags, "meat") <= 0
        end,
        priority = 11,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_TINY,
        hunger = TUNING.CALORIES_TINY,
        perishtime = nil, -- not perishable
        sanity = TUNING.SANITY_SUPERTINY,
        cooktime = CookTime(10),
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA,
        oneatenfn = function(inst, eater)
            if eater.components.gale_stamina then
                eater.components.gale_stamina:DoDelta(10)
                eater.components.gale_stamina:Resume()
            end
        end,
        potlevel = "med",
        tags = { "honeyed" },
        stacksize = 3,
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "honey", 4 } } },
    },

    gale_ckptfood_dog_cookie = {
        test = function(cooker, names, tags)
            local num_monster = GetNum(tags, "monster")
            local num_meat = GetNum(tags, "meat")

            return num_monster > 0
                and num_meat > 0
                and num_meat <= num_monster
        end,
        priority = 0,
        foodtype = FOODTYPE.MEAT,
        secondaryfoodtype = FOODTYPE.MONSTER,
        health = TUNING.HEALING_TINY,
        hunger = TUNING.CALORIES_TINY,
        perishtime = nil, -- not perishable
        sanity = 0,
        cooktime = CookTime(10),
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_DOG_FOOD,
        oneatenfn = function(inst, eater)
            if eater.prefab == "galeboss_katash"
                -- or eater.prefab == "critter_puppy"
                or eater.prefab == "wobysmall"
                or eater:HasTag("critter")
                or eater:HasTag("woby")
                or eater:HasTag("hound")
                or eater:HasTag("warg") then
                if eater.components.health then
                    eater.components.health:DoDelta(TUNING.HEALING_HUGE)
                end
                if eater.components.hunger then
                    eater.components.hunger:DoDelta(TUNING.CALORIES_LARGE)
                end
                if eater.components.sanity then
                    eater.components.sanity:DoDelta(TUNING.SANITY_LARGE)
                end
            end
        end,
        potlevel = "high",
        stacksize = 2,
        floater = { nil, 0.1 },
        card_def = { ingredients = { { "berries", 1 }, { "monstermeat", 3 } } },
    },

    -- TODO: Add anims
    -- gale_ckptfood_super_mushroom_dinner = {
    --     test = function(cooker, names, tags)
    --         return GetNum(names, "athetos_mushroom_cap") > 0
    --     end,
    --     priority = 0,
    --     foodtype = FOODTYPE.VEGGIE,
    --     health = 250,
    --     hunger = TUNING.CALORIES_SMALL,
    --     perishtime = TUNING.PERISH_SLOW,
    --     sanity = TUNING.SANITY_TINY,
    --     cooktime = CookTime(30),
    --     oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_AND_RECOVER_STAMINA_OVER_TIME,
    --     oneatenfn = function(inst, eater)
    --         local max_power = 10
    --         local cur_power = GaleCondition.GetConditionStacks(eater, "condition_power")
    --         local delta_power = max_power - cur_power
    --         if delta_power > 0 then
    --             GaleCondition.AddCondition(eater, "condition_power", math.min(4, delta_power))
    --         end

    --         if eater.components.gale_stamina then
    --             local cur_stack = GaleCondition.GetConditionStacks(eater, "condition_stamina_recover")
    --             local max_stack = 120
    --             if cur_stack < max_stack then
    --                 GaleCondition.AddCondition(eater, "condition_stamina_recover", max_stack - cur_stack)
    --             end
    --         end
    --     end,
    --     potlevel = "high",
    --     stacksize = 2,
    --     floater = { nil, 0.1 },
    --     card_def = { ingredients = { { "berries", 1 }, { "athetos_mushroom_cap", 3 } } },
    -- },
}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.overridebuild = "gale_ckptfoods1"
    -- v.cookbook_atlas = "images/inventoryimages/"..k..".xml"
    v.cookbook_atlas = "images/ui/cookbook_images/" .. k .. ".xml"
end

return foods
