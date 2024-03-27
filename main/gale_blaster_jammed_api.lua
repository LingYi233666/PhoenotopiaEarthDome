AddAction("GALE_RESET_JAMMED_BLASTER","GALE_RESET_JAMMED_BLASTER",function(act) 
    local gun = act.invobject
    if gun and gun:IsValid() 
        and gun.components.gale_blaster_jammed
        and gun.components.gale_blaster_jammed.jammed then
            
        gun.components.gale_blaster_jammed:SetJammed(false)
        
        return true 
    end
end) 



AddComponentAction("INVENTORY", "gale_blaster_jammed", function(inst, doer, actions, right) 
    if doer and doer:HasTag("player") and inst:HasTag("gale_blaster_jammed") then 
        table.insert(actions, ACTIONS.GALE_RESET_JAMMED_BLASTER)
    end 
end)


AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_RESET_JAMMED_BLASTER, function(inst)
    return "dolongaction"
end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_RESET_JAMMED_BLASTER,function(inst)
    return "dolongaction"
end))