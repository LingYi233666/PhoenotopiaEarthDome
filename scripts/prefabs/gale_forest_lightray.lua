local GaleEntity = require("util/gale_entity")


local RAYS_ID ={
    DAY = 1,
    DUSK = 2,
    NIGHT = 3,
}

local function OnEntityWake(inst)
    inst.Transform:SetRotation(45)
end

local function showlightrays(inst)
    local rays = {1,2,3,4,5,6,7,8,9,10,11}
    for i=1,#rays,1 do
        inst.AnimState:Hide("lightray"..i)
    end

    for i=1,math.random(2,3),1 do
        local selection =math.random(1,#rays)
        inst.AnimState:Show("lightray"..rays[selection]) 
        table.remove(rays,selection)
    end
end

local function hiderays(inst)
    inst.rayshidden = true
    local rays = {1,2,3,4,5,6,7,8,9,10,11}
    for i=1,#rays,1 do
        inst.AnimState:Hide("lightray"..i)
    end
end

local function hidelightrays(inst)
    inst.intensity_target = 0
end

local function updateintensity(inst)
    local inc = 0.5/ (5 * 30)
    if inst.intensity ~= inst.intensity_target then
        if inst.intensity < inst.intensity_target then
            inst.intensity = math.min(inst.intensity + inc, inst.intensity_target)
        elseif inst.intensity > inst.intensity_target then
            inst.intensity = math.max(inst.intensity - inc, inst.intensity_target)
        end 
    end

    if inst.intensity <= 0 and not inst.rayshidden then
        hiderays(inst)
    end

    if inst.intensity > 0 and inst.rayshidden then
        inst.rayshidden = nil
        showlightrays(inst)
    end        
end

local function OnPhase(inst, phase)

    if phase == "dusk" then
        inst._rays:set(RAYS_ID.DUSK)
    end

    if phase == "night" then
        inst._rays:set(RAYS_ID.NIGHT)
    end

    if phase == "day" then
        inst._rays:set(RAYS_ID.DAY)
    end
end

local function getintensity(inst)
    return inst.intensity or 1
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_forest_lightray",

    assets = {
        Asset("ANIM", "anim/lightrays.zip"),
    },

    tags = {"NOBLOCK","NOCLICK","lightrays","exposure","ignorewalkableplatforms"},
    
    bank = "lightrays",
    build = "lightrays",
    anim = "idle_loop",

    loop_anim = true,

    clientfn = function(inst)
        inst.entity:AddLight()        

        -- inst.OnEntityWake = OnEntityWake

        inst.Transform:SetRotation(45)
        inst.Transform:SetEightFaced()

        inst.intensity = 1
        inst.intensity_target = 1

        inst._rays = net_tinybyte(inst.GUID, "lightrays_canopy._rays", "raysdirty")

        inst:ListenForEvent("raysdirty", function()
            local rays = inst._rays:value()
            if rays == RAYS_ID.DAY then
                if not inst.lastphasefullmoon then 
                    inst.intensity_target = 1
                end
            elseif rays == RAYS_ID.DUSK then
                inst.intensity_target = 0.3
            else
                if TheWorld.state.isfullmoon then 
                    inst.intensity_target = 1
                else
                    hidelightrays(inst)
                end
            end
            inst.lastphasefullmoon = TheWorld.state.isfullmoon
        end)
        inst:DoPeriodicTask(1*FRAMES, updateintensity)

        showlightrays(inst)


        if not TheNet:IsDedicated() then
            inst:AddComponent("distancefade")
            inst.components.distancefade:Setup(15,25)
            inst.components.distancefade:SetExtraFn(getintensity)
        end
    end,


    serverfn = function(inst)
        inst:WatchWorldState("phase", OnPhase)

        inst:AddComponent("savedrotation")
    end,
})
