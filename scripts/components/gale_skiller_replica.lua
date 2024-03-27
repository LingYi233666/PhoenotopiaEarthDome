require "json"

local GaleCommon = require("util/gale_common")

local GaleSkiller = Class(function(self,inst)
    self.inst = inst

    self.learned_skill = {}
    self.unlocked_tree = {}
    self.skillmem = {}

    self.keyhandler = {
        -- [KEY_Z] = nil,
        -- [KEY_X] = nil,
        -- [KEY_C] = nil,
        -- [KEY_V] = nil,
    }

    self.json_data = net_string(inst.GUID,"GaleSkiller.json_data","gale_skiller_json_data_dirty")

    if not TheNet:IsDedicated() then
        
        inst:DoTaskInTime(1,function()
            if self.inst == ThePlayer then
                TheSim:GetPersistentString("mod_config_data/gale_skiller_keyhandler", function(success, encoded_data)
                    if success then 
                        local save_data = json.decode(encoded_data)
                        print("Replica gale_skiller load key config success:")
                        for k,v in pairs(save_data) do
                            self:SetKeyHandler(v[1],v[2])
                        end

                        self.inst:PushEvent("gale_skiller_ui_update")
                    else
                        print("Replica gale_skiller keyhandler load failed !!!")
                    end
                end)
            end 
        end)

        inst:ListenForEvent("gale_skiller_json_data_dirty",function()
            local tab = json.decode(self.json_data:value())
            self.learned_skill = tab.learned_skill or {}
            self.unlocked_tree = tab.unlocked_tree or {}
            
            if self.inst == ThePlayer then
                for key,name in pairs(self.keyhandler) do
                    self:SetKeyHandler(key,name)
                end
                
                -- update galke skill ui (in menu screen) here
                self.inst:PushEvent("gale_skiller_ui_update")
            end 
        end)
    end

    -- inst:ListenForEvent("onremove",function()
    --     TheSim:SetPersistentString("mod_config_data/gale_skiller_keyhandler", json.encode(self.keyhandler), true)
    -- end)

    -- inst:ListenForEvent("playerdeactivated",function()
    --     TheSim:SetPersistentString("mod_config_data/gale_skiller_keyhandler", json.encode(self.keyhandler), true)
    -- end)
end)

function GaleSkiller:SetJsonData(data)
    self.json_data:set(data) 
end

function GaleSkiller:SetKeyHandler(key,name)
    if name ~= nil and not self:IsLearned(name) then
        return
    end

    for k,v in pairs(self.keyhandler) do
        if v == name then
            self.keyhandler[k] = nil 
            print(string.format("GaleSkiller replica clean old setting:%s,%s",name,GaleCommon.GetStringFromKey(k)))
            break
        end
    end

    self.keyhandler[key] = name 
    
    if name ~= nil then
        print(string.format("GaleSkiller replica setting %s to %s",name,GaleCommon.GetStringFromKey(key)))
    else 
        -- print(string.format("GaleSkiller replica clear key %s",GaleCommon.GetStringFromKey(key)))
    end
    
    print("Current key settings:")
    local tab = {}
    for k,v in pairs(self.keyhandler) do
        table.insert(tab,{k,v})
        print(string.format("%s:%s",GaleCommon.GetStringFromKey(k),v))
    end
    TheSim:SetPersistentString("mod_config_data/gale_skiller_keyhandler", json.encode(tab), true)

    -- self.inst:PushEvent("gale_skiller_ui_update")
end

function GaleSkiller:IsLearned(name)
    return name and self.learned_skill[name] == true
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