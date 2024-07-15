local GaleHelmsplitter = Class(function(self, inst)
    self.inst = inst

    self.onstartfn = nil
    self.onstopfn = nil
    self.oncastfn = nil
end)

function GaleHelmsplitter:StartHelmSplitting()
    return self.onstartfn and self.onstartfn(self.inst)
end

function GaleHelmsplitter:StopHelmSplitting()
    return self.onstopfn and self.onstopfn(self.inst)
end

function GaleHelmsplitter:DoHelmSplit(doer, target)
    return self.oncastfn and self.oncastfn(self.inst, doer, target)
end

return GaleHelmsplitter
