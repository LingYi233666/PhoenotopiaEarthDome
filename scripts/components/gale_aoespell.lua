local GaleAoeSpell = Class(function(self,inst)
    self.inst = inst 
    self.oncastfn = nil 

    inst:AddTag("gale_aoe_spell_weapon")
end)

function GaleAoeSpell:CanCast(doer,pos)
    return true
end

function GaleAoeSpell:SetOnCastFn(fn)
    self.oncastfn = fn 
end

function GaleAoeSpell:CastSpell(doer, act_pos)
    if self.oncastfn then
        local result = self.oncastfn(self.inst,doer, act_pos)
        return result == true or result == nil 
    end
end


return GaleAoeSpell