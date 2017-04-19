--
-- Created by IntelliJ IDEA.
-- User: zhaoqing
-- Date: 17-3-23
-- Time: 下午2:21
-- To change this template use File | Settings | File Templates.
--

local lor = require("lor.index")
--local lor = xpcall(require,"lor.index")
local adminUser = lor:Router()

local json = require("cjson")

local user = require("app.model.user")

local utils = require("app.libs.utils")

--查询用户
--e.g.  /get/123
adminUser:get("/get/:id",function(req,res,next)
    --ngx.say("查看用户信息");
    res:render("admin/user_detail")
end)


--获取用户列表
--e.g. /list
adminUser:get("/list",function(req,res,next)
    --@todo 获取用户列表
    local flag,err,data = user:userList();
    --ngx.say(json.encode(res.locals.user))
    res:render('admin/user_list',{data=data,user=res.locals.user})
end)

--获取用户添加/更新页面
adminUser:get("/view",function(req,res,next)
    --ngx.say("get the view of add/update")
    local flag = tostring(req.query.flag) or nil
    local errFlag = tostring(req.query.errFlag) or nil
    local errMsg = tostring(req.query.errMsg) or nil
    local id = tonumber(req.query.id) or nil
    local params = {flag=flag,errFlag=errFlag,errMsg=errMsg,id = id}
    --@todo 更新操作获取用户待更改信息
    if (flag=='update' or flag==nil) and id then
        --@todo 获取用户信息
        local data,no_err = user:get(id)

        if data and no_err then
            --ngx.say("data:",json.encode(data),"msg:",msg)
            params["data"] = data
        else
           res:redirect("/ause/list")
        end

    end
    res:render("admin/user_detail",params)
end)

--添加用户信息
--e.g. /add
adminUser:post("/add",function(req,res,next)
    --验证用户名
    local username = req.body.username or nil
    local username_data = string.match(username,"%a+%w+")
    if username_data then
         username = username_data
    else
        res:redirect("/ause/view",{flag="add",errFlag="username",errMsg="用户名格式错误"})
    end
    --查询用户是否存在
    local is_exists,msg = user:is_exists(username)
    if is_exists then
        res:redirect("/ause/view",{flag="add",errFlag="username",errMsg="该用户名已存在请重新输入"})
    end

    --验证邮箱
    local email = req.body.email or nil
    ngx.log(ngx.ERR,"email:"..email)
    local email_data = string.match(email,"%w+@%w+%p%w+")
    ngx.log(ngx.ERR,"email_data:"..json.encode(email_data))
    if email_data then
         email = email_data
    else
        res:redirect("/ause/view",{flag="add",errFlag="email",errMsg="邮箱格式错误"})
    end

    --验证手机号码
    local mobile = req.body.mobile or nil
    ngx.log(ngx.ERR,"mobile:"..mobile)
    local mobile_data =string.match(mobile,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d")
    if mobile_data then
        local mobile = mobile_data
    else
        res:redirect("/ause/view",{flag="add",errFlag="mobile",errMsg="手机格式错误"})
    end

    --验证输入密码
    local password = req.body.password or nil
    if not password then
        res:redirect("/ause/view",{flag="add",errFlag="password",errMsg="密码不能为空"})
    end
    --验证输入真实姓名
    local name = req.body.name or nil
    if not name then
        res:redirect("/ause/view",{flag="add",errFlag="name",errMsg="真实姓名不能为空"})
    end

    --用户等级
    local grade = req.body.grade or 1
    local data = {
        username = username,
        email    = email,
        mobile   = mobile,
        password = password,
        name     = name,
        grade    = grade
    }
    ngx.log(ngx.ERR,'pre_info:'..json.encode(data))

    --添加新用户到数据库中
    local flag,msg,data = user:add(data)
    --[[ngx.say("flag:",flag)
    ngx.say("msg:",msg)
    if res then
        ngx.log(ngx.ERR,'add info :'..json.encode(res))
    end]]
    if flag then
        --@todo 创建用户成功
        res:redirect("/ause/vimg/"..data,{flag="add"})
    else
        --@todo 创建用户失败
        res:redirect("/ause/view",{flag="add",errFlag="username",errMsg="信息提交失败，请重新尝试"})
    end




    --[[if req.body and type(req.body) == 'table' then
        for i,v in paris(req.body) do
            ngx.say("i:",i,"v",v)
        end
    else
        ngx.say("add user info")
    end]]
end)

--选择上传图片展示页面
--e.g. /vimg
adminUser:get("/vimg/:id",function(req,res,next)
    local id = tonumber(req.params.id) or nil
    local flag = tostring(req.query.flag) or nil
    if not id or id == nil then
        res:redirect("/list")
    else
        res:render("/admin/user_image",{id=id,flag=flag})
    end
end)

--上传图片文件
--e.g. /image
adminUser:post("/image",function(req,res,next)
     --[[ngx.log(ngx.ERR,json.encode(req.file))]]
     --[[ {"path":"\/home\/zhaoqing\/myblog\/app\/static\/img\/myblog1662322.jpg","extname":"jpg","success":true,"filename":"myblog1662322.jpg","origin_filename":"梦想.jpg"}]]
    local path = req.file.filename or nil
    local id = req.query.id or nil

    if not id then
        res:redirect("/ause/list")
    end

    if not path and id then
        res:redirect("/ause/vimg/"..id,{flag='add'})
    end

    --添加头像到用户信息
    local data = {
        images = path,
        id = id
    }
    local flag,err,data = user:update(data)
    if flag then
        res:redirect("/ause/list",{flag="add_success"})
    else
        res:redirect("/ause/vimg/"..id,{flag='add'})
    end
end)

--修改用户信息
--e.g. /update
adminUser:post("/update",function(req,res,next)
    local id = req.body.id or nil
    if not id then
        res:redirect("/ause/list")
    end
    --验证用户名
    local username = req.body.username or nil
    local username_data = string.match(username,"%a+%w+")
    if username_data then
        username = username_data
    else
        res:redirect("/ause/view",{flag="update",id=id,errFlag="username",errMsg="用户名格式错误"})
    end
    --查询用户是否存在
    --[[local is_exists,msg = user:is_exists(username)
    if is_exists then
        res:redirect("/ause/view",{flag="add",errFlag="username",errMsg="该用户名已存在请重新输入"})
    end]]

    --验证邮箱
    local email = req.body.email or nil
    ngx.log(ngx.ERR,"email:"..email)
    local email_data = string.match(email,"%w+@%w+%p%w+")
    ngx.log(ngx.ERR,"email_data:"..json.encode(email_data))
    if email_data then
        email = email_data
    else
        res:redirect("/ause/view",{flag="update",id=id,errFlag="email",errMsg="邮箱格式错误"})
    end

    --验证手机号码
    local mobile = req.body.mobile or nil
    ngx.log(ngx.ERR,"mobile:"..mobile)
    local mobile_data =string.match(mobile,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d")
    if mobile_data then
        local mobile = mobile_data
    else
        res:redirect("/ause/view",{flag="update",id=id,errFlag="mobile",errMsg="手机格式错误"})
    end

    --验证输入密码
    local password = req.body.password or nil
    if not password then
        res:redirect("/ause/view",{flag="update",id=id,errFlag="password",errMsg="密码不能为空"})
    end
    --验证输入真实姓名
    local name = req.body.name or nil
    if not name then
        res:redirect("/ause/view",{flag="update",id=id,errFlag="name",errMsg="真实姓名不能为空"})
    end

    --用户等级
    local grade = req.body.grade or 1
    local data = {
        username = username,
        email    = email,
        mobile   = mobile,
        password = password,
        name     = name,
        grade    = grade,
        id       = id,
    }
    ngx.log(ngx.ERR,'pre_info:'..json.encode(data))

    --添加新用户到数据库中
    local flag,msg,data = user:update(data)
    --[[ngx.say("flag:",flag)
    ngx.say("msg:",msg)
    if res then
        ngx.log(ngx.ERR,'add info :'..json.encode(res))
    end]]
    if flag then
        --@todo 修改用户成功
        res:redirect("/ause/vimg/"..id,{flag="update"})
    else
        --@todo 修改用户失败
        res:redirect("/ause/view",{flag="update",id=id,errFlag="username",errMsg="信息提交失败，请重新尝试"})
    end
end)

--验证信息修改
adminUser:post("/validate",function(req,res,next)
    local id = req.body.id or nil
    local validate = req.body.validate or nil
    local headers = req.headers or nil
    local headers_raw = ngx.req.get_headers() or nil
    local result = {success=false,msg="操作失败" }
    if not headers["x-requested-with"] or headers["x-requested-with"] ~= "XMLHttpRequest" then
        res:json(result)
    end

    if id then
        local valid = '1';
        if tonumber(validate) >= 1 then
            valid = '0';
        end

        local params = {
            id=id,
            validate=valid
        }
        local flag,ems,data = user:update(params)
        if flag then
            result["success"] = true
            result["flag"] = valid
            result["msg"] = "修改成功"
        end
        res:json(result)
    else
        result["msg"] = "修改成功"
        res:json(result)
    end
end)

--删除用户信息
--e.g. /delete/1
adminUser:get("/delete/:id",function(req,res,next)
    local id = tonumber(req.params.id) or nil
    local result = {success=false,msg=''}
    if id then
        local flag,msg,data = user:delete(id)
        if flag then
            result["success"] = true
            result["msg"] = msg
        end
    end

    res:json(result)
end)

--登录用户页面展示
--e.g. /login
adminUser:get("/login",function(req,res,next)
    res:render("/admin/login")
end)

--异步验证码获取
--e.g. /flush
adminUser:get("/flush",function(req,res,next)
    local result = {success=false,msg="操作失败" }
    local headers = req.headers or nil
    if not headers["x-requested-with"] or headers["x-requested-with"] ~= "XMLHttpRequest" then
        res:json(result)
    end

    local code_str,flag = utils.validate_code(4)

    if not code_str or flag==false then
        result['msg'] = "验证码获取失败,请重新尝试!"
    else
        req.session.set("loginCode", code_str)
        --ngx.log(ngx.ERR," logining code:"..req.session.get("loginCode"))
        result['success'] = true
        result["msg"] = "成功"
        result['code'] = code_str
    end
    res:json(result)
end)


--lor 3.0.0以上的版本才能使用
   --[[ --判断是否是异步请求(asynchronous)
    local is_asyn = function(req,res,next)
        local result = {success=false,msg="操作失败" }
        local headers = req.headers or nil
        if not headers["x-requested-with"] or headers["x-requested-with"] ~= "XMLHttpRequest" then
            res:json(result)
        end
        next()
    end

    --登录判断验证码时候正确
    local check_code = function(req,res,next)
        local input_code = tostring(req.body.code) or nil
        if not input_code then
            res:json({success=false,msg="验证码不能为空"})
        end
        local session_code = tosting(req.session.get("loginCode")) or nil
        if not session_code or session_code == "" then
            res:json({success=false,msg="验证码不能为空"})
        end
        ngx.log(ngx.ERR,"check_code params:".."session:"..session_code.." code:"..input_code)

        if string.lower(session_code)==string.lower(input_code) then
            next()
        else
            res:json({success=false,msg="输入验证码错误"})
        end
    end

    --用户信息验证
    local check_user = function(req,res,next)
        --@todo 根据信息获取用户信息
        local username = tostring(req.body.username) or nil
        local password = tostring(req.body.password) or nil
        if not username or not password then
            res:json({success=false,msg="用户名或密码错误"})
        end
        local flag , msg , data = user:login(username,password)
        if flag then
            --登录成功
            req.session.set('user',json.encode(data))
        else
            res:json({success=false,msg="用户名或密码错误"})
        end

    end
    --验证验证码是否正确
    local response_validate = function(req,res,next)
        local code_s = req.session.get("loginCode") or nil
        local code_i = req.body.code or nil
        res.json({success=true,msg="成功",codes=code_s,codei=code_i});
    end

--验证验证码是否正确
--e.g. /validate
adminUser:post("/validateCode",{is_asyn,check_code},response_validate)]]

--验证验证码是否正确
--e.g. /validateCode
adminUser:post("/validateCode",function(req,res,next)
    local result = {success=false,msg="操作失败" }
    local headers = req.headers or nil
    if not headers["x-requested-with"] or headers["x-requested-with"] ~= "XMLHttpRequest" then
        res:json(result)
    end

    local input_code = tostring(req.body.code) or nil
    if not input_code then
        res:json({success=false,msg="验证码不能为空"})
    end
    local session_code = req.session.get("loginCode") or nil
    if not session_code or session_code == "" then
        res:json({success=false,msg="验证码不能为空"})
    end
    ngx.log(ngx.ERR,"check_code params:".."session:"..session_code.." code:"..input_code)

    if string.lower(session_code)==string.lower(input_code) then
        local code_s = req.session.get("loginCode") or nil
        local code_i = req.body.code or nil
        res:json({success=true,msg="成功",codes=code_s,codei=code_i});
    else
        res:json({success=false,msg="输入验证码错误"})
    end

end)

--登录信息异登录
--e.g. /logining
adminUser:post("/logining",function(req,res,next)
    local result = {success=false,msg="操作失败" }
    local headers = req.headers or nil
    if not headers["x-requested-with"] or headers["x-requested-with"] ~= "XMLHttpRequest" then
        res:json(result)
    end

    local input_code = tostring(req.body.code) or nil
    if not input_code then
        res:json({success=false,msg="验证码不能为空"})
    end
    local session_code = req.session.get("loginCode") or nil
    if not session_code or session_code == "" then
        res:json({success=false,msg="验证码不能为空"})
    end

    if string.lower(session_code)==string.lower(input_code) then
        --@todo 根据信息获取用户信息
        local username = tostring(req.body.username) or nil
        local password = tostring(req.body.password) or nil
        if not username or not password then
            res:json({success=false,msg="用户名或密码错误!!!"})
        end
        local flag , msg , data = user:login(username,password)
        if flag then
            --登录成功
            req.session.set('user',data)
            ngx.log(ngx.ERR,"user logined params:"..json.encode(data))
            res:json({success=true,msg="成功",data=data});
        else
            res:json({success=false,msg="用户名或密码错误"})
        end
    else
        res:json({success=false,msg="输入验证码错误"})
    end
end)



return adminUser
