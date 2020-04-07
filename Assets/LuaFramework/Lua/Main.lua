require("Bird.GameSurFaceScene")
--主入口函数。从这里开始lua逻辑
function Main()	
	-- 断点调试代码
	local fileName
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.OSXEditor then
		fileName = "LuaDebug"
	else
		fileName = "LuaDebugjit"
	end
	if fileName then
		local breakSocketHandle,debugXpCall = require(fileName)("localhost",7003)
		local timer = Timer.New(function() 
		breakSocketHandle() end, 1, -1, false)
		timer:Start();
    end
    
    print("bobo")
end

-- C#提供给Lua的生命周期
-- private LuaFunction onActiveSceneChanged;
-- private LuaFunction onSceneLoaded;
-- private LuaFunction onApplicationQuit;
-- private LuaFunction onBackClick;

-- 游戏启动
function OnInitOK()
	
	LuaFramework.Util.Log("OnInitOK--lua")
	-- 先引入需要用到的全局变量
	json = require("cjson")
	require("Core/functions")
	require("Core/define")
	require("CocosBridge/init")
	require("App/common/luaFunctions")
	-- require("3rd/pbc/protobuf")
    -- WebView = require("Core/WebView")
    require("Utils.init")
	-- 开始启动Lua逻辑
    -- require("Update.UpdateController").new()  
    
    GameSurFaceScene.ctor() 
    GameSurFaceScene.init()
end

function onActiveSceneChanged(sceneName)
	
	if GameManager then
		GameManager.sceneName = sceneName
		if GameManager.runningScene.creatView then
			GameManager.runningScene:creatView()
		end
	end
end

function onSceneLoaded(sceneName)
	if GameManager then
		GameManager.sceneName = sceneName
	end
end

function onApplicationQuit()
	
end

function onApplicationFocus(focus)
	if GameManager then
		GameManager:onApplicationFocus(focus)
	end
end

function onApplicationPause(pause)
	local message = ""
	if pause then
		message = T("暂停 程序进入到前台了")
	else
		message = T("暂停 程序退出到后台了")
	end
end

function onReturnKeyClick()
	-- 安卓返回键的点击事件
	Event.Brocast(EventNames.RETURN_CLICK)
end

function OnLevelWasLoaded(level)

end

function nativeErrorCallback(error)
	if error == "noWechat" then
		if GameManager and GameManager.TopTipManager then
			GameManager.TopTipManager:showTopTip(T("您还没有安装微信！"))
		end
	elseif error == "noAlipay" then
		if GameManager and GameManager.TopTipManager then
			GameManager.TopTipManager:showTopTip(T("您还没有安装支付宝！"))
		end
	end
end

function connected()
	if GameManager then
		GameManager.ServerManager.connected = true
		GameManager.ServerManager:loginGame()
	end
end

function receiveCallBack(receiveValue)
	if GameManager then
		GameManager.ServerManager:receiveCallBack(receiveValue)
	end
end

function networkErrorCallBack()
	if GameManager then
		GameManager.ServerManager:networkErrorCallBack()
	end
end

function playSound(type, param)
	if GameManager then
		GameManager:playSound(type, param)
	end
end

function topTips(string)
	if GameManager then
		GameManager.TopTipManager:showTopTip(string)
	end
end
