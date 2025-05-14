local InteriorProvider = {}
InteriorProvider.__index = InteriorProvider

local NONE = -1

function InteriorProvider.getCurrentInterior()
    local id = getActiveInterior()
    if id ~= 0 then
        return id
    end
    return NONE
end

return InteriorProvider