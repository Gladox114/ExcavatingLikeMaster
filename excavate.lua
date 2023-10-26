--require("fuelCheck")
require("GodOfLegs/movement")
require("GodOfLegs/gotoGPS")
require("config")

if not turtle.location then turtle.location = vector.new(0, 0, 0) end
if not turtle.facing then turtle.facing = 3 end


function doItRight(input)
    if excavate.left > 0 then
        return input - 1
    else
        return input + 1
    end
end

excavate.left = doItRight(excavate.left)



-- create a tabke that will hold all calculated positions --
--table: OrderedNumber, {coordinate,digNumber}
stepTable = {}

-- copied randomy table cloner from the web --
function table.clone(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[table.clone(k)] = table.clone(v) end
    return res
end

-- copy original move function sets --
local tunnel = table.clone(move)
local tunnelR = table.clone(move)
local bigTunnel = table.clone(move)
-- replace forward functions with custom ones --
tunnel.forward = move.tunnel
tunnelR.forward = move.tunnelR
bigTunnel.forward = move.bigTunnel
-- replace up and down functions with custom ones --
bigTunnel.up = function() move.up() dig.up() end
bigTunnel.down = function() move.down() dig.down() end

-- Index the above function sets for easy access --
digFunc = {
    move, --forward
    tunnel, --forward+digUp
    tunnelR, --forward+digDown
    bigTunnel --forward+digDown+digUp
}

function insertPos(list, position, digNumber)
    table.insert(list, { position = position, digN = digNumber })
end

calc = {}

function calc.leftAxis(baseAxis, digN)
    -- if it's on the basisAxis then calculate to the left --
    if baseAxis == virtLocation.z then
        -- calculate to the left --
        virtLocation = virtLocation + vector.new(0, 0, -excavate.left)
        insertPos(stepTable, virtLocation, digN)
    else
        -- calculate to the right --
        virtLocation = virtLocation + vector.new(0, 0, excavate.left)
        insertPos(stepTable, virtLocation, digN)
    end
end

function calc.forwardAxis(baseAxis, forwardDir, skipForward, digN)
    if excavate.forward > 0 then
        -- not sure why again but it's necessary --
        -- when coming from a layer or going into the box then --
        -- don't go one forward because you already are there --
        if skipForward == true then
            skipForward = false
        else
            -- go one forward --
            virtLocation = virtLocation + vector.new(forwardDir, 0, 0)
            insertPos(stepTable, virtLocation, digN)
        end
        -- go to the left axis --
        calc.leftAxis(baseAxis, digN)
    end
    for forward = 2, excavate.forward do --x
        virtLocation = virtLocation + vector.new(forwardDir, 0, 0) -- go forward
        insertPos(stepTable, virtLocation, digN)
        calc.leftAxis(baseAxis, digN)
    end

end

function loopY(up, forwardDir, directionUp)
    -- the directionUp can invert the direction --
    -- Meaming that it needs always 1 to go up and -1 to go downs --

    -- if only two layers are remaining --
    if up * directionUp == 2 then

        if directionUp > 0 then
            digNum = 2 -- dig forward and up
        else
            digNum = 3 -- dig forward and down
        end

        --dig forward and up or down
        calc.forwardAxis(baseAxis, forwardDir, true, digNum)
        cleared = 2
        ---------------------------------------

        -- if 3 or more layers are remaining --
    elseif up * directionUp > 2 then

        -- dig a layer with 4 -- meaning that it will dig up and down while digging forward
        calc.forwardAxis(baseAxis, forwardDir, true, 4)

        -- after finishing check if some "up" layers are remaining --
        -- if yes then go 3 up when 3 or more layers are ahead for efficiency or two for else --
        if up * directionUp - 3 > 2 then
            -- go three up --
            virtLocation = virtLocation + vector.new(0, 3 * directionUp, 0)
            insertPos(stepTable, virtLocation, 4)
        elseif up * directionUp - 3 > 0 then
            -- go two up --
            virtLocation = virtLocation + vector.new(0, 2 * directionUp, 0)
            -- if digging two layers select a digNumber --
            -- 4 will dig above the turtle when going up --
            -- 1 will just go up normally --
            if up * directionUp - 3 > 1 then -- if remaining layers are 2s
                insertPos(stepTable, virtLocation, 4) -- dig into the layer
            else -- if digging one layer
                insertPos(stepTable, virtLocation, 1)
            end
        end
        cleared = 3
        ----------------------------------------

        -- if only 1 layer is remaining --
    else
        --dig only forward
        calc.forwardAxis(baseAxis, forwardDir, true, 1)

        cleared = 1
    end
    ----------------------------------
    return cleared
end

function wholeLoop(remaining, forwardDir, directionUp)
    -- execute loop and subtract the cleared layers from remaining layers
    cleared = loopY(remaining * directionUp, forwardDir, directionUp)
    remaining = remaining - cleared

    -- change the forward direction --s
    if forwardDir == 1 then
        forwardDir = -1
    else
        forwardDir = 1
    end
    return remaining, forwardDir
end

function goIntoBox(up, directionUp)
    -- go into offset location --
    virtLocation = virtLocation + vector.new(excavate.offset.forward, excavate.offset.up, excavate.offset.left * -1)
    insertPos(stepTable, virtLocation, 1)

    -- if 3 layers are going to be digged or more then go one up --
    if up > 2 then
        -- go one up --
        virtLocation = virtLocation + vector.new(0, 1 * directionUp, 0)
        insertPos(stepTable, virtLocation, 4)
    end
end

-- Precalculate the Room that will be digged --
---------------------------------------------------------
-- It will store every coordinate in table "stepTable" --
---------------------------------------------------------
function calcRoom()
    virtLocation = turtle.location -- save the current location as a virtual location
    baseAxis = turtle.location.z - excavate.offset.left -- get the axis that will be used to go Left later. For now it's static
    forwardDir = 1 -- forward Direction. It will be used after the FirstY so the turtle goes to the negative direction back

    -- check if up is inverted
    if excavate.up > 0 then -- it's 1 or above
        --cleared = firstY(excavate.up,1) -- Excavate the first Layer and return the layers cleared.
        --remaining = excavate.up - cleared
        remaining = excavate.up
        goIntoBox(remaining, 1)
        while remaining > 0 do
            remaining, forwardDir = wholeLoop(remaining, forwardDir, 1)
        end
    elseif excavate.up < 0 then -- it's -1 or under
        --cleared = firstY(excavate.up,-1) -- Excavate the first Layer and return the layers cleared.
        --remaining = excavate.up*-1 - cleared
        remaining = excavate.up * -1 -- make it a positive number
        goIntoBox(remaining, -1)
        while remaining > 0 do
            remaining, forwardDir = wholeLoop(remaining, forwardDir, -1)
        end
    end
end

calcRoom()

function printWholeList(list)
    for i, v in pairs(list) do
        if type(v) == "table" then
            for z, a in pairs(v) do
                print(i, z, a)
            end
        else
            print(i, v)
        end
    end
end

printWholeList(stepTable)

function execute46(stepTable)
    for i, v in pairs(stepTable) do
        dest = v.position - turtle.location -- get delta to the position you are going to
        Goto.facingFirst(dest, digFunc[v.digN], turtle.facing)
    end
end

--print(turtle.location)

execute46(stepTable)
