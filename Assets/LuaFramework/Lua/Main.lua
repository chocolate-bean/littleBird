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
function OnInitOk(  )
    print("OnInitOk")
end

--场景切换通知
function OnLevelWasLoaded(level)
    print("场景切换")
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end