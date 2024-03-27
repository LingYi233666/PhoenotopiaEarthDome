require "class"

Vector4 = Class(function(self, x, y, z, w)
    self.x, self.y, self.z, self.w = x or 0, y or 0, z or 0, w or 0
end)

function Vector4:__add( rhs )
    return Vector4( self.x + rhs.x, self.y + rhs.y, self.z + rhs.z, self.w + rhs.w)
end

function Vector4:__sub( rhs )
    return Vector4( self.x - rhs.x, self.y - rhs.y, self.z - rhs.z, self.w - rhs.w)
end

function Vector4:__mul( rhs )
    return Vector4( self.x * rhs, self.y * rhs, self.z * rhs, self.w * rhs)
end

function Vector4:__div( rhs )
    return Vector4( self.x / rhs, self.y / rhs, self.z / rhs, self.w / rhs)
end

function Vector4:__unm()
    return Vector4(-self.x, -self.y, -self.z, -self.w)
end

function Vector4:Dot( rhs )
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z + self.w * rhs.w
end

function Vector4:__tostring()
    return string.format("(%2.2f, %2.2f, %2.2f, %2.2f)", self.x, self.y, self.z, self.w)
end

function Vector4:__eq( rhs )
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z and self.w == rhs.w
end

function Vector4:DistSq(other)
    return (self.x - other.x)*(self.x - other.x) + (self.y - other.y)*(self.y - other.y) + (self.z - other.z)*(self.z - other.z)
     + (self.w - other.w)*(self.w - other.w)
end

function Vector4:Dist(other)
    return math.sqrt(self:DistSq(other))
end

function Vector4:LengthSq()
    return self.x*self.x + self.y*self.y + self.z*self.z + self.w*self.w
end

function Vector4:Length()
    return math.sqrt(self:LengthSq())
end

function Vector4:Normalize()
    local len = self:Length()
    if len > 0 then
        self.x = self.x / len
        self.y = self.y / len
        self.z = self.z / len
        self.w = self.w / len
    end
    return self
end

function Vector4:GetNormalized()
    return self / self:Length()
end

function Vector4:GetNormalizedAndLength()
    local len = self:Length()
    return (len > 0 and self / len) or self, len
end

function Vector4:Get()
    return self.x, self.y, self.z, self.w
end

function Vector4:IsVector4()
    return true
end
