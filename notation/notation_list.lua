package.path = "./?.lua;" .. package.path
local Notation = require('notation')
local print = require('colorP').p

local NotationList = {
	fileName = nil,
	methodList = nil
} 


function NotationList:new(fileName)
	if not fileName then
		return nil,'fileName is necessary'
	end		
	obj = {}
	setmetatable(obj, self)
	self.__index = self
	obj.fileName = fileName
	return obj
end

function NotationList:setField(field)
	Notation:setField(field)
end


function NotationList:generate(file)
	-- get
	local blockList = {}

	for block in string.gmatch(file,"%-*%[%[+%s+(@.-)%-*%]%]") do --TODO
		table.insert(blockList, block)
	end 
	
	self.methodList = {}	
	
	for _,block in ipairs(blockList) do
		table.insert(self.methodList, Notation:genNote(block))	
	end	
	return self
end

function NotationList:format()
	local res = {}
	
	table.insert(res,string.format("file name\t%s\n",self.fileName))
	for _,k in ipairs(self.methodList) do
		if k.format then
			table.insert(res,string.format("%s\n%s",string.rep("-",20),k:format()))
		end
	end	
		
	return table.concat(res)
end



return NotationList
