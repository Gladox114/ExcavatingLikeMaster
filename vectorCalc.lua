
--[[
vectorFacing = {
    --          x,y,z
    vector.new(-1,0,0), -- ore is from your position facing to -x
    vector.new(0,0,-1), -- block is facing -z
    vector.new(1,0,0), -- block is facing +x
    vector.new(0,0,1), -- +z

    vector.new(0,1,0), -- +y
    vector.new(0,-1,0) -- -y
}
]]

getBlockPos = {
    --          x,y,z
    function(i) return vector.new(-i,0,0) end, -- ore is from your position facing to -x
    function(i) return vector.new(0,0,-i) end, -- block is facing -z
    function(i) return vector.new(i,0,0) end, -- block is facing +x
    function(i) return vector.new(0,0,i) end, -- +z
    
    function(i) return vector.new(0,i,0) end, -- +y
    function(i) return vector.new(0,-i,0) end -- -y
}

dryTurn = {
    left = function(dryFacing)
        dryFacing = dryFacing - 1
        if dryFacing < 1 then dryFacing = 4 end
        return dryFacing
    end,
    right = function(dryFacing)
        dryFacing = dryFacing + 1
        if dryFacing > 4 then dryFacing = 1 end
        return dryFacing
    end
}

getBlockPos.t = {
    main = function(facing,distance) return getBlockPos[facing](distance) end,

    forward = function(facing,distance) return getBlockPos.t.main(facing,distance) end,
    left = function(facing,distance) return getBlockPos.t.main(dryTurn.left(facing),distance) end,
    right = function(facing,distance) return getBlockPos.t.main(dryTurn.right(facing),distance) end,
    back = function(facing,distance) return getBlockPos.t.main(dryTurn.left(dryTurn.left(facing)),distance) end,

    up = function(distance) return getBlockPos.t.main(5,distance) end,
    down = function(distance) return getBlockPos.t.main(6,distance) end
}

