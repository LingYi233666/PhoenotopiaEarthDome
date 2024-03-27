local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_eco_dome_fountain",
    assets = {
        Asset("ANIM","anim/python_fountain.zip"),
    },

    bank = "fountain",
    build = "python_fountain",
    anim = "flow_loop",
    loop_anim = true,

    clientfn = function(inst)
        MakeObstaclePhysics(inst, 0.75)
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")

        inst.SoundEmitter:PlaySound("grotto/common/waterfall_LP","watersound")
    end

})