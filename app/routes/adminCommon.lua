--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-2-24
-- Time: 下午2:33
-- To change this template use File | Settings | File Templates.
--

local commom = require("app.model.common")
local json = require("cjson")

local adminCommon = {}

--后台首页页面
adminCommon.index = function(req,res,next)
    res:render("admin/index")
end


return adminCommon