local GaleMagic = Class(function(self,inst)
    self.inst = inst 

    self.current = net_float(inst.GUID,"GaleMagic.current","GaleMagic.current")
    self.max = net_float(inst.GUID,"GaleMagic.max") 

    self.enable = net_bool(inst.GUID,"GaleMagic.enable","GaleMagic.enable")
    self.enable_HUD = net_bool(inst.GUID,"GaleMagic.enable_HUD","GaleMagic.enable_HUD")
end)

function GaleMagic:SetCurrent(val)
    self.current:set(val)
end

function GaleMagic:SetMax(val)
    self.max:set(val)
end

function GaleMagic:GetPercent()
    return self:GetCurrent() / self:GetMax()
end

function GaleMagic:GetCurrent()
    return self.current:value()
end

function GaleMagic:GetMax()
    return self.max:value()
end

function GaleMagic:Enable(enable)
    self.enable:set(enable)
end

function GaleMagic:EnableHUD(enable)
    self.enable_HUD:set(enable)
end

function GaleMagic:IsEnable()
    return self.enable:value()
end

function GaleMagic:IsHUDEnable()
    return self.enable_HUD:value()
end

function GaleMagic:CanUseMagic(value)
    return self:IsEnable() and self:GetCurrent() >= value 
end

return GaleMagic