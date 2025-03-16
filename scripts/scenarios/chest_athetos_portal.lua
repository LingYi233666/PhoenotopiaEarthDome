chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "athetos_production_process_gale_fran_door_item",
        count = 1
    },
}


local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, loot)
end

return
{
    OnCreate = OnCreate,
}
