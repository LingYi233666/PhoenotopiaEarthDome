require("stategraphs/commonstates")

-- ChargeableAttackSG({
-- 	pre_name = "gale_atk_melee_charging_pre",
-- 	attack_name = "gale_atk_melee_charging",
-- 	pre_anims = {"atk_pre","atk_lag"},
-- 	attack_anims = "atk",
-- 	do_attack_time = FRAMES,
-- 	idle_time = 13 * FRAMES,
-- })

-- Old
-- local function ChargeableAttackSG(out_data)
-- 	local DO_ATK_TIME = out_data.do_attack_time or FRAMES
-- 	local IDLE_TIME = out_data.idle_time or 13 * FRAMES

-- 	local server_sg = {
-- 		State{
-- 	        name = out_data.pre_name,
-- 	        tags = { "attack","charging_attack", "charging_attack_pre","doing", "busy", "notalking"},

-- 	        onenter = function(inst)
-- 	            inst.components.locomotor:Stop()

-- 	            if type(out_data.pre_anims) == "table" then
-- 		            for k,v in pairs(out_data.pre_anims) do
-- 		            	if k == 1 then
-- 		            		inst.AnimState:PlayAnimation(v)
-- 		            	else
-- 		            		inst.AnimState:PushAnimation(v, false)
-- 		            	end
-- 		            end
-- 		        else
-- 		        	inst.AnimState:PlayAnimation(out_data.pre_anims)
-- 		        end


-- 	            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

-- 	            local buffaction = inst:GetBufferedAction()
-- 	            local target = buffaction ~= nil and buffaction.target or nil
-- 	            inst.components.combat:SetTarget(target)
-- 	            inst.components.combat:StartAttack()
-- 	            inst.components.combat:BattleCry()

-- 	            if not inst.components.gale_melee_charge:IsComplete() then
-- 	                inst.components.gale_melee_charge:Start()
-- 	            end

-- 	            if out_data.pre_server_enter then
-- 	            	out_data.pre_server_enter(inst)
-- 	            end
-- 	        end,
-- 	        timeline = {},

-- 	        onupdate = function(inst)
-- 		        local buffaction = inst:GetBufferedAction()
-- 		        local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
-- 		        if target ~= nil and target:IsValid() then
-- 		            inst:ForceFacePoint(target.Transform:GetWorldPosition())
-- 		        end

-- 		        if not inst.components.gale_melee_charge:AtkPressed(buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE)
-- 	                and (inst.AnimState:AnimDone() or inst.AnimState:IsCurrentAnimation(type(out_data.pre_anims) == "table" and out_data.pre_anims[#out_data.pre_anims] or out_data.pre_anims)) then
-- 	                local complete = inst.components.gale_melee_charge:IsComplete()
-- 	            	inst.sg:GoToState(out_data.attack_name,{complete = complete})
-- 	            end
-- 	        end,

-- 	        events =
-- 	        {
-- 	            EventHandler("unequip", function(inst)
-- 	                inst.sg:GoToState("idle")
-- 	            end),
-- 	        },

-- 	        onexit = function(inst)
-- 	            inst.components.gale_melee_charge:Stop(inst.sg.statemem.stored_charge == true and "COMPLETE" or "NONE")
-- 	            if out_data.pre_onexit_server then
-- 	            	out_data.pre_onexit_server(inst)
-- 	            end
-- 	        end,
-- 	    },

-- 	    State{
-- 	        name = out_data.attack_name,
-- 	        tags = { "attack","charging_attack", "doing", "busy", "notalking","autopredict" },

-- 	        onenter = function(inst,data)
-- 	            inst.components.locomotor:Stop()

-- 	            if type(out_data.attack_anims) == "table" then
-- 		            for k,v in pairs(out_data.attack_anims) do
-- 		            	if k == 1 then
-- 		            		inst.AnimState:PlayAnimation(v)
-- 		            	else
-- 		            		inst.AnimState:PushAnimation(v, false)
-- 		            	end
-- 		            end
-- 		        else
-- 		        	inst.AnimState:PlayAnimation(out_data.attack_anims)
-- 		        end

-- 	            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")

-- 	            if data.complete then
-- 	                local ha_sound = "gale_sound_pack/battle/p1_gale_charge_atk_shout"
-- 	                local weapon = inst.components.combat:GetWeapon()
-- 	                if weapon and weapon.ha_sound ~= nil then
-- 	                    ha_sound = weapon.ha_sound
-- 	                end
-- 	            	inst.SoundEmitter:PlaySound(ha_sound)
-- 	            end

-- 	            inst.sg.statemem.charge_complete = data.complete

-- 	            if data.complete then
-- 	                inst.sg:AddStateTag("completed_charging_attack")
-- 	            end

-- 	            if out_data.attack_server_enter then
-- 	            	out_data.attack_server_enter(inst,data)
-- 	            end
-- 	        end,
-- 	        timeline =
-- 	        {
-- 	            TimeEvent(DO_ATK_TIME, function(inst)
-- 	                local bufferedaction = inst:GetBufferedAction()
-- 	                local attack_target = bufferedaction ~= nil and bufferedaction.action == ACTIONS.ATTACK and bufferedaction.target or nil


-- 	                inst:PerformBufferedAction()

-- 	                if inst.sg.statemem.charge_complete then
-- 		                inst.components.gale_melee_charge:DoSuperAttackMelee()
-- 	                    if attack_target and attack_target:IsValid() and attack_target.components.health and attack_target.components.health:IsDead() then
-- 	                        attack_target:PushEvent("knockback", { knocker = inst, radius = GetRandomMinMax(4,5) + attack_target:GetPhysicsRadius(.5)})
-- 	                    end          	
-- 		            end
-- 	            end),

-- 	            TimeEvent(DO_ATK_TIME + 3 * FRAMES, function(inst)
-- 	            	inst.sg:RemoveStateTag("doing")
-- 	            	inst.sg:RemoveStateTag("busy")
-- 	            	inst.sg:RemoveStateTag("attack")
-- 	            	inst.sg:AddStateTag("idle")
-- 	            end),

-- 	            TimeEvent(IDLE_TIME, function(inst)
-- 	                inst.sg:GoToState("idle", true)
-- 	            end),
-- 	        },

-- 	        events =
-- 	        {
-- 	            EventHandler("unequip", function(inst)
-- 	                inst.sg:GoToState("idle")
-- 	            end),
-- 	            EventHandler("animover", function(inst)
-- 	                if inst.AnimState:AnimDone() then
-- 	                    inst.sg:GoToState("idle")
-- 	                end
-- 	            end),
-- 	        },

-- 	        onexit = out_data.attack_onexit_server,
-- 	    },
-- 	}
-- 	-- end of server sg


-- 	local client_sg = {
-- 		State{
-- 	        name = out_data.pre_name,
-- 	        tags = { "attack","charging_attack", "charging_attack_pre", "doing", "busy" },

-- 	        onenter = function(inst)
-- 	            inst.components.locomotor:Stop()

-- 	            if type(out_data.pre_anims) == "table" then
-- 		            for k,v in pairs(out_data.pre_anims) do
-- 		            	if k == #out_data.pre_anims then
-- 		            		inst.AnimState:PushAnimation(v, false)
-- 		            	else
-- 		            		inst.AnimState:PlayAnimation(v)
-- 		            	end
-- 		            end
-- 		        else
-- 		        	inst.AnimState:PlayAnimation(out_data.pre_anims)
-- 		        end

-- 		        if out_data.pre_client_enter then
-- 	            	out_data.pre_client_enter(inst)
-- 	            end

-- 	            inst:PerformPreviewBufferedAction()
-- 	        end,

-- 	        timeline = {

-- 	        },

-- 	        onupdate = function(inst)
-- 	            local buffaction = inst:GetBufferedAction()
-- 	            local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
-- 	            if target ~= nil and target:IsValid() then
-- 	                inst:ForceFacePoint(target.Transform:GetWorldPosition())
-- 	            end

-- 	            local is_free_charge = buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE
-- 	            if not inst.replica.gale_melee_charge:AtkPressed(is_free_charge)
-- 	                and (inst.AnimState:AnimDone() or inst.AnimState:IsCurrentAnimation(type(out_data.pre_anims) == "table" and out_data.pre_anims[#out_data.pre_anims] or out_data.pre_anims)) then

-- 	                if is_free_charge then
-- 	                    SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_melee_charge_btn"],CONTROL_SECONDARY,false)
-- 	                else
-- 	                    SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_melee_charge_btn"],CONTROL_PRIMARY,false)
-- 	                    SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_melee_charge_btn"],CONTROL_ATTACK,false)
-- 	                    SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_melee_charge_btn"],CONTROL_CONTROLLER_ATTACK,false)
-- 	                end
-- 	                inst:PerformPreviewBufferedAction()
-- 	                inst.sg:GoToState(out_data.attack_name)
-- 	            end
-- 	        end,

-- 	        onexit = out_data.pre_onexit_client,
-- 	    },

-- 	    State{
-- 	        name =out_data.attack_name,
-- 	        tags = { "attack","charging_attack", "doing", "busy", "notalking"},

-- 	        onenter = function(inst)
-- 	            inst.components.locomotor:Stop()
-- 	            if type(out_data.attack_anims) == "table" then
-- 		            for k,v in pairs(out_data.attack_anims) do
-- 		            	if k == #out_data.attack_anims then
-- 		            		inst.AnimState:PushAnimation(v, false)
-- 		            	else
-- 		            		inst.AnimState:PlayAnimation(v)
-- 		            	end
-- 		            end
-- 		        else
-- 		        	inst.AnimState:PlayAnimation(out_data.attack_anims)
-- 		        end
-- 		        if out_data.attack_client_enter then
-- 	            	out_data.attack_client_enter(inst)
-- 	            end
-- 	            inst:PerformPreviewBufferedAction()
-- 	        end,
-- 	        timeline =
-- 	        {
-- 	            TimeEvent(DO_ATK_TIME + 3 * FRAMES, function(inst)
-- 	                inst.sg:RemoveStateTag("doing")
-- 	                inst.sg:RemoveStateTag("busy")
-- 	                inst.sg:RemoveStateTag("attack")
-- 	                inst.sg:AddStateTag("idle")
-- 	            end),

-- 	            TimeEvent(IDLE_TIME, function(inst)
-- 	                inst.sg:GoToState("idle", true)
-- 	            end),
-- 	        },

-- 	        events =
-- 	        {
-- 	            EventHandler("animover", function(inst)
-- 	                if inst.AnimState:AnimDone() then
-- 	                    inst.sg:GoToState("idle")
-- 	                end
-- 	            end),
-- 	        },

-- 	        onexit = out_data.attack_onexit_client,
-- 	    },
-- 	}
-- 	-- end of client sg

-- 	for _,v in pairs(out_data.pre_timeline_server or {}) do
-- 		table.insert(server_sg[1].timeline,v)
-- 	end
-- 	table.sort(server_sg[1].timeline,function(t1,t2)
-- 		return t1.time < t2.time
-- 	end)

-- 	for _,v in pairs(out_data.attack_timeline_server or {}) do
-- 		table.insert(server_sg[2].timeline,v)
-- 	end
-- 	table.sort(server_sg[2].timeline,function(t1,t2)
-- 		return t1.time < t2.time
-- 	end)

-- 	for _,v in pairs(out_data.pre_timeline_client or {}) do
-- 		table.insert(client_sg[1].timeline,v)
-- 	end
-- 	table.sort(client_sg[1].timeline,function(t1,t2)
-- 		return t1.time < t2.time
-- 	end)

-- 	for _,v in pairs(out_data.attack_timeline_client or {}) do
-- 		table.insert(client_sg[2].timeline,v)
-- 	end
-- 	table.sort(client_sg[2].timeline,function(t1,t2)
-- 		return t1.time < t2.time
-- 	end)

-- 	return server_sg,client_sg
-- end

-- local function CommonEnterPreChargeableServerSG(inst)
-- 	inst.components.locomotor:Stop()
-- 	local buffaction = inst:GetBufferedAction()
-- 	local target = buffaction ~= nil and buffaction.target or nil
-- 	inst.components.combat:SetTarget(target)
-- 	inst.components.combat:StartAttack()
-- 	inst.components.combat:BattleCry()

-- 	if not inst.components.gale_weaponcharge:IsComplete() then
-- 	    inst.components.gale_weaponcharge:Start()
-- 	end
-- end

-- local function CommonUpdatePreChargeableServerSG(inst,data)
-- 	local buffaction = inst:GetBufferedAction()
-- 	local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
-- 	if target ~= nil and target:IsValid() then
-- 		inst:ForceFacePoint(target.Transform:GetWorldPosition())
--  	end

-- 	if not inst.components.gale_weaponcharge:AtkPressed(buffaction and buffaction.action == ACTIONS.TZ_FREE_CHARGE)
-- 	    and (inst.AnimState:AnimDone() or inst.AnimState:IsCurrentAnimation(type(out_data.pre_anims) == "table" and out_data.pre_anims[#out_data.pre_anims] or out_data.pre_anims)) then
-- 	    local complete = inst.components.gale_weaponcharge:IsComplete()
-- 	    inst.sg:GoToState(out_data.attack_name,{complete = complete})
-- 	 end
-- end

local function ServerChargePreEnter(inst, target)
	-- local buffaction = inst:GetBufferedAction()
	-- local target = buffaction ~= nil and buffaction.target or nil
	inst.components.combat:SetTarget(target)
	inst.components.combat:StartAttack()
	inst.components.combat:BattleCry()

	if not inst.components.gale_weaponcharge:IsComplete() and not inst:HasTag("gale_skill_carry_charge_trigger") then
		inst.components.gale_weaponcharge:Start()
	end
end

-- data:
-- 	last_anim
-- 	attack_sg_name
local function ServerChargePreUpdate(inst, data)
	-- local buffaction = inst:GetBufferedAction()
	-- local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
	local target = data.target
	local is_free_charge = data.is_free_charge

	if not inst.sg:HasStateTag("moving") then
		if target ~= nil and target:IsValid() and not is_free_charge then
			inst:ForceFacePoint(target.Transform:GetWorldPosition())
		else
			inst:ForceFacePoint(inst.components.gale_control_key_helper:GetMousePosition():Get())
		end
	end


	if (not inst.components.gale_weaponcharge:AtkPressed(is_free_charge)
		-- or inst:HasTag("gale_skill_carry_charge_trigger")
		)
		and (inst.AnimState:IsCurrentAnimation(data.last_anim)) then
		local complete = inst.components.gale_weaponcharge:IsComplete()

		inst.sg.statemem.exit_normally = true
		inst.sg:GoToState(data.attack_sg_name, {
			complete = complete,
			buffaction_storage = data.buffaction_storage,
		})
	end
end

-- data:
-- 	last_anim
-- 	attack_sg_name
local function ClientChargePreUpdate(inst, data)
	-- local buffaction = inst:GetBufferedAction()
	-- local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
	local target = data.target
	local is_free_charge = data.is_free_charge

	if not inst.sg:HasStateTag("moving") then
		if target ~= nil and target:IsValid() and not is_free_charge then
			inst:ForceFacePoint(target.Transform:GetWorldPosition())
		else
			inst:ForceFacePoint(TheInput:GetWorldPosition():Get())
		end
	end

	-- local is_free_charge = buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE

	-- should be false true
	-- print(os.time(),"ClientChargePreUpdate",inst.replica.gale_weaponcharge:AtkPressed(is_free_charge),inst.AnimState:IsCurrentAnimation(data.last_anim))
	if (not inst.replica.gale_weaponcharge:AtkPressed(is_free_charge)
		-- or inst:HasTag("gale_skill_carry_charge_trigger")
		)
		and (inst.AnimState:IsCurrentAnimation(data.last_anim)) then
		-- and (inst.AnimState:AnimDone()) then

		-- if is_free_charge then
		-- 	SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"],CONTROL_SECONDARY,false)
		-- else
		-- 	SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"],CONTROL_PRIMARY,false)
		-- 	SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"],CONTROL_ATTACK,false)
		-- 	SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"],CONTROL_CONTROLLER_ATTACK,false)
		-- end
		-- inst:PerformPreviewBufferedAction()
		inst.sg:GoToState(data.attack_sg_name)
	end
end


local function ServerAttackEnter(inst)
	if inst.components.combat:InCooldown() then
		inst.sg:RemoveStateTag("abouttoattack")
		inst:ClearBufferedAction()
		inst.sg:GoToState("idle", true)
		return false
	end

	-- if inst.sg.laststate == inst.sg.currentstate then
	-- 	inst.sg.statemem.chained = true
	-- end

	local buffaction = inst:GetBufferedAction()
	local target = buffaction ~= nil and buffaction.target or nil
	inst.components.combat:SetTarget(target)
	inst.components.combat:StartAttack()
	inst.components.locomotor:Stop()

	if target ~= nil then
		inst.components.combat:BattleCry()
		if target:IsValid() then
			inst:FacePoint(target:GetPosition())
			inst.sg.statemem.attacktarget = target

			-- This can make quick attack
			inst.sg.statemem.retarget = target
		end
	end

	return target
end

local function ClientAttackEnter(inst)
	local combat = inst.replica.combat
	if combat:InCooldown() then
		inst.sg:RemoveStateTag("abouttoattack")
		inst:ClearBufferedAction()
		inst.sg:GoToState("idle", true)
		return false
	end

	combat:StartAttack()
	inst.components.locomotor:Stop()

	local buffaction = inst:GetBufferedAction()
	if buffaction ~= nil then
		inst:PerformPreviewBufferedAction()

		if buffaction.target ~= nil and buffaction.target:IsValid() then
			inst:FacePoint(buffaction.target:GetPosition())
			inst.sg.statemem.attacktarget = buffaction.target
			inst.sg.statemem.retarget = buffaction.target
		end
	end
end

local function ChargeableAttackSG(out_data)
	local DO_ATK_TIME = out_data.do_attack_time or FRAMES
	local IDLE_TIME = out_data.idle_time or 13 * FRAMES

	local server_sg = {
		State {
			name = out_data.pre_name,
			tags = { "attack", "charging_attack", "charging_attack_pre", "doing", "busy", "notalking" },

			onenter = function(inst)
				inst.components.locomotor:Stop()

				if type(out_data.pre_anims) == "table" then
					for k, v in pairs(out_data.pre_anims) do
						if k == 1 then
							inst.AnimState:PlayAnimation(v)
						else
							inst.AnimState:PushAnimation(v, false)
						end
					end
				else
					inst.AnimState:PlayAnimation(out_data.pre_anims)
				end


				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.target or nil
				inst.components.combat:SetTarget(target)
				inst.components.combat:StartAttack()
				inst.components.combat:BattleCry()

				if not inst.components.gale_weaponcharge:IsComplete() then
					inst.components.gale_weaponcharge:Start()
				end

				if out_data.pre_server_enter then
					out_data.pre_server_enter(inst)
				end
			end,
			timeline = {},

			onupdate = function(inst)
				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
				if target ~= nil and target:IsValid() then
					inst:ForceFacePoint(target.Transform:GetWorldPosition())
				end

				if not inst.components.gale_weaponcharge:AtkPressed(buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE)
					and (inst.AnimState:AnimDone() or inst.AnimState:IsCurrentAnimation(type(out_data.pre_anims) == "table" and out_data.pre_anims[#out_data.pre_anims] or out_data.pre_anims)) then
					local complete = inst.components.gale_weaponcharge:IsComplete()
					inst.sg:GoToState(out_data.attack_name, { complete = complete })
				end
			end,

			events =
			{
				EventHandler("unequip", function(inst)
					inst.sg:GoToState("idle")
				end),
			},

			onexit = function(inst)
				if out_data.pre_onexit_server then
					out_data.pre_onexit_server(inst)
				end
			end,
		},

		State {
			name = out_data.attack_name,
			tags = { "attack", "charging_attack", "doing", "busy", "notalking", "autopredict" },

			onenter = function(inst, data)
				inst.components.locomotor:Stop()

				if type(out_data.attack_anims) == "table" then
					for k, v in pairs(out_data.attack_anims) do
						if k == 1 then
							inst.AnimState:PlayAnimation(v)
						else
							inst.AnimState:PushAnimation(v, false)
						end
					end
				else
					inst.AnimState:PlayAnimation(out_data.attack_anims)
				end

				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")

				if data.complete then
					inst.sg:AddStateTag("completed_charging_attack")
				end

				inst.sg.statemem.charge_complete = data.complete

				if out_data.attack_server_enter then
					out_data.attack_server_enter(inst, data)
				end
			end,
			timeline =
			{
				TimeEvent(DO_ATK_TIME, function(inst)
					inst:PerformBufferedAction()
				end),

				TimeEvent(DO_ATK_TIME + 3 * FRAMES, function(inst)
					inst.sg:RemoveStateTag("doing")
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("attack")
					inst.sg:AddStateTag("idle")
				end),

				TimeEvent(IDLE_TIME, function(inst)
					inst.sg:GoToState("idle", true)
				end),
			},

			events =
			{
				EventHandler("unequip", function(inst)
					inst.sg:GoToState("idle")
				end),
				EventHandler("animover", function(inst)
					if inst.AnimState:AnimDone() then
						inst.sg:GoToState("idle")
					end
				end),
			},

			onexit = out_data.attack_onexit_server,
		},
	}
	-- end of server sg


	local client_sg = {
		State {
			name = out_data.pre_name,
			tags = { "attack", "charging_attack", "charging_attack_pre", "doing", "busy" },

			onenter = function(inst)
				inst.components.locomotor:Stop()

				if type(out_data.pre_anims) == "table" then
					for k, v in pairs(out_data.pre_anims) do
						if k == #out_data.pre_anims then
							inst.AnimState:PushAnimation(v, false)
						else
							inst.AnimState:PlayAnimation(v)
						end
					end
				else
					inst.AnimState:PlayAnimation(out_data.pre_anims)
				end

				if out_data.pre_client_enter then
					out_data.pre_client_enter(inst)
				end

				inst:PerformPreviewBufferedAction()
			end,

			timeline = {

			},

			onupdate = function(inst)
				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.action == ACTIONS.ATTACK and buffaction.target or nil
				if target ~= nil and target:IsValid() then
					inst:ForceFacePoint(target.Transform:GetWorldPosition())
				end

				local is_free_charge = buffaction and buffaction.action == ACTIONS.GALE_FREE_CHARGE
				if not inst.replica.gale_weaponcharge:AtkPressed(is_free_charge)
					and (inst.AnimState:AnimDone() or inst.AnimState:IsCurrentAnimation(type(out_data.pre_anims) == "table" and out_data.pre_anims[#out_data.pre_anims] or out_data.pre_anims)) then
					if is_free_charge then
						SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"], CONTROL_SECONDARY, false)
					else
						SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"], CONTROL_PRIMARY, false)
						SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"], CONTROL_ATTACK, false)
						SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_weaponcharge_btn"], CONTROL_CONTROLLER_ATTACK, false)
					end
					inst:PerformPreviewBufferedAction()
					inst.sg:GoToState(out_data.attack_name)
				end
			end,

			onexit = out_data.pre_onexit_client,
		},

		State {
			name = out_data.attack_name,
			tags = { "attack", "charging_attack", "doing", "busy", "notalking" },

			onenter = function(inst)
				inst.components.locomotor:Stop()

				if type(out_data.attack_anims) == "table" then
					for k, v in pairs(out_data.attack_anims) do
						if k == 1 then
							inst.AnimState:PlayAnimation(v)
						else
							inst.AnimState:PushAnimation(v, false)
						end
					end
				else
					inst.AnimState:PlayAnimation(out_data.attack_anims)
				end

				if out_data.attack_client_enter then
					out_data.attack_client_enter(inst)
				end
				inst:PerformPreviewBufferedAction()
			end,
			timeline =
			{
				TimeEvent(DO_ATK_TIME + 3 * FRAMES, function(inst)
					inst.sg:RemoveStateTag("doing")
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("attack")
					inst.sg:AddStateTag("idle")
				end),

				TimeEvent(IDLE_TIME, function(inst)
					inst.sg:GoToState("idle", true)
				end),
			},

			events =
			{
				EventHandler("animover", function(inst)
					if inst.AnimState:AnimDone() then
						inst.sg:GoToState("idle")
					end
				end),
			},

			onexit = out_data.attack_onexit_client,
		},
	}
	-- end of client sg

	for _, v in pairs(out_data.pre_timeline_server or {}) do
		table.insert(server_sg[1].timeline, v)
	end
	table.sort(server_sg[1].timeline, function(t1, t2)
		return t1.time < t2.time
	end)

	for _, v in pairs(out_data.attack_timeline_server or {}) do
		table.insert(server_sg[2].timeline, v)
	end
	table.sort(server_sg[2].timeline, function(t1, t2)
		return t1.time < t2.time
	end)

	for _, v in pairs(out_data.pre_timeline_client or {}) do
		table.insert(client_sg[1].timeline, v)
	end
	table.sort(client_sg[1].timeline, function(t1, t2)
		return t1.time < t2.time
	end)

	for _, v in pairs(out_data.attack_timeline_client or {}) do
		table.insert(client_sg[2].timeline, v)
	end
	table.sort(client_sg[2].timeline, function(t1, t2)
		return t1.time < t2.time
	end)

	return server_sg, client_sg
end


local function GenerateMultiShootSG_pistol()
	local normal_play_shoot_sound_time = 16 * FRAMES
	local normal_shoot_time = 17 * FRAMES
	-- local normal_remove_attacktag_time = 18 * FRAMES


	local server_sgs = {}
	local client_sgs = {}

	for earlier_index = 0, 14 do
		-- 18,21,24,27,30
		for remove_attacktag_index = 18, 30 do
			local earlier_time = earlier_index * FRAMES
			local remove_attacktag_time = remove_attacktag_index * FRAMES
			local chain_duration = remove_attacktag_time - normal_shoot_time + 5 * FRAMES


			local state_name = "galeatk_pistol"
			if earlier_index > 0 then
				state_name = state_name .. "_earlier_" .. tostring(earlier_index)
			end
			state_name = state_name .. "_remove_attacktag_at_" .. tostring(remove_attacktag_index)


			local server_sg = State {
				name = state_name,
				tags = { "attack", "notalking", "abouttoattack", "autopredict" },
				onenter = function(inst)
					local target = ServerAttackEnter(inst)
					if target == false then
						return
					end


					inst.AnimState:PlayAnimation("hand_shoot")

					if earlier_index > 0 and inst.gale_last_pistol_shoot_time and GetTime() - inst.gale_last_pistol_shoot_time <= chain_duration then
						inst.sg.statemem.chained = true
						inst.AnimState:SetTime(earlier_time)
					end

					local bufferedaction = inst:GetBufferedAction()
					local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

					if equip and bufferedaction then
						inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and
							equip.shoot_sound_skill or equip.shoot_sound
					end

					inst.sg:SetTimeout(
						math.max(
							inst.sg.statemem.chained and (remove_attacktag_time - earlier_time) or remove_attacktag_time,
							inst.components.combat.min_attack_period + .5 * FRAMES)
					)
				end,

				ontimeout = function(inst)
					inst.sg:RemoveStateTag("attack")
					inst.sg:AddStateTag("idle")
				end,

				timeline =
				{
					TimeEvent(normal_play_shoot_sound_time - earlier_time, function(inst)
						if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
							inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
						end
					end),

					TimeEvent(normal_shoot_time - earlier_time, function(inst)
						if inst.sg.statemem.chained then
							inst:PerformBufferedAction()
							inst.gale_last_pistol_shoot_time = GetTime()
							inst.sg:RemoveStateTag("abouttoattack")
						end
					end),

					TimeEvent(normal_play_shoot_sound_time, function(inst)
						if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
							inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
						end
					end),

					TimeEvent(normal_shoot_time, function(inst)
						if not inst.sg.statemem.chained then
							if inst:PerformBufferedAction() then
								inst.gale_last_pistol_shoot_time = GetTime()
							end

							inst.sg:RemoveStateTag("abouttoattack")
						end
					end),
				},

				events =
				{
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle")
						end
					end),
				},

				onexit = function(inst)
					inst.components.combat:SetTarget(nil)
					if inst.sg:HasStateTag("abouttoattack") then
						inst.components.combat:CancelAttack()
					end
				end,
			}

			local client_sg = State {
				name = state_name,
				tags = { "attack", "notalking", "abouttoattack" },
				onenter = function(inst)
					local target = ClientAttackEnter(inst)
					if target == false then
						return
					end

					inst.AnimState:PlayAnimation("hand_shoot")

					if earlier_index > 0 and inst._gale_last_pistol_shoot_time and GetTime() - inst._gale_last_pistol_shoot_time <= chain_duration then
						inst.sg.statemem.chained = true
						inst.AnimState:SetTime(earlier_time)
					end

					local bufferedaction = inst:GetBufferedAction()
					local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

					local timeout = math.max(
						inst.sg.statemem.chained and (remove_attacktag_time - earlier_time) or remove_attacktag_time,
						inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
					)
					inst.sg:SetTimeout(timeout)


					if equip and bufferedaction then
						inst.sg.statemem.shoot_sound = bufferedaction.action == ACTIONS.CASTAOE and
							equip.shoot_sound_skill or equip.shoot_sound
					end
				end,

				ontimeout = function(inst)
					inst.sg:RemoveStateTag("attack")
					inst.sg:AddStateTag("idle")
				end,

				timeline = {
					TimeEvent(normal_play_shoot_sound_time - earlier_time, function(inst)
						if inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
							inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
						end
					end),

					TimeEvent(normal_shoot_time - earlier_time, function(inst)
						if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
							inst._gale_last_pistol_shoot_time = GetTime()
							inst:ClearBufferedAction()
							inst.sg:RemoveStateTag("abouttoattack")
						end
					end),

					TimeEvent(normal_play_shoot_sound_time, function(inst)
						if not inst.sg.statemem.chained and inst.sg.statemem.shoot_sound then
							inst.SoundEmitter:PlaySound(inst.sg.statemem.shoot_sound, nil, nil, true)
						end
					end),

					TimeEvent(normal_shoot_time, function(inst)
						if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
							inst._gale_last_pistol_shoot_time = GetTime()
							inst:ClearBufferedAction()
							inst.sg:RemoveStateTag("abouttoattack")
						end
					end),

				},

				events =
				{
					EventHandler("animqueueover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle")
						end
					end),
				},

				onexit = function(inst)
					if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
						inst.replica.combat:CancelAttack()
					end
				end,

			}

			table.insert(server_sgs, server_sg)
			table.insert(client_sgs, client_sg)
		end
	end

	return server_sgs, client_sgs
end

return {
	-- ChargeableAttackSG = ChargeableAttackSG,

	ServerChargePreEnter = ServerChargePreEnter,
	ServerChargePreUpdate = ServerChargePreUpdate,

	ClientChargePreUpdate = ClientChargePreUpdate,

	ServerAttackEnter = ServerAttackEnter,
	ClientAttackEnter = ClientAttackEnter,


	GenerateMultiShootSG_pistol = GenerateMultiShootSG_pistol,
}
