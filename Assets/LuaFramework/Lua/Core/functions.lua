
--输出日志--
function log(str)
    Util.Log(str);
end

--错误日志--
function logError(str) 
	Util.LogError(str);
end

--警告日志--
function logWarn(str) 
	Util.LogWarning(str);
end

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
	GameObject.Destroy(obj);
	obj = nil
end

function newObject(prefab)
	return GameObject.Instantiate(prefab);
end

function showOrHide(isShow, objOrList)
	if isShow then
		show(objOrList)
	else
		hide(objOrList)
	end
end

function hide(objOrList)
	if type(objOrList) == "userdata" then
		objOrList:SetActive(false)
	elseif type(objOrList) == "table" then
		for _, v in ipairs(objOrList) do
			v:SetActive(false)
		end
	end
end

function show(objOrList)
	if type(objOrList) == "userdata" then
		objOrList:SetActive(true)
	elseif type(objOrList) == "table" then
		for _, v in ipairs(objOrList) do
			v:SetActive(true)
		end
	end
end

function handler(obj, method)
    return function(...)
        if obj and method and ((type(obj) =="userdata" and not tolua.isnull(obj)) or type(obj) ~="userdata") then
            return method(obj, ...)
        end
    end
end

function buttonSoundHandler(obj, method,soundId)
	return function(...)
		if GameManager.SoundManager then
			GameManager.SoundManager:PlaySound("clickButton")
		end
      	if method then
        	return method(obj, ...)
      	end  	
    end
end

-- 这个我也不会写
-- 写两个看看
function removeAllChild(gameObject) 
	Util.ClearChild(gameObject);
end

function addClick(gameObject, func)
    
    UIHelper.AddButtonClick(gameObject,func)
end

function platformIsIPhone()
    return UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
end

function platformIsWindowsPlayer()
    return UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer
end

-- function shadow_(obj)
-- 	local count = obj.transform:GetChildCount()
-- 	for index = 0, count - 1 do
-- 		-- obj.transform:GetChild(index).
-- 	end
-- end

-- function shadow(objOrList)
-- 	if type(objOrList) == "userdata" then
-- 		objOrList:SetActive(true)
-- 	elseif type(objOrList) == "table" then
-- 		for _, v in ipairs(objOrList) do
-- 			v:SetActive(true)
-- 		end
-- 	end
-- end