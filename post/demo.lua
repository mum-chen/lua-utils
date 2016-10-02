local CRAWLER_PATH =  '.'
package.path = string.format("%s/?.lua;",CRAWLER_PATH) .. package.path
local Post = require('post')
local print = require('colorP').p

local data ={
    aa = "a",
    bb = 1,
}

local url = "/delivery/query_by_device"

local file = Post.post(url,data,'v')
