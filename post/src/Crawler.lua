local DEFAULT_FILE = "tempWeb.html"

local Crawler = {
	url=nil,
	file = nil,
	isNewestWeb = false,
}


-- desc  获取url路径上的web，并且赋值到当前类中,返回web
-- input fileName optional
-- output web 
function Crawler:grabWeb(fileName)
	print("getting the web ",self.url)
	local path = fileName or DEFAULT_FILE 
	local cmd = string.format('curl -o %s \'%s\'',path,self.url)
	os.execute(string.format('touch %s',path))
	os.execute(cmd)
	
	local file = io.open(path,"r")
	if not io.type(file) then
		print("error,no file %s",path)
		io.close(file)
		os.exit()
	end
	self.file = file:read("*all")
	file:close()
	file = nil
	self.isNewestWeb = true 
	return self.file;
end



--input data type(data) == "string"
function Crawler:getWeb(data,fileName)
	if not data then
		return self:grabWeb(fileName)
	end
	if type(data) ~= "string" then
		return string.format("Crawler:getWeb error:data expect the string type , the data type:%s",type(data))
	end
	
	local url = self.url .. "?" .. data
	print("getting the web in getWeb",url)
	local path = fileName or DEFAULT_FILE 
	local cmd = string.format("curl -o %s '%s' ",path,url)
	os.execute(string.format('touch %s',path))
	--debug
	--print("get:",cmd)
	os.execute(cmd)
	
	local file = io.open(path,"r")
	if not io.type(file) then
		print("error,no file %s",path)
		io.close(file)
		os.exit()
	end
	self.file = file:read("*all")
	file:close()
	file = nil
	self.isNewestWeb = false
	return self.file;
end

function Crawler:postWeb(data,fileName)
	if type(data) ~= "string" then
		return string.format("Crawler:getWeb error:data expect the string type , the data type:%s",type(data))
	end

	print("getting the web in postWeb",self.url)
	local path = fileName or DEFAULT_FILE 
	local cmd = string.format('curl -o %s \'%s\' -d  \'%s\' ',path,self.url,data)
	os.execute(string.format('touch %s',path))
	--debug
	--print("post:",cmd)
	os.execute(cmd)
	
	local file = io.open(path,"r")
	if not io.type(file) then
		print("error,no file %s",path)
		io.close(file)
		os.exit()
	end
	self.file = file:read("*all")
	file:close()
	file = nil
	self.isNewestWeb = false
	return self.file

end




-- 获取最新的web页面
function Crawler:getNewestWeb()
	--文件存在，且Url没有被重置过
	if self.file and  (self.isNewestWeb== true) then
		return self.file
	else
		return self:getWeb()
	end
end


-- input file (optional ),如果没有填写文件，则默认选择当前类下最新的web页面
-- output list of url
function Crawler:getUrlList(file)
	local webFile = file or self:getNewestWeb()
	
	local list = {}
	for k in string.gmatch(webFile,"(https?://.-['\")])")  do
		table.insert(list,k)
	end	

	return list
end


-- input url necessary
-- output true ,false error
function Crawler:setUrl(url)
	if not url then 
		print("error:url必填",url)
		return nil,"error:url is nil"
	end 
	self.url = url
	self.isNewestWeb = false
	return true
end

function Crawler:new(url)
	local obj = {}	
	setmetatable(obj,self)
	self.__index = self
	obj:setUrl(url)
	return obj
end



return Crawler
