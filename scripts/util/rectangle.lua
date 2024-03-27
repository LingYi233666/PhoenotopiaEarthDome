local Polygon = require("util/polygon")

local Rectangle = Class(Polygon,function(self,w,h)
    Polygon._ctor(self,{
        Vector3(w/2,0,h/2),
        Vector3(-w/2,0,h/2),
        Vector3(-w/2,0,-h/2),
        Vector3(w/2,0,-h/2),
    })

    self.dtype = "rectangle"
end)

function Rectangle:SetRectWH(w,h)
    self:SetPtList({
        Vector3(w/2,0,h/2),
        Vector3(-w/2,0,h/2),
        Vector3(-w/2,0,-h/2),
        Vector3(w/2,0,-h/2),
    })
end

function Rectangle:IsInside(tar_pos)
    if tar_pos.x < self.ranges[1] or tar_pos.x > self.ranges[2] 
        or tar_pos.z < self.ranges[3] or tar_pos.z > self.ranges[4] then
            
        return false
    end

    return true 
end

return Rectangle