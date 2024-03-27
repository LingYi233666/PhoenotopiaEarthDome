local GaleSkillParry = Class(function(self,inst)
    self.inst = inst 

    self._is_parrying = net_bool(inst.GUID,"GaleSkillParry._is_parrying","GaleSkillParry._is_parrying")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("GaleSkillParry._is_parrying",function()
            if self:IsParrying() and not self.task then
                self.task = inst:DoPeriodicTask(0,function()
                    inst:ForceFacePoint(TheInput:GetWorldPosition())
                end)
            elseif not self:IsParrying() and self.task then
                self.task:Cancel()
                self.task = nil 
            end
        end)
    end
end)

function GaleSkillParry:SetIsParrying(val)
    self._is_parrying:set(val)
end

function GaleSkillParry:IsParrying()
    return self._is_parrying:value()
end


return GaleSkillParry