local HttpService = {}

HttpService.defaultURL = ""
HttpService.defaultParams = {}

function HttpService.getDefaultURL()
    return HttpService.defaultURL
end

function HttpService.setDefaultURL(url)
    HttpService.defaultURL = url
end

function HttpService.clearDefaultParameters()
    HttpService.defaultParams = {}
end

function HttpService.setDefaultParameter(key, value)
    HttpService.defaultParams[key] = value;
end

function HttpService.cloneDefaultParams(params)
    if params ~= nil then
        table.merge(params, HttpService.defaultParams)
        return params
    else
        return clone(HttpService.defaultParams)
    end
end

local function request_(method, url, addDefaultParams, params, resultCallback, errorCallback)
    local url = url

    local allParams
    if addDefaultParams then
        allParams = HttpService.cloneDefaultParams()
        table.merge(allParams, params)
    else
        allParams = params
    end

    if method == "POST" then
        local form = UnityEngine.WWWForm.New()
        for k,v in pairs(allParams) do
            form:AddField(tostring(k),tostring(v))
        end
        wwwMgr:RequestHttpPOST(url,form,function(error,data)
            if error then
                errorCallback(data)
            else
                resultCallback(data)
            end
        end)
    else
        for k,v in pairs(allParams) do
            url = url.."&"..k.."="..v
        end
        wwwMgr:RequestHttpGET(url,function(error,data)
            if error then
                errorCallback(data)
            else
                resultCallback(data)
            end
        end)
    end

    return nil
end

--[[
    GET到默认的URL，并附加默认参数
]]
function HttpService.GET(params, resultCallback, errorCallback)
    return request_("GET", HttpService.defaultURL, true, params, resultCallback, errorCallback)
end

--[[
    POST到默认的URL，并附加默认参数
]]
function HttpService.POST(params, resultCallback, errorCallback)
    return request_("POST", HttpService.defaultURL, true, params, resultCallback, errorCallback)
end

--[[
    GET到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.GET_URL(url, params, resultCallback, errorCallback, timeOut)
    return request_("GET", url, false, params, resultCallback, errorCallback)
end

--[[
    POST到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用HttpService.cloneDefaultParams初始化
]]
function HttpService.POST_URL(url, params, resultCallback, errorCallback, timeOut)
    return request_("POST", url, false, params, resultCallback, errorCallback)
end

return HttpService