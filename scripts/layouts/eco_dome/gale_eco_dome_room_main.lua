return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 2,
  height = 2,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 18,
  properties = {
    ["centeral_z_offset"] = "-2"
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
      height = 2,
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
        2, 2,
        2, 2
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
          id = 6,
          name = "door_up",
          class = "gale_house_door",
          shape = "point",
          x = 64,
          y = 33.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\" "
          }
        },
        {
          id = 7,
          name = "door_left",
          class = "gale_house_door",
          shape = "point",
          x = 1.6,
          y = 80,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"plate\""
          }
        },
        {
          id = 8,
          name = "door_right",
          class = "gale_house_door",
          shape = "point",
          x = 126.4,
          y = 80,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\" \nent:SetEnabled(false)\nent.key_prefab = \"atrium_key\""
          }
        },
        {
          id = 9,
          name = "pillar_left_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 0,
          y = 128,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "pillar_right_down",
          class = "gale_eco_dome_room_pillar_sidewall",
          shape = "point",
          x = 128,
          y = 128,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "pillar_left_up",
          class = "gale_eco_dome_room_pillar_corner",
          shape = "point",
          x = 0,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "pillar_right_up",
          class = "gale_eco_dome_room_pillar_corner",
          shape = "point",
          x = 128,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "vfx_wall",
          class = "1",
          shape = "point",
          x = 0,
          y = 128,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "vfx_wall",
          class = "2",
          shape = "point",
          x = 0,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 16,
          name = "vfx_wall",
          class = "3",
          shape = "point",
          x = 128,
          y = 32,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 17,
          name = "vfx_wall",
          class = "4",
          shape = "point",
          x = 128,
          y = 128,
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
