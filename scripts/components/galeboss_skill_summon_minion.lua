local GaleBossSkillSummonMinion = Class(function(self,inst)
    self.inst = inst

    -- self.tentacle_prefab = "galeboss_dragon_snare_moving_tentacle"
    self.minions = {}
    self.on_minion_spawn = nil 
    self.on_minion_abandon = nil 

    self._on_ent_death = function(ent)
        self:AbandonMinion(ent,"ENTITY_DEATH")
    end

    self._on_ent_remove = function(ent)
        self:AbandonMinion(ent,"ENTITY_REMOVE")
    end

    -- inst:ListenForEvent("death",function()
    --     self:AbandonAllMinion(false)
    -- end)

    -- inst:ListenForEvent("onremove",function()
    --     self:AbandonAllMinion(false)
    -- end)
end)


-- for k,v in pairs(c_findnext("galeboss_dragon_snare").components.dragon_snare_skill_moving_tentacle.minions) do print(k,v) end
-- function GaleBossSkillSummonMinion:Cast()
--     self:AbandonAllMinion(true)

--     local pos = self.inst:GetPosition()
    
--     for i = 1,self.max_num do
--         local offset = FindWalkableOffset(pos,GetRandomMinMax(0,PI * 2),GetRandomMinMax(2,8),15)
--         local ent = self:AddMinion(pos+offset)
--     end
-- end

function GaleBossSkillSummonMinion:IsMyMinion(target)
    return self.minions[target] == true
end

function GaleBossSkillSummonMinion:MinionCount()
    local count = 0
    for ent,_ in pairs(self.minions) do
        count = count + 1
    end

    return count
end

function GaleBossSkillSummonMinion:AddMinion(prefab,pos)
    local ent = SpawnAt(prefab,pos) 

    self:TakeControl(ent)

    if self.inst.components.combat.target then
        ent.components.combat:SetTarget(self.inst.components.combat.target)
    end

    if self.on_minion_spawn then
        self.on_minion_spawn(self.inst,ent)
    end

    self.inst:PushEvent("galeboss_add_minion",{ent = ent})

    return ent 
end

function GaleBossSkillSummonMinion:AbandonMinion(ent,reason,remove_ent)
    if ent and self.minions[ent] then
        self.minions[ent] = nil 
        self.inst:RemoveEventCallback("death",self._on_ent_death,ent)
        self.inst:RemoveEventCallback("onremove",self._on_ent_remove,ent)

        if self.on_minion_abandon then
            self.on_minion_abandon(self.inst,ent)
        end

        self.inst:PushEvent("galeboss_abandon_minion",{ent = ent,reason = reason,remove_ent = remove_ent})

        if remove_ent then
            ent:Remove()
        end
    end
end

function GaleBossSkillSummonMinion:AbandonAllMinion(reason,remove_ent)
    for ent,_ in pairs(self.minions) do
        self:AbandonMinion(ent,reason,remove_ent)
    end
end


function GaleBossSkillSummonMinion:TakeControl(ent)
    if not self.minions[ent] then
        self.minions[ent] = true 

        if ent.components.follower then
            ent.components.follower:SetLeader(self.inst)
        end
    
        self.inst:ListenForEvent("death",self._on_ent_death,ent)
        self.inst:ListenForEvent("onremove",self._on_ent_remove,ent)
    end
end

function GaleBossSkillSummonMinion:OnSave()
    local data = {
        minions = {},
    }
    local references = {}

    for ent,_ in pairs(self.minions) do
        table.insert(data.minions,ent.GUID)
        table.insert(references,ent.GUID)
    end

	return data, references
end

function GaleBossSkillSummonMinion:LoadPostPass(newents, savedata)
    if savedata.minions ~= nil then
        for i, guid in ipairs(savedata.minions) do
            local tentacle = newents[guid]
            if tentacle ~= nil then
                tentacle = tentacle.entity
                self:TakeControl(tentacle)
            end
        end
    end
end


return GaleBossSkillSummonMinion