local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require"widgets/image"
local UIAnim = require "widgets/uianim"

local easing = require("easing")


local GaleQteCookArrow = Class(Widget, function(self)
    Widget._ctor(self, "GaleQteCookArrow")

    self.arrow_type = "UP"
    self.cancel_input = false
    self.sanityarrow = self:AddChild(Image("images/ui/qte_cook/arrow.xml","arrow.tex"))

	-- Custom "MoveTo"
	self.pos_t = nil 
	self.pos_whendone = nil 
	self.pos_start = nil
    self.pos_dest = nil
    self.pos_duration = nil
	self.easing_func = easing.outQuad

    self._end_rotate_fn = function()
    	self.cancel_input = false
    	self.sanityarrow:SetTint(1,1,1,1)
    end
end)

function GaleQteCookArrow:RotateArrow(set_type)
	self.sanityarrow:CancelRotateTo(self._end_rotate_fn)
	local cur_roa = self.sanityarrow.inst.UITransform:GetRotation()
	local circle = 2 * (math.random() <= 0.5 and -1 or 1)
	self.cancel_input = true
	if set_type == "UP" then 
		self.sanityarrow:RotateTo(cur_roa,0 + circle * 360,0.33,self._end_rotate_fn)
	elseif set_type == "DOWN" then 
		self.sanityarrow:RotateTo(cur_roa,180 + circle * 360,0.33,self._end_rotate_fn)
	elseif set_type == "LEFT" then 
		self.sanityarrow:RotateTo(cur_roa,270 + circle * 360,0.33,self._end_rotate_fn)
	elseif set_type == "RIGHT" then 
		self.sanityarrow:RotateTo(cur_roa,90 + circle * 360,0.33,self._end_rotate_fn)
	end
	self.arrow_type = set_type
end

function GaleQteCookArrow:RoatteRandom()
	local set_type = {
		"UP","DOWN","LEFT","RIGHT"
	}
	self.sanityarrow:SetTint(0,1,0,1)
	self:RotateArrow(set_type[math.random(1,#set_type)])
end

function GaleQteCookArrow:RedFlash(end_fn)
	self.red_flashing = true 
	self.cancel_input = true
	self.sanityarrow:SetTint(1,0,0,1)
	if self.red_task then 
		self.red_task:Cancel()
	end 
	self.red_task = self.inst:DoTaskInTime(0.33,function()
		self.sanityarrow:SetTint(1,1,1,1)
		self.red_task:Cancel()
		self.red_task = nil 
		self.red_flashing = false 
		self.cancel_input = false
		if end_fn then
			end_fn()
		end 
	end)
end

function GaleQteCookArrow:MoveTo(start, dest, duration, whendone)
	self.pos_start = start
    self.pos_dest = dest
    self.pos_duration = duration
    self.pos_t = 0

    if self.pos_whendone then
		self.pos_whendone()
    end
    self.pos_whendone = whendone


    self:StartUpdating()
    self:SetPosition(start)
end

function GaleQteCookArrow:CancelMoveTo(run_complete_fn)
	self.pos_t = nil
	if run_complete_fn ~= nil and self.pos_whendone then
		self.pos_whendone()
    end
	self.pos_whendone = nil
end

function GaleQteCookArrow:OnUpdate(dt)
	if self.red_flashing then
		return 
	end
    local done = false

    if self.pos_t then

        self.pos_t = self.pos_t + dt
        if self.pos_t < self.pos_duration then
            local valx = self.easing_func( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
            local valy = self.easing_func( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
            local valz = self.easing_func( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
            self:SetPosition(valx, valy, valz)
        else
            local valx = self.pos_dest.x
            local valy = self.pos_dest.y
            local valz = self.pos_dest.z
            self:SetPosition(valx, valy, valz)

            self.pos_t = nil
            if self.pos_whendone then
                local pos_whendonefn = self.pos_whendone
				self.pos_whendone = nil -- reset this here so that self.pos_whendone can call MoveTo
                pos_whendonefn()
            end
        end
    end


    if not self.pos_t then
        self:StopUpdating()
    end
end


return GaleQteCookArrow