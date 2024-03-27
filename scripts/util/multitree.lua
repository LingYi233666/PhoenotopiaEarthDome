-- 定义多叉树类节点类
GaleNode = Class(function(self,data,childs)
    self.data = data
    self.parent = nil 
    self.childs = childs or {}
end)

function GaleNode:AddChild(another_node)
    another_node.parent = self
    table.insert(self.childs,another_node)
end

function GaleNode:AddChilds(another_nodes)
    for k,v in pairs(another_nodes) do 
        another_nodes[k].parent = self
        table.insert(self.childs,another_nodes[k])
    end
end

function GaleNode:__tostring()
    local child_datas = ""
    for k,v in pairs(self.childs) do 
        child_datas = child_datas..tostring(v.data)..","
    end
    return string.format("Node:%s,parent[%s],child[%s]",tostring(self.data),tostring(self.parent and self.parent.data or "nil"),child_datas)    
end

------------------------------------------------------------------------------------------------------------------------------

-- 定义多叉树类
GaleMultiTree = Class(function(self,root_data,root_childs)
    self.root = GaleNode(root_data,root_childs)
end)


local function ListByLeftHelper(node,result_list,return_whole_node)
    if node == nil then
        return 
    end

    table.insert(result_list,return_whole_node and node or node.data)
    for k,v in pairs(node.childs) do
        ListByLeftHelper(v,result_list,return_whole_node)
    end
end

-- 多叉树中序遍历(根左右？)
function GaleMultiTree:ListByLeft(return_whole_node)
    local result_list = {}
    ListByLeftHelper(self.root,result_list,return_whole_node)
    return result_list
end

-- 多叉树层序遍历
function GaleMultiTree:ListByLayer(return_whole_node)
    local seek_list = {self.root}
    local result_list = {}

    while #seek_list > 0 do
        local temp_result = {}
    
        for i=1,#seek_list do 
            local top_node = seek_list[1]
            table.insert(temp_result,return_whole_node and top_node or top_node.data)

            for k,node in pairs(top_node.childs) do 
                table.insert(seek_list,node)
            end
            table.remove(seek_list,1)
        end
        table.insert(result_list,temp_result)
    end

    return result_list
end


