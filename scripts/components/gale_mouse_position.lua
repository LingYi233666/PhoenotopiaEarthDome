local GaleMousePosition = Class(function(self,inst)
    self.inst = inst

    if not TheNet:IsDedicated() then
        self._task = inst:DoPeriodicTask(0.2,function()
            local pos = TheInput:GetWorldPosition()
            local target = TheInput:GetWorldEntityUnderMouse()
            SendModRPCToServer(MOD_RPC["gale_rpc"]["update_mouse_position"],pos.x,pos.y,pos.z)
            SendModRPCToServer(MOD_RPC["gale_rpc"]["update_mouse_entity"],target)
        end)
    else
        self.pos = Vector3(0,0,0)
        self.target = nil 
    end
end)

function GaleMousePosition:SetEntity(tar)
    self.target = tar
end

function GaleMousePosition:GetEntity()
    return self.target
end

function GaleMousePosition:SetPosition(pos)
    self.pos = pos
end

function GaleMousePosition:GetPosition()
    return self.pos
end

return GaleMousePosition