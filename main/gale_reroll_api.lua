local function GaleSaveForRerollWrapper(old_fn)
    local function GaleSaveForReroll(inst, ...)
        local data = old_fn(inst, ...)

        -- if inst.components.gale_skiller then
        -- 	data.gale_skiller = inst.components.gale_skiller:OnSave()

        -- 	print(inst,"Gale SaveForReroll !!!")
        -- elseif inst.wonkey_carried_gale_data and inst.wonkey_carried_gale_data then
        -- 	data.gale_skiller = inst.wonkey_carried_gale_skiller_data

        -- 	print(inst,"Wonkey carry gale skiller data SaveForReroll !!!")
        -- end


        -- if inst.com

        if inst.prefab == "gale" then
            -- data.gale_skiller = inst.components.gale_skiller:OnSave()
            -- data.gale_status_bonus = inst.components.gale_status_bonus:OnSave()

            inst.components.gale_reroll_data_handler:UpdateMemory()
            data.gale_reroll_data_handler = inst.components.gale_reroll_data_handler:OnSave()

            print(inst, "Gale save for reroll")
            -- elseif inst.prefab == "wonkey" then
            --     if inst.wonkey_carried_gale_data then
            --         data.gale_skiller = inst.wonkey_carried_gale_data.gale_skiller
            --         data.gale_status_bonus = inst.wonkey_carried_gale_data.gale_status_bonus
            --     end


            --     -- print(inst,"Wonkey carry gale skiller data SaveForReroll !!!")
            --     print(inst, "Wonkey save for reroll (carry)")
        else
            -- if inst.other_character_carried_gale_data then
            --     data.gale_skiller = inst.other_character_carried_gale_data.gale_skiller
            --     data.gale_status_bonus = inst.other_character_carried_gale_data.gale_status_bonus
            -- end

            data.gale_reroll_data_handler = inst.components.gale_reroll_data_handler:OnSave()


            print(inst, "Other character save for reroll (carry)")
        end



        return data
    end

    return GaleSaveForReroll
end

local function GaleLoadForRerollWrapper(old_fn)
    local function GaleLoadForReroll(inst, data, ...)
        old_fn(inst, data, ...)

        if inst.prefab == "gale" then
            -- if data.gale_skiller ~= nil then
            --     inst.components.gale_skiller:OnLoad(data.gale_skiller)
            -- end
            -- if data.gale_status_bonus ~= nil then
            --     inst.components.gale_status_bonus:OnLoad(data.gale_status_bonus)
            -- end

            if data.gale_reroll_data_handler ~= nil then
                inst.components.gale_reroll_data_handler:OnLoad(data.gale_reroll_data_handler)
                inst.components.gale_reroll_data_handler:ApplyMemory()
            end


            print(inst, "Gale load for rerool")
            -- elseif inst.prefab == "wonkey" then
            --     if inst.wonkey_carried_gale_data == nil then
            --         inst.wonkey_carried_gale_data = {}
            --     end
            --     inst.wonkey_carried_gale_data.gale_skiller = data.gale_skiller
            --     inst.wonkey_carried_gale_data.gale_status_bonus = data.gale_status_bonus
            --     -- print(inst, "Wonkey carry gale skiller data LoadForReroll !!!")

            --     print(inst, "Wonkey load for rerool (carry)")
        else
            -- if inst.other_character_carried_gale_data == nil then
            --     inst.other_character_carried_gale_data = {}
            -- end
            -- inst.other_character_carried_gale_data.gale_skiller = data.gale_skiller
            -- inst.other_character_carried_gale_data.gale_status_bonus = data.gale_status_bonus

            if data.gale_reroll_data_handler ~= nil then
                inst.components.gale_reroll_data_handler:OnLoad(data.gale_reroll_data_handler)
            end

            print(inst, "Other character load for rerool (carry)")
        end

        -- if data.gale_skiller ~= nil then
        -- 	if inst.components.gale_skiller ~= nil then
        -- 		inst.components.gale_skiller:OnLoad(data.gale_skiller)

        -- 		print(inst,"Gale LoadForReroll !!!")
        -- 	else
        -- 		-- inst.wonkey_carried_gale_skiller_data = data.gale_skiller
        --         if inst.wonkey_carried_gale_data == nil then
        --             inst.wonkey_carried_gale_data = {}
        --         end
        --         inst.wonkey_carried_gale_data.gale_skiller = data.gale_skiller

        -- 		print(inst,"Wonkey carry gale skiller data LoadForReroll !!!")
        -- 	end


        -- end
    end

    return GaleLoadForReroll
end

-- Case 1: Gale --> Wonkey: Test success!
-- Trigger GaleSaveForReroll(print "Gale save for reroll") --> Gale become Wonkey --> Trigger GaleLoadForReroll(print "Wonkey load for rerool (carry)")

-- Case 2: Wonkey --> Gale: Test success!
-- Trigger GaleSaveForReroll(print "Wonkey save for reroll (carry)") --> Wonkey return to Gale --> Trigger GaleLoadForReroll(print "Gale load for rerool")

-- Case 3: Gale --> Gale (re-select character but still choose Gale): Test success!
-- Trigger GaleSaveForReroll(print "Gale save for reroll") --> Gale become Gale --> Trigger GaleLoadForReroll(print "Gale load for rerool")

-- Case 4: Gale --> Other character: Test success!
-- Trigger GaleSaveForReroll(print "Gale save for reroll") --> Gale become other character --> over, save discarded.

-- Case 5: Other character --> Gale: Test success!
-- Trigger GaleLoadForReroll(print "Gale load for rerool") --> No saved found, do nothing.

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- if inst.prefab == "gale" or inst.prefab == "wonkey" then
    --     inst.SaveForReroll = GaleSaveForRerollWrapper(inst.SaveForReroll)
    --     inst.LoadForReroll = GaleLoadForRerollWrapper(inst.LoadForReroll)
    -- end

    inst:AddComponent("gale_reroll_data_handler")

    inst.SaveForReroll = GaleSaveForRerollWrapper(inst.SaveForReroll)
    inst.LoadForReroll = GaleLoadForRerollWrapper(inst.LoadForReroll)
end)
