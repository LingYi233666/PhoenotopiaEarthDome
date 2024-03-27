local Widget = require "widgets/widget" --Widget，所有widget的祖先类
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text" --Text类，文本处理
local Battery = require "widgets/gale_charge_battery"
local OverloadFire = require "widgets/gale_charge_fire"

local ChargeUI = Class(Widget, function(self,owner)
	Widget._ctor(self, "RookChargeUI")

	self.owner = owner
	self.battery_list = {}
	self.anim_queue = {}
	self.overload_fire = self:AddChild(OverloadFire())
	self.overload_fire:SetNum(0)



	self:ResetBatteryNum(4)
	self:SetOverloadNum(0)

	-- self.owner:DoPeriodicTask(2,function()
	-- 	self:SetChargeNum(math.random(1,4))
	-- end)

	self.inst:DoPeriodicTask(0,function()
		-- self.inst:SetPosition(owner:GetPosition() + TheCamera:GetDownVec() * 1)
	end)
end)
-- ThePlayer.HUD.controls.RookChargeUI.battery_list[1]:SpawnVFX()
-- ThePlayer.HUD.controls.RookChargeUI:SetChargeNum(3)
-- ThePlayer.HUD.controls.RookChargeUI:SetOverloadNum(15)
function ChargeUI:ResetBatteryNum(cnt)
	if self.anim_task then 
		self.anim_task:Cancel()
		self.anim_task = nil 
	end

	for k,v in pairs(self.battery_list) do 
		self:RemoveChild(v)
		v:Kill()
	end
	self.battery_list = {}

	for i=1,cnt do
		local battery = self:AddChild(Battery())
		battery.cell_num = i
		battery:SetPosition(i * 60,0,0)
		table.insert(self.battery_list,battery)
		if i==cnt then 
			self.overload_fire:SetPosition((i+1) * 60,0,0)
		end
	end

	self:SetChargeNum(0,true)
end

function ChargeUI:SetChargeNum(cnt,instant)
	-- print("[RookChargeUI]:SetChargeNum to "..tostring(cnt))
	local do_charge_bty = {}
	local do_uncharge_bty = {}

	for i=1,#self.battery_list do
		if i <= cnt then 
			if not self.battery_list[i].charged then 
				table.insert(do_charge_bty,i)
			end 
		else
			if self.battery_list[i].charged then 
				table.insert(do_uncharge_bty,i)
			end 
		end
	end

	local old_has_task = self.anim_task

	for i=#do_charge_bty,1,-1 do 
		if not instant then 
			self:InsertAnim(do_charge_bty[i],"charge")
		else
			self.battery_list[do_charge_bty[i]]:Charge()
		end
	end

	for i=1,#do_uncharge_bty do 
		if not instant then 
			self:InsertAnim(do_uncharge_bty[i],"uncharge")
		else
			self.battery_list[do_uncharge_bty[i]]:Uncharge()
		end
	end

	if not old_has_task then 
		self:AnimTaskFn()
	end 
end

function ChargeUI:SetOverloadNum(cnt)
	self.overload_fire:SetNum(cnt)
end

function ChargeUI:InsertAnim(battery_num,c_task)
	table.insert(self.anim_queue,1,{battery_num,c_task})
	if not self.anim_task then 
		self.anim_task = self.owner:DoPeriodicTask(0.15,function()
			self:AnimTaskFn()
		end)
	end
end

function ChargeUI:AnimTaskFn()
	if #self.anim_queue > 0 then 
		local battery_num,c_task = self.anim_queue[1][1],self.anim_queue[1][2]
		table.remove(self.anim_queue,1)
		if c_task == "charge" then 
			self.battery_list[battery_num]:Charge()
			if battery_num >= #self.battery_list then 
				TheFocalPoint.SoundEmitter:PlaySound("rook_charge_sound/sfx/GL_Overcharge_fill")
			end
		elseif c_task == "uncharge" then 
			self.battery_list[battery_num]:Uncharge()
		end
	else
		if self.anim_task then 
			self.anim_task:Cancel()
			self.anim_task = nil 
		end
	end 
end

return ChargeUI