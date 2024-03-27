local GaleAnatomical = Class(function(self, inst)
    self.inst = inst

    self.loottablenames = {}
    self.dissectsound = "dontstarve/wilson/hit_animal"
end)

function GaleAnatomical:Dissect(dissecter)
    local level = 1
    if dissecter.components.gale_skiller then
        if dissecter.components.gale_skiller:IsLearned("anatomy") then
            level = 2
        end
    end

    local loottablename = self.loottablenames[level]
    if loottablename == nil then
        print("loottablename is", loottablename)
        return false
    end

    if not self.inst.components.lootdropper then
        print("lootdropper is", self.inst.components.lootdropper)

        return false
    end

    self.inst.components.lootdropper:SetChanceLootTable(loottablename)

    if self.dissectsound and dissecter.SoundEmitter then
        dissecter.SoundEmitter:PlaySound(self.dissectsound)
    end

    -- Spawn loots
    local loots = self.inst.components.lootdropper:GenerateLoot()
    local loots_ent = {}
    for k, v in pairs(loots) do
        local loot = SpawnAt(v, dissecter)
        if loot ~= nil then
            table.insert(loots_ent, loot)
        end
    end

    if self.inst.components.stackable then
        self.inst.components.stackable:Get():Remove()
    else
        self.inst:Remove()
    end

    for k, v in pairs(loots_ent) do
        dissecter.components.inventory:GiveItem(v, nil, dissecter:GetPosition())
    end

    return true
end

return GaleAnatomical
