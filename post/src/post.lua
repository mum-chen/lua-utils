local CRAWLER_PATH =  '/home/ubuntu/luaTest/src'
package.path = string.format("%s/?.lua;",CRAWLER_PATH) .. package.path


local json = require("cjson53.safe")
local Crawler = require("Crawler")

local crawler = nil

local host = "pay.trylong.cn"


local function encode(arr)
	return json.encode(arr)
end

local function decode(str)
	return json.decode(str)
end

local function converUrl(t)
	if not t then return false end

	local pair = {}
	for k,v in pairs(t) do
		table.insert(pair,string.format("%s=%s",k,v or "nil"))
	end
	
	return table.concat(pair,"&")
end

local function sendMsg(url,msg,type)
	
	crawler = crawler or Crawler:new(url)
	crawler:setUrl(url)

	local url  = url or "192.168.0.252/index"
	local file
	
	if type == 1 or type == "p" or type == "post" then
		file = crawler:postWeb(msg)
	elseif type == 0 or type == "g" or type == "get" then
		file = crawler:getWeb(msg)
	else 
		print("test.lua sendMsg:type error:type belong {p/g}")
	end
	
	return file
end



------public function --------
local function postObj(url,d,opt,key) 
	local verbose,encode = false,true
	--opt get
	if opt then 	
		if string.find(opt,'v') then
			verbose = true
		end
		
		if string.find(opt,'D') then
			encode = false
		end
	end

	url = host .. url
	local data = d or  {}
	
	local k = key or "data"

	--local output = { data = encode and  json.encode(data) or data }	
	local output = {}
	output[k] = encode and  json.encode(data) or data 	

	local msg = converUrl(output) 
	local _ = verbose and print(msg)
	file = sendMsg(url,msg,"p")		
	local _ = verbose and  print(file)
	return file
end


local function help()
	local info = [[
		-v :verbose
		-D :disable jsonencode
		
	]]	
	print(info)
end

local function setHost(newHost)
	host = newHost 
end



local function getMessage(file)
	local _,_,msg,obj = string.find(file,"(.-)({.*})")	

	return msg,obj
end

local function getObj(file)
	local begin,_,file = string.find(file,"({.*})")

	if not begin  then	
		print("not found json-formate string")
		return nil
	end

	if tonumber(begin) > 1 then
		print("may be contain the debug infomation")
	end 

	if not file then
		print("not file")
		return	nil 
	end
	
	local _table = decode(file)

	return _table
end


return {
	setHost = setHost,
	post = postObj,
	json_encode = encode,
	json_decode = decode,
	help = help,
	getObj = getObj,
	getMessage = getMessage,
}
