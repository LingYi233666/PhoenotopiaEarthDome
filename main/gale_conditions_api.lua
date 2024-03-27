local GaleConditionUtil = require "util/gale_conditions"

local condition_Assets = {
	Asset("ATLAS", "images/ui/bufftips/bar.xml"),
	Asset("IMAGE", "images/ui/bufftips/bar.tex"),

	Asset("ATLAS", "images/ui/bufftips/bg.xml"),
	Asset("IMAGE", "images/ui/bufftips/bg.tex"),

	Asset("ATLAS", "images/ui/bufftips/bg_white.xml"),
	Asset("IMAGE", "images/ui/bufftips/bg_white.tex"),

	Asset("ATLAS", "images/ui/bufftips/circle.xml"),
	Asset("IMAGE", "images/ui/bufftips/circle.tex"),

	Asset("ATLAS", "images/ui/bufftips/corner.xml"),
	Asset("IMAGE", "images/ui/bufftips/corner.tex"),

	Asset("ATLAS", "images/ui/bufftips/dtype_bg.xml"),
	Asset("IMAGE", "images/ui/bufftips/dtype_bg.tex"),

	Asset("ATLAS", "images/ui/bufftips/dtype_bg_long.xml"),
	Asset("IMAGE", "images/ui/bufftips/dtype_bg_long.tex"),
}

for k, v in pairs(condition_Assets) do
	table.insert(Assets, v)
end

local GaleBuffBar = require("widgets/galebuffbar")
AddClassPostConstruct("widgets/controls", function(self)
	self.GaleBuffBar = self:AddChild(GaleBuffBar(self.owner))
	self.GaleBuffBar:SetHAnchor(1) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.GaleBuffBar:SetVAnchor(1) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下	
	self.GaleBuffBar:SetPosition(250, -65)
end)

AddClientModRPCHandler("gale_rpc", "add_buff", function(target_name, stacks, buff_name, addition_tip, image_name, dtype)
	if ThePlayer and ThePlayer.HUD then
		ThePlayer.HUD.controls.GaleBuffBar:AddBuff(target_name,
			{ stacks = stacks, buff_name = buff_name, addition_tip = addition_tip, image_name = image_name, dtype = dtype })
	end
end)

AddClientModRPCHandler("gale_rpc", "update_buff", function(target_name, stacks, buff_name, addition_tip, image_name,
														   dtype)
	if ThePlayer and ThePlayer.HUD then
		ThePlayer.HUD.controls.GaleBuffBar:UpdateBuff(target_name,
			{ stacks = stacks, buff_name = buff_name, addition_tip = addition_tip, image_name = image_name, dtype = dtype })
	end
end)

AddClientModRPCHandler("gale_rpc", "remove_buff", function(target_name)
	if ThePlayer and ThePlayer.HUD then
		ThePlayer.HUD.controls.GaleBuffBar:RemoveBuff(target_name)
	end
end)



local function RegisterDebuff(self, name, ent, data)
	if ent.components.debuff ~= nil then
		self.debuffs[name] =
		{
			inst = ent,
			onremove = function(debuff)
				self.debuffs[name] = nil
				if self.ondebuffremoved ~= nil then
					self.ondebuffremoved(self.inst, name, debuff)
				end
			end,
		}
		self.inst:ListenForEvent("onremove", self.debuffs[name].onremove, ent)
		ent.persists = false
		ent.components.debuff:AttachTo(name, self.inst, self.followsymbol, self.followoffset, data)
		if self.ondebuffadded ~= nil then
			self.ondebuffadded(self.inst, name, ent, data)
		end
	else
		ent:Remove()
	end
end

AddComponentPostInit("debuffable", function(self)
	self.resume_list = {}

	local old_Enable = self.Enable
	self.Enable = function(self, enable, ...)
		if not enable then
			for name, v in pairs(self.debuffs) do
				if (v.inst.components.debuff ~= nil and v.inst.components.debuff.keepondisabled) then
					self.resume_list[name] = v.inst:GetSaveRecord()
				end
			end
		else
			for name, record in pairs(self.resume_list) do
				if self.debuffs[name] == nil then
					local ent = SpawnSaveRecord(record)
					if ent ~= nil then
						RegisterDebuff(self, name, ent)
					end
				end
			end
			self.resume_list = {}
		end

		return old_Enable(self, enable, ...)
	end

	local old_OnSave = self.OnSave
	self.OnSave = function(self, ...)
		local data = old_OnSave(self, ...) or {}
		data.resume_list = self.resume_list
		return data
	end

	local old_OnLoad = self.OnLoad
	self.OnLoad = function(self, data, ...)
		local old_ret = old_OnLoad(self, data, ...)
		if data ~= nil and data.resume_list ~= nil then
			self.resume_list = data.resume_list
		end
		return old_ret
	end
end)

AddPrefabPostInitAny(function(inst)
	if not TheWorld.ismastersim then
		return inst
	end

	-- condition_metallic
	if inst:HasTag("chess") or inst:HasTag("mech") or inst.prefab == "wx78" then
		GaleConditionUtil.AddCondition(inst, "condition_metallic")
	end
	----------------------------------------------------------------------------------

	-- condition_inbattle
	inst:ListenForEvent("onhitother", function(inst, data)
		GaleConditionUtil.AddCondition(inst, "condition_inbattle")
	end)

	inst:ListenForEvent("newstate", function(inst, data)
		if GaleConditionUtil.GetCondition(inst, "condition_inbattle") ~= nil and inst.sg:HasStateTag("attack") then
			GaleConditionUtil.AddCondition(inst, "condition_inbattle")
		end
	end)

	inst:ListenForEvent("attacked", function(inst, data)
		GaleConditionUtil.AddCondition(inst, "condition_inbattle")
	end)
	----------------------------------------------------------------------------------

	-- condition_bloated
	-- inst:ListenForEvent("hungerdelta",function(inst,data)

	-- end)
	----------------------------------------------------------------------------------
end)

-- AddPrefabPostInit("deerclops",function(inst)
-- 	if not TheWorld.ismastersim then
-- 		return inst
-- 	end

-- 	inst:ListenForEvent("onhitother",function(inst,data)
-- 		if not data.redirected and data.target and data.target:IsValid() and data.target.components.health and not data.target.components.health:IsDead() then
-- 			GaleConditionUtil.AddCondition(data.target,"condition_wound",3)
-- 		end
-- 	end)
-- end)
--------------------------------------------------------------------------------------------------------------------------






GLOBAL.c_condition = function(name, stack, target)
	target = target or ThePlayer
	stack = stack or 1
	if stack > 0 then
		GaleConditionUtil.AddCondition(target, name, stack)
	elseif stack < 0 then
		GaleConditionUtil.RemoveCondition(target, name, -stack)
	else
		print("Zero stack condition!")
	end
end
