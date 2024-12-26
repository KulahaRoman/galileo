local Serializer = {}
Serializer.__index = Serializer

function Serializer.serializeObject(object)
    return encodeJson(object)
end

function Serializer.deserializeObject(data)
    return decodeJson(data)
end

return Serializer