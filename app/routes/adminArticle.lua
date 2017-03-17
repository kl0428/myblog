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

local tag = require("app.model.tag")

local slen = string.len


--获取文章列表
    adminArticle:get('/list',function(req,res,next)
        --查询文章信息，返回文章列表
        --ngx.say('获取文章列表')
        --ngx.log(ngx.ERR,json.encode(ngx.req.get_uri_args()),"进入list router")
        local page = tonumber(req.query.page) or 1;
        --获取文章数量
        local num = article:list_num()
        if not num or type(num) ~= 'number' then
            num = 0
        end
        --计算文章页数
        local page_num = 0
        if num then
            page_num = math.ceil((num+29)/30)
        end

        if page_num < page then
            page = page_num
        end

        local res_list = article:get_list(page)
        if not res_list or (type(res_list)=='table' and #res_list == 0) then
            res:status(500):send("500! sorry, not found.")
        else
            res:render("admin/article_list",{list=res_list,currentPage=page,pageNum=page_num})
        end

    end)


--添加文章
    adminArticle:post('/add',function(req,res,next)
        ngx.log(ngx.ERR,"$document_uri")
    end)
--文章添加页面
    adminArticle:get("/view",function(req,res,next)
        --获取tag列表
        local tags=tag:list()
        local id = req.query.id
        if not id or id ~= nil then
            id = tonumber(id) or 0
        end
        local article_detail = {}
        if id > 0 then
             article_detail = article:get(id)
        end
        --ngx.log(ngx.ERR,"object",type(article_detail),json.encode(article_detail))
        res:render("admin/article_detail",{tags=tags,id=id,article=article_detail})
    end)

--修改文章
    adminArticle:post('/update',function(req,res,next)
        local art_title = req.body.title
        local art_abstarct = req.body.abstarct
        local art_tag       = req.body.tag
        local art_recommend = req.body.is_recommend
        local art_content   = req.body.content
        local art_id        = req.body.id
        local result = {code=0,success=false,msg='',class='',database=json.encode(req.body) }
        if not art_title or type(art_title) ~= 'string' then
            result['class']='title'
        end

        if not art_content or type(art_content) ~= 'string' then
            result['class'] = 'content'
        end
        local tags=tag:list()
        local image = 'panda.jpg'
        for _,v in pairs(tags) do
            if tonumber(v.id) == tonumber(art_tag) then
                image = string.lower(v.name)..".jpg"
                break
            end
        end

        local data = {
                        title=art_title,
                        abstarct=art_abstarct,
                        tag=art_tag,
                        is_recommend=art_recommend,
                        content=art_content,
                        image=image,
                        update_time=ngx.localtime(),
        }
        if type(art_id)=='string' and tonumber(art_id) > 0 then
            data['id'] = art_id

            local res,err = article:update(data)
            if not res or err then
                result['msg'] ="修改文章失败"
            else
                result['success'] = true
            end
        else
            data['create_time']=ngx.localtime() -- create_time=ngx.localtime(),
            local res,err=article:add(data)
            if not res or err then
                result['msg'] ='添加文章失败！'
            else
                result['success']=true
            end
        end
        res:json(result)
        --res:json({title=art_title,tag=art_tag,recommend=art_recommend,conetnt=art_content,id=art_id})
        --ngx.say(json.encode(ngx.req.get_uri_args()))
        --ngx.say(json.encode(req))
        --ngx.say("修改文章")
    end)

--删除文章
    adminArticle:get('/delete/:id',function(req,res,next)
        ngx.say(json.encode(ngx.req.get_uri_args()))
        ngx.say(json.encode(req.body))
        ngx.say("删除文章")
    end)
--查看文章
    adminArticle:get('/detail/:id',function(req,res,next)
        local id = tonumber(req.params.id)
        if not id then
            res:redircet("/list")
        end

        local detail = article:get(id)
        --ngx.log(ngx.ERR,"ngx:",json.encode(detail))

        if detail ~= 0 then
            res:render("show",{article=detail})
        else
            res:redircet("/list")
        end
    end)

return adminArticle