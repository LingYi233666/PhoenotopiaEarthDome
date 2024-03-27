local GaleTalkable = Class(function(self, inst)
    self.inst = inst

    self.interactfn = nil
end)

function GaleTalkable:Interact(talker)
    if self.interactfn then
        self.interactfn(self.inst, talker)

        return true
    end
end

return GaleTalkable
