package.path = "./?.lua;".. package.path
local clean = require("clean_db")
local mysql = require("dbcommon")

local db_list = {
	'auth_cloud_db',
	'wcpay',
	'trade',
}


for i, v in ipairs(db_list) do
	clean.truncate(v)	
end


mysql.connect('auth_cloud_db')

mysql.execute('alter table account auto_increment = 45;')

mysql.disconnect()
