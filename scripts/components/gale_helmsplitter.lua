local GaleHelmsplitter = Class(function(self, inst)
    self.inst = inst

    self.onstartfn = nil
    self.onstopfn = nil
    self.oncastfn = nil
end)

function GaleHelmsplitter:StartHelmSplitting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstartfn and self.onstartfn(self.inst, owner)
end

function GaleHelmsplitter:StopHelmSplitting()
    local owner = self.inst.components.equippable:IsEquipped() and self.inst.components.inventoryitem.owner or nil
    return self.onstopfn and self.onstopfn(self.inst, owner)
end

function GaleHelmsplitter:DoHelmSplit(doer, target)
    return self.oncastfn and self.oncastfn(self.inst, doer, target)
end

return GaleHelmsplitter
