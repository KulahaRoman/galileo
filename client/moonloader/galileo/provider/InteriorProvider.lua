local InteriorProvider = {}
InteriorProvider.__index = InteriorProvider

InteriorProvider.NONE = -1

function InteriorProvider.getCurrentInterior()
    local id = getActiveInterior()
    if id ~= 0 then
        return id
    end
    return InteriorProvider.NONE
end

return InteriorProvider