local cooking = require("cooking")

local GaleQteCooker = Class(function(self, inst)
	self.inst = inst
	self.product = nil
	self.doer = nil
	self.is_cooking = false
	self.product_stacksize = nil
	self.ingredient_prefabs = nil


	self.qte_data_overrides = {
		jellybean = {
			dot_num = 10,
			per_time = 1.0,
			time_remain = 11.0,
		},
	}


	self._do_interrupt = function()
		SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_end_client"], self.doer.userid, "INTERRUPTE")
	end

	self._do_interrupt_player_exit = function(world, player)
		if player == self.doer then
			self._do_interrupt()
		end
	end
end)



-- local cooking = require("cooking") print(PrintTable(cooking.GetRecipe("meatballs","cookpot")))
function GaleQteCooker:GetQTEData(product)
	if self.qte_data_overrides[product] ~= nil then
		local data = self.qte_data_overrides[product]
		return data.dot_num, data.per_time, data.time_remain
	end

	local recipe_data = cooking.GetRecipe("cookpot", product)
	local cooktime = recipe_data.cooktime or 1

	local recover_score = (recipe_data.health or 0) + (recipe_data.sanity or 0) * 0.7 + (recipe_data.hunger or 0) * 0.5

	local dot_num = math.ceil(math.clamp(cooktime * 8.25, 1, TUNING.GALECOOK.MAX_DOTS_NUM))
	-- if recipe_data.foodtype == FOODTYPE.VEGGIE then
	-- 	dot_num = math.max(1, dot_num - 1)
	-- end

	-- local per_time = Remap(math.clamp(recover_score, 50, 90), 50, 90, 1.2, 0.9)
	local per_time = Remap(math.clamp(recover_score, 0, 100), 0, 100, 1.8, 0.9)
	-- if recipe_data.foodtype ~= FOODTYPE.MEAT then
	-- 	per_time = per_time + 0.1
	-- end

	-- local time_remain = dot_num * 2.05 * per_time * (math.clamp((recipe_data.hunger or 0) / 55, 1, 1.5))

	local fault_tolerant = Remap(math.clamp(recover_score, 0, 100), 0, 100, 5, 0) + (recipe_data.hunger or 0) / 55

	local time_remain = (dot_num + fault_tolerant) * per_time

	return dot_num, per_time, time_remain
end

function GaleQteCooker:GetQTEData_Debug(product)
	local dot_num = 6
	local per_time = 2

	local time_remain = dot_num * per_time
	return dot_num, per_time, time_remain
end

function GaleQteCooker:GetMinStack()
	local min_stack
	for k, v in pairs(self.inst.components.container.slots) do
		if v then
			local stack = v.components.stackable and v.components.stackable:StackSize() or 1
			if min_stack == nil or min_stack > stack then
				min_stack = stack
			end
		end
	end

	return min_stack
end

function GaleQteCooker:RemoveRecipes(remove_stack)
	remove_stack = remove_stack or self:GetMinStack()
	if remove_stack == nil or remove_stack <= 0 then
		return
	end

	for k, v in pairs(self.inst.components.container.slots) do
		if v then
			if v.components.stackable then
				local cur_stack_size = v.components.stackable:StackSize()
				if cur_stack_size <= remove_stack then
					v:Remove()
				else
					v.components.stackable:SetStackSize(cur_stack_size - remove_stack)
				end
			else
				v:Remove()
			end
		end
	end
end

function GaleQteCooker:ReturnRedundantRecipes(doer)
	for k, v in pairs(self.inst.components.container.slots) do
		if v then
			local item = self.inst.components.container:RemoveItem(v, true)
			if item then
				doer.components.inventory:GiveItem(item)
			end
		end
	end
end

function GaleQteCooker:Start(doer)
	self.ingredient_prefabs = {}
	for k, v in pairs(self.inst.components.container.slots) do
		table.insert(self.ingredient_prefabs, v.prefab)
	end
	self.inst.components.container:Close()
	self.inst.components.container.canbeopened = false

	if self.onstartcooking ~= nil then
		self.onstartcooking(self.inst)
	end

	local min_stack_size = self:GetMinStack()

	-- print("Min stack size:", min_stack_size)

	local unused_cook_time = 0
	self.product, unused_cook_time = cooking.CalculateRecipe("cookpot", self.ingredient_prefabs)

	self.doer = doer
	self.is_cooking = true
	self.product_stacksize = (cooking.GetRecipe("cookpot", self.product).stacksize or 1) * min_stack_size

	doer.sg:GoToState("gale_qte_cooking")
	self.inst:ListenForEvent("ms_playerleft", self._do_interrupt_player_exit, TheWorld)
	self.inst:ListenForEvent("onremove", self._do_interrupt, doer)
	self.inst:ListenForEvent("attacked", self._do_interrupt, doer)
	self.inst:ListenForEvent("onremove", self._do_interrupt)

	-- self.inst.components.container:DestroyContents()
	self:RemoveRecipes(min_stack_size)
	self:ReturnRedundantRecipes(doer)

	local dot_num, per_time, time_remain = self:GetQTEData(self.product)
	-- local dot_num, per_time, time_remain = self:GetQTEData_Debug(self.product)

	print(self.product,
		string.format("QTE Data.dot_num:%.2f,per_time:%.2f,time_remain:%.2f", dot_num, per_time, time_remain))


	SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_start"], doer.userid, self.product, self.inst, dot_num,
		per_time, time_remain)
end

function GaleQteCooker:Stop(end_state)
	if end_state == "FAILED" then
		self.product = "spoiled_food"
	end

	if self.ondonecooking ~= nil then
		self.ondonecooking(self.inst, end_state)
	end

	self.inst:RemoveEventCallback("ms_playerleft", self._do_interrupt_player_exit, TheWorld)
	self.inst:RemoveEventCallback("onremove", self._do_interrupt)

	if self.doer and self.doer:IsValid() then
		self.inst:RemoveEventCallback("onremove", self._do_interrupt, self.doer)
		self.inst:RemoveEventCallback("attacked", self._do_interrupt, self.doer)

		if not self.doer.sg:HasStateTag("dead") then
			if end_state ~= "INTERRUPTE" then
				self.doer.sg:GoToState("gale_qte_cooking_pst",
					{
						end_state = end_state,
						product = self.product,
						container = self.inst,
						ingredient_prefabs = shallowcopy(self.ingredient_prefabs),
						-- product_stacksize = (self.product == "spoiled_food" and 1 or self.product_stacksize)
						product_stacksize = self.product_stacksize
					})
			else
				self.doer.sg:GoToState("idle")
			end
		end
	end
	self.inst.components.container.canbeopened = true
	self.product = nil
	self.doer = nil
	self.is_cooking = false
	self.product_stacksize = nil
	self.ingredient_prefabs = nil
end

function GaleQteCooker:IsCooking()
	return self.is_cooking
end

function GaleQteCooker:Harvest(harvester, product, stacks, ingredient_prefabs)
	if self.onharvest ~= nil then
		self.onharvest(self.inst)
	end

	for i = 1, stacks do
		harvester.components.inventory:GiveItem(SpawnAt(product, harvester), nil, harvester:GetPosition())
	end

	local recipe = cooking.GetRecipe("cookpot", product)

	-- print("recipt = ", recipe)
	-- print("recipe.cookbook_category = ", recipe and recipe.cookbook_category or nil)
	-- print("ingredient_prefabs = ")
	-- dumptable(ingredient_prefabs)


	if harvester ~= nil and
		recipe ~= nil and
		recipe.cookbook_category ~= nil and
		ingredient_prefabs ~= nil and
		#ingredient_prefabs > 0 and
		cooking.cookbook_recipes[recipe.cookbook_category] ~= nil and
		cooking.cookbook_recipes[recipe.cookbook_category][product] ~= nil then
		print(harvester, "learncookbookrecipe", product)
		harvester:PushEvent("learncookbookrecipe", { product = product, ingredients = ingredient_prefabs })
	end
end

return GaleQteCooker
