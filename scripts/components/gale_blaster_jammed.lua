local GaleBlasterJammed = Class(function(self, inst)
    self.inst = inst

    self.temperature_facter = 0.8

    self.finiteuses_facter = 0.1
    self.finiteuses_thres = 0.5

    self.storm_facter = 0.33

    self.jammed = false
end)

function GaleBlasterJammed:SetJammed(enable)
    local old_jammed = self.jammed

    self.jammed = enable

    if self.jammed then
        self.inst:AddTag("gale_blaster_jammed")
    else
        self.inst:RemoveTag("gale_blaster_jammed")
    end

    if not old_jammed and enable then
        self.inst:PushEvent("gale_blaster_jammed")

        if self.inst.components.inventoryitem then
            local owner = self.inst.components.inventoryitem.owner
            if owner then
                owner:PushEvent("owner_find_gale_blaster_jammed", { gun = self.inst })
                if owner.components.talker and not owner:HasTag("mime") then
                    owner.components.talker:Say(GetString(owner, "ANNOUNCE_GUN_JAMMED"))
                end
            end
        end
    elseif old_jammed and not enable then
        self.inst:PushEvent("gale_blaster_not_jammed")

        if self.inst.components.inventoryitem then
            local owner = self.inst.components.inventoryitem.owner
            if owner then
                owner:PushEvent("owner_reset_gale_blaster_jammed", { gun = self.inst })
            end
        end
    end
end

function GaleBlasterJammed:GetPercent()
    local percent = 0

    if self.inst.components.temperature and self.inst.components.temperature:IsOverheating() then
        local begin_heat_temp = self.inst.components.temperature.overheattemp
        local max_heat_temp = self.inst.components.temperature.maxtemp

        percent = percent +
            Remap(self.inst.components.temperature:GetCurrent(), begin_heat_temp, max_heat_temp, 0,
                self.temperature_facter)
    end

    if self.inst.components.finiteuses and self.inst.components.finiteuses:GetPercent() < self.finiteuses_thres then
        percent = percent +
            Remap(self.inst.components.finiteuses:GetPercent(), 0, self.finiteuses_thres, self.finiteuses_facter, 0)
    end

    local storm_level = 0
    if TheWorld.components.sandstorms then
        storm_level = math.max(storm_level, TheWorld.components.sandstorms:GetSandstormLevel(self.inst))
    end
    if TheWorld.components.moonstorms then
        storm_level = math.max(storm_level, TheWorld.net.components.moonstorms:GetMoonstormLevel(self.inst))
    end

    percent = percent + math.clamp(storm_level, 0, 1) * self.storm_facter


    return math.clamp(percent, 0, 1)
end

function GaleBlasterJammed:JudgeJammed()
    if self:GetPercent() >= math.random() then
        self:SetJammed(true)
    end

    return self.jammed
end

function GaleBlasterJammed:OnSave()
    return {
        jammed = self.jammed,
    }
end

function GaleBlasterJammed:OnLoad(data)
    if data ~= nil then
        if data.jammed ~= nil then
            self:SetJammed(data.jammed)
        end
    end
end

return GaleBlasterJammed
