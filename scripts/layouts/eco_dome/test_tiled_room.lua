return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 3,
  height = 2,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 10,
  properties = {
    ["centeral_z_offset"] = "-3"
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
      width = 3,
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
        9, 6, 11,
        2, 7, 8
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
          id = 5,
          name = "vfx_wall",
          class = "2",
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
          id = 6,
          name = "vfx_wall",
          class = "3",
          shape = "point",
          x = 192,
          y = 48,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "vfx_wall",
          class = "4",
          shape = "point",
          x = 192,
          y = 128,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "door_up",
          class = "gale_house_door",
          shape = "point",
          x = 96,
          y = 49.6,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.style = \"stone\""
          }
        },
        {
          id = 9,
          name = "gale_loot_skeleton",
          class = "gale_loot_skeleton",
          shape = "point",
          x = 39,
          y = 102.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["fn"] = "ent.components.lootdropper:SetChanceLootTable(\"gale_loot_skeleton_eco_dome_room_checkpoint1\")"
          }
        }
      }
    }
  }
}
