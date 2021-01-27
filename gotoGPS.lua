--[[
-x = 1
-z = 2
+x = 3
+z = 4
]]

-- needs movement library
require("movement")


--[[
To not get stupid colors and underlines in my text editor I decided to
name it Goto because in true lua there is a function named goto but not in CC
]]
Goto = {}
------ 3 axis to go to -------
function Goto.Zaxis(vec,moveFunc)

    if vec.z < 0 then -- if the destination is in the minus 
        if facing ~= 2 then -- if not facing in the direction then rotate
            turn.to(2)
        end
        move.line(moveFunc,vec.z*-1)
    elseif vec.z > 0 then -- if the destination is in the plus
        if facing ~= 4 then
            turn.to(4)
        end
        move.line(moveFunc,vec.z)
    end

end

function Goto.Xaxis(vec,moveFunc)

    if vec.x < 0 then -- if the destination is in the minus 
        if facing ~= 1 then -- if not facing in the direction then rotate
            turn.to(1)
        end
        move.line(moveFunc,vec.x*-1)
    elseif vec.x > 0 then -- if the destination is in the plus
        if facing ~= 3 then
            turn.to(3)
        end
        move.line(moveFunc,vec.x)
    end

end

function Goto.Yaxis(vec,MoveDirections)
    if vec.y < 0 then -- if the destination is in the minus 
        move.line(MoveDirections.down,vec.y*-1)
    elseif vec.y > 0 then -- if the destination is in the plus
        move.line(MoveDirections.up,vec.y)
    end

end

function Goto.getAxis(facing)

    if facing == 1 or facing == 3 then
        return "x"
    else
        return "z"
    end
end
------------------------------
-- go to position functions --
function Goto.posFirstZ(vec,forwardFunc)
    Goto.Zaxis(vec,forwardFunc) -- going the Z axis first
    Goto.Xaxis(vec,forwardFunc) -- then X axis
end

function Goto.posFirstX(vec,forwardFunc)
    Goto.Xaxis(vec,forwardFunc)
    Goto.Zaxis(vec,forwardFunc)
end

function Goto.facingFirst(vec,MoveDirections,facing)
    if facing == 2 or facing == 4 then -- walk the facing axis first... Will be useless if we want to use a main axis. Maybe it's completely useless
        Goto.posFirstZ(vec,MoveDirections.forward)
    else                        -- probably facing the x coordinates so lets go them first  | I really don't know why I am doing this
        Goto.posFirstX(vec,MoveDirections.forward)
    end
    Goto.Yaxis(vec,MoveDirections)
end

function Goto.position(vec,mainAxis,goingFromAxis,MoveDirections) -- vector position, string "x" or "z", true or false, just put "move" api into it or a custom move list that doesn't have veinminer call function as example
    if mainAxis == "z" then
        if goingFromAxis then
            Goto.posFirstZ(vec,MoveDirections.forward)
            Goto.Yaxis(vec,MoveDirections)
        else
            Goto.Yaxis(vec,MoveDirections)
            Goto.posFirstX(vec,MoveDirections.forward)
        end
    elseif mainAxis == "x" then
        if goingFromAxis then
            Goto.posFirstX(vec,MoveDirections.forward)
            Goto.Yaxis(vec,MoveDirections)
        else
            Goto.Yaxis(vec,MoveDirections)
            Goto.posFirstZ(vec,MoveDirections.forward)
        end
    end
end
------------------------
