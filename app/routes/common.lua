--[[
local type = type
local utils = require("app.libs.utils")
local user_model = require("app.model.user")
local topic_model = require("app.model.topic")
local comment_model = require("app.model.comment")
local common_router = {}

local function topics_category_handler(current_category, req, res, next)
    local comment_count = comment_model:get_total_count()
    local topic_count = topic_model:get_all_count()
    local user_count = user_model:get_total_count()

    local diff_days, diff = utils.days_after_registry(req)

    res:render("index", {
        diff_days = diff_days,
        diff = diff,
        user_count = user_count,
        topic_count = topic_count,
        comment_count = comment_count,
        current_category = current_category
    })
end

common_router.settings = function(req, res, next)
    local user_id = req.session.get("user").userid
    if not user_id or user_id == 0 then
        return res:render("error", {
            errMsg = "cannot find user, please login."
        })
    end

    local result, err = user_model:query_by_id(user_id)
    if not result or err then
        return res:render("error", {
            errMsg = "error to find user."
        })
    end

    res:render("user/settings", {
        user = result
    })
end

common_router.index = function(req, res, next)
    local current_category = 0
    topics_category_handler(current_category, req, res, next)
end

common_router.share = function(req, res, next)
    local current_category = 1
    topics_category_handler(current_category, req, res, next)
end

common_router.ask = function(req, res, next)
    local current_category = 2
    topics_category_handler(current_category, req, res, next)
end

common_router.about = function(req, res, next)
    res:render("about")
end


return common_router]]

local common = require("app.model.common")
local Redis = require("app.libs.redis_extend")
local redis = Redis:new()
local json = require("cjson")

local commonRouter = {}

--首页页面控制器
--查询最新10条数据
commonRouter.index = function(req , res , next)
    local page_no = req.params.page or 1
    local page_size = 10
    local flag = 'index'
    local articles = {}
    local list = common:get_index_list(page_no,page_size,flag)
    --ngx.log(ngx.INFO,"object:",json.encode(list))
    if #list ~= 0 then
        articles = list
    end

    local tags_list = common:get_tag_list()
    local tags = {}
    if #tags_list ~= 0 then
        for _,val in pairs(tags_list) do
            tags[val.id] = val.name
        end
    end
    --ngx.log(ngx.ERR,"object:",json.encode(tags))

    res:render("index",{articles=articles,tags =tags})
end

--列表页面控制器
--查询列表数据按id倒叙显示
commonRouter.list = function(req,res,next)
    local page_no = req.params.page or 1
    --ngx.log(ngx.ERR,"req:",json.encode(req.params.page))
    --ngx.log(ngx.ERR,"ngx:",json.encode(ngx.req.get_uri_args()))
    local page_size = 20
    local flag = 'list'
    local articles = {}
    local list = common:get_index_list(page_no,page_size,flag)
    if #list ~= 0 then
        articles = list
    end
    res:render("list",{articles=articles,title="全部列表"})
end

--详情页面
--根据id查询详细信息
commonRouter.show = function(req,res,next)
    local id = tonumber(req.params.id)
    if not id then
        res:redircet("/list")
    end

    local detail = common:get_detail(id)
    --ngx.log(ngx.ERR,"ngx:",json.encode(detail))

    if detail ~= 0 then
        res:render("show",{article=detail[1]})
    else
        res:redircet("/list")
    end

end

commonRouter.redis = function(req,res,next)
    local name = req.params.name or "zhaoqing"
    local redis_set = redis:set("name",name)
    ngx.say(redis_set)
    local redis_get = redis:get("name")
    ngx.say(redis_get)
end

return commonRouter
