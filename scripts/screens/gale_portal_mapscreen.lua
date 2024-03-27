local Screen = require "widgets/screen"
local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local MapControls = require "widgets/mapcontrols"
local HudCompass = require "widgets/hudcompass"
local Image = require "widgets/image"
local GalePortalMapWidget = require("widgets/gale_portal_map_widget")

local easing = require("easing")


local GalePortalMapScreen = Class(Screen, function(self, owner,world_pt_list,start_id)
    Screen._ctor(self, "GalePortalMapScreen")

    self.owner = owner
    
    self.minimap = self:AddChild(GalePortalMapWidget(self.owner))
    -- self.minimap.img:ScaleToSize()

    self.middle_rect = self:AddChild(Image("images/frontend_redux.xml","listitem_thick_hover.tex"))
    self.middle_rect:SetVAnchor(ANCHOR_MIDDLE)
    self.middle_rect:SetHAnchor(ANCHOR_MIDDLE)
    -- self.middle_rect:SetSize(100,100)

    self.easing_func = easing.outQuad


    self:SetWorldPtList(world_pt_list,start_id)

    SetAutopaused(true)
end)

function GalePortalMapScreen:OnBecomeInactive()
    GalePortalMapScreen._base.OnBecomeInactive(self)

    if TheWorld.minimap.MiniMap:IsVisible() then
        TheWorld.minimap.MiniMap:ToggleVisibility()
    end
end

function GalePortalMapScreen:OnBecomeActive()
    GalePortalMapScreen._base.OnBecomeActive(self)

    if not TheWorld.minimap.MiniMap:IsVisible() then
        TheWorld.minimap.MiniMap:ToggleVisibility()
    end
    self.minimap:UpdateTexture()
end

function GalePortalMapScreen:OnDestroy()
    SetAutopaused(false)

	GalePortalMapScreen._base.OnDestroy(self)
end


--[[ EXAMPLE of map coordinate functions
function GalePortalMapScreen:NearestEntToCursor()
    local closestent = nil
    local closest = nil
    for ent,_ in pairs(someentities) do
        local ex,ey,ez = ent.Transform:GetWorldPosition()
        local entpos = self:MapPosToWidgetPos( Vector3(self.minimap:WorldPosToMapPos(ex,ez,0)) )
        local mousepos = self:ScreenPosToWidgetPos( TheInput:GetScreenPosition() )
        local delta = mousepos - entpos

        local length = delta:Length()
        if length < 30 then
            if closest == nil or length < closest then
                closestent = ent
                closest = length
            end
        end
    end

    if closestent ~= nil then
        local ex,ey,ez = closestent.Transform:GetWorldPosition()
        local entpos = self:MapPosToWidgetPos( Vector3(self.minimap:WorldPosToMapPos(ex,ez,0)) )

        self.hovertext:SetPosition(entpos:Get())
        self.hovertext:Show()
    else
        self.hovertext:Hide()
    end
end
]]

function GalePortalMapScreen:GenSort()
    self.poses_sorted_by_x = {}
    self.poses_sorted_by_z = {}

    for k,v in pairs(self.world_pt_list) do
        table.insert(self.poses_sorted_by_x,{k,v})
        table.insert(self.poses_sorted_by_z,{k,v})
    end

    table.sort(self.poses_sorted_by_x,function(ta,tb)
        return ta[2].pos.x < tb[2].pos.x
    end)

    table.sort(self.poses_sorted_by_z,function(ta,tb)
        return ta[2].pos.z < tb[2].pos.z
    end)
end

function GalePortalMapScreen:SetWorldPtList(pt_list,start_id)
    self.world_pt_list = pt_list or {}
    self.start_id = start_id
    self.target_world_pt_id = start_id or 1
    self.camera_world_pt = #self.world_pt_list > 0 and self.world_pt_list[self.target_world_pt_id].pos or self.owner:GetPosition()

    self:GenSort()

    self:FocusMapOnWorldPosition(self.camera_world_pt)
end

function GalePortalMapScreen:MapPosToWidgetPos(mappos)
    return Vector3(
        mappos.x * RESOLUTION_X/2,
        mappos.y * RESOLUTION_Y/2,
        0
    )
end

function GalePortalMapScreen:ScreenPosToWidgetPos(screenpos)
    local w, h = TheSim:GetScreenSize()
    return Vector3(
        screenpos.x / w * RESOLUTION_X - RESOLUTION_X/2,
        screenpos.y / h * RESOLUTION_Y - RESOLUTION_Y/2,
        0
    )
end

function GalePortalMapScreen:WidgetPosToMapPos(widgetpos)
    return Vector3(
        widgetpos.x / (RESOLUTION_X/2),
        widgetpos.y / (RESOLUTION_Y/2),
        0
    )
end

function GalePortalMapScreen:SearchNextPos(origin_k,direction)
    local suit_k = nil 

    -- print("origin_k:",origin_k)

    if direction == CONTROL_MOVE_RIGHT then
        for tk,tp in pairs(self.poses_sorted_by_x) do
            if tp[1] == origin_k then
                if tk + 1 <= #self.poses_sorted_by_x then
                    suit_k = self.poses_sorted_by_x[tk + 1][1]
                else 
                    suit_k = self.poses_sorted_by_x[1][1]
                end

                break
            end
        end
    elseif direction == CONTROL_MOVE_LEFT then
        for tk,tp in pairs(self.poses_sorted_by_x) do
            if tp[1] == origin_k then
                if tk - 1 >= 1 then
                    suit_k = self.poses_sorted_by_x[tk - 1][1]
                else 
                    suit_k = self.poses_sorted_by_x[#self.poses_sorted_by_x][1]
                end

                break
            end
        end

    elseif direction == CONTROL_MOVE_UP then
        for tk,tp in pairs(self.poses_sorted_by_z) do
            if tp[1] == origin_k then
                if tk + 1 <= #self.poses_sorted_by_z then
                    suit_k = self.poses_sorted_by_z[tk + 1][1]
                else 
                    suit_k = self.poses_sorted_by_z[1][1]
                end

                break
            end
        end
    elseif direction == CONTROL_MOVE_DOWN then
        for tk,tp in pairs(self.poses_sorted_by_z) do
            if tp[1] == origin_k then
                if tk - 1 >= 1 then
                    suit_k = self.poses_sorted_by_z[tk - 1][1]
                else 
                    suit_k = self.poses_sorted_by_z[#self.poses_sorted_by_z][1]
                end
                break
            end
        end
    end

    -- print("Find next suit_k:",suit_k)

    return suit_k
end

function GalePortalMapScreen:ToTeleport()
    SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_portal_teleport"],
        self.world_pt_list[self.start_id].guid,
        self.world_pt_list[self.target_world_pt_id].guid)
        
    TheFrontEnd:PopScreen(self)
end

function GalePortalMapScreen:OnRawKey(key, down)
    if GalePortalMapScreen._base.OnRawKey(self, key, down) then return true end

    if down and key == KEY_ENTER then
        self:ToTeleport()
        return true 
    end
end

function GalePortalMapScreen:OnControl(control, down)
    if GalePortalMapScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:PopScreen(self)
        return true
    end

    if not (down and self.shown) then
        return false
    end

    if (control == CONTROL_MOVE_RIGHT 
        or control == CONTROL_MOVE_LEFT
        or control == CONTROL_MOVE_UP
        or control == CONTROL_MOVE_DOWN) then

        if #self.world_pt_list <= 1 then
            return true
        else 
            local target_k = self:SearchNextPos(self.target_world_pt_id,control)
            self.target_world_pt_id = target_k

            
            
            self:CameraMoveTo(self.camera_world_pt,self.world_pt_list[self.target_world_pt_id].pos,1)
        end
    end

    -- if control == CONTROL_ROTATE_LEFT and ThePlayer and ThePlayer.components.playercontroller then
    --     ThePlayer.components.playercontroller:RotLeft()
    --     self:GenSort()
    -- elseif control == CONTROL_ROTATE_RIGHT and ThePlayer and ThePlayer.components.playercontroller then
    --     ThePlayer.components.playercontroller:RotRight()
    --     self:GenSort()
    -- else

    if control == CONTROL_ATTACK or control == CONTROL_ACTION then
        self:ToTeleport()
        return true 
    end
        
    if control == CONTROL_MAP_ZOOM_IN then
        self.minimap:OnZoomIn()
    elseif control == CONTROL_MAP_ZOOM_OUT then
        self.minimap:OnZoomOut()
    else
        return false
    end
    return true
end

function GalePortalMapScreen:CameraMoveTo(start_world_pos,end_world_pos,duration)
    

    -- print("CameraMoveTo:",start_world_pos,end_world_pos,duration)
    
    -- self:StopUpdating()

    self:FocusMapOnWorldPosition(start_world_pos)

    self.pos_t = 0
    self.move_duration = duration or 1
    self.start_world_pos = start_world_pos
    self.end_world_pos = end_world_pos
    self:StartUpdating()
end

function GalePortalMapScreen:OnUpdate(dt)
    if self.pos_t == nil then
        self:StopUpdating()
        return 
    end

    self.pos_t = self.pos_t + dt

    if self.pos_t < self.move_duration then
        local valx = self.easing_func(self.pos_t, 
            self.start_world_pos.x, self.end_world_pos.x - self.start_world_pos.x, self.move_duration)

        local valz = self.easing_func(self.pos_t, 
            self.start_world_pos.z, self.end_world_pos.z - self.start_world_pos.z, self.move_duration)

        self:FocusMapOnWorldPosition(Vector3(valx, 0, valz))

    else
        local valx = self.end_world_pos.x
        local valz = self.end_world_pos.z
        self:FocusMapOnWorldPosition(Vector3(valx, 0, valz))

        self.pos_t = nil 
        self.move_duration = nil 
        self.start_world_pos = nil
        self.end_world_pos = nil

        self:StopUpdating()
    end

    
end


function GalePortalMapScreen:FocusMapOnWorldPosition(world_pos)
	-- while self.minimap.minimap:GetZoom() > 1 do self.minimap:OnZoomIn() end

	-- local cur_x, _, cur_z = self.camera_world_pt:Get()
    local cur_x, _, cur_z = self.owner.Transform:GetWorldPosition()
	local dx, dy = world_pos.x - cur_x, world_pos.z - cur_z

	local angle_correction = (PI / 4) * (10 - (math.fmod(TheCamera:GetHeadingTarget() / 360, 1) * 8))
	local theta = math.atan2(dy, dx)
	local mag = math.sqrt(dx * dx + dy * dy) / self.minimap.minimap:GetZoom()

    self.minimap:ResetOffset()
	self.minimap:Offset(math.cos(theta + angle_correction) * mag, math.sin(theta + angle_correction) * mag)

    self.camera_world_pt = world_pos
end


return GalePortalMapScreen
