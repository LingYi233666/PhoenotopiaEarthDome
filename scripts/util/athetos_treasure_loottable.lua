local RandomLootCommon = {
    blueprint = 1,
    gears = 1,
    redgem = 1,
    bluegem = 1,

    gale_ckptfood_miranda = 1,
    gale_ckptfood_nutri_food = 1,
    gale_ckptfood_canned_beans = 1,
    gale_ckptfood_ancient_ration2 = 1,

    athetos_fertilizer = 0.5,
    athetos_neuromod = 1,
}

local athetos_special_items = {
    -- Medkits
    "athetos_medkit_small",
    "athetos_medkit_mid",
    "athetos_medkit_big",

    -- Status upgrade
    "athetos_health_upgrade_node",

    -- Athetos Weapons
    "athetos_grenade_elec",

    -- MSF weapons
    "msf_silencer_pistol",
    "msf_clip_pistol",
    "msf_ammo_9mm_pistol",

    -- Human skills
    "athetos_fertilizer",
    "athetos_mushroom_cap",

    -- Typhon skills
    "athetos_neuromod",

    -- Production process
    "athetos_production_process_athetos_fertilizer",
    "athetos_production_process_athetos_neuromod",
}

local internalloot = {
    gale_fran_door_item = {
        count = 5,
        loot = {
            gale_fran_door_item = 1,
        },
        random_loot = RandomLootCommon,
        chance_loot =
        {
            athetos_production_process_gale_fran_door_item = 0.1,
        },
    },

    athetos_production_process_gale_fran_door_item = {
        count = 10,
        loot = {
            athetos_production_process_gale_fran_door_item = 1,
        },
        random_loot = RandomLootCommon,
    },

    medkits = {
        count = 15,
        loot = {
            athetos_medkit_small = 1,
        },
        random_loot = MergeMaps(RandomLootCommon, {
            athetos_medkit_big = 1,
            athetos_medkit_mid = 1,
        }),
        chance_loot =
        {
            athetos_health_upgrade_node = 0.1,
            athetos_production_process_athetos_medkit_small = 0.1,
            athetos_production_process_athetos_medkit_mid = 0.05,
            athetos_production_process_athetos_medkit_big = 0.025,
        },
    },

    medkits_small_production_process = {
        count = 9,
        loot = {
            athetos_production_process_athetos_medkit_small = 1,
        },
        random_loot =
        {
            athetos_production_process_athetos_health_upgrade_node = 1,
            athetos_production_process_athetos_medkit_mid = 1,
            athetos_production_process_athetos_medkit_big = 1,
        },
    },

    medkits_mid_production_process = {
        count = 5,
        loot = {
            athetos_production_process_athetos_medkit_mid = 1,
        },
        random_loot =
        {
            athetos_production_process_athetos_health_upgrade_node = 1,
            athetos_production_process_athetos_medkit_small = 1,
            athetos_production_process_athetos_medkit_big = 1,
        },
    },

    medkits_big_production_process = {
        count = 5,
        loot = {
            athetos_production_process_athetos_medkit_big = 1,
        },
        random_loot =
        {
            athetos_production_process_athetos_health_upgrade_node = 1,
            athetos_production_process_athetos_medkit_mid = 1,
            athetos_production_process_athetos_medkit_small = 1,
        },
    },


    health_upgrade_node = {
        count = 15,
        loot = {
            athetos_health_upgrade_node = 1,
        },
        random_loot = RandomLootCommon,
    },

    health_upgrade_node_production_process = {
        count = 5,
        loot = {
            athetos_production_process_athetos_health_upgrade_node = 1,
        },
        chance_loot =
        {
            athetos_health_upgrade_node = 0.5,
        },
        random_loot = RandomLootCommon,
    },

    gardening = {
        count = 15,
        loot = {
            athetos_fertilizer = 2,
            athetos_mushroom_cap = 1,
        },
        random_loot = MergeMaps(RandomLootCommon, {
            athetos_fertilizer = 0.5,
            athetos_mushroom_cap = 0.5,
        }),
    },

    fertilizer_production_process = {
        count = 10,
        loot = {
            athetos_production_process_athetos_fertilizer = 1,
        },
        random_loot = MergeMaps(RandomLootCommon, {
            athetos_fertilizer = 0.5,
            athetos_mushroom_cap = 0.5,
        }),
    },



    silencer_pistol = {
        count = 20,
        custom_lootfn = function(lootlist)
            lootlist.msf_silencer_pistol_full = math.random(1, 2)
            lootlist.msf_clip_pistol_full = math.random(3, 4)
        end
    },


    silencer_pistol_production_process = {
        count = 10,
        loot = {
            athetos_production_process_msf_silencer_pistol = 1,
            athetos_production_process_msf_clip_pistol = 1,
            athetos_production_process_msf_ammo_9mm_pistol = 1,
        },
        random_loot = RandomLootCommon,
    },

    grenade_elec = {
        count = 15,
        random_loot = RandomLootCommon,
        custom_lootfn = function(lootlist)
            lootlist.athetos_grenade_elec = math.random(2, 4)
        end,
    },

    grenade_elec_production_process = {
        count = 10,
        loot = {
            athetos_production_process_athetos_grenade_elec = 1,
        },
        custom_lootfn = function(lootlist)
            lootlist.athetos_grenade_elec = math.random(1, 4)
        end,
        random_loot = RandomLootCommon,
    },

    neuromod = {
        count = 5,
        custom_lootfn = function(lootlist)
            lootlist.athetos_neuromod = math.random(1, 3)
        end
    },


    neuromod_production_process_1 = {
        count = 3,
        loot = {
            athetos_production_process_athetos_neuromod = 1,
        },
    },

    turrets = {
        count = 7,
        loot = {
            athetos_portable_turret_item = 1,
        },
    },

    turrets_production_process = {
        count = 5,
        loot = {
            athetos_production_process_athetos_portable_turret_item = 1,
        },
    },

    athetos_psychostatic_cutter = {
        count = 5,
        loot = {
            athetos_psychostatic_cutter = 1,
        },
        random_loot = RandomLootCommon,
    },


    athetos_magic_potion = {
        count = 15,
        custom_lootfn = function(lootlist)
            lootlist.athetos_magic_potion = math.random(2, 4)
        end,
        random_loot = RandomLootCommon,
    },

    athetos_magic_potion_production_process = {
        count = 5,
        loot = {
            athetos_production_process_athetos_magic_potion = 1,
        },
        custom_lootfn = function(lootlist)
            lootlist.athetos_magic_potion = math.random(1, 4)
        end,
        random_loot = RandomLootCommon,
    },



    --[[
	["sample"] =
	{
		--All items in loot is given when a treasure is dug up	
		loot =
		{
			goldnugget = 2,
			redgem = 4
		},

		--'num_random_loot' items are given from random_loot (a weighted table)
		num_random_loot = 1,
		random_loot =
		{
			purplegem = 1,
			orangegem = 1,
			yellowgem = 1,
			greengem = 1,
			redgem = 5,
			bluegem = 5,
		},

		--Every item in chance_loot has a custom chance of being given
		--Possible for nothing or everything to be given
		chance_loot =
		{
			goldnugget = 0.25,
			goldnugget = 0.25,
			bluegem = 0.1
		},

		--A custom function used to give items
		-- custom_lootfn = function(lootlist) end
	},
	--]]
}

-- print(GetTableSize(require("util/athetos_treasure_loottable")))
return internalloot
