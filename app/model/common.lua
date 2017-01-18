--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-1-11
-- Time: 下午2:01
-- To change this template use File | Settings | File Templates.
--
local DB = require("app.libs.db")
local db = DB:new()

local common_model = {}

function common_model:get_index_list(page_no,page_size,flag)
    page_no = tonumber(page_no)
    page_size = tonumber(page_size)
    local sql_str_condition = ""

    if page_no < 1 then
        page_no = 1
    end
    local sql_str = "select a.id,a.tag,a.title,a.abstarct,a.image,a.viewNum,a.is_recommend,a.create_time ,t.name as tagName from t_article  a left join t_tag t on a.tag=t.id ";

    if flag == 'list' then
         sql_str_condition = "order by create_time desc limit ?,?;";
    else
         sql_str_condition = "order by id desc limit ?,?;";
    end
    local res,err = db:query(sql_str..sql_str_condition,{(page_no-1)*page_size,page_size})

    if not res or err or type(res) ~= 'table' or #res <= 0 then
        return {}

    else
        return res
    end
end

function common_model:get_tag_list()
    local res,err =db:query("select id,name from t_tag order by id asc;")
    if not res or err or type(res) ~= 'table' or #res <=0 then
        return {}
    else
        return res
    end
end

--获取文章详细信息
function common_model:get_detail(id)
    local res , err = db:query("select a.id,a.tag,a.title,a.abstarct,a.content,a.image,a.viewNum,a.is_recommend,a.create_time ,t.name as tagName from t_article  a left join t_tag t on a.tag=t.id where a.id=?;",{id})
    if not res or err or type(res) ~= 'table' then
        return {}
    else
        return res
    end
end

return common_model


