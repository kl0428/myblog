--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-3-1
-- Time: 上午10:52
-- To change this template use File | Settings | File Templates.
--@desc 文章数据操作model
--@author zhaoqing zhaoq0428@163.com

local DB = require("app.libs.db")--引入DB model

local db = DB:new()

local tinsert = table.insert

local article = {}

--查询文章列表
function article:get_list(page)
        local page = tonumber(page)
        local limit = 30
        if page < 1 then
            page = 1
        end
        --sql 语句拼写
        local sql_str = "select id,tag,title,viewNum,is_recommend,create_time from t_article limit ? , ?;"

        local res,err = db:query(sql_str,{page,limit})
        --ngx.log(ngx.ERR,"object:",res)
        if not res or err or type(res) ~= 'table'  or #res <= 0 then
                return {}
        else
                return res
        end
end

--查询文章信息
function article:get(id)
        local id = tonumber(page)
        if id < 0 then
                return {}
        end
        local sql_str = "select id , tag , title , abstarct , image, message,viewNum,content,is_recommend,create_time";
        local res,err = db:select(sql_str)
        if not res or err or type(res) ~= table or #res == 0 then
                return {}
        else
                return res
        end
end

--修改文章信息
function article:update(info)
        local info = info
        if type(info) ~= 'table' then
                return {}
        end
        --信息整理
        local update_vals = {}
        local id = 0
        local part_str = 'set '
        local where_str = 'where '
        for i,v in pairs(info) do
                if type(i) == 'string' then
                        if i == 'id' then
                                id = v
                                where_str = where_str ..i .."=?"
                        else
                                part_str = part_str ..","..i.."=? "
                                tinsert(update_vals,v)
                        end
                end
        end
        tinsert(update_vals,id)
        local sql_str = "update t_article "..part_str .. where_str..";"
        local res , err = db:update(sql_str,update_vals)

        if not res or err then
                return {}
        else
                return res
        end

end

--添加文章信息
function article:add(info)
        local info = info
        if type(info) ~= 'table' then
                return {}
        end
        --信息处理
        local params_str = " "
        local val_str = " "
        for i , v in pairs(info) do
                if type(i)=='string' then
                        params_str = params_str .." , "..i
                        if v and type(v) == "string" then
                                v = ngx.quote_sql_str(v)
                        end
                        val_str = val_str ..","..v
                end
        end

        local sql_str = "insert into t_article ("..params_str..") values ("..val_str..");"
        local res , err = db:insert(sql_str)
        if not res or err then
                return {}
        else
                return res
        end
end

--删除文章信息
function article:delete(id)
        local id = tonumber(id)
        if not id or id  <= 0 then
                return {}
        end
        local sql_str = "delete from t_article where id="..id..";"
        local res , err = db:delete(sql_str)
        if not res or err then
                return {}
        else
                return res
        end
end


return article
