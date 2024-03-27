local GaleBossRuinforceSpawner = Class(function(self,inst)
    self.inst = inst 

    self.spawn_cnt = 0
    self.spawn_delay = nil 
    self.pending_task = nil 
    self.try_spawn_task = nil 

    self.inst:WatchWorldState("phase",function()
        if self.try_spawn_task then
            self.try_spawn_task:Cancel()
        end

        self.try_spawn_task = self.inst:DoTaskInTime(GetRandomMinMax(12,14),function()
            self:TrySpawn()
            self.try_spawn_task = nil 
        end)
        
        -- print("Check phase:",TheWorld.state.phase)
    end)
end)

-- function GaleBossRuinforceSpawner:CheckCanSpawn()
    
-- end

-- function GaleBossRuinforceSpawner()
    
-- end

-- TheWorld.components.galeboss_ruinforce_spawner:SpawnAt(ThePlayer,30)
-- TheWorld.components.galeboss_ruinforce_spawner.spawn_cnt = 0
-- print(TheWorld.components.galeboss_ruinforce_spawner.spawn_cnt)
function GaleBossRuinforceSpawner:TrySpawn()
    if self.spawn_cnt < 1
        and self.pending_task == nil 
        and TheWorld.state.isautumn 
        and (TheWorld.state.isdusk or TheWorld.state.isnight)
        and TheWorld.state.remainingdaysinseason <= GetRandomMinMax(3,5) then
        
        for k,v in pairs(AllPlayers) do
            if self:IsValidPlayer(v) then
                self:SpawnAt(v,GetRandomMinMax(50,65))
                break 
            end
        end
    end
end

function GaleBossRuinforceSpawner:IsValidPlayer(player)
    return player and player:IsValid() and not IsEntityDeadOrGhost(player,true) and not player:GetCurrentPlatform()
end

function GaleBossRuinforceSpawner:SpawnAt(player,delay)
    if not (self:IsValidPlayer(player)) then
        self.spawn_delay = nil 
        if self.pending_task then
            self.pending_task:Cancel()
            self.pending_task = nil 
        end

        return 
    end

    if delay == nil or delay < 0 then
        local offset = FindWalkableOffset(player:GetPosition(),
                                          math.random() * 360,
                                          GetRandomMinMax(30,40),
                                          25,
                                          nil,
                                          true,
                                          nil,
                                          false,
                                          false)

        if offset then
            local metal_gear = SpawnAt("galeboss_ruinforce",player,nil,offset) 
            metal_gear.components.combat:SetTarget(player)

            local player_nearby = FindWalkableOffset(player:GetPosition(),
                                    math.random() * 360,
                                    GetRandomMinMax(5,8),
                                    25,
                                    nil,
                                    true,
                                    nil,
                                    false,
                                    false)

            metal_gear.sg:GoToState("superjump",{
                target_pos = player:GetPosition() + (player_nearby or Vector3(0,0,0)),
                warning = true,
            })

        else 
            local player_nearby = FindWalkableOffset(player:GetPosition(),
                                    math.random() * 360,
                                    GetRandomMinMax(5,8),
                                    25,
                                    nil,
                                    true,
                                    nil,
                                    false,
                                    false)
            local metal_gear = SpawnAt("galeboss_ruinforce",player,nil,player_nearby) 
            metal_gear.components.combat:SetTarget(player)
            metal_gear.sg:GoToState("superland",player:GetPosition() + (player_nearby or Vector3(0,0,0)))
        end

        self.spawn_cnt = self.spawn_cnt + 1
        self.spawn_delay = nil 
        if self.pending_task then
            self.pending_task:Cancel()
            self.pending_task = nil 
        end
    else 
        self.spawn_delay = delay

        local duration = 1
        if self.spawn_delay > 20 then
            for _,v in pairs(AllPlayers) do
                if v:IsNear(player,66) then
                    SpawnAt("galeboss_ruinforce_warnings_low",v):SetPlayer(v)
                end
            end
            
            duration = GetRandomMinMax(6,8)
        elseif self.spawn_delay > 5 then
            for _,v in pairs(AllPlayers) do
                if v:IsNear(player,66) then
                    SpawnAt("galeboss_ruinforce_warnings_high",v):SetPlayer(v)
                end
            end
            duration = GetRandomMinMax(5,6)
        elseif self.spawn_delay > 3 then
            duration = 1
        else
            ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .01, 0.1, player, 10)
            SpawnAt("galeboss_ruinforce_warnings_step",player):SetPlayer(player)
            duration = 1
        end

        if self.pending_task then
            self.pending_task:Cancel()
        end
        self.pending_task = self.inst:DoTaskInTime(duration,function()
            self:SpawnAt(player,delay - duration)
        end)
    end
end

function GaleBossRuinforceSpawner:OnSave()
    return {
        spawn_cnt = self.spawn_cnt,
    }
end

function GaleBossRuinforceSpawner:OnLoad(data)
    if data ~= nil then
        if data.spawn_cnt ~= nil then
            self.spawn_cnt = data.spawn_cnt
        end
    end
end

return GaleBossRuinforceSpawner