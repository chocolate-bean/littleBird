--[[
    unity 原生系列
]]

function newObject(prefab)
	return UnityEngine.GameObject.Instantiate(prefab);
end

function destroy(obj)
	UnityEngine.GameObject.Destroy(obj);
	obj = nil
end

--[[
    工具方法
]]


function md5(input)
    input = tostring(input)
    return CSharpTools.md5(input)
end

function encodeBase64(input)
    -- input = tostring(input)
    -- return CSharpTools.Base64Encode(input)
    return base64.encode(input)
end

function decodeBase64(input)
    -- input = tostring(input)
    -- return CSharpTools.Base64Decode(input)
    return base64.decode(input)
end


--[[
    manager 内的方法
]]

function getRandomID()
    local randomID = ""
    math.randomseed(os.time());
    local words = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local wl = string.len(words)
    for i=1,32 do  
        local index = math.random(1,wl);
        randomID = randomID .. string.sub(words,index,index)
    end 
    return randomID
end

function appendMD5Value(ID)
    local md5 = md5(ID)
    local len = string.len(md5)
    ID = ID..string.sub(md5,1,4)..string.sub(md5,len-3,len)
    return ID
end
