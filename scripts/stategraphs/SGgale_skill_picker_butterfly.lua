local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")
require("util/vector4")

local events = {

}

local states = {
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                    -- inst:Remove()
                end
            end),
        },
    },
    -- c_spawn("gale_skill_picker_butterfly").sg:GoToState("land",{target=c_findnext("gale_spear"),owner=ThePlayer})
    State {
        name = "land",
        tags = { "canrotate" },

        onenter = function(inst, data)
            data.target:AddChild(inst)
            inst.Transform:SetPosition(0, 0.55, 0)

            inst.AnimState:PlayAnimation("land")

            inst.sg.statemem.target = data.target
            inst.sg.statemem.owner = data.owner

            inst:ListenForEvent("onpickup", function()
                                    if not inst.prepare_fadeout then
                                        inst.sg.statemem.target.Physics:Stop()
                                        inst:Remove()
                                    end
                                end, inst.sg.statemem.target)

            inst:ListenForEvent("onputininventory", function()
                                    if not inst.prepare_fadeout then
                                        inst.sg.statemem.target.Physics:Stop()
                                        inst:Remove()
                                    end
                                end, inst.sg.statemem.target)

            GaleCommon.FadeTo(inst, 1, nil, {
                                  Vector4(0, 0, 0, 0),
                                  Vector4(1, 1, 1, 1),
                              }, {
                                  Vector4(0, 0, 0, 1),
                                  Vector4(147 / 255, 245 / 255, 247 / 255, 1),
                              })
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("return", {
                        target = inst.sg.statemem.target,
                        owner = inst.sg.statemem.owner,
                    })
                end
            end),
        },
    },

    State {
        name = "return",
        tags = { "canrotate" },

        onenter = function(inst, data)
            inst.AnimState:SetDeltaTimeMultiplier(15)
            inst.AnimState:PlayAnimation("idle", true)

            inst.sg.statemem.target = data.target
            inst.sg.statemem.owner = data.owner
            inst.sg.statemem.height = 1.5
            inst.sg.statemem.speed_mult = 0.0
            inst.sg.statemem.base_speed = 12
        end,
        -- c_spawn("gale_skill_picker_butterfly").sg:GoToState("land",{target=c_findnext("gale_spear"),owner=ThePlayer})
        -- print(ThePlayer:GetAngleToPoint(c_findnext("dummytarget"):GetPosition():Get())-ThePlayer:GetRotation())
        onupdate = function(inst)
            if not (inst.sg.statemem.owner and inst.sg.statemem.owner:IsValid()) then
                inst.sg.statemem.target.Physics:Stop()
                inst:Remove()
                return
            end

            local owner_pos = inst.sg.statemem.owner:GetPosition()
            local my_pos = inst.sg.statemem.target:GetPosition()

            local dx = owner_pos.x - my_pos.x
            local dz = owner_pos.z - my_pos.z
            local dl = math.sqrt(dx * dx + dz * dz)

            local is_blocked = false
            local max_height = 0

            for add = 0, 2, 0.05 do
                if not TheWorld.Map:IsPassableAtPoint(my_pos.x + add * dx / dl, 0, my_pos.z + add * dz / dl) then
                    is_blocked = true

                    if add == 0 then
                        max_height = 5
                    else
                        max_height = 6
                        break
                    end
                end
            end



            if is_blocked then
                inst.sg.statemem.height = math.min(inst.sg.statemem.height + 15 * FRAMES, max_height)
            else
                inst.sg.statemem.height = math.max(inst.sg.statemem.height - 10 * FRAMES, 1.5)
            end



            local dy = owner_pos.y + inst.sg.statemem.height - my_pos.y


            local current_vel = Vector3(inst.sg.statemem.target.Physics:GetMotorVel())
            local delta_vel = Vector3(dx, dy, dz):GetNormalized() * 0.8


            local delta_angle = math.atan2(current_vel:Cross(delta_vel):Length(), current_vel:Dot(delta_vel))

            if math.abs(delta_angle) < PI / 3 then
                -- delta_vel = delta_vel * 0.75
                inst.sg.statemem.speed_mult = math.min(1, inst.sg.statemem.speed_mult + FRAMES * 1)
            else
                inst.sg.statemem.speed_mult = math.max(0.01, inst.sg.statemem.speed_mult - FRAMES * 1)
            end



            local final_vel = (current_vel + delta_vel):GetNormalized() * inst.sg.statemem.base_speed *
                inst.sg.statemem.speed_mult
            inst.sg.statemem.target.Physics:SetMotorVel(final_vel:Get())

            inst:ForceFacePoint(owner_pos:Get())
            inst.sg.statemem.target.Transform:SetRotation(0)



            if inst.sg.statemem.target:IsNear(inst.sg.statemem.owner, 1.5) then
                local x, y, z = inst.sg.statemem.target.Transform:GetWorldPosition()

                inst.sg.statemem.target.Physics:Stop()
                inst.sg.statemem.target:RemoveChild(inst)

                inst.Transform:SetPosition(x, y, z)

                inst.prepare_fadeout = true

                if inst.sg.statemem.owner.components.inventory:CanAcceptCount(inst.sg.statemem.target) > 0 then
                    inst.sg.statemem.owner.components.inventory:GiveItem(
                        inst.sg.statemem.target, nil, inst.sg.statemem.target:GetPosition()
                    )
                else
                    inst.sg.statemem.target.components.inventoryitem:DoDropPhysics(x, y, z)
                end


                inst.sg:GoToState("fadeout")
            end
        end,

        events =
        {

        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    },

    State {
        name = "fadeout",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("take_off")
            inst.AnimState:PushAnimation("flight_cycle", true)

            local rm, gm, bm, am = inst.AnimState:GetMultColour()
            local ra, ga, ba, aa = inst.AnimState:GetAddColour()
            GaleCommon.FadeTo(inst, GetRandomMinMax(1, 1.33), nil,
                              {
                                  Vector4(rm, gm, bm, am),
                                  Vector4(0, 0, 0, 0),
                              }, {
                                  Vector4(ra, ga, ba, aa),
                                  Vector4(0, 0, 0, 1),
                              }, function(inst)
                                  inst:Remove()
                              end)
        end,

        onexit = function(inst)
            inst:Remove()
        end,
    },
}


return StateGraph("SGgale_skill_picker_butterfly", states, events, "idle")
