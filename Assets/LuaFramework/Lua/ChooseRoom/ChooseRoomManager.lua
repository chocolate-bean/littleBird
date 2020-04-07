local ChooseRoomManager = class( "ChooseRoomManager")

function ChooseRoomManager:setCurrentConfig(data)
    self.currentPlayType = data.playType
end

function ChooseRoomManager:setRoomSwitch(switch)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.ROOM_SWITCH, switch)
end

function ChooseRoomManager:getRoomSwitch()
    return UnityEngine.PlayerPrefs.GetInt(DataKeys.ROOM_SWITCH) or 0
end

function ChooseRoomManager:setRoomList(roomList)
    UnityEngine.PlayerPrefs.SetString(DataKeys.ROOM_CONFIG, json.encode(roomList))
end

function ChooseRoomManager:getRoomList()
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.ROOM_CONFIG)
    if string and string ~= "" then
        return json.decode(string)
    end
    return {}
end

function ChooseRoomManager:setRoomVersion(version)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.ROOM_VERSION, version)
end

function ChooseRoomManager:getRoomVersion()
    return UnityEngine.PlayerPrefs.GetInt(DataKeys.ROOM_VERSION) or 0
end

function ChooseRoomManager:setPrePlayData(data)
    UnityEngine.PlayerPrefs.SetString(DataKeys.PRE_PLAY_DATA, json.encode(data))
end

function ChooseRoomManager:getPrePlayData()
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.PRE_PLAY_DATA)
    if string and string ~= "" then
        return json.decode(string)
    end
    return {}
end

function ChooseRoomManager:getRoomConfigByLevel(level)
    local currentRoomConfig = self:getRoomList()
    local roomConfig = {}
    for _, playTypeList in ipairs(currentRoomConfig) do
        for _, playLevelList in ipairs(playTypeList) do
            for _, playerCountList in ipairs(playLevelList) do
                for _, config in ipairs(playerCountList) do
                    if tostring(config.level) == tostring(level) then
                        roomConfig = config
                        break
                    end
                end
            end
        end
    end
    return roomConfig
end

function ChooseRoomManager:updateRoomList(callback)
    local version = self:getRoomVersion()
    http.getRoomList(
        version,
        function(retData)
            table.append(retData.list, retData.pokeng_list)
            if retData.list and #retData.list > 0 then
                self:setRoomList(retData.list)
            end
            self:setRoomVersion(retData.version)
            self:setRoomSwitch(retData.switch)
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )  
end

function ChooseRoomManager:getSlotsConfig(callback)
    http.getSlotsConfig(
        function(retData)
            self.slotsConfig = retData
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )  
end

function ChooseRoomManager:getNiuniuConfig(callback)
    http.getNiuNiuRoomConfig(
        function(retData)
            self.niuniuConfig = retData
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )  
end

function ChooseRoomManager:getDouniuConfig(callback)
    http.getNormalNiuConfig(
        function(retData)
            self.douniuConfig = retData
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )  
end

--[[
    捕鱼
]]

-- 这个配置主要是 鱼相关的
function ChooseRoomManager:getFishingConfigJson(jsonFileUrl)
    GameManager.JsonFileLoader:cacheFile(jsonFileUrl, function(isSuccess, content)
        if isSuccess then
            print(jsonFileUrl)
            print(content)
            local jsonData = json.decode(content)
            if self.fishingConfig then
                for key, value in pairs(jsonData) do
                    self.fishingConfig[key] = value
                end
            else
                self.fishingConfig = jsonData
            end
        end
    end)
end

function ChooseRoomManager:setCannonLevel(level)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.FISHING_CANNON_LEVEL, level)
end

function ChooseRoomManager:getCannonLevel()
    local level =  UnityEngine.PlayerPrefs.GetInt(DataKeys.FISHING_CANNON_LEVEL)
    if level == 0 then
        level = 1
        self:setCannonLevel(level)
    end
    return level
end

function ChooseRoomManager:setLocalFishRoomList(roomList)
    self.fishingRoomConfig = roomList
    UnityEngine.PlayerPrefs.SetString(DataKeys.FISH_ROOM_CONFIG, json.encode(roomList))
end

function ChooseRoomManager:getLocalFishRoomList()
    if self.fishingRoomConfig then
        return self.fishingRoomConfig
    end
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.FISH_ROOM_CONFIG)
    if string and string ~= "" then
        local config = json.decode(string)
        self:setLocalFishRoomList(config)
        return 
    end
    return {}
end

function ChooseRoomManager:getFishRoomList(callback)
    http.getFishingRoomConfig(
        function(retData)
            self:setLocalFishRoomList(retData)
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )   
end

function ChooseRoomManager:setLocalFishingMoneyRoomList(roomList)
    self.fishingMoneyRoomConfig = roomList
    UnityEngine.PlayerPrefs.SetString(DataKeys.FISH_MONEY_ROOM_CONFIG, json.encode(roomList))
end

function ChooseRoomManager:getLocalFishingMoneyRoomList()
    if self.fishingMoneyRoomConfig then
        return self.fishingMoneyRoomConfig
    end
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.FISH_MONEY_ROOM_CONFIG)
    if string and string ~= "" then
        local config = json.decode(string)
        self:setLocalFishingMoneyRoomList(config)
        return 
    end
    return {}
end


function ChooseRoomManager:getFishingMoneyRoomList(callback)
    http.getFishingMoneyRoomConfig(
        function(retData)
            self:setLocalFishingMoneyRoomList(retData.list)
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )   
end

--[[
    娱乐场次相关
]]

function ChooseRoomManager:setLocalHappyRoomList(roomList)
    UnityEngine.PlayerPrefs.SetString(DataKeys.HAPPY_ROOM_CONFIG, json.encode(roomList))
end

function ChooseRoomManager:getLocalHappyRoomList()
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.HAPPY_ROOM_CONFIG)
    if string and string ~= "" then
        return json.decode(string)
    end
    return {}
end

function ChooseRoomManager:getHappyRoomList(callback)
    http.getHappyRoomList(
        function(retData)
            self:setLocalHappyRoomList(retData.config)
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )   
end

--[[
    斗地主场次相关
]]

function ChooseRoomManager:setLocalLandlordsRoomList(roomList)
    UnityEngine.PlayerPrefs.SetString(DataKeys.LANDLORDS_ROOM_CONFIG, json.encode(roomList))
end

function ChooseRoomManager:getLocalLandlordsRoomList()
    local string = UnityEngine.PlayerPrefs.GetString(DataKeys.LANDLORDS_ROOM_CONFIG)
    if string and string ~= "" then
        return json.decode(string)
    end
    return {}
end

function ChooseRoomManager:setRoomLandlordsVersion(version)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.LANDLORDS_ROOM_VERSION, version)
end

function ChooseRoomManager:getRoomLandlordsVersion()
    return UnityEngine.PlayerPrefs.GetInt(DataKeys.LANDLORDS_ROOM_VERSION) or 0
end

function ChooseRoomManager:getLandlordsRoomConfigByRoomLevel(roomLevel)
    local roomList = self:getLocalLandlordsRoomList()
    for index, config in ipairs(roomList) do
        if roomLevel == config.level then
            return config
        end 
    end
    return nil
end

function ChooseRoomManager:getLandlordsRoomConfigByMoney(money)
    local roomList = self:getLocalLandlordsRoomList()
    money = money and money or GameManager.UserData.money
    local roomLevel = 0
    for index, config in ipairs(roomList) do
        if (money <= config.referrer_money or config.max_limit_money == 0) and money >= config.min_money and config.status ~= 0 then
            return config
        end 
    end
    return nil
end

function ChooseRoomManager:getLandlordsRoomList(callback)
    local version = self:getRoomLandlordsVersion()
    http.getLandlordsRoomList(
        version,
        function(retData)
            if retData.ddz and (type(retData.ddz) ~= "userdata" and #retData.ddz > 0) then
                self:setLocalLandlordsRoomList(retData.ddz)
            end
            self:setRoomLandlordsVersion(retData.version)
            if callback then
                callback()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )   
end


return ChooseRoomManager