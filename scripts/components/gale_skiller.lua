require "json"

local function onjson_data(self,data)
    self.inst.replica.gale_skiller:SetJsonData(data)
end

local GaleSkiller = Class(function(self,inst)
    self.inst = inst

    self.learned_skill = {}
    self.unlocked_tree = {
        "survival","science","combat",
        "energy","morph","psy"
    }

    self.skillmem = {}
    self.json_data = "{}"

    self:UpdateJsonData()
end,nil,{
    json_data = onjson_data,
})

function GaleSkiller:Learn(name,is_onload)
    if self:IsLearned(name) then
        print("[GaleSkiller]Try to learn a skill you already learned:",name)
        return 
    end

    -- if is_onload then
    --     print("[GaleSkiller] Loading learned skill:",name)
    -- end

    -- if not table.contains(self:GetCanUnlockSkill(),name) then
    --     print("[GaleSkiller]Try to learn a skill you can't unlock:",name)
    --     return
    -- end

    local data = GALE_SKILL_NODES[name:upper()].data
    if data then
        self.learned_skill[name] = true
        if data.OnLearned then
            data.OnLearned(self.inst,is_onload)
        end

        self.inst:PushEvent("gale_skill_learned",{
            name = name,
            is_onload = is_onload
        })
    else
        print("[GaleSkiller]Error:Unable to learn",name)
    end

    self:UpdateJsonData()
end

function GaleSkiller:Forget(name)
    if not self:IsLearned(name) then
        return 
    end

    self.learned_skill[name] = nil 
    local data = GALE_SKILL_NODES[name:upper()].data
    if data then
        if data.OnForget then
            data.OnForget(self.inst)
        end
        self.inst:PushEvent("gale_skill_forgot",{
            name = name,
        })
    else
        print("[GaleSkiller]Error:Data not found:",name)
    end

    self:UpdateJsonData()
end

function GaleSkiller:UpdateJsonData()
    local data = {
        learned_skill = self.learned_skill,
        unlocked_tree = self.unlocked_tree
    }

    self.json_data = json.encode(data)
end

function GaleSkiller:IsLearned(name)
    return self.learned_skill[name] == true
end

function GaleSkiller:GetLearnedSkill()
    local ret = {}
    for name,v in pairs(self.learned_skill) do
        if v == true then
            table.insert(ret,name)
        end
    end

    return ret
end

-- print(ThePlayer.components.gale_skiller:GetTyphonSkillNum())
function GaleSkiller:GetTyphonSkillNum()
    local typhon_skill_names = ArrayUnion(
        GALE_SKILL_TREE.ENERGY:ListByLeft(),
        GALE_SKILL_TREE.MORPH:ListByLeft(),
        GALE_SKILL_TREE.PSY:ListByLeft()
    )
    for i=1,#typhon_skill_names do
        local node = table.remove(typhon_skill_names,1)
        table.insert(typhon_skill_names,node.code_name)
    end

    local result = 0
    for name,v in pairs(self.learned_skill) do
        if v == true then
            if table.contains(typhon_skill_names,name) then
                result = result + 1
            end
        end
    end

    return result
end

function GaleSkiller:GetCanUnlockSkill()
    local ret = {}
    for _,name in pairs(self.unlocked_tree) do
        local tree = GALE_SKILL_TREE[name:upper()]
        for k,child in pairs(tree.root.childs) do
            if not self:IsLearned(child.data.code_name) then
                table.insert(ret,child.data.code_name)
            end
        end
    end

    for name,v in pairs(self.learned_skill) do
        if v == true then
            local node = GALE_SKILL_NODES[name:upper()]
            for k,child in pairs(node.childs) do
                if not self:IsLearned(child.data.code_name) then
                    table.insert(ret,child.data.code_name)
                end
            end
        end
    end

    return ret
end

function GaleSkiller:OnSave()
    local ret = {
        learned_skill = self:GetLearnedSkill()
    }

    return ret
end

function GaleSkiller:OnLoad(data)
    if data then
        if data.learned_skill then
            print("[GaleSkiller]:OnLoad() data.learned_skill:")
            dumptable(data.learned_skill)
            for k,name in pairs(data.learned_skill) do
                self:Learn(name,true)
            end
        end
    end
end

function GaleSkiller:GetDebugString()
    local s = "Learned skill:"
    for name,bool in pairs(self.learned_skill) do
        if bool then
            s = s..name..","
        end
    end
    s = s.."  Can unlock skill:"
    for k,name in pairs(self:GetCanUnlockSkill()) do
        s = s..name..","
    end
    return s
end

return GaleSkiller