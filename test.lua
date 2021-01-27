require("vectorCalc")
require("movement")
require("gotoGPS")

if not turtle.location then turtle.location = vector.new(0,0,0)   end
if not turtle.facing then   turtle.facing = 3                     end

base = turtle.location
baseFacing = turtle.facing
forw = getBlockPos.t.forward(turtle.facing,3)
print(forw)
point1 = forw+getBlockPos.t.right(turtle.facing,2)
point2 = forw+getBlockPos.t.left(turtle.facing,2)

print(point1)
print(point2)

entrypoint = vector.new(point1.x,base.y,base.z)

-- goto entrypoint

-- if not right then left

