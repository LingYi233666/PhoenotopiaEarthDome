return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 7,
  height = 5,
  tilewidth = 64,
  tileheight = 64,
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
      width = 7,
      height = 5,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        6, 6, 6, 6, 2, 6, 6,
        6, 7, 7, 7, 2, 7, 6,
        2, 2, 2, 2, 2, 2, 2,
        6, 2, 7, 7, 7, 7, 6,
        6, 2, 6, 6, 6, 6, 6
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
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 93,
          y = 94,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 160,
          y = 92,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 221,
          y = 91,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 352,
          y = 93,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 347,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 291,
          y = 225,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 230,
          y = 225,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "rectangle",
          x = 158,
          y = 219,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "athetos_iron_slug",
          shape = "rectangle",
          x = 202,
          y = 229,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
