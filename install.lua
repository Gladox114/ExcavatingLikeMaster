-- This file Downloads all files from github https://github.com/Gladox114/ExcavatingLikeMaster

-- create a list full of files (excavate.lua, invCheck.lua, ...)
local folder = "ExcavatingLikeMaster"

local files = {
  "excavate.lua",
  "config-default-excavate.lua"
}

local dependencies = {
  "GodOfLegs"
}

-- use wget and github raw page to download each file

for i = 1, #files do
  shell.run("wget https://raw.githubusercontent.com/Gladox114/" .. folder .. "/veinMining/" ..
    files[i] .. " " .. files[i])
end

-- get all dependencies installed
for i = 1, #dependencies do
  shell.run("wget https://raw.githubusercontent.com/Gladox114/" .. dependencies[i] .. "/master/" ..
    "install.lua install-" .. dependencies[i] .. ".lua")
  shell.run("install-" .. dependencies[i] .. ".lua")
end
