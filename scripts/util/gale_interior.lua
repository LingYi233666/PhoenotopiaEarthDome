local GaleEntity = require("util/gale_entity")

-- Note 1 range in Game = 150 pixel
local function GetScalesFromPixelAndGameSize(pixel_size,game_size)
    return {game_size[1] * 150 / pixel_size[1],game_size[2] * 150 / pixel_size[2],1}
end

local function CreateFloor(inst,bank,build,anim,scales)
    local floor = GaleEntity.CreateClientAnim({
        bank = bank,
        build = build,
        anim = anim,
    })

    floor.entity:SetParent(inst.entity)
    floor.AnimState:SetFinalOffset(3)

    floor.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    floor.AnimState:SetLayer( LAYER_GROUND )
    floor.AnimState:SetSortOrder( 5 )
    
    if scales then
        floor.AnimState:SetScale(unpack(scales))
    end
    
    return floor
end

local function CreateFloors(inst,symbol,img_size,floor_len,game_size)
    local floors = {}
    local floor_scale = GetScalesFromPixelAndGameSize({img_size,img_size},{floor_len,floor_len})
    floor_scale[1] = floor_scale[1] + 0.01
    floor_scale[2] = floor_scale[2] + 0.01
    -- floor_scale[1] = floor_scale[1]
    -- floor_scale[2] = floor_scale[2]
    
    local delta_z_cnt = math.ceil(game_size[2] / floor_len)
    local max_z = math.max(game_size[2] / 2,delta_z_cnt * floor_len)

    for x = -game_size[1] / 2,game_size[1] / 2 - 0.01,floor_len do
        for z = -game_size[2] / 2,max_z - 0.01,floor_len do
            local floor = CreateFloor(inst,"gale_interior_floors","gale_interior_floors","idle")
            floor.AnimState:OverrideSymbol("jungle_deep","gale_interior_floors",symbol)
            floor.Transform:SetPosition(x + floor_len/2,0,z + floor_len / 2)
            floor.AnimState:SetScale(unpack(floor_scale))

            table.insert(floors,floor)
        end
    end

    return floors
end

local function CreateVFXFloor(inst,texture,rotation)
    local floor = inst:SpawnChild("gale_interior_floor")
    if texture then
        floor:SetTexture(texture)
    end
    -- if offset then
    --     floor:SetCutUV(offset[1],offset[2])
    -- end
    if rotation then
        floor:SetRotation(rotation)
    end

    return floor
end

local function CreateVFXFloorsAtRectangle(inst,texture,pos_leftdown,pos_rightup,rotation)
    local offset = {0,0}
    local segcnt = 8
    local floor = CreateVFXFloor(inst,texture,rotation)
    local emit_data_list = {}

    -- local dx = pos_rightup.x - pos_leftdown.x 
    -- local dz = pos_rightup.z - pos_leftdown.z 
    for z = pos_leftdown.z,pos_rightup.z - 1e-5 do
        offset[1] = 0
        for x = pos_leftdown.x,pos_rightup.x - 1e-5 do
            table.insert(emit_data_list,{
                pos = Vector3(x + 0.5,0,z + 0.5),
                uv_x = offset[1],
                uv_y = offset[2],
            })
            
            offset[1] = offset[1] + 1/segcnt
            if offset[1] >= 1 then
                offset[1] = 0
            end
        end
        offset[2] = offset[2] + 1/segcnt
        if offset[2] >= 1 then
            offset[2] = 0
        end

    end

    floor:SetEmitDataList(emit_data_list)

    return floor
end

local function CreateVFXFloors(inst,texture,game_size,rotation)
    -- local offset = {0,0}
    -- local segcnt = 8
    -- local floor = CreateVFXFloor(inst,texture,rotation)
    -- local emit_data_list = {}

    -- for z = -game_size[2] / 2,game_size[2] / 2 - 1e-5 do
    --     offset[1] = 0
    --     for x = -game_size[1] / 2,game_size[1] / 2 - 1e-5 do
    --         table.insert(emit_data_list,{
    --             pos = Vector3(x + 0.5,0,z + 0.5),
    --             uv_x = offset[1],
    --             uv_y = offset[2],
    --         })
            
    --         offset[1] = offset[1] + 1/segcnt
    --         if offset[1] >= 1 then
    --             offset[1] = 0
    --         end
    --     end

    --     offset[2] = offset[2] + 1/segcnt
    --     if offset[2] >= 1 then
    --         offset[2] = 0
    --     end
    -- end

    -- floor:SetEmitDataList(emit_data_list)

    -- return floor

    local pos_leftdown = Vector3(-game_size[1] / 2,0,-game_size[2] / 2)
    local pos_rightup = Vector3(game_size[1] / 2,0,game_size[2] / 2)
    return CreateVFXFloorsAtRectangle(inst,texture,pos_leftdown,pos_rightup,rotation)
end

local function CreateCorners(inst,data,game_size)
    local function FaceRightFn(ent,room)
        ent:ForceFacePoint((ent:GetPosition()+Vector3(1,0,0)):Get())
    end
    local function FaceLeftFn(ent,room)
        ent:ForceFacePoint((ent:GetPosition()+Vector3(-1,0,0)):Get())
    end
    local pillar_layouts_data = {
        
        
        
    }

    if data.up_name then
        pillar_layouts_data.pillar_left_up = {
            prefab = data.up_name,
            offset = Vector3(-game_size[1]/2,0,game_size[2]/2),
            fn = FaceRightFn,
        }
        pillar_layouts_data.pillar_right_up = {
            prefab = data.up_name,
            offset = Vector3(game_size[1]/2,0,game_size[2]/2),
            fn = FaceLeftFn,
        }
    end

    if data.down_name then
        pillar_layouts_data.pillar_left_down = {
            prefab = data.down_name,
            offset = Vector3(-game_size[1]/2,0,-game_size[2]/2),
            fn = FaceRightFn,
        }
        pillar_layouts_data.pillar_right_down = {
            prefab = data.down_name,
            offset = Vector3(game_size[1]/2,0,-game_size[2]/2),
            fn = FaceLeftFn,
        }
    end

    for name,data in pairs(pillar_layouts_data) do
        inst.components.gale_interior_room.layouts_data[name] = data
    end
end

local function CreateDoors(inst,data,game_size)
    local door_layouts_data = {}
    local up_delta = 0.1
    if data.up_num and data.up_num > 0 then
        for i=1,data.up_num do
            local name = data.up_num > 1 and "door_up"..i or "door_up"
            door_layouts_data[name] = {
                prefab = "gale_house_door",
                offset = Vector3(game_size[1] * i / (data.up_num+1) - 0.5*game_size[1],
                                0,
                                game_size[2] / 2 - up_delta
                ),
                fn = function(ent,room,...)
                    ent:SetDirection("north")
                    if data.fns and data.fns[name] then
                        data.fns[name](ent,room,...)
                    end
                end
            }
        end
    end
    if data.left_num and data.left_num > 0 then
        for i=1,data.left_num do
            local name = data.left_num > 1 and "door_left"..i or "door_left"
            door_layouts_data[name] = {
                prefab = "gale_house_door",
                offset = Vector3(-game_size[1] / 2 + up_delta,
                                0,
                                game_size[2] * i / (data.left_num+1) - 0.5*game_size[2]
                ),
                fn = function(ent,room,...)
                    ent:SetDirection("east")
                    if data.fns and data.fns[name] then
                        data.fns[name](ent,room,...)
                    end
                end
            }
        end
    end
    if data.right_num and data.right_num > 0 then
        for i=1,data.right_num do
            local name = data.right_num > 1 and "door_right"..i or "door_right"
            door_layouts_data[name] = {
                prefab = "gale_house_door",
                offset = Vector3(game_size[1] / 2 - up_delta,
                                0,
                                game_size[2] * i / (data.right_num+1) - 0.5*game_size[2]
                ),
                fn = function(ent,room,...)
                    ent:SetDirection("west")
                    if data.fns and data.fns[name] then
                        data.fns[name](ent,room,...)
                    end
                end
            }
        end
    end
    if data.down_num and data.down_num > 0 then
        for i=1,data.down_num do
            local name = data.down_num > 1 and "door_down"..i or "door_down"
            door_layouts_data[name] = {
                prefab = "gale_house_door",
                offset = Vector3(game_size[1] * i / (data.down_num+1) - 0.5*game_size[1],
                                0,
                                -game_size[2] / 2 + up_delta
                ),
                fn = function(ent,room,...)
                    ent:SetDirection("south")
                    if data.fns and data.fns[name] then
                        data.fns[name](ent,room,...)
                    end
                end
            }
        end
    end

    for name,data in pairs(door_layouts_data) do
        inst.components.gale_interior_room.layouts_data[name] = data
    end
end

-- local function CreateLineWalls(inst,start_pos,end_pos,offset,layer,texture)
--     local down_y = -0.1
--     local wall_dist = 1
--     offset = offset or 0

--     local delta = end_pos - start_pos
--     delta.y = 0

--     local wall = inst:SpawnChild("gale_interior_wall")

--     local angle = math.atan2(delta.z, delta.x)
--     if angle < 0 then
--         angle = 2 * PI + angle
--     end
--     wall:SetWallRotation(angle)

--     if layer then
--         wall:SetLayer(layer)
--     end
--     if texture then
--         wall:SetTexture(texture)
--     end
    
    
--     local emit_data_list = {}
--     for i = 0,delta:Length() - wall_dist,wall_dist do
--         local delta_nor = delta:GetNormalized()
--         local pos = start_pos + delta_nor * i + delta_nor * (wall_dist / 2)
--         pos.y = pos.y + down_y

--         table.insert(emit_data_list,{
--             pos = pos,
--             uv_x = offset / 8,
--         })        
        

--         offset = offset + 1
--         if offset >= 8 then
--             offset = 0
--         end
--     end

--     wall:SetEmitDataList(emit_data_list)

    

--     return wall,offset
-- end
local function CreateLineWalls(inst,start_pos,end_pos,height,offset,layer,texture)
    local wall = inst:SpawnChild("gale_interior_wall_height_"..height)
    local next_offset = wall:GenEmitData(start_pos,end_pos,offset)

    if layer then
        wall:SetLayer(layer)
    end
    if texture then
        wall:SetTexture(texture)
    end
    

    return wall,next_offset
end

local function CreateWalls(inst,game_size,height,texture)
    local offset = 0
    local walls_left,walls_up,walls_right
    walls_left,offset = CreateLineWalls(inst,
        Vector3(-game_size[1]/2,0,-game_size[2]/2),
        Vector3(-game_size[1]/2,0,game_size[2]/2),
        height,
        offset,
        nil,
        texture
    )
    walls_up,offset = CreateLineWalls(inst,
        Vector3(-game_size[1]/2,0,game_size[2]/2),
        Vector3(game_size[1]/2,0,game_size[2]/2),
        height,
        offset,
        nil,
        texture
    )
    walls_right,offset = CreateLineWalls(inst,
        Vector3(game_size[1]/2,0,game_size[2]/2),
        Vector3(game_size[1]/2,0,-game_size[2]/2),
        height,
        offset,
        nil,
        texture
    )

    return {walls_left,walls_up,walls_right}
end

local function LoadFloorIndex(path)
    local result = {}
    local file = require(path)
    for k,v in pairs(file.tiles) do
        result[v.id+1] = v.image:match("/(%w+)%.png")
    end

    return result
end

local function LoadTiledLayout(path)
    local file = require(path)
    -- local floor_index = require("layouts.gale_interior_floors_index")
    local floor_index = LoadFloorIndex("layouts.gale_interior_floors")

    local floor_data = file.layers[1].data
    local floor_w = file.layers[1].width
    local floor_h = file.layers[1].height
    local floor_result = {}

    local centeral_offset = -Vector3(file.properties.centeral_x_offset or 0,
                                    0,
                                    file.properties.centeral_z_offset or 0
                                )

    -- floor_result
    -- {
    --     {offset = Vector3(px1,0,py1),symbol = symbol1},
    --     {offset = Vector3(px2,0,py2),symbol = symbol2},
    --     {offset = Vector3(px3,0,py3),symbol = symbol3},
    --     .......
    -- }
    for x = 1,floor_w do
        for y = 1,floor_h do
            local data = floor_data[(y-1) * floor_w + x]
            local symbol = floor_index[data]
            local px = (x - (floor_w+1) / 2) * 8
            local py = (-y + (floor_h+1) / 2) * 8
            table.insert(floor_result,{
                offset = Vector3(px,0,py) + centeral_offset,
                symbol = symbol,
            })
        end
    end

    -- wall_result
    -- {
    --     {offset = Vector3(px1,0,py1),texture = texture1},
    --     .........
    -- }

    -- entity_result
    -- {
    --     name = {prefab = "xxx",offset = Vector3(px,0,py),fn = fn},
    --     .........
    -- }
    local wall_result = {}
    local entity_result = {}
    local entity_data = file.layers[2].objects
    for k,v in pairs(entity_data) do
        local px = (v.x / 64 - floor_w/2) * 8
        local py = (-v.y / 64 + floor_h/2) * 8

        if v.name == "vfx_wall" then
            if wall_result[tonumber(v.class)] ~= nil then
                print("wall_result[tonumber(v.class)] failed:",tonumber(v.class))
            end

            wall_result[tonumber(v.class)] = {
                offset = Vector3(px,0,py) + centeral_offset,
                texture = v.properties.texture ~= nil 
                        and #v.properties.texture > 0 
                        and v.properties.texture,
            }
        else 
            if entity_result[v.name] ~= nil then
                print("entity_result[v.name] failed:",v.name)
            end
            entity_result[v.name] = {
                prefab = v.class,
                offset = Vector3(px,0,py) + centeral_offset,
            }
            if v.properties.fn then
                entity_result[v.name].fn = loadstring("return  function(ent,room) "..v.properties.fn.."  end")()
            end
            if v.name:find("pillar") and entity_result[v.name].fn == nil then
                entity_result[v.name].fn = function(ent,room,...)
                    ent:ForceFacePoint(room:GetPosition():Get())
                end
            end

            if v.name:find("door_up") then
                local old = entity_result[v.name].fn
                entity_result[v.name].fn = function(ent,room,...)
                    old(ent,room,...)
                    ent:SetDirection("north")
                end
            elseif v.name:find("door_left") then
                local old = entity_result[v.name].fn
                entity_result[v.name].fn = function(ent,room,...)
                    old(ent,room,...)
                    ent:SetDirection("east")
                end
            elseif v.name:find("door_right") then
                local old = entity_result[v.name].fn
                entity_result[v.name].fn = function(ent,room,...)
                    old(ent,room,...)
                    ent:SetDirection("west")
                end
            elseif v.name:find("door_down") then
                local old = entity_result[v.name].fn
                entity_result[v.name].fn = function(ent,room,...)
                    old(ent,room,...)
                    ent:SetDirection("south")
                end
            end
        end
    end

    if #wall_result <= 1 then
        wall_result = {
            {offset = Vector3(-floor_w/2,0,-floor_h/2) * 8  + centeral_offset,},
            {offset = Vector3(-floor_w/2,0,floor_h/2) * 8  + centeral_offset,},
            {offset = Vector3(floor_w/2,0,floor_h/2) * 8  + centeral_offset,},
            {offset = Vector3(floor_w/2,0,-floor_h/2) * 8  + centeral_offset,},
        }
    end

    local global_texture = file.properties.wall_texture
    if global_texture then
        for k,v in pairs(wall_result) do
            v.texture = v.texture or global_texture
        end
    end
    

    return floor_result,wall_result,entity_result
end

local function CreateFromTiledLayout(inst,path)
    inst:AddComponent("gale_interior_room")

    local floor_result,wall_result,entity_result = LoadTiledLayout(path)

    -- Floor Walls are client things
    if not TheNet:IsDedicated() then
        -- Don't Use it to create floor
        -- inst.floors = {}

        -- local floor_scale = GetScalesFromPixelAndGameSize({512,512},{8,8})
        -- floor_scale[1] = floor_scale[1] + 0.01
        -- floor_scale[2] = floor_scale[2] + 0.01

        -- for k,v in pairs(floor_result) do
        --     -- local floor = CreateFloor(inst,"gale_interior_floors","gale_interior_floors","idle")
        --     -- floor.AnimState:OverrideSymbol("jungle_deep","gale_interior_floors",v.symbol)
        --     -- floor.Transform:SetRotation(90)
        --     local floor = CreateVFXFloor(inst)
        --     floor.Transform:SetPosition(v.offset:Get())
        --     -- floor.AnimState:SetScale(unpack(floor_scale))

        --     table.insert(inst.floors,floor)
        -- end

        inst.walls = {}
        local offset = 0
        for i = 1,#wall_result-1 do
            local pt1 = wall_result[i].offset
            local pt2 = wall_result[i+1].offset
            local texture = wall_result[i].texture
            local tmp_walls = {}
            tmp_walls,offset = CreateLineWalls(inst,pt1,pt2,offset,nil,texture)
            for k,v in pairs(tmp_walls) do
                table.insert(inst.walls,v)
            end
        end
    end
    
    if not TheWorld.ismastersim then
        return 
    end
    
    inst.components.gale_interior_room.layouts_data = entity_result
end

return {
    GetScalesFromPixelAndGameSize = GetScalesFromPixelAndGameSize,

    CreateVFXFloor = CreateVFXFloor,
    -- CreateFloors = CreateFloors,
    CreateVFXFloorsAtRectangle = CreateVFXFloorsAtRectangle,
    CreateVFXFloors = CreateVFXFloors,
    CreateLineWalls = CreateLineWalls,
    CreateWalls = CreateWalls,
    CreateCorners = CreateCorners,
    CreateDoors = CreateDoors,

    LoadTiledLayout = LoadTiledLayout,
    CreateFromTiledLayout = CreateFromTiledLayout,
}