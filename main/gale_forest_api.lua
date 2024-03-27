
local GaleForestLeaves = require("widgets/gale_forest_leaves")

AddClassPostConstruct("widgets/controls", function(self)
	self.GaleForestLeaves = self:AddChild(GaleForestLeaves(self.owner))
end)