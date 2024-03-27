local json = require("json")

local Polygon = Class(function(self,pt_list)
    self.pt_list = nil 
    self.ranges = nil
    self.dtype = "polygon"

    if type(pt_list) == "table" then
        self:SetPtList(pt_list)
    elseif type(pt_list) == "string" then
        -- self:FromJson(pt_list)
        print("[WARNING] Polygon:FromJson() is not use!")
    end
    
end)

function Polygon:SetPtList(pt_list)
    self.ranges = {}
    self.pt_list = pt_list or {}

    local min_x,max_x,min_z,max_z

    for _,v in pairs(self.pt_list) do
        min_x = min_x == nil and v.x or math.min(min_x,v.x)
        max_x = max_x == nil and v.x or math.max(max_x,v.x)
        min_z = min_z == nil and v.z or math.min(min_z,v.z)
        max_z = max_z == nil and v.z or math.max(max_z,v.z)
    end

    self.ranges = {min_x,max_x,min_z,max_z}
end

function Polygon:GetPtList()
    return self.pt_list
end

-- maybe complex...
local function SignedPolygonArea(pt_list)
    local pointsCount = #pt_list

    local pts = {}
    for _,v in pairs(pt_list) do
        table.insert(pts,v)
    end
    table.insert(pts,pt_list[1])

    local area = 0;

    for i = 1,pointsCount do
        area = area + (pts[i + 1].x - pts[i].x) * (pts[i + 1].z + pts[i].z) / 2
    end

    return math.abs(area)
end

function Polygon:IsInside(tar_pos)
    -- self.ranges = {min_x,max_x,min_z,max_z}
    -- Check Out of range
    if tar_pos.x < self.ranges[1] or tar_pos.x > self.ranges[2] 
        or tar_pos.z < self.ranges[3] or tar_pos.z > self.ranges[4] then
            
        return false
    end

    local whole_area = SignedPolygonArea(self.pt_list)

    local link_area = 0
    for i = 1,#self.pt_list do
        if i < #self.pt_list then
            link_area = link_area + SignedPolygonArea({
                self.pt_list[i],
                self.pt_list[i+1],
                tar_pos,
            })
        else 
            link_area = link_area + SignedPolygonArea({
                self.pt_list[i],
                self.pt_list[1],
                tar_pos,
            })
        end
    end

    return math.abs(whole_area - link_area) <= 0.000000001
end


-- Currently NOT complicable with sub class
function Polygon:ToJson()
    local list_to_encode = {}
    for _,v in pairs(self.pt_list) do
        table.insert(list_to_encode,v.x)
        table.insert(list_to_encode,v.z)
    end
    table.insert(list_to_encode,self.dtype)

    -- -- list_to_encode = {x1,z1,x2,z2,x3,z3,.....,xn,zn,dtype}
    return json.encode(list_to_encode)
end

function Polygon:FromJson(json_str)
    local list_to_dncode = json.decode(json_str)
    local pt_list = {}
    for i = 1,#list_to_dncode-2,2 do
        table.insert(pt_list,Vector3(list_to_dncode[i],0,list_to_dncode[i+1]))
    end
    self.dtype = list_to_dncode[#list_to_dncode]
    self:SetPtList(pt_list)
    
end

return Polygon

-- require("util/polygon")
-- require("util/polygon") local pol = Polygon({Vector3(0,0,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(0,0,1)}) print(pol:IsInside(Vector3(0.5,0,0.5)))

-- local pol = Polygon({Vector3(0,0,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(0,0,1),Vector3(-1,0,1)}) local j = pol:ToJson() local pol2 = Polygon() pol2:FromJson(j) dumptable(pol2.pt_list)