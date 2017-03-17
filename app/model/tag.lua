--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-3-14
-- Time: 下午3:40
-- To change this template use File | Settings | File Templates.
-- DESC: 获取标签列表
local DB = require("app.libs.db")
local db = DB:new()

--local tinsert = table.insert

local tag = {}

--获取所有tag信息
function tag:list()
    local sql_str = "select `id` , `name` , `describe` from t_tag order by id asc;"
    local res , err =db:select(sql_str)
    if not res or err or type(res) ~= 'table' or #res == 0 then
        return {}
    else
        return res
    end
end

return tag