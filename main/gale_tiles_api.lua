local GROUND_OCEAN_COLOR = -- Color for blending to the land ground tiles 
{ 
    primary_color =         {  0,   0,   0,  25 }, 
    secondary_color =       { 0,  20,  33,  0 }, 
    secondary_color_dusk =  { 0,  20,  33,  80 }, 
    minimap_color =         {  23,  51,  62, 102 },
}

local TIDALMARSH_OCEAN_COLOR = 
{ 
    primary_color =         {  0,   0,   0,  25 }, 
    secondary_color =       { 105,  79,  45,  80 }, 
    secondary_color_dusk =  { 90,  46,  33,  80 }, 
    minimap_color =         {  90,  46,  33, 102 },
}

local INFECTED_OCEAN_COLOR = {
    primary_color =         {  180,   0,   0,  60 }, 
    secondary_color =       { 168,  0,  0,  100 }, 
    secondary_color_dusk =  { 195,  0,  0,  100 }, 
    minimap_color =         {  168,  0,  0, 102 },
}

if WORLD_TILES.GALE_JUNGLE_DEEP == nil then
    -- (tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
    AddTile(
        "GALE_JUNGLE",
        "LAND",
        {
            ground_name = "Gale Jungle", 
        },
        {
            name = "jungle",
            noise_texture = "Ground_noise_jungle",
            runsound="dontstarve/movement/run_woods",
            walksound="dontstarve/movement/walk_woods",
            snowsound="dontstarve/movement/run_snow",
            mudsound="dontstarve/movement/run_mud",
            colors = GROUND_OCEAN_COLOR,
        },
        {
            name="map_edge",
            noise_texture = "mini_jungle_noise",
        }
    )

    AddTile(
        "GALE_JUNGLE_DEEP",
        "LAND",
        {
            ground_name = "Gale Jungle Deep", 
        },
        {
            name = "jungle_deep",
            noise_texture = "Ground_noise_jungle_deep",
            runsound="dontstarve/movement/run_woods",
            walksound="dontstarve/movement/walk_woods",
            snowsound="dontstarve/movement/run_snow",
            mudsound="dontstarve/movement/run_mud",
            colors = GROUND_OCEAN_COLOR,
        },
        {
            name="map_edge",
            noise_texture = "mini_noise_jungle_deep",
        }
    )

    ChangeTileRenderOrder(WORLD_TILES.GALE_JUNGLE_DEEP, WORLD_TILES.FOREST)

    -- Ground_noise_savannah_detail
    AddTile(
        "GALE_SAVANNAH_DETAIL",
        "LAND",
        {
            ground_name = "Gale Savannah Detail", 
        },
        {
            name = "savannah",
            noise_texture = "Ground_noise_savannah_detail",
            runsound="dontstarve/movement/run_woods",
            walksound="dontstarve/movement/walk_woods",
            snowsound="dontstarve/movement/run_snow",
            mudsound="dontstarve/movement/run_mud",
            colors = GROUND_OCEAN_COLOR,
        },
        {
            name="map_edge",
            noise_texture = "mini_savannah_noise",
        }
    )

end



-- c_settile(WORLD_TILES.GALE_JUNGLE_DEEP)
local function c_settile(tile,pt)
    pt = pt or TheInput:GetWorldPosition()
    local map = TheWorld.Map
    local original_tile_type = map:GetTileAtPoint(pt:Get())
    local x, y = map:GetTileCoordsAtPoint(pt:Get())
    if x ~= nil and y ~= nil then
        map:SetTile(x, y, tile)
        map:RebuildLayer(original_tile_type, x, y)
        map:RebuildLayer(tile, x, y)
    end

    local minimap = TheWorld.minimap.MiniMap
    minimap:RebuildLayer(original_tile_type, x, y)
    minimap:RebuildLayer(tile, x, y)
end

local function c_looktiles()
    local GroundTiles = require("worldtiledefs")
    for k, v in pairs(GroundTiles.turf) do
        print(k,v.bank_build)
    end
end

GLOBAL.c_settile = c_settile
GLOBAL.c_looktiles = c_looktiles