package.path = "./?.lua;" .. package.path
local Config = require("config")
local print = require('colorP').p


local Notation = { }
Notation.field = Config.NOTE_FIELD

local function split(inputstr,sep)
	if sep == nil then
		sep = '%s'
	end
	--delete head space
	inputstr = string.gsub(inputstr,"%s*",'',1)
	local t={}
	local i=1
	for str in string.gmatch(inputstr,"([^" .. sep .. "]+)") do
		t[i] = sep ..  str
		i = i + 1
	end
	return t
end

Notation.isInit = false

local  function init(self)
	if  self.arrField and self.isInit then return end
	
	self.arrField = {}	
	for k,v in pairs(self.field) do
		self.arrField[v] = k	
	end
	self.isInit = true	
end

function Notation:new()
	obj = {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Notation:setField(field)
	self.field = field
	self.isInit = false
end


function Notation:set(file)
	if type(file) ~= 'string' then
		return nil,"type error"
	end
	local separator = '@'
	local noteArr =	split(file, separator)
	local noteMap = {}
	if not noteArr or #noteArr <= 0  then
		return nil, "null noteArr"
	end
	--load map	
	for i, note in ipairs(noteArr) do
		local k, v = string.match(note, "@(.-)%s+(.*)") 
		if k then
			if not noteMap[k]  then
				noteMap[k] = {}
			end
			table.insert(noteMap[k], v)
		end
	end

	for k,v in pairs(self.field) do
		if v then 
			self[k] = noteMap[k] 
		end
	end

	return self
end

function Notation:format()
	init(self)
	local res = {}
	for i, v in ipairs(self.arrField) do
		if self[v] then
			for _,val in ipairs(self[v]) do
				table.insert(res,string.format("@%s\t%s\n",v,val))	
			end
		end	
	end	
	return table.concat(res)
end

function Notation:genNote(file)
	local str = file or ""
	local note = Notation:new()
	local bool, err = note:set(str)	
	if not bool then return print(err) 	end
	return note
end


function Notation:genFormat(file)
	local str = file or ""
	local note = Notation:new()
	local bool, err = note:set(str)	
	if not bool then return print(err) 	end
	return note:format()
end


local function test()
	--read file
	local str = [[
		@desc what ever
		@method whar ever
		@param k1
		@param k2
		@return success fail dashdlhaslk

			fdjaslkdjaslkdj
	]]
	--get all notation list
	local note = Notation:genNote(str)
	print(note:format())
	--format  
end
--test()

return Notation
