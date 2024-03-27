local function IsFlying(inst) 
    return inst.components.mk_flyer and inst.components.mk_flyer:IsFlying() 
end

local SpecialTags = {
    "gale_speedrun",
}

local function HasOneOfTags(inst,tags)
	if not (inst and inst:IsValid()) then 
		return false 
	end 
	for k,v in pairs(tags) do 
		if inst:HasTag(v) then 
			return true
		end
	end
end 

local function ConfigureRunState(inst)
    local is_ride = (inst.components.rider and inst.components.rider:IsRiding()) 
        or (inst.replica.rider ~= nil and inst.replica.rider:IsRiding())

    if not is_ride then
        if inst:HasTag("gale_speedrun") then 
            inst.sg.statemem.gale_speedrun = true
        end  
    end
   
end

local function GetRunStateAnim(inst)
    local handitem = (inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
     or (inst.replica.inventory and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)) 
    local headitem = (inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD))
     or (inst.replica.inventory and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)) 
    local wearing_hat_bush = headitem and headitem.prefab == "bushhat"

    return (inst.sg.statemem.gale_speedrun and (handitem and "gale_speedrun_withitem" or "gale_speedrun"))
        or "run"
end

local function DoEquipmentFoleySounds(inst)
	local inventory = inst.components.inventory or inst.replica.inventory
	if inventory.equipslots then 
		for k, v in pairs(inventory.equipslots) do
			if v.foleysound ~= nil then
				inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
			end
		end
	end 
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local function PlayWaterSound(inst)
	inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small",nil,nil,true)
end 

local DoRunSounds = function(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

local function GetUnequipState(inst, data)
    return (inst:HasTag("wereplayer") and "item_in")
        or (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in")
        or (data.item ~= nil and data.item:IsValid() and "tool_slip")
        or "toolbroke"
        , data.item
end

AddStategraphPostInit("wilson", function(sg)
	local old_locomote = sg.events["locomote"].fn 
	sg.events["locomote"].fn = function(inst,data)
        if IsFlying(inst) then 
            return old_locomote(inst,data)
        end
		if inst.sg:HasStateTag("busy") then
			return
		end
		local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

		
		if HasOneOfTags(inst,SpecialTags) then 
			if inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or inst.sg:HasStateTag("waking") then

			elseif is_moving and not should_move then
				inst.sg:GoToState("gale_specialrun_stop")
			elseif not is_moving and should_move then
				inst.sg:GoToState("gale_specialrun_start")
			elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
		
			end
		end 

		return old_locomote(inst,data)
	end 
end)

AddStategraphPostInit("wilson_client", function(sg)
	local old_locomote = sg.events["locomote"].fn 
	sg.events["locomote"].fn = function(inst,data)
        if IsFlying(inst) then 
            return old_locomote(inst,data)
        end
		if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
		local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

		if HasOneOfTags(inst,SpecialTags) then 
			if inst:HasTag("sleeping") then

			elseif not inst.entity:CanPredictMovement() then

			elseif is_moving and not should_move then
				inst.sg:GoToState("gale_specialrun_stop")
			elseif not is_moving and should_move then
				inst.sg:GoToState("gale_specialrun_start")
			end
		end 
		
		return old_locomote(inst,data)
	end 
end)

AddStategraphState("wilson", 
	State{
        name = "gale_specialrun_start",
        tags = { "moving","running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            local anim = GetRunStateAnim(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(anim.."_pre")
            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
           TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("gale_specialrun_loop")
                end
            end),
        },
    }
)

AddStategraphState("wilson", 
	State{
        name = "gale_specialrun_loop",
        tags = { "moving","runing" , "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            local anim = GetRunStateAnim(inst)
            if anim == "run" then
                anim = "run_loop"
            elseif anim == "run_werewilba" then
                anim = "run_werewilba_loop"
            elseif anim == "walk" then
                anim = "walk_loop"
            elseif anim == "gale_speedrun" then
                anim = "gale_speedrun_loop"
            elseif anim == "gale_speedrun_withitem" then 
                anim = "gale_speedrun_withitem_loop"
            end
            
            inst.AnimState:PlayAnimation(anim)


            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
			
            --careful
            --Frame 11 shared with heavy lifting below
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.swimming then
					PlayWaterSound(inst)
					DoFoleySounds(inst)
                end
            end),
            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.swimming then
					PlayWaterSound(inst)
					DoFoleySounds(inst)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("gale_specialrun_loop")
        end,

        events = {
            EventHandler("unequip", function(inst, data)
                -- We need to handle this during the initial "busy" frames
                if not inst.sg:HasStateTag("idle") then
                    inst.sg:GoToState(GetUnequipState(inst, data))
                end
            end),
        },
    }
)

AddStategraphState("wilson", 
    State{
        name = "gale_specialrun_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")
            
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }	
)



AddStategraphState("wilson_client", 
	State{
        name = "gale_specialrun_start",
        tags = { "moving" ,"running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            local anim = GetRunStateAnim(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(anim.."_pre")
            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("gale_specialrun_loop")
                end
            end),
        },
    }
)

AddStategraphState("wilson_client", 
	State{
        name = "gale_specialrun_loop",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            local anim = GetRunStateAnim(inst)
            if anim == "gale_speedrun" then
                anim = "gale_speedrun_loop"
            elseif anim == "gale_speedrun_withitem" then 
                anim = "gale_speedrun_withitem_loop"
            end
            
            inst.AnimState:PlayAnimation(anim)

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {

            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

			
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.gale_speedrun then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
			
			TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.swimming then
					PlayWaterSound(inst)
					DoFoleySounds(inst)
                end
            end),
            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.swimming then
					PlayWaterSound(inst)
					DoFoleySounds(inst)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("gale_specialrun_loop")
        end,
    }
)

AddStategraphState("wilson_client", 
    State{
        name = "gale_specialrun_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()

            local anim = GetRunStateAnim(inst)
            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    }	
)