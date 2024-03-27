local GaleLinkedLine = Class(function(self,inst)
    self.inst = inst

    self.targetpos = nil 
end)


function GaleLinkedLine:SetTargetPos(pos)
    self.targetpos = pos 

    self.inst:ForceFacePoint(pos:Get())

    local dist = (self.inst:GetPosition() - pos):Length()

    -- TODO:Calc Scale Facter
    local scale_x = 1.17 * dist
    -- print("dist is",dist)
    self.inst.AnimState:SetScale(scale_x,0.3,1)
end



return GaleLinkedLine