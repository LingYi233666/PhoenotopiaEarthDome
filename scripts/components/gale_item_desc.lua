local function onsimple_desc(self,val)
    self.inst.replica.gale_item_desc:SetSimpleDesc(val)
end

local function oncomplex_desc(self,val)
    self.inst.replica.gale_item_desc:SetComplexDesc(val)
end

local GaleItemDesc = Class(function(self,inst)
    self.inst = inst

    self.simple_desc = ""
    self.complex_desc = ""

    inst:DoTaskInTime(0,function ()
        local tab = STRINGS.GALE_ITEM_DESC[inst.prefab:upper()]

        if #self.simple_desc == 0 and tab and tab.SIMPLE then
            self.simple_desc = tab.SIMPLE 
        end

        if #self.complex_desc == 0 and tab and tab.COMPLEX then
            self.complex_desc = tab.COMPLEX 
        end
    end)
end,nil,{
    simple_desc = onsimple_desc,
    complex_desc = oncomplex_desc,
})

function GaleItemDesc:SetSimpleDesc(val)
    self.simple_desc = val 
end

function GaleItemDesc:SetComplexDesc(val)
    self.complex_desc = val 
end

return GaleItemDesc