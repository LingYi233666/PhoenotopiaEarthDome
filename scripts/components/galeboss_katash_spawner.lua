local GalebossKatashSpawner = Class(function(self, inst)
    self.inst = inst
    self.phase = 1
    self.entities = {
        safebox = nil,
        katash = nil,
        -- spaceship = nil,
        -- punchingbag = nil,
        -- firepit = nil,
    }
    self.statemem = {
        box_opened = false,      -- change this in safebox code
        katash_defeated = false, -- use Shard_SyncBossDefeated in galeboss_katash to change this
        katash_returned_from_cave = false,
        katash_dead = false,
    }

    self.OnForestKatashDefeated = function(src)
        if self.phase == self.Phase.BOX_WITH_KATASH then
            print("[GalebossKatashSpawner] katash defeated ! set katash_defeated to true !")
            self.statemem.katash_defeated = true
        end
    end

    self.OnDayPhaseChange = function()
        if self.entities.safebox ~= nil and self.entities.safebox:IsValid() and
            FindClosestPlayerToInst(self.entities.safebox, 66) == nil then
            print("[GalebossKatashSpawner] Day phase change, no player nearby, run TryPushStoryLine()")
            self:TryPushStoryLine()
        end
    end

    inst:ListenForEvent("forest_katash_defeated", self.OnForestKatashDefeated, TheWorld)
    inst:WatchWorldState("phase", self.OnDayPhaseChange)

    inst:DoTaskInTime(FRAMES, function()
        if self.entities.safebox == nil then
            print("[GalebossKatashSpawner] init !")

            local success = false
            for k, v in pairs(Ents) do
                if v.prefab == "galeboss_katash_safebox" then
                    print("Find a", v)
                    self:SetSafeBox(v)
                    success = true
                    break
                end
            end

            -- if not success then
            --     print("[GalebossKatashSpawner] can't find prefabs in world,try create it ?")
            -- end

            if success then
                print("[GalebossKatashSpawner] init success, run TryPushStoryLine()")
                self:TryPushStoryLine()
            else
                print("[GalebossKatashSpawner] init failed !")
            end
        else
            print("[GalebossKatashSpawner] debugstring:")
            print(self:GetDebugString())
        end
    end)
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
--      Update shard

-- local function GenerateBasicResources(count)
--     local loot_presets = {
--         cutgrass = 0.10,
--         twigs = 0.10,
--         log = 0.06,
--         rocks = 0.06,
--         goldnugget = 0.02,
--         gears = 0.01,
--         wagpunk_bits = 0.01,
--     }

--     local result = {}
--     local tab = weighted_random_choices(loot_presets, count)
--     for _, prefab in pairs(tab) do
--         if result[prefab] then
--             result[prefab] = result[prefab] + 1
--         else
--             result[prefab] = 1
--         end
--     end

--     return result
-- end

local function GenerateBasicResources()
    local loot_presets = {
        cutgrass = 0.10,
        twigs = 0.10,
        log = 0.06,
        rocks = 0.06,
        goldnugget = 0.02,
        gears = 0.01,
        wagpunk_bits = 0.01,
    }

    return weighted_random_choice(loot_presets)
end


local box_items = {
    BOX_NORMAL = {
        galeboss_katash_notebook_1 = 1,
        random_resource = 4,
    },
    BOX_WITH_LOCK = {
        gale_ckptfood_dog_cookie = 3,
        galeboss_katash_notebook_2 = 1,
        random_resource = 4,
    },
    BOX_WITH_DRONES = {
        gale_ckptfood_dog_cookie = 2,
        galeboss_katash_notebook_3 = 1,
        random_resource = 4,
    },
    BOX_WITH_KATASH = {

    },
    KATASH_GO_TO_CAVE = {
        galeboss_katash_notebook_4 = 1,
    },
}

local function OnPhaseChange(self, old_phase, new_phase, onload)
    print(string.format("[GalebossKatashSpawner] phase change: %s --> %s%s", phase_preset[old_phase],
        phase_preset[new_phase], onload and " (onload)" or ""))
    print(self:GetDebugString())

    if not onload then
        if box_items[phase_preset[new_phase]] ~= nil then
            print("Giving item at phase", phase_preset[new_phase])
            -- self.entities.safebox.components.container

            self:PopContainerItem(self.entities.safebox, 9, nil, nil, true)

            for prefab, count in pairs(box_items[phase_preset[new_phase]]) do
                for i = 1, count do
                    local item = SpawnAt(prefab == "random_resource" and GenerateBasicResources() or prefab,
                        self.entities.safebox)
                    self.entities.safebox.components.container:GiveItem(item, nil, nil, true)
                end
            end
        end

        if new_phase == self.Phase.BOX_WITH_LOCK then
            -- Lock safe box
            self.entities.safebox:SetLocked(true)
        elseif new_phase == self.Phase.BOX_WITH_DRONES then
            -- Spawn drones
            for i = 1, 10 do
                local pos = self.entities.safebox:GetPosition()

                local offset = FindWalkableOffset(pos, math.random() * TWOPI, GetRandomMinMax(3, 20), 40, nil, false,
                    function(newpos)
                        local ents = TheSim:FindEntities(newpos.x, newpos.y, newpos.z, 3)
                        for _, v in pairs(ents) do
                            if v.prefab == "galeboss_katash_skymine" then
                                return false
                            end

                            if v.Physics and (
                                    v.Physics:GetCollisionGroup() == COLLISION.OBSTACLES or
                                    v.Physics:GetCollisionGroup() == COLLISION.SMALLOBSTACLES) then
                                return false
                            end
                        end

                        return true
                    end, false, false)
                if offset ~= nil then
                    SpawnAt("galeboss_katash_skymine", self.entities.safebox, nil, offset)
                end
            end
        elseif new_phase == self.Phase.KATASH_GO_TO_CAVE then
            -- Announce the shard, make cave katash spawner can spawn katash
            Shard_SyncKatashInCave(true)
        elseif new_phase == self.Phase.KATASH_RETURN_FROM_CAVE then

        end
    end

    -- NOTE: When onload, the shard is not spawned, should find another way to sync...
    -- if new_phase == self.Phase.KATASH_GO_TO_CAVE then
    --     if not TheWorld.shard.components.shard_galeboss_katash_spawner:GetKatashShouldInCave() then
    --         print("Katash should in cave, but the shard not update, so update it.")
    --         print("This should occur in old savefiles.")
    --         Shard_SyncKatashInCave(true)
    --     end
    -- end
end

function GalebossKatashSpawner:SetSafeBox(ent)
    self.entities.safebox = ent
end

function GalebossKatashSpawner:Setkatash(ent)
    assert(ent.prefab == "galeboss_katash")
    self.entities.katash = ent
end

function GalebossKatashSpawner:Spawnkatash(pos, target)
    local katash = SpawnAt("galeboss_katash", pos)
    katash.sg:GoToState("intro_teleportin", { target = target })
    self:Setkatash(katash)
end

function GalebossKatashSpawner:SetPhase(phase, onload)
    assert(phase_preset[phase] ~= nil)
    local old_phase = self.phase
    self.phase = phase


    if old_phase ~= self.phase then
        -- TheWorld:PushEvent("galeboss_katash_spawner_phase_change", { old = old_phase, new = self.phase, onload = onload })

        OnPhaseChange(self, old_phase, self.phase, onload)
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
            local item = ent.components.container.slots[lucky_slot]

            if removed and not item:HasTag("irreplaceable") then
                item = ent.components.container:DropItemBySlot(lucky_slot, pos)
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

                item = ent.components.container:DropItemBySlot(lucky_slot, pos)

                if item ~= nil then
                    success_count = success_count + 1
                end
            end
        else
            break
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

function GalebossKatashSpawner:OnLoad(data)
    if data ~= nil then
        if data.statemem ~= nil then
            self.statemem = deepcopy(data.statemem)
        end

        if data.phase ~= nil then
            self:SetPhase(data.phase, true)
        end
    end
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

    else
        print("TryPushStoryLine() has nothing to do.")
    end
end

function GalebossKatashSpawner:GetDebugString()
    local result = "Phase: " .. phase_preset[self.phase] .. "\nEntities: "
    for name, ent in pairs(self.entities) do
        result = result .. name .. ": " .. tostring(ent) .. "\n"
    end

    result = result .. "Statemem:\n"
    for k, v in pairs(self.statemem) do
        result = result .. k .. ": " .. tostring(v) .. "\n"
    end

    return result
end

return GalebossKatashSpawner
