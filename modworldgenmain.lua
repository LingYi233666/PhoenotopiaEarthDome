GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })


modimport("main/gale_tiles_api.lua")
-- print("Gale modworldgenmain: WORLD_TILES.GALE_JUNGLE_DEEP = ",WORLD_TILES.GALE_JUNGLE_DEEP)
local StaticLayout = require("map/static_layout")
local Layouts = require("map/layouts").Layouts
local tasks = require("map/tasks")


local function GaleAddStaticLayout(name, path)
	Layouts[name] = StaticLayout.Get(path)
	Layouts[name].ground_types[WORLD_TILES.GALE_JUNGLE] = WORLD_TILES.GALE_JUNGLE
	Layouts[name].ground_types[WORLD_TILES.GALE_JUNGLE_DEEP] = WORLD_TILES.GALE_JUNGLE_DEEP
	Layouts[name].ground_types[WORLD_TILES.GALE_SAVANNAH_DETAIL] = WORLD_TILES.GALE_SAVANNAH_DETAIL
	-- Layouts[name].ground_types[WORLD_TILES.FARMING_SOIL] = WORLD_TILES.FARMING_SOIL

	return Layouts[name]
end

GaleAddStaticLayout("zophiel_statue", "layouts/zophiel_statue")
GaleAddStaticLayout("katash_impact_zone", "layouts/katash_impact_zone")
GaleAddStaticLayout("athetos_employee_farmland1", "layouts/athetos_employee_farmland1")
GaleAddStaticLayout("athetos_employee_farmland2", "layouts/athetos_employee_farmland2")
GaleAddStaticLayout("athetos_employee_farmland3", "layouts/athetos_employee_farmland3")

local Boons = {
	["AthetosStaffBoon_Security"] = StaticLayout.Get("map/static_layouts/small_boon", {
		areas = {
			item_area = function()
				return { "msf_silencer_pistol_random" }
			end,
			resource_area = function()
				local bonus = PickSomeWithDups(math.random(1, 3),
											   { "msf_clip_pistol_random", "msf_clip_pistol_full" })
				local typhons = PickSomeWithDups(math.random(1, 3), { "typhon_mimic", })
				if math.random() <= 0.5 then
					table.insert(typhons, "typhon_phantom")
				end

				return JoinArrays(bonus, typhons)
			end,
		},
	}),


	["AthetosStaffBoon_Psychic"] = StaticLayout.Get("map/static_layouts/small_boon", {
		areas = {
			item_area = function()
				return math.random() <= 0.1
					and PickSome(1, {
						"icestaff",
						"firestaff",
						"telestaff",
						"orangestaff",
						"greenstaff",
						"yellowstaff",
					})
					or nil
			end,
			resource_area = function()
				local bonus = weighted_random_choices({
														  athetos_health_upgrade_node = 0.1,
														  athetos_neuromod = 0.2,
														  athetos_mushroom_cap = 0.3,
														  athetos_magic_potion = 0.4,
														  --   nightmarefuel = 0.6,
													  },
													  math.random(2, 4))
				local typhons = PickSomeWithDups(math.random(3, 4), { "typhon_mimic", })
				if math.random() <= 0.9 then
					table.insert(typhons, "typhon_phantom")
				end

				return JoinArrays(bonus, typhons)
			end,
		},
	}),

	["AthetosStaffBoon_Psychic_Weaver"] = StaticLayout.Get("map/static_layouts/small_boon", {
		areas = {
			item_area = function()
				return PickSome(1, {
					"icestaff",
					"firestaff",
					"telestaff",
					"orangestaff",
					"greenstaff",
					"yellowstaff",
				})
			end,
			resource_area = function()
				local bonus = weighted_random_choices({
														  athetos_health_upgrade_node = 0.1,
														  athetos_neuromod = 0.2,
														  athetos_mushroom_cap = 0.3,
														  athetos_magic_potion = 0.4,
														  nightmarefuel = 0.8,
													  },
													  math.random(2, 4))
				local typhons = PickSomeWithDups(math.random(1, 2), { "typhon_phantom", })
				table.insert(typhons, "typhon_weaver")

				return JoinArrays(bonus, typhons)
			end,
		},
	}),

	["AthetosStaffBoon_Scientist"] = StaticLayout.Get("map/static_layouts/small_boon", {
		areas = {
			item_area = function()
				return PickSome(1, {
					"plantregistryhat",
					"nutrientsgoggleshat",
					"hammer",
					"msf_silencer_pistol_random",
					"soil_amender_fermented",
				})
			end,
			resource_area = function()
				local bonus = weighted_random_choices({
														  -- 硬体实验室的索科洛夫通过逆向工程打造了一个天体英雄
														  -- 因此有极少量科学家会携带启迪碎片
														  alterguardianhatshard = 0.005,
														  athetos_neuromod = 0.1,
														  athetos_mushroom_cap = 0.1,
														  sewing_tape = 0.2,
														  athetos_fertilizer = 0.3,
														  trinket_6 = 0.2,
														  -- gears = 0.3,
														  seedpouch = 0.3,
														  blueprint = 0.3,
														  goldnugget = 0.4,
													  },
													  math.random(2, 4))
				local typhons = PickSomeWithDups(math.random(2, 4), { "typhon_mimic", })
				if math.random() <= 0.1 then
					table.insert(typhons, "typhon_phantom")
				end
				return JoinArrays(bonus, typhons)
			end,
		},
	}),


}

for name, data in pairs(Boons) do
	Layouts[name] = data
end


AddRoomPreInit("MagicalDeciduous", function(room)
	room.contents = room.contents or {}
	room.contents.countprefabs = room.contents.countprefabs or {}
	room.contents.countprefabs.gale_fran_door_lv2 = 1
end)




AddRoom("duri_forest_bg_room", {
	colour = { r = 0, g = 1, b = 0, a = 1 },
	value = WORLD_TILES.GALE_JUNGLE_DEEP,
	tags = {},
	required_prefabs = { "athetos_iron_slug" },
	contents = {
		countprefabs = {
			livingtree = 1,
			athetos_iron_slug = function()
				return 1
			end
		},

		distributepercent = 0.5,
		distributeprefabs = {
			trees = { weight = 0.7, prefabs = { "gale_forest_pillar_tree" } },

			gale_forest_hanging_vine_dynamic = 0.4,
			gale_forest_hanging_vine_static = 0.6,
			gale_forest_lightray = 0.15,

			deciduoustree = 0.15,
			evergreen_sparse = 0.1,
			flower = 1.2,
			catcoonden = 0.1,
			beehive = 0.1,
			fireflies = 0.5,
			grass = 0.6,
			sapling = 0.8,
			twiggytree = 0.8,
			ground_twigs = 0.06,
			molehill = 0.2,
			berrybush = 0.15,
			berrybush2 = 0.1,
			berrybush_juicy = 0.15,
			red_mushroom = 0.3,
			green_mushroom = 0.2,
			spiderden = 0.05,
			rocks = 0.14,
			carrot_planted = 0.2,
		},
	},

})

AddRoom("duri_forest_dragon_snare_room", {
	colour = { r = 0, g = 1, b = 0, a = 1 },
	value = WORLD_TILES.GALE_JUNGLE_DEEP,
	tags = {},
	contents = {
		countprefabs = {
			galeboss_dragon_snare = 1,
		},

		distributepercent = 0.5,
		distributeprefabs = {
			trees = { weight = 0.5, prefabs = { "gale_forest_pillar_tree" } },

			gale_forest_hanging_vine_dynamic = 0.4,
			gale_forest_hanging_vine_static = 0.6,
			gale_forest_lightray = 0.15,

			deciduoustree = 0.15,
			rabbithole = 0.6,
			evergreen_sparse = 0.1,
			flower = 1.2,
			grass = 0.6,
			sapling = 0.8,
			twiggytree = 0.8,
			ground_twigs = 0.06,
			molehill = 0.2,
			berrybush = 0.15,
			berrybush2 = 0.1,
			berrybush_juicy = 0.15,
			red_mushroom = 0.3,
			green_mushroom = 0.2,
			carrot_planted = 0.2,
		},
	},

})

AddRoom("duri_forest_zophiel_statue", {
	colour = { r = 0, g = 1, b = 0, a = 1 },
	value = WORLD_TILES.GALE_JUNGLE_DEEP,
	tags = { "ExitPiece" },
	required_prefabs = { "athetos_zophiel_statue" },
	contents = {
		countstaticlayouts = {
			zophiel_statue = 1,
		},
		distributepercent = 0.5,
		distributeprefabs = {
			trees = { weight = 0.5, prefabs = { "gale_forest_pillar_tree" } },

			gale_forest_hanging_vine_dynamic = 0.4,
			gale_forest_hanging_vine_static = 0.6,
			gale_forest_lightray = 0.15,

			deciduoustree = 0.15,
			rabbithole = 0.6,
			evergreen_sparse = 0.1,
			flower = 1.2,
			grass = 0.6,
			sapling = 0.8,
			twiggytree = 0.8,
			ground_twigs = 0.06,
			berrybush = 0.15,
			berrybush2 = 0.1,
			berrybush_juicy = 0.15,
			red_mushroom = 0.3,
			green_mushroom = 0.2,
			carrot_planted = 0.2,
		},
	},
})

AddRoom("duri_forest_farmland1", {
	colour = { r = 0, g = 1, b = 0, a = 1 },
	value = WORLD_TILES.GALE_JUNGLE_DEEP,
	tags = {},
	required_prefabs = { "athetos_iron_slug" },
	contents = {
		countstaticlayouts = {
			-- athetos_employee_farmland1 = 1,
			-- athetos_employee_farmland2 = 1,
			athetos_employee_farmland3 = 1,
		},
		distributepercent = 0.5,
		distributeprefabs = {
			trees = { weight = 0.2, prefabs = { "gale_forest_pillar_tree" } },

			gale_forest_hanging_vine_dynamic = 0.2,
			gale_forest_hanging_vine_static = 0.3,
			gale_forest_lightray = 0.1,

			deciduoustree = 0.15,
			rabbithole = 0.6,
			evergreen_sparse = 0.1,
			flower = 1.2,
			grass = 0.6,
			sapling = 0.8,
			twiggytree = 0.8,
			ground_twigs = 0.06,
			berrybush = 0.15,
			berrybush2 = 0.1,
			berrybush_juicy = 0.15,
			red_mushroom = 0.3,
			green_mushroom = 0.2,
			carrot_planted = 0.2,
		},
	},

})

AddRoom("katash_impact_zone_room", {
	colour = { r = 0, g = 1, b = 0, a = 1 },
	value = WORLD_TILES.FOREST,
	required_prefabs = {
		"galeboss_katash_spaceship",
		"galeboss_katash_safebox",
		"galeboss_katash_firepit",
		"gale_punchingbag",
	},
	contents = {
		countstaticlayouts = {
			katash_impact_zone = 1,
		},
		distributepercent = .3,
		distributeprefabs =
		{
			fireflies = 0.2,
			--evergreen = 6,
			rock1 = 0.05,
			grass = .05,
			sapling = .8,
			twiggytree = 0.8,
			ground_twigs = 0.06,
			--rabbithole=.05,
			berrybush = .03,
			berrybush_juicy = 0.015,
			red_mushroom = .03,
			green_mushroom = .02,
			trees = { weight = 6, prefabs = { "evergreen", "evergreen_sparse" } }
		},
	},

})

AddTask("duri_forest", {
	-- locks = LOCKS.NONE,
	locks = { KEYS.STONE, KEYS.WOOD, KEYS.TIER1 },
	keys_given = KEYS.NONE,
	room_choices = {
		duri_forest_bg_room = 4,
		-- duri_forest_dragon_snare_room = 1,
		duri_forest_zophiel_statue = 1,
		duri_forest_farmland1 = 1,
	},
	room_bg = WORLD_TILES.GALE_JUNGLE_DEEP,
	background_room = "duri_forest_bg_room",
	colour = { r = 0, g = 1, b = 0, a = 1 },
})

-- AddTaskSetPreInit("default", function(tasksetdata)
-- 	if type(tasksetdata)=="table" and type(tasksetdata.tasks)=="table" then
-- 		local tab= {
-- 			"duri_forest",
-- 		}
-- 		for _,v in pairs(tab) do
-- 			table.insert(tasksetdata.tasks, v)
-- 		end
-- 	end
-- end)

AddTaskSetPreInitAny(function(tasksetdata)
	if tasksetdata.location == "forest" then
		table.insert(tasksetdata.tasks, "duri_forest")
	end
end)

--

-- AddRoomPre
-- AddTaskSetPreInit("Forest hunters", function(tasksetdata)
-- 	tasksetdata.required_prefabs = tasksetdata.required_prefabs or {}
-- 	table.insert(tasksetdata.required_prefabs, "athetos_operator_medical_broken")

-- 	tasksetdata.contents = tasksetdata.contents or {}
-- 	tasksetdata.contents.countprefabs = tasksetdata.contents.countprefabs or {}
-- 	tasksetdata.contents.countprefabs.athetos_operator_medical_broken = 1
-- end)

AddRoomPreInit("MoonbaseOne", function(data)
	data.contents = data.contents or {}
	data.contents.countprefabs = data.contents.countprefabs or {}
	data.required_prefabs = data.required_prefabs or {}

	table.insert(data.required_prefabs, "athetos_operator_medical_broken")
	data.contents.countprefabs.athetos_operator_medical_broken = 1
end)

AddTaskPreInit("For a nice walk", function(tasksetdata)
	tasksetdata.room_choices = tasksetdata.room_choices or {}
	tasksetdata.room_choices.katash_impact_zone_room = 1
end)

AddLevelPreInitAny(function(level)
	if level.location == "forest" then
		if level.required_setpieces == nil then
			level.required_setpieces = {}
		end

		local my_setpieces = {}
		for i = 1, 10 do
			table.insert(my_setpieces, "AthetosStaffBoon_Security")
		end
		for i = 1, 5 do
			table.insert(my_setpieces, "AthetosStaffBoon_Psychic")
		end
		for i = 1, 3 do
			table.insert(my_setpieces, "AthetosStaffBoon_Psychic_Weaver")
		end
		for i = 1, 10 do
			table.insert(my_setpieces, "AthetosStaffBoon_Scientist")
		end

		local old_ChooseSetPieces = level.ChooseSetPieces
		assert(level.ChooseSetPieces ~= nil, "ChooseSetPieces is nil, sth wrong !!!")



		level.ChooseSetPieces = function(self, ...)
			local task_names_no_typhoon = {
				"Make a pick", "Dig that rock", "duri_forest"
			}
			local tasks = self:GetTasksForLevelSetPieces()
			local i = 1
			while i <= #tasks do
				if table.contains(task_names_no_typhoon, tasks[i].id) then
					table.remove(tasks, i)
				else
					i = i + 1
				end
			end

			assert(#tasks > 0, "Not enough tasks !!!")

			print("Aviable tasks for typhoon boon:")
			for _, v in pairs(tasks) do
				print(v.id)
			end

			for _, set_piece in pairs(my_setpieces) do
				--Get random task
				local idx = math.random(#tasks)

				if tasks[idx].random_set_pieces == nil then
					tasks[idx].random_set_pieces = {}
				end
				print("[Phoenotopia] " .. set_piece .. " added to task " .. tasks[idx].id)
				table.insert(tasks[idx].random_set_pieces, set_piece)
			end
			return old_ChooseSetPieces(self, ...)
		end
	end
end)
-- c_gonext("gale_forest_pillar_tree")
