--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]


--- config ---
blacklist = {
  "chest",
  "turtle"
}
veinMiningEnabled = true
--------------


-- Calling Requirements
nilfunc = function() return end

fuel = {}


--[[
TT1 = require("fuelCheck") -- if you don't want or need this then just remove this or don't put in the file
TT2 = require("veinMining")
]]
TT3 = require("torch")

if not TT1 then
  fuel.refuelItself = nilfunc
  print("Movement: fuelCheck not loaded")
end

if not TT3 then
  torch.placeDown = nilfunc
  print("Movement: torch not loaded")
end

vectorFacing = {
  --          x,y,z
  vector.new(-1, 0, 0), -- ore is from your position facing to -x
  vector.new(0, 0, -1), -- block is facing -z
  vector.new(1, 0, 0), -- block is facing +x
  vector.new(0, 0, 1), -- +z

  vector.new(0, 1, 0), -- +y
  vector.new(0, -1, 0) -- -y
}

-- Virtual steps --
-- Tracking location without GPS --
virt = {
  forward = function() turtle.location = turtle.location + vectorFacing[turtle.facing] end,
  up = function() turtle.location = turtle.location + vectorFacing[5] end,
  down = function() turtle.location = turtle.location + vectorFacing[6] end
}
-------------------


-- Turn functions
turn = {}
function turn.left()
  turtle.facing = turtle.facing - 1
  if turtle.facing < 1 then turtle.facing = 4 end -- If facing under
  turtle.turnLeft()
end

function turn.right()
  turtle.facing = turtle.facing + 1
  if turtle.facing > 4 then turtle.facing = 1 end
  turtle.turnRight()
end

function turn.leftTwice() turn.left() turn.left() end

function turn.rightTwice() turn.right() turn.right() end

directionList = {
  [0] = nilfunc, -- there is nothing to do |if the robot is facing the same target direction then it always gets zero and there is nothing to do

  [1] = turn.right, -- direction is one to the left or right
  [-1] = turn.left,

  [2] = turn.rightTwice, -- direction is behind the turtle
  [-2] = turn.leftTwice,

  [3] = turn.left, -- direction is one to the left or right but not mathematicly
  [-3] = turn.right
}

function turn.to(direction)
  local turnnum = direction - turtle.facing
  directionList[turnnum]()
end

-- Dig functions
dig = {}
function dig.main(Tinspect, Tdig)
  local isblock, block = Tinspect()
  if isblock then -- if the block isn't air then
    local blacklisted = false
    for i, name in pairs(blacklist) do -- check for every blacklisted word and if there is one then don't dig, else otherwise
      if string.find(block["name"], name) then
        blacklisted = true
        break
      end
    end
    if blacklisted == false then
      if not inv.checkInv(block["name"]) then
        shouldCheck = false
        local saveLocation = turtle.location
        local saveFacing = turtle.facing
        -- go to start position --
        Goto.facingFirst(excavate.startPosition, move, dryTurn.left(excavate.startFacing))

        inv.gotoChest()

        -- go to start position
        Goto.facingFirst(excavate.startPosition, move, dryTurn.left(excavate.startFacing))

        -- go back to the saved location --
        Goto.facingFirst(saveLocation, move, dryTurn.left(excavate.startFacing))

        turn.to(saveFacing)
      end
      Tdig() -- turtle.digDIRECTION()
    end
  end
end

dig.forward = function() dig.main(turtle.inspect, turtle.dig) end
dig.up = function() dig.main(turtle.inspectUp, turtle.digUp) end
dig.down = function() dig.main(turtle.inspectDown, turtle.digDown) end



-- Movement functions
move = {}
function move.main(MoveDirection, digFunc)
  while true do -- while the turtle isn't moving try to make the way clear by digging

    local moved, error = turtle[MoveDirection]()
    if moved then
      -- This is an Important part for offline walking
      -- This will updates every step in turtle.location
      virt[MoveDirection]()
      --print(turtle.location)
      return
    end
    if error == "Movement obstructed" then
      digFunc()
    elseif error == "Out of fuel" then
      fuel.refuelItself()
    end

    -- check if inventory is full

  end
end

move.forward = function() move.main("forward", dig.forward) end
move.up = function() move.main("up", dig.up) end
move.down = function() move.main("down", dig.down) end

-- same like "move.forward" but also diggin above making a tunnel --
move.tunnel = function()
  move.main("forward", dig.forward)
  dig.up()
end
--reversed
move.tunnelR = function()
  move.main("forward", dig.forward)
  dig.down()
end

move.bigTunnel = function()
  move.main("forward", dig.forward)
  dig.up()
  dig.down()
end

-- repeating one function --
move.line = function(moveFunc, number) -- one move function like "move.forward" or even "move.tunnel",how many times to walk it |repeating a process to walk a line
  for i = 1, number do
    moveFunc()
  end
end
