local log = require("log")
local js = require("cjson53.safe")
local luasql = require("luasql.mysql")
local DB_DEFAULT = "wcpay"
local database

local g_db, g_env
local function connect(db)
	database = db or database or DB_DEFAULT
	g_env = luasql.mysql()
	local conn, err = g_env:connect(database, "root", "authcloud2014") 
	local _ = conn or log.fatal("connect db fail %s", err or "")
	g_db = conn
end

local gone_str = "has gone away"
local function myexecute(sql)
	local cur, err = g_db:execute(sql)
	if cur then 
		return cur 
	end 
	
	if not err:find(gone_str) then 
		return nil, err 
	end 
	g_db:close()
	g_env:close()
	g_db, g_env = nil, nil
	log.info("mysql gone away, reconnect %s %s", sql, err)
	connect()
	return g_db:execute(sql)
end

local function select_cb_common(sql, cb)
	local s = os.time()
	local cur, err = myexecute(sql)
	if not cur then
		return nil, err 
	end

	local row = cur:fetch({}, "a")
	while row do
		cb(row)
		row = cur:fetch(row, "a")	-- reusing the table of results 
	end
	cur:close() 
	local d = os.time() - s 
	local _ = d >= 2 and log.info("sql spend %ss %s", d, sql)
	return true
end

local function select(sql) 
	local arr = {}
	local ret, err = select_cb_common(sql, function(row)
		local nmap = {}
		for k, v in pairs(row) do 
			nmap[k] = v
		end 
		table.insert(arr, nmap)
	end)
	local _ = ret or log.fatal("sql fail %s %s", sql, err)
	return arr
end

local function get_db()
	return g_db
end

local function escape(s)
	return g_db:escape(s)
end

local function execute(sql)
	local s = os.time()
	local ret, err =  myexecute(sql)
	local d = os.time() - s
	local _ = d >= 2 and log.info("sql spend %ss %s", d, sql)
	return ret, err
end

local function rollback(sql, err)
	local _ = sql and err and log.error("rollback for %s", sql, err)
	return execute("ROLLBACK")
end

local function transaction(func)
	local sql = "START TRANSACTION"
	local _, err = execute(sql)
	if err then
		return nil, err or ""
	end

	local ret, err = func()
	if not ret then 
		rollback()
		return ret, err or "" 
	end 

	local sql = "COMMIT"
	local _, err = execute(sql)
	if err then
		rollback(sql, err)
		return nil, err or ""
	end

	return true
end

local function disconnect()
	g_db:close()
	g_env:close()
	g_db, g_env = nil, nil
end

return {
	get_db = get_db,
	select = select, 
	escape = escape,
	connect = connect, 
	execute = execute,
	rollback = rollback,
	disconnect = disconnect,
	transaction = transaction, 
}

