local commonRouter = require("app.routes.common")
local adminCommonRouter = require("app.routes.adminCommon")
local userRouter = require("app.routes.user")
local adminArticleRouter = require("app.routes.adminArticle")
local errorRouter = require("app.routes.error")

return function(app)
    app:use("/user",userRouter())
    app:get("/", commonRouter.index)
    app:get("/index", commonRouter.index)
    app:get("/index.(html|php|tmpl)", commonRouter.index)
    app:get("/(list|list.html)",commonRouter.list)
    app:get("/list/:page",commonRouter.list)
    app:get("/show/:id",commonRouter.show)
    app:get("/admin/index(.html|)",adminCommonRouter.index)
    app:use("/article" , adminArticleRouter())
    app:use("/error", errorRouter())
end

