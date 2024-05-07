local GalebossKatashSpawner = Class(function(self, inst)
    self.inst = inst
    self.phase = 1
    self.entities = {
        safebox = nil,
        katash = nil,
    }
    self.statemem = {
        box_opened = false,      -- change this in safebox entity code
        katash_defeated = false, -- use Shard_SyncBossDefeated in galeboss_katash to change this
        katash_returned_from_cave = false,
        katash_dead = false,
    }

    self.OnForestKatashDefeated = function(src, data)
        if data == nil then
            return
        end

        if data.bossprefab == "galeboss_katash" and self.phase == self.Phase.BOX_WITH_KATASH then
            self.statemem.katash_defeated = true
        end
    end

    inst:ListenForEvent("master_shardbossdefeated", self.OnForestKatashDefeated, TheWorld)
end)

local phase_preset = {
    "NONE",
    "BOX_NORMAL",
    "BOX_WITH_LOCK",
    "BOX_WITH_DRONES",
    "BOX_WITH_KATASH",
    "KATASH_GO_TO_CAVE",
    "KATASH_RETURN_FROM_CAVE",
    "KATASH_DEAD",
}
-- key: name, value: number
GalebossKatashSpawner.Phase = table.invert(phase_preset)
-- for _, name in pairs(phase_preset) do
--     GalebossKatashSpawner.Phase[name] = name
-- end


function GalebossKatashSpawner:SetSafeBox(ent)
    self.entities.safebox = ent
end

function GalebossKatashSpawner:Setkatash(ent)
    assert(ent.prefab == "galeboss_katash")
    self.entities.katash = ent
end

function GalebossKatashSpawner:Spawnkatash(pos)
    local katash = SpawnAt("galeboss_katash", pos)
    self:Setkatash(katash)
end

function GalebossKatashSpawner:SetPhase(phase, onload)
    assert(phase_preset[phase] ~= nil)
    local old_phase = self.phase
    self.phase = phase

    -- What should we do when galeboss_katash_spawner_phase_change triggered ?
    -- safebox:
    --  BOX_NORMAL:
    --      Init container storage: dogfoodx3, notebook, random basic resources and tools.
    --  BOX_WITH_LOCK:
    --      Init container storage: dogfoodx2, notebook, random basic resources and tools.
    --      Lock safebox.
    --  BOX_WITH_DRONES:
    --      Init container storage: dogfoodx2, notebook, random basic resources and tools.
    --      Lock safebox.
    --      Init drones.
    --  BOX_WITH_KATASH:
    --      When opened, spawn a bomb and summon katash.
    --  KATASH_GO_TO_CAVE:
    --      Init container storage: notebook.
    if old_phase ~= self.phase then
        -- TheWorld:PushEvent("galeboss_katash_spawner_phase_change", { old = old_phase, new = self.phase, onload = onload })
        if not onload then

        end
    end
end

function GalebossKatashSpawner:PopContainerItem(ent, count, must_drop_prefabs, cant_drop_prefabs, removed)
    local success_count = 0
    for i = 1, count do
        local valid_slot_ids = {}
        for slotid, item in pairs(ent.components.container.slots) do
            if item
                and (cant_drop_prefabs == nil or not table.contains(cant_drop_prefabs, item.prefab))
                and (must_drop_prefabs == nil or table.contains(must_drop_prefabs, item.prefab)) then
                table.insert(valid_slot_ids, slotid)
            end
        end
        if #valid_slot_ids > 0 then
            local lucky_slot = GetRandomItem(valid_slot_ids)
            local pos = ent:GetPosition()

            if removed then
                local item = ent.components.container:DropItemBySlot(lucky_slot, pos)
                if item ~= nil then
                    item:Remove()
                    success_count = success_count + 1
                end
            else
                for radius = 30, 50 do
                    local offset = FindWalkableOffset(ent:GetPosition(), math.random() * TWOPI, radius, 5,
                        nil, false, nil, true, true)
                    if offset then
                        pos = pos + offset
                        break
                    end
                end

                local item = ent.components.container:DropItemBySlot(lucky_slot, pos)

                if item ~= nil then
                    success_count = success_count + 1
                end
            end
        end
    end

    return success_count
end

function GalebossKatashSpawner:OnSave()
    local ents = {}
    local refs = {}

    for k, v in pairs(self.entities) do
        if v ~= nil and v:IsValid() then
            table.insert(ents, { name = k, GUID = v.GUID })
            table.insert(refs, v.GUID)
        end
    end

    local data = {
        entities = ents,
        phase = self.phase,
        statemem = self.statemem,
    }

    return data, refs
end

function GalebossKatashSpawner:LoadPostPass(ents, data)
    if data.entities ~= nil then
        for i, v in ipairs(data.entities) do
            local ent = ents[v.GUID]
            if ent ~= nil then
                if v.name == "safebox" then
                    self:SetSafeBox(ent.entity)
                end

                if v.name == "katash" then
                    self:Setkatash(ent.entity)
                end
            end
        end
    end

    if data.statemem ~= nil then
        self.statemem = deepcopy(data.statemem)
    end

    if data.phase ~= nil then
        self:SetPhase(self.phase, true)
    end
end

function GalebossKatashSpawner:TryPushStoryLine()
    if self.phase == self.Phase.NONE then
        if self.entities.safebox ~= nil and self.entities.safebox:IsValid() then
            self.statemem.box_opened = false
            self:SetPhase(self.phase + 1)
        end
    elseif self.Phase.BOX_NORMAL <= self.phase and self.phase <= self.Phase.BOX_WITH_DRONES then
        if self.statemem.box_opened and not TheWorld.components.timer:TimerExists("galeboss_katash_spawner_phase_cd") then
            self.statemem.box_opened = false
            self:SetPhase(self.phase + 1)

            TheWorld.components.timer:StartTimer("galeboss_katash_spawner_phase_cd",
                TUNING.TOTAL_DAY_TIME * GetRandomMinMax(1, 1.5))
        end
    elseif self.phase == self.Phase.BOX_WITH_KATASH then
        if self.statemem.katash_defeated then
            self:SetPhase(self.phase + 1)
        end
    elseif self.phase == self.Phase.KATASH_GO_TO_CAVE then
        if self.statemem.katash_dead then
            self:SetPhase(self.Phase.KATASH_DEAD)
        elseif self.statemem.katash_returned_from_cave then
            self:SetPhase(self.Phase.KATASH_RETURN_FROM_CAVE)
        end
    elseif self.phase == self.Phase.KATASH_RETURN_FROM_CAVE then
        if self.statemem.katash_dead then
            self:SetPhase(self.Phase.KATASH_DEAD)
        end
    elseif self.phase == self.Phase.KATASH_DEAD then

    end
end

function GalebossKatashSpawner:GetDebugString()
    local result = "Phase: " .. phase_preset[self.phase] .. ". Entities: "
    for name, ent in pairs(self.entities) do
        result = result .. name .. ": " .. tostring(ent) .. ", "
    end

    result = result + ". Statemem: "
    for k, v in pairs(self.statemem) do
        result = result .. k .. ": " .. tostring(v) .. ","
    end

    return result
end

return GalebossKatashSpawner
