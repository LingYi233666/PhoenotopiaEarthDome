chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "athetos_production_process_athetos_neuromod",
        count = 1
    },
    {
        item = "athetos_neuromod",
        count = function()
            return math.random(0, 2)
        end
    },
}


local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, loot)
end

return
{
    OnCreate = OnCreate,
}
