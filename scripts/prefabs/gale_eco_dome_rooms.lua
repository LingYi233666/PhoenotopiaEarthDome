local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleInterior = require("util/gale_interior")
local Rectangle    = require("util/rectangle")


SetSharedLootTable("gale_loot_skeleton_eco_dome_room_first_keycard",
{
    {"boneshard",   1.0},
    {"boneshard",   1.0},
    {"gale_eco_dome_keycard",   1.0},
    {"nightmarefuel",   1.0},
    {"nightmarebeak",   1.0},
    {"nightmarefuel",   0.75},
})

SetSharedLootTable("gale_loot_skeleton_eco_dome_room_checkpoint1",
{
    {"boneshard",   1.0},
    {"boneshard",   1.0},
    {"nightmarefuel",   1.0},
    {"nightmarebeak",   1.0},
    {"nightmarefuel",   0.75},
})

local WALL_HEIGHT = 8

local function spear_trap_fn(ent,room,new_spawned,on_loaded)
    ent.nearby_alert = false 
    if new_spawned then
        ent.triggered = true 
        ent.sg:GoToState("idle")
    end
    
    ent.components.health:SetMinHealth(ent.components.health.maxhealth - 0.000001)

    ent:ListenForEvent("healthdelta",function()
        if ent.components.health:IsHurt() then
            ent.components.health:SetPercent(1)
        end 
    end)
end

-- c_spawn("gale_eco_dome_room_main"):OnBuilt(ThePlayer)
return 
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_pillar_sidewall",

    assets = {
        Asset("ANIM", "anim/interior_pillar.zip"),
        Asset("ANIM", "anim/interior_wall_decals_batcave.zip"),
    },
    bank = "interior_wall_decals_cave",
    build = "interior_wall_decals_batcave",
    anim = "pillar_sidewall",

    tags = {"NOCLICK","pillar"},

    clientfn = function(inst)
        MakeObstaclePhysics(inst,1.8,25)

        inst.Transform:SetTwoFaced()
    end,

    serverfn = function(inst)
        inst:AddComponent("savedrotation")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_pillar_corner",

    assets = {
        Asset("ANIM", "anim/interior_pillar.zip"),
        Asset("ANIM", "anim/interior_wall_decals_batcave.zip"),
    },
    bank = "interior_wall_decals_cave",
    build = "interior_wall_decals_batcave",
    anim = "pillar_corner",

    tags = {"NOCLICK","pillar"},

    clientfn = function(inst)
        MakeObstaclePhysics(inst,1.8,25)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.Transform:SetTwoFaced()
    end,

    serverfn = function(inst)
        inst:AddComponent("savedrotation")
    end,
}),
GaleEntity.CreateNormalInventoryItem({
    prefabname = "gale_eco_dome_keycard",

    assets = {
        Asset("ANIM", "anim/atrium_key.zip"),

    },
    bank = "atrium_key",
    build = "atrium_key",
    anim = "idle",

    tags = {},

    inventoryitem_data = {
        imagename = "atrium_key",
        atlasname_override = "images/inventoryimages.xml",
        use_gale_item_desc = false,
    },

    clientfn = function(inst)

    end,

    serverfn = function(inst)
        inst:AddComponent("tradable")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_keycard_fake",

    assets = {
        Asset("ANIM", "anim/atrium_key.zip"),

    },
    bank = "atrium_key",
    build = "atrium_key",
    anim = "idle",

    tags = {},

    persists = false,

    clientfn = function(inst)
        inst.entity:AddFollower()

        inst:SetPrefabNameOverride("gale_eco_dome_keycard")
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_main",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
        Asset("ANIM", "anim/interior_pillar.zip"),
        Asset("ANIM", "anim/interior_wall_decals_batcave.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },


    clientfn = function(inst)
        inst.game_size = {16,12}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))


        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/noise_gardenstone.tex",
                                                    inst.game_size)
            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")
        end
    end,

    serverfn = function(inst)        
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                up_num = 1,
                left_num = 1,
                right_num = 1,
                fns = {
                    door_up = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_left = function(ent,room)
                        ent.style = "plate" 
                    end,
                    door_right = function(ent,room,new_spanwed,on_loaded)
                        ent.style = "stone" 
                        if new_spanwed then
                            print(ent,"new spawned and set enabled false")
                            ent:SetEnabled(false)
                        end
                        ent.key_prefab = "gale_eco_dome_keycard"
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            for i = 1,math.random(4,6) do
                inst.components.gale_interior_room:AddLayout("grass_"..i,{
                    prefab = "grass",
                    offset = Vector3(
                        GetRandomMinMax(-inst.game_size[1]/2+2,inst.game_size[1]/2-2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+1.5,inst.game_size[2]/2-1.5)
                    ),
                })
            end

            

            for i = 1,math.random(3,5) do
                inst.components.gale_interior_room:AddLayout("sapling_"..i,{
                    prefab = "sapling",
                    offset = Vector3(
                        GetRandomMinMax(-inst.game_size[1]/2+2,inst.game_size[1]/2-2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+1.5,inst.game_size[2]/2-1.5)
                    ),
                })
            end

            for i = 1,math.random(1,3) do
                inst.components.gale_interior_room:AddLayout("berrybush_"..i,{
                    prefab = "berrybush",
                    offset = Vector3(
                        GetRandomMinMax(-inst.game_size[1]/2+2,inst.game_size[1]/2-2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+1.5,inst.game_size[2]/2-1.5)
                    ),
                })
            end
        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_first_keycard",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },


    clientfn = function(inst)
        inst.game_size = {10,9}

        
        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))


        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/shop_floor_woodpaneling2.tex",
                                                    inst.game_size)
            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_bricks.tex")
        end
    end,

    serverfn = function(inst)     
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)
        inst.components.gale_interior_room.layouts_data.pillar_left_up = nil
        inst.components.gale_interior_room.layouts_data.pillar_right_up = nil

        GaleInterior.CreateDoors(inst,
            {
                right_num = 1,
                fns = {
                    door_right = function(ent,room)
                        ent.style = "plate" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            for i = 1,math.random(2,3) do
                inst.components.gale_interior_room:AddLayout("grass_"..i,{
                    prefab = "grass",
                    offset = Vector3(
                        GetRandomMinMax(-inst.game_size[1]/2+2,inst.game_size[1]/2-2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+1.5,inst.game_size[2]/2-1.5)
                    ),
                })
            end

            inst.components.gale_interior_room:AddLayout("gale_loot_skeleton",{
                prefab = "gale_loot_skeleton",
                offset = Vector3(
                    GetRandomMinMax(-inst.game_size[1]/2+2,inst.game_size[1]/2-2),
                    0,
                    GetRandomMinMax(-inst.game_size[2]/2+1.5,inst.game_size[2]/2-1.5)
                ),
                fn = function(skeleton)
                    skeleton.components.lootdropper:SetChanceLootTable("gale_loot_skeleton_eco_dome_room_first_keycard")
                end,
            })
        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_corridor1",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {56,8}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")

            -- Cameras
            inst.dist_1 = 19.5
            inst.dist_2 = 10
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                if math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)        
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                up_num = 3,
                right_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up1 = function(ent,room)
                        ent.style = "plate" 
                    end,
                    door_up2 = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up3 = function(ent,room,new_spanwed,on_loaded)
                        ent.style = "wood" 
                        if new_spanwed then
                            print(ent,"new spawned and set enabled false")
                            ent:SetEnabled(false)
                        end
                        ent.key_prefab = "gale_eco_dome_keycard"
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            local dist = 3
            for i = dist,inst.game_size[1] - dist,dist do
                inst.components.gale_interior_room:AddLayout("vine_"..i,{
                    prefab = "gale_forest_hanging_vine_static",
                    offset = Vector3(
                        GetRandomMinMax(i - 2 - inst.game_size[1]/2,i + 2 - inst.game_size[1]/2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+3,inst.game_size[2]/2-3)
                    ),
                })
            end

            dist = 6
            for i = dist,inst.game_size[1] - dist,dist do
                inst.components.gale_interior_room:AddLayout("lightray_"..i,{
                    prefab = "gale_forest_lightray",
                    offset = Vector3(
                        GetRandomMinMax(i - 2 - inst.game_size[1]/2,i + 2 - inst.game_size[1]/2),
                        0,
                        GetRandomMinMax(-inst.game_size[2]/2+3,inst.game_size[2]/2-3)
                    ),
                })
            end

            


        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_checkpoint1",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },


    clientfn = function(inst)
        inst.game_size = {16,10}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))
        
        if not TheNet:IsDedicated() then

            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/shop_floor_woodpaneling2.tex",
                                                    inst.game_size)
            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_woodwall.tex")

        end
    end,

    serverfn = function(inst)        
        inst.components.gale_interior_room.layouts_data = {
            firepit = {
                prefab = "firepit",
                offset = Vector3(0.00, 0.00, -1.00),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.components.fueled:SetPercent(0)
                    end
                end
            },

            cookpot = {
                prefab = "cookpot",
                offset = Vector3(0.00, 0.00, 4.00),
            },

            portabletent_1 = {
                prefab = "portabletent",
                offset = Vector3(6.00, 0.00, 1.50),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.components.finiteuses:SetUses(1)
                    end
                end,
            },

            portabletent_2 = {
                prefab = "portabletent",
                offset = Vector3(6.00, 0.00, 4.00),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.components.finiteuses:SetUses(1)
                    end
                end,
            },

            gale_loot_skeleton = {
                prefab = "gale_loot_skeleton",
                offset = Vector3(-3.77,0,-1.14),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.components.lootdropper:SetChanceLootTable("gale_loot_skeleton_eco_dome_room_checkpoint1")
                    end
                end
            },

            potatosack_1 = {
                prefab = "potatosack",
                offset = Vector3(-5.45, -0.00, 3.95),
            },
            potatosack_2 = {
                prefab = "potatosack",
                offset = Vector3(-6.15, 0.00, 3.19),
            },
            potatosack_3 = {
                prefab = "potatosack",
                offset = Vector3(-7.20, -0.00, 3.76),
            },
        }

        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)
        inst.components.gale_interior_room.layouts_data.pillar_left_up = nil
        inst.components.gale_interior_room.layouts_data.pillar_right_up = nil

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "plate" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)

        end
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_path_to_moon",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },


    clientfn = function(inst)
        inst.game_size = {16,8}
        
        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/floor_woodpanels.tex",
                                                    inst.game_size)
            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_floraltrim2_2.tex")

        end
    end,

    serverfn = function(inst)     
        inst.components.gale_interior_room.layouts_data = {
            houndbone = {
                prefab = "houndbone",
                offset = Vector3(3.94, 0.00, -2.08),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.animname = "piece2"
                        ent.AnimState:PlayAnimation(ent.animname)
                    end
                    
                end
            },
            horn = {
                prefab = "horn",
                offset = Vector3(-2.78, 0.00, 1.45),
                fn = function(ent,room,new_spanwed)
                    if new_spanwed then
                        ent.components.finiteuses:SetUses(1)
                    end
                end
            },
            beefalowool_1 = {
                prefab = "beefalowool",
                offset = Vector3(-0.26, 0.00, 0.74),
            },
            beefalowool_2 = {
                prefab = "beefalowool",
                offset = Vector3(1.44, 0.00, -1.86)	,
            },
            beefalowool_3 = {
                prefab = "beefalowool",
                offset = Vector3(3.76, 0.00, -0.24)	,
            },
        }

        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)
        inst.components.gale_interior_room.layouts_data.pillar_left_up = nil
        inst.components.gale_interior_room.layouts_data.pillar_right_up = nil

        GaleInterior.CreateDoors(inst,
            {
                up_num = 1,
                left_num = 1,
                fns = {
                    door_up = function(ent,room)
                        ent.style = "stone" 
                        ent.Transform:SetScale(0.7,0.7,0.7)
                    end,
                    door_left = function(ent,room)
                        ent.style = "wood" 
                    end,
                },
            },
            inst.game_size
        )
        inst.components.gale_interior_room.layouts_data.door_up.offset = Vector3(5.625,0,inst.game_size[2]/2-0.1)

        inst.components.gale_interior_room.layouts_data.beefalo_groomer = {
            prefab = "beefalo_groomer",
            offset = Vector3(5.16, 0.00, 2.72),
        }
        inst.components.gale_interior_room.layouts_data.wardrobe = {
            prefab = "wardrobe",
            offset = Vector3(7.05, 0.00, 3.05),
        }
        inst.components.gale_interior_room.layouts_data.succulent_potted_1 = {
            prefab = "succulent_potted",
            offset = Vector3(3.00, 0.00, 2.50),
        }
        inst.components.gale_interior_room.layouts_data.succulent_potted_2 = {
            prefab = "succulent_potted",
            offset = Vector3(4.00, 0.00, 3.50),
        }
        inst.components.gale_interior_room.layouts_data.pottedfern_2 = {
            prefab = "pottedfern",
            offset = Vector3(3.00, 0.00, 3.50),
        }
        inst.components.gale_interior_room.layouts_data.pottedfern_2 = {
            prefab = "pottedfern",
            offset = Vector3(4.00, 0.00, 2.50),
        }
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_moon_treasure",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },


    clientfn = function(inst)
        inst.game_size = {10,8}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/floor_gardenstone.tex",
                                                    inst.game_size)
            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")

        end
    end,

    serverfn = function(inst)        
        inst.components.gale_interior_room.layouts_data = {
            icebox_1 = {
                prefab = "icebox",
                offset = Vector3(2.00, 0.00, 0),
            }
        }
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                down_num = 1,
                fns = {
                    door_down = function(ent,room)
                        ent.style = "stone" 
                        ent.Transform:SetScale(0.7,0.7,0.7)
                    end,
                },
            },
            inst.game_size
        )
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_down_corridor1",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {10,24}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")

            -- Cameras
            inst.dist_1 = 6
            inst.dist_2 = 4
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_z = player_pos.z - room_pos.z

                if math.abs(delta_z) >= inst.dist_2 then
                    delta_z = delta_z * inst.dist_1 / math.abs(delta_z)
                end

                target.Transform:SetPosition(room_pos.x,0,room_pos.z + delta_z)
            end)
        end
    end,

    serverfn = function(inst)      
        inst.components.gale_interior_room.layouts_data = {
            flower1 = {
                prefab = "flower",
                offset = Vector3(-2.79, 0.00, -8.29),
            },
            flower2 = {
                prefab = "flower",
                offset = Vector3(2.35, -0.00, -8.44),
            },
            flower3 = {
                prefab = "flower",
                offset = Vector3(3.78, -0.00, -8.33),
            },
            flower4 = {
                prefab = "flower",
                offset = Vector3(-0.96, 0.00, -9.17),
            },
            flower5 = {
                prefab = "flower",
                offset = Vector3(-3.92, 0.00, -8.35),
            },
            berrybush21 = {
                prefab = "berrybush2",
                offset = Vector3(3.21, 0.00, -9.92),
            },
            berrybush1 = {
                prefab = "berrybush",
                offset = Vector3(1.62, 0.00, -10.45),
            },
            berrybush22 = {
                prefab = "berrybush2",
                offset = Vector3(-2.75, 0.00, -10.37),
            },
            flower6 = {
                prefab = "flower",
                offset = Vector3(-1.68, 0.00, -10.77),
            },
            berrybush23 = {
                prefab = "berrybush2",
                offset = Vector3(-0.05, 0.00, -11.55),
            },
        }  
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                right_num = 1,
                up_num = 1,
                down_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_down = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )
        inst.components.gale_interior_room.layouts_data.door_left.offset.z = 
            inst.game_size[2] * 1 / 3 - inst.game_size[2] * 0.5

        inst.components.gale_interior_room.layouts_data.door_right.offset.z = 
            inst.game_size[2] * 2 / 3 - inst.game_size[2] * 0.5

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            -- fence_item
            -- -4.5,-3.5,-2.5,-1.5,1.5,2.5,3.5,4.5
            -- fence_gate_item 
            -- -0.5,0.5
            for i = -4.5,-1.5,1 do
                local offset = Vector3(i,0,-7.5)
                local fence_item = SpawnAt("fence_item",inst,nil,offset)
                fence_item.components.deployable.restrictedtag = nil
                fence_item.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
                fence_item.components.deployable:Deploy(inst:GetPosition()+offset,inst,90)
            end

            for i = -0.5,0.5,1 do
                local offset = Vector3(i,0,-7.5)
                local fence_gate_item = SpawnAt("fence_gate_item",inst,nil,offset)
                fence_gate_item.components.deployable.restrictedtag = nil
                fence_gate_item.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
                fence_gate_item.components.deployable:Deploy(inst:GetPosition()+offset,inst,90)
            end

            for i = 1.5,4.5,1 do
                local offset = Vector3(i,0,-7.5)
                local fence_item = SpawnAt("fence_item",inst,nil,offset)
                fence_item.components.deployable.restrictedtag = nil
                fence_item.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
                fence_item.components.deployable:Deploy(inst:GetPosition()+offset,inst,90)
            end
        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_teach_pressure_plates",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {16,8}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")
        end
    end,

    serverfn = function(inst)      
        inst.components.gale_interior_room.layouts_data = {
            pressure_plate = {
                prefab = "gale_interior_pressure_plate_yellow_stone",
                offset = Vector3(0,0,0),
                fn = function(ent,room)
                    ent.components.gale_creatureprox.on_occupied = function()
                        -- print(ent,"on_occupied")
                        local door_left = room.components.gale_interior_room.layouts.door_left
                        if door_left and door_left:IsValid() then
                            door_left:SetEnabled(true)
                        end
                        
                    end

                    ent.components.gale_creatureprox.on_empty = function()
                        -- print(ent,"on_empty")
                        local door_left = room.components.gale_interior_room.layouts.door_left
                        if door_left and door_left:IsValid() then
                            door_left:SetEnabled(false)
                        end
                    end
                end,
            },
        }  
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                right_num = 1,
                fns = {
                    door_left = function(ent,room,new_spanwed)
                        ent.style = "stone" 
                        if new_spanwed then
                            ent:SetEnabled(false,false)
                        end
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            
        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_inner_forest",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {24,10}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")
        end
    end,

    serverfn = function(inst)      
        inst.components.gale_interior_room.layouts_data = {
            waterpipes = {
                prefab = "gale_eco_dome_room_waterpipes",
                offset = Vector3(0,6,1),
            },

            pressure_plate_left = {
                prefab = "gale_interior_pressure_plate_yellow_stone",
                offset = Vector3(-4,0,-3),
                fn = function(ent,room)
                    ent.components.gale_creatureprox.on_occupied = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(-1,true)
                        end
                    end

                    ent.components.gale_creatureprox.on_empty = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(-1,false)
                        end
                    end
                end,
            },

            pressure_plate_med = {
                prefab = "gale_interior_pressure_plate_yellow_stone",
                offset = Vector3(0,0,-3),
                fn = function(ent,room)
                    ent.components.gale_creatureprox.on_occupied = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(0,true)
                        end
                    end

                    ent.components.gale_creatureprox.on_empty = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(0,false)
                        end
                    end
                end,
            },

            pressure_plate_right = {
                prefab = "gale_interior_pressure_plate_yellow_stone",
                offset = Vector3(4,0,-3),
                fn = function(ent,room)
                    ent.components.gale_creatureprox.on_occupied = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(1,true)
                        end
                    end

                    ent.components.gale_creatureprox.on_empty = function()
                        local waterpipes = room.components.gale_interior_room.layouts.waterpipes
                        if waterpipes and waterpipes:IsValid() then
                            waterpipes:EnableWaterAt(1,false)
                        end
                    end
                end,
            },

            twigs = {
                prefab = "twigs",
                offset = Vector3(4,0,-3),
            },
            
            -- generated by c_print_inner()
            evergreen1 = {
                prefab = "evergreen",
                offset = Vector3(0.12, 0.00, -1.28),
            },
            evergreen2 = {
                prefab = "evergreen",
                offset = Vector3(-2.34, 0.00, -1.08),
            },
            evergreen3 = {
                prefab = "evergreen",
                offset = Vector3(-1.32, 0.00, 2.40),
            },
            evergreen4 = {
                prefab = "evergreen",
                offset = Vector3(2.02, 0.00, 2.32),
            },
            evergreen5 = {
                prefab = "evergreen",
                offset = Vector3(3.38, 0.00, -1.35),
            },
            evergreen6 = {
                prefab = "evergreen",
                offset = Vector3(-4.18, 0.00, 2.32),
            },
            evergreen7 = {
                prefab = "evergreen",
                offset = Vector3(5.20, 0.00, -1.20),
            },
            evergreen8 = {
                prefab = "evergreen",
                offset = Vector3(-5.37, 0.00, -0.95),
            },
            evergreen9 = {
                prefab = "evergreen",
                offset = Vector3(4.96, 0.00, 2.67),
            },
            sapling1 = {
                prefab = "sapling",
                offset = Vector3(-6.91, -0.00, -1.45),
            },
            evergreen10 = {
                prefab = "evergreen",
                offset = Vector3(7.90, -0.00, -0.42),
            },
            evergreen11 = {
                prefab = "evergreen",
                offset = Vector3(-8.22, 0.00, 0.18),
            },
            evergreen12 = {
                prefab = "evergreen",
                offset = Vector3(-8.17, 0.00, 2.89),
            },
            sapling2 = {
                prefab = "sapling",
                offset = Vector3(-8.88, 0.00, -0.83),
            },
            evergreen13 = {
                prefab = "evergreen",
                offset = Vector3(8.26, 0.00, 3.56),
            },
            sapling3 = {
                prefab = "sapling",
                offset = Vector3(9.74, 0.00, 1.47),
            },
            evergreen14 = {
                prefab = "evergreen",
                offset = Vector3(10.20, 0.00, 1.80),
            },
            evergreen15 = {
                prefab = "evergreen",
                offset = Vector3(-10.35, 0.00, 0.96),
            },
        }  
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                right_num = 1,
                fns = {
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )   
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_wall_maze",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
        Asset("IMAGE", resolvefilepath("levels/textures/ground_noise_checkeredlawn.tex")),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {24,12}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/ground_noise_checkeredlawn.tex",
                                                    inst.game_size)

            -- inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")
        end
    end,

    serverfn = function(inst)     
        

        local function lever_fn_wrapper(indexs)
            local function lever_fn(ent,room,new_spawned,on_loaded)
                ent:ListenForEvent("gale_lever_direction_change",function(ent,data)
                    if data.old_direction == data.direction then
                        return 
                    end
                    if data.direction == 0 then
                        for k,id in pairs(indexs) do
                            local spear_trap = room.components.gale_interior_room.layouts["gale_spear_trap"..id]
                            if spear_trap and spear_trap:IsValid() then
                                if data.immediate then
                                    spear_trap.triggered = true 
                                    spear_trap.sg:GoToState("idle")
                                else
                                    spear_trap.sg:GoToState("extending")
                                end
                                
                            end
                        end
                    else 
                        for k,id in pairs(indexs) do
                            local spear_trap = room.components.gale_interior_room.layouts["gale_spear_trap"..id]
                            if spear_trap and spear_trap:IsValid() then
                                if data.immediate then
                                    spear_trap.triggered = false 
                                    spear_trap.sg:GoToState("idle")
                                else
                                    spear_trap.sg:GoToState("retracting")
                                end
                                
                            end
                        end
                    end
                end)
            end

            return lever_fn
        end

        local function spear_trap_fn(ent,room,new_spawned,on_loaded)
            ent.nearby_alert = false 
            if new_spawned then
                ent.triggered = true 
                ent.sg:GoToState("idle")
            end
            
            ent.components.health:SetMinHealth(ent.components.health.maxhealth - 0.000001)

            ent:ListenForEvent("healthdelta",function()
                if ent.components.health:IsHurt() then
                    ent.components.health:SetPercent(1)
                end 
            end)
        end

        inst.components.gale_interior_room.layouts_data = {
            gale_lever_wood1 = {
                prefab = "gale_lever_wood",
                offset = Vector3(2.00, 0.00, 0.00),
                fn = lever_fn_wrapper({1,2}),
            },
            gale_lever_wood2 = {
                prefab = "gale_lever_wood",
                offset = Vector3(0.50, 0.00, 5.50),
                fn = lever_fn_wrapper({3,4}),
            },
            gale_lever_wood3 = {
                prefab = "gale_lever_wood",
                offset = Vector3(7.00, 0.00, -0.50),
                fn = lever_fn_wrapper({5,6}),
            },
            
            piggyback1 = {
                prefab = "piggyback",
                offset = Vector3(2.50, 0.00, 5.50),
            },
            
            gale_eco_dome_keycard1 = {
                prefab = "gale_eco_dome_keycard",
                offset = Vector3(10.39, 0.00, -3.53),
            },
            goldnugget1 = {
                prefab = "goldnugget",
                offset = Vector3(-10.69, 0.00, 3.51),
            },

            gale_spear_trap1 = {
                prefab = "gale_spear_trap",
                offset = Vector3(9.86, 0.00, -0.66),
                fn = spear_trap_fn,
            },
            gale_spear_trap2 = {
                prefab = "gale_spear_trap",
                offset = Vector3(11.28, 0.00, -0.72),
                fn = spear_trap_fn,
            },

            gale_spear_trap3 = {
                prefab = "gale_spear_trap",
                offset = Vector3(10.00, 0.00, 1.22),
                fn = spear_trap_fn,
            },
            gale_spear_trap4 = {
                prefab = "gale_spear_trap",
                offset = Vector3(11.31, 0.00, 1.18),
                fn = spear_trap_fn,
            },

            gale_spear_trap5 = {
                prefab = "gale_spear_trap",
                offset = Vector3(9.82, -0.00, -2.46),
                fn = spear_trap_fn,
            },
            gale_spear_trap6 = {
                prefab = "gale_spear_trap",
                offset = Vector3(11.28, 0.00, -2.53),
                fn = spear_trap_fn,
            },

        }  

        
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )   

        local wall1_pos = 
        {
            Vector3(-0.50, 0.00, -0.50),Vector3(-2.50, 0.00, 0.50),Vector3(3.50, 0.00, 0.50),Vector3(-3.50, 0.00, 0.50),Vector3(-0.50, 0.00, 3.50),Vector3(3.50, 0.00, -0.50),Vector3(3.50, 0.00, -1.50),Vector3(3.50, 0.00, 1.50),Vector3(3.50, 0.00, -2.50),Vector3(-4.50, 0.00, 0.50),Vector3(0.50, 0.00, -4.50),Vector3(-1.50, 0.00, 4.50),Vector3(-3.50, 0.00, 3.50),Vector3(-2.50, 0.00, -4.50),Vector3(-5.50, 0.00, 0.50),Vector3(0.50, 0.00, -5.50),Vector3(-3.50, 0.00, -4.50),Vector3(3.50, 0.00, 4.50),Vector3(1.50, 0.00, 5.50),Vector3(4.50, 0.00, -3.50),Vector3(-5.50, 0.00, 2.50),Vector3(-4.50, 0.00, 4.50),Vector3(4.50, 0.00, 4.50),Vector3(-4.50, 0.00, -4.50),Vector3(5.50, 0.00, -3.50),Vector3(-6.50, 0.00, 2.50),Vector3(-5.50, 0.00, -4.50),Vector3(-6.50, 0.00, 3.50),Vector3(-6.50, 0.00, 4.50),Vector3(-7.50, 0.00, -2.50),Vector3(-6.50, 0.00, 5.50),
        }
        local wall2_pos = 
        {
            Vector3(0.50, 0.00, -1.50),Vector3(-1.50, 0.00, 1.50),Vector3(2.50, 0.00, -1.50),Vector3(-0.50, 0.00, 4.50),Vector3(0.50, 0.00, 4.50),Vector3(1.50, 0.00, 4.50),Vector3(3.50, 0.00, 3.50),Vector3(2.50, 0.00, 4.50),Vector3(-5.50, 0.00, -2.50),Vector3(4.50, 0.00, -4.50),Vector3(-6.50, 0.00, 1.50),Vector3(5.50, 0.00, 4.50),Vector3(6.50, 0.00, -3.50),Vector3(-7.50, 0.00, -3.50),Vector3(8.50, 0.00, -0.50),Vector3(8.50, 0.00, 0.50),Vector3(8.50, 0.00, 1.50),Vector3(8.50, 0.00, -1.50),Vector3(-7.50, 0.00, -4.50),Vector3(8.50, 0.00, 2.50),Vector3(8.50, 0.00, -2.50),Vector3(8.50, 0.00, -3.50),Vector3(-7.50, 0.00, -5.50),Vector3(8.50, 0.00, -4.50),Vector3(-9.50, 0.00, 2.50),Vector3(8.50, 0.00, -5.50),Vector3(-9.50, 0.00, 4.50),Vector3(-10.50, 0.00, 2.50),Vector3(-9.50, 0.00, 5.50),Vector3(-11.50, 0.00, 2.50),
        }
        local wall3_pos = 
        {
            Vector3(0.50, 0.00, 1.50),Vector3(1.50, 0.00, -1.50),Vector3(1.50, 0.00, 1.50),Vector3(-2.50, 0.00, -0.50),Vector3(-2.50, 0.00, -1.50),Vector3(2.50, 0.00, 1.50),Vector3(-2.50, 0.00, -2.50),Vector3(-2.50, 0.00, -3.50),Vector3(3.50, 0.00, 2.50),Vector3(3.50, 0.00, -3.50),Vector3(-2.50, 0.00, 4.50),Vector3(5.50, 0.00, 0.50),Vector3(5.50, 0.00, -0.50),Vector3(5.50, 0.00, -1.50),Vector3(-3.50, 0.00, 4.50),Vector3(-6.50, 0.00, 0.50),Vector3(6.50, 0.00, 0.50),Vector3(-6.50, 0.00, -2.50),Vector3(7.50, 0.00, 0.50),Vector3(-10.50, 0.00, -2.50),Vector3(-10.50, 0.00, -3.50),Vector3(-11.50, 0.00, -2.50),
        }

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            for k,offset in pairs(wall1_pos) do
                local wall = SpawnAt("gale_invincible_wall_hedge1",inst,nil,offset)
                wall.Transform:SetScale(1,0.7,1)
            end
            for k,offset in pairs(wall2_pos) do
                local wall = SpawnAt("gale_invincible_wall_hedge2",inst,nil,offset)
                wall.Transform:SetScale(1,0.7,1)
            end
            for k,offset in pairs(wall3_pos) do
                local wall = SpawnAt("gale_invincible_wall_hedge3",inst,nil,offset)
                wall.Transform:SetScale(1,0.7,1)
            end
        end
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_lobby",

    assets = {

    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {20,10}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/Ground_noise_jungle.tex",
                                                    inst.game_size)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_rock.tex")

            
        end
    end,

    serverfn = function(inst)   
        inst.components.gale_interior_room.layouts_data = {
            gale_eco_dome_fountain1 = {
                prefab = "gale_eco_dome_fountain",
                offset = Vector3(-5.93, 0.00, 3.34),
                fn = function(ent)
                    ent.Transform:SetScale(0.6,0.6,0.6)
                end,
            },
            gale_eco_dome_fountain2 = {
                prefab = "gale_eco_dome_fountain",
                offset = Vector3(5.93, 0.00, 3.34),
                fn = function(ent)
                    ent.Transform:SetScale(0.6,0.6,0.6)
                end,
            },
        }

        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                up_num = 2,
                right_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up1 = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up2 = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_right = function(ent,room,new_spanwed,on_loaded)
                        ent.style = "plate" 
                        -- if new_spanwed then
                        --     print(ent,"new spawned and set enabled false")
                        --     ent:SetEnabled(false)
                        -- end
                    end,
                },
            },
            inst.game_size
        )  
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_multlayer_spear_trap",

    assets = {

    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {10,30}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/interiors/shop_wall_bricks.tex",
                                                    inst.game_size)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_woodwall.tex")

            -- Cameras
            inst.dist_1 = 8
            inst.dist_2 = 6
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_z = player_pos.z - room_pos.z

                if math.abs(delta_z) >= inst.dist_2 then
                    delta_z = delta_z * inst.dist_1 / math.abs(delta_z)
                end

                target.Transform:SetPosition(room_pos.x,0,room_pos.z + delta_z)
            end)
        end
    end,

    serverfn = function(inst)      

        local function lever_fn_wrapper(indexs)
            
            local function lever_fn(ent,room,new_spawned,on_loaded)
                ent:ListenForEvent("gale_lever_direction_change",function(ent,data)
                    if data.old_direction == data.direction then
                        return 
                    end
                    for k,id in pairs(indexs) do
                        for i = 1,9 do
                            local spear_trap = room.components.gale_interior_room.layouts["gale_spear_trap"..id.."_"..i]
                            if spear_trap and spear_trap:IsValid() then
                                local goto_triggered = not spear_trap.triggered

                                if data.immediate then
                                    spear_trap.triggered = goto_triggered 
                                    spear_trap.sg:GoToState("idle")
                                else
                                    spear_trap.sg:GoToState(goto_triggered and "extending" or "retracting")
                                end
                            end
                        end
                    end
                end)
            end

            return lever_fn
        end

        

        inst.components.gale_interior_room.layouts_data = {
            treasurechest = {
                prefab = "treasurechest",
                offset = Vector3(0.21, 0.00, 13.68),
            },

            gale_lever_wood1 = {
                prefab = "gale_lever_wood",
                offset = Vector3(-4, 0.00, -9),
                fn = lever_fn_wrapper({1,4}),
            },
            gale_lever_wood2 = {
                prefab = "gale_lever_wood",
                offset = Vector3(-2, 0.00, -9),
                fn = lever_fn_wrapper({1,5}),
            },
            gale_lever_wood3 = {
                prefab = "gale_lever_wood",
                offset = Vector3(0, 0.00, -9),
                fn = lever_fn_wrapper({3,4}),
            },
            gale_lever_wood4 = {
                prefab = "gale_lever_wood",
                offset = Vector3(2, 0.00, -9),
                fn = lever_fn_wrapper({2,3}),
            },
            gale_lever_wood5 = {
                prefab = "gale_lever_wood",
                offset = Vector3(4, 0.00, -9),
                fn = lever_fn_wrapper({2,4,5}),
            },
        }  

        local level = 1
        for z = -6,10,4 do
            local width = 1
            for x = -4,4 do
                inst.components.gale_interior_room.layouts_data["gale_spear_trap"..level.."_"..width] = {
                    prefab = "gale_spear_trap",
                    offset = Vector3(x,0,z),
                    fn = spear_trap_fn
                }
                width = width + 1
            end
            level = level + 1
        end


        GaleInterior.CreateCorners(inst,{
            -- up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                down_num = 1,
                fns = {
                    door_down = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        ) 
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_dragon_snare",

    assets = {},

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {30,12}

        inst._boss_focus = net_bool(inst.GUID,"inst._boss_focus")
        inst._boss_entity = net_entity(inst.GUID,"inst._boss_entity")
        inst._boss_focus:set(false)

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/Ground_noise_savannah_detail.tex",
                                                    inst.game_size)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_fullwall_moulding.tex")

            -- Cameras
            inst.dist_1 = 8
            inst.dist_2 = 6
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                if inst._boss_focus:value() then
                    local dying_dragon_snare = inst._boss_entity:value()
                    if dying_dragon_snare ~= nil and dying_dragon_snare:IsValid() then
                        local boss_pos = dying_dragon_snare:GetPosition()
                        target.Transform:SetPosition(boss_pos.x,0,boss_pos.z)
                        return 
                    end
                end
                
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                if math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)      
        -- rabbithole multcolour: 150/255,255/255,10/255,1
        inst.components.gale_interior_room.layouts_data = {
            galeboss_dragon_snare = {
                prefab = "galeboss_dragon_snare",
                offset = Vector3(0,0,0),
                fn = function(ent)
                    -- inst._boss_entity:set(ent)
                    inst:ListenForEvent("death",function()
                        inst._boss_entity:set(ent)
                        inst._boss_focus:set(true)
                    end,ent)
                    inst:ListenForEvent("onremove",function()
                        inst._boss_focus:set(false)
                    end,ent)
                end,
            },

            gale_interior_window_greenhouse_up1 = {
                prefab = "gale_interior_window_greenhouse_up",
                offset = Vector3(-inst.game_size[1] / 4,0,inst.game_size[2] / 2),
                fn = function(ent)
                    ent.Transform:SetScale(1.14,1.25,1)
                end,
            },

            gale_interior_window_greenhouse_up2 = {
                prefab = "gale_interior_window_greenhouse_up",
                offset = Vector3(inst.game_size[1] / 4,0,inst.game_size[2] / 2),
                fn = function(ent)
                    ent.Transform:SetScale(1.14,1.25,1)
                end,
            },

            flower1 = {
                prefab = "flower",
                offset = Vector3(-0.68, 0.00, 1.05),
            },
            flower2 = {
                prefab = "flower",
                offset = Vector3(0.93, 0.00, -1.57),
            },
            flower3 = {
                prefab = "flower",
                offset = Vector3(-2.03, 0.00, -2.31),
            },
            rabbithole1 = {
                prefab = "rabbithole",
                offset = Vector3(1.73, 0.00, 3.56),
            },
            carrot_planted1 = {
                prefab = "carrot_planted",
                offset = Vector3(-3.77, 0.00, 1.40),
            },
            rabbithole2 = {
                prefab = "rabbithole",
                offset = Vector3(-1.34, 0.00, -4.47),
            },
            flower4 = {
                prefab = "flower",
                offset = Vector3(1.64, -0.00, -5.10),
            },
            rabbithole3 = {
                prefab = "rabbithole",
                offset = Vector3(4.55, 0.00, -3.75),
            },
            rabbit1 = {
                prefab = "rabbit",
                offset = Vector3(2.41, 0.00, 5.48),
            },
            flower5 = {
                prefab = "flower",
                offset = Vector3(-6.06, 0.00, -0.89),
            },
            rabbithole4 = {
                prefab = "rabbithole",
                offset = Vector3(-5.18, 0.00, 3.47),
            },
            rabbithole5 = {
                prefab = "rabbithole",
                offset = Vector3(6.38, 0.00, -0.96),
            },
            rabbit2 = {
                prefab = "rabbit",
                offset = Vector3(6.40, 0.00, -1.33),
            },
            rabbit3 = {
                prefab = "rabbit",
                offset = Vector3(-5.68, 0.00, -4.17),
            },
            carrot_planted2 = {
                prefab = "carrot_planted",
                offset = Vector3(5.85, 0.00, 4.26),
            },
            carrot_planted3 = {
                prefab = "carrot_planted",
                offset = Vector3(-5.24, 0.00, -5.05),
            },
            flower6 = {
                prefab = "flower",
                offset = Vector3(7.08, 0.00, 1.93),
            },
            rabbit4 = {
                prefab = "rabbit",
                offset = Vector3(-7.70, 0.00, 3.73),
            },
            carrot_planted4 = {
                prefab = "carrot_planted",
                offset = Vector3(7.96, 0.00, -3.24),
            },
            flower7 = {
                prefab = "flower",
                offset = Vector3(-7.50, 0.00, -5.25),
            },
            flower8 = {
                prefab = "flower",
                offset = Vector3(-9.07, -0.00, 3.47),
            },
            rabbithole6 = {
                prefab = "rabbithole",
                offset = Vector3(-9.32, 0.00, -3.68),
            },
            rabbithole7 = {
                prefab = "rabbithole",
                offset = Vector3(-9.95, 0.00, 1.42),
            },
            flower9 = {
                prefab = "flower",
                offset = Vector3(9.75, 0.00, -4.10),
            },
            flower10 = {
                prefab = "flower",
                offset = Vector3(-11.38, 0.00, -1.93),
            },
            carrot_planted5 = {
                prefab = "carrot_planted",
                offset = Vector3(11.65, 0.00, -0.68),
            },
            wateringcan1 = {
                prefab = "wateringcan",
                offset = Vector3(11.45, 0.00, 4.15),
            },
            carrot_planted6 = {
                prefab = "carrot_planted",
                offset = Vector3(-12.95, 0.00, 3.16),
            },
            compostingbin1 = {
                prefab = "compostingbin",
                offset = Vector3(13.00, 0.00, 4.50),
            },
            butterfly1 = {
                prefab = "butterfly",
                offset = Vector3(13.50, -0.00, 5.49),
            },
            butterfly2 = {
                prefab = "butterfly",
                offset = Vector3(14.48, 0.00, 1.93),
            },
            butterfly3 = {
                prefab = "butterfly",
                offset = Vector3(14.48, 0.00, 1.93),
            },
            butterfly4 = {
                prefab = "butterfly",
                offset = Vector3(14.50, -0.00, 5.49),
            },
        }  

        GaleInterior.CreateCorners(inst,{
            -- up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                right_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "plate" 
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        ) 
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_corridor2",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {56,8}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")

            -- Cameras
            inst.dist_1 = 19.5
            inst.dist_2 = 10
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                if math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)     
        inst.components.gale_interior_room.layouts_data = {

        }   
        GaleInterior.CreateCorners(inst,{
            -- up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                up_num = 4,
                right_num = 1,
                down_num = 1,
                fns = {
                    door_up1 = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up2 = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_up3 = function(ent,room,new_spanwed,on_loaded)
                        ent.style = "stone" 
                    end,
                    door_up4 = function(ent,room,new_spanwed,on_loaded)
                        ent.style = "stone" 
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_down = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_sanctuary",

    assets = {},

    tags = {
        "interior_room","eco_dome","sanctuary"
    },

    clientfn = function(inst)
        inst.game_size = {30,12}


        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        local water_polygon = Rectangle(0,0)
        water_polygon:SetPtList({
            Vector3(-inst.game_size[1] / 2,0,2),
            Vector3(inst.game_size[1] / 2,0,2),
            Vector3(inst.game_size[1] / 2,0,inst.game_size[2] / 2),
            Vector3(-inst.game_size[1] / 2,0,inst.game_size[2] / 2),
        })
        inst.components.gale_interior_room:AddWaterPolygon(water_polygon)

        local land_ocean_limit = SpawnPrefab("gale_physics_land_ocean_limit")
        land_ocean_limit:AttachPtList({
            Vector3(-inst.game_size[1] / 2,0,2),
            Vector3(inst.game_size[1] / 2,0,2),
        },5)
        GaleCommon.AddConstrainedPhysicsObj(inst,land_ocean_limit)

        if not TheNet:IsDedicated() then
            -- inst.floors = GaleInterior.CreateVFXFloors(inst,
            --                                         "levels/textures/Ground_noise_savannah_detail.tex",
            --                                         inst.game_size)

            local pos_leftdown1 = Vector3(-inst.game_size[1] / 2,0,2)
            local pos_rightup1 = Vector3(inst.game_size[1] / 2,0,inst.game_size[2] / 2)
            -- water floor 
            inst.floors1 = GaleInterior.CreateVFXFloorsAtRectangle(inst,
                                                    "levels/interiors/Ground_noise_water_shallow.tex",
                                                    pos_leftdown1,pos_rightup1)

            local pos_leftdown2 = Vector3(-inst.game_size[1] / 2,0,-inst.game_size[2] / 2)
            local pos_rightup2 = Vector3(inst.game_size[1] / 2,0,2)

            inst.floors2 = GaleInterior.CreateVFXFloorsAtRectangle(inst,
                                                    "levels/textures/Ground_noise_savannah_detail.tex",
                                                    pos_leftdown2,pos_rightup2)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_fullwall_moulding.tex")

            -- Cameras
            inst.dist_1 = 8
            inst.dist_2 = 6
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                if math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)      
        -- rabbithole multcolour: 150/255,255/255,10/255,1
        inst.components.gale_interior_room.layouts_data = {

        }  

        GaleInterior.CreateCorners(inst,{
            -- up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                right_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        ) 

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            local p1 = Vector3(-inst.game_size[1] / 2,0,1.66)
            local p2 = Vector3(inst.game_size[1] / 2,0,1.66)
            local delta = p2 - p1
            local norm = delta:GetNormalized()
            local rock_prefabs = {
                "farmrock",
                "farmrocktall",
                "farmrockflat",
            }

            local step = 1 / 2
            local cnt = 1
            for i = 1,delta:Length()-1,step do
                inst.components.gale_interior_room:AddLayout("farmrock"..cnt,{
                    prefab = GetRandomItem(rock_prefabs),
                    offset = p1 + norm * i,
                })
                cnt = cnt + 1
            end

        end


        -- Vector3(-inst.game_size[1] / 2,0,2),
        -- Vector3(inst.game_size[1] / 2,0,2),
        -- Vector3(inst.game_size[1] / 2,0,inst.game_size[2] / 2),
        -- Vector3(-inst.game_size[1] / 2,0,inst.game_size[2] / 2),

        local ocean_mid_z = (2 + inst.game_size[2] / 2) / 2
        local box_emitter = CreateBoxEmitter(-inst.game_size[1] / 2 + 8,
                                            0,
                                            ocean_mid_z-0.1,
                                            inst.game_size[1] / 2 - 8,
                                            0,
                                            ocean_mid_z+0.1)
        inst:DoPeriodicTask(0.33,function()
            -- local x,_,z = box_emitter()  
            for i = 1,3 do
                local x = GetRandomMinMax(-13,13)
                local z = GetRandomMinMax(ocean_mid_z - 0.8,ocean_mid_z - 0.1)
                SpawnAt("gale_wave_shimmer",inst,{0.4,0.4,0.4},Vector3(x,0,z))
            end
            
        end)
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_totally_ocean",

    assets = {},

    tags = {
        "interior_room","eco_dome","sanctuary"
    },

    clientfn = function(inst)
        inst.game_size = {30,12}


        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        local water_polygon = Rectangle(0,0)
        water_polygon:SetPtList({
            Vector3(-10,0,-inst.game_size[2] / 2),
            Vector3(inst.game_size[1] / 2,0,-inst.game_size[2] / 2),
            Vector3(inst.game_size[1] / 2,0,inst.game_size[2] / 2),
            Vector3(-10,0,inst.game_size[2] / 2),
        })
        inst.components.gale_interior_room:AddWaterPolygon(water_polygon)

        if not TheNet:IsDedicated() then
            -- inst.floors = GaleInterior.CreateVFXFloors(inst,
            --                                         "levels/textures/Ground_noise_savannah_detail.tex",
            --                                         inst.game_size)

            local pos_leftdown1 = Vector3(-10,0,-inst.game_size[2] / 2)
            local pos_rightup1 = Vector3(inst.game_size[1] / 2,0,inst.game_size[2] / 2)
            -- water floor 
            inst.floors1 = GaleInterior.CreateVFXFloorsAtRectangle(inst,
                                                    "levels/interiors/Ground_noise_water_shallow.tex",
                                                    pos_leftdown1,pos_rightup1)

            local pos_leftdown2 = Vector3(-inst.game_size[1] / 2,0,-inst.game_size[2] / 2)
            local pos_rightup2 = Vector3(-10,0,inst.game_size[2] / 2)

            inst.floors2 = GaleInterior.CreateVFXFloorsAtRectangle(inst,
                                                    "levels/textures/Ground_noise_savannah_detail.tex",
                                                    pos_leftdown2,pos_rightup2)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/shop_wall_fullwall_moulding.tex")

            -- Cameras
            inst.dist_1 = 8
            inst.dist_2 = 6
            inst.components.gale_interior_room:SetCameraTargetUpdateFn(function(target,room,player)
                local player_pos = player:GetPosition()
                local room_pos = room:GetPosition()
                local delta_x = player_pos.x - room_pos.x 

                if math.abs(delta_x) >= inst.dist_2 then
                    delta_x = delta_x * inst.dist_1 / math.abs(delta_x)
                end

                target.Transform:SetPosition(room_pos.x + delta_x,0,room_pos.z)
            end)
        end
    end,

    serverfn = function(inst)      
        -- rabbithole multcolour: 150/255,255/255,10/255,1
        inst.components.gale_interior_room.layouts_data = {

        }  

        GaleInterior.CreateCorners(inst,{
            -- up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                right_num = 1,
                fns = {
                    door_left = function(ent,room)
                        ent.style = "stone" 
                    end,
                    door_right = function(ent,room)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        ) 
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_trigger_two_walls",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {16,8}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/noise_sinkhole.tex",
                                                    inst.game_size)

            inst.floors.VFXEffect:SetScaleEnvelope(0,"gale_interior_floor_1024_scaleenvelope")

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_sinkhole.tex")
        end
    end,

    serverfn = function(inst)      
        local function line2_spear_trap_fn(ent,room,new_spawned,on_loaded)
            spear_trap_fn(ent,room,new_spawned,on_loaded)

            if new_spawned then
                ent.triggered = false 
                ent.sg:GoToState("idle")
            end
        end

        inst.components.gale_interior_room.layouts_data = {
            pressure_plate = {
                prefab = "gale_interior_pressure_plate_yellow_stone",
                offset = Vector3(-4,0,0),
                fn = function(ent,room)
                    ent.components.gale_creatureprox.on_occupied = function()
                        local layouts = room.components.gale_interior_room.layouts
                        for k,v in pairs(layouts) do
                            if k:find("gale_spear_trap_line1") then
                                v.sg:GoToState("retracting")
                            end
                            if k:find("gale_spear_trap_line2") then
                                v.sg:GoToState("extending")
                            end
                        end
                    end

                    ent.components.gale_creatureprox.on_empty = function()
                        local layouts = room.components.gale_interior_room.layouts
                        for k,v in pairs(layouts) do
                            if k:find("gale_spear_trap_line1") then
                                v.sg:GoToState("extending")
                            end
                            if k:find("gale_spear_trap_line2") then
                                v.sg:GoToState("retracting")
                            end
                        end
                    end
                end,
            },

            gale_spear_trap_line1_1 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, 0.53),
                fn = spear_trap_fn,
            },
            gale_spear_trap_line1_2 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, -0.85),
                fn = spear_trap_fn,
            },

            gale_spear_trap_line1_3 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, -2.08),
                fn = spear_trap_fn,
            },
            gale_spear_trap_line1_4 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, 2.16),
                fn = spear_trap_fn,
            },
            gale_spear_trap_line1_5 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, -3.34),
                fn = spear_trap_fn,
            },
            gale_spear_trap_line1_6 = {
                prefab = "gale_spear_trap",
                offset = Vector3(-2, 0.00, 3.54),
                fn = spear_trap_fn,
            },

            gale_spear_trap_line2_1 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, 0.53),
                fn = line2_spear_trap_fn,
            },
            gale_spear_trap_line2_2 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, -0.85),
                fn = line2_spear_trap_fn,
            },

            gale_spear_trap_line2_3 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, -2.08),
                fn = line2_spear_trap_fn,
            },
            gale_spear_trap_line2_4 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, 2.16),
                fn = line2_spear_trap_fn,
            },
            gale_spear_trap_line2_5 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, -3.34),
                fn = line2_spear_trap_fn,
            },
            gale_spear_trap_line2_6 = {
                prefab = "gale_spear_trap",
                offset = Vector3(2, 0.00, 3.54),
                fn = line2_spear_trap_fn,
            },

            gale_eco_dome_keycard1 = {
                prefab = "gale_eco_dome_keycard",
                offset = Vector3(3.5, 0.00, 2),
            },
        }  
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                fns = {
                    door_left = function(ent,room,new_spanwed)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            
        end        
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_room_many_crates",

    assets = {
        Asset("ANIM", "anim/gale_interior_floors.zip"),
    },

    tags = {
        "interior_room","eco_dome"
    },

    clientfn = function(inst)
        inst.game_size = {20,15}

        inst:AddComponent("gale_interior_room")
        inst.components.gale_interior_room:SetRectWH(unpack(inst.game_size))

        if not TheNet:IsDedicated() then
            inst.floors = GaleInterior.CreateVFXFloors(inst,
                                                    "levels/textures/Ground_noise_jungle.tex",
                                                    inst.game_size)

            inst.walls = GaleInterior.CreateWalls(inst,inst.game_size,WALL_HEIGHT,"levels/interiors/gale_wall_rock.tex")

            
        end
    end,

    serverfn = function(inst)      


        inst.components.gale_interior_room.layouts_data = {
            
        }  
        GaleInterior.CreateCorners(inst,{
            up_name = "gale_eco_dome_room_pillar_corner",
            down_name = "gale_eco_dome_room_pillar_sidewall",
        },inst.game_size)

        GaleInterior.CreateDoors(inst,
            {
                left_num = 1,
                fns = {
                    door_left = function(ent,room,new_spanwed)
                        ent.style = "stone" 
                    end,
                },
            },
            inst.game_size
        )

        inst.components.gale_interior_room.extra_built_fn = function(inst,builder)
            
        end        
    end,
})