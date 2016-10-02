package.path = "./?.lua;" .. package.path
local NotationList = require('notation_list')
local print = require('colorP').p

local function test()
	local n, err = NotationList:new("temp.lua")
	if not n then return err	end
	
	local file = io.open("./temp.lua", "r")
	assert(file)
	local data = file:read("*a") 
	file:close()
	
	local str = n:generate(data):format()
	print(str)
end


local function getNotation(dir, path, fileName)
	dir = dir or "all"
	fileName = fileName or string.match(path,".*/(.-).lua") 
		--	or string.match(path,".*/(.-)$") or 'temp'
	local n, err = NotationList:new(fileName)
	if not n then return err	end
	local input = path
	local output = string.format("%s.note",fileName)
	local file = io.open(input, "r")
	assert(file, string.format("fail to read file %s", input))
	local data = file:read("*a") 
	file:close()
	
	local str = n:generate(data):format()
	os.execute("cd ~/note")	
	local file = io.open(output, "w")
	assert(file, string.format("fail to write file %s", output))
	file:write(str)
	file:close()
end


getNotation(arg[1], arg[2], arg[3])
