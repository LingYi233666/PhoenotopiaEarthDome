local GaleSkillShadowDodge = Class(function(self,inst)
    self.inst = inst

    self._is_dodging = net_bool(inst.GUID,"GaleSkillShadowDodge._is_dodging")

    if not TheNet:IsDedicated() then
        -- Client
        inst._flame1 = SpawnPrefab("gale_phantom_eyes_vfx")
        inst._flame2 = SpawnPrefab("gale_phantom_eyes_vfx")

        inst._flame1.no_point = true 
        inst._flame2.no_point = true 

        inst._flame1.entity:SetParent(inst.entity)
        inst._flame2.entity:SetParent(inst.entity)

        inst._flame1.entity:AddFollower()
        inst._flame2.entity:AddFollower()

        inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",0,0,0)
        inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",0,0,0)

        inst:DoPeriodicTask(0,function()
            if not self._is_dodging:value() then
                inst._flame1.should_emit = false  
                inst._flame2.should_emit = false 
                return 
            end
            local face = inst.Transform:GetFacing()
            if face == 3 then
                inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)

                inst._flame1.should_emit = true 
                inst._flame2.should_emit = true 
            elseif face == 0 then
                inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",10,-50,0.1)
                inst._flame1.should_emit = true 
                inst._flame2.should_emit = false 
            elseif face == 1 then
                inst._flame1.should_emit = false  
                inst._flame2.should_emit = false 
            elseif face == 2 then
                inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",10,-50,0.1)
                inst._flame1.should_emit = true 
                inst._flame2.should_emit = false 
            else 
                inst._flame1.should_emit = false  
                inst._flame2.should_emit = false 
            end
        end)        
    end

    if TheNet:GetIsMasterSimulation() then
        -- Server
        self.last_shadow_time = 0
    end
end)

function GaleSkillShadowDodge:Enable(enable)
    if TheNet:GetIsMasterSimulation() then
        if self.inst.components.health then
            self.inst.components.health:SetInvincible(enable)
        end

        self._is_dodging:set(enable)

        if enable then
            self.inst.AnimState:SetMultColour(0,0,0,1)
        else 
            self.inst.AnimState:SetMultColour(1,1,1,1)
        end
    end
end

function GaleSkillShadowDodge:CoolDone()
    if TheNet:GetIsMasterSimulation() then
        if GetTime() - self.last_shadow_time >= 3.0 then
            self.last_shadow_time = GetTime()
            return true 
        end
    end

    return false 
end

return GaleSkillShadowDodge