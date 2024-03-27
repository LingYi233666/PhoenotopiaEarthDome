
local function GaleSaveForRerollWrapper(old_fn)
	local function GaleSaveForReroll(inst,...)
		local data = old_fn(inst,...)

		-- if inst.components.gale_skiller then
		-- 	data.gale_skiller = inst.components.gale_skiller:OnSave()

		-- 	print(inst,"Gale SaveForReroll !!!")
		-- elseif inst.wonkey_carried_gale_data and inst.wonkey_carried_gale_data then
		-- 	data.gale_skiller = inst.wonkey_carried_gale_skiller_data

		-- 	print(inst,"Wonkey carry gale skiller data SaveForReroll !!!")
		-- end


        -- if inst.com

        if inst.prefab == "gale" then
            data.gale_skiller = inst.components.gale_skiller:OnSave()
            data.gale_status_bonus = inst.components.gale_status_bonus:OnSave()

            print(inst,"Gale SaveForReroll gale_skiller,gale_status_bonus")
        elseif inst.prefab == "wonkey" then 
            if inst.wonkey_carried_gale_data then
                data.gale_skiller = inst.wonkey_carried_gale_data.gale_skiller
                data.gale_status_bonus = inst.wonkey_carried_gale_data.gale_status_bonus
            end
            

            print(inst,"Wonkey carry gale skiller data SaveForReroll !!!")
        end



		return data
	end

	return GaleSaveForReroll
end

local function GaleLoadForRerollWrapper(old_fn)
	local function GaleLoadForReroll(inst,data,...)
		old_fn(inst,data,...)

        if inst.prefab == "gale" then 
            if data.gale_skiller ~= nil then
                inst.components.gale_skiller:OnLoad(data.gale_skiller)
            end
            if data.gale_status_bonus ~= nil then
                inst.components.gale_status_bonus:OnLoad(data.gale_status_bonus)
            end
            print(inst,"Gale LoadForReroll !!!")
        elseif inst.prefab == "wonkey" then 
            if inst.wonkey_carried_gale_data == nil then
                inst.wonkey_carried_gale_data = {}
            end
            inst.wonkey_carried_gale_data.gale_skiller = data.gale_skiller
            inst.wonkey_carried_gale_data.gale_status_bonus = data.gale_status_bonus
            print(inst,"Wonkey carry gale skiller data LoadForReroll !!!")
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

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return 
    end

    if inst.prefab == "gale" or inst.prefab == "wonkey" then
        inst.SaveForReroll = GaleSaveForRerollWrapper(inst.SaveForReroll)
        inst.LoadForReroll = GaleLoadForRerollWrapper(inst.LoadForReroll)
    end
end)
