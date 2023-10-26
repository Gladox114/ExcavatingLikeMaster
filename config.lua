require("movement")

--[[ directions 
-x = 1
-z = 2
+x = 3
+z = 4
]]

excavate = {
    forward = 12,
    left = 11,
    up = 2,

    offset = {
        forward = 0,
        left = 0,
        up = 0
    },

    -- keep out --
    startFacing = 1, -- keep this one
    startLocation = turtle.location
    ---------------
}
