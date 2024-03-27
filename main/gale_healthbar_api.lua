local healthbar_Assets = {

}

for k, v in pairs(healthbar_Assets) do
	table.insert(Assets, v)
end
-- ThePlayer.HUD.controls.GaleHealthBar:SetPercent(0.75)
local GaleHealthBar = require("widgets/galehealthbar")
AddClassPostConstruct("widgets/controls", function(self)
	self.GaleHealthBar = self:AddChild(GaleHealthBar(self.owner))
	self.GaleHealthBar:SetVAnchor(ANCHOR_BOTTOM)
	self.GaleHealthBar:SetHAnchor(ANCHOR_MIDDLE)
	self.GaleHealthBar:SetPosition(0, -75)
	self.GaleHealthBar:MoveToBack()
end)

AddReplicableComponent("gale_healthbar")

-- local HealthBaredCreatures = {
-- 	"bishop",
-- 	"knight",
-- 	"rook",
-- }

-- for k,v in pairs(HealthBaredCreatures) do
-- 	AddPrefabPostInit(v,function(inst)
-- 		if not TheWorld.ismastersim then
-- 			return inst
-- 		end

-- 		inst:AddComponent("gale_healthbar")
-- 	end)
-- end

local banned_prefab = {
	"cherry_watcher",
}

AddPrefabPostInitAny(function(inst)
	if not TheWorld.ismastersim then
		return inst
	end

	if table.contains(banned_prefab, inst.prefab) then

	end

	if inst.components.combat and inst.components.health then
		inst:AddComponent("gale_healthbar")
	end
end)



AddClientModRPCHandler("gale_healthbar", "settarget", function(target)
	if ThePlayer.HUD and ThePlayer.HUD.controls.GaleHealthBar then
		ThePlayer.HUD.controls.GaleHealthBar:SetTarget(target)
	end
end)

local function SetHealthBarTarget(inst, target)
	if inst == target then
		return
	end
	if target and target.components and target.components.gale_healthbar then
		SendModRPCToClient(CLIENT_MOD_RPC["gale_healthbar"]["settarget"], inst.userid, target)
	else
		SendModRPCToClient(CLIENT_MOD_RPC["gale_healthbar"]["settarget"], inst.userid, nil)
	end
end

local HEALTHBAR_ENABLE = GetModConfigData("gale_healthbar_enable", nil, true)

AddPlayerPostInit(function(inst)
	if not TheWorld.ismastersim then
		return inst
	end

	inst:ListenForEvent("onhitother", function(inst, data)
		if not HEALTHBAR_ENABLE then
			return
		end

		if data.target then
			SetHealthBarTarget(inst, data.target)
		end
	end)

	inst:ListenForEvent("attacked", function(inst, data)
		if not HEALTHBAR_ENABLE then
			return
		end

		if data.attacker then
			SetHealthBarTarget(inst, data.attacker)
		end
	end)

	inst:ListenForEvent("performaction", function(inst, data)
		if not HEALTHBAR_ENABLE then
			return
		end

		local act = data.action
		if act and act.action then
			if act.action == ACTIONS.LOOKAT then
				SetHealthBarTarget(inst, act.target or act.invobject)
			elseif act.action == ACTIONS.ATTACK then
				SetHealthBarTarget(inst, act.target)
			elseif act.action == ACTIONS.GALE_FREE_CHARGE then
				if act.target then
					SetHealthBarTarget(inst, act.target)
				end
			end
		end
	end)
end)
