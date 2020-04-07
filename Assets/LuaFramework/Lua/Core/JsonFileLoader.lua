local JsonFileLoader = class("JsonFileLoader")

function JsonFileLoader:ctor()

end

function JsonFileLoader:cacheFile(url,callback)
    local hash = crypto.md5(url)
    local path = UnityEngine.Application.persistentDataPath.."/"..hash

    if io.exists(path) then
        local json = io.readfile(path)

        if json then
            callback(true,json)
        else
            callback(false,nil)
        end
    else
        -- coroutine.start(function ()
        --     local www = WWW(url)
        --     coroutine.www(www)
        --     if www.error == nil then
        --         local json = www.text
                
        --         io.writefile(path,json)

        --         callback(true,json)
        --     else
        --         callback(false,nil)
        --     end
        -- end)

        wwwMgr:RequestHttpGET(url,function(error,data)
            if error then
                callback(false,nil)
            else
                local json = data
                io.writefile(path,json)
                callback(true,json)
            end
        end)
    end
    
end

return JsonFileLoader