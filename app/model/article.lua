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

local json = require("cjson")

local article = {}

--查询文章列表
function article:get_list(page)
        local page = tonumber(page)
        local limit = 30
        local start = 0
        if page <= 1 then
                start = 0
        else
                start = (page-1)*limit
        end
        --sql 语句拼写
        local sql_str = "select a.id,t.name as tag_name,a.title,a.viewNum,a.messages,a.is_recommend,a.create_time from t_article  a left join t_tag  t on a.tag=t.id order by a.id desc  limit ? , ?;"

        local res,err = db:query(sql_str,{start,limit})
        --ngx.log(ngx.ERR,"object:",res)
        if not res or err or type(res) ~= 'table'  or #res <= 0 then
                return 0
        else
                return res
        end
end

--查询文章总条数
function article:list_num()
        local sql_str = "select count(id) from t_article;"
        local res,err = db:select(sql_str)
        if not res or err or type(res) ~= 'number' then
                return {}
        else
                return res
        end
end

--查询文章信息
function article:get(id)
        local id = tonumber(id)
        if id <= 0 then
                return {}
        end
        --ngx.log(ngx.ERR,"object:",id)
        local sql_str = "select a.id , a.tag , t.name, a.title , a.abstarct , a.image, a.messages,a.viewNum,a.content,a.is_recommend from t_article a left join t_tag t on a.tag=t.id where a.id=?";
        local res,err = db:select(sql_str,{id})
        --ngx.log(ngx.ERR,"mysql response:",json.encode(res))
        if not res or err then
                return {}
        else
                return res[1]
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
        local id = info['id'] or 0
        local part_str = 'set `'
        local part_table = {}
        local where_str = 'where '
        for i,v in pairs(info) do
                if i == 'id' then
                        where_str = where_str .."`"..i.."`" .."=?"
                else
                        tinsert(part_table,i)
                        tinsert(update_vals,v)
                end
        end
        tinsert(update_vals,id)
        local part_middel_str = table.concat(part_table,"` = ? , `")
        part_str = part_str ..part_middel_str.."`= ? "
        local sql_str = "update t_article "..part_str .. where_str..";"
        --ngx.log(ngx.ERR,"update_str:",sql_str)
        --ngx.log(ngx.ERR,"update_values",json.encode(update_vals))
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
        local params_str = ""
        local val_str = ""
        for i , v in pairs(info) do
                if string.len(params_str) > 0 then
                        params_str = params_str .." , "..i
                else
                        params_str = params_str ..i
                end
                local param = ""
                if v and type(v) == "string"  then
                         param = ngx.quote_sql_str(v)
                end
                if string.len(val_str) > 0  then
                        val_str = val_str ..","..param
                else
                        val_str = val_str ..param
                end
        end

        local sql_str = "insert into t_article ("..params_str..") values ("..val_str..");"
        --ngx.log(ngx.ERR,json.encode(sql_str))
        local res , err = db:insert(sql_str)
        if not res or err then
                return {},err
        else
                return res,err
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
                return {},err
        else
                return res,err
        end
end


return article
