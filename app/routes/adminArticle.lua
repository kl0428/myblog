--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-2-28
-- Time: 下午2:19
-- To change this template use File | Settings | File Templates.
--@title:后台文章管理
--@author：zhaoqing qzhao0428@163.com
local lor = require("lor.index")
local adminArticle = lor:Router()
local json = require("cjson")
local article = require("app.model.article")


--获取文章列表
    adminArticle:get('/list',function(req,res,next)
        --查询文章信息，返回文章列表
        --ngx.say('获取文章列表')
        --ngx.log(ngx.ERR,"come","进入list router")
        local page = req.query.page or 1;
        local res_list = article:get_list(page)
        if not res_list or (type(res_list)=='table' and #res_list == 0) then
            res:status(500):send("500! sorry, not found.")
        else
            res:render("admin/article_list",{list=res_list})
        end

    end)

--添加文章
    adminArticle:post('/add',function(req,res,next)
        ngx.say('添加文章')
    end)

--修改文章
    adminArticle:post('/update/:id',function(req,res,next)
        ngx.say(json.encode(ngx.req.get_uri_args()))
        ngx.say(json.encode(req))
        ngx.say("修改文章")
    end)

--删除文章
    adminArticle:get('/delete/:id',function(req,res,next)
        ngx.say(json.encode(ngx.req.get_uri_args()))
        ngx.say(json.encode(req.body))
        ngx.say("删除文章")
    end)
--查看文章
    adminArticle:get('/detail/:id',function(req,res,next)
        ngx.say('查看文章')
    end)

return adminArticle