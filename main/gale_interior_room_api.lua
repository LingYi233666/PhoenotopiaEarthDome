require "components/map"
local UpvalueHacker = require("util/upvaluehacker")
local GaleInterior = require("util/gale_interior")

local interior_vfx_assets = {
	Asset("IMAGE", resolvefilepath("levels/interiors/antcave_floor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/antcave_floor_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/antcave_wall_rock.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/antcave_wall_rock_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/batcave_floor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/batcave_floor_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/batcave_wall_rock.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/batcave_wall_rock_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_cityhall.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_gardenstone.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_geometrictiles.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_marble_royal.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_shag_carpet.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_transitional.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/floor_woodpanels.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/gale_wall_dirt.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/gale_wall_rock.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/gale_wall_sinkhole.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/Ground_noise_water_shallow.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/minimap_floor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/mini_antcave_floor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/mini_floor_marble_royal.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/mini_woodfloor_noise.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/noise_farmland.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/noise_gardenstone.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/noise_snakeskinfloor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/noise_woodfloor.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_checker.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_checkered.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_checker_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_herringbone.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_hexagon.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_hoof_curvy.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_marble.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_marble_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_octagon.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_sheetmetal.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_sheetmetal_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_woodmetal.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_woodmetal_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_floor_woodpaneling2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_bricks.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_checkered.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_checkered_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_checkered_metal.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_checkered_metal_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_circles.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_floraltrim2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_floraltrim2_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_fullwall_moulding.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_marble.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_marble_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_moroc.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_sunflower.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_sunflower2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_sunflower2_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_sunflower_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_tiles.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_tiles_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_upholstered.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_woodwall.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/shop_wall_woodwall_2.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_mayorsoffice_whispy.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_peagawk.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_plain_DS.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_plain_RoG.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_rope.tex")),
	Asset("IMAGE", resolvefilepath("levels/interiors/wall_royal_high.tex")),
}

-- Add Interior wall and floor images
for k,v in pairs(interior_vfx_assets) do
	table.insert(Assets,v)
end

-- Interior room system is inspired by workshop-1349799880 
-- Mod Link: https://steamcommunity.com/sharedfiles/filedetails/?id=1349799880

-- Interior room has 2 Problems:
-- 1. Client side Interior room check
-- 2. Client side Physics
-- 2022-08-21: Above problems were all solved.

local old_IsAboveGroundAtPoint = Map.IsAboveGroundAtPoint
local old_IsVisualGroundAtPoint = Map.IsVisualGroundAtPoint

local function new_IsAboveGroundAtPoint(self,x,y,z,allow_water,...)
	local old_result = old_IsAboveGroundAtPoint(self,x,y,z,allow_water,...)
	if old_result then
		return old_result
	end

	local room = TheWorld.components.gale_interior_room_manager and TheWorld.components.gale_interior_room_manager:GetRoom(Vector3(x,y,z))

	if room then
		if allow_water == true then
			return true 
		else 
			return not room.components.gale_interior_room:IsInRoomWaterArea(Vector3(x, y, z))
		end
	end

	return false 
end

local function new_IsVisualGroundAtPoint(self,x,y,z,...)
	local old_result = old_IsVisualGroundAtPoint(self,x,y,z,...)
	if old_result then
		return old_result
	end

	local room = TheWorld.components.gale_interior_room_manager and TheWorld.components.gale_interior_room_manager:GetRoom(Vector3(x,y,z))
	
	return room and not room.components.gale_interior_room:IsInRoomWaterArea(Vector3(x, y, z))
end

Map.IsAboveGroundAtPoint = new_IsAboveGroundAtPoint
Map.IsVisualGroundAtPoint = new_IsVisualGroundAtPoint

AddPrefabPostInit("world",function(inst)
	-- if not TheWorld.ismastersim then
	-- 	return
	-- end

	inst:AddComponent("gale_interior_room_manager")
end)

-- for k,v in pairs(Ents) do if v.prefab == "wall_stone" then v.components.health:DoDelta(999) end end
-- for k,v in pairs(Ents) do if v.prefab == "wall_stone" then v.AnimState:SetScale(1,5,1) end end
-- for x = -850,850,20 do for z = -850,850,20 do ThePlayer.player_classified.MapExplorer:RevealArea(x, 0, z, true, true) end end
AddClassPostConstruct("cameras/followcamera", function(self)
	-- self.gale_interior_pitch = 35 
	self.gale_interior_heading = 0
	-- self.gale_interior_distance = 20
	self.gale_interior_distance = 21.5
	self.gale_interior_currentpos = Vector3(0,0,0)
	-- self.gale_interior_fov = 35
	self.gale_interior_camera_enabled = false
	self.gale_interior_targetoffset = Vector3(2, 1.5,0)

	-- TheCamera:SetGaleInterior(true)

	-- TODO:Try TheFocalPoint.components.focalpoint:StartFocusSource(c_sel(), "large", nil, 5, 12, 4) ?
	self.SetGaleInterior = function(self,enable,room,camera_target)
		room = room or TheWorld.components.gale_interior_room_manager:GetRoom(ThePlayer:GetPosition())
		camera_target = camera_target or room 

		if room and enable then
			-- self.pitch = self.gale_interior_pitch
			-- self.mindistpitch = self.gale_interior_pitch
			-- self.maxdistpitch = self.gale_interior_pitch + 0.01

			self.heading = self.gale_interior_heading
			self:SetMinDistance(self.gale_interior_distance)
			self:SetMaxDistance(self.gale_interior_distance+0.01)
			self.currentpos = self.gale_interior_currentpos
			-- self.fov = self.gale_interior_fov
			
			
			-- self:SetTarget(camera_target)
			TheFocalPoint.components.focalpoint:StartFocusSource(room, "gale_interior_room", camera_target, 15,20, 4) 
			self:SetOffset(self.gale_interior_targetoffset)
			self:SetDistance(self.gale_interior_distance)
			self:SetHeadingTarget(-90)
			self:Snap()
			ThePlayer:DoTaskInTime(0.1,function()
				self:SetDistance(self.gale_interior_distance)
				self:Snap()
			end)

			self.gale_interior_camera_enabled = enable 
			self.gale_interior_camera_target = camera_target
		else 
			-- self:SetTarget(ThePlayer)
			local to_remove = {}
			for source, sourcetbl in pairs(TheFocalPoint.components.focalpoint.targets) do
				for id, params in pairs(sourcetbl) do
					-- self:StopFocusSource(source, id)
					if id == "gale_interior_room" then
						table.insert(to_remove,{
							source,id
						})
					end
					
				end
			end
			for k,v in pairs(to_remove) do
				TheFocalPoint.components.focalpoint:StopFocusSource(v[1], v[2])
			end

			self:SetDefault()
			self:SetDistance((self.mindist + self.maxdist) / 2)
			self:Snap()
			self.gale_interior_camera_enabled = false  
			self.gale_interior_camera_target = nil 
		end
	end

	local old_SetHeadingTarget = self.SetHeadingTarget
	self.SetHeadingTarget = function(self,r,...)
		if self.gale_interior_camera_enabled then
			r = -90 
		end
		return old_SetHeadingTarget(self,r,...)
	end

	local old_ZoomIn = self.ZoomIn
	self.ZoomIn = function(self,...)
		if self.gale_interior_camera_enabled then
			self:SetDistance(self.gale_interior_distance)
			return 
		end

		return old_ZoomIn(self,...)
	end

	local old_ZoomOut = self.ZoomOut
	self.ZoomOut = function(self,...)
		if self.gale_interior_camera_enabled then
			self:SetDistance(self.gale_interior_distance)
			return 
		end

		return old_ZoomOut(self,...)
	end

	-- TheCamera:CheckGaleInteriorCamera()
	self.CheckGaleInteriorCamera = function(self,force)
		local room = TheWorld.components.gale_interior_room_manager:GetRoom(ThePlayer:GetPosition())
		if room then
			if force or not self.gale_interior_camera_enabled then
				local camera_target = room.components.gale_interior_room.camera_target
				self:SetGaleInterior(true,room,camera_target)
			else 
				local old_camera_target = self.gale_interior_camera_target
				local camera_target = room.components.gale_interior_room.camera_target

				if force or camera_target ~= old_camera_target then
					self:SetGaleInterior(true,room,camera_target)
				end
			end
		else
			if force or self.gale_interior_camera_enabled then
				self:SetGaleInterior(false)
			end
		end
	end


end)

-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_camera"],ThePlayer.userid)
AddClientModRPCHandler("gale_rpc","check_gale_interior_camera",function(force)
	if TheCamera then
		-- TheCamera:CheckGaleInteriorCamera(true)
		print(ThePlayer,"CheckGaleInteriorCamera",force)
		TheCamera:CheckGaleInteriorCamera(force)
	end
end)



-- Should be client side override ambient lighting
-- AddClientModRPCHandler("gale_rpc","check_gale_interior_ambientlighting",function()
-- 	if ThePlayer and ThePlayer.HUD then
-- 		ThePlayer:CheckInteriorAmbientLightAndOcean()
-- 	else 
-- 		print("check_gale_interior_ambientlighting FAILED !!!")
-- 	end
-- end)

AddClientModRPCHandler("gale_rpc","check_gale_interior_oceancolor",function()
	if ThePlayer and not TheNet:IsDedicated() then
		ThePlayer:CheckInteriorAmbientLightAndOcean()
	else 
		print("check_gale_interior_oceancolor FAILED !!!")
	end
end)

AddClientModRPCHandler("gale_rpc","period_check_gale_interior_environment",function(max_try)
	if ThePlayer and not TheNet:IsDedicated() then
		ThePlayer:PeriodCheckGaleInteriorEnvironment(max_try)
	else 
		print("check_gale_interior_environment FAILED !!!")
	end
end)



AddPlayerPostInit(function(inst)
	
	if not TheNet:IsDedicated() then
		-- overrideambientlighting functions 
		inst.InteriorAmbientLightAndOceanEnabled = false
		inst.EnableInteriorAmbientLightAndOcean = function(inst,enable)
			local oceancolor = TheWorld.components.oceancolor

			if enable then
				-- TheWorld:PushEvent("overrideambientlighting",Point(0 / 255, 0 / 255, 0 / 255))

				if oceancolor ~= nil then
					TheWorld:StopWallUpdatingComponent(oceancolor)
					oceancolor:Initialize(not enable and TheWorld.has_ocean)
				end 
			else 
				-- TheWorld:PushEvent("overrideambientlighting",nil)

				if oceancolor ~= nil then
					TheWorld:StartWallUpdatingComponent(oceancolor)
					oceancolor:Initialize(not enable and TheWorld.has_ocean)
				end 
			end
			
			

			inst.InteriorAmbientLightAndOceanEnabled = enable 
		end

		-- Check functions
		inst.CheckInteriorAmbientLightAndOcean = function(inst)
			local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
			if room and room:IsValid() then
				if not inst.InteriorAmbientLightAndOceanEnabled then
					inst:EnableInteriorAmbientLightAndOcean(true)
				end
			else 
				if inst.InteriorAmbientLightAndOceanEnabled then
					inst:EnableInteriorAmbientLightAndOcean(false)
				end
			end
		end

		-- Period Check room state,until room state change 
		-- This is because sometimes client room didn't load when player is already in the room
		inst.PeriodCheckGaleInteriorEnvironment = function(inst,max_try)
			local old_room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
			local old_gale_interior_camera_enabled = TheCamera.gale_interior_camera_enabled
			if inst.PeriodCheckGaleInteriorEnvironmentThread then
				KillThread(inst.PeriodCheckGaleInteriorEnvironmentThread)
			end
			-- print("old_gale_interior_camera_enabled:",old_gale_interior_camera_enabled,"old_room:",old_room)
			inst.PeriodCheckGaleInteriorEnvironmentThread = ThePlayer:StartThread(function()
				while (max_try == nil or max_try > 0) do
					TheCamera:CheckGaleInteriorCamera()
					inst:CheckInteriorAmbientLightAndOcean()

					local cur_gale_interior_camera_enabled = TheCamera.gale_interior_camera_enabled
					local cur_room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())

					-- print("cur_gale_interior_camera_enabled:",cur_gale_interior_camera_enabled,"cur_room:",cur_room)

					if cur_gale_interior_camera_enabled == old_gale_interior_camera_enabled and cur_room == old_room then
						Sleep(0)
					else 
						-- print("Success !")
						break
					end


					if max_try then
						max_try = max_try - 1
					end
				end
				inst.PeriodCheckGaleInteriorEnvironmentThread = nil 
			end)
		end

		-- Used for initialize ambient lighting
		inst:DoTaskInTime(0.1,function()
            if inst == ThePlayer then
                TheCamera:CheckGaleInteriorCamera()  -- camera or sth
                inst:CheckInteriorAmbientLightAndOcean()
            end

		end)
	end

	-- Method from <Tropical Experience | The Volcano Biome>
	-- Failed
	-- inst._interior_room_light_netval = net_bool(inst.GUID,"inst._interior_room_light_netval","interior_room_light_dirty")
	-- inst._interior_room_light_netval:set(false)
	-- inst:DoTaskInTime(0.1,function(inst)
	-- 	-- check that the entity is the playing player
	-- 	if inst.HUD ~= nil then
	-- 		inst:ListenForEvent("interior_room_light_dirty", function()
	-- 			-- if ThePlayer == inst then
	-- 			-- 	inst:EnableInteriorAmbientLightAndOcean(inst._interior_room_light_netval:value())
	-- 			-- end

	-- 			if inst._interior_room_light_netval:value() then
	-- 				TheWorld:PushEvent("overrideambientlighting",Point(0 / 255, 0 / 255, 0 / 255))
	-- 			else 
	-- 				TheWorld:PushEvent("overrideambientlighting",nil)
	-- 			end
	-- 		end)
	-- 		-- inst:DoTaskInTime(0.1,function()
	-- 		-- 	if ThePlayer == inst then
	-- 		-- 		inst:CheckInteriorAmbientLightAndOcean(inst._interior_room_light_netval:value())
	-- 		-- 	end 
	-- 		-- end)
	-- 	end
	-- end)

	if not TheWorld.ismastersim then
		return inst
	end

	-- inst:ListenForEvent("",function()
	-- 	SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_camera"],inst.userid)
	-- end)
end)

local PlayerCommonExtensions = require "prefabs/player_common_extensions"
local old_OnRespawnFromGhost = PlayerCommonExtensions.OnRespawnFromGhost
local old_OnRespawnFromPlayerCorpse = PlayerCommonExtensions.OnRespawnFromPlayerCorpse

local function OnceFn(inst)
	local pre_name = inst.sg and inst.sg.laststate and inst.sg.laststate.name
	local cur_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name

	if pre_name and cur_name and not cur_name:find("rebirth") then
		inst:DoTaskInTime(8,function()
			SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_camera"],inst.userid,true)
		end)
		print(inst,pre_name,cur_name,"Change to interior camera finish!")
		inst:RemoveEventCallback("newstate",OnceFn)
	end
end

PlayerCommonExtensions.OnRespawnFromGhost = function(inst,...)
	local ret = old_OnRespawnFromGhost(inst,...)
	inst:ListenForEvent("newstate",OnceFn)
	return ret
end
PlayerCommonExtensions.OnRespawnFromPlayerCorpse = function(inst,...)
	local ret = old_OnRespawnFromPlayerCorpse(inst,...)
	inst:ListenForEvent("newstate",OnceFn)
	return ret
end

local old_JUMPIN_fn = ACTIONS.JUMPIN.fn

ACTIONS.JUMPIN.fn = function(act,...)
	if act.target and act.target:HasTag("gale_interior_room_door")
		and act.target.components.teleporter ~= nil 
		and act.target.components.teleporter:IsActive() then 

		-- local target_teleporter = act.target.components.teleporter:GetTarget()

		act.target.components.teleporter:Activate(act.doer)

		return true 
	end 

	return old_JUMPIN_fn(act,...)
end

-- ACTIONS.JUMPIN.extra_arrive_dist = function(player,dest)
-- 	local target = dest.inst 
-- 	return target:HasTag("gale_interior_room_door") and 3 or 0
-- end

-- gale_weighdownable_item
-- USEITEM using an inventory item on an object in the world
-- args: inst, doer, target, actions, right
AddAction("GALE_PUT_ITEM_ON_PRESSURE_PLATE","GALE_PUT_ITEM_ON_PRESSURE_PLATE",function(act) 
	local item = act.invobject
	if item and not item:HasTag("soul") and item.components.inventoryitem then
		if act.doer.components.inventory then		
			local wholestack = act.options.wholestack
			if act.invobject and act.invobject.components.stackable and act.invobject.components.stackable.forcedropsingle then
				wholestack = false	
			end
			return act.doer.components.inventory:DropItem(act.invobject, wholestack, false, act.pos) 
		end
	end
end) 

ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE.strfn = ACTIONS.DROP.strfn

AddComponentAction("USEITEM", "gale_weighdownable_item", function(inst, doer, target, actions, right) 
    if inst:HasTag("gale_weighdownable_item") and target:HasTag("weighdownable") then 
        table.insert(actions, ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE)
    end 
end)

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE,"doshortaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE,"doshortaction"))


AddStategraphState("wilson",State{
	name = "gale_interior_room_door_use",
	tags = { "busy","nopredict" },

	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.components.health:SetInvincible(true)

		local bufferaction = inst:GetBufferedAction()
		local timeout = 1.3

		if bufferaction then
			local door = bufferaction.target 
			local door2 = door.components.teleporter:GetTarget()
			local dist = math.sqrt(inst:GetDistanceSqToInst(door))
			local speed = dist / 1

			inst.sg.statemem.door = door
			inst.sg.statemem.door2 = door2
			inst.sg.statemem.teleportarrivestate = "idle"
			inst.sg.statemem.speed = speed

			inst:ForceFacePoint(door:GetPosition():Get())
			inst.AnimState:PlayAnimation("run_pre")
			inst.AnimState:PushAnimation("run_loop", true)

			inst.Physics:SetMotorVel(speed,0,0)

			
		else 
			inst.sg:GoToState("idle")
		end

		inst.sg:SetTimeout(timeout)
	end,

	onupdate = function(inst)
		if inst.sg.statemem.door and not inst.sg.statemem.nomove  then
			local dist = math.sqrt(inst:GetDistanceSqToInst(inst.sg.statemem.door))

			if dist > 0.5 then
				inst:ForceFacePoint(inst.sg.statemem.door:GetPosition():Get())
				inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
			else 
				inst.Physics:Stop()
				inst.sg.statemem.nomove = true 
				inst.SoundEmitter:PlaySound("gale_sfx/other/p1_door_entry")
				inst:ScreenFade(false,1)
			end
			
		end
	end,

	ontimeout = function(inst)
		inst.Physics:Stop()
		inst:PerformBufferedAction()

		inst:Show()
		inst:SnapCamera()
        inst:ScreenFade(true, 1)

		inst.sg.statemem.vision_ok = true 

		local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
		-- print("gale_interior_room_door_use SendModRPCToClient,current room:",room)
		SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["period_check_gale_interior_environment"],inst.userid,1 / FRAMES)

		-- delay 1 FRAMES to make clientside spawn client room entities.
		-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_camera"],inst.userid)
		-- Sample: Server send rpc command to client side
		-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_ambientlighting"],inst.userid)
		-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["check_gale_interior_oceancolor"],inst.userid)
		-- if TheNet:GetIsServer() and TheNet:GetIsMasterSimulation() then
		-- 	local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
		-- 	inst._interior_room_light_netval:set(room ~= nil)
		-- end
		
		
	end,

	timeline =
	{

		-- TimeEvent(0.8, function(inst)
		-- 	inst:Hide()
		-- end),

		
	},

	onexit = function(inst)
		inst:Show()
		inst.components.health:SetInvincible(false)

		if not inst.sg.statemem.vision_ok then
			inst:SnapCamera()
        	inst:ScreenFade(true,0.5)
		end
		
	end,
})




AddStategraphPostInit("wilson", function(sg)
    local old_JUMPIN = sg.actionhandlers[ACTIONS.JUMPIN].deststate
    sg.actionhandlers[ACTIONS.JUMPIN].deststate = function(inst, action,...)
		if action.target and action.target:HasTag("gale_interior_room_door") then 
			return "gale_interior_room_door_use"
		end

		return old_JUMPIN(inst, action,...)
    end
end)
AddStategraphPostInit("wilson_client", function(sg)
    local old_JUMPIN = sg.actionhandlers[ACTIONS.JUMPIN].deststate
    sg.actionhandlers[ACTIONS.JUMPIN].deststate = function(inst, action,...)
		if action.target and action.target:HasTag("gale_interior_room_door") then
			inst:PerformPreviewBufferedAction()
			return 
		end
		return old_JUMPIN(inst, action,...)
    end
end)

AddComponentPostInit("birdspawner",function (self)
	local old_SpawnBird = self.SpawnBird
	self.SpawnBird = function(self,spawnpoint, ignorebait,...)
		local pos = Vector3(spawnpoint.x,0,spawnpoint.z)
		if TheWorld.components.gale_interior_room_manager:GetRoom(pos) then
			return 
		end
		return old_SpawnBird(self,spawnpoint, ignorebait,...)
	end
end)

AddComponentPostInit("inventoryitem",function (self)
	self.inst:AddComponent("gale_weighdownable_item")
end)

AddComponentPostInit("drownable",function(self)
	local old_IsOverWater = self.IsOverWater
	self.IsOverWater = function(self,...)
		local x, y, z = self.inst.Transform:GetWorldPosition()
		local old_result = old_IsOverWater(self,...)
		if old_result then
			return old_result
		end

		local room = TheWorld.components.gale_interior_room_manager:GetRoom(Vector3(x, y, z))

		return self.inst:GetCurrentPlatform() == nil and room and room.components.gale_interior_room:IsInRoomWaterArea(Vector3(x, y, z)) 
	end

	local old_ShouldDrown = self.ShouldDrown 
	self.ShouldDrown = function(self,...)		
		local x, y, z = self.inst.Transform:GetWorldPosition()
		return y <= 0.05 and old_ShouldDrown(self,...)
	end

	-- self.shore_pos_fn
	local old_OnFallInOcean = self.OnFallInOcean
	self.OnFallInOcean = function(self,shore_x, shore_y, shore_z,...)
		if shore_x == nil then
			local x, y, z = self.inst.Transform:GetWorldPosition()
			local room = TheWorld.components.gale_interior_room_manager:GetRoom(Vector3(x, y, z))
			if room then
				shore_x, shore_y, shore_z = room.components.gale_interior_room:GetShorePos(self.inst):Get()
			end
		end
		return old_OnFallInOcean(self,shore_x, shore_y, shore_z,...)
	end
end)


-- Used to Collides with interior room walls (see gale_polygon_physics.lua also)
-- require("standardcomponents")
-- local old_RemovePhysicsColliders = RemovePhysicsColliders
-- GLOBAL.RemovePhysicsColliders = function(inst,...)
-- 	local ret = old_RemovePhysicsColliders(inst,...)

-- 	local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
-- 	if inst.Physics:GetMass() > 0 and room then
--         inst.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
--     end
-- 	return ret
-- end

-- RemovePhysicsColliders
-- c_gale_room()
-- GLOBAL.c_gale_room = function()
-- 	local door1 = SpawnAt("gale_house_door",ConsoleWorldPosition())

-- 	local room_pos = TheWorld.components.gale_interior_room_manager:GenerateHousePos()
-- 	-- local room = SpawnAt("gale_test_room_more_width",room_pos)
-- 	local room = SpawnAt("gale_test_room",room_pos)

-- 	-- local door2 = SpawnAt("gale_house_door",room_pos,nil,Vector3(0,0,4.8))
-- 	local door2 = SpawnAt("gale_house_door",room_pos,nil,Vector3(0,0,4.4))
	
-- 	door1:LinkDoor(door2)
-- end

-- c_eco_dome(c_spawn("gale_house_door"))
-- c_eco_dome(c_select()) c_give("atrium_key")
GLOBAL.c_eco_dome = function(door1)
	c_removeallwithtags("eco_dome")

	if not door1 then
		print("Please enter door1")
		return  
	end
	local start_pos = Vector3(1200,0,1200)
	local main_room = SpawnAt("gale_eco_dome_room_main",start_pos)
	main_room:OnBuilt()

	main_room.components.gale_interior_room.layouts.door_up:LinkDoor(door1)

	local first_keycard_room = SpawnAt("gale_eco_dome_room_first_keycard",start_pos,nil,Vector3(-50,0,0))
	first_keycard_room:OnBuilt()

	first_keycard_room.components.gale_interior_room.layouts.door_right:LinkDoor(main_room.components.gale_interior_room.layouts.door_left)

	-- gale_eco_dome_room_corridor1

	local corridor1 = SpawnAt("gale_eco_dome_room_corridor1",start_pos,nil,Vector3(80,0,0))
	corridor1:OnBuilt()
	corridor1.components.gale_interior_room.layouts.door_left:LinkDoor(main_room.components.gale_interior_room.layouts.door_right)

	local corridor1_pos = corridor1:GetPosition()

	local checkpoint1 = SpawnAt("gale_eco_dome_room_checkpoint1",corridor1_pos,nil,Vector3(-20,0,50))
	checkpoint1:OnBuilt()
	checkpoint1.components.gale_interior_room.layouts.door_left:LinkDoor(corridor1.components.gale_interior_room.layouts.door_up1)

	local down_corridor1 = SpawnAt("gale_eco_dome_room_down_corridor1",corridor1_pos,nil,Vector3(0,0,-50))
	down_corridor1:OnBuilt()
	down_corridor1.components.gale_interior_room.layouts.door_up:LinkDoor(corridor1.components.gale_interior_room.layouts.door_up2)

	local path_to_moon = SpawnAt("gale_eco_dome_room_path_to_moon",corridor1_pos,nil,Vector3(20,0,50))
	path_to_moon:OnBuilt()
	path_to_moon.components.gale_interior_room.layouts.door_left:LinkDoor(corridor1.components.gale_interior_room.layouts.door_up3)

	local moon_treasure = SpawnAt("gale_eco_dome_room_moon_treasure",corridor1_pos,nil,Vector3(20,0,95))
	moon_treasure:OnBuilt()
	moon_treasure.components.gale_interior_room.layouts.door_down:LinkDoor(path_to_moon.components.gale_interior_room.layouts.door_up)

	local down_corridor1_pos = down_corridor1:GetPosition()

	local teach_pressure_plate = SpawnAt("gale_eco_dome_room_teach_pressure_plates",down_corridor1_pos,nil,Vector3(-40,0,0))
	teach_pressure_plate:OnBuilt()
	teach_pressure_plate.components.gale_interior_room.layouts.door_right:LinkDoor(down_corridor1.components.gale_interior_room.layouts.door_left)

	local inner_forest = SpawnAt("gale_eco_dome_room_inner_forest",down_corridor1_pos,nil,Vector3(-80,0,0))
	inner_forest:OnBuilt()
	inner_forest.components.gale_interior_room.layouts.door_right:LinkDoor(teach_pressure_plate.components.gale_interior_room.layouts.door_left)
	
	local wall_maze = SpawnAt("gale_eco_dome_room_wall_maze",down_corridor1_pos,nil,Vector3(40,0,0))
	wall_maze:OnBuilt()
	wall_maze.components.gale_interior_room.layouts.door_left:LinkDoor(down_corridor1.components.gale_interior_room.layouts.door_right)

	local lobby = SpawnAt("gale_eco_dome_room_lobby",corridor1_pos,nil,Vector3(60,0,0))
	lobby:OnBuilt()
	lobby.components.gale_interior_room.layouts.door_left:LinkDoor(corridor1.components.gale_interior_room.layouts.door_right)

	local lobby_pos = lobby:GetPosition()

	local multlayer_spear_trap = SpawnAt("gale_eco_dome_room_multlayer_spear_trap",lobby_pos,nil,Vector3(0,0,55))
	multlayer_spear_trap:OnBuilt()
	multlayer_spear_trap.components.gale_interior_room.layouts.door_down:LinkDoor(lobby.components.gale_interior_room.layouts.door_up1)

	local room_dragon_snare = SpawnAt("gale_eco_dome_room_dragon_snare",lobby_pos,nil,Vector3(40,0,0))
	room_dragon_snare:OnBuilt()
	room_dragon_snare.components.gale_interior_room.layouts.door_left:LinkDoor(lobby.components.gale_interior_room.layouts.door_right)

	local room_dragon_snare_pos = room_dragon_snare:GetPosition()

	local room_sanctuary = SpawnAt("gale_eco_dome_room_sanctuary",room_dragon_snare_pos,nil,Vector3(40,0,0))
	room_sanctuary:OnBuilt()
	room_sanctuary.components.gale_interior_room.layouts.door_left:LinkDoor(room_dragon_snare.components.gale_interior_room.layouts.door_right)

	local room_sanctuary_pos = room_sanctuary:GetPosition()

	-- local room_totally_ocean = SpawnAt("gale_eco_dome_room_totally_ocean",room_sanctuary_pos,nil,Vector3(40,0,0))
	-- room_totally_ocean:OnBuilt()
	-- room_totally_ocean.components.gale_interior_room.layouts.door_left:LinkDoor(room_sanctuary.components.gale_interior_room.layouts.door_right)

	local corridor2 = SpawnAt("gale_eco_dome_room_corridor2",down_corridor1_pos,nil,Vector3(0,0,-60))
	corridor2:OnBuilt()
	corridor2.components.gale_interior_room.layouts.door_up1:LinkDoor(down_corridor1.components.gale_interior_room.layouts.door_down)

	local room_trigger_two_walls = SpawnAt("gale_eco_dome_room_trigger_two_walls",corridor2,nil,Vector3(0,0,-45))
	room_trigger_two_walls:OnBuilt()
	room_trigger_two_walls.components.gale_interior_room.layouts.door_left:LinkDoor(corridor2.components.gale_interior_room.layouts.door_up2)
end

local code_text = [[
%s = {
	prefab = "%s",
	offset = Vector3%s,
},
]]
local code_text_simple = [[Vector3%s,]]

GLOBAL.c_print_inner = function(room,rad)
	if room == nil then
		room = TheWorld.components.gale_interior_room_manager:GetRoom(ThePlayer:GetPosition())
		if room == nil then
			return 
		end
	end
	local pos = room:GetPosition()
	local count_tab = {}
	local text = ""
	for k,v in pairs(TheSim:FindEntities(pos.x,pos.y,pos.z,rad or 100,nil,{"FX","INLIMBO","gale_interior_room_door","pillar","interior_room","CLASSIFIED"})) do
		if room.components.gale_interior_room:IsInside(v:GetPosition()) and v.prefab and #(v.prefab) > 0 then
			-- print(v,v:GetPosition() - pos)
			if count_tab[v.prefab] == nil then
				count_tab[v.prefab] = 1
			else 
				count_tab[v.prefab] = count_tab[v.prefab] + 1
			end


			text = text..string.format(code_text,
								v.prefab..count_tab[v.prefab],
								v.prefab,
								tostring(v:GetPosition() - pos)
							)
			
		end
	end
	print(text)

	-- local wall1_pos,wall2_pos,wall3_pos = "","",""
	-- for k,v in pairs(TheSim:FindEntities(pos.x,pos.y,pos.z,rad or 100,nil,{"FX","INLIMBO","gale_interior_room_door","pillar","interior_room","CLASSIFIED"})) do
	-- 	if room.components.gale_interior_room:IsInside(v:GetPosition()) and v.prefab and #(v.prefab) > 0 then

	-- 		if v.prefab == "gale_invincible_wall_hedge1" then
	-- 			wall1_pos = wall1_pos..string.format(code_text_simple,tostring(v:GetPosition() - pos))
	-- 		end
	-- 		if v.prefab == "gale_invincible_wall_hedge2" then
	-- 			wall2_pos = wall2_pos..string.format(code_text_simple,tostring(v:GetPosition() - pos))
	-- 		end
	-- 		if v.prefab == "gale_invincible_wall_hedge3" then
	-- 			wall3_pos = wall3_pos..string.format(code_text_simple,tostring(v:GetPosition() - pos))
	-- 		end
			
	-- 	end
	-- end

	-- print(wall1_pos)
	-- print(wall2_pos)
	-- print(wall3_pos)

end

GLOBAL.c_rewall = function(room,path)
	for k,v in pairs(room.walls) do
		v:Remove()
	end
	room.walls = GaleInterior.CreateWalls(room,room.game_size,8,path)
end

-- GLOBAL.c_test_fn = function()
-- 	local GaleInterior = require("util/gale_interior")
-- 	local floor_result,wall_result,entity_result = GaleInterior.LoadTiledLayout("layouts.eco_dome.test_tiled_room")

-- 	print("Floor data:")
-- 	for k,v in pairs(floor_result) do
-- 		print(v.offset,v.symbol)
-- 	end

-- 	print("\nWall data:")
-- 	for k,v in pairs(wall_result) do
-- 		print(k,v.offset,v.texture)
-- 	end

-- 	print("\nEntity data:")
-- 	for name,v in pairs(entity_result) do
-- 		print(name,v.prefab,v.offset,v.fn)
-- 	end
-- end

-- GLOBAL.c_remove



