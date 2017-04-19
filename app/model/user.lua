--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-3-23
-- Time: 下午1:50
-- To change this template use File | Settings | File Templates.
--
local DB = require("app.libs.db")
local db = DB:new()

local tinsert = table.insert

local json = require("cjson")

local user = {}

--根据id查询用户信息
function user:get(id)
    if not id then
        return {},"参数id不存在"
    end
    local id = tonumber(id)
    --@todo 查询用户信息sql语句
    local sql_str = "select `id`,`username`,`name`,`mobile`,`email`,`vaildate`,`grade`,`images`,`gmt_created` from t_user where id = ?;"
    --@todo 调用db封装接口查询用户信息
    local res,err = db:select(sql_str,{id})
    --@todo 查询结果判断
    if not res or err then
        return {} ,false
    else
        return res,true
    end
end

--查询用户名是否存在
function user:is_exists(username)
    local username = username or nil
    if not username then
        return true,"用户名不能为空"
    end
    --@todo 查询用户信息sql语句
    local sql_str = "select `id` from t_user where username = ?;"
    --@todo 调用db封装接口查询用户信息
    local res , err = db:select(sql_str,{username})
    ngx.log(ngx.ERR,"is_exists:"..#res)
    if not res or err then
        return true ,err
    else
        if #res == 0 then
            return false , "不存在该用户"
        else
            return true,"存在"
        end
    end
end


--登陆用户查询username，password
function user:login(username,password)
    local username = username or nil
    local password = password or nil
    if not username then
        return false,"用户信息不存在",nil
    end

    if not password then
        return false,"用户密码不能为空",nil
    end

    local username = tostring(username)
    --@todo 查询用户信息
    local sql_str = "select `id`,`username`,`name`,`mobile`,`email`,`validate`,`grade`,`images`,`gmt_created`,`password` from t_user where `username` = ?; "
    local res , err = db:select(sql_str,{username})

    --@todo 判断查询结果
    if not res or err then
        return false,"用户验证错误",nil
    else
        local get_pwd = res[1].password
        ngx.log(ngx.ERR,"login data:"..json.encode(res).."passwprd:"..password)
        if tostring(get_pwd) == tostring(password) then
            --@todo 将用户信息存储到user session中去
            return true,"成功",res[1]
        else
            return false,"用户名或密码错误",nil
        end
    end
end


--用户列表查询
function user:userList()
    local sql_str = "select `id`,`username`,`name`,`mobile`,`email`,`validate`,`grade`,`images`,`gmt_created` from t_user"
    local res , err = db:select(sql_str)
    if not res or err then
        return false,"失败",{}
    else
        return true,"成功",res
    end
end

--用户创建
function user:add(info)
    --@todo 判断输入信息
    local user_temp = info or nil
    ngx.log(ngx.ERR,"info:"..json.encode(user_temp))
    if not user_temp or type(user_temp) ~= 'table'then
        return false , "参数信息错误" ,user_temp
    end
    user_temp['gmt_created'] = ngx.utctime()
    user_temp['gmt_modified'] = ngx.utctime()
    --@todo sql语句拼装
    local keys = {}
    local vals = {}
    for i,v in pairs(user_temp) do
        if v ~= nil and #i > 0 then
            local key = '`'..i..'`'
            local val = '"'..v..'"' or ""
            tinsert(keys,key)
            tinsert(vals,val)
        end
    end
    local keys_str = table.concat(keys," , ")
    local vals_str = table.concat(vals, " , ")
    --@todo 数据存储
    local sql_str = "insert into `t_user` ("..keys_str..") values ("..vals_str..");"
    ngx.log(ngx.ERR,"sql add info:"..json.encode(sql_str))
    local res , err = db:insert(sql_str)
    if not res or err then
        return false , err , user_temp
    else
        return true , "成功" , res
    end
end


--用户修改
function user:update(info)
    --@todo 判断输入数据信息
    local user_temp = info or nil
    if not user_temp or type(user_temp) ~= 'table' then
        return false ,"参数信息错误", user_temp
    end
    --@todo sql语句拼装
    local params = {}
    local id = 0
    for i,v in pairs(user_temp) do
        if #i > 0 and i ~= 'id' then
            local names = '`'..i..'`'
            local values = '"'..v..'"' or ""
            tinsert(params,names.."="..values)
        else
            if i == 'id' and tonumber(v) > 0 then
                id = tonumber(v)
            end
        end
    end
    --@todo 数据更新
    if id < 0  or id == nil then
        return false ,"没有找到需要更新的数据",user_temp
    end

    local update_str = table.concat(params,",")
    local sql_str = "update `t_user` set "..update_str.." where id=?;"
    ngx.log(ngx.ERR,"update info:"..json.encode(sql_str).."id:"..id)
    local res , err = db:query(sql_str,{id})
    if not res or err then
        return false ,err,user_temp
    else
        return true,"成功",res
    end
end

--用户删除
function user:delete(id)
    local id = tonumber(id) or nil
    if not id then
        return false, "该用户不存在",id
    end
    --@todo 删除操作
    local sql_str = "delete from `t_user` where id = ?; "
    local res , err = db:delete(sql_str,{id})
    if not res or err then
        return false , err ,id
    else
        return true , "成功" ,res
    end
end

return user

