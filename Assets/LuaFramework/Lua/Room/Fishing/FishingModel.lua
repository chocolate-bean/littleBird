local FishingModel = class("FishingModel")
local Card        = require("Room.Landlords.Card")


function FishingModel:ctor(data)
    self:initProperties()
    if data then
        self.fishConfig = GameManager.ChooseRoomManager.FishingConfig[self.defaultCannonStyle]
        if not self.fishConfig then
            print("self.fishConfig 为空 roomLevel 对应不上 房间创建失败")
        end
    end
end

function FishingModel:initProperties()
    self.defaultCannonStyle  = 1
    self.playerList          = {}
    self.selfData            = nil
    self.nuclearBombConfig   = nil
    self.niudaoxiaoshiConfig = nil
end

function FishingModel:clean()
    
end

function FishingModel:reset()
    -- 游戏结束 准备的时候调用
end

function FishingModel:getEmptySeatId()
    for seatId = 1, self.tableInfo.maxSeatCnt do
        local havePlayer = false
        for i, player in pairs(self.playerList) do
            if player.seatId == seatId then
                havePlayer = true
                break
            end
        end
        if not havePlayer then
            return seatId     
        end
    end
    return -1
end

function FishingModel:getPlayerByUid(uid)
    for i, player in pairs(self.playerList) do
        if player.uid == uid then
            return player
        end
    end
end

function FishingModel:getTableInfoText()
    
end

function FishingModel:getNextCannonConfig()
    -- 仅在需要炮台升级的场里面生效
    if not self.fishConfig or self:isRedpacketRoom() then
        return nil
    end

    local list = self.fishConfig.cannon[self.defaultCannonStyle].list
    local currentLevel = GameManager.UserData.maxCannonLevel
    local nextConfig
    for index, config in ipairs(list) do
        if currentLevel == config.level then
            if index < #list then
                nextConfig = list[index + 1]
            end
        end
    end

    return nextConfig
end

function FishingModel:isRedpacketRoom()
    if self.roomConfig then
        return self.roomConfig.redpack_ground == 1
    end
    return false
end

function FishingModel:isCannonMulSwitchOpen()
    -- 1是开 0是关
    if self.roomConfig then
        return self.roomConfig.cannon_mul_switch == 1
    end
    return false
end

function FishingModel:getFishMultipleWithFishType(fishType)
    for i, fishInfo in ipairs(self.fishConfig.fish) do
        if tonumber(fishInfo.fish_id) == fishType then
            return tonumber(fishInfo.multiple)
        end
    end
    return 0
end

function FishingModel:serverPlayerToClientPlayer(playerInfo, isSitDown)
    local clientPlayer = {}
    clientPlayer             = json.decode(playerInfo.userInfo)
    clientPlayer.uid         = playerInfo.uid
    clientPlayer.seatId      = playerInfo.seatId
    clientPlayer.money       = playerInfo.userMoney
    -- clientPlayer.cannonStyle = clientPlayer.viplevel + 1

    -- 张易说的向上兼容
    if clientPlayer.cannonStyle then
        if  clientPlayer.cannonStyle == 0 or clientPlayer.cannonStyle > 11 then
            clientPlayer.cannonStyle = 1
        end
    else
        clientPlayer.cannonStyle = 1
    end

    -- 坐下的时候的参数不一致 必须做区分判断 不然protobuff会报错
    if isSitDown then
        if #self.roomConfig.cannon_mul > 0 then
            clientPlayer.multiple = self.roomConfig.cannon_mul[1].mul
        else
            clientPlayer.multiple = 1
        end
        clientPlayer.cannonLevel = playerInfo.param
        clientPlayer.userStatus  = CONSTS.FISHING.USER_STATE.READY
    else
        clientPlayer.multiple   = playerInfo.multiple
        clientPlayer.userStatus  = playerInfo.userStatus
        clientPlayer.cannonLevel = playerInfo.specialCard
        for index, propItem in ipairs(playerInfo.propList) do
            if propItem.propId == CONSTS.PROPS.DIAMOND then
                clientPlayer.diamond = propItem.propCount
            elseif propItem.propId == CONSTS.PROPS.JEWEL_REDPACKET then
                clientPlayer.jewel = propItem.propCount
            end
        end
    end

    if clientPlayer.cannonLevel == 0 then
        clientPlayer.cannonLevel = self.fishConfig.cannon[self.defaultCannonStyle].list[1].level
    end

    clientPlayer = self:cannonLevelToCannonMultiple(clientPlayer)
    return clientPlayer
end

function FishingModel:cannonLevelToCannonMultiple(player)
    if player.cannonLevel then
        for index, config in ipairs(self.fishConfig.cannon[self.defaultCannonStyle].list) do
            if player.cannonLevel == tonumber(config.level) then
                player.cannonMultiple = tonumber(config.multiple)
                break
            end
            if index == #self.fishConfig.cannon[self.defaultCannonStyle].list then
                config = self.fishConfig.cannon[self.defaultCannonStyle].list[1]
                player.cannonMultiple = tonumber(config.multiple)
                player.cannonLevel = tonumber(config.level)
            end
        end
    end
    return player
end

function FishingModel:cannonLevelToCannonMultipleWithValue(level)
    if level then
        for index, config in ipairs(self.fishConfig.cannon[self.defaultCannonStyle].list) do
            if level == tonumber(config.level) then
                return tonumber(config.multiple)
            end
            if index == #self.fishConfig.cannon[self.defaultCannonStyle].list then
                config = self.fishConfig.cannon[self.defaultCannonStyle].list[1]
                return tonumber(config.multiple)
            end
        end
    end
    return 0
end

function FishingModel:loginRoom(data)
    self.tableInfo = data.table
    local playerList = {}
    for i, playerInfo in ipairs(data.playerList) do
        local seatId = playerInfo.seatId
        playerList[seatId] = self:serverPlayerToClientPlayer(playerInfo, false)
        if playerInfo.uid == GameManager.UserData.mid then
            self.selfData = playerList[seatId]
            self.selfData.consume = playerInfo.curAnte
        end
    end
    self.playerList = playerList
end

function FishingModel:someoneSitDown(data)
    local playerInfo = data
    local seatId = playerInfo.seatId
    self.playerList[seatId] = self:serverPlayerToClientPlayer(playerInfo, true)
    local currentPlayer = self.playerList[seatId]
    if currentPlayer.uid == GameManager.UserData.mid then
        self.selfData = currentPlayer
        self.selfData.consume = 0
    end
    return currentPlayer
end

function FishingModel:someoneStandUp(data)
    local seatId = data.seatId
    local prePlayer = self.playerList[seatId]
    self.playerList[seatId] = nil
    return prePlayer
end

function FishingModel:operate(data)
    local currentPlayer = self.playerList[data.seatId]
    currentPlayer.operate = data.operate
    currentPlayer.curAnte = data.curAnte
    if currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.CANNON then
        currentPlayer.cannonLevel = data.curAnte
        currentPlayer = self:cannonLevelToCannonMultiple(currentPlayer)
    elseif currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.PROPS then
        currentPlayer.propType = data.curAnte
        currentPlayer.countDownTime = data.times
    elseif currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.MUL then
        currentPlayer.multiple = data.curAnte
    end
    return currentPlayer
end

function FishingModel:shooting(data)
    --[[
        int32  seatId      = 1;
        int32  cannonLevel = 2;  //炮等级
        string param       = 3;  //其他参数
        int32  ret         = 4;
        int32  bulletId    = 5;  //子弹id
        int64  userMoney   = 6;
        int32  bindUser    = 7; //绑定的用户 (机器人使用)
        int64  addup       = 8; //累计花费
    ]]
    local currentPlayer = self.playerList[data.seatId]
    currentPlayer.money = data.userMoney
    if currentPlayer.uid == GameManager.UserData.mid then
        GameManager.UserData.money = data.userMoney
        self.selfData.consume = data.addup
        currentPlayer.jewel = GameManager.UserData.jewel
    end
    return currentPlayer
end

function FishingModel:fishing(data)
    --[[
        int32    seatId             = 1;
        int32    bulletId           = 2;
        repeated FishInfo  fishList = 3;  //捕获的鱼
        repeated FishInfo  killList = 4;
        int64    userMoney          = 5;
        int32    totalKilled        = 6;
    ]]

    -- 更新总击杀值
    self.tableInfo.totalAnte = data.totalKilled

    local currentPlayer = self.playerList[data.seatId]
    -- 别人 只管钱 道具不管
    currentPlayer.money = data.userMoney
    -- 都管
    for index, fishInfo in ipairs(data.killList) do
        for jndex, drop in ipairs(fishInfo.propInfo) do
            if drop.propId == CONSTS.PROPS.GOLD then
                -- 金币
            elseif drop.propId == CONSTS.PROPS.JEWEL_REDPACKET then
                -- 红包
                currentPlayer.jewel = currentPlayer.jewel + drop.propCount
                if currentPlayer.uid == GameManager.UserData.mid then
                    GameManager.GameFunctions.setJewel(currentPlayer.jewel)
                    GameManager.ServerManager:sendSyncOther()
                end
            elseif drop.propId == CONSTS.PROPS.DIAMOND then
                -- 钻石
                currentPlayer.diamond = currentPlayer.diamond + drop.propCount
                if currentPlayer.uid == GameManager.UserData.mid then
                    GameManager.UserData.diamond = GameManager.UserData.diamond + drop.propCount
                end
            elseif drop.propId == CONSTS.PROPS.FISHING_SKILL_SPRINT 
            or drop.propId == CONSTS.PROPS.FISHING_SKILL_FROZE then
                -- 急速 && 冰冻
                local propIndex
                for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
                    if config.id == drop.propId then
                        propIndex = index
                        break
                    end
                end
                if GameManager.UserData.fishingSkillConfig[propIndex] then
                    GameManager.UserData.fishingSkillConfig[propIndex].num = GameManager.UserData.fishingSkillConfig[propIndex].num + drop.propCount
                end
            end
        end
    end
    if currentPlayer.uid == GameManager.UserData.mid then
        GameManager.UserData.money = data.userMoney
    end
    return currentPlayer
end

function FishingModel:setNiudaoxiaoshi(data)
    self.niudaoxiaoshiConfig = data.list
    self.niudaoxiaoshiConfig.open = data.flag
end

return FishingModel