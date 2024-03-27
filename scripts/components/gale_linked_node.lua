local GaleLinkedNode = Class(function(self,inst)
    self.inst = inst

    -- Child nodes that me link to 
    self.linked_nodes_me_to_another = {}

    -- Parent nodes that link their to me
    self.linked_nodes_another_to_me = {}
    
    -- Linked lines
    self.linked_lines = {}
end)

function GaleLinkedNode:HasLinkedWith(other)
    return self.linked_nodes_me_to_another[other] ~= nil or self.linked_nodes_another_to_me[other] ~= nil
end

function GaleLinkedNode:GetLinkedChilds()
    return self.linked_nodes_me_to_another
end

function GaleLinkedNode:GetLinkedParents()
    return self.linked_nodes_another_to_me
end

function GaleLinkedNode:GetLinkedAll()
    local ret = {}
    for k,_ in pairs(self.linked_nodes_me_to_another) do
        ret[k] = true 
    end

    for k,_ in pairs(self.linked_nodes_another_to_me) do
        ret[k] = true 
    end

    return ret 
end

function GaleLinkedNode:EnableLinkLine(other,enable)
    if self.linked_lines[other] then
        self.linked_lines[other]:Remove()
        self.linked_lines[other] = nil 
    end
    if enable then
        self.linked_lines[other] = SpawnAt("gale_linked_line",self.inst)
        self.linked_lines[other].components.gale_linked_line:SetTargetPos(other:GetPosition())
    end
end

function GaleLinkedNode:LinkTo(other,is_onload)
    if other.components.gale_linked_node then
        if self:HasLinkedWith(other) then
            print("[GaleLinkedNode] Unable to LinkTo",other,"because already linked with it")
            return
        end
        self:EnableLinkLine(other,true)
        other.components.gale_linked_node:BeLinkedBy(self.inst,is_onload)
        self.linked_nodes_me_to_another[other] = true 
    else
        print("[GaleLinkedNode] Unable to LinkTo a ent without gale_linked_node component")
    end
    
end

function GaleLinkedNode:BeLinkedBy(other,is_onload)
    if other.components.gale_linked_node then
        if self:HasLinkedWith(other) then
            print("[GaleLinkedNode] Unable to BeLinkedBy",other,"because already linked with it")
            return
        end
        self.linked_nodes_another_to_me[other] = true 
    else
        print("[GaleLinkedNode] Unable to BeLinkedBy a ent without gale_linked_node component")
    end 
end

function GaleLinkedNode:Dislink(other)
    if self.linked_nodes_me_to_another[other] then
        other.components.gale_linked_node:OnDislink(self.inst)
        self:EnableLinkLine(other,false)
        self:OnDislink(other)
    elseif self.linked_nodes_another_to_me[other] then
        other.components.gale_linked_node:OnDislink(self.inst)

        self:OnDislink(other)
    else 
        print("[GaleLinkedNode] Unable to DisLink",other,"because no link between us")
    end
end

function GaleLinkedNode:OnDislink(other)
    if self.linked_nodes_me_to_another[other] then
        self.linked_nodes_me_to_another[other] = nil 
    end

    if self.linked_nodes_another_to_me[other] then
        self.linked_nodes_another_to_me[other] = nil 
    end
end

function GaleLinkedNode:OnSave()
    local data = {
        GUIDs_linked_nodes_me_to_another = {},
        GUIDs_linked_nodes_another_to_me = {},
    }
    local references = {}

    for k,_ in pairs(self.linked_nodes_me_to_another) do
        table.insert(data.GUIDs_linked_nodes_me_to_another,k.GUID)
        table.insert(references,k.GUID)
    end

    -- for _,v in pairs(self.linked_nodes_another_to_me) do
    --     table.insert(data.GUIDs_linked_nodes_another_to_me,v.GUID)
    --     table.insert(references,v.GUID)
    -- end

    return data,references
end

function GaleLinkedNode:OnLoad(data)
    if data ~= nil then
        
    end
end

function GaleLinkedNode:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        if savedata.GUIDs_linked_nodes_me_to_another ~= nil then
            for _,guid in pairs(savedata.GUIDs_linked_nodes_me_to_another) do
                local child_ent = newents[guid]
                if child_ent and child_ent.entity.components.gale_linked_node then
                    self:LinkTo(child_ent.entity,true)
                end
            end
        end

        if savedata.GUIDs_linked_nodes_another_to_me ~= nil then
            
        end
    end
end

function GaleLinkedNode:GetDebugString()
    local str = "Linked Childs:\n%sLinked Parents:\n%s"
    local str_childs = ""
    local str_parents = ""

    for k,_ in pairs(self.linked_nodes_me_to_another) do
        str_childs = str_childs..tostring(k).."\n"
    end

    for k,_ in pairs(self.linked_nodes_another_to_me) do
        str_parents = str_parents..tostring(k).."\n"
    end
    return string.format(str,str_childs,str_parents) 
end

-- TEST_NODE1 = c_spawn("gale_spheralis_node")
-- TEST_NODE2 = c_spawn("gale_spheralis_node")
-- TEST_NODE3 = c_spawn("gale_spheralis_node")
-- TEST_NODE4 = c_spawn("gale_spheralis_node")

-- TEST_NODE1.components.gale_linked_node:LinkTo(TEST_NODE2)
return GaleLinkedNode