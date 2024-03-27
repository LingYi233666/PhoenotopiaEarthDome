local AthetosProductionProcess = Class(function(self, inst)
    self.inst = inst
    self.recipes = nil
    self.used_remove = false 
end)

function AthetosProductionProcess:SetRecipes(recipes)
    self.recipes = recipes
end

function AthetosProductionProcess:Teach(target)
    if self.recipes == nil then
        self.inst:Remove()
        return false
    elseif target.components.builder == nil then
        return false

    end 

    local known_recipes = {}
    local can_learn_recipes = {}

    for _,v in pairs(self.recipes) do
        if target.components.builder:KnowsRecipe(v) then
            table.insert(known_recipes,v)
        else 
            if target.components.builder:CanLearn(v) then
                table.insert(can_learn_recipes,v)
            end
        end
    end

    if #known_recipes == #self.recipes then
        return false, "KNOWN"
    end

    if #can_learn_recipes == 0 then
        return false, "CANTLEARN"
    end

    for _,v in pairs(can_learn_recipes) do
        target.components.builder:UnlockRecipe(v)
    end
    
    if self.onteach then
        self.onteach(self.inst, target)
    end

    if self.used_remove then
        self.inst:Remove()
    end

    return true
end

return AthetosProductionProcess