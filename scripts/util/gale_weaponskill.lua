
local function ReticuleTargetFnPoint()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end


local function ReticuleTargetFnLine()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFnLine(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFnLine(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end

local function AddAoetargetingClient(inst,aoetype,tags,range,extrafn)
	range = range or 8 
	
	if tags then 
		for k,v in pairs(tags) do 
			inst:AddTag(v)
		end
	end 
	inst:AddTag("rechargeable")
	
	inst:AddComponent("aoetargeting")
	inst.components.aoetargeting.range = range
	inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
	inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
	inst.components.aoetargeting.reticule.ease = true
	inst.components.aoetargeting.reticule.mouseenabled = true
	
	if aoetype == "point" then 
		inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
		inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
		inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFnPoint
	elseif aoetype == "line" then 
		inst.components.aoetargeting:SetAlwaysValid(true)
		inst.components.aoetargeting.reticule.reticuleprefab = "reticulelongmulti"
		inst.components.aoetargeting.reticule.pingprefab = "reticulelongmultiping"
		inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFnLine
		inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFnLine
		inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFnLine
	elseif aoetype == "parry" then 
		inst.components.aoetargeting:SetAlwaysValid(true)
		inst.components.aoetargeting.reticule.reticuleprefab = "reticulearc"
		inst.components.aoetargeting.reticule.pingprefab = "reticulearcping"
		inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFnLine
		inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFnLine
		inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFnLine
	else
		inst.components.aoetargeting:SetAlwaysValid(true)
		inst.components.aoetargeting.reticule.reticuleprefab = ""
		inst.components.aoetargeting.reticule.pingprefab = ""
		inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFnLine
		inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFnLine
		inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFnLine
	end 
	
	if extrafn then
		extrafn(inst) 
	end
end 

local function AddAoetargetingServer(inst,oncastfn,ondischarged,oncharged,extrafn)	
	inst:AddComponent("rechargeable")
	inst.components.rechargeable:SetOnDischargedFn(function()
		if inst.components.aoetargeting then
			inst.components.aoetargeting:SetEnabled(false)
		end

		if ondischarged then
			ondischarged(inst)
		end
		
	end)
	inst.components.rechargeable:SetOnChargedFn(function()
		if inst.components.aoetargeting then
			inst.components.aoetargeting:SetEnabled(true)
		end

		if oncharged then
			oncharged(inst)
		end
	end)
	
	inst:AddComponent("gale_aoespell")
	inst.components.gale_aoespell:SetOnCastFn(oncastfn)
	inst.components.aoespell = inst.components.gale_aoespell
	inst:RegisterComponentActions("aoespell")
	
	if extrafn then
		extrafn(inst) 
	end
end 


return {
	AddAoetargetingClient = AddAoetargetingClient,
	AddAoetargetingServer = AddAoetargetingServer,
}