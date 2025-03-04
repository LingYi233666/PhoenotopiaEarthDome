chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "athetos_production_process_athetos_fertilizer",
        count = 1
    },
    {
        item = "athetos_mushroom_cap",
        count = function()
            return math.random(1, 3)
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
