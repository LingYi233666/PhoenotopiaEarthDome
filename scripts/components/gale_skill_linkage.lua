local GaleSkillLinkage = Class(function(self,inst)
    self.inst = inst
    self.ents = {
        -- {target,line_ent,circle_ent},
    }
    self.check_task = nil 
    

    self._on_exit_linkage = function(link_target)
        self:Remove(link_target)
    end

    self._on_target_death = function(link_target)
        link_target:DoTaskInTime(GetRandomMinMax(1,2),function()
            if inst:IsValid() then
                self:Remove(link_target)
            end
        end)
    end

    self._on_target_attacked = function(link_target,data)
        if data.attacker and data.damage > 0 and not data.redirected and data.stimuli ~= "gale_skill_linkage" then
            local ents_copy = {}
            for k,v in pairs(self.ents) do
                if v[1].components.combat and not IsEntityDeadOrGhost(v[1],true) then
                    table.insert(ents_copy,v[1])
                end
                
            end

            -- self:RemoveMany(ents_copy)

            for k,v in pairs(ents_copy) do
                v:DoTaskInTime(GetRandomMinMax(1,2),function()
                    if v ~= link_target and v.components.combat and data.attacker:IsValid() then
                        SpawnAt("gale_skill_linkage_puff",v,v:HasTag("largecreature") and Vector3(1.3,1.3,1.3) or Vector3(0.8,0.8,0.8))
                        v.components.combat:GetAttacked(data.attacker,data.damage,nil,"gale_skill_linkage")
                    end

                    if inst:IsValid() then
                        self:Remove(v)
                    end
                end)
            end
        end
    end

    self._on_target_sleep_or_grog = function(link_target)
        local ents_copy = {}
        for k,v in pairs(self.ents) do
            if (v[1].components.sleeper or v[1].components.grogginess) and not IsEntityDeadOrGhost(v[1],true) then
                table.insert(ents_copy,v[1])
            end
        end

        -- self:RemoveMany(ents_copy)

        for k,v in pairs(ents_copy) do
            v:DoTaskInTime(GetRandomMinMax(1,2),function()
                if v ~= link_target
                    and not (v.components.sleeper and v.components.sleeper:IsAsleep())
                    and not (v.components.grogginess and v.components.grogginess:IsKnockedOut()) then

                    local sleeptime = 10
                    local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil 
                    if mount ~= nil then
                        mount:PushEvent("ridersleep", { sleepiness = 7, sleeptime = sleeptime + math.random() })
                    end
                    if v:HasTag("player") then
                        v:PushEvent("yawn", { grogginess = 4, knockoutduration = sleeptime + math.random() })
                    elseif v.components.sleeper ~= nil then
                        v.components.sleeper:AddSleepiness(7, sleeptime + math.random())
                    elseif v.components.grogginess ~= nil then
                        v.components.grogginess:AddGrogginess(4, sleeptime + math.random())
                    else
                        v:PushEvent("knockedout")
                    end
                    SpawnAt("gale_skill_linkage_puff",v,v:HasTag("largecreature") and Vector3(1.3,1.3,1.3) or Vector3(0.8,0.8,0.8))
                end

                if inst:IsValid() then
                    self:Remove(v)
                end
            end)
        end
    end


    inst:ListenForEvent("death",function()
        self:RemoveAll()
    end)

    inst:ListenForEvent("onremove",function()
        self:RemoveAll()
    end)

    inst:ListenForEvent("playerdeactivated",function()
        self:RemoveAll()
    end)
end)

function GaleSkillLinkage:IsLinked(target)
    for k,v in pairs(self.ents) do
        if v[1] == target then
            return true 
        end 
    end 
end

function GaleSkillLinkage:Add(target)
    if self:IsLinked(target) then
        return 
    end

    self.inst.SoundEmitter:PlaySound("gale_sfx/skill/linkage")

    table.insert(self.ents,{
        target,
        nil,
        target:SpawnChild("gale_skill_linkage_circle"),
    })

    if target:HasTag("largecreature") then
        self.ents[#self.ents][3].Transform:SetScale(1,1,1)
    end

    if #self.ents >= 2 then
        local pre_tail = self.ents[#self.ents-1]
        pre_tail[2] = pre_tail[1]:SpawnChild("gale_skill_linkage_line_vfx")
        pre_tail[2].TargetEntity:set(target)
    end

    self.inst:ListenForEvent("death",self._on_target_death,target)
    self.inst:ListenForEvent("onremove",self._on_exit_linkage,target)
    self.inst:ListenForEvent("attacked",self._on_target_attacked,target)
    self.inst:ListenForEvent("gotosleep",self._on_target_sleep_or_grog,target)
    self.inst:ListenForEvent("knockedout",self._on_target_sleep_or_grog,target)

    if not self.check_task then
        self.check_task = self.inst:DoPeriodicTask(0,function()
            local ents_no = {}
            for k,v in pairs(self.ents) do
                if not (v[1] and v[1]:IsValid() and self.inst:IsNear(v[1],33)) then
                    table.insert(ents_no,v[1])
                end
            end

            self:RemoveMany(ents_no)
        end)
    end
end

function GaleSkillLinkage:Remove(target)
    local target_index = nil 
    for k,v in pairs(self.ents) do
        if v[1] == target then
            target_index = k 
            break 
        end
    end

    if target_index == nil then
        return 
    end
    
    local removed = table.remove(self.ents,target_index)
    if removed[2] then
        removed[2]:Remove()
    end
    if removed[3] then
        removed[3]:Remove()
    end
    

    -- TODO: Set line from target_index-1 and target_index
    if target_index - 1 >= 1 then
        if target_index <= #self.ents then
            self.ents[target_index - 1][2].TargetEntity:set(self.ents[target_index][1])
        else 
            self.ents[target_index - 1][2]:Remove()
            self.ents[target_index - 1][2] = nil 
        end
    end

    self.inst:RemoveEventCallback("death",self._on_target_death,target)
    self.inst:RemoveEventCallback("onremove",self._on_exit_linkage,target)
    self.inst:RemoveEventCallback("attacked",self._on_target_attacked,target)
    self.inst:RemoveEventCallback("gotosleep",self._on_target_sleep_or_grog,target)
    self.inst:RemoveEventCallback("knockedout",self._on_target_sleep_or_grog,target)

    if self.check_task and #self.ents <= 0 then
        self.check_task:Cancel()
        self.check_task = nil 
    end
end

function GaleSkillLinkage:RemoveMany(target_list)
    for _,v in pairs(target_list) do
        self:Remove(v)
    end
end

function GaleSkillLinkage:RemoveAll()
    while #self.ents > 0 do
        local target = self.ents[1][1]
        self:Remove(target)
    end
end

return GaleSkillLinkage