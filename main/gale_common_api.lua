AddPrefabPostInit("mushroom_farm", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end


    local old_abletoaccepttest = inst.components.trader.abletoaccepttest
    local function accepttest(inst, item, ...)
        if item.prefab == "athetos_mushroom_cap" or item.prefab == "athetos_mushroom_cap_dirty" then
            return false, "MUSHROOMFARM_NOATHETOSCAPALLOWED"
        end

        return old_abletoaccepttest(inst, item, ...)
    end

    inst.components.trader:SetAbleToAcceptTest(accepttest)
end)

-- 囊状体攻击动作
AddAction("TYPHON_CYSTOID_ATTACK", "TYPHON_CYSTOID_ATTACK", function(act)
    if act.target and act.target:IsValid() then
        return true
    end
end)

-- 编织魔幻影创造动作
AddAction("TYPHON_WEAVER_CREATE_PHANTOM", "TYPHON_WEAVER_CREATE_PHANTOM", function(act)
    if act.target and act.target:IsValid() then
        return true
    end
end)

ACTIONS.TYPHON_WEAVER_CREATE_PHANTOM.distance = 6



-- 手动对话动作
AddAction("GALE_TALKTO", "GALE_TALKTO", function(act)
    if act.target
        and act.target:IsValid()
        and act.target.components.gale_talkable
        and act.doer
        and act.doer:IsValid() then
        return act.target.components.gale_talkable:Interact(act.doer)
    end
end)

ACTIONS.GALE_TALKTO.priority = 5

AddComponentAction("SCENE", "gale_talkable", function(inst, doer, actions, right)
    if doer and doer:HasTag("player") then
        table.insert(actions, ACTIONS.GALE_TALKTO)
    end
end)


AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_TALKTO, "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GALE_TALKTO, "give"))


for i = 1, 25 do
    AddStategraphState("wilson", State
        {
            name = "gale_dolongaction_" .. tostring(i),
            tags = {},

            onenter = function(inst)
                inst.sg:GoToState("dolongaction", i)
            end,
        })
end


AddAction("GALE_DISSECT", "GALE_DISSECT", function(act)
    if act.invobject ~= nil and act.invobject:IsValid() then
        local doer = act.target or act.doer
        if act.invobject.components.gale_anatomical ~= nil then
            return act.invobject.components.gale_anatomical:Dissect(doer)
        end
    end
end)

ACTIONS.GALE_DISSECT.priority = 1
ACTIONS.GALE_DISSECT.actionmeter = true

AddComponentAction("INVENTORY", "gale_anatomical", function(inst, doer, actions, right)
    if doer:HasTag("player") then
        table.insert(actions, ACTIONS.GALE_DISSECT)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GALE_DISSECT, function(inst)
    return "gale_dolongaction_5"
end))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GALE_DISSECT, function(inst)
    return "dolongaction"
end))


AddIngredientValues({ "gale_duri_flower_petal" }, { veggie = 0.5 })
