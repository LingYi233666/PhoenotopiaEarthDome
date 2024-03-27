local GaleStatusBonus = Class(function(self,inst)
    self.inst = inst 

    self.base_value = {
        hunger = 100,
        health = 100,
        sanity = 100,
        gale_stamina = 100,
        gale_magic = 100,
    }

    self.bonus_value = {
        hunger = 0,
        health = 0,
        sanity = 0,
        gale_stamina = 0,
        gale_magic = 0,
    }
end)

function GaleStatusBonus:AddBonus(dtype,val)
    self.bonus_value[dtype] = self.bonus_value[dtype] + val 

    self:Apply()
end

function GaleStatusBonus:Apply()
    local hunger_percent = self.inst.components.hunger:GetPercent()
	local health_percent = self.inst.components.health:GetPercent()
	local sanity_percent = self.inst.components.sanity:GetPercent()
    local stamina_percent = self.inst.components.gale_stamina:GetPercent()
    local magic_percent = self.inst.components.gale_magic:GetPercent()

	self.inst.components.hunger.max = self.base_value.hunger + (self.bonus_value.hunger or 0)
	self.inst.components.health.maxhealth = self.base_value.health + (self.bonus_value.health or 0)
	self.inst.components.sanity.max = self.base_value.sanity + (self.bonus_value.sanity or 0)
    self.inst.components.gale_stamina.max = self.base_value.gale_stamina + (self.bonus_value.gale_stamina or 0)
    self.inst.components.gale_magic.max = self.base_value.gale_magic + (self.bonus_value.gale_magic or 0)
    
    self.inst.components.hunger:SetPercent(hunger_percent)
    self.inst.components.health:SetPercent(health_percent)
    self.inst.components.sanity:SetPercent(sanity_percent)
    self.inst.components.gale_stamina:SetPercent(stamina_percent)
    self.inst.components.gale_magic:SetPercent(magic_percent)
end

function GaleStatusBonus:OnSave()
    local data = {
        bonus_value = self.bonus_value,
        old_percent = {
            hunger = self.inst.components.hunger:GetPercent(),
            health = self.inst.components.health:GetPercent(),
            sanity = self.inst.components.sanity:GetPercent(),
            gale_stamina = self.inst.components.gale_stamina:GetPercent(),
            gale_magic = self.inst.components.gale_magic:GetPercent(),
        },
    }

    return data 
end

function GaleStatusBonus:OnLoad(data)
    if data ~= nil then
        if data.bonus_value ~= nil then
            self.bonus_value = data.bonus_value
        end
    end

    self:Apply()

    if data ~= nil then
        if data.old_percent ~= nil then
            if data.old_percent.hunger ~= nil then
                self.inst.components.hunger:SetPercent(data.old_percent.hunger)
            end
            if data.old_percent.health ~= nil then
                self.inst.components.health:SetPercent(data.old_percent.health)
            end
            if data.old_percent.sanity ~= nil then
                self.inst.components.sanity:SetPercent(data.old_percent.sanity)
            end
            if data.old_percent.gale_stamina ~= nil then
                self.inst.components.gale_stamina:SetPercent(data.old_percent.gale_stamina)
            end
            if data.old_percent.gale_magic ~= nil then
                self.inst.components.gale_magic:SetPercent(data.old_percent.gale_magic)
            end
        end
    end
end

return GaleStatusBonus