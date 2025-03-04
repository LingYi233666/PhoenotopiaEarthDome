local MakePlayerCharacter = require "prefabs/player_common"
local GaleCondition = require("util/gale_conditions")

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

	Asset("ANIM", "anim/player_pistol.zip"),
	Asset("ANIM", "anim/player_actions_roll.zip"),

	Asset("ANIM", "anim/gale_speedrun.zip"),
	Asset("ANIM", "anim/gale_actions_harpy_whirl.zip"),

	Asset("ANIM", "anim/gale_dark_vision_ui.zip"),


	-- Asset("ANIM", "anim/gale_bigger_test.zip"),
}

-- face up 15 pixel
-- face-side up 15 pixel,right 5 pixel
-- ThePlayer.AnimState:OverrideSymbol("headbase","gale_bigger_test","headbase") ThePlayer.AnimState:OverrideSymbol("face","gale_bigger_test","face")
-- ThePlayer.AnimState:ClearOverrideSymbol("headbase") ThePlayer.AnimState:ClearOverrideSymbol("face")
-- ThePlayer.AnimState:SetBuild("gale_bigger_test")
local prefabs = {}

-- 初始物品
local start_inv = {
	"gale_flute",
	"gale_crowbar",
	"gale_cookpot_item",
	"gale_bombbox",
	-- "gale_spear",
	-- "gale_blaster_katash",
}

-- 当人物复活的时候
local function onbecamehuman(inst)
	-- 设置人物的移速（1表示1倍于wilson）
	-- inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gale_speed_mod", 1)
	--（也可以用以前的那种
	--inst.components.locomotor.walkspeed = 4
	--inst.components.locomotor.runspeed = 6）
end
--当人物死亡的时候
local function onbecameghost(inst)
	-- 变成鬼魂的时候移除速度修正
	-- inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "gale_speed_mod")
end

-- 重载游戏或者生成一个玩家的时候
local function onload(inst)
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	inst:ListenForEvent("ms_becameghost", onbecameghost)

	if inst:HasTag("playerghost") then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end
end

local function OnNewSpawn(inst)
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	inst:ListenForEvent("ms_becameghost", onbecameghost)

	if inst:HasTag("playerghost") then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end

	inst.components.inventory:Equip(SpawnAt("gale_pocket_backpack_lv8", inst))

	inst.sg:GoToState("gale_newspawn_sleeping")
end

local AtkTags = {
	-- galeatk_lunge = 0.5,
	galeatk_leap = 0.4,
	galeatk_multithrust = 0.3,
	galeatk_none = 1.0,
}

local function RemoveAllAtkTags(player)
	for k, v in pairs(AtkTags) do
		player:RemoveTag(k)
	end
end

local function AddRandomAtkTag(player)
	RemoveAllAtkTags(player)

	if player:HasTag("attack") and not player:HasTag("gale_skill_carry_charge_trigger") then
		local weapon = player.components.combat:GetWeapon()
		if weapon and weapon:HasTag("gale_crowbar") then
			local tag = weighted_random_choice(AtkTags)
			if tag ~= "galeatk_none" then
				-- print("Configure gale atk tag to",tag)
				player.last_atk_tag = tag
				player:AddTag(tag)
			end
		end
	end
end


--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- inst:AddTag("pebblemaker")
	-- inst:AddTag("slingshot_sharpshooter")
	inst:AddTag("gale")
	inst:AddTag("gale_weaponcharge")

	-- Minimap icon
	inst.MiniMapEntity:SetIcon("gale.tex")

	inst.yawnsoundoverride = "gale_sfx/character/gale_yawn"
	inst.deathsoundoverride = "gale_sfx/character/gale_fallen"

	-- inst.AnimState:SetScale(1.15,1.15,1.15)

	inst.AnimState:AddOverrideBuild("player_actions_roll")
	inst.AnimState:HideSymbol("shadow_1")
	inst.AnimState:HideSymbol("shadow_2")
	inst.AnimState:HideSymbol("shadow_3")

	inst.AnimState:AddOverrideBuild("gale_phantom_add")
	-- inst.AnimState:SetSymbolMultColour("handswipes_fx", 0, 0, 0, 1)
	inst.AnimState:SetSymbolAddColour("handswipes_fx", 255 / 255, 255 / 255, 0 / 255, 1)
	inst.AnimState:SetSymbolLightOverride("handswipes_fx", 1)



	inst:AddComponent("gale_skill_shadow_dodge")

	inst:AddComponent("gale_skill_dark_vision")

	-- inst.speech_override_fn = function () return "" end
end

local function PlayAttackedSound(inst, data)
	if data.redirected then
		return
	end
	if not inst.components.health:IsDead() then
		if data.damage >= 50 then
			inst.SoundEmitter:PlaySound("gale_sfx/character/p1_gale_hurt3")
		elseif data.damage >= 20 then
			inst.SoundEmitter:PlaySound("gale_sfx/character/p1_gale_hurt2")
		else
			inst.SoundEmitter:PlaySound("gale_sfx/character/p1_gale_hurt1")
		end
	end
end

local talk_alternative = {
	"gale_sfx/character/talk/female/f_B",
	"gale_sfx/character/talk/female/f_C",
	"gale_sfx/character/talk/female/f_D",
	"gale_sfx/character/talk/female/f_E",
	"gale_sfx/character/talk/female/f_G",
	"gale_sfx/character/talk/female/f_Q",
	"gale_sfx/character/talk/female/f_T",
	"gale_sfx/character/talk/female/f_Z",
}
local function PlayTalkSeq(inst, data)
	-- if not data.noanim and not inst:HasTag("busy") then
	if not data.noanim and inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
		local length = #data.message
		length = math.clamp(length, 18, 25)

		if inst.GaleTalkThread then
			KillThread(inst.GaleTalkThread)
		end
		inst.GaleTalkThread = inst:StartThread(function()
			Sleep(0)
			local i = 0
			while true do
				if i > length or not inst.sg:HasStateTag("talking") then
					break
				end

				local seq = talk_alternative[math.random(1, #talk_alternative)]
				inst.SoundEmitter:PlaySound(seq)
				i = i + 1


				Sleep(2 * FRAMES)
			end

			inst.GaleTalkThread = nil
		end)
	end
end

local function OnSpawnPet(inst, pet)
	if pet:HasTag("shadowminion") then

	elseif inst._OnSpawnPet ~= nil then
		inst:_OnSpawnPet(pet)
	end
end

local function OnDespawnPet(inst, pet)
	if pet:HasTag("shadowminion") then
		pet:Remove()
	elseif inst._OnDespawnPet ~= nil then
		inst:_OnDespawnPet(pet)
	end
end

local function AdditionSleepTick(inst)

end

local function CanDodgeTest(inst, attacker)
	-- return inst.components.gale_skill_shadow_dodge and inst.components.gale_skill_shadow_dodge:IsDodging()
	return (inst.sg and inst.sg:HasStateTag("gale_attack_dodge")) or inst:HasTag("gale_attack_dodge")
end

-- local function OnCollide(inst, other, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)

-- 	print(inst, other,world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)
-- end


-- Add condition_bloated when eat too much
-- local function CustomStateModFn(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
-- 	local hunger_val = inst.components.hunger.current
-- 	local hunger_max = inst.components.hunger.max

-- 	local overflow = hunger_val + hunger_delta - hunger_max
-- 	if overflow >= 10 then
-- 		GaleCondition.AddCondition(inst,"condition_bloated",math.ceil(overflow))
-- 	end

-- 	return health_delta, hunger_delta, sanity_delta
-- end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "gale"

	-- inst.Physics:SetCollisionCallback(OnCollide)

	inst:AddComponent("gale_skiller")

	inst:AddComponent("gale_stamina")

	inst:AddComponent("gale_magic")

	-- Inventory slots
	-- inst.components.inventory.maxslots = 10

	-- inst:AddComponent("worker")
	-- inst.components.worker:SetAction(ACTIONS.CHOP, 4)

	inst.components.foodaffinity:AddPrefabAffinity("pumpkincookie", TUNING.AFFINITY_15_CALORIES_HUGE)

	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.GALE_HEALTH)
	inst.components.hunger:SetMax(TUNING.GALE_HUNGER)
	inst.components.sanity:SetMax(TUNING.GALE_SANITY)

	-- 伤害系数
	inst.components.combat.damagemultiplier = 1

	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

	inst.components.talker.ontalkfn = PlayTalkSeq

	inst._OnSpawnPet = inst.components.petleash.onspawnfn
	inst._OnDespawnPet = inst.components.petleash.ondespawnfn
	inst.components.petleash:SetOnSpawnFn(OnSpawnPet)
	inst.components.petleash:SetOnDespawnFn(OnDespawnPet)

	inst.components.sleepingbaguser:SetHealthBonusMult(2)
	local old_SleepTick = inst.components.sleepingbaguser.SleepTick
	inst.components.sleepingbaguser.SleepTick = function(self, ...)
		local period = self.bed.components.sleepingbag.tick_period or 1
		if self.inst.components.gale_magic then
			self.inst.components.gale_magic:DoDelta((period + FRAMES) * 5)
		end
		return old_SleepTick(self, ...)
	end

	-- inst.components.eater.custom_stats_mod_fn = CustomStateModFn

	if not inst.components.attackdodger then
		inst:AddComponent("attackdodger")
	end
	inst.components.attackdodger:SetCanDodgeFn(CanDodgeTest)


	inst:AddComponent("gale_weaponcharge")

	inst:AddComponent("gale_flute_buffed")

	inst:AddComponent("gale_status_bonus")
	inst.components.gale_status_bonus.base_value.health = TUNING.GALE_HEALTH
	inst.components.gale_status_bonus.base_value.hunger = TUNING.GALE_HUNGER
	inst.components.gale_status_bonus.base_value.sanity = TUNING.GALE_SANITY
	inst.components.gale_status_bonus.base_value.gale_stamina = 100

	inst:AddComponent("gale_spellpower_level")

	inst:AddComponent("gale_skill_mimic")

	inst:AddComponent("gale_skill_phantom_create")

	inst:AddComponent("gale_skill_linkage")

	inst:AddComponent("gale_skill_parry")

	inst:AddComponent("gale_skill_hyperburn")

	inst:AddComponent("gale_skill_electric_punch")
	inst.components.gale_skill_electric_punch:CreateWeapon()
	-- inst.components.gale_skill_electric_punch:SetEnabled(true)
	-- ThePlayer.components.gale_skill_electric_punch:SetEnabled(true)



	GaleCondition.AddCondition(inst, "condition_gale_boon")
	-- inst:SpawnChild("gale_speedrun_vfx")

	inst.OnLoad = onload
	inst.OnNewSpawn = OnNewSpawn


	inst:ListenForEvent("attacked", PlayAttackedSound)
	-- inst:ListenForEvent("newcombattarget", AddRandomAtkTag)
	-- inst:ListenForEvent("equip", RemoveAllAtkTags)
	-- inst:ListenForEvent("unequip", RemoveAllAtkTags)

	-- inst:ListenForEvent("owner_find_gale_blaster_jammed", function()
	-- 	if not IsEntityDeadOrGhost(inst, true) then
	-- 		inst.components.talker:Say(STRINGS.GALE_CHATTYNODES.GALE.FIND_BLASTER_JAMMED)
	-- 	end
	-- end)
end

return MakePlayerCharacter("gale", prefabs, assets, common_postinit, master_postinit, start_inv)
