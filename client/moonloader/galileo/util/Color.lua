local Color = {}
Color.__index = Color

function Color.explodeARGB(color)
    local a = bit.band(bit.rshift(color, 24), 0xFF)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    return a, r, g, b
end

function Color.explodeRGB(color)
    local r = bit.band(bit.rshift(color, 24), 0xFF)
    local g = bit.band(bit.rshift(color, 16), 0xFF)
    local b = bit.band(bit.rshift(color, 8), 0xFF)
    return r, g, b
end

function Color.implodeARGB(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function Color.implodeRGB(r, g, b)
    local rgb = bit.lshift(r, 24)
    rgb = bit.bor(rgb, bit.lshift(g, 16))
    rgb = bit.bor(rgb, bit.lshift(b, 8))
    return rgb
end

return Color