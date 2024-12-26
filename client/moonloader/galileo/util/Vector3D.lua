local Vector3D = {}
Vector3D.__index = Vector3D

function Vector3D.new(x, y, z)
    local object = setmetatable({}, Vector3D)
    object.x = x;
    object.y = y;
    object.z = z;

    return object
end

function Vector3D.parse(table)
    local x = table.x
    local y = table.y
    local z = table.z

    return Vector3D.new(x, y, z)
end

function Vector3D.sub(left, right)
    return Vector3D.new(left.x - right.x, left.y - right.y, left.z - right.z)
end

function Vector3D.add(left, right)
    return Vector3D.new(left.x + right.x, left.y + right.y, left.z + right.z)
end

function Vector3D.normalize(vector)
    local magnitude = math.sqrt(vector.x^2 + vector.y^2 + vector.z^2)
    
    if magnitude == 0 then
        return Vector3D.new(0, 0, 0)
    end

    return Vector3D.new(vector.x / magnitude, vector.y / magnitude, vector.z / magnitude)
end

function Vector3D.magnitude(vector)
    return math.sqrt(vector.x^2 + vector.y^2 + vector.z^2)
end

function Vector3D.dot(left, right)
    return  left.x * right.x +
            left.y * right.y +
            left.z * right.z
end

function Vector3D:__tostring()
    return  "x="..tostring(self.x)..
            ", y="..tostring(self.y)..
            ", z="..tostring(self.z)
end

return Vector3D