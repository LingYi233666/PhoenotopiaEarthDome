local TreasureLootTable = require("util/athetos_treasure_loottable")

local AthetosTreasureSpawner = Class(function(self, inst)
    self.inst = inst

    self.init_spawn_finished = false
    self.treasures = {}

    self.loot_table_keys = {}

    self:RefreshLootTableKeys()

    self.inst:DoTaskInTime(FRAMES, function()
        if not self.init_spawn_finished then
            self:DoInitSpawn()
            self.init_spawn_finished = true
        end
    end)

    -- print("test_tab.....")
    -- local test_tab = {}
    -- for k,v in pairs(TreasureLootTable) do
    --     if v.loot then
    --         for prefab, n in pairs(v.loot) do
    --             test_tab[prefab] = true
    --         end
    --     end

    --     if v.random_loot then
    --         for prefab, n in pairs(v.random_loot) do
    --             test_tab[prefab] = true
    --         end
    --     end

    --     if v.chance_loot then
    --         for prefab, n in pairs(v.chance_loot) do
    --             test_tab[prefab] = true
    --         end
    --     end
    -- end

    -- local print_str = ""
    -- for prefab,_ in pairs(test_tab) do
    --     if STRINGS.NAMES[prefab:upper()] == nil then
    --         -- print("Can't find:",prefab)
    --         print_str = print_str..prefab..",\n"
    --     else
    --         -- print(prefab,"is",STRINGS.NAMES[prefab:upper()])
    --     end
    -- end
    -- print("Invalid prefabs:",print_str)
end)

function AthetosTreasureSpawner:DeleteAllTreasure()
    for _, v in pairs(self.treasures) do
        if v.IsValid and v:IsValid() and v:HasTag("athetos_treasure") then
            v:Remove()
        end
    end
    self.treasures = {}
end

function AthetosTreasureSpawner:RefreshLootTableKeys()
    self.loot_table_keys = {}
    for k, v in pairs(TreasureLootTable) do
        local repeat_cnt = v.count or 1
        for i = 1, repeat_cnt do
            table.insert(self.loot_table_keys, k)
        end
    end

    shuffleArray(self.loot_table_keys)
end

function AthetosTreasureSpawner:SetLootListForTreasure(loottab, treasure)
    local lootlist = {}
    if loottab.loot then
        for prefab, n in pairs(loottab.loot) do
            if lootlist[prefab] == nil then
                lootlist[prefab] = 0
            end
            lootlist[prefab] = lootlist[prefab] + n
        end
    end
    if loottab.random_loot then
        -- for i = 1, (loottab.num_random_loot or 1), 1 do
        --     local prefab = weighted_random_choice(loottab.random_loot)
        --     if prefab then
        --         if lootlist[prefab] == nil then
        --             lootlist[prefab] = 0
        --         end
        --         lootlist[prefab] = lootlist[prefab] + 1
        --     end
        -- end

        for _, prefab in pairs(weighted_random_choices(loottab.random_loot, loottab.num_random_loot or 1)) do
            if lootlist[prefab] == nil then
                lootlist[prefab] = 0
            end
            lootlist[prefab] = lootlist[prefab] + 1
        end
    end
    if loottab.chance_loot then
        for prefab, chance in pairs(loottab.chance_loot) do
            if math.random() < chance then
                if lootlist[prefab] == nil then
                    lootlist[prefab] = 0
                end
                lootlist[prefab] = lootlist[prefab] + 1
            end
        end
    end
    if loottab.custom_lootfn then
        loottab.custom_lootfn(lootlist)
    end

    treasure.loot_list = {}

    for name, num in pairs(lootlist) do
        table.insert(treasure.loot_list, { name, num })
    end
end

-- local function GetTreasureNearBy(x,y,z,rad)
--     return TheSim:FindEntities(x,y,z,rad,{"athetos_treasure"})
-- end

local function GetVoxelCellIndex(point, voxel_size)
    local x = math.floor(point.x / voxel_size)
    local y = math.floor(point.y / voxel_size)
    local z = math.floor(point.z / voxel_size)
    return bit.lshift(x, 42) + bit.lshift(y, 21) + z
end

-- print(#TheWorld.components.athetos_treasure_spawner:GetTreasuresWithItem("athetos_psychostatic_cutter"))
function AthetosTreasureSpawner:GetTreasuresWithItem(itemname)
    local results = {}
    for _, treasure in pairs(self.treasures) do
        for _, v in pairs(treasure.loot_list) do
            local name, num = v[1], v[2]
            if name == itemname then
                table.insert(results, treasure)
            end
        end
    end

    return results
end

-- TheWorld.components.athetos_treasure_spawner:GotoTreasuresWithItem(ThePlayer,"athetos_psychostatic_cutter")
function AthetosTreasureSpawner:GotoTreasuresWithItem(player, itemname)
    for _, treasure in pairs(self.treasures) do
        for _, v in pairs(treasure.loot_list) do
            local name, num = v[1], v[2]
            if name == itemname then
                player.Transform:SetPosition(treasure:GetPosition():Get())
                return
            end
        end
    end
end

function AthetosTreasureSpawner:IsValidPos(pos)
    local x, y, z = pos:Get()

    if not TheWorld.Map:IsPassableAtPoint(x, 0, z, true, true) or TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil then
        return false
    end

    local ents = TheSim:FindEntities(x, 0, z, 4, nil, { "NOBLOCK", "FX", "INLIMBO" })

    if #ents > 0 then
        return false
    end

    return true
end

-- TheWorld.components.athetos_treasure_spawner:DoInitSpawn()
-- TheWorld.components.athetos_treasure_spawner:DeleteAllTreasure()
-- for k,v in pairs(TheWorld.components.athetos_treasure_spawner.treasures) do ThePlayer.player_classified.MapExplorer:RevealArea(v:GetPosition():Get()) end
function AthetosTreasureSpawner:DoInitSpawn()
    local cand_points = {}
    local voxel_size = 100

    local success_cnt = 0
    local map_x, map_y = TheWorld.Map:GetWorldSize()
    map_x = map_x * TILE_SCALE / 2
    map_y = map_y * TILE_SCALE / 2

    while success_cnt < #self.loot_table_keys do
        local pos = Vector3(GetRandomMinMax(-map_x, map_x), 0, GetRandomMinMax(-map_y, map_y))

        if self:IsValidPos(pos) then
            local voxel_id = GetVoxelCellIndex(pos, voxel_size)

            if cand_points[voxel_id] == nil then
                cand_points[voxel_id] = { 1, pos }
                success_cnt = success_cnt + 1
            else
                cand_points[voxel_id][1] = cand_points[voxel_id][1] + 1
                if math.random() < (1 / cand_points[voxel_id][1]) then
                    cand_points[voxel_id][2] = pos
                end
                -- cand_points[voxel_id][2] = cand_points[voxel_id][2] + pos
            end
        end
    end


    for _, v in pairs(cand_points) do
        local pos = v[2]
        local prefab = nil
        if TheWorld.Map:IsOceanAtPoint(pos.x, 0, pos.z) then
            prefab = "athetos_hidden_treasure_seastack"
        else
            prefab = GetRandomItem({
                "athetos_hidden_treasure_tree",
                "athetos_hidden_treasure_sapling",
                "athetos_hidden_treasure_rock_flintless",
            })
        end

        print(string.format("Generate at %s with %s", tostring(pos), prefab))

        local treasure = SpawnAt(prefab, pos)

        if #self.loot_table_keys <= 0 then
            self:RefreshLootTableKeys()
        end

        local loot_key = table.remove(self.loot_table_keys, 1)
        if TreasureLootTable[loot_key] == nil then
            self:RefreshLootTableKeys()
            loot_key = table.remove(self.loot_table_keys, 1)
        end
        self:SetLootListForTreasure(TreasureLootTable[loot_key], treasure)


        table.insert(self.treasures, treasure)
    end

    print("Treasure gen done,count:", #self.treasures)
end

function AthetosTreasureSpawner:OnSave()
    local data = {
        init_spawn_finished = self.init_spawn_finished,
        loot_table_keys = self.loot_table_keys,
        treasure_GUIDs = {}
    }
    local references = {}

    for k, v in pairs(self.treasures) do
        if v:IsValid() then
            table.insert(data.treasure_GUIDs, v.GUID)
            table.insert(references, v.GUID)
        end
    end

    return data, references
end

function AthetosTreasureSpawner:OnLoad(data)
    if data ~= nil then
        if data.init_spawn_finished ~= nil then
            self.init_spawn_finished = data.init_spawn_finished
        end

        if data.loot_table_keys ~= nil then
            self.loot_table_keys = data.loot_table_keys
        end
    end
end

function AthetosTreasureSpawner:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        if savedata.treasure_GUIDs ~= nil then
            for _, guid in pairs(savedata.treasure_GUIDs) do
                local new_ent = newents[guid]
                if new_ent then
                    table.insert(self.treasures, new_ent.entity)
                end
            end
        end
    end
end

return AthetosTreasureSpawner
