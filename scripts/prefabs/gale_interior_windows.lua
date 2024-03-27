local GaleEntity = require("util/gale_entity")

local assets = {
    
    
    Asset("ANIM", "anim/interior_window_greenhouse.zip"),
    Asset("ANIM", "anim/interior_window_greenhouse_build.zip"),
}

local function WindowOnPhase(inst)
    local phase = TheWorld.state.phase
    if phase == "day" then
        inst.AnimState:PlayAnimation("to_day")
        inst.AnimState:PushAnimation("day_loop", true)
    elseif phase == "night" then
       inst.AnimState:PlayAnimation("to_night")
        inst.AnimState:PushAnimation("night_loop", true)
    elseif phase == "dusk" then
        inst.AnimState:PlayAnimation("to_dusk")
        inst.AnimState:PushAnimation("dusk_loop", true)
    end
end



local function MakeWindow(out_data)
    local results = {}
    if out_data.light_side then
        table.insert(results,GaleEntity.CreateNormalEntity({
            prefabname = out_data.prefabname.."_light_side",
    
            assets = assets,

            tags = {"NOCLICK","NOBLOCK"},
    
            bank = out_data.light_side.bank,
            build = out_data.light_side.build,
    
            clientfn = function(inst)
                inst.Transform:SetTwoFaced()
            end,
    
            serverfn = function(inst)
                inst:WatchWorldState("phase",WindowOnPhase)
                WindowOnPhase(inst)
            end,
        }))
    end
    
    if out_data.window_side then
        table.insert(results,GaleEntity.CreateNormalEntity({
            prefabname = out_data.prefabname.."_side",
    
            assets = assets,

            tags = {"NOCLICK","NOBLOCK"},
    
            bank = out_data.window_side.bank,
            build = out_data.window_side.build,
    
            clientfn = function(inst)
                inst.Transform:SetTwoFaced()
            end,
    
            serverfn = function(inst)
                inst.window_light = inst:SpawnChild(out_data.prefabname.."_light_side")
                inst.window_light:DoTaskInTime(0,function ()
                    inst.window_light.Transform:SetRotation(inst.Transform:GetRotation())
                end)
                inst:WatchWorldState("phase",WindowOnPhase)
                WindowOnPhase(inst)
            end,
        }))
    end

    if out_data.light_up then 
        table.insert(results,GaleEntity.CreateNormalEntity({
            prefabname = out_data.prefabname.."_light_up",

            assets = assets,

            tags = {"NOCLICK","NOBLOCK"},

            bank = out_data.light_up.bank,
            build = out_data.light_up.build,

            serverfn = function(inst)
                inst:WatchWorldState("phase",WindowOnPhase)
                WindowOnPhase(inst)
            end,
        })) 
    end
    
    if out_data.window_up then
        table.insert(results,GaleEntity.CreateNormalEntity({
            prefabname = out_data.prefabname.."_up",
    
            assets = assets,

            tags = {"NOCLICK","NOBLOCK"},
    
            bank = out_data.window_up.bank,
            build = out_data.window_up.build,
    
            serverfn = function(inst)
                inst.window_light = inst:SpawnChild(out_data.prefabname.."_light_up")
                inst:WatchWorldState("phase",WindowOnPhase)
                WindowOnPhase(inst)
            end,
        }))
    end

    return results
end

return unpack(ConcatArrays(
    MakeWindow({
        prefabname = "gale_interior_window_greenhouse",
        light_side = {
            bank = "interior_window_greenhouse_light_side",
            build = "interior_window_greenhouse_build",
        },
        window_side = {
            bank = "interior_window_greenhouse_side",
            build = "interior_window_greenhouse_build",
        },
        light_up = {
            bank = "interior_window_greenhouse_light",
            build = "interior_window_greenhouse_build",
        },
        window_up = {
            bank = "interior_window_greenhouse",
            build = "interior_window_greenhouse_build",
        },
    }),
    {}
))