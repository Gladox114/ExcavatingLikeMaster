inv = {}

--config--
inv.chestItemsPos = vector.new(0, 0, 0) -- don't select the chest position but rather one that is in front of the chest
inv.chestItemsDir = 4
inv.blacklist = {
  "torch",
  "coal"
}
----------

function inv.Space()
  local slotsEmpty = 0
  for i = 1, 16 do
    if turtle.getItemCount(i) == 0 then
      slotsEmpty = slotsEmpty + 1
    end
  end
  if slotsEmpty == 0 then
    return false
  else return true end
end

function inv.doesItFit(name) -- call this if the inventory is full
  for i = 1, 16 do
    if turtle.getItemDetail(i)["name"] == name then
      if turtle.getItemSpace() > 0 then
        return true
      end
    end
  end
  return false
end

local emptyInv = {
  function() turn.to(1) turtle.drop() end,
  function() turn.to(2) turtle.drop() end,
  function() turn.to(3) turtle.drop() end,
  function() turn.to(4) turtle.drop() end,

  function() turtle.dropUp() end,
  function() turtle.dropDown() end
}

function inv.checkBlacklisted(object, blacklist)
  for i, name in pairs(blacklist) do
    if string.find(object, name) then
      return true
    end
  end
  return false
end

function inv.emptyFullInv()
  for i = 1, 16 do
    if inv.checkBlacklisted(turtle.getItemDetail(i)["name"], inv.blacklist) == false then
      turtle.select(i)
      emptyInv[inv.chestItemsDir]()
    end
  end
end

function inv.gotoChest()
  local saveFacing = turtle.facing
  local saveLocation = turtle.location
  local distance = inv.chestItemsPos - turtle.location
  Goto.position(distance, Goto.getAxis(turtle.facing), false, move)
  inv.emptyFullInv()
  distance = saveLocation - turtle.location
  Goto.position(distance, Goto.getAxis(turtle.facing), true, move)
  turn.to(saveFacing)
end

function inv.checkInv(blockName) -- passthrough the blockname as string
  -- check for space
  if inv.Space() == false then
    -- If it still can fit then mine it. If not then go back and empty yourself
    if inv.doesItFit(blockName) == false then -- if the block doesn't fit
      -- return back to chests and empty yourself
      return false
    end
  end
  return true
end
