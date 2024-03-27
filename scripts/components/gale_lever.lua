local function ondirection(self,direction)
    if direction == 0 then
        self.inst:AddTag("gale_lever_direction_zero")
    else 
        self.inst:RemoveTag("gale_lever_direction_zero")
    end
end

local GaleLever = Class(function(self,inst)
    self.inst = inst

    self.on_direction_change = nil 

    self.direction = 0
    self.possible_directions = {-1,0,1}

    inst:AddTag("gale_lever")
end,nil,{
    direction = ondirection
})

function GaleLever:GetDirection()
    return self.direction
end

function GaleLever:IsZeroDirection()
    return self.direction == 0
end

function GaleLever:SetDirection(direction,immediate)
    local old_direction = self.direction
    self.direction = direction

    if self.on_direction_change then
        self.on_direction_change(self.inst,old_direction,direction,immediate)
    end

    self.inst:PushEvent("gale_lever_direction_change",{
        old_direction = old_direction,
        direction = direction,
        immediate = immediate,
    })
end

function GaleLever:OnSave()
    return {
        direction = self.direction
    }
end

function GaleLever:OnLoad(data)
    if data ~= nil then
        if data.direction ~= nil then
            self:SetDirection(data.direction,true)
        end
    end
end

return GaleLever