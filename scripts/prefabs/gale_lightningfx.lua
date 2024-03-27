local LightningDrawer = require("util/lightning_drawer")
local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM", "anim/gale_lightningfx.zip"),
}

return GaleEntity.CreateNormalFx({
    prefabname = "gale_lightningfx_segment",
    assets = assets,

    bank = "gale_lightningfx",
    build = "gale_lightningfx",

    animover_remove = false,


    clientfn = function(inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        inst.AnimState:SetDeltaTimeMultiplier(5)
    end,

    serverfn = function(inst)
        inst.Emit = function(inst,p1,p2)
            inst.Transform:SetPosition(p1:Get())
            inst:ForceFacePoint(p2)

            local dist = (p2-p1):Length()
            inst.AnimState:SetScale(dist,1.2,1)

            inst.AnimState:PlayAnimation("spawn_1")
            inst.AnimState:PushAnimation("despawn_1",false)
        end

        inst:ListenForEvent("animqueueover",function(inst)
            if inst.AnimState:AnimDone() then
                inst:Remove()
            end
        end)
    end,
}),

-- local sp=ThePlayer:GetPosition() local ep=TheInput:GetWorldPosition() print(sp,ep) c_spawn("gale_lightningfx"):Emit(sp,ep)
GaleEntity.CreateNormalFx({
    prefabname = "gale_lightningfx",
    assets = assets,


    clientfn = function(inst)
        inst._scale = net_float(inst.GUID,"inst._scale")
        inst._p1_x = net_float(inst.GUID,"inst._p1_x")
        inst._p1_z = net_float(inst.GUID,"inst._p1_z")
        inst._p2_x = net_float(inst.GUID,"inst._p2_x")
        inst._p2_z = net_float(inst.GUID,"inst._p2_z")

        inst._emit_trigger = net_event(inst.GUID,"inst._emit_trigger")
        -- inst._emit_trigger = net_bool(inst.GUID,"inst._emit_trigger","triggerdirty")

        inst._scale:set(1)
        -- inst._emit_trigger:set(false)

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("inst._emit_trigger",function()
                -- print(inst,"triggerdirty pre:",inst._emit_trigger:value())
                -- if inst._emit_trigger:value() ~= true then
                --     return 
                -- end
                -- print(inst,"triggerdirty !!!!!!")
                local start_pos = Vector3(inst._p1_x:value(),0,inst._p1_z:value())
                local end_pos = Vector3(inst._p2_x:value(),0,inst._p2_z:value())
                local points = LightningDrawer.DrawPoints(
                    start_pos,end_pos)

                -- print("start_pos =",start_pos)
                -- print("end_pos =",end_pos)
                -- print("DrawPoints:Draw",#points,"points")

                for k,p1 in pairs(points) do
                    -- print("emit at ",p1)
                    if k < #points then
                        local p2 = points[k+1]

                        local segment = GaleEntity.CreateClientAnim({
                            bank = "gale_lightningfx",
                            build = "gale_lightningfx",

                            lightoverride = 1,
                        })

                        segment.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                        segment.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
                        segment.AnimState:SetSortOrder(3)

                        segment.AnimState:SetSymbolMultColour("bg",0,229/255, 232/255,1)

                        -- segment.AnimState:SetMultColour(1,0,0,1)

                        segment.AnimState:SetDeltaTimeMultiplier(5)

                        segment.Transform:SetPosition(p1:Get())
                        segment:ForceFacePoint(p2)

                        local dist = (p2-p1):Length()
                        segment.AnimState:SetScale(dist,inst._scale:value(),1)

                        segment.AnimState:PlayAnimation("spawn_3")
                        segment.AnimState:PushAnimation("despawn_3",false)

                        segment:ListenForEvent("animqueueover",function()
                            if segment.AnimState:AnimDone() then
                                segment:Remove()
                            end
                        end)

                        -- SpawnPrefab("gale_lightningfx_segment"):Emit(p1,p2)
                    end
                end
            end)
        end
    end,

    serverfn = function(inst)
        inst.Emit = function(inst,start_pos,finish_pos,scale,remove)
            inst.Transform:SetPosition(start_pos:Get())

            inst._p1_x:set(start_pos.x)
            inst._p1_z:set(start_pos.z)
            inst._p2_x:set(finish_pos.x)
            inst._p2_z:set(finish_pos.z)

            inst._scale:set(scale or 1)

            inst._emit_trigger:push()
            -- inst._emit_trigger:set(true)

            if remove == nil or remove == true then
                inst:DoTaskInTime(20 * FRAMES,inst.Remove)
                -- inst:Remove()
            end
        end
    end,
})
