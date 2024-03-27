local GaleEntity = require("util/gale_entity")

-- TheFocalPoint.components.focalpoint:StartFocusSource(inst, "large", nil, 5, 12, 4)
-- function FocalPoint:StartFocusSource(source, id, target, minrange, maxrange, priority, updater)

-- Hamlet house size is 13.96 x 8.96

-- Note 1 range in Game = 150 pixel
local function GetScalesFromPixelAndGameSize(pixel_size,game_size)
    return {game_size[1] * 150 / pixel_size[1],game_size[2] * 150 / pixel_size[2],1}
end





return GaleEntity.CreateNormalEntity({
    prefabname = "gale_test_room",

    assets = {
        Asset("ANIM","anim/gale_interior_room_testbg.zip"),
        -- Asset("ANIM","anim/wallhamletant.zip"),
        
    },

    bank = "gale_interior_room_testbg",
    build = "gale_interior_room_testbg",
    anim = "idle",

    tags = {
        "interior_room"
    },

    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(3)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )

        -- inst.AnimState:SetLightOverride(1)


        local game_size = {13.96,8.96}
        local scales = GetScalesFromPixelAndGameSize({400,200},game_size)
        inst.AnimState:SetScale(unpack(scales))

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(game_size))

        if not TheNet:IsDedicated() then
            -- inst.test_wall = inst:SpawnChild("gale_interior_wall")
            -- inst.test_wall.Transform:SetPosition(-(game_size[1] / 2 + 0.2),0,game_size[2] / 2)
            -- inst.test_wall:SetWallRotation(PI / 2)

            -- inst.test_wall2 = inst:SpawnChild("gale_interior_wall")
            -- inst.test_wall2.Transform:SetPosition(1.1725-(game_size[1] / 2 + 0.2),0,game_size[2] / 2)
            -- inst.test_wall2:SetWallRotation(0)

            -- inst.wall = CreateWall(inst)
            -- inst.wall.AnimState:SetScale(2.5,2.5,1)
            -- inst.wall.Transform:SetPosition(0,0,2)
        end

        -- if TheNet:GetIsClient() then
            
        -- end
    end,

    serverfn = function(inst)        
        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_test_room_more_width",

    assets = {
        Asset("ANIM","anim/gale_interior_room_testbg.zip"),
    },

    bank = "gale_interior_room_testbg",
    build = "gale_interior_room_testbg",
    anim = "idle",

    tags = {
        "interior_room"
    },

    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(3)

        inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
        inst.AnimState:SetLayer( LAYER_BACKGROUND )
        inst.AnimState:SetSortOrder( 3 )

        local game_size = {70,10}
        local scales = GetScalesFromPixelAndGameSize({400,200},game_size)
        inst.AnimState:SetScale(unpack(scales))

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(game_size))

        if not TheNet:IsDedicated() then

            inst.dist_1 = 27.5
            inst.dist_2 = 18
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                -- print(delta_x)
                -- local max_dist = inst.max_dist
                -- if math.abs(delta_x) >= max_dist then
                --     delta_x = delta_x * max_dist / math.abs(delta_x)
                -- end

                if math.abs(delta_x) >= inst.dist_1 then 
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                elseif math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)        
        
    end,
})


