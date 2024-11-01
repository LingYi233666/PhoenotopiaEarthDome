local GalebossKatashSpawner = Class(function(self, inst)
    self.inst = inst

    self.katash = nil
    self.camp_entrance = nil
    self.camp_exit = nil

    inst:DoTaskInTime(FRAMES, function()
        if self.camp_entrance == nil or self.camp_exit == nil then
            self:Init()
        end
    end)



    self.OnCavePhaseChange = function()
        -- if self.entities.safebox ~= nil and self.entities.safebox:IsValid() and
        --     FindClosestPlayerToInst(self.entities.safebox, 66) == nil then
        --     print("[GalebossKatashSpawner] Day phase change, no player nearby, run TryPushStoryLine()")
        --     self:TryPushStoryLine()
        -- end
    end

    inst:WatchWorldState("phase", self.OnCavePhaseChange)
end)

function GalebossKatashSpawner:Init()

end

function GalebossKatashSpawner:TryPushStoryLine()
    local should_in_cave = TheWorld.shard.components.shard_galeboss_katash_spawner:GetKatashShouldInCave()

    if should_in_cave and self.katash == nil then
        -- TODO: Spawn katash, enable camp entrance
    end
end

return GalebossKatashSpawner
