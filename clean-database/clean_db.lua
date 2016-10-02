package.path = "./?.lua;".. package.path
local print = require('colorP').p
local mysql = require("dbcommon")

local database = "wcpay"

local function truncate(table)
	local sql = string.format("truncate %s;",table)
	mysql.execute(sql)
end

local function truncate_all()
	local res, err = mysql.select("show tables")
	for i, v in ipairs(res) do
		truncate(v[string.format('Tables_in_%s',database)])
	end	
end


local function truncate_db(db)
	database = db or database
	mysql.connect(database)
	mysql.transaction(truncate_all)
	mysql.disconnect()
end


return{
	truncate = truncate_db,
}
