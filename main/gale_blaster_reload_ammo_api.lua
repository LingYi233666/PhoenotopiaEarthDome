local UpvalueHacker = require("util/upvaluehacker")


require("entityscript")

local COMPONENT_ACTIONS = UpvalueHacker.GetUpvalue(EntityScript.IsActionValid,"COMPONENT_ACTIONS")

local old_reloaditem_componentactions_fn = COMPONENT_ACTIONS.INVENTORY.reloaditem
COMPONENT_ACTIONS.INVENTORY.reloaditem = function(inst, doer, actions, right,...)
    if doer.replica.inventory ~= nil and not doer.replica.inventory:IsHeavyLifting() and inst:HasTag("msf_ammo") then
        local opened_containers = doer.replica.inventory:GetOpenContainers()

        for clip,v in pairs(opened_containers) do
            if clip:HasTag("msf_clip") and clip.replica.container:IsOpenedBy(doer) and (inst.replica.inventoryitem:IsHeldBy(clip) or clip.replica.container:CanTakeItemInSlot(inst)) then
                
                table.insert(actions, ACTIONS.CHANGE_TACKLE)
                return 
            end
        end
    end


    return old_reloaditem_componentactions_fn(inst, doer, actions, right,...)
end

local old_ACTIONS_CHANGE_TACKLE_strfn = ACTIONS.CHANGE_TACKLE.strfn
ACTIONS.CHANGE_TACKLE.strfn = function(act)
    local item = (act.invobject ~= nil and act.invobject:IsValid()) and act.invobject or nil
    if item and item:HasTag("msf_ammo") then
        local opened_containers = act.doer.replica.inventory:GetOpenContainers()

        for clip,v in pairs(opened_containers) do
            if clip:HasTag("msf_clip") and clip.replica.container:IsOpenedBy(act.doer) then 
                
                if item.replica.inventoryitem:IsHeldBy(clip) then
                    return "REMOVE"
                end

                if clip.replica.container:CanTakeItemInSlot(item) then
                    return "AMMO"
                end

                -- if not clip.replica.container:IsFull() then
                --     return "AMMO"
                -- end
                
            end
        end
    end

    

    return old_ACTIONS_CHANGE_TACKLE_strfn(act)
end

local old_ACTIONS_CHANGE_TACKLE_fn = ACTIONS.CHANGE_TACKLE.fn
ACTIONS.CHANGE_TACKLE.fn = function(act)
    local opened_containers = act.doer.components.inventory.opencontainers

    for clip,v in pairs(opened_containers) do
        if clip:HasTag("msf_clip") and clip.components.container:IsOpenedBy(act.doer) then
            if act.invobject.components.inventoryitem:IsHeldBy(clip) then
                
                local item = clip.components.container:RemoveItem(act.invobject, true)
                if item ~= nil then
                    item.prevcontainer = nil
                    item.prevslot = nil

                    act.doer.components.inventory:GiveItem(item, nil, clip:GetPosition())
                    return true
                end
            end

            if act.invobject.components.inventoryitem:GetGrandOwner() == act.doer then
                -- local targetslot = clip.components.container:GetSpecificSlotForItem(act.invobject)
                -- if targetslot then
                --     local item = act.invobject.components.inventoryitem:RemoveFromOwner(clip.components.container.acceptsstacks)
                --     -- local old_item = clip.components.container:RemoveItemBySlot(targetslot)
                --     -- if not clip.components.container:GiveItem(item, targetslot, nil, false) then
                --     --     act.doer.components.inventory:GiveItem(item, nil, clip:GetPosition())
                --     -- end
                --     -- if old_item ~= nil then
                --     --     act.doer.components.inventory:GiveItem(old_item, nil, clip:GetPosition())
                --     -- end
                --     clip.components.container:GiveItem(item, targetslot,nil,false)
                --     return true
                -- end

                if not clip.components.container:IsFull() then
                    local item = act.invobject.components.inventoryitem:RemoveFromOwner(clip.components.container.acceptsstacks)
                    -- print("remove item:",item)
                    return clip.components.container:GiveItem(item)
                end


            end



 
        end
    end


    return old_ACTIONS_CHANGE_TACKLE_fn(act)
end