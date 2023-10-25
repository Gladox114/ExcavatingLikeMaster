-- This file Downloads all files from github https://github.com/Gladox114/ExcavatingLikeMaster

-- create a list full of files (excavate.lua, invCheck.lua, ...)

local files = {
  "excavate.lua",
  "invCheck.lua",
  "movement.lua",
  "fuelCheck.lua",
  "torch.lua",
  "gotoGPS.lua",
  "excavate.lua",
  "vectorCalc.lua",
  "test.lua"
}


-- use wget and github raw page to download each file


for i = 1, #files do
  shell.run("wget https://raw.githubusercontent.com/Gladox114/ExcavatingLikeMaster/master/" ..
    files[i] .. " " .. files[i])
end
