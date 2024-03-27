local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local function DoorCommonClient(inst)
    
end

local function OnSave(inst,data)
    data.key_prefab = inst.key_prefab
    data.enabled = inst.components.teleporter.enabled
    data.direction = inst.direction
    data.style = inst.style 
end

local function OnLoad(inst,data)
    if data then
        if data.key_prefab ~= nil then
            inst.key_prefab = data.key_prefab
        end

        if data.enabled ~= nil then
            inst:SetEnabled(data.enabled,false)
        end

        if data.direction ~= nil then
            inst:SetDirection(data.direction)
        end

        if data.style ~= nil then
            inst.style = data.style
        end
    end
end

local out_offset = {
    north = Vector3(0,0,-1),
    sorth = Vector3(0,0,1),
    west = Vector3(-1,0,0),
    east = Vector3(1,0,0),
}

local function DoorCommonServer(inst)
    inst.direction = "north"

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.SetEnabled = function(inst,enabled,use_sg,not_to_other)
        local old = inst.components.teleporter:IsActive()
        inst.components.teleporter:SetEnabled(enabled)
        local new = inst.components.teleporter:IsActive()

        if use_sg == nil or use_sg == true then
            if not old and new then
                inst.sg:GoToState("opening")
            elseif old and not new then
                inst.sg:GoToState("closing")
            end
        end

        local target = inst.components.teleporter:GetTarget()
        if target and target:IsValid() and not not_to_other then
            target:SetEnabled(enabled,use_sg,true)
        end
    end

    inst.LinkDoor = function(inst,target)
        inst.components.teleporter:Target(target)
        target.components.teleporter:Target(inst)
        local all_enabled = inst.components.teleporter.enabled and target.components.teleporter.enabled
        inst:SetEnabled(all_enabled,false,true)
        target:SetEnabled(all_enabled,false,true)
    end

    inst.SetDirection = function(inst,direction)
        inst.direction = direction
        if inst.direction ~= "south" then
            inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        else
            inst.AnimState:SetLayer( LAYER_WORLD )
        end
    end

    inst.GetOutOffset = function(inst)
        return out_offset[inst.direction] or Vector3(0,0,0)
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.teleporter.enabled then
            return "LOCKED_BY_KEY"
        end
        if not inst.components.teleporter:IsActive() then
            return "CANT_OPEN"
        end
    end

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(function(inst, item, giver)
        return not inst.components.teleporter.enabled and item.prefab == inst.key_prefab
    end)
    inst.components.trader.onaccept = function(inst, giver, item)
        inst:SetEnabled(true)
    end

    inst:AddComponent("teleporter")
    inst.components.teleporter.offset = 0
    inst.components.teleporter.OnDoneTeleporting = function(inst,target)
        local offset = inst:GetOutOffset()
        target.Transform:SetPosition((offset+inst:GetPosition()):Get())
        target:ForceFacePoint((target:GetPosition() + offset):Get())
    end

    inst:AddComponent("savedscale")

    inst:SetDirection("north")
    inst:SetEnabled(true,false)
end

local function ondoerarrive(inst, self, doer)
    if not doer:IsValid() then
        doer = nil
    elseif self.overrideteleportarrivestate ~= nil then
        doer.sg:GoToState(self.overrideteleportarrivestate)
    elseif doer.sg.statemem.teleportarrivestate ~= nil then
        doer.sg:GoToState(doer.sg.statemem.teleportarrivestate)
    end
    self.numteleporting = self.numteleporting - 1
    self:PushDoneTeleporting(doer)
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_house_door",

    assets = {
        Asset("ANIM", "anim/player_house_doors.zip"),
    },

    bank = "player_house_doors",
    build = "player_house_doors",

    tags = {"gale_interior_room_door"},

    clientfn = function(inst)
        DoorCommonClient(inst)

        -- MakeObstaclePhysics(inst,0.2,5)
    end,

    serverfn = function(inst)
        inst.style = "plate"

        DoorCommonServer(inst)

        
        inst.components.teleporter.travelarrivetime = 0.33
        inst.components.teleporter.ReceivePlayer = function(self,doer, source)
            if self.onActivateByOther ~= nil then
                self.onActivateByOther(self.inst, source, doer)
            end
        
            self.numteleporting = self.numteleporting + 1
            self.inst:DoTaskInTime(self.travelarrivetime, ondoerarrive, self, doer)
        end

        inst:SetStateGraph("SGgale_house_door")
    end,
})