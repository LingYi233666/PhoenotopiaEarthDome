local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleBuffSlot = require "widgets/galebuffslot"

local STZRT_X = 0
local SLOTDIST = 105
local UPDATE_PERIOD = 0.2

local GaleBuffBar = Class(Widget, function(self, owner)
    Widget._ctor(self,"GaleBuffBar")
	self.owner = owner
	self.buffslots = {}
	self.anim_queue = {}
	self.time = 0
	self.AnimTask = nil 
	self.tip_type = "DOWN"
	self.slot_scale = nil 
	self.slot_dist = SLOTDIST
	
end)

function GaleBuffBar:EnableAnimTask(enable)
	if self.AnimTask then 
		self.AnimTask:Cancel()
		self.AnimTask = nil 
	end 
	if enable then 
		self.AnimTask = self.inst:DoPeriodicTask(UPDATE_PERIOD,function()
			self:PopAnim()
		end)
	end 
end

function GaleBuffBar:PushAnim(fn)
	table.insert(self.anim_queue,fn)
	if not self.AnimTask then 
		self:EnableAnimTask(true)
	end
end

function GaleBuffBar:PopAnim()
	if #self.anim_queue > 0 then 
		self.anim_queue[1]()
		table.remove(self.anim_queue,1)
	else
		self:EnableAnimTask(false)
	end
end

function GaleBuffBar:HasBuff(name)
	return self.buffslots[name] ~= nil 
end

function GaleBuffBar:AddBuff(name,data)
	data.tip_type = self.tip_type
	if not self.buffslots[name] then 
		data.prefab_name = name
		data.slot_scale = self.slot_scale
		local child = self:AddChild(GaleBuffSlot(data))
		child.add_time = GetTime()
		self.buffslots[name] = child
		-- ent是buff的实体
		-- if data.ent then 
		-- 	data.ent:ListenForEvent("onremove",function()
		-- 		self:RemoveBuff(name)
		-- 	end)
		-- end
		
		self:PushAnim(function()
			child:SlideIn()
			self:Line()
		end)
		
	else
		print("[GaleBuffBar-AddBuff]:AddBuff failed,"..tostring(name).." already exists")
	end
end

function GaleBuffBar:UpdateBuff(name,data)
	if self.buffslots[name] then 
		if data.stacks then 
			self.buffslots[name]:SetStacks(data.stacks)
		end 
		if data.image_name then 
			self.buffslots[name]:SetImage(data.image_name)
		end 
		if data.buff_name then 
			self.buffslots[name]:SetBuffName(data.buff_name)
		end
		if data.addition_tip then 
			self.buffslots[name]:SetAdditionTip(data.addition_tip)
		end
		if data.dtype then 
			self.buffslots[name]:SetDtype(data.dtype)
		end
	else
		self:AddBuff(name,data)
		-- print("[GaleBuffBar-UpdateBuff]:Update failed,no name "..tostring(name))
	end
end

function GaleBuffBar:RemoveBuff(name,delay)	
	if self.buffslots[name] then 
		if delay == nil then 
			delay = 0.33
		end 
		local tar = self.buffslots[name]
		self.buffslots[name] = nil 
		self:PushAnim(function()
			tar:SlideOut(delay)
			self:Line()
		end)
	end 
end

function GaleBuffBar:ForceSetAllBuff(datas)
	for name,data in pairs(datas) do 
		self:UpdateBuff(name,data)
	end

	local to_be_removed = {}
	for c_name,data in pairs(self.buffslots) do 
		if not datas[c_name] then 
			table.insert(to_be_removed,c_name)
		end
	end

	for k,v in pairs(to_be_removed) do 
		self:RemoveBuff(v)
	end 

	local names = {}
	for k,v in pairs(self.buffslots) do 
		table.insert(names,k)
	end
	-- print("GaleBuffBar:ForceSetAllBuff")
	-- dumptable(names)
end

function GaleBuffBar:ListByTime()
	local list = {}
	for name,v in pairs(self.buffslots) do 
		table.insert(list,v)
	end
	table.sort(list,function(a,b)
		return a.add_time > b.add_time
	end)

	return list
end

function GaleBuffBar:Line(instant)
	-- local index = 1 
	for index,v in pairs(self:ListByTime()) do 
		local x,y,z = STZRT_X + self.slot_dist * (index - 1),0,0
		v:CancelMoveTo()
		if instant then 
			v:SetPosition(x,y,z)
		else
			local old_pos = v:GetPosition()
			v:MoveTo(old_pos,Vector3(x,y,z),0.5)
		end 
		-- index = index + 1
	end
end 

-- function GaleBuffBar:OnUpdate(dt)
-- 	self.time = self.time - dt 
-- 	if self.time <= 0 then 
-- 		self.time = UPDATE_PERIOD
-- 		-- Do Anim here
-- 	end
-- end



return GaleBuffBar
