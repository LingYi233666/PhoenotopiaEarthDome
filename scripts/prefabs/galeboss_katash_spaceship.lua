local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local function ClientFn(inst)
    MakeObstaclePhysics(inst, 1.2)
end

local function ServerFn(inst)
    inst:AddComponent("inspectable")
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_katash_spaceship",
    assets = {
        Asset("ANIM", "anim/galeboss_katash_spaceship.zip"),
    },

    bank = "galeboss_katash_spaceship",
    build = "galeboss_katash_spaceship",
    anim = "idle_broken",


    clientfn = ClientFn,
    serverfn = ServerFn,
})
