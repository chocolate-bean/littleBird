--获取整形版本号，比如版本1.3.0，返回1030000
function getAppVersionCode(version)
    --BM_UPDATE.VERSION 是四位的；ninek.Native:getAppVersion()是三位的大版本号
    if #(string.split(version, ".")) == 3 then
        version = version .. ".0"
    end
    return getVersionNum(version)
end

function getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end

function formatFiveNumber(num)

    local temp = tonumber(num)
    if not temp then return "0" end
    local sys = ""
    if temp < 0 then
        sys = "-"
    end
    temp = math.abs(num)
    local ret
    if math.log10(temp) >= 10 then
        temp = math.floor(((temp / 10^10) * 100) + 0.5) * 1
        ret = temp..T("亿")
    elseif math.log10(temp) >= 9 then
        temp = math.floor(((temp / 10^9) * 100) + 0.5) * 0.1
        ret = temp..T("亿")
    elseif math.log10(temp) >= 8 then
        temp = math.floor(((temp / 10^8) * 100) + 0.5) * 0.01
        ret = temp..T("亿")
    elseif math.log10(temp) >= 6 then
        temp = math.floor(((temp / 10^6) * 100) + 0.5) * 1
        ret = temp..T("万")
    elseif math.log10(temp) >= 5 then
        temp = math.floor(((temp / 10^5) * 100) + 0.5) * 0.1
        ret = temp..T("万")
    elseif math.log10(temp) >= 4 then
        temp = math.floor(((temp / 10^4) * 100) + 0.5) * 0.01
        ret = temp..T("万")
    else
        ret = temp
    end
    return sys..ret
end

-- function function_name(  )
--     
-- end

function fit(vector)
    local x, y = vector:Get()
    local screen = UnityEngine.GameObject.Find("Canvas")
    x = screen.transform.sizeDelta.x / 1280.0 * x
    y = screen.transform.sizeDelta.y / 720.0 * y
    return Vector2.New(x,y)
end

function fitX(vector)
    local x, y = vector:Get()
    local screen = UnityEngine.GameObject.Find("Canvas")
    x = screen.transform.sizeDelta.x / 1280.0 * x
    return Vector2.New(x,y)
end

function fitY(vector)
    local x, y = vector:Get()
    local screen = UnityEngine.GameObject.Find("Canvas")
    y = screen.transform.sizeDelta.y / 720.0 * y
    return Vector2.New(x,y)
end

function getScreenSize()
    local screen = UnityEngine.GameObject.Find("Canvas")
    return screen.transform.sizeDelta.x, screen.transform.sizeDelta.y
end

function vectorAdd(v1, v2)
    local x1, y1 = v1:Get()
    local x2, y2 = v2:Get()
    return Vector2.New(x1 + x2, y1 + y2)
end

function doFadeAutoShow(obj, component, time, delayTime, doneCallback)
    show(obj)
    doFade(true,obj,component,time,delayTime,doneCallback)
end


function doFadeShow(obj, component, time, delayTime, doneCallback)
    doFade(true,obj,component,time,delayTime,doneCallback)
end

function doFadeDismiss(obj, component, time, delayTime, doneCallback)
    doFade(false,obj,component,time,delayTime,function()
        hide(obj)
        if doneCallback then
            doneCallback()
        end
    end)
end

function doFade(isShow, obj, component, time, delayTime, doneCallback)

    if component == 'TextMeshProUGUI' then
        doFadeTMP(isShow, obj, time, delayTime, doneCallback)
        return
    end

    -- 渐变文字需要单独处理
    if obj:GetComponent('Gradient') then
        hide(obj)
        Timer.New(function()
            show(obj)
        end, delayTime , 1, true):Start()
        return
    end

    -- 文字里面是rich
    if component == 'Text' then
        local text = obj:GetComponent(component).text
        local result = string.find(text, "</color>")
        if result and result ~= 0 then
            hide(obj)
            Timer.New(function()
                show(obj)
            end, delayTime , 1, true):Start()
            return
        end
    end
    
    local r, g, b, a = obj:GetComponent(component).color:Get()
    obj:GetComponent(component).color = Color.New(r, g, b, isShow and 0 or 1)

    local animation = function()
        local colorAnimation = obj:GetComponent(component):DOColor(Color.New(r, g, b, isShow and 1 or 0), time)
        -- colorAnimation:SetEase(DG.Tweening.Ease.OutQuint)
        colorAnimation:OnComplete(function()
            if doneCallback then
                doneCallback()
            end
        end)
    end

    if delayTime == 0 then
        animation()
    else
        Timer.New(function()
            animation()
        end, delayTime , 1, true):Start()
    end
end

function doFadeTMP(isShow, target, time, delayTime, doneCallback)

    local originColor = TMPHelper.getTextColor(target)
    local r, g, b, a = originColor.r, originColor.g, originColor.b, originColor.a
    local endColor = Color.New(r, g, b, isShow and 1 or 0)
    local startColor = Color.New(r, g, b, isShow and 0 or 1)

    TMPHelper.setTextColor(target, startColor)

    local getter = DG.Tweening.Core.DOGetter_UnityEngine_Color(function(a, b)
        return startColor
    end)

    local setter = DG.Tweening.Core.DOSetter_UnityEngine_Color(function(intColor)
        TMPHelper.setTextColor(target, intColor)
        return intColor
    end)

    Timer.New(function()
        local x = DG.Tweening.DOTween.To(getter, setter, endColor, time)
        local y = x:SetEase(DG.Tweening.Ease.Linear)
        y:OnUpdate(function() end)
        y:OnComplete(function()
            if doneCallback then
                doneCallback()
            end
        end)
    end, delayTime, 1, true):Start()

end

function T(string)
    if false then
        local parseData
        parseData = function(mo_data)
            
            local byte=string.byte
            local sub=string.sub
    
            local peek_long --localize
            local magic=sub(mo_data,1,4)
            -- intel magic 0xde120495
            if magic=="\222\018\004\149" then
                peek_long=function(offs)
                    local a,b,c,d=byte(mo_data,offs+1,offs+4)
                    return ((d*256+c)*256+b)*256+a
                end
            -- motorola magic = 0x950412de
            elseif magic=="\149\004\018\222" then
                peek_long=function(offs)
                    local a,b,c,d=byte(mo_data,offs+1,offs+4)
                    return ((a*256+b)*256+c)*256+d
                end
            else
                return nil,"no valid mo-file"
            end
    
            local V=peek_long(4)
            if V~=0 then
                return nil,"unsupported version"
            end
    
            local N,O,T=peek_long(8),peek_long(12),peek_long(16)
    
            local hash={}
            for nstr=1,N do
                local ol,oo=peek_long(O),peek_long(O+4) O=O+8
                local tl,to=peek_long(T),peek_long(T+4) T=T+8
                hash[sub(mo_data,oo+1,oo+ol)]=sub(mo_data,to+1,to+tl)
            end
            return hash
        end
    
    
        local gettext
        gettext = function(mo_data)
            local hash = parseData(mo_data)
            return function(text)
                return hash[text] or text
            end
        end
    
        local path = Util.DataPath.."lua/3rd/i18n/zh_TW.mo"
    
        local fd,err = io.open(path,"rb")
        if not fd then 
            return nil,err 
        end
        local raw_data = fd:read("*all")
        fd:close()
    
        local mo_data=assert(parseData(raw_data))
        local str = mo_data[string] or string
    
        return str
    end
    return string
end


function GetUUID()
    local uuid = sdkMgr:GetUUID()

    if uuid == "" or uuid == nil then
        math.randomseed(os.time());
        local words = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        local wl = string.len(words)
        for i=1,32 do  
            local index = math.random(1,wl);
            uuid = uuid .. string.sub(words,index,index)
        end 
    end

    local uuid_md5 = crypto.md5(uuid)
    local len = string.len(uuid_md5)
    uuid = uuid..string.sub(uuid_md5,1,4)..string.sub(uuid_md5,len-3,len)
    return uuid
end

function GetStoreID()
    
    local storeid = sdkMgr:GetStoreID()

    if storeid == "" or storeid == nil then
        math.randomseed(os.time());
        local words = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        local wl = string.len(words)
        for i=1,32 do  
            local index = math.random(1,wl);
            storeid = storeid .. string.sub(words,index,index)
        end 
    end

    local storeid_md5 = crypto.md5(storeid)
    local len = string.len(storeid_md5)
    storeid = storeid..string.sub(storeid_md5,1,4)..string.sub(storeid_md5,len-3,len)
    return storeid
end

--[[
    @desc: 根据想要的长度自适应文本大小
    author: zhangyi
    time:2018-08-22 18:34:27
    --@text: Text物体
	--@wantWidth: 想要变成的宽度
    @return:
]]
function AutoTextSize(text,wantWidth)
    local curSizeWidth = text:GetComponent('Text').preferredWidth
    if curSizeWidth > wantWidth then
        local scale = wantWidth/curSizeWidth
        text.transform.localScale = Vector3.New(scale,scale,1)
        local curSzie = text.transform.sizeDelta
        text.transform.sizeDelta = Vector3.New(curSizeWidth,curSzie.y,0)
    end
end

-- 根据秒数获取时分秒
function formatTimer(second)
    local result = ""
    if second > 0 then
        local hour = math.floor(second/3600)
        local minute = math.floor((second - 3600 * hour)/60)
        local second = math.floor((second - 3600 * hour - 60 * minute) % 60)

        if string.len(minute) == 1 then
            minute = '0'..minute
        end

        if string.len(second) == 1 then
            second = '0'..second
        end

        if string.len(hour) == 1 then
            hour = '0'..hour
        end
        result = hour..':'..minute..':'..second
    end

    return result
end

function formatTimerForHour(second)
    local result = ""
    if second > 0 then
        -- 强行过滤掉天的影响，万一超过一天呢
        local hour = math.floor(second/3600)
        local minute = math.floor((second - 3600 * hour)/60)
        local second = math.floor((second - 3600 * hour - 60 * minute) % 60)

        if string.len(minute) == 1 then
            minute = '0'..minute
        end

        if string.len(second) == 1 then
            second = '0'..second
        end

        result = minute..':'..second
    end

    return result
end

function formatTimerForDay(second)
    local result = ""

    if second > 0 then
        local day = math.floor(second/86400);
        local hour = math.floor((second - 86400 * day)/3600)
        local minute = math.floor((second - 86400 * day - 3600 * hour) / 60)

        result = day..T("天")..hour..T("时")..minute..T("分")
    end

    return result; 
end

function isWZBY() 
    return AppConst.channelType == LuaFramework.ChannelType.WZBY
end

function isMZBY() 
    return AppConst.channelType == LuaFramework.ChannelType.MZBY  or
           AppConst.channelType == LuaFramework.ChannelType.TEST_MZBY
end

function isDBBY() 
    return AppConst.channelType == LuaFramework.ChannelType.DBBY
end

function isDFBY() 
    return AppConst.channelType == LuaFramework.ChannelType.DFBY or
           AppConst.channelType == LuaFramework.ChannelType.TEST_DFBY or
           AppConst.channelType == LuaFramework.ChannelType.TDBY
end

function isFKBY()
    return AppConst.channelType == LuaFramework.ChannelType.FKBY
end

function isOPPO() 
    return AppConst.sidConfig == LuaFramework.SidConfig.OPPO
end

function isVIVO() 
    return AppConst.sidConfig == LuaFramework.SidConfig.VIVO
end

function IS_APPLE_OFFICIAL() 
    return AppConst.sidConfig == LuaFramework.SidConfig.APPLE
end

function isAndorid() 
    return UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android
end

