local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"
local GaleBuffBar = require "widgets/galebuffbar"

local GaleConditionUtil = require "util/gale_conditions"

local BAR_SIZE = Vector3(600,38,0)
local PROGRESS_SIZE = BAR_SIZE + Vector3(10,5,0)
local GaleHealthBar = Class(GaleTooltip, function(self,owner,target)
	GaleTooltip._ctor(self,"GaleHealthBar")

	self.owner = owner
	self.target = target
	self.target_percent = 1.0
	self.percent = 1.0

	

	self.bg:SetTint(91/255,55/255,16/255,1)
	self.bg:SetSize(BAR_SIZE:Get())

	self.progress = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
	self.progress:SetTint(144/255,3/255,3/255,1)
	self.progress:SetSize(PROGRESS_SIZE:Get())
	self.progress:SetVRegPoint(ANCHOR_MIDDLE)
	self.progress:SetHRegPoint(ANCHOR_LEFT)

	self.name_text = self:AddChild(Text(NUMBERFONT, 50,""))
	-- self.name_text:SetHAlign(ANCHOR_RIGHT)
	self.name_text:SetColour(244/255,138/255,67/255,1)
	self.name_text:SetPosition(0,1)

	for k,v in pairs(self.bars) do 
		v:MoveToFront()
	end

	for k,v in pairs(self.corners) do 
		v:MoveToFront()
	end 

	self.buffbar = self:AddChild(GaleBuffBar(owner))
	self.buffbar:SetPosition(-BAR_SIZE.x / 2 + 15,BAR_SIZE.y + 55)
	self.buffbar.tip_type = "UP"
	self.buffbar.slot_scale = 0.45
	self.buffbar.slot_dist = 95

	self:SetTarget(target)
	self:MakeLayout()
end)

function GaleHealthBar:MakeLayout()
	GaleHealthBar._base.MakeLayout(self)

	local bg_w,bg_h = self.bg:GetSize()
	self.progress:SetPosition(-bg_w/2,0)

	-- local name_w,name_h = self.name_text:GetRegionSize()
	-- self.name_text:SetPosition(-bg_w/2 - name_w / 2 - 28 ,0)
end

function GaleHealthBar:SetPercent(percent,force)
	percent = math.clamp(percent,0,1) 
	local old_percent = self.target_percent
	-- if percent < self.target_percent then 

	-- end 

	self.target_percent = percent
	if force then 
		self.percent = self.target_percent
	end
	if not self.DoPercentTask then 
		self.DoPercentTask = self.inst:DoPeriodicTask(0,function()
			if math.abs(self.percent - self.target_percent) <= 0.01 then
				self.percent = self.target_percent
				self.DoPercentTask:Cancel()
				self.DoPercentTask = nil 
			else
				local delta = self.target_percent - self.percent
				delta = math.clamp(delta * 0.5,-0.05,0.05)
				self.percent = math.clamp(self.percent + delta,0,1)
			end

			self.progress:SetSize(PROGRESS_SIZE.x * self.percent,PROGRESS_SIZE.y) 
		end)
	end
end

function GaleHealthBar:SetTarget(target)
	local old_target = self.target
	self.target = target
	if old_target ~= target then 
		self.buffbar:ForceSetAllBuff({})
	end
	if self.target ~= nil and self.target:IsValid() then 
		self.last_target_set_time = GetTime()
		-- self.name_text:SetString(target.name)
		self.name_text:SetString(target:GetDisplayName())
		self:MakeLayout()
		if old_target == nil then 
			self:Appear()
			self:StartUpdating()
		end 
		if old_target ~= target then 
			self.percent = 1
			self:SetPercent(target.replica.gale_healthbar:GetPercent())
		end
	else
		self.target = nil 
		self:StopUpdating()
		self.name_text:SetString("")
		self.buffbar:ForceSetAllBuff({})
		self:Disappear()
	end
end

function GaleHealthBar:Appear()
	self:CancelMoveTo()
	self:SetPosition(0,-75)
	self:Show()
	-- TODO：背包布局 融合 y值矫正
	if Profile:GetIntegratedBackpack() then 
		self:MoveTo(Vector3(0,-75),Vector3(0,175),0.5)
	else 
		self:MoveTo(Vector3(0,-75),Vector3(0,125),0.5)
	end
end

function GaleHealthBar:Disappear()
	self.buffbar:ForceSetAllBuff({})
	self:CancelMoveTo()
	self:MoveTo(self:GetPosition(),Vector3(0,-75),0.5,function()
		self:Hide()
	end)
end

function GaleHealthBar:OnUpdate()
	if self.target ~= nil and self.target:IsValid() and (GetTime() - self.last_target_set_time <= 10) then 
		self:SetPercent(self.target.replica.gale_healthbar:GetPercent())
		if self.last_update_buff_time == nil or GetTime() - self.last_update_buff_time >= 0.5 then 
			self.buffbar:ForceSetAllBuff(self.target.replica.gale_healthbar:GetDebuffData())
			-- print("GaleHealthBar:UpdateBuff")
			-- dumptable(self.target.replica.gale_healthbar:GetDebuffData())
			-- for k,v in pairs(self.target.replica.gale_healthbar:GetDebuffData()) do 
				-- print(k,v)
			-- end
			self.last_update_buff_time = GetTime()
		end 
	else
		self:SetTarget(nil)
	end 
end

return GaleHealthBar