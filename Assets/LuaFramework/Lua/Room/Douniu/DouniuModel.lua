local DouniuModel = class("DouniuModel")
local Card        = require("Room.Landlords.Card")

DouniuModel.ModelChange = {
    TableStatus = 1,
}

DouniuModel.SpecialCardType = {
    DoubleTen = 10,
    Same4 = 11,
    Same5 = 12,
    Small5 = 13,
}

function DouniuModel:ctor(data)
    if data then
        for index, roomConfig in ipairs(GameManager.ChooseRoomManager.douniuConfig) do
            if tonumber(roomConfig.room.level) == tonumber(data.table.level) then
                self.roomConfig = roomConfig
            end
        end
        if not self.roomConfig then
            print("self.roomConfig 为空 roomLevel 对应不上 房间创建失败")
        end
    end
    self:initProperties()
end

function DouniuModel:initProperties()
    self.playerList = {}
    self.selfData   = {}
    self.betArray   = {}
    self.tips = nil
    self.modelChangeCallback = nil
end

function DouniuModel:clean()
    
end

function DouniuModel:reset()
    -- 游戏结束 准备的时候调用
    for index, player in pairs(self.playerList) do
        player.cards = {}
        player.isBanker = false
        player.isPlaying = false
    end
end

function DouniuModel:getEmptySeatId()
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

function DouniuModel:getPlayerByUid(uid)
    if self.playerList then
        for index, playerInfo in pairs(self.playerList) do
            if playerInfo and playerInfo.uid == uid then
                return playerInfo
            end
        end
    end
    return -1
end

function DouniuModel:getTableInfoText()
    if self.roomConfig then
        return string.format(T("%s    底分:%s"),  self.roomConfig.room.tab_name, self.roomConfig.room.ante)
    else
        return ""
    end
end

function DouniuModel:isPlayingGame()
    return self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.PLAY
end

function DouniuModel:isSelfPlayingGame()
    if self.selfData then
        return self.selfData.isPlaying
    end
    return nil
end

function DouniuModel:isSelfBanker()
    if self.selfData then
        return self.selfData.isBanker
    end
    return nil
end

function DouniuModel:getBankerPlayer()
    for index, player in pairs(self.playerList) do
        if player.isBanker then
            return player
        end
    end
    return nil
end

function DouniuModel:isSelfWin()
    if self.selfData then
        return self.selfData.addMoney > 0
    end
end

function DouniuModel:serverCardToClientCards(cards)
    local clientCards = {}
    for index, card in ipairs(cards) do
        clientCards[index] = card.card
    end
    return clientCards
end

function DouniuModel:serverPlayerToClientPlayer(playerInfo, haveCards)
    local clientPlayer = {}
    clientPlayer           = json.decode(playerInfo.userInfo)
    clientPlayer.uid       = playerInfo.uid
    clientPlayer.seatId    = playerInfo.seatId
    clientPlayer.cards     = haveCards and self:serverCardToClientCards(playerInfo.cards) or {}
    clientPlayer.money     = playerInfo.userMoney
    clientPlayer.isPlaying = false
    clientPlayer.isBanker  = false
    return clientPlayer
end

function DouniuModel:tableStatusChange()
    if self.modelChangeCallback and self.tableInfo then
        local data = {}
        data.status = self.tableInfo.tableStatus
        data.time = self.tableInfo.leftTime
        if data.status == CONSTS.DOUNIU.TABLE_STATE.STOPED then
            data.format = T("等待其他玩家进入游戏")
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.WAITING then
            data.format = T("游戏即将开始(%ds)")
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.CALL then
            data.format = T("请抢庄(%ds)")
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.BET then
            if self:isSelfBanker() then
                data.format = T("等待其他玩家选择倍数(%ds)")
            else
                data.format = T("请选择下注倍数(%ds)")
            end
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.CONFIRM then
            data.format = T("拼牌中(%ds)")
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.SETTLE then
            data.format = T("下一局即将开始(%ds)")
        elseif data.status == CONSTS.DOUNIU.TABLE_STATE.CLOSING then
            data.format = T("下一局即将开始(%ds)")
        end
        self.modelChangeCallback(DouniuModel.ModelChange.TableStatus, data)
    end
end

--[[
    监听数值变化的回调
]]

function DouniuModel:addModelChangeListener(callback)
    self.modelChangeCallback = callback
end


function DouniuModel:loginRoom(data)
    --[[
        table = {
            int32    tid            = 2;
            int32    level          = 3;
            int32    tableStatus    = 4;
            int32    bankSeatid     = 5;   //庄家座位id --地主座位id -- 叫地主阶段为 -1 谁叫地主 就是谁的座位id
            int64    defaultAnte    = 6;   //底注
            int64    totalAnte      = 7;   //桌上总筹码 -- 当前倍数
            int32    curSeatid      = 8;
            int32    leftTime       = 9;   //操作剩余时间
            int64    quickCall      = 10;  //快速跟注
            int64    minCall        = 11;  //最小加注
            int64    maxCall        = 12;  //最大加注
            int32    roundTime      = 13;  //操作时间
            int32    maxSeatCnt     = 14;
            int64    minCarry       = 15;  //最小携带
            int64    maxCarry       = 16;  //最大携带
            int64    defaultCarry   = 17;  //默认携带
            int32    roomTab        = 18;  //初中高
            repeated Card boardCard = 19;  //桌面公共牌
            int32    sysBanker      = 20;  //系统做庄 
            int32    boardCardTimes = 21;  //公共牌倍数
            int32    bankUserId     = 22;  //庄家ID
            repeated Card leftCards = 23;  //剩余牌

        };
        playerList = [
            {
                int32    uid             = 1;
                int32    seatId          = 2;
                int32    userStatus      = 3;
                int32    online          = 4;
                string   userInfo        = 5;
                int64    curCarry        = 6;   //携带
                int64    curAnte         = 7;   //当前下注
                int32    wintimes        = 8;
                int32    losetimes       = 9;
                int32    specialCard     = 10;
                int64    userMoney       = 11;
                int32    addExp          = 12;  //结算时加的经验
                int32    addMoney        = 13;  //结算
                repeated Card cards      = 14;  //手牌
                int32    isShow          = 15;
                repeated Card bestCards  = 16;  //最大牌组合
                int32    multiple        = 17;  //牌型倍数
                int32    roomFee         = 18;  //台费
                int32    cardsCnt        = 19;  //牌数量
                int32    index           = 20;  //位置编号
                repeated BetInfo betInfo = 21;  //下注信息
                int32    settleState     = 22;  // 结算状态 0正常结算 1封顶 2包赔
                repeated Card outCards   = 23;  //当前回合出牌
            }
        ]
    ]]
    self.tableInfo = data.table
    local playerList = {}
    for i, playerInfo in ipairs(data.playerList) do
        local seatId = playerInfo.seatId
        -- 判断玩家状态 是否在游戏中
        local isPlaying = false
        if playerInfo.userStatus == CONSTS.DOUNIU.USER_STATE.BET 
        or playerInfo.userStatus == CONSTS.DOUNIU.USER_STATE.CALL
        or playerInfo.userStatus == CONSTS.DOUNIU.USER_STATE.CONFIRM
        or playerInfo.userStatus == CONSTS.DOUNIU.USER_STATE.CHOICING
        or playerInfo.userStatus == CONSTS.DOUNIU.USER_STATE.WAITOTHER then
            isPlaying = true
        end
        playerList[seatId] = self:serverPlayerToClientPlayer(playerInfo, isPlaying)
        playerList[seatId].isPlaying = isPlaying
        if playerInfo.uid == GameManager.UserData.mid then
            self.selfData = playerList[seatId]
        end
    end
    self.playerList = playerList

    -- 当前是不是有庄家了
    if (self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.BET
    or self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CONFIRM
    or self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.SETTLE) and self.tableInfo.bankSeatid >= 1 then
        local bankerPlayer = self.playerList[self.tableInfo.bankSeatid]
        bankerPlayer.isBanker = true
        -- 庄家使用的倍数是 当前倍数
        bankerPlayer.curAnte = self.tableInfo.boardCardTimes
    end
    self:tableStatusChange()
end

function DouniuModel:someoneSitDown(data)
    --[[
            int32  uid       = 1;
            int32  seatId    = 2;
            int64  curCarry  = 3;  //携带
            int64  userMoney = 4;  //总钱数
            string userInfo  = 5;
    ]]
    local playerInfo = data
    local seatId = playerInfo.seatId
    self.playerList[seatId] = self:serverPlayerToClientPlayer(playerInfo, false)
    -- 自己有没有在游戏
    if playerInfo.uid == GameManager.UserData.mid then
        self.selfData = self.playerList[seatId]
    end

    -- 如果当前桌子在等人
    if self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.STOPED then
        -- 判断人数
        local count = 0
        for index, player in pairs(self.playerList) do
            count = count + 1
        end
        if count > 1 then
            self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.WAITING
            self.tableInfo.leftTime    = 5
            self:tableStatusChange()
        end
    end

    return self.playerList[seatId]
end

function DouniuModel:someoneStandUp(data)
    --[[
        int32 uid    = 1;
        int32 seatId = 2;
    ]]
    local seatId = data.seatId
    local prePlayer = self.playerList[seatId]
    self.playerList[seatId] = nil

    -- 如果当前桌子已经结算
    if self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.SETTLE
    or self.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.WAITING then
        -- 判断人数
        local count = 0
        for index, player in pairs(self.playerList) do
            count = count + 1
        end
        if count == 1 then
            self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.STOPED
            self.tableInfo.leftTime    = 0
            self:tableStatusChange()
        end
    end

    return prePlayer
end

function DouniuModel:gameStart(data)
    --[[
        int64    defaultAnte       = 2;
        int64    totalAnte         = 3;  //当前倍数
        repeated Card cards        = 5;  //用户手牌
        int32    roundTime         = 8; // 操作时间
    ]]
    -- 拿到当前座位上的人 给他们开始游戏
    for index, player in pairs(self.playerList) do
        player.isPlaying = true
        if player.uid == GameManager.UserData.mid then
            player.cards = self:serverCardToClientCards(data.cards)
        end
    end
    self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.CALL
    self.tableInfo.leftTime    = data.roundTime
    self:tableStatusChange()
end


function DouniuModel:operate(data)
    --[[
        int32    seatId     = 1;
        int32    userStatus = 2;
        int64    curAnte    = 3;  // 0取消 1确认
        repeated Card cards = 7;  //操作的牌
    ]]
    local currentPlayer      = self.playerList[data.seatId]
    currentPlayer.userStatus = data.userStatus
    currentPlayer.curAnte    = data.curAnte
    currentPlayer.cards      = self:serverCardToClientCards(data.cards)
    return currentPlayer
end

function DouniuModel:callBanker(data)
    --[[
        int32 seatId = 1;
        int32 uid    = 2;
    ]]
    local bankerPlayer = self.playerList[data.seatId]
    bankerPlayer.isBanker = true
    local sameAntePlayers = {}
    for index, player in ipairs(self.playerList) do
        if player.isPlaying and player.curAnte == bankerPlayer.curAnte then
            sameAntePlayers[#sameAntePlayers + 1] = player
        end
    end
    return bankerPlayer, sameAntePlayers
end

function DouniuModel:startBet(data)
    --[[
        int32 seatId        = 1;
        int32 leftTime      = 2;
        int64 minCall       = 3;    //最小加注
        int64 maxCall       = 4;    //最大加注
        int64 quickCall     = 5;   //跟注 
        int32 operate       = 6;   //landlord: --1叫地主，2抢地主，3出牌，4接牌 5过牌
    ]]
    local mulGruop = self.roomConfig.mulGroup
    local minMul   = self.roomConfig.minMul
    local callArray = {}
    for index, group in ipairs(mulGruop) do
        local max = group[#group]
        if max > data.maxCall then
            if index == 1 then
                print("这种情况是不可能发生的")
            else
                callArray = mulGruop[index - 1]
            end
            break
        end
    end

    callArray = table.unique(callArray, true)
    self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.BET
    self.tableInfo.leftTime    = data.leftTime
    self.betArray = callArray
    self:tableStatusChange()
end

function DouniuModel:showCard(data)
    --[[
        int32    seatId      = 1;
        repeated Card cards  = 2;
        int32    specialCard = 3;
        int32    multiple    = 4;
        int32  isWin         = 5;  //比牌结果
        int32  roundTime     = 6;  //操作时间
    ]]
    if self:isSelfPlayingGame() then
        local cards = self:serverCardToClientCards(data.cards)
        self.playerList[self.selfData.seatId].cards            = cards
        self.playerList[self.selfData.seatId].specialCard      = data.specialCard
        self.playerList[self.selfData.seatId].specialCardArray = nil
        if self.selfData.specialCard == DouniuModel.SpecialCardType.Same4 then
            local array = {}
            for index, hex in ipairs(cards) do
                local cardClass = Card.new(hex)
                array[#array + 1] = cardClass
            end
            table.sort(array,function(a, b)
                return a.count < b.count
            end)
            if array[1].count ~= array[2].count then
                array[1], array[5] = array[5], array[1]
            end
            local hexArray = {}
            for index, cardClass in ipairs(array) do
                hexArray[#hexArray + 1] = cardClass.hex
            end
            self.playerList[self.selfData.seatId].specialCardArray = hexArray
        elseif self.selfData.specialCard == DouniuModel.SpecialCardType.Same5 then
            local array = {}
            for index, hex in ipairs(cards) do
                local cardClass = Card.new(hex)
                array[#array + 1] = cardClass
            end
            table.sort(array,function(a, b)
                return a.count < b.count
            end)
            local hexArray = {}
            for index, cardClass in ipairs(array) do
                hexArray[#hexArray + 1] = cardClass.hex
            end
            self.playerList[self.selfData.seatId].specialCardArray = hexArray
        elseif self.selfData.specialCard == DouniuModel.SpecialCardType.Small5 then
            local array = {}
            for index, hex in ipairs(cards) do
                local cardClass = Card.new(hex)
                array[#array + 1] = cardClass
            end
            table.sort(array,function(a, b)
                return a.count > b.count
            end)
            local hexArray = {}
            for index, cardClass in ipairs(array) do
                hexArray[#hexArray + 1] = cardClass.hex
            end
            self.playerList[self.selfData.seatId].specialCardArray = hexArray
        end
    end
    self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.CONFIRM
    self.tableInfo.leftTime    = data.roundTime
    self:tableStatusChange()
end

function DouniuModel:gameOver(data)
    --[[
        playerList = [
            {
                int32    uid             = 1;
                int32    seatId          = 2;
                int32    specialCard     = 10;
                int64    userMoney       = 11;
                int32    addExp          = 12;  //结算时加的经验
                int32    addMoney        = 13;  //结算
                repeated Card cards      = 14;  //手牌
                int32    settleState     = 22;  //结算状态 0正常结算 1封顶 2包赔
            }
        ]
        {"bonusList":{},"playerList":[{"cards":[{"card":1},{"card":1},{"card":24},{"card":2},{"card":5},{"card":49}],"userMoney":642188,"seatId":1,"addMoney":1200,"specialCard":7,"multiple":2,"uid":10007},{"cards":[{"card":11},{"card":11},{"card":11},{"card":12},{"card":53},{"card":54},{"card":61}],"uid":6082,"seatId":2,"addMoney":600,"specialCard":1,"multiple":1,"userMoney":542524},{"cards":[{"card":27},{"card":27},{"card":27},{"card":18},{"card":29},{"card":43},{"card":55}],"uid":6050,"seatId":3,"addMoney":-1800,"specialCard":9,"multiple":2,"userMoney":905052}]}
    ]]

    for index, playerInfo in ipairs(data.playerList) do
        local player = self.playerList[playerInfo.seatId]
        player.addMoney    = playerInfo.addMoney
        player.money       = playerInfo.userMoney
        player.specialCard = playerInfo.specialCard
        player.addExp      = playerInfo.addExp
    end
    self.tableInfo.tableStatus = CONSTS.DOUNIU.TABLE_STATE.SETTLE
    self.tableInfo.leftTime    = tonumber(self.roomConfig.room.show_time) + tonumber(self.roomConfig.room.settle_animate_time)
    self:tableStatusChange()
end

function DouniuModel:getNormalNiuTips(data)
    self.tips = {}
    if data.tips then
        self.tips.text = data.tips
        if data.cost then
            self.tips.cost = tonumber(data.cost)
        end
    else
        self.tips = nil
    end
end

return DouniuModel