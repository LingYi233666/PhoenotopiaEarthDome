local function GetCondition(target,buff_name)
	return target.components.debuffable and target.components.debuffable:GetDebuff(buff_name)
end

local function GetConditionStacks(target,buff_name)
    local debuff = GetCondition(target,buff_name)

    return debuff and debuff.condition_data.stacks or 0
end

local function IsTargetImmune(target,buff_name)
	if target.components.debuffable then 
		for name,_ in pairs(target.components.debuffable.debuffs) do 
			local debuff = target.components.debuffable:GetDebuff(name)
			if debuff:HasTag("gale_condition") then 
				for _,v in pairs(debuff.condition_data.immune_debuffs) do 
					-- all_immune_list[v] = true
					if v == buff_name then 
						return true
					end
				end
			end
		end		
	end

	return false
end

local function AddCondition(target,buff_name,stacks)
	stacks = stacks or 1

	if not target.components.debuffable then 
		target:AddComponent("debuffable")
	end

	if IsTargetImmune(target,buff_name) then 
		-- 免疫
		return 
	end


	local new_add = not target.components.debuffable:HasDebuff(buff_name)
	target.components.debuffable:AddDebuff(buff_name,buff_name)

	local debuff = target.components.debuffable:GetDebuff(buff_name)
	
	if debuff and debuff:IsValid() then 
		if new_add then 
			-- debuff.condition_data.stacks = math.min(stacks,debuff.condition_data.max_stacks)
			debuff:SetStacks(math.min(stacks,debuff.condition_data.max_stacks))
		else
			-- debuff.condition_data.stacks = math.min(debuff.condition_data.stacks + stacks,debuff.condition_data.max_stacks)
			debuff:SetStacks(math.min(debuff.condition_data.stacks + stacks,debuff.condition_data.max_stacks))
		end
	end 
	-- if stacks then  
	-- 	debuff.condition_data.stacks = math.min(stacks,debuff.condition_data.max_stacks)
	-- end 
end

local function RemoveCondition(target,buff_name,stacks)
	stacks = stacks or 1

	if not target.components.debuffable then 
		target:AddComponent("debuffable")
	end

	local debuff = target.components.debuffable:GetDebuff(buff_name)

	if debuff then 
		-- debuff.condition_data.stacks = math.max(debuff.condition_data.stacks - stacks,0)
		debuff:SetStacks(math.max(debuff.condition_data.stacks - stacks,0))
		if debuff.condition_data.stacks <= 0 then 
			target.components.debuffable:RemoveDebuff(buff_name)
		end
	else
		print("[WARNING]",target,"Has no debuff named",buff_name)
	end
	-- if stacks then  
	-- 	debuff.condition_data.stacks = math.min(stacks,debuff.condition_data.max_stacks)
	-- end 
end

local function RemoveConditionAll(target,buff_name)
	if target.components.debuffable then 
		target.components.debuffable:RemoveDebuff(buff_name)
	end 
end

-- 举例：
-- 获得三层{BLOODTHIRSTY} --> 获得三层嗜血
local function ReplaceConditionDesc(target_desc)
	local after_desc,count = target_desc:gsub("{.-}",function(s)
		local key_word = s:sub(2,s:len()-1)
		local finded = STRINGS.NAMES[key_word]
		if finded then 
			return finded		
		end
	end)
	return after_desc
end

-- 举例：
-- 战斗开始时，获得2层{POWER}和4层{WOUND} --> POWER,WOUND
local function GetConditionKeywords(target_desc,ignore_names)
	ignore_names = ignore_names or {}
	local key_words = {}
	for s in target_desc:gmatch("{.-}") do 
		local key_word = s:sub(2,s:len()-1)
		local finded = STRINGS.NAMES[key_word]
		if finded and not table.contains(ignore_names,key_word) and not table.contains(key_words,key_word) then 
			table.insert(ignore_names,key_word)
			table.insert(key_words,key_word)
			for k,v in pairs(GetConditionKeywords(key_word,ignore_names)) do 
				table.insert(key_words,v)
			end
		end
	end

	return key_words
end




return {
	GetCondition = GetCondition,
    GetConditionStacks = GetConditionStacks,
	IsTargetImmune = IsTargetImmune,
	AddCondition = AddCondition,
	RemoveCondition = RemoveCondition,
	RemoveConditionAll = RemoveConditionAll,

	ReplaceConditionDesc = ReplaceConditionDesc,
	GetConditionKeywords = GetConditionKeywords,
}