local GaleDreamOreSpawner = Class(function(self, inst)
    self.inst = inst

    self.progress = 0
    self.threshold = 100

    self.check_cd = TUNING.TOTAL_DAY_TIME * 5
end)

function GaleDreamOreSpawner:DoDelta(val)
    self.progress = math.clamp(self.progress + val, 0, self.threshold)
end

function GaleDreamOreSpawner:TrySpawnMeteor()
    local centers = {}
    for i, node in ipairs(TheWorld.topology.nodes) do
        if TheWorld.Map:IsPassableAtPoint(node.x, 0, node.y) and node.type ~= NODE_TYPE.SeparatedRoom then
            table.insert(centers, Vector3(node.x, 0, node.y))
        end
    end

    if #centers == 0 then
        return false
    end

    local pos = centers[math.random(#centers)]

    local meteor = SpawnAt("shadowmeteor", pos)
    meteor:SetSize("large")
    meteor.loot = {
        { prefab = "rocks",          chance = TUNING.METEOR_CHANCE_INVITEM_OFTEN },
        { prefab = "rocks",          chance = TUNING.METEOR_CHANCE_INVITEM_RARE },
        { prefab = "flint",          chance = TUNING.METEOR_CHANCE_INVITEM_ALWAYS },
        { prefab = "flint",          chance = TUNING.METEOR_CHANCE_INVITEM_VERYRARE },
        { prefab = "moonrocknugget", chance = TUNING.METEOR_CHANCE_INVITEM_SOMETIMES },
        { prefab = "moonrocknugget", chance = 1.0 },
    }

    return true
end

function GaleDreamOreSpawner:OnUpdate(dt)
    local speed = 1 / (GetRandomMinMax(1, 2) * TUNING.TOTAL_DAY_TIME)
    self:DoDelta(dt * speed)

    self.check_cd = self.check_cd - dt
    if self.check_cd <= 0 then
        if self.progress >= math.random() * self.threshold then
            if self:TrySpawnMeteor() then
                -- Spawn success, set a long cd
                self.progress = 0
                self.check_cd = GetRandomMinMax(6, 10) * TUNING.TOTAL_DAY_TIME
            else
                -- Spawn failed, set a short cd
                self.check_cd = GetRandomMinMax(0.5, 1) * TUNING.TOTAL_DAY_TIME
            end
        else
            -- Progress not enough, set a normal cd
            self.check_cd = GetRandomMinMax(4, 6) * TUNING.TOTAL_DAY_TIME
        end
    end
end

function GaleDreamOreSpawner:OnSave()
    return {
        progress = self.progress,
        check_cd = self.check_cd,
    }
end

function GaleDreamOreSpawner:OnLoad(data)
    if data ~= nil then
        if data.progress ~= nil then
            self.progress = data.progress
        end
        if data.check_cd ~= nil then
            self.check_cd = data.check_cd
        end
    end
end

function GaleDreamOreSpawner:GetDebugString()
    return string.format("Progress: %.3f/%d, check cd: %d", self.progress, self.threshold, self.check_cd)
end

GaleDreamOreSpawner.OnLongUpdate = GaleDreamOreSpawner.OnUpdate

return GaleDreamOreSpawner
