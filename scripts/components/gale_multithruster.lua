local GaleMultiThruster = Class(function(self, inst)
    self.inst = inst

    self.onstartfn = nil
    self.onstopfn = nil
    self.oncastfn = nil
end)

function GaleMultiThruster:StartThrusting()
    return self.onstartfn and self.onstartfn(self.inst)
end

function GaleMultiThruster:StopThrusting()
    return self.onstopfn and self.onstopfn(self.inst)
end

function GaleMultiThruster:DoThrust(doer, target)
    return self.oncastfn and self.oncastfn(self.inst, doer, target)
end

return GaleMultiThruster
