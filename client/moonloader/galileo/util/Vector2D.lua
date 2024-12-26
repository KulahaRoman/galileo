local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    local object = setmetatable({}, Vector2D)
    object.x = x;
    object.y = y;

    return object
end

function Vector2D.parse(table)
    local x = table.x
    local y = table.y

    return Vector2D.new(x, y)
end

function Vector2D.sub(left, right)
    return Vector2D.new(left.x - right.x, left.y - right.y)
end

function Vector2D.add(left, right)
    return Vector2D.new(left.x + right.x, left.y + right.y)
end

function Vector2D.normalize(vector)
    local magnitude = Vector2D.magnitude(vector)

    if magnitude == 0 then
        return Vector2D.new(0, 0)
    end
    
    return Vector2D.new(vector.x / magnitude, vector.y / magnitude)
end

function Vector2D.magnitude(vector)
    return math.sqrt(vector.x^2 + vector.y^2)
end

function Vector2D.dot(left, right)
    return left.x * right.x + left.y * right.y
end

function Vector2D:__tostring()
    return  "x="..tostring(self.x)..
            ", y="..tostring(self.y)
end

return Vector2D