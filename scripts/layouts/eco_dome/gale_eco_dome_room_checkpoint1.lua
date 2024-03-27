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
  nextobjectid = 29,
  properties = {
    ["centeral_z_offset"] = "-3",
    ["wall_texture"] = "shop_wall_marble"
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
        11, 11,
        11, 11
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
          id = 7,
          name = "door_left",
          class = "gale_house_door",
          shape = "point",
          x = 1.6,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"plate\""
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
          y = 48,
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
          y = 48,
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
          visible = false,
          properties = {}
        },
        {
          id = 15,
          name = "vfx_wall",
          class = "2",
          shape = "point",
          x = 0,
          y = 48,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 16,
          name = "vfx_wall",
          class = "3",
          shape = "point",
          x = 128,
          y = 48,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
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
          visible = false,
          properties = {}
        },
        {
          id = 18,
          name = "cookpot",
          class = "cookpot",
          shape = "point",
          x = 63.75,
          y = 80.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "firepit",
          class = "firepit",
          shape = "point",
          x = 64,
          y = 93.75,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.components.fueled:SetPercent(0)"
          }
        },
        {
          id = 20,
          name = "gale_loot_skeleton",
          class = "gale_loot_skeleton",
          shape = "point",
          x = 27.75,
          y = 106.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.components.lootdropper:SetChanceLootTable(\"gale_loot_skeleton_eco_dome_room_checkpoint1\")"
          }
        },
        {
          id = 21,
          name = "portabletent_1",
          class = "portabletent",
          shape = "point",
          x = 87.5,
          y = 63,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 22,
          name = "portabletent_2",
          class = "portabletent",
          shape = "point",
          x = 106.75,
          y = 62.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 23,
          name = "potatosack_1",
          class = "potatosack",
          shape = "point",
          x = 118.25,
          y = 89.75,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 24,
          name = "potatosack_2",
          class = "potatosack",
          shape = "point",
          x = 119,
          y = 102.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 25,
          name = "potatosack_3",
          class = "potatosack",
          shape = "point",
          x = 113.5,
          y = 111,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 26,
          name = "potatosack_4",
          class = "potatosack",
          shape = "point",
          x = 100,
          y = 117.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 27,
          name = "potatosack_5",
          class = "potatosack",
          shape = "point",
          x = 115.5,
          y = 120.25,
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
