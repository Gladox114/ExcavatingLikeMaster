--[[ directions 
-x = 1
-z = 2
+x = 3
+z = 4
]]
if not turtle.location then
    turtle.location = vector.new(0, 0, 0)
    turtle.startPosition = turtle.location
    turtle.startFacing = 1
end

excavate = {
    forward = 12,
    left = 11,
    up = 2,

    offset = {
        forward = 0,
        left = 0,
        up = 0
    },
    skip = {
        num = nil, -- a value
        position = nil -- vector.new(x,y,z)
    }
}
