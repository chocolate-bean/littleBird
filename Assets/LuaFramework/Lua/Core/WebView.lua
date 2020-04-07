local WebView = class("WebView")

function WebView:ctor()
end

--[[
    @desc: 调用原生WebView
    author:{author}
    time:2018-10-31 10:57:33
    --@url: 链接地址
    @return:
]]
function WebView:OpenUrl(url)
    sdkMgr:OpenWebView(url, function(url)
        print("Lua:"..url)
        self:onMessageReceived(url)
    end)
end

--[[
    @desc: 网页加载成功的回调
    author:{author}
    time:2018-10-30 12:32:33
    --@webViewGameObject:物体,用于需要时销毁
	--@statusCode:状态码
	--@url: 链接URL
    @return:
]]
function WebView:onLoadSuccess()

end

--[[
    @desc: 和Unity3D进行交互
    author:{author}
    time:2018-10-30 12:35:05
    --@webViewGameObject:物体,用于需要时销毁
	--@command:命令，用于跳转
	--@args: 命令携带的参数
    @return:
]]
function WebView:onMessageReceived(command)
    if command then
        -- local command = string.SubUrl(url, "//", "?")
        print(command)
        GameManager.ActivityJumpConfig:Jump(command)
    end
end

return WebView