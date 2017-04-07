--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-3-23
-- Time: 下午2:21
-- To change this template use File | Settings | File Templates.
--

local lor = require("lor.index")
--local lor = xpcall(require,"lor.index")
local adminUser = lor:Router()

local json = require("cjson")

local user = require("app.model.user")

--查询用户
--e.g.  /get/123
adminUser:get("/get/:id",function(req,res,next)
    ngx.say("查看用户信息");
end)


--获取用户列表
--e.g. /list
adminUser:get("/list",function(req,res,next)
    ngx.say("get the list about all user")
end)

--获取用户添加/更新页面
adminUser:get("/view",function(req,res,next)
    ngx.say("get the view of add/update")
end)

--添加用户信息
--e.g. /add
adminUser:post("/add",function(req,res,next)
   ngx.say("add user info")
end)

--修改用户信息
--e.g. /update
adminUser:post("/update",function(req,res,next)
    ngx.say("update user info")
end)

--删除用户信息
--e.g. /delete/1
adminUser:get("/delete/:id",function(req,res,next)
    ngx.say("delelte user info")
end)

return adminUser
