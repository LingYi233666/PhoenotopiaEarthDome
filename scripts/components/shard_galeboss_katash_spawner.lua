local GalebossKatashSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "galeboss_katash_spawner_shared should not exist on a client.")

    self.inst = inst

    self.katash_should_in_cave = net_bool(inst.GUID, "GalebossKatashSpawner.katash_should_in_cave",
        "katash_should_in_cave_dirty")

    inst:ListenForEvent("katash_should_in_cave_dirty", function()
        print(string.format("katash_should_in_cave_dirty%s: %s", TheWorld.ismastershard and "(mastershard)" or "",
            tostring(self:GetKatashShouldInCave())))
    end)

    if TheWorld.ismastershard then
        function self:OnSave()
            return {
                katash_should_in_cave = self:GetKatashShouldInCave(),
            }
        end

        function self:OnLoad(data)
            if data == nil then
                return
            end

            self:SetKatashShouldInCave(data.katash_should_in_cave)
        end
    end
end)

function GalebossKatashSpawner:SetKatashShouldInCave(val)
    self.katash_should_in_cave:set(val)
end

function GalebossKatashSpawner:GetKatashShouldInCave()
    return self.katash_should_in_cave:value()
end

return GalebossKatashSpawner
