return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 16,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 16,
      height = 16,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 209,
          y = 140,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 30,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 46,
          y = 85,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["scenario"] = "chest_athetos_portal"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 142,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 78,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 222,
          y = 117,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 94,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 222,
          y = 69,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 94,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 101,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 14,
          y = 133,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 222,
          y = 181,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 62,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 222,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 174,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 222,
          y = 165,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 183,
          y = 121,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 222,
          y = 133,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 158,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 158,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 222,
          y = 101,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 206,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 14,
          y = 117,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_stone",
          shape = "rectangle",
          x = 222,
          y = 149,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 165,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 46,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 30,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 45,
          y = 166,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 190,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 78,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 222,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 110,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 206,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 62,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 85,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 126,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 142,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 67,
          y = 150,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 174,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 190,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 14,
          y = 69,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 46,
          y = 197,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 74,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 206,
          y = 53,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 119,
          y = 84,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 147,
          y = 95,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 128,
          y = 154,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 190,
          y = 171,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 88,
          y = 114,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 99,
          y = 143,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 164,
          y = 137,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sapling",
          shape = "rectangle",
          x = 148,
          y = 184,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_fran_door_item",
          shape = "rectangle",
          x = 198,
          y = 93,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
