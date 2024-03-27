local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local GalePopupFlute = Class(Widget, function(self, owner, pos,max_time,image_name)
    Widget._ctor(self, "GalePopupFlute")
    self.owner = owner
    self.pos = pos
    self.max_time = max_time
    self.image = self:AddChild(Image("images/ui/flute/"..image_name..".xml", image_name..".tex"))

    self.image_state = "none"
    self.cur_time = 0
    self:InitSpeed()

    self:SetScale(0.25,0.25)

    self:SetClickable(false)
    -- self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:StartUpdating()
    self:OnUpdate(0)
end)

function GalePopupFlute:InitSpeed()
    local camera_dist = TheCamera.distance
    local camera_dist_min,camera_dist_mid,camera_dist_max = 15,30,55

    local delta = 1 
    if camera_dist < camera_dist_mid then 
        delta = Remap(camera_dist,camera_dist_min,camera_dist_mid,1.6,1)
    elseif  camera_dist >=camera_dist_mid then
        delta = Remap(camera_dist,camera_dist_mid,camera_dist_max,1,0.75)
    end 

    self.speed = (Vector3(0,190,0) + Vector3(1,0,0) * GetRandomMinMax(-75,75)) * delta
    self.anti_force = 150
end

function GalePopupFlute:OnUpdate(dt)
    local camera_dist = TheCamera.distance
    local camera_dist_min,camera_dist_mid,camera_dist_max = 15,30,55

    local delta = 1 
    if camera_dist < camera_dist_mid then 
        delta = Remap(camera_dist,camera_dist_min,camera_dist_mid,2,1)
    elseif  camera_dist >=camera_dist_mid then
        delta = Remap(camera_dist,camera_dist_mid,camera_dist_max,1,0.25)
    end 
    -- delta = 1
    self.image:SetScale(0.45 * delta,0.45 * delta)
    if self.image_state == "none" then 
        local time = 0.33
        self:ScaleTo(0.15,1,time,function()
            self.image_state = "normal"
        end)
        self.image:TintTo({r = 1,g = 1,b = 1,a = 0},{r = 1,g = 1,b = 1,a = 1},time)
        self.image_state = "fadein"
    elseif self.image_state == "normal" then
        if self.cur_time >= self.max_time * 0.75 then 
            self.image:TintTo({r = 1,g = 1,b = 1,a = 1},{r = 1,g = 1,b = 1,a = 0},self.max_time * 0.25)
            self.image_state = "fadeout"
        end
    elseif self.image_state == "fadeout" then

    end 

    self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))

    local image_cur_pos = self.image:GetPosition()
    image_cur_pos = image_cur_pos + self.speed * dt 
    self.image:SetPosition(image_cur_pos:Get())

    if self.speed:Length() >= self.anti_force * dt then 
        self.speed = self.speed - self.speed:GetNormalized() * dt * self.anti_force
    else
        self.speed = Vector3(0,0,0)
    end
    -- print("self.speed =",self.speed,"Length:",self.speed:Length())

    self.cur_time = self.cur_time + dt 
    if self.cur_time >= self.max_time then 
        self:Kill()
    end
end

return GalePopupFlute