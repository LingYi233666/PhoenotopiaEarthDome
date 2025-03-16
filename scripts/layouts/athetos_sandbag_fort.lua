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
        0, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0
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
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 32,
          y = 32,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 32,
          y = 64,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 64,
          y = 32,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 192,
          y = 64,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 192,
          y = 32,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 160,
          y = 32,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 32,
          y = 192,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 64,
          y = 192,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 32,
          y = 160,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 160,
          y = 192,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 192,
          y = 160,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_sandbag",
          shape = "rectangle",
          x = 192,
          y = 192,
          width = 32,
          height = 32,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "athetos_portable_turret",
          shape = "rectangle",
          x = 56,
          y = 120,
          width = 16,
          height = 16,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 113,
          y = 105,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 163,
          y = 143,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 101,
          y = 165,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 18,
          y = 111,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 44,
          y = 146,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 140,
          y = 194,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 124,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 87,
          y = 243,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 237,
          y = 76,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 211,
          y = 131,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 247,
          y = 169,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 142,
          y = 37,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 109,
          y = 19,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "nightmarefuel",
          shape = "rectangle",
          x = 145,
          y = 86,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "athetos_production_process_athetos_portable_turret_item",
          shape = "rectangle",
          x = 126,
          y = 138,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
