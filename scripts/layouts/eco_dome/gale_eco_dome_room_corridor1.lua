return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 7,
  height = 1,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 38,
  properties = {},
  tilesets = {
    {
      name = "gale_interior_floors",
      firstgid = 1,
      filename = "../../../tiled/gale_interior_floors.tsx",
      exportfilename = "../gale_interior_floors.lua"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 7,
      height = 1,
      id = 1,
      name = "图块层 1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        8, 8, 8, 8, 8, 8, 8
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "对象层 1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 12,
          name = "door_up3",
          class = "gale_house_door",
          shape = "point",
          x = 336,
          y = 1.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\""
          }
        },
        {
          id = 11,
          name = "door_up2",
          class = "gale_house_door",
          shape = "point",
          x = 224,
          y = 1.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\" "
          }
        },
        {
          id = 1,
          name = "door_up1",
          class = "gale_house_door",
          shape = "point",
          x = 112,
          y = 1.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"plate\" "
          }
        },
        {
          id = 2,
          name = "door_left",
          class = "gale_house_door",
          shape = "point",
          x = 1.6,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\" "
          }
        },
        {
          id = 3,
          name = "door_right",
          class = "gale_house_door",
          shape = "point",
          x = 446.4,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\" "
          }
        },
        {
          id = 4,
          name = "pillar_left_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 0,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "pillar_right_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 448,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "pillar_left_up",
          class = "gale_eco_dome_room_pillar_corner",
          shape = "point",
          x = 0,
          y = 0,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "pillar_right_up",
          class = "gale_eco_dome_room_pillar_corner",
          shape = "point",
          x = 448,
          y = 0,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "gale_forest_hanging_vine_static_16",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 42.6667,
          y = 46.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 14,
          name = "gale_forest_hanging_vine_static_15",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 90,
          y = 29.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 15,
          name = "gale_forest_hanging_vine_static_14",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 120.667,
          y = 38.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 16,
          name = "gale_forest_hanging_vine_static_13",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 155.333,
          y = 34.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 17,
          name = "gale_forest_hanging_vine_static_12",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 187.333,
          y = 38,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 18,
          name = "gale_forest_hanging_vine_static_11",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 212.667,
          y = 26.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 19,
          name = "gale_forest_hanging_vine_static_10",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 234,
          y = 44,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 20,
          name = "gale_forest_hanging_vine_static_9",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 268,
          y = 30.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 21,
          name = "gale_forest_hanging_vine_static_8",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 288,
          y = 44.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 22,
          name = "gale_forest_hanging_vine_static_7",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 318.667,
          y = 28.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 23,
          name = "gale_forest_hanging_vine_static_6",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 347.333,
          y = 36.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 24,
          name = "gale_forest_hanging_vine_static_5",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 372,
          y = 37.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 25,
          name = "gale_forest_hanging_vine_static_4",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 394.667,
          y = 45.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 26,
          name = "gale_forest_hanging_vine_static_3",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 419.333,
          y = 35.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 27,
          name = "gale_forest_hanging_vine_static_2",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 101.333,
          y = 46,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 28,
          name = "gale_forest_hanging_vine_static_1",
          class = "gale_forest_hanging_vine_static",
          shape = "point",
          x = 156.667,
          y = 45.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 29,
          name = "gale_forest_lightray_7",
          class = "gale_forest_lightray",
          shape = "point",
          x = 54.6667,
          y = 31.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 31,
          name = "gale_forest_lightray_6",
          class = "gale_forest_lightray",
          shape = "point",
          x = 118,
          y = 21.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 32,
          name = "gale_forest_lightray_5",
          class = "gale_forest_lightray",
          shape = "point",
          x = 182.667,
          y = 30.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 33,
          name = "gale_forest_lightray_4",
          class = "gale_forest_lightray",
          shape = "point",
          x = 244,
          y = 28.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 34,
          name = "gale_forest_lightray_3",
          class = "gale_forest_lightray",
          shape = "point",
          x = 304,
          y = 30.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 35,
          name = "gale_forest_lightray_2",
          class = "gale_forest_lightray",
          shape = "point",
          x = 374,
          y = 29.3333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 37,
          name = "gale_forest_lightray_1",
          class = "gale_forest_lightray",
          shape = "point",
          x = 398,
          y = 40.6667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        }
      }
    }
  }
}
