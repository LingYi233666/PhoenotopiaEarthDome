local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

return GaleEntity.CreateNormalFx({
    prefabname = "gale_groundstone_fx",
    
    bank = "gale_groundstone_fx",
    build = "gale_groundstone_fx",
    -- anim = "anim",

    animover_remove = false,

    clientfn = function(inst)
        -- 
    end,

    -- c_spawn("gale_groundstone_fx"):Trigger("fx5")
    serverfn = function(inst)
        inst.Trigger = function(inst,symbol,scale,durations)
            local dirt_colour = Vector4(100/255,77/255,50/255,1)
            inst.AnimState:PlayAnimation("anim")

            scale = scale or 5
            durations = durations or {
                0.25,1.5,1
            }
            if symbol then
                inst.AnimState:OverrideSymbol("fx0","gale_groundstone_fx",symbol)
            end

            inst.AnimState:SetMultColour(0,0,0,0)
            inst.AnimState:SetAddColour(0,0,0,0)

            GaleCommon.FadeTo(inst,durations[1],{
                Vector3(scale * 0.6,scale * 0.6,scale * 0.6),
                Vector3(scale,scale,scale),
            },{
                Vector4(0,0,0,0),
                dirt_colour,
            },nil,function()
                
                inst:DoTaskInTime(durations[2],function()
                    GaleCommon.FadeTo(inst,durations[3],nil,{
                        dirt_colour,
                        Vector4(0,0,0,0),
                    },nil,inst.Remove)
                end)
            end)
        end
    end,
})