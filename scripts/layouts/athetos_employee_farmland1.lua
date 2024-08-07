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
        6, 6, 6, 6, 6, 6, 6,
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
          type = "athetos_iron_slug",
          shape = "rectangle",
          x = 260,
          y = 227,
          width = 32,
          height = 13,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 95,
          y = 94,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 159,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 221,
          y = 95,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 354,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 353,
          y = 221,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 288,
          y = 220,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 221,
          y = 218,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gale_farm_soil_creater",
          shape = "ellipse",
          x = 157,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
