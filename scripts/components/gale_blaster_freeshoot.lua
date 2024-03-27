local GaleBlasterFreeShoot = Class(function(self,inst)
    self.inst = inst 
    self.shootfn = nil 
end)

function GaleBlasterFreeShoot:FreeShoot(attacker,targetpos)
    if self.shootfn then
        return self.shootfn(self.inst,attacker,targetpos)
    end
end


return GaleBlasterFreeShoot