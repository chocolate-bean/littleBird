local UpdateController = class("UpdateController")

function UpdateController:ctor()
    LuaFramework.Util.Log("UpdateController:ctor")
    self:OnLoadFinish()
end

function UpdateController:OnLoadFinish()
    
    -- 此处用不到Update函数
    -- UpdateBeat:Add(self.Update, self)
    IdentityManager:trySomething(function ()
        coroutine.start(function ()
            self:checkUpdateConfig()
        end)
    end)
end

function UpdateController:checkUpdateConfig()
    
    local url = AppConst.CheckUrl
    local param = {
        device        = "windows",
        pay           = "windows",
        noticeVersion = "noticeVersion",
        osVersion     = AppConst.OsVersion,
        version       = AppConst.Version,
        sid           = IdentityManager.Sid,
        gid           = 7,
        lid           = 2,
        server        = AppConst.ServerId,
    }

    for k,v in pairs(param) do
        url = url.."&"..k.."="..v
    end

    print(url)

    local WWW = UnityEngine.WWW;
    local www = WWW(url);
    coroutine.www(www);
    -- logWarn(www.text);

    if www.error == nil then
        local phpData = json.decode(www.text)
        self:onCheckSuccess(www.text)

    else
        print("获取版本信息失败")
    end
end

function UpdateController:getVersionNum(version, num)
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

function UpdateController:onCheckSuccess(data)
    sdkMgr:GetIMEI(function(IMEI)
        local DataKeys   = require("App/keys/DATA_KEYS")
        if IMEI and IMEI ~= "error" then
            UnityEngine.PlayerPrefs.SetString(DataKeys.IMEI, IMEI)
        else
            UnityEngine.PlayerPrefs.SetString(DataKeys.IMEI, "")
        end
    end)

    sdkMgr:GetIDFA(function(IDFA)
        local DataKeys   = require("App/keys/DATA_KEYS")
        if IDFA and IDFA ~= "error" then
            UnityEngine.PlayerPrefs.SetString(DataKeys.IDFA, IDFA)
        else
            UnityEngine.PlayerPrefs.SetString(DataKeys.IDFA, "")
        end
    end)

    -- UnityEngine.PlayerPrefs.SetString(DataKeys.IMEI, "123456789")
    -- UnityEngine.PlayerPrefs.SetString(DataKeys.IDFA, "123456789")

    local retData = data and json.decode(data) or nil
    if retData then
        local svrVersion = retData.curVersion
        local svrVerTitle = retData.verTitle
        local svrVerMsg = retData.verMessage
        local svrStoreURL = retData.updateUrl
        local svrIsForce = (checknumber(retData.isForce) ~= 0)
        local md5 = retData.md5

        if retData.isHotUpdateForce and checknumber(retData.isHotUpdateForce) ~= 0 then
            self.isHotUpdateForce = true
        end

        local isHotUpdate = retData.isHotUpdate == 1
        local isVersionUpdate = retData.isVersionUpdate == 1  -- 是否大版本版本更新

        local checkNotice = function()
            if retData.notification == nil or next(retData.notification) == nil then
                self:endUpdate(retData)
            else
                -- 这里是需要弹出公告
                local PanelLoginDialog = import("Panel.Dialog.PanelLoginDialog").new(false,retData.notification.content,function()
                    if svrIsForce then
                        UnityEngine.Application.Quit()
                    else
                        self:endUpdate(retData)
                    end
                end)
            end
        end

        local OnUpdateClick = function()
            -- 调用C#的方法去下载更新
            if platformIsIPhone() then
                UnityEngine.Application.OpenURL(svrStoreURL)
            else
                wwwMgr:DownloadAPK(svrStoreURL,md5)
            end
        end

        local OnCancleUpdateClick = function()
            if svrIsForce then
                UnityEngine.Application.Quit()
            else
                checkNotice()
            end
        end

        -- 如果需要大版本更新
        if isVersionUpdate then
            local PanelLoginDialog = import("Panel.Dialog.PanelLoginDialog").new(true,svrVerMsg,OnUpdateClick,OnCancleUpdateClick)
        else
            checkNotice()
        end
    end
end

function UpdateController:endUpdate(data)
    -- 导出全局变量
    BM_UPDATE = {}
    BM_UPDATE.LOGIN_URL = data.loginUrl or ""
    BM_UPDATE.PHONE_REG = data.phoneReg
    BM_UPDATE.CURVERSION = AppConst.OsVersion
    BM_UPDATE.PHONESID = data.phoneOpenSwitch
    dump(BM_UPDATE.PHONESID)

    self:setDefultPlayerPrefs()

    GameManager = require("GameManager").new()
end

function UpdateController:setDefultPlayerPrefs()
    -- if not UnityEngine.PlayerPrefs.HasKey(DataKeys.MUSIC) then
    --     UnityEngine.PlayerPrefs.SetInt(DataKeys.MUSIC, 0)
    -- end

    -- if not UnityEngine.PlayerPrefs.HasKey(DataKeys.SOUND) then
    --     UnityEngine.PlayerPrefs.SetInt(DataKeys.SOUND, 0)
    -- end

    -- if not UnityEngine.PlayerPrefs.HasKey(DataKeys.IS_3D) then
    --     UnityEngine.PlayerPrefs.SetInt(DataKeys.IS_3D, 0)
    -- end
    
    -- if not UnityEngine.PlayerPrefs.HasKey(DataKeys.FISH_QUALITY) then
    --     UnityEngine.PlayerPrefs.SetInt(DataKeys.FISH_QUALITY, 2)
    -- end
end

return UpdateController