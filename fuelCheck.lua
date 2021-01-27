
fuel = {} -- This is the whole API
-- config --
fuel.minimum=1 -- Minimum fuel level till it refuels itself
fuel.allowSelfRefuel=true 
fuel.refuelmode="all" -- There are 3 modes. [all,slot,slots] scan and refuel everything in the inventory, refuel only from one slot, refuel from some specific slots
fuel.slot=1 -- if mode is slot then those are the slots for fuel
fuel.slots={15,16} 
fuel.refuelAtOnce=1
------------


function fuel.scanInv(runFunc,...)
    local oldSlot = turtle.getSelectedSlot()
    for i=1,16 do
        turtle.select(i)
        if runFunc(...) then return end
    end
    turtle.select(oldSlot)
end

-- refuelModes --
local refuelItselfFunctions = {
    ["all"] = function()
        fuel.scanInv(turtle.refuel,fuel.refuelAtOnce)
    end,
    ["slot"] = function() -- This may be unnecessary
        local oldSlot = turtle.getSelectedSlot()
        turtle.select(fuel.slot)
        turtle.refuel(fuel.refuelAtOnce)
        turtle.select(oldSlot)
    end,
    ["slots"] = function()
        local oldSlot = turtle.getSelectedSlot()
        for _,i in pairs(fuel.slots) do
            turtle.select(i)
            turtle.refuel(fuel.refuelAtOnce)
        end
        turtle.select(oldSlot)
    end
}

if fuel.allowSelfRefuel then
    fuel.refuelItself = refuelItselfFunctions[fuel.refuelmode]
else
    fuel.refuelItself = function() return end -- Ask in the interface. WIP
end
------------------

function fuel.checkFuel()
    if turtle.getFuelLevel() < fuel.minimum then
        fuel.refuelItself()
    end
end

function fuel.checkIfEnough(steps)
    if turtle.getFuelLevel() < steps then
        return false
    end
    return true
end

