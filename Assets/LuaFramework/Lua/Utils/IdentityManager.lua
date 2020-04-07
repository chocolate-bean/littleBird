--[[
    主要是用来请求一些特征值
    UUID IDFA StoreID IMEI Sid
]]

require("Core.csharp")

local IdentityManager = class("IdentityManager")
local DATA_KEYS       = require("App.keys.DATA_KEYS")

IdentityManager.CONST = {
    IDFA    = "IDFA",
    IMEI    = "IMEI",
    UUID    = "UUID",
    StoreID = "StoreID",
    OAID    = "OAID",
    Sid     = "Sid",
}

function IdentityManager:ctor()
    self.IDFA    = ""
    self.IMEI    = ""
    self.UUID    = ""
    self.StoreID = ""
    self.OAID    = ""
    self.Sid     = ""
end

function IdentityManager:GetReadPhoneStatePermission(callback)
    nativeMgr:FromLua("plugin_base", json.encode({
        method = "GetReadPhoneStatePermission",
        sends = {
            "权限申请"
        }
    }), function(remandBoxString)
        self:GetReadWriteStoragePermission(callback)
    end)
end

function IdentityManager:GetReadWriteStoragePermission(callback)
    nativeMgr:FromLua("plugin_base", json.encode({
        method = "GetReadWriteStoragePermission",
        sends = {
            "权限申请"
        }
    }), function(remandBoxString)
        local remandBox = json.decode(remandBoxString)
        --dump(remandBox)
        if remandBox.error then
            print("回调失败 "..remandBoxString)
        else
            print("回调回成功")
            self:trueTrySomething(callback)
        end
    end)
end

function IdentityManager:trySomething(callback)
    print("拿取想要的一些id")
        --兼容Android10 拿取 oaid
        print("系统版本   "..UnityEngine.SystemInfo.operatingSystem)
        print("系统版本   "..string.getAndroidAPI(UnityEngine.SystemInfo.operatingSystem))
        if isAndorid() and string.getAndroidAPI(UnityEngine.SystemInfo.operatingSystem) >= 23 then
    
            print("调用IdentityManagers")
            self:GetReadPhoneStatePermission(callback)

        else
          self:trueTrySomething(callback)
    end
end


function IdentityManager:trueTrySomething(callback)

    printCallback = function()
        print("获取到的 ids 值为 --------------------------------------------------------- ")
        for _, id in pairs(IdentityManager.CONST) do
            printf("%s: %s", id, self:isNullOrEmpty(self[id]) and "空" or self[id])
        end
        print(" --------------------------------------------------------- ")
        if callback then
            callback()
        end
    end

    self:tryGetFromLocal()

    local checkIds = {}
    if isAndorid() then
        checkIds = {
            IdentityManager.CONST.UUID,
            IdentityManager.CONST.StoreID,
            IdentityManager.CONST.Sid,
            IdentityManager.CONST.IMEI,
        }
        if string.getAndroidAPI(UnityEngine.SystemInfo.operatingSystem) >= 29 then
            checkIds[#checkIds + 1] = IdentityManager.CONST.OAID
        end
    end
    local done = true
    local sendIds = {}
    for _, id in ipairs(checkIds) do
        if self:isNullOrEmpty(self[id]) then
            sendIds[#sendIds + 1] = id
            done = false
        end
    end
    dump(sendIds, "尝试去获取的id")
    if true then
       
        local box = {
            method = "GetIdentitys",
            sends = checkIds
        }
        nativeMgr:FromLua("plugin_identify", json.encode(box), function(remandBoxString)
            local remandBox = json.decode(remandBoxString)
            dump(remandBox)
            if remandBox.error then
                print(remandBox.error)
                self:setRandom()
                printCallback()
            else
                local remand = json.decode(remandBox.remand)
                for index, id in ipairs(sendIds) do
                    if id == IdentityManager.CONST.StoreID or id == IdentityManager.CONST.UUID then
                        self[id] = appendMD5Value(remand[id])
                    else
                        self[id] = remand[id]
                    end
                end
                -- if isAndorid() and string.getAndroidAPI(UnityEngine.SystemInfo.operatingSystem) >= 29 then
                --     if self.OAID then
                --         print(string.format("第%d次获取到了oaid: %s", self.testOAIDCount, self.OAID))
                --         printCallback()
                --     else
                --         print(string.format("失败！！！当前第%d次", self.testOAIDCount))
                --         if self.testOAIDCount >= 0 then
                --             self.testOAIDCount = self.testOAIDCount - 1
                --             Timer.New(function ()
                --                 self:trueTrySomething(callback)
                --             end, 1, 1, true):Start()
                --         else
                --             printCallback()
                --         end
                --     end
                -- else
                --     printCallback()
                -- end
                printCallback()
            end
            self:save()
        end)
    else
        printCallback()
    end
    
end

function IdentityManager:setRandom()
    self.UUID    = appendMD5Value(UnityEngine.SystemInfo.deviceUniqueIdentifier)
    self.StoreID = appendMD5Value(UnityEngine.SystemInfo.deviceUniqueIdentifier)
    self.IDFA    = ""
    self.IMEI    = ""
    self.Sid     = "1"
    self.OAID    = ""
end

--从本地获取保存的相关id
function IdentityManager:tryGetFromLocal()
    self.UUID    = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.UUID)
    self.StoreID = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.STORE_ID)
    self.IDFA    = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.IDFA)
    self.IMEI    = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.IMEI)
    self.Sid     = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.SID)
    self.OAID    = UnityEngine.PlayerPrefs.GetString(DATA_KEYS.OAID)
end

--将相关的id保存在本地
function IdentityManager:save()
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.UUID, self.UUID)
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.STORE_ID, self.StoreID)
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.IDFA, self.IDFA)
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.IMEI, self.IMEI)
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.SID, self.Sid)
    UnityEngine.PlayerPrefs.SetString(DATA_KEYS.OAID, self.OAID)
end

function IdentityManager:isNullOrEmpty(str)
    return str == nil or string.len(str) == 0
end

return IdentityManager