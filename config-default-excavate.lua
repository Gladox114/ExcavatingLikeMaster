--[[ directions 
-x = 1
-z = 2
+x = 3
+z = 4
]]
require("GodOfLegs/home")
if not turtle.location then
    turtle.location = vector.new(0, 0, 0)
    turtle.facing = 3
    turtle.startPosition = turtle.location
    turtle.startFacing = 1
    inv.initHomeAxis()
end

excavate = {
    run = false,
    forward = 12,
    left = 11,
    up = 2,

    offset = {
        forward = 1,
        left = 0,
        up = 0
    },
    skip = {
        number = nil, -- a value
        position = nil -- vector.new(x,y,z)
    }
}
