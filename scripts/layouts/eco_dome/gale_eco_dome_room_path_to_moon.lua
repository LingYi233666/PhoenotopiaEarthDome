return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 2,
  height = 1,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 9,
  properties = {
    ["wall_texture"] = "shop_wall_floraltrim2"
  },
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
      width = 2,
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
        10, 10
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
            ["fn"] = "ent.style = \"stone\""
          }
        },
        {
          id = 2,
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
          id = 3,
          name = "pillar_right_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 128,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
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
          id = 5,
          name = "door_up",
          class = "gale_house_door",
          shape = "point",
          x = 109.364,
          y = 1.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\"\nent.Transform:SetScale(0.7,0.7,0.7)"
          }
        }
      }
    }
  }
}
