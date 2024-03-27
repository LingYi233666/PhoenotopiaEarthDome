--注册动作
AddAction("GALE_LEVER_TRIGGER_LEFT","GALE_LEVER_TRIGGER_LEFT",function(act) 
    if act.target and act.target.components.gale_lever and act.target.components.gale_lever:IsZeroDirection() then
        act.target.components.gale_lever:SetDirection(-1)
        return true
    end
end) 

AddAction("GALE_LEVER_TRIGGER_RIGHT","GALE_LEVER_TRIGGER_RIGHT",function(act) 
    if act.target and act.target.components.gale_lever and act.target.components.gale_lever:IsZeroDirection() then
        act.target.components.gale_lever:SetDirection(1)
        return true
    end
end) 

AddAction("GALE_LEVER_TRIGGER_ZERO","GALE_LEVER_TRIGGER_ZERO",function(act) 
    if act.target and act.target.components.gale_lever and not act.target.components.gale_lever:IsZeroDirection() then
        act.target.components.gale_lever:SetDirection(0)
        return true
    end
end) 


AddComponentAction("SCENE", "gale_lever", function(inst, doer, actions, right) 
    if doer:HasTag("player") and inst:HasTag("gale_lever") then
        if inst:HasTag("gale_lever_direction_zero") then
            if right then
                table.insert(actions, ACTIONS.GALE_LEVER_TRIGGER_RIGHT)
            else 
                table.insert(actions, ACTIONS.GALE_LEVER_TRIGGER_LEFT)
            end
        else 
            table.insert(actions, ACTIONS.GALE_LEVER_TRIGGER_ZERO)
        end
    end
end)


AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_LEFT, function(inst)
    return "give"
end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_LEFT,function(inst)
    return "give"
end))

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_RIGHT, function(inst)
    return "give"
end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_RIGHT,function(inst)
    return "give"
end))

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_ZERO, function(inst)
    return "give"
end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_LEVER_TRIGGER_ZERO,function(inst)
    return "give"
end))
