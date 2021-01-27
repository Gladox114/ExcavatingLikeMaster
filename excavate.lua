--require("fuelCheck")
require("movement")
require("gotoGPS")

if not turtle.location then turtle.location = vector.new(0,0,0)   end
if not turtle.facing then   turtle.facing = 3                     end

excavate = {
    forward = 2,
    left = 0,
    up = -8,
    startFacing = 1, -- keep this one
    startLocation = turtle.location,
    offset={
        forward = 0,
        left = 0,
        up = 0
    }
}


function printWholeList(list)
    for i,v in pairs(list) do
        if type(v) == "table" then
            for z,a in pairs(v) do
                print(i,z,a)
            end
        else
            print(i,v)
        end
    end
end

--table: executeNumber, {coordinate,digNumber}

stepTable = {}

function table.clone(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[table.clone(k)] = table.clone(v) end
    return res
end



local tunnel = table.clone(move)
local tunnelR = table.clone(move)
local bigTunnel = table.clone(move)
tunnel.forward = move.tunnel
tunnelR.forward = move.tunnelR
bigTunnel.forward = move.bigTunnel
bigTunnel.up = function() move.up() dig.up() end
bigTunnel.down = function() move.down() dig.down() end

digFunc = {
    move,    --forward
    tunnel,  --forward+digUp
    tunnelR, --forward+digDown
    bigTunnel--forward+digDown+digUp
}

function insertPos(list,position,digNumber)
    table.insert(list,{position = position, digN = digNumber})
end

calc = {}

function calc.leftAxis(baseAxis,digN)
    if baseAxis == virtLocation.z then --if it's on the basis axis then calculate to the left
        virtLocation = virtLocation + vector.new(0,0,-excavate.left)
        insertPos(stepTable,virtLocation,digN)
    else --else to the right
        virtLocation = virtLocation + vector.new(0,0,excavate.left)
        insertPos(stepTable,virtLocation,digN)
    end
end

function calc.forwardAxis(baseAxis,forwardDir,skipForward,digN)
    if excavate.forward > 0 then
        if skipForward == true then
            skipForward = false
        else
            virtLocation = virtLocation + vector.new(forwardDir,0,0) -- go forward
            insertPos(stepTable,virtLocation,digN)
        end
        calc.leftAxis(baseAxis,digN)
    end
    for forward=2,excavate.forward do --x
        virtLocation = virtLocation + vector.new(forwardDir,0,0) -- go forward
        insertPos(stepTable,virtLocation,digN)
        calc.leftAxis(baseAxis,digN)
    end

end

function firstY(up,directionUp)
    print("what dir? "..up)
    print(vector.new(excavate.offset.forward,excavate.offset.up,excavate.offset.left))
    if up*directionUp == 2 then
        --Goto Offset Position --
        virtLocation = virtLocation + vector.new(excavate.offset.forward,excavate.offset.up,excavate.offset.left) --go into the area
        insertPos(stepTable,virtLocation,1)
        -------------------------
        if directionUp > 0 then -- when it's +1
            digNum = 2 -- dig forward and up
        else                    -- when it's -1
            digNum = 3 -- dig forward and downs
        end

        lastMove = #stepTable
        --printWholeList(stepTable)
        if lastMove > 0 then
            stepTable[lastMove].digN = digNum
        end
        --printWholeList(stepTable)
        calc.forwardAxis(baseAxis,1,true,digNum) --dig a layer forward and (down or up)
        cleared=2
    elseif up*directionUp > 2 then -- 3 or above
        --Goto Offset Position --
        --print("xxs: ",up)
        --print(virtLocation)
        virtLocation = virtLocation + vector.new(excavate.offset.forward,excavate.offset.up,excavate.offset.left) --go into the area
        insertPos(stepTable,virtLocation,1)
        -------------------------
        virtLocation = virtLocation + vector.new(0,1*directionUp,0) --go one up
        insertPos(stepTable,virtLocation,4)
        calc.forwardAxis(baseAxis,1,true,4) -- dig a layer up,down and forward
        if (up-3)*directionUp > 2 then
            virtLocation = virtLocation + vector.new(0,3*directionUp,0) --go three up
            insertPos(stepTable,virtLocation,4)
        elseif (up-3)*directionUp > 0 then
            virtLocation = virtLocation + vector.new(0,2*directionUp,0) --go three up
            insertPos(stepTable,virtLocation,4)
        end
        cleared=3
    else --it's always up == 1
        --Goto Offset Position --
        virtLocation = virtLocation + vector.new(excavate.offset.forward,excavate.offset.up,excavate.offset.left) --go into the area
        insertPos(stepTable,virtLocation,1)
        -------------------------
        calc.forwardAxis(baseAxis,1,true,1) --dig a layer only forward
        cleared=1
    end
    return cleared
end

function loopY(up,forwardDir,directionUp)
    print("xxs: ",up)
    if up*directionUp == 2 then
        print("dig 2")
        if directionUp < 0 then
            digNum = 2
        else
            digNum = 3
        end
        stepTable[#stepTable].digN = digNum
        --[[
        if directionUp > 0 then -- when it's +1
            digNum = 2 -- dig forward and up
        else                    -- when it's -1
            print("zz_3")
            digNum = 3 -- dig forward and downs
        end]]
        calc.forwardAxis(baseAxis,forwardDir,true,2) --dig forward and up or down
        --virtLocation = virtLocation + vector.new(0,1,0)
        --insertPos(stepTable,virtLocation,4)
        cleared=2
    elseif up*directionUp > 2 then
        print("dig 3")
        calc.forwardAxis(baseAxis,forwardDir,true,4)
        if (up-3)*directionUp > 2 then
            virtLocation = virtLocation + vector.new(0,3*directionUp,0) --go three up (or down)
            insertPos(stepTable,virtLocation,4)
        elseif (up-3)*directionUp > 0 then
            virtLocation = virtLocation + vector.new(0,2*directionUp,0) --go three up (or down)
            insertPos(stepTable,virtLocation,4)
        end
        cleared=3
        --printWholeList(stepTable)
    else --probably up = 1
        print("dig 1")
        calc.forwardAxis(baseAxis,forwardDir,true,1) --dig only forward
        --virtLocation = virtLocation + vector.new(0,1*directionUp,0)
        --insertPos(stepTable,virtLocation,1)
        cleared=1
    end
    return cleared
end

function wholeLoop(remaining,forwardDir,directionUp)
    --print("Remaining:"..remaining)
    cleared = loopY(remaining*directionUp,forwardDir,directionUp)
    remaining = remaining - cleared
    print(remaining,cleared)
    if forwardDir == 1 then
        forwardDir = -1
    else
        forwardDir = 1
    end
    return remaining,forwardDir
end

-- Precalculate the Room that will be digged --
---------------------------------------------------------
-- It will store every coordinate in table "stepTable" --
---------------------------------------------------------
function calcRoom()
    virtLocation = turtle.location -- save the current location as a virtual location
    baseAxis= turtle.location.z -- get the axis that will be used to go Left later. For now it's static
    forwardDir=-1 -- forward Direction. It will be used after the FirstY so the turtle goes to the negative direction back
    -- check if up is inverted
    if excavate.up > 0 then -- it's 1 or above
        cleared = firstY(excavate.up,1) -- Excavate the first Layer and return the layers cleared.
        remaining = excavate.up - cleared
        while remaining > 0 do 
            --print("Remaining: "..remaining)
            remaining,forwardDir = wholeLoop(remaining,forwardDir,1)
        end
    elseif excavate.up < 0 then -- it's -1 or under
        cleared = firstY(excavate.up,-1) -- Excavate the first Layer and return the layers cleared.
        remaining = excavate.up*-1 - cleared
        print("Remaining: "..remaining.." and "..excavate.up,cleared)
        print("forwardDir = "..forwardDir)
        while remaining > 0 do
            remaining,forwardDir = wholeLoop(remaining,forwardDir,-1)
        end
    end
end

function calcRoomEfficient()

end

calcRoom()

function printWholeList(list)
    for i,v in pairs(list) do
        if type(v) == "table" then
            for z,a in pairs(v) do
                print(i,z,a)
            end
        else
            print(i,v)
        end
    end
end

printWholeList(stepTable)

function execute46(stepTable)
    for i,v in pairs(stepTable) do
        dest = v.position - turtle.location -- get delta to the position you are going to
        --print(dest,v.position,turtle.location)
        print("table:Dig:"..v.digN)
        printWholeList(digFunc[v.digN])
        Goto.facingFirst(dest,digFunc[v.digN],turtle.facing)
    end
end

--print(turtle.location)

execute46(stepTable)
