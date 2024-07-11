local GaleRerollDataHandler = Class(function(self, inst)
    self.inst = inst

    self.memory = nil
    self:ResetMemory()
end)

function GaleRerollDataHandler:ResetMemory()
    self.memory = {
        components = {},
    }
end

function GaleRerollDataHandler:UpdateMemory()
    self:ResetMemory()
    for name, cmp in pairs(self.inst.components) do
        if cmp.use_gale_reroll_data_handler == true then
            self.memory.components[name] = cmp:OnSave()
        end
    end
end

function GaleRerollDataHandler:ApplyMemory()
    for name, saved_data in pairs(self.memory.components) do
        local cmp = self.inst.components[name]
        if cmp then
            cmp:OnLoad(saved_data)
        end
    end

    self:ResetMemory()
end

function GaleRerollDataHandler:OnSave()
    return {
        memory = self.memory,
    }
end

function GaleRerollDataHandler:OnLoad(data)
    if data.memory ~= nil then
        self.memory = data.memory
    end
end

return GaleRerollDataHandler
