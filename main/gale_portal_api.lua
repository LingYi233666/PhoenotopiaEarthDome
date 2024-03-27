local Screen = require "widgets/screen"
local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local MapControls = require "widgets/mapcontrols"
local HudCompass = require "widgets/hudcompass"

local GalePortalMapScreen = require("screens/gale_portal_mapscreen")

local GaleCommon = require("util/gale_common")

-- ThePlayer.HUD.controls:PushGalePortalMap()
-- ThePlayer.HUD.controls.GalePortalMap:FocusMapOnWorldPosition(c_findnext("pigking"):GetPosition())
-- ThePlayer.HUD.controls.GalePortalMap.minimap.img:SetSize(5,5)
-- TheCamera:SetHeadingTarget(-90)
-- TheCamera:GetRightVec()
-- TheCamera:GetDownVec()
-- dumptable(TheWorld.net.replica.gale_portal_manager.portals)
AddClassPostConstruct("widgets/controls", function(self)
    self.PushGalePortalMap = function(self, start_tower_guid)
        if self.GalePortalMap ~= nil then
            self:PopGalePortalMap()
        end

        TheCamera:SetHeadingTarget(-90)

        local pt_list = {}
        local start_id = 1
        for k, v in pairs(TheWorld.net.replica.gale_portal_manager.portals) do
            table.insert(pt_list, { guid = v.guid, pos = Vector3(v.pos.x, 0, v.pos.z) })

            if start_tower_guid and start_tower_guid == v.guid then
                start_id = k
            end
        end

        self.GalePortalMap = GalePortalMapScreen(self.owner, pt_list, start_id)

        TheFrontEnd:PushScreen(self.GalePortalMap)
    end

    self.PopGalePortalMap = function(self)
        if self.GalePortalMap ~= nil then
            TheFrontEnd:PopScreen(self.GalePortalMap)
            self.GalePortalMap = nil
        end
    end
end)

AddReplicableComponent("gale_portal_manager")

AddPrefabPostInit("forest_network", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("gale_portal_manager")
end)

AddPrefabPostInit("cave_network", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("gale_portal_manager")
end)

-- RPCs
AddModRPCHandler("gale_rpc", "gale_portal_teleport", function(inst, start_guid, target_guid)
    local start_portal = TheWorld.net.components.gale_portal_manager:GetPortalByGUID(start_guid)
    local target_portal = TheWorld.net.components.gale_portal_manager:GetPortalByGUID(target_guid)

    if start_portal and start_portal:IsValid()
        and target_portal and target_portal:IsValid() then
        start_portal:PushEvent("gale_portal_activite", {
            time_remain = 3.5,
            sound = true,
        })
        target_portal:PushEvent("gale_portal_activite", {
            time_remain = 8.5
        })

        inst.sg:GoToState("gale_portal_hopping_pre", {
            start_portal = start_portal,
            target_portal = target_portal,
        })
    end
end)

AddClientModRPCHandler("gale_rpc", "open_gale_portal_screen", function(start_tower_guid)
    ThePlayer.HUD.controls:PushGalePortalMap(start_tower_guid)
end)


-- Actions
AddAction("GALE_OPEN_PORTAL", "GALE_OPEN_PORTAL", function(act)
    if act.target:IsValid() then
        if act.target:HasTag("athetos_type") then
            -- Gale can't use Athetos's portal currently.

            act.target.SoundEmitter:PlaySound("gale_sfx/fran_door/DroneError")
            return false
        else
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["open_gale_portal_screen"], act.doer.userid, act.target.GUID)
            return true
        end
    end
end)

ACTIONS.GALE_OPEN_PORTAL.priority = 0


AddComponentAction("SCENE", "gale_portal", function(inst, doer, actions, right)
    if inst:HasTag("gale_portal") then
        table.insert(actions, ACTIONS.GALE_OPEN_PORTAL)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_OPEN_PORTAL, function(inst)
    return "give"
end))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GALE_OPEN_PORTAL, function(inst)
    return "give"
end))

local function GetHopPreAnim(inst)
    return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and
    "boat_jumpheavy_pre" or "boat_jump_pre"
end

local function GetHopLoopAnim(inst)
    return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and
    "boat_jumpheavy_loop" or "boat_jump_loop"
end

local function GetHopPstAnim(inst)
    return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and
    "boat_jumpheavy_pst" or "boat_jump_pst"
end

AddStategraphState("wilson", State
    {
        name = "gale_portal_hopping_pre",
        tags = { "busy", "nointerrupt", "nopredict", "gale_portal_hopping" },

        onenter = function(inst, data)
            GaleCommon.ToggleOffPhysics(inst)

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(GetHopPreAnim(inst))
            inst.AnimState:PushAnimation(GetHopLoopAnim(inst), true)

            inst.sg.statemem.start_portal = data.start_portal
            inst.sg.statemem.target_portal = data.target_portal
            inst.sg.statemem.duration = data.duration or 1.8

            inst.sg.statemem.last_dist = math.sqrt(inst:GetDistanceSqToInst(inst.sg.statemem.start_portal))
            inst.sg.statemem.speed_to = inst.sg.statemem.last_dist / inst.sg.statemem.duration


            inst.sg:SetTimeout(inst.sg.statemem.duration)

            -- inst.AnimState:SetFinalOffset(2)
            inst.AnimState:SetLayer(LAYER_WORLD_DEBUG)

            -- inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump_on")
            inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
        end,

        onupdate = function(inst)
            if not (inst.sg.statemem.start_portal
                    and inst.sg.statemem.start_portal:IsValid()
                    and inst.sg.statemem.start_portal.components.gale_portal
                    and inst.sg.statemem.target_portal
                    and inst.sg.statemem.target_portal:IsValid()
                    and inst.sg.statemem.target_portal.components.gale_portal
                ) then
                inst.sg:GoToState("gale_portal_hopping_pst", {})

                return
            else
                inst:ForceFacePoint(inst.sg.statemem.start_portal:GetPosition():Get())

                local dist = math.sqrt(inst:GetDistanceSqToInst(inst.sg.statemem.start_portal))
                if dist > inst.sg.statemem.last_dist then
                    inst.sg.statemem.speed_to = 0
                    inst.Physics:Stop()
                else
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed_to, 0, 0)
                end
            end
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.target_portal
                and inst.sg.statemem.target_portal:IsValid()
                and inst.sg.statemem.target_portal.components.gale_portal then
                inst.sg:GoToState("gale_portal_hopping_loop", {
                    pos = inst.sg.statemem.target_portal:GetPosition(),
                    start_portal = inst.sg.statemem.start_portal,
                    target_portal = inst.sg.statemem.target_portal,
                })
            end
        end,

        onexit = function(inst)
            inst.sg.statemem.speed_to = 0
            inst.Physics:Stop()
            GaleCommon.ToggleOnPhysics(inst)
            inst.AnimState:SetLayer(LAYER_WORLD)
        end,
    })

AddStategraphState("wilson", State
    {
        name = "gale_portal_hopping_loop",
        tags = { "busy", "nointerrupt", "nopredict", "gale_portal_hopping" },

        onenter = function(inst, data)
            GaleCommon.ToggleOffPhysics(inst)

            inst.sg:SetTimeout(data.duration or 5)

            inst.sg.statemem.pos = data.pos

            inst.sg.statemem.start_portal = data.start_portal
            inst.sg.statemem.target_portal = data.target_portal

            inst.sg.statemem.flash_fx = SpawnPrefab("gale_fran_door_flash_fx")
            inst.sg.statemem.flash_fx.entity:SetParent(inst.entity)
            inst.sg.statemem.flash_fx.entity:AddFollower()
            inst.sg.statemem.flash_fx.Follower:FollowSymbol(inst.GUID, "torso", 0, 0, 0.05)

            inst.sg.statemem.auto_flash = true
            inst.sg.statemem.shown = true

            inst.sg.statemem.flash_task = inst:DoPeriodicTask(3 * FRAMES, function()
                if inst.sg.statemem.flash_fx and inst.sg.statemem.auto_flash then
                    if inst.sg.statemem.shown then
                        inst.sg.statemem.flash_fx:Hide()
                    else
                        inst.sg.statemem.flash_fx:Show()
                    end

                    inst.sg.statemem.shown = not inst.sg.statemem.shown
                end
            end)

            inst.AnimState:SetLayer(LAYER_WORLD_DEBUG)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
        end,


        ontimeout = function(inst)
            inst.sg:GoToState("gale_portal_hopping_pst", {
                start_portal = inst.sg.statemem.start_portal,
                target_portal = inst.sg.statemem.target_portal,
            })
        end,

        timeline = {
            TimeEvent(0, function(inst)
                inst.sg.statemem.fadeout_thread = GaleCommon.FadeTo(inst, FRAMES * 5, {
                    Vector3(1, 1, 1),
                    Vector3(0.9, 1.1, 1),
                })
            end),

            TimeEvent(5 * FRAMES, function(inst)
                inst.sg.statemem.flash_fx:Hide()
                if inst.sg.statemem.fadeout_thread then
                    KillThread(inst.sg.statemem.fadeout_thread)
                    inst.sg.statemem.fadeout_thread = nil
                end

                inst.sg.statemem.fadeout_thread = GaleCommon.FadeTo(inst, FRAMES * 5, {
                    Vector3(0.9, 1.1, 1),
                    Vector3(1.1, 0.8, 1),
                })
            end),

            TimeEvent(10 * FRAMES, function(inst)
                inst.sg.statemem.flash_fx:Show()
                if inst.sg.statemem.fadeout_thread then
                    KillThread(inst.sg.statemem.fadeout_thread)
                    inst.sg.statemem.fadeout_thread = nil
                end

                inst.sg.statemem.fadeout_thread = GaleCommon.FadeTo(inst, FRAMES * 5, {
                    Vector3(1.1, 0.8, 1),
                    Vector3(0.1, 1.6, 1),
                })
            end),


            TimeEvent(13 * FRAMES, function(inst)
                local vfx = SpawnPrefab("gale_portal_teleport_vfx")
                vfx.entity:SetParent(inst.entity)
                vfx.entity:AddFollower()
                vfx.Follower:FollowSymbol(inst.GUID, "torso", 0, -125, 0.05)

                vfx:DoTaskInTime(3 * FRAMES, vfx.Remove)
            end),


            TimeEvent(15 * FRAMES, function(inst)
                inst.sg.statemem.flash_fx:Hide()
                if inst.sg.statemem.fadeout_thread then
                    KillThread(inst.sg.statemem.fadeout_thread)
                    inst.sg.statemem.fadeout_thread = nil
                end





                inst.sg.statemem.auto_flash = false
                inst:Hide()

                -- Spawn some fx
            end),



            TimeEvent(50 * FRAMES, function(inst)
                inst:ScreenFade(false, 1)
            end),

            TimeEvent(100 * FRAMES, function(inst)
                inst.Transform:SetPosition(inst.sg.statemem.pos:Get())
                inst.player_classified.camerasnap:set_local(false)
                inst.player_classified.camerasnap:set(false)
                inst:ScreenFade(true, 1)
            end),

        },


        onexit = function(inst)
            if inst.sg.statemem.flash_task then
                inst.sg.statemem.flash_task:Cancel()
            end

            inst.Transform:SetScale(1, 1, 1)
            if inst.sg.statemem.fadeout_thread then
                KillThread(inst.sg.statemem.fadeout_thread)
            end
            inst:Show()
            inst.Transform:SetPosition(inst.sg.statemem.pos:Get())

            inst.player_classified.camerasnap:set_local(false)
            inst.player_classified.camerasnap:set(false)
            inst:ScreenFade(true)

            GaleCommon.ToggleOnPhysics(inst)
            inst.AnimState:SetLayer(LAYER_WORLD)

            if inst.sg.statemem.flash_fx then
                inst.sg.statemem.flash_fx:Remove()
                inst.sg.statemem.flash_fx = nil
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    })

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

AddStategraphState("wilson", State
    {
        name = "gale_portal_hopping_pst",
        tags = { "busy", "nointerrupt", "nopredict", "gale_portal_hopping" },

        onenter = function(inst, data)
            GaleCommon.ToggleOffPhysics(inst)

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(GetHopPstAnim(inst))

            inst.sg.statemem.start_portal = data.start_portal
            inst.sg.statemem.target_portal = data.target_portal

            local pt = inst:GetPosition()
            local angle = math.random() * 2 * PI
            local radius = GetRandomMinMax(2, 3)

            local offset =
                FindWalkableOffset(pt, angle, radius, 8, true, false, NoPlayersOrHoles) or
                FindWalkableOffset(pt, angle, radius * .5, 6, true, false, NoPlayersOrHoles) or
                FindWalkableOffset(pt, angle, radius, 8, true, false, NoHoles) or
                FindWalkableOffset(pt, angle, radius * .5, 6, true, false, NoHoles)


            if offset then
                inst:ForceFacePoint((pt + offset):Get())
                local time = inst.AnimState:GetCurrentAnimationLength()
                inst.Physics:SetMotorVel(offset:Length() / time, 0, 0)
                inst.sg:SetTimeout(time * 0.58)

                inst.sg.statemem.fade_thread = GaleCommon.FadeTo(inst, time * 0.58, nil, {
                    Vector4(0, 0, 0, 0),
                    Vector4(1, 1, 1, 1),
                })
            end

            if data.target_portal and data.target_portal:IsValid() then
                inst.sg.statemem.flash_fx = SpawnPrefab("gale_fran_door_flash_fx")

                inst.sg.statemem.flash_fx.entity:SetParent(data.target_portal.entity)
                inst.sg.statemem.flash_fx.entity:AddFollower()
                inst.sg.statemem.flash_fx.Follower:FollowSymbol(data.target_portal.GUID, "base", 0, -300, 0.05)
                inst.sg.statemem.flash_fx.Transform:SetScale(0.8, 0.8, 0.8)
                inst.sg.statemem.flash_fx.AnimState:SetMultColour(1, 1, 1, 1)

                -- inst.sg.statemem.flash_fx.AnimState:SetScale(2,2,2)
                -- inst.sg.statemem.flash_fx:Show()

                GaleCommon.FadeTo(inst.sg.statemem.flash_fx, 1.5, {
                                      Vector3(0.8, 0.8, 0.8),
                                      Vector3(0.4, 0.4, 0.4),
                                  }, {
                                      Vector4(1, 1, 1, 1),
                                      Vector4(0, 0, 0, 0),
                                  }, nil, function(fx)
                                      inst.sg.statemem.flash_fx = nil
                                      fx:Remove()
                                  end)


                inst.SoundEmitter:PlaySound("dontstarve/common/together/spawn_vines/spawnportal_open")
            end
        end,

        ontimeout = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            GaleCommon.ToggleOnPhysics(inst)

            if inst.sg.statemem.fade_thread then
                KillThread(inst.sg.statemem.fade_thread)
            end
        end,
    })
