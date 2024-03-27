local GaleEntity = require("util/gale_entity")

local function OnRemoveEntity(inst)
    inst._hascanopy:set(false)
end

local SHADOW_RANGE = 5
local LIGHT_RAY_RANGE = 4.5

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_forest_pillar_tree",

    assets = {
        Asset("ANIM", "anim/pillar_tree.zip"),

        Asset( "IMAGE", "images/map_icons/gale_forest_pillar_tree.tex" ), --小地图
        Asset( "ATLAS", "images/map_icons/gale_forest_pillar_tree.xml" ),
    },

    tags = {"gale_forest_pillar_tree","NOCLICK"},
    
    bank = "pillar_tree",
    build = "pillar_tree",
    anim = "idle",

    loop_anim = true,

    clientfn = function(inst)
        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("gale_forest_pillar_tree.tex")

        inst.entity:SetAABB(60, 20)
        
        MakeObstaclePhysics(inst, 2.75, 24)
        
        inst.nameoverride = "evergreen_sparse"


        if not TheNet:IsDedicated() then
            inst:AddComponent("distancefade")
            inst.components.distancefade:Setup(15,25)
    
            inst:AddComponent("canopyshadows")
            inst.components.canopyshadows.range = SHADOW_RANGE
    
            inst:ListenForEvent("hascanopydirty", function()
                if not inst._hascanopy:value() then
                    inst:RemoveComponent("canopyshadows")
                end
            end)
        end
    
        inst._hascanopy = net_bool(inst.GUID, "gale_forest_pillar_tree._hascanopy", "hascanopydirty")
        inst._hascanopy:set(true)
    end,


    serverfn = function(inst)
        inst.AnimState:SetTime(math.random(0,30) * FRAMES)

        -- inst:AddComponent("inspectable")
        -- inst.components.inspectable.nameoverride = "evergreen"

        -- inst:AddComponent("canopylightrays")
        -- inst.components.canopylightrays.range = LIGHT_RAY_RANGE

        inst.OnRemoveEntity = OnRemoveEntity
    end,

})