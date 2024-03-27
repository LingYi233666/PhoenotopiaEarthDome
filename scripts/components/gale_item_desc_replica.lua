local GaleItemDesc = Class(function(self,inst)
    self.inst = inst

    self.simple_desc = net_string(inst.GUID,"GaleItemDesc.simple_desc")
    self.complex_desc = net_string(inst.GUID,"GaleItemDesc.complex_desc")
end)

function GaleItemDesc:SetSimpleDesc(val)
    self.simple_desc:set(val) 
end

function GaleItemDesc:SetComplexDesc(val)
    self.complex_desc:set(val)
end

function GaleItemDesc:GetSimpleDesc(val)
    return self.simple_desc:value()
end

function GaleItemDesc:GetComplexDesc(val)
    return self.complex_desc:value()
end


return GaleItemDesc