local commonRouter = require("app.routes.common")
local userRouter = require("app.routes.user")
local errorRouter = require("app.routes.error")

return function(app)
    app:use("/user",userRouter())
    app:get("/", commonRouter.index)
    app:get("/index", commonRouter.index)
    app:get("/index.(html|php|tmpl)", commonRouter.index)
    app:get("/(list|list.html)",commonRouter.list)
    app:get("/list/:page",commonRouter.list)
    app:get("/show/:id",commonRouter.show)
    app:use("/error", errorRouter())
end

