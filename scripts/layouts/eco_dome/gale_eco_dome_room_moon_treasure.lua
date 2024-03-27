return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 1,
  height = 1,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 10,
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
      width = 1,
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
        7
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
          id = 1,
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
          id = 2,
          name = "pillar_right_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 64,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
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
          id = 4,
          name = "pillar_right_up",
          class = "gale_eco_dome_room_pillar_corner",
          shape = "point",
          x = 64,
          y = 0,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "door_down",
          class = "gale_house_door",
          shape = "point",
          x = 32,
          y = 62.4,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\""
          }
        },
        {
          id = 6,
          name = "icebox_1",
          class = "icebox",
          shape = "point",
          x = 17.25,
          y = 18.75,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "icebox_2",
          class = "icebox",
          shape = "point",
          x = 34.75,
          y = 23.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "icebox_3",
          class = "icebox",
          shape = "point",
          x = 51.75,
          y = 21.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
