local LandlordsModel = class("LandlordsModel")

-- 常量
LandlordsModel.MaxCardsCount    = 20
LandlordsModel.NormalCardsCount = 17

LandlordsModel.ActionStatus = {
    --0 叫地主 抢地主 出牌 接牌 过牌
    Jiaodizhu  = 1,
    Qiangdizhu = 2,
    Qishou     = 3,
    Yaodeqi    = 4,
    Yaobuqi    = 5,
    Tuoguan    = 6,
}

LandlordsModel.ActionResult = {
    jiaodizhu  = 1,
    bujiao     = 2,
    qiangdizhu = 3,
    buqiang    = 4,
    yaobuqi    = 5,
    tuoguan    = 6,
    zaiwan     = 7
}

LandlordsModel.Player = {
    Ziji     = 1,
    XiaJia   = 2,
    ShangJia = 3,
}

LandlordsModel.SXJSeatId = {
    [1] = {
        sj = 3,
        xj = 2,
    },
    [2] = {
        sj = 1,
        xj = 3,
    },
    [3] = {
        sj = 2,
        xj = 1,
    },
}

LandlordsModel.CardsType = 
{
	INVALID         = -1, --非法
	SINGLE          = 0, --单张
	BLACK_JOKER     = 1, --小王
	RED_JOKER       = 2, --大王
	DOUBLE_JOKER    = 3, --双王炸
	FLUSH           = 4, --同花(底牌)
	PAIR            = 5, --对子
	THREE           = 6, --3张
	LINE            = 7, --顺子(底牌3张算顺子)
	PAIR_LINE       = 8, --连对
	THREE_LINE      = 9, --飞机
	THREE_TAKE_ONE  = 10, --三带一
	THREE_TAKE_PAIR = 11, --三带对
	FOUR_TAKE_ONE   = 12, --四带两单
	FOUR_TAKE_PAIR  = 13, --四带两对
	BOMB            = 14, --四张炸弹
};

LandlordsModel.ConditionType = {
    DayWin = 2,
    BeDz   = 8,
    DZWin  = 22,
}

LandlordsModel.ConditionConfig = {
    --[[
        2. 每日赢牌
        8. 叫地主
        22. 当地主赢牌
    ]]
    [LandlordsModel.ConditionType.DayWin] = {
        type      = LandlordsModel.ConditionType.DayWin,
        title     = T("玩牌赢红包"),
        titleInfo = T("今日累计胜利局数："),
        tips      = T("<color=#963C1E>再赢<color=#FA641E> %s </color>局拿红包</color>"),
    },
    [LandlordsModel.ConditionType.BeDz] = {
        type      = LandlordsModel.ConditionType.BeDz,
        title     = T("地主赢红包"),
        titleInfo = T("已累计当地主局数："),
        tips      = T("<color=#963C1E>再当<color=#FA641E> %s </color>局拿红包</color>"),
    },
    [LandlordsModel.ConditionType.DZWin]= {
        type      = LandlordsModel.ConditionType.DZWin,
        title     = T("地主赢红包"),
        titleInfo = T("地主累计胜利局数："),
        tips      = T("<color=#963C1E>当地主再赢<color=#FA641E> %s </color>局</color>"),
    },
}

function LandlordsModel:ctor(data)
    if data then
        self.roomConfig = GameManager.ChooseRoomManager:getLandlordsRoomConfigByRoomLevel(data.table.level)
        if not self.roomConfig then
            print("self.roomConfig 为空 roomLevel 对应不上 房间创建失败")
        end
    end
    self:initProperties()
end

function LandlordsModel:initProperties()
    self.isSelfInGame = false
    self.isSelfInSeat = false
    self.isSelfRobot  = false
    self.currentAction = {}
    self.currentAction.seatId        = -1
    self.currentAction.player        = -1
    self.currentAction.operate       = -1
    self.currentAction.actionTime    = -1
    self.currentAction.operateResult = -1

    self.otherAction = {}
    self.otherAction.seatId        = -1
    self.otherAction.player        = -1
    self.otherAction.operate       = -1
    self.otherAction.operateResult = -1

    self.playerList = {}
    self.zj = nil
    self.sj = nil
    self.xj = nil

    self.firstSeatId = -1
    self.dizhuSeatId = -1
    self.dizhuPlayer = -1

    self.mulitipleChanged = false
    self.mulitiple = -1
    self.currentMulitiple = -1
    self.boardCards = {}
    self.hintCards = {}
    self.boardCardMulitiple = -1

    self.knownCards = {}
    self.currentCards = {}
    self.currentCardType = nil

    self.timeOverTimes = 0

    self.result = {}
    self.result.userInfo = {}
    self.result.winnerResult = -1

    self.needChangeRoom  = false -- 用于换桌
    self.needChangeLevel = false -- 用于换场
    self.kickOutSelf     = false -- 用于server踢人
    self.judgeOperate    = false -- 用于重连判断
    self.testRobot       = false -- 用于测试机器人 展示手牌

    --[[
        红包任务相关
        self.redpacketMission.currentGoal = goal.goal
        self.redpacketMission.currentId   = goal.id
        self.redpacketMission.current     = data.current
        self.redpacketMission.goal        = data.goal
        self.redpacketMission.received    = data.received
        self.redpacketMission.switch      = data.switch
        self.redpacketMission.gainJewel   = data.gain_jewel
        self.redpacketMission.otherJewel  = data.other_reward
        self.redpacketMission.isAllDone   = false --所有任务完成
    ]]
    self.redpacketMission = {}
end

function LandlordsModel:clean()
    self.isSelfRobot  = false
    self.currentAction = {}
    self.currentAction.seatId        = -1
    self.currentAction.player        = -1
    self.currentAction.operate       = -1
    self.currentAction.actionTime    = -1
    self.currentAction.operateResult = -1

    self.otherAction = {}
    self.otherAction.seatId        = -1
    self.otherAction.player        = -1
    self.otherAction.operate       = -1
    self.otherAction.operateResult = -1

    self.sj = {
        cards    = self.sj.cards,
        cardsCnt = self.sj.cardsCnt,
        seatId   = self.sj.seatId,
    }
    self.xj = {
        cards    = self.xj.cards,
        cardsCnt = self.xj.cardsCnt,
        seatId   = self.xj.seatId,
    }

    self.firstSeatId = -1
    self.dizhuSeatId = -1
    self.dizhuPlayer = -1

    self.mulitipleChanged = false
    self.mulitiple = -1
    self.currentMulitiple = -1
    self.boardCards = {}
    self.hintCards = {}
    self.boardCardMulitiple = -1

    self.knownCards = {}
    self.currentCards = {}
    self.currentCardType = nil

    self.timeOverTimes = 0

    self.result = {}
    self.result.userInfo = {}
    self.result.winnerResult = -1

    self.needChangeRoom  = false -- 用于换桌
    self.needChangeLevel = false -- 用于换场
    self.kickOutSelf     = false -- 用于server踢人
    self.judgeOperate    = false -- 用于重连判断
    self.testRobot       = false -- 用于测试机器人 展示手牌
end


function LandlordsModel:reset()
    -- 游戏结束 准备的时候调用

    self.currentAction = {}
    self.currentAction.seatId        = -1
    self.currentAction.player        = -1
    self.currentAction.operate       = -1
    self.currentAction.actionTime    = -1
    self.currentAction.operateResult = -1

    self.otherAction = {}
    self.otherAction.seatId        = -1
    self.otherAction.player        = -1
    self.otherAction.operate       = -1
    self.otherAction.operateResult = -1

    self.firstSeatId = -1
    self.dizhuSeatId = -1
    self.dizhuPlayer = -1

    self.mulitipleChanged = false
    self.mulitiple = -1
    self.currentMulitiple = -1
    self.boardCards = {}
    self.hintCards = {}
    self.boardCardMulitiple = -1

    self.knownCards = {}
    self.currentCards = {}
    self.currentCardType = nil

    self.timeOverTimes = 0

    self.result = {}
    self.result.userInfo = {}
    self.result.winnerResult = -1

    self.judgeOperate   = false
end

function LandlordsModel:getEmptySeatId()
    -- return 3
    for seatId = 1, self.tableInfo.maxSeatCnt do
        local havePlayer = false
        for i, player in ipairs(self.playerList) do
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

function LandlordsModel:getPlayerByUid(uid)
    if self.playerList then
        for index, playerInfo in ipairs(self.playerList) do
            if playerInfo and playerInfo.uid == uid then
                return self:seatIdToPlayer(playerInfo.seatId)
            end
        end
    end
    return -1
end

function LandlordsModel:getTableInfoText()
    if self.roomConfig then
        return string.format(T("%s    底分:%s"),  self.roomConfig.tab_name, self.roomConfig.ante)
    else
        return ""
    end
end

function LandlordsModel:isDizhu()
    return self.dizhuSeatId == self.selfSeatId
end

function LandlordsModel:isZijiAction()
    return self.currentAction.player == LandlordsModel.Player.Ziji
end

function LandlordsModel:isPlayingGame()
    return self.tableInfo.tableStatus == CONSTS.LANDLORDS.TABLE_STATE.PLAY
end

function LandlordsModel:seatIdToPlayer(seatId)
    if not self.isSelfInSeat then
        return nil
    else
        if self.selfSeatId == seatId then
            return LandlordsModel.Player.Ziji
        end
        local seatConfig = LandlordsModel.SXJSeatId[self.selfSeatId]
        if seatConfig.xj == seatId then
            return LandlordsModel.Player.XiaJia
        elseif seatConfig.sj == seatId then
            return LandlordsModel.Player.ShangJia
        end
    end
end

function LandlordsModel:playerToSeatId(player)
    if player == LandlordsModel.Player.Ziji then
        return self.selfSeatId
    elseif player == LandlordsModel.Player.XiaJia then
        return self.xj.seatId
    elseif player == LandlordsModel.Player.ShangJia then
        return self.sj.seatId
    end
end

function LandlordsModel:updatePlayers()
    local selfSeatId = 1
    if self.isSelfInSeat then
        selfSeatId = self.zj.seatId
    else
        selfSeatId = self:getEmptySeatId()
    end
    local seatConfig = LandlordsModel.SXJSeatId[selfSeatId]
    self.sj = self.playerList[seatConfig.sj]
    self.xj = self.playerList[seatConfig.xj]
end

function LandlordsModel:allottedOperate(seatId, operate, operateTime, result)

    local ActionStatus = LandlordsModel.ActionStatus
    local ActionResult = LandlordsModel.ActionResult

    if operate ~= ActionStatus.Tuoguan  then
        self.currentAction.seatId = seatId
        self.currentAction.player = self:seatIdToPlayer(seatId)
        self.currentAction.operate = operate

        -- 重置托管相关操作
        local time = operateTime
        if operate == ActionStatus.Yaobuqi and self:isZijiAction() then
            time = math.ceil(operateTime * 0.5)
        end
        self.currentAction.actionTime = time

        if result == nil then
            self.currentAction.operateResult = -1
        else
            if operate == ActionStatus.Jiaodizhu then
                if result == 0 then
                    self.currentAction.operateResult = ActionResult.bujiao
                else
                    self.currentAction.operateResult = ActionResult.jiaodizhu
                end 
            elseif operate == ActionStatus.Qiangdizhu then
                if result == 0 then
                    self.currentAction.operateResult = ActionResult.buqiang
                else
                    self.currentAction.operateResult = ActionResult.qiangdizhu
                end 
            elseif operate == ActionStatus.Yaobuqi then
                self.currentAction.operateResult = ActionResult.yaobuqi
            elseif operate == ActionStatus.Tuoguan then
                if result == 0 then
                    self.currentAction.operateResult = ActionResult.zaiwan
                    if self.currentAction.player == LandlordsModel.Player.Ziji then
                        self.isSelfRobot = false
                    end
                else
                    self.currentAction.operateResult = ActionResult.tuoguan
                    if self.currentAction.player == LandlordsModel.Player.Ziji then
                        self.isSelfRobot = true
                    end
                end 
            else
                self.currentAction.operateResult = -1
            end
        end
    else
        self.otherAction.seatId = seatId
        self.otherAction.player = self:seatIdToPlayer(seatId)
        self.otherAction.operate = operate

        if result ~= nil then
            if operate == ActionStatus.Tuoguan then
                if result == 0 then
                    self.otherAction.operateResult = ActionResult.zaiwan
                    if self.otherAction.player == LandlordsModel.Player.Ziji then
                        self.isSelfRobot = false
                    end
                else
                    self.otherAction.operateResult = ActionResult.tuoguan
                    if self.otherAction.player == LandlordsModel.Player.Ziji then
                        self.isSelfRobot = true
                    end
                end 
            end
        end
    end
end

function LandlordsModel:serverCardToClientCards(cards)
    local clientCards = {}
    for index, card in ipairs(cards) do
        clientCards[index] = card.card
    end
    return clientCards
end

function LandlordsModel:loginRoom(data)
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
        playerList[seatId]          = json.decode(playerInfo.userInfo)
        playerList[seatId].uid      = playerInfo.uid
        playerList[seatId].seatId   = seatId
        playerList[seatId].cardsCnt = playerInfo.cardsCnt
        playerList[seatId].cards    = self:serverCardToClientCards(playerInfo.cards)
        playerList[seatId].outCards = self:serverCardToClientCards(playerInfo.outCards)
        playerList[seatId].money    = playerInfo.userMoney
        -- 自己有没有在游戏
        if playerInfo.uid == GameManager.UserData.mid then
            self.selfSeatId = seatId
            self.isSelfInGame = true
            self.isSelfInSeat = true
            self.zj = playerList[seatId]
        end
    end

    self.playerList = playerList
    self:updatePlayers()

    if self.isSelfInGame then
        -- 重连进来的
        -- 当前操作的人
        self.currentAction.seatId = data.table.curSeatid
        self.currentAction.player = self:seatIdToPlayer(data.table.curSeatid)
        self.currentAction.actionTime = data.table.leftTime
        
        self.knownCards = clone(self.zj.cards)

        -- 通过桌子状态来看 叫抢地主
        if data.table.tableStatus == CONSTS.LANDLORDS.TABLE_STATE.CALL then
            if data.table.bankSeatid == -1 then
                self.currentAction.operate = LandlordsModel.ActionStatus.Jiaodizhu
            else
                self.currentAction.operate = LandlordsModel.ActionStatus.Qiangdizhu
            end
        else
            self.mulitiple          = data.table.totalAnte
            self.boardCardMulitiple = self.tableInfo.boardCardTimes
            self.boardCards         = self:serverCardToClientCards(data.table.boardCard)
            self.dizhuSeatId        = data.table.bankSeatid
            self.dizhuPlayer        = self:seatIdToPlayer(self.dizhuSeatId)

            -- 剩余牌记录
            local leftCards = self:serverCardToClientCards(data.table.leftCards)
            -- server给的是剩余的牌 而这边记录的是出过的牌 然后做减法的
            local allCard = {
                0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,        --方块 A - K   1 - 13
                0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,        --梅花 A - K   17 - 29
                0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,        --红桃 A - K   33 - 45
                0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,        --黑桃 A - K   49 - 61
                                                                                0x4E,0x4F,  --78,79
            }

            local outCards = {}
            for index, card in ipairs(allCard) do
                local isOut = true
                for j, leftCard in pairs(leftCards) do
                    if leftCard == card then
                        isOut = false
                        leftCards[j] = nil
                        break
                    end
                end
                if isOut then
                    outCards[#outCards + 1] = card
                end
            end
            self.knownCards = table.append(self.knownCards, outCards)
        end
    end
end

function LandlordsModel:someoneSitDown(data)
    --[[
            int32  uid       = 1;
            int32  seatId    = 2;
            int64  curCarry  = 3;  //携带
            int64  userMoney = 4;  //总钱数
            string userInfo  = 5;
    ]]
    local seatId = data.seatId
    self.playerList[seatId]          = json.decode(data.userInfo)
    self.playerList[seatId].uid      = data.uid
    self.playerList[seatId].seatId   = seatId
    self.playerList[seatId].cardsCnt = 0
    self.playerList[seatId].money    = data.userMoney
    -- self.playerList[seatId].isReady  = true
    self.playerList[seatId].cards    = {}
    if data.uid == GameManager.UserData.mid then
        GameManager.UserData.money = data.userMoney
        self.selfSeatId = seatId
        self.isSelfInSeat = true
        self.zj = self.playerList[seatId]
    end
    self:updatePlayers()
    return self:seatIdToPlayer(data.seatId)
end

function LandlordsModel:someoneStandUp(data)
    --[[
        int32 uid    = 1;
        int32 seatId = 2;
    ]]
    self.playerList[data.seatId] = {
        cards    = self.playerList[data.seatId].cards,
        cardsCnt = self.playerList[data.seatId].cardsCnt,
        seatId   = self.playerList[data.seatId].seatId,
    }
    if data.uid == GameManager.UserData.mid then
        self.isSelfInSeat = false
        self.isSelfInGame = false
        self.zj = nil
    end
    self:updatePlayers()
    return self:seatIdToPlayer(data.seatId)
end

function LandlordsModel:someoneReady(data)
    --[[
        int32 seatId    = 1;
        int64 userMoney = 2;
    ]]
    -- self.playerList[data.seatId].isReady = true
    -- self:updatePlayers()
    -- 更新用户的金币数目
    self.playerList[data.seatId].money = data.userMoney
    return self:seatIdToPlayer(data.seatId)
end

function LandlordsModel:gameStart(data)
    --[[
        int32    bankSeatid        = 1;  //起手人的id
        int64    defaultAnte       = 2;
        int64    totalAnte         = 3;  //当前倍数
        repeated Card cards        = 5;  //用户手牌
    ]]
    self.isSelfInGame = true
    for index, player in ipairs(self.playerList) do
        player.cardsCnt = LandlordsModel.NormalCardsCount
    end

    self.mulitiple = data.totalAnte
    if #data.cards == LandlordsModel.NormalCardsCount then
        self.playerList[self.selfSeatId].cards = self:serverCardToClientCards(data.cards)
    elseif #data.cards == LandlordsModel.NormalCardsCount * 3 then
        -- 说明在测试
        self.testRobot = true

        local zjCards = {}
        local xjCards = {}
        local sjCards = {}
        for index, card in ipairs(data.cards) do
            if 1 <= index and index <= LandlordsModel.NormalCardsCount then
                zjCards[#zjCards + 1] = card
            elseif LandlordsModel.NormalCardsCount < index and index <= LandlordsModel.NormalCardsCount * 2 then
                xjCards[#xjCards + 1] = card
            elseif LandlordsModel.NormalCardsCount * 2 < index and index <= LandlordsModel.NormalCardsCount * 3 then
                sjCards[#sjCards + 1] = card
            end
        end
        self.playerList[self.selfSeatId].cards = self:serverCardToClientCards(zjCards)
        self.playerList[self:playerToSeatId(LandlordsModel.Player.XiaJia)].cards = self:serverCardToClientCards(xjCards)
        self.playerList[self:playerToSeatId(LandlordsModel.Player.ShangJia)].cards = self:serverCardToClientCards(sjCards)
    end
    self.knownCards = self.playerList[self.selfSeatId].cards
    self.firstSeatId = data.bankSeatid
    self:allottedOperate(data.bankSeatid, LandlordsModel.ActionStatus.Jiaodizhu)
end

function LandlordsModel:nextOperate(data)
    --[[
        int32 seatId    = 1;
        int32 leftTime  = 2;
        int64 operate   = 6;  //跟注     --0 叫地主 抢地主 出牌 接牌 过牌
    ]]
    self:allottedOperate(data.seatId, data.operate, data.leftTime)
end

function LandlordsModel:operate(data)
    --[[
        int32    seatId     = 1;
        int32    userStatus = 2;
        int64    curAnte    = 3;  // 0取消 1确认
        int64    totalAnte  = 5;  //当前倍数
        int32    operate    = 6;  //当前操作
        repeated Card cards = 7;  //操作的牌
        int32    cardType   = 8;  //牌型
        int32    times      = 9;  //当前操作产生的倍数
    ]]
    --{"cardType":5,"totalAnte":3,"seatId":3,"operate":6}
    self.currentCardType = data.cardType
    self.currentCards = self:serverCardToClientCards(data.cards)
    
    -- 牌型变更
    if self.currentCardType == LandlordsModel.CardsType.THREE_TAKE_ONE then
        if #self.currentCards > 4 then
            self.currentCardType = LandlordsModel.CardsType.THREE_LINE
        end
    elseif self.currentCardType == LandlordsModel.CardsType.THREE_TAKE_PAIR then
        if #self.currentCards > 5 then
            self.currentCardType = LandlordsModel.CardsType.THREE_LINE
        end
    elseif self.currentCardType == LandlordsModel.CardsType.FOUR_TAKE_PAIR then
        if #self.currentCards == 6 then
            self.currentCardType = LandlordsModel.CardsType.FOUR_TAKE_ONE
        end
    elseif self.currentCardType == LandlordsModel.CardsType.DOUBLE_JOKER then
        -- FIXME: 双王炸改炸弹
        -- self.currentCardType = LandlordsModel.CardsType.BOMB
        -- self.currentCardType = LandlordsModel.CardsType.DOUBLE_JOKER
    end

    if self.mulitiple ~= data.totalAnte then
        self.mulitipleChanged = true
        self.currentMulitiple = data.times
    else
        self.mulitipleChanged = false
        self.currentMulitiple = -1
    end
    self.mulitiple = data.totalAnte
    
    -- 自己操作的牌 不加
    if self.currentAction.player ~= LandlordsModel.Player.Ziji then
        table.append(self.knownCards, self.currentCards)
    end
    self:allottedOperate(data.seatId, data.operate, 0, data.curAnte)
    self.playerList[data.seatId].cardsCnt = self.playerList[data.seatId].cardsCnt - #self.currentCards

    if self.testRobot then
        local newHandCards = {}
        for index, card in ipairs(self.playerList[data.seatId].cards) do
            local isOutCard = false
            for _, outCard in ipairs(self.currentCards) do
                if outCard == card then
                    isOutCard = true
                    break
                end
            end
            if not isOutCard then
                newHandCards[#newHandCards + 1] = card
            end
        end
        self.playerList[data.seatId].cards = newHandCards
    end
end

function LandlordsModel:flipCards(data)
    --[[
        int32 seatId            = 1; //地主座位
        repeated Card cards     = 2; //底牌
        int32 boardCardTimes    = 3; //底牌倍数
        int32 totalTimes        = 4; //当前总倍数
    ]]
    -- 当前桌子 游戏中
    self.tableInfo.tableStatus = CONSTS.LANDLORDS.TABLE_STATE.PLAY


    -- 翻底牌的时候 扣除台费
    self.sj.money = self.sj.money - self.roomConfig.charge
    self.xj.money = self.xj.money - self.roomConfig.charge
    GameManager.UserData.money = GameManager.UserData.money - self.roomConfig.charge

    self.dizhuSeatId = data.seatId
    self.dizhuPlayer = self:seatIdToPlayer(data.seatId)
    self.boardCards  = self:serverCardToClientCards(data.cards)
    if self:isDizhu() then
        table.append(self.knownCards, self.boardCards)
    end
    self.playerList[data.seatId].cardsCnt = LandlordsModel.MaxCardsCount
    if self.mulitiple ~= data.totalTimes then
        self.mulitipleChanged = true
    else
        self.mulitipleChanged = false
    end
    self.mulitiple          = data.totalTimes
    self.boardCardMulitiple = data.boardCardTimes
end

function LandlordsModel:hint(data)
    self.hintCards = self:serverCardToClientCards(data.cards)
    dump(self.hintCards, T("提示的牌是"))
end

function LandlordsModel:gameOver(data)
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
        int32    result                = 4;  //1地主赢 2农民赢
        int32    isSpring              = 5;  //是否是春天
    ]]
    -- 结算界面需要的相关数据
    self.tableInfo.tableStatus = CONSTS.LANDLORDS.TABLE_STATE.STOPED
    self.isSelfInGame = false
    self.isSelfRobot  = false
    self.result.winnerResult = data.result
    self.result.isSelfDizhu  = self.dizhuPlayer == LandlordsModel.Player.Ziji
    if     self.result.winnerResult == 1 then
        self.result.isSelfWinner = self.dizhuPlayer == LandlordsModel.Player.Ziji
    elseif self.result.winnerResult == 2 then
        self.result.isSelfWinner = self.dizhuPlayer ~= LandlordsModel.Player.Ziji
    end

    if self.result.isSelfWinner then
        GameManager.UserData.win = GameManager.UserData.win + 1
    else
        GameManager.UserData.lose = GameManager.UserData.lose + 1
    end

    --[[
        更新红包局数
    ]]
    if self.redpacketMission.condition.type == LandlordsModel.ConditionType.DayWin then
        if self.result.isSelfWinner then
            if not self.redpacketMission.isAllDone then
                self.redpacketMission.current = self.redpacketMission.current + 1
            end
        end
    elseif self.redpacketMission.condition.type == LandlordsModel.ConditionType.BeDz then
        if self.result.isSelfDizhu then
            if not self.redpacketMission.isAllDone then
                self.redpacketMission.current = self.redpacketMission.current + 1
            end
        end
    elseif self.redpacketMission.condition.type == LandlordsModel.ConditionType.DZWin then
        if self.result.isSelfDizhu and self.result.isSelfWinner then
            if not self.redpacketMission.isAllDone then
                self.redpacketMission.current = self.redpacketMission.current + 1
            end
        end
    end

    if data.isSpring == 1 then
        self.mulitipleChanged = true
        self.currentMulitiple = 2
        self.mulitiple = self.mulitiple * 2
    end
    local userInfo = {}
    for index, playInfo in ipairs(data.playerList) do
        -- 然后把牌放到每个人里面去
        self.playerList[index].cards = self:serverCardToClientCards(playInfo.cards)
        self.playerList[index].money = playInfo.userMoney

        local player = self:seatIdToPlayer(playInfo.seatId)
        local isDizhu = self.dizhuPlayer == player

        -- 是不是破产
        local isBankrupt = false
        
        if GameManager.ODialogManager:judegeIsBankrupt(playInfo.userMoney) then
            isBankrupt = true
        end

        userInfo[player] = {
            name        = self.playerList[index].name,
            addMoney    = playInfo.addMoney,
            userMoney   = playInfo.userMoney,
            settleState = playInfo.settleState,
            isDizhu     = isDizhu,
            mulitiple   = isDizhu and self.mulitiple * 2 or self.mulitiple,
            uid         = playInfo.uid,
            ante        = self.roomConfig.ante,
            isBankrupt  = isBankrupt,
        }
        if player == LandlordsModel.Player.Ziji then
            GameManager.UserData.exp = GameManager.UserData.exp + playInfo.addExp
        end
    end
    self.result.userInfo                = userInfo
    self.result.isSpring                = data.isSpring == 1
    self.result.redpacketExchangeRate   = self.roomConfig.jewel_rate
    -- self.result.redpacketExchangeSwitch = self.roomConfig.jewel_switch
    local landlordsType = UnityEngine.PlayerPrefs.GetInt(DataKeys.CHOOSEROOM_TYPE)
    if landlordsType == 0 then
        self.result.redpacketExchangeSwitch = self.roomConfig.jewel_switch
    else
        self.result.redpacketExchangeSwitch = 0
    end
    self.result.baopeiTime              = self.roomConfig.drop_line
    self:updatePlayers()
end


--[[
    红包相关
]]

function LandlordsModel:updateRedpacketMission()
    for index, goal in ipairs(self.redpacketMission.goal) do
        local isReceived = false
        for j, received in ipairs(self.redpacketMission.received) do
            if received.id == goal.id then
                isReceived = true
                break;
            end
        end
        if not isReceived then
            self.redpacketMission.isAllDone = false
            self.redpacketMission.currentGoal = goal.goal
            self.redpacketMission.currentId   = goal.id
            break
        end
    end
    if not self.redpacketMission.currentGoal then
        -- 所有任务完成
        self.redpacketMission.isAllDone = true

        local goal = self.redpacketMission.goal[#self.redpacketMission.goal]
        self.redpacketMission.currentGoal = goal.goal
        self.redpacketMission.currentId   = goal.id
    end
end

function LandlordsModel:getRedpacketMission(data)
    --[[
        "current": 2,
        "goal": {
            {
                "id": 2,
                "goal": 5
            },
        },
        "received": {
            {
                "id": 1,
                "num": "7"
            }
        }
        "switch" : 1
    ]]
    self.redpacketMission.current   = data.current
    self.redpacketMission.goal      = data.goal
    self.redpacketMission.received  = data.received
    self.redpacketMission.switch    = data.switch
    self.redpacketMission.condition = LandlordsModel.ConditionConfig[data.condition]
    self:updateRedpacketMission()
end

function LandlordsModel:receiveRedpacket(data)
    --[[
        "flag": 1,
        "gain_jewel": 10,
        "other_reward": {
            "7"
            "9"
            "11"
            "12"
        }
    ]]
    self.redpacketMission.gainJewel = data.gain_jewel
    self.redpacketMission.otherJewel = data.other_reward
end

return LandlordsModel