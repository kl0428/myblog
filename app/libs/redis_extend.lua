--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-4-26
-- Time: 上午9:31
-- To change this template use File | Settings | File Templates.
--

local redis = require("resty.redis")
local config = require("app.config.config")

local Redis = {}

--新建Redis
--[[**todo 创建Redis实例
    *@param table conf 连接配置文件
    *@return table(object) Redis 返回Redis 实例
  ]]
function Redis:new(conf)
    conf = conf or config.redis
    local instance = {}
    instance.conf = conf
    setmetatable(instance,{ __index=self })
    return instance
end

--[[
--@todo 创建Redis连接
-- ]]
function Redis:connect()
   local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    local conf= self.conf

    --连接redis库
    local ok , err = red:connect(conf.connect_config.host,conf.connect_config.port)
    if not ok or err then
        ngx.log(ngx.ERR,"failed to connect:"..err)
        return
    end

    --登陆验证
    if #conf.connect_config.password > 0 then
        local count , err = red:get_reused_times()
        if count == 0 then
            local ok ,err = red:auth(conf.connect_config.password)
            if not ok or err then
                ngx.log(ngx.ERR,"auth passwprd error:"..err)
                return
            end
        elseif err then
            ngx.log(ngx.ERR,"failed to get reused times:",err)
            return
        end
    end

    return red
end

--[[
-- @todo 设置连接池
-- ]]
function Redis:pool(red)
    local conf= self.conf
    --设置连接池的大小100 空闲时间设置为10秒
    local ok ,err = red:set_keepalive(conf.pool_config.max_idle_timeout,conf.pool_config.pool_size)
    if not ok or err then
        ngx.log(ngx.ERR,"keepalive set failed:"..err)
        return
    end
end

--@todo redis set 设置操作
function Redis:set(key,value)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data , err = red:set(key,value)
    if not data or err then
        ngx.log(ngx.ERR,"[set] failed err:"..err)
        return
    end
    --处理完毕放回连接池
    self:pool(red)
    return data;
end

--@todo redis get 设置操作
function Redis:get(key)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data , err = red:get(key)
    if not data or err then
        ngx.log(ngx.ERR,"[get] failed err:"..err)
        return
    end
    self:pool(red)
    return data;
end

--@todo redis hset 设置操作
function Redis:hset(key,field,value)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data , err = red:hset(key,field,value)
    if not data or err then
        ngx.log(ngx.ERR,"[hset] err reason:"..err)
        return
    end
    self:pool(red)
    return data;
end

--@todo redis hget 设置操作
function Redis:hget(key,field)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data , err = red:hget(key,field)
    if not data or err then
        ngx.log(ngx.ERR,"[hget] err reason:"..err)
        return
    end
    self:pool(red)
    return data
end

--@todo redis lpush 设置操作
function Redis:lpush(key,value)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data,err = red:lpush(key,value)
    if not data or err then
        ngx.log(ngx.ERR,"[lpush] err reason:"..err)
        return
    end
    self:pool(red)
    return data
end

--@todo redis lrange 设置操作
function Redis:lrange(key,offset,length)
    local red = self:connect()
    if not red then
        ngx.log(ngx.ERR,"[redis] failed connect")
    end
    local data,err = red:lrange(key,offset,length)
    if not data or err then
        ngx.log(ngx.ERR,"[lrange] err reason:"..err)
        return
    end
    self:pool(red);
    return data
end

return Redis

