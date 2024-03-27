local GaleEntity = require("util/gale_entity")

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_lever_wood",
    assets = {
        Asset("ANIM", "anim/boat_rotator.zip"),
    },

    tags = {"structure"},

    bank = "boat_rotator",
    build = "boat_rotator",
    
    clientfn = function(inst)
        inst.AnimState:SetFinalOffset(1)
	    inst:SetPhysicsRadiusOverride(0.25)
    end,

    serverfn = function(inst)
        inst:AddComponent("inspectable")

        inst:AddComponent("lootdropper")

        inst:AddComponent("gale_lever")

        inst:SetStateGraph("SGboatrotator")

        inst:ListenForEvent("gale_lever_direction_change",function(inst,data)
            local old_direction = data.old_direction
            local direction = data.direction
            
            if data.immediate then
                inst.sg.mem.direction = direction
                inst.sg:GoToState("idle")
                return 
            end
            
            if old_direction ~= 0 and direction == 0 then
                inst.sg.mem.direction = old_direction
                inst.sg:GoToState("off")
            elseif old_direction == 0 and direction ~= 0 then
                inst.sg.mem.direction = direction
                inst.sg:GoToState("on")
            elseif old_direction == direction then
                inst.sg.mem.direction = direction
                inst.sg:GoToState("idle")
            else 
                -- pass
                print(inst,"gale_lever error !")
            end
        end)
    end,
})