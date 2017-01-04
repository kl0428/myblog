local commonRouter = require("app.routes.common")
local userRouter = require("app.routes.user")
local errorRouter = require("app.routes.error")

return function(app)
    app:use("/user",userRouter())
    app:get("/", commonRouter.index)
    app:get("/index", commonRouter.index)
    app:use("/error", errorRouter())

end

