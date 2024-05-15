local GalebossKatashSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "galeboss_katash_spawner_shared should not exist on a client.")

    self.inst = inst

    self.katash_should_in_cave = net_bool(inst.GUID, "GalebossKatashSpawner.katash_should_in_cave",
        "katash_should_in_cave_dirty")

    inst:ListenForEvent("katash_should_in_cave_dirty", function()
        print(string.format("katash_should_in_cave_dirty%s: %s", TheWorld.ismastershard and "(mastershard)" or "",
            tostring(self:GetKatashShouldInCave())))
    end)
end)

function GalebossKatashSpawner:SetKatashShouldInCave(val)
    self.katash_should_in_cave:set(val)
end

function GalebossKatashSpawner:GetKatashShouldInCave(val)
    return self.katash_should_in_cave:value()
end

return GalebossKatashSpawner
