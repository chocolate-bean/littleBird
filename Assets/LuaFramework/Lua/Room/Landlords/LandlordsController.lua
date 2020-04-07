local LandlordsController  = class("LandlordsController")
local LandlordsModel       = require("Room.Landlords.LandlordsModel")
local Card                 = require("Room.Landlords.Card")
local LandlordsSettleView  = require("Room.Landlords.LandlordsSettleView")
local RedpacketSelectView  = require("Room.Landlords.RedpacketSelectView")
local QuickChatView        = require("Room.QuickChatView")
local PanelNewVipHelper       = require("Panel.Special.PanelNewVipHelper")
local SP = require("Server.SERVER_PROTOCOL")

LandlordsController.RESULT_DELAY_TIME = 2

function LandlordsController:ctor(scene, data)
    self.scene_ = scene
    self.model = LandlordsModel.new()
    if type(data) == "table" then
        self.loginRoomData = data
    else
        local tid = data
        self.loginRoomTid = tid
    end
end

function LandlordsController:prefabDidLoad()
    self.view = self.scene_.view
    self.quickChatView = QuickChatView.new({type = QuickChatView.Type.Default})
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
    if self.loginRoomData then
        self:loginRoomResponse(self.loginRoomData)
    elseif self.loginRoomTid then
        GameManager.ServerManager:loginRoom(self.loginRoomTid)
    end
end

function LandlordsController:exitScene()

    function logoutRoom()
        GameManager.ServerManager:logoutRoom()
    end

    if self.model.kickOutSelf then
        GameManager:enterScene("HallScene", 2)
    end

    if self.model:isPlayingGame() then
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("确认退出"),
            text = T("牌局已经开始，退出会进入托管"),
            firstButtonCallbcak = function()
                logoutRoom()
            end,
        })
    else
        logoutRoom()
    end
end

function LandlordsController:onReturnKeyClick()
    self:exitScene()
end

function LandlordsController:onCleanUp()
    self.scene_:onCleanUp()
    if self.view.onCleanUp then
        self.view:onCleanUp()
    end
    self:setServerResponseStop(true)
    self.quickChatView:removeServerListener()
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end

function LandlordsController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function LandlordsController:onServerResponse(cmd, data)
    if self.serverResponseStop_ then
        return
    end

    if not self.responseAction then
        self.responseAction = {
            [SP.CLISVR_HEART_BEAT]      = self.heartBeatResponse,

            [SP.CLI_LOGIN_ROOM]         = self.loginRoomResponse,
            [SP.CLI_CHANGE_ROOM]        = self.changeRoomResponse,
            [SP.CLI_SIT_DOWN]           = self.sitDownResponse,
            [SP.CLI_STAND_UP]           = self.standupResponse,
            [SP.CLI_LOGOUT_ROOM]        = self.logoutRoomResponse,
            [SP.CLI_SEND_ROOM_MSG]      = self.sendRoomMsgResponse,
            [SP.CLI_TABLE_SYNC]         = self.syncTableResponse,
            [SP.CLI_SET_BET]            = self.setBetResponse,
            [SP.CLI_SEND_REQ_HINT]      = self.getHintResponse,
            
            [SP.SVR_SIT_DOWN]           = self.svrSitDownResponse,
            [SP.SVR_GAME_START]         = self.svrGameStartResponse,
            [SP.SVR_BC_USER_READY]      = self.svrReadyResponse,
            [SP.SVR_OTHER_STAND_UP]     = self.svrStandUpResponse,
            [SP.SVR_KICK_OUT]           = self.svrKickOutResoponse,
            [SP.SVR_COMMON_BROADCAST]   = self.commonBroadcastResponse,
            [SP.SVR_NEXT_BET]           = self.svrNextBetResponse,
            [SP.SVR_BET]                = self.svrBetResponse,
            [SP.SVR_FLIP_CARDS]         = self.svrFlipCardsResponse,
            [SP.SVR_GAME_OVER]          = self.svrGameOverResponse,
            [SP.SVN_AUTO_ADD_MIN_CHIPS] = self.xxxxxxxxx,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        if data then
            print(string.format("LandlordsController cmd:%#x -> %s",cmd, json.encode(data)))
        else
            -- print(string.format("LandlordsController cmd:%#x -> null",cmd))
        end
        action(self, data)
    else
        print(string.format("LandlordsController 没有找到Action cmd:%#x", cmd))
    end
end



--[[
    server
]]
    
function LandlordsController:heartBeatResponse(data)
    -- print("斗地主内心跳")
end

function LandlordsController:loginRoomResponse(data)
    -- 初始化model
    self:getCardRecord()
    self:getJewelMission()
    self:getRedDot()

    -- http请求开始
    
    if self.model.needChangeRoom or self.model.needChangeLevel then
        local roomType = CONSTS.ROOM_TYPE.LANDLORDS
        self.gameOverAutoAction = nil
        --[[
            房间内不重新切换
        ]]
        -- GameManager:enterScene("RoomScene", {data = data, roomType = roomType})
        -- return
    end
    -- 五个位置里面的空位置
    self.model.roomConfig = GameManager.ChooseRoomManager:getLandlordsRoomConfigByRoomLevel(data.table.level)
    self.model:loginRoom(data)
    self.view:updateTableInfo(false)
    self.view:updateOtherPlayer()

    if self.model.tableInfo.tableStatus == CONSTS.LANDLORDS.TABLE_STATE.STOPED then

        -- 查看桌子里面有没有人
        if self.model.sj then
            self.view:tableShowReadyImage(LandlordsModel.Player.ShangJia, true)
        end

        if self.model.xj then
            self.view:tableShowReadyImage(LandlordsModel.Player.XiaJia, true)
        end

        local seatId = self.model:getEmptySeatId()
        if seatId ~= -1 then
            GameManager.ServerManager:sitDown(seatId, GameManager.UserData.money, true)
        else
            self:sitDownFail()
        end
    else
        -- 重连进来 看看自己手上还有多少手牌
        local isDizhu = false
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.AI, 0, {})
        -- 游戏中
        if self.model.tableInfo.tableStatus == CONSTS.LANDLORDS.TABLE_STATE.PLAY then
            self.view:dealHandCard(self.model.zj.cards, isDizhu)
            -- 有底牌了 就是已经完成了叫抢地主阶段
            self.view:showTableInfo()
            self.view:showCoverCards(self.model.boardCards, self.model.boardCardMulitiple)
            -- 谁是地主 谁是农民
            self.view:becomeDizhuAnimation(self.model.dizhuPlayer, false)
            self.view:updateCardRecord(self.model.knownCards)
            -- 每家出的牌
            local isFollow = false
            for index, player in pairs(LandlordsModel.Player) do
                if player ~= self.model.currentAction.player then
                    local seatId = self.model:playerToSeatId(player)
                    local isDizhu = player == self.model.dizhuPlayer
                    local outCards = self.model.playerList[seatId].outCards
                    if not isFollow then
                        isFollow = #outCards > 0
                    end
                    self.view:tableShowDapaiCard(player, self.model.playerList[seatId].outCards, false, isDizhu)
                end
            end
            -- 自己的回合 展示要得起还是出牌
            if isFollow then
                -- TODO: 判断自己到底要不要的起
                -- self.view:showActionView(self.model.isZijiAction(), LandlordsModel.ActionStatus.Yaodeqi)
                self.model.judgeOperate = true
                self.model.hintCards = {}
                GameManager.ServerManager:getHint()
            else
                self.view:showActionView(self.model:isZijiAction(), LandlordsModel.ActionStatus.Qishou)
                self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
            end
        end

        -- 叫抢地主阶段
        if self.model.tableInfo.tableStatus == CONSTS.LANDLORDS.TABLE_STATE.CALL then
            self.view:showTableInfo()
            self.view:dealHandCard(self.model.zj.cards, isDizhu)
            self.view:showActionView(self.model:isZijiAction(), self.model.currentAction.operate)
        end

        -- 当前轮到谁
        self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
        self.view:updateTableInfo(false)
    end
end

function LandlordsController:changeRoomResponse(data)
    if data.ret == 0 then
        if data.tid then
            self.model.needChangeRoom = true
            self.model:clean()
            self.view:updateOtherPlayer()

            local allPlayer = {
                LandlordsModel.Player.Ziji,
                LandlordsModel.Player.XiaJia,
                LandlordsModel.Player.ShangJia,
            }   

            for i, player in ipairs(allPlayer) do
                self.view:tableShowReadyImage(player, false)
            end
            self.view:showGameoverView(false)
            
            GameManager.ServerManager:loginRoom(data.tid)
        else
            GameManager.TopTipManager:showTopTip(T("换桌失败"))
        end
    else
        GameManager.TopTipManager:showTopTip(T("换桌失败"))
    end
end

function LandlordsController:sitDownResponse(data)
    if data.ret ~= 0 then
        self:sitDownFail()
    end
end

function LandlordsController:standupResponse(data)
    
end

function LandlordsController:logoutRoomResponse(data)
    if self.model.needChangeRoom then
        local roomLevel = self.model.roomConfig.level
        if self.model.needChangeLevel then
            local config = GameManager.ChooseRoomManager:getLandlordsRoomConfigByMoney(GameManager.UserData.money)
            roomLevel = config.level
        end
        GameManager.ServerManager:changeRoomAndLogin(roomLevel, GameManager.UserData.mlevel, GameManager.UserData.money, self.model.tableInfo.tid)
    else
        GameManager:enterScene("HallScene", 2)
    end
end

function LandlordsController:sendRoomMsgResponse(data)
    local mtype = data.mtype
    local info = json.decode(data.info)
    local uid = tonumber(data.uid)

    local fromPlayer = self.model:getPlayerByUid(uid)
    info.mtype = mtype
    info.fromPlayer = fromPlayer
    
    if mtype == 1 then
        --聊天消息
        self.view:showChatBubbleView(fromPlayer, info.message)
    elseif mtype == 2 then
        -- 用户换头像
    elseif mtype == 3 then
        -- 赠送礼物
    elseif mtype == 4 then
        -- 设置礼物
    elseif mtype == 5 then
        --发送表情
        self.view:showEmojiView(fromPlayer, {type = info.fType, index = info.faceId})
    elseif mtype == 6 then
        --互动道具info.toSeatIds
        local index   = info.index
        local count = info.count or 1
        if fromPlayer then
            if type(info.toSeatIds) == "table" then
                for i, seatId in ipairs(info.toSeatIds) do
                    --[[FIXME: 兼容机器人发送表情时候 位置不对的bug]]
                    if uid >= 5000 and uid <= 10000 then
                        seatId = seatId + 1
                    end
                    self.view:showHDDJView(fromPlayer, self.model:seatIdToPlayer(seatId), index)
                end
            else
                self.view:showHDDJView(fromPlayer, self.model:seatIdToPlayer(info.toSeatIds), index)
            end
        end
    elseif mtype == 7 then
        --给荷官赠送筹码
    elseif mtype == 8 then
        --老虎机大奖广播
    elseif mtype == 9 then
        --广播加好友动画
    end
end

function LandlordsController:syncTableResponse(data)
    
end

function LandlordsController:setBetResponse(data)
    if data.ret ~= 0 then
        -- GameManager.TopTipManager:showTopTip(T("网络不给力，获取数据失败，请重试"))
        self.view:showCantPlayView(true, true)
    else
        self.view:showActionView(false)
    end
end

function LandlordsController:getHintResponse(data)
    self.model:hint(data)
    if self.model.isSelfRobot then
        local yes = 1
        local no  = 0  
        if self.model.currentAction.operate == LandlordsModel.ActionStatus.Jiaodizhu then
            GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.CALL, no, {})
        elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Qiangdizhu then
            GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.GRAB, no, {})
        elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Qishou 
        or     self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaodeqi then
            if self.model.hintCards and #self.model.hintCards ~= 0 then
                if self.model.currentAction.operate == LandlordsModel.ActionStatus.Qishou then
                    GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.OUTCARD, yes, self.model.hintCards)
                elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaodeqi then
                    GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.FOLLOW, yes, self.model.hintCards)
                end
            else
                GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes, {})
            end
        elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaobuqi then
            GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes, {})
        end
    elseif self.model.judgeOperate then
        -- 如果是用来判断自己要不要的起的话 那么 就去显示相关信息
        if #self.model.hintCards == 0 then
            self.view:showActionView(self.model:isZijiAction(), LandlordsModel.ActionStatus.Yaobuqi)
        else
            self.view:showActionView(self.model:isZijiAction(), LandlordsModel.ActionStatus.Yaodeqi)
        end
        self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
        self.model.judgeOperate = false
    end
end

function LandlordsController:svrSitDownResponse(data)
    local currentPlayer = self.model:someoneSitDown(data)
    self.view:updateOtherPlayer()
    Timer.New(function()
    self.view:tableShowReadyImage(currentPlayer, true)
    self.view:tableShowActionImage(currentPlayer, false)
    end,0.5,0,true):Start()
end

function LandlordsController:svrStandUpResponse(data)
    local currentPlayer = self.model:someoneStandUp(data)
    self.view:updateOtherPlayer()
    self.view:tableShowReadyImage(currentPlayer, false)
    -- self.view:tableShowDapaiView(currentPlayer, false)
    self.view:tableShowActionImage(currentPlayer, false)
    -- self.view:tableShowMingpaiCard(currentPlayer, false)
end

function LandlordsController:svrReadyResponse(data)
    local currentPlayer = self.model:someoneReady(data)
    self.view:updateOtherPlayer()
    -- self.view:tableShowDapaiView(currentPlayer, false)
    self.view:tableShowActionImage(currentPlayer, false)
    self.view:tableShowReadyImage(currentPlayer, true)
    -- self.view:tableShowMingpaiCard(currentPlayer, false)
end

function LandlordsController:svrGameStartResponse(data)
    self.view:dealHandCard({}, false, false)
    self.view:showTableInfo()
    -- 重置相关操作
    local allPlayer = {
        LandlordsModel.Player.Ziji,
        LandlordsModel.Player.ShangJia,
        LandlordsModel.Player.XiaJia,
    }
    for index, player in ipairs(allPlayer) do
        self.view:tableShowMingpaiCard(player, false)
        self.view:tableShowDapaiView(player, false)
        self.view:tableShowActionImage(player, false)
        self.view:showRobotView(player, false)
    end

    self.model:gameStart(data)

    -- 发牌
    local isDizhu = false
    self.view:dealHandCard(self.model.zj.cards, true, isDizhu, function()
        -- 发完牌才展示对应的操作按钮以及相关
        local isShow = self.model:isZijiAction()
        self.view:showActionView(isShow, self.model.currentAction.operate)
        self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
        self.view:updateCardRecord(self.model.knownCards)
        self.view:showCardRecordCount(true)
    end)
    self:soundWithDealCard()

    if self.model.testRobot then
        self.view:tableShowMingpaiCard(LandlordsModel.Player.XiaJia, self.model.xj.cards)
        self.view:tableShowMingpaiCard(LandlordsModel.Player.ShangJia, self.model.sj.cards)
        self.view.xjMingpaiView.transform.localPosition = Vector3.New(self.view.xjMingpaiView.transform.localPosition.x,118,0)
        self.view.sjMingpaiView.transform.localPosition = Vector3.New(self.view.sjMingpaiView.transform.localPosition.x,118,0)
    end

    self.view:updateTableInfo(self.model.mulitipleChanged)
    self.view:rebackCoverCards()
    self.view:tableShowReadyImage(nil, false)
end

function LandlordsController:xxxxxxxxx(data)
    
end 

function LandlordsController:svrNextBetResponse(data)
    self:resume()
    self.model:nextOperate(data)

    -- 隐藏牌
    self.view:tableShowDapaiView(self.model.currentAction.player, false)
    self.view:tableShowActionImage(self.model.currentAction.player, false)

    if self.model.isSelfRobot then
        self.view:showActionView(false, LandlordsModel.ActionStatus.Tuoguan)
    end
    if self.model.currentAction.operate == LandlordsModel.ActionStatus.Jiaodizhu
    and self.model.currentAction.seatId == self.model.firstSeatId then
        -- 第一个人叫地主 等牌发完在显示钟
        -- Timer.New(function()
        --     self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
        -- end, 1.697, 1, true):Start()
    else
        local isShow = self.model:isZijiAction()
        self.view:showActionView(isShow, self.model.currentAction.operate)
        self.view:tableShowClock(self.model.currentAction.player, true, self.model.currentAction.actionTime)
    end

    if self.model:isZijiAction() 
    and (self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaodeqi or self.model.isSelfRobot) then
        -- 如果是自己的回合 同时是可以有提示的情况下
        -- 托管状态下 帮他操作 根据获取的提示来
        self.model.hintCards = {}
        GameManager.ServerManager:getHint()
    end
end

function LandlordsController:svrBetResponse(data)
    self:resume()
    self.model:operate(data)
    if not self.model:isZijiAction() then
        self.view:updateOtherPlayerHandCard()
    end

    if data.operate ~= LandlordsModel.ActionStatus.Tuoguan then
        if self.model.currentAction.operate == LandlordsModel.ActionStatus.Qishou 
        or self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaodeqi then

            -- 起手的时候 清除桌子状态
            if self.model.currentAction.operate == LandlordsModel.ActionStatus.Qishou then
                local allPlayer = {
                    LandlordsModel.Player.Ziji,
                    LandlordsModel.Player.ShangJia,
                    LandlordsModel.Player.XiaJia,
                }
                for index, player in ipairs(allPlayer) do
                    self.view:tableShowActionImage(player, false)
                end
            end
            -- 判断需不需要牌型动画
            local needAnimation = (self.model.currentCardType == LandlordsModel.CardsType.PAIR_LINE 
            or self.model.currentCardType == LandlordsModel.CardsType.THREE_LINE)
            local isDizhu = self.model.currentAction.player == self.model.dizhuPlayer
            self.view:tableShowDapaiCard(self.model.currentAction.player, self.model.currentCards, needAnimation, isDizhu)
            if self.model:isZijiAction() then
                self.view:subCardsInHand(self.model.currentCards)
            end
            -- 播放牌型动画
            self.view:showCardTypeAnimation(self.model.currentAction.player, self.model.currentCardType)
        elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaobuqi then
            self.view:tableShowDapaiCard(self.model.currentAction.player, self.model.currentCards, true)
        else
            self.view:tableShowActionImage(self.model.currentAction.player, true, self.model.currentAction.operateResult)
        end
    else
         -- 托管操作不在对应的流程队列里面
        if self.model.otherAction.operate == LandlordsModel.ActionStatus.Tuoguan then
            self.view:showRobotView(self.model.otherAction.player, self.model.otherAction.operateResult == LandlordsModel.ActionResult.tuoguan)
            -- 判断当前是不是自己在玩
            if self.model:isZijiAction() and self.model.otherAction.operateResult == LandlordsModel.ActionResult.tuoguan then
                self.model.hintCards = {}
                GameManager.ServerManager:getHint()
            end
            -- 这个地方主动做操作 因为 getHint 在叫地主抢地主阶段不会回包
            local yes = 1
            local no  = 0  
            if self.model.currentAction.operate == LandlordsModel.ActionStatus.Jiaodizhu then
                GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.CALL, no, {})
            elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Qiangdizhu then
                GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.GRAB, no, {})
            end
        end
    end
    self.view:updateTableInfo(self.model.mulitipleChanged)
    self.view:updateCardRecord(self.model.knownCards)
    self.view:tableShowClock(self.model.currentAction.player, false)
    if self.model.testRobot then
        self.view:tableShowMingpaiCard(LandlordsModel.Player.XiaJia, self.model.xj.cards)
        self.view:tableShowMingpaiCard(LandlordsModel.Player.ShangJia, self.model.sj.cards)
    end

    self:soundWithOperateAndCard(
    self.model.currentAction.seatId, 
    self.model.currentAction.operate, 
    self.model.currentAction.operateResult, 
    self.model.currentCards, 
    self.model.currentCardType)

end

function LandlordsController:svrFlipCardsResponse(data)
    self.model:flipCards(data)
    self.view:showCoverCards(self.model.boardCards, self.model.boardCardMulitiple)
    if self.model:isDizhu() then
        self.view:addCardsInHand(self.model.boardCards)
    end
    self.view:updateOtherPlayer()
    self.view:updateOtherPlayerHandCard()
    self.view:updateTableInfo(self.model.mulitipleChanged)
    self.view:becomeDizhuAnimation(self.model.dizhuPlayer, true)
    self.view:updateCardRecord(self.model.knownCards)

    -- 不清除桌子状态 让玩家知道 谁叫谁抢 这样
    -- local allPlayer = {
    --     LandlordsModel.Player.Ziji,
    --     LandlordsModel.Player.ShangJia,
    --     LandlordsModel.Player.XiaJia,
    -- }
    -- for index, player in ipairs(allPlayer) do
    --     self.view:tableShowActionImage(player, false)
    -- end

end

function LandlordsController:svrGameOverResponse(data)
    -- 结束时候调用 获取红点信息
    self:getRedDot()

    self.model:gameOver(data)

    function gameoverAction()
        self:soundWithGameOver()
        LandlordsSettleView.new(self.model.result, function(event)
            if event == LandlordsSettleView.Event.Ready then
                self:ready()
            elseif event == LandlordsSettleView.Event.Change then
                self:changeRoom()
            elseif event == LandlordsSettleView.Event.InitDone then
                self.view:realignRedpackButton(true)
                self.view:showGameoverView(true)
            elseif event == LandlordsSettleView.Event.Dismiss then
                self.view:realignRedpackButton(false)
            elseif event == LandlordsSettleView.Event.LevelUp then
                PanelNewVipHelper.new()
            end
        end)
        
        self.view:showRobotView(LandlordsModel.Player.Ziji, false)
        self.view:tableShowMingpaiCard(LandlordsModel.Player.ShangJia, self.model.sj.cards)
        self.view:tableShowMingpaiCard(LandlordsModel.Player.XiaJia, self.model.xj.cards)
        local otherPlayer = {
            LandlordsModel.Player.ShangJia,
            LandlordsModel.Player.XiaJia,
        }
        for index, player in ipairs(otherPlayer) do
            if player == LandlordsModel.Player.ShangJia then
                self.view:tableShowDapaiView(player, #self.model.sj.cards == 0)
            end
            if player == LandlordsModel.Player.XiaJia then
                self.view:tableShowDapaiView(player, #self.model.xj.cards == 0)
            end
            self.view:tableShowActionImage(player, false)
        end
        self.view:becomePlayerAnimation(true)
        self.view:updateOtherPlayer()
        self.view:showActionView(false, self.model.currentAction.operate)
        self.view:tableShowClock(self.model.currentAction.player, false, self.model.currentAction.actionTime)
        self.model:reset()
        self:getCardRecord()
        -- 更新牌局数
        self.view:updateRedpackMissionInfo(
            self.model.redpacketMission.current, 
            self.model.redpacketMission.currentGoal, 
            self.model.redpacketMission.isAllDone,
            self.model.redpacketMission.condition.tips)
    end
    -- 播放春天动画
    if self.model.result.isSpring then
        self.view:updateTableInfo(self.model.mulitipleChanged)
        self.view:showCardTypeAnimation(self.model.currentAction.player, "Chuntian", function()
            gameoverAction()
        end)
    else
        gameoverAction()
    end
end

function LandlordsController:svrKickOutResoponse(data)
    -- self:exitScene()
    self.model.needChangeRoom = true
    self.model.kickOutSelf    = true
    -- 这里的收到踢人 等于就是当前桌子不能坐了 必须换桌
end

function LandlordsController:commonBroadcastResponse(data)
    local infoData = json.decode(data.info)
    if infoData and infoData.latest_money then
        GameManager.UserData.money = tonumber(infoData.latest_money)
    end
    if infoData and infoData.message then
        GameManager.TopTipManager:showTopTip({msg = infoData.message, type = 1})
    end
    if data.mtype == 1 then
    elseif data.mtype == 2 then
    elseif data.mtype == 3 then
    elseif data.mtype == 4 then
    end
end

--[[
    私有方法
]]

function LandlordsController:sitDownFail()
    GameManager.TopTipManager:showTopTip(T("获取房间配置失败\n请重新尝试！"))
        Timer.New(function()
            self:exitScene()
        end, 1, 0, true):Start()
end

--[[
    暂停复原
]]

function LandlordsController:resume()
    local allPlayer = {
        LandlordsModel.Player.Ziji,
        LandlordsModel.Player.XiaJia,
        LandlordsModel.Player.ShangJia,
    }   
    
    for i, player in ipairs(allPlayer) do
        self.view:tableShowReadyImage(player, false)
    end
end

--[[
    view 回调
]]
function LandlordsController:timeOver()
    -- 记录超时次数
    local yes = 1
    local no  = 0
    if self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaobuqi then
        self.model.timeOverTimes = self.model.timeOverTimes + 1
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes, {})
    elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Yaodeqi then
        self.model.timeOverTimes = self.model.timeOverTimes + 1
        if self.model.hintCards then
            GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.FOLLOW, yes, self.model.hintCards)
        else
            GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes)
        end
    elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Qishou then
        self.model.timeOverTimes = self.model.timeOverTimes + 1
        local lastCard = self.model.zj.cards[#self.model.zj.cards]
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.OUTCARD, yes, {lastCard})
    elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Jiaodizhu then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.CALL, no, {})
    elseif self.model.currentAction.operate == LandlordsModel.ActionStatus.Qiangdizhu then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.GRAB, no, {})
    end
    if self.model.timeOverTimes >= 2 then
        print("超时次数"..self.model.timeOverTimes)
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.AI, yes, {})
    end
end

function LandlordsController:action()
    -- 取消超时次数
    self.model.timeOverTimes = 0
end

function LandlordsController:changeRoom(isReadyButtonClick)

    local changeRoom = function(isReadyButtonClick)
        if GameManager.UserData.money < self.model.roomConfig.min_money
        or (GameManager.UserData.money > self.model.roomConfig.max_limit_money 
        and self.model.roomConfig.max_limit_money ~= 0) then
            -- 不能在这个场子里面玩了
            self.model.needChangeLevel = true
        end

        if not isReadyButtonClick then
            self.view:dealHandCard({}, false, false)
        end
        self.model.needChangeRoom = true
        if self.model.kickOutSelf then
            local roomLevel = self.model.roomConfig.level
            if self.model.needChangeLevel then
                local config = GameManager.ChooseRoomManager:getLandlordsRoomConfigByMoney(GameManager.UserData.money)
                roomLevel = config.level
            end
            GameManager.ServerManager:changeRoomAndLogin(roomLevel, GameManager.UserData.mlevel, GameManager.UserData.money, self.model.tableInfo.tid)
        else
            GameManager.ServerManager:logoutRoom()
        end
    end

    if GameManager.ODialogManager.judegeIsBankrupt() then
        GameManager.ODialogManager:showBankruptDialogs(function(isSuccess)
            if not isSuccess then
                local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                    hasFristButton = true,
                    hasSecondButton = false,
                    hasCloseButton = false,
                    title = T("提示"),
                    text = T("你的金币不足"),
                    firstButtonCallbcak = function()
                    end,
                })   
            else
                changeRoom(isReadyButtonClick)
            end 
        end)
    else
        changeRoom(isReadyButtonClick)
    end
end

function LandlordsController:ready()

    local ready = function()
        -- 判断当前的金币需不需弹出破产补助 而且 还得判断当前的金币是不是适用于这个场次
        if GameManager.UserData.money < self.model.roomConfig.min_money
        or (GameManager.UserData.money > self.model.roomConfig.max_limit_money 
        and self.model.roomConfig.max_limit_money ~= 0) then
            -- 不能在这个场子里面玩了
            self.model.needChangeLevel = true
            self:changeRoom(true)
            return
        end

        if self.model.needChangeRoom then
            self:changeRoom(true)
            return
        end
        
        GameManager.ServerManager:sendReady()
        self.view:showGameoverView(false)
    end

    if GameManager.ODialogManager.judegeIsBankrupt() then
        GameManager.ODialogManager:showBankruptDialogs(function(isSuccess)
            if not isSuccess then
                local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                    hasFristButton = true,
                    hasSecondButton = false,
                    hasCloseButton = false,
                    title = T("提示"),
                    text = T("你的金币不足"),
                    firstButtonCallbcak = function()
                    end,
                })   
            else
                ready()
            end 
        end)
    else
        ready()
    end
end

function LandlordsController:chatButtonClick()
    self.quickChatView:show()
end

function LandlordsController:showRedpacketMission()
    -- self:receiveJewelMission(self.model.redpacketMission.currentId)
    self.redpacketSelectView = RedpacketSelectView.new( {datas = self.model.redpacketMission}, 
        function(event, index)
            if event == RedpacketSelectView.EventCallback.InitDone then
                -- self.view:realignRedpackButton(true)
            elseif event == RedpacketSelectView.EventCallback.Select then
                if self.model.redpacketMission.goal[index].goal > self.model.redpacketMission.current then
                    return
                end
                self:receiveJewelMission(self.model.redpacketMission.goal[index].id)
            elseif event == RedpacketSelectView.EventCallback.Dismiss then
                self:getJewelMission()
            end
        end)
end


--[[
    声音相关
]]

--[[
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
]]

function LandlordsController:soundWithOperateAndCard(seatId, operate, result, cards, cardType)
    local playInfo = self.model.playerList[seatId]
    local sex = tonumber(playInfo.msex)

    local soundName = "landlords/"
    if sex == 1 then
        soundName = soundName.."man/"
    else
        soundName = soundName.."woman/"
    end

    if operate == LandlordsModel.ActionStatus.Jiaodizhu then
        if result == LandlordsModel.ActionResult.jiaodizhu then
            soundName = soundName.."call"
            GameManager.SoundManager:PlaySoundWithNewSource(soundName)
        elseif result == LandlordsModel.ActionResult.bujiao then
            soundName = soundName.."bujiao"
            GameManager.SoundManager:PlaySoundWithNewSource(soundName)
        end
    elseif operate == LandlordsModel.ActionStatus.Qiangdizhu then
        if result == LandlordsModel.ActionResult.qiangdizhu then
            local qiangdizhuConfig = {
                "rob1",
                "rob2",
            }
            soundName = soundName..qiangdizhuConfig[math.random(#qiangdizhuConfig)]
            GameManager.SoundManager:PlaySoundWithNewSource(soundName)
        elseif result == LandlordsModel.ActionResult.buqiang then
            soundName = soundName.."buqiang"
            GameManager.SoundManager:PlaySoundWithNewSource(soundName)
        end
    elseif operate == LandlordsModel.ActionStatus.Qishou then
        soundName = soundName..self:soundNameWithCard(cards,cardType)
        GameManager.SoundManager:PlaySoundWithNewSource(soundName, false, function()
            -- 判断剩余手牌数目 小于张数切换声音
            local soundName = self:soundWithOutCardDone(seatId, cards)
            print(soundName)
        end)
    elseif operate == LandlordsModel.ActionStatus.Yaodeqi then
        -- 要得起    
        local yaobuqiConfig = {
            "discard1",
            "discard2",
            "discard3",
        }
        if math.random(2) == 1 then
            soundName = soundName..yaobuqiConfig[math.random(#yaobuqiConfig)]
        else
            soundName = soundName..self:soundNameWithCard(cards,cardType)
        end
        GameManager.SoundManager:PlaySoundWithNewSource(soundName, false, function()
            -- 判断剩余手牌数目 小于张数切换声音
            local soundName = self:soundWithOutCardDone(seatId, cards)
            print(soundName)
        end)
    elseif operate == LandlordsModel.ActionStatus.Yaobuqi then
        -- 要不起
        local yaobuqiConfig = {
            "pass1",
            "pass2",
            "pass3",
        }
        soundName = soundName..yaobuqiConfig[math.random(#yaobuqiConfig)]
        GameManager.SoundManager:PlaySoundWithNewSource(soundName)
    end
end

function LandlordsController:soundNameWithCard(cards, cardType)
    local soundName = ""
    if cardType == LandlordsModel.CardsType.SINGLE then
        local count = Card.getCount(cards[1])
        soundName = "1/ge_"..count
    elseif cardType == LandlordsModel.CardsType.PAIR then
        local count = Card.getCount(cards[1])
        soundName = "2/dui_"..count
    elseif cardType == LandlordsModel.CardsType.THREE then
        local count = Card.getCount(cards[1])
        soundName = "3/san_"..count
    elseif cardType == LandlordsModel.CardsType.LINE then
        soundName = "shunzi"
    elseif cardType == LandlordsModel.CardsType.PAIR_LINE then
        soundName = "liandui"
    elseif cardType == LandlordsModel.CardsType.THREE_LINE then
        soundName = "feiji"
    elseif cardType == LandlordsModel.CardsType.THREE_TAKE_ONE then
        soundName = "sandaiyi"
    elseif cardType == LandlordsModel.CardsType.THREE_TAKE_PAIR then
        soundName = "sandaiyidui"
    elseif cardType == LandlordsModel.CardsType.FOUR_TAKE_ONE then
        soundName = "sidaier"
    elseif cardType == LandlordsModel.CardsType.FOUR_TAKE_PAIR then
        soundName = "sidailiangdui"
    elseif cardType == LandlordsModel.CardsType.BOMB then
        soundName = "bomb"
    elseif cardType == LandlordsModel.CardsType.DOUBLE_JOKER then
        soundName = "wangzha"
    end
    GameManager.SoundManager:PlaySoundWithNewSource("landlords/outCard")
    GameManager.SoundManager:PlaySoundWithNewSource("landlords/outCardTable")
    return soundName
end

function LandlordsController:soundWithOutCardDone(seatId, cards)
    local soundName = ""
    local playInfo = self.model.playerList[seatId]

    -- 判断要不要播放对应的音乐
    if playInfo.cardsCnt > 2 then
        return
    end

    local sex = tonumber(playInfo.msex)
    local soundName = "landlords/"
    if sex == 1 then
        soundName = soundName.."man/"
    else
        soundName = soundName.."woman/"
    end
    if playInfo.cardsCnt == 2 then
        soundName = soundName.."warning2"
    elseif playInfo.cardsCnt == 1 then
        soundName = soundName.."warning1" 
    end
    if playInfo.cardsCnt ~= 0 then
        GameManager.SoundManager:PlaySoundWithNewSource(soundName)
        GameManager.SoundManager:ChangeBGM("landlords/bgm_rapid")
    end
    return soundName
end

function LandlordsController:soundWithDealCard()
    GameManager.SoundManager:PlaySoundWithNewSource("landlords/dealCard")
end

function LandlordsController:soundWithGameOver()
    GameManager.SoundManager:ChangeBGM("landlords/bgm_normal")
    if self.model.result.isSelfWinner then
        GameManager.SoundManager:PlaySoundWithNewSource("landlords/win")
    else
        GameManager.SoundManager:PlaySoundWithNewSource("landlords/lose")
    end
end

--[[
    Http请求相关
]]

function LandlordsController:getRedDot()
    -- 检查红点
    http.checkRedDot(
        function(callData)
            
            if callData then
                GameManager.GameFunctions.refashRedDotData(callData)
                
                if callData.task.dot == 1 then
                    self.view:showTaskRedDot(true)
                end
            end
        end,
        function (callData)
            
        end
    )
end

function LandlordsController:getCardRecord()
    http.getUserProp(
        5,
        function(callData)
            if callData then
                if #callData == 0 then
                    self.view:showCardRecordButton(false)
                else
                    self.view:showCardRecordButton(true)
                    if self.model:isPlayingGame() then
                        self.view:onCardRecordButtonClick()
                    end
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function LandlordsController:getJewelMission()
    http.getJewelMission(
        function(callData)
            if callData then
                self.model:getRedpacketMission(callData)
                self.view:showRedpackMissionButton(self.model.redpacketMission.switch == 1)
                self.view:updateRedpackMissionInfo(
                    self.model.redpacketMission.current, 
                    self.model.redpacketMission.currentGoal, 
                    self.model.redpacketMission.isAllDone,
                    self.model.redpacketMission.condition.tips)
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function LandlordsController:receiveJewelMission(id, callback)
    http.receiveJewelMission(
        id,
        function(callData)
            if callData and callData.flag == 1 then
                self.model:receiveRedpacket(callData)
                self.redpacketSelectView:showSelectView(self.model.redpacketMission, function()
                    GameManager.GameFunctions.setJewel(GameManager.UserData.jewel + tonumber(self.model.redpacketMission.gainJewel))
                    self:getJewelMission()
                end)
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function LandlordsController:exchangeJewel()
    http.exchangeJewel(
        function(callData)
            if callData then
                if #callData == 0 then
                    self.view:showCardRecordButton(false)
                else
                    self.view:showCardRecordButton(true)
                    if self.model:isPlayingGame() then
                        self.view:onCardRecordButtonClick()
                    end
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end


return LandlordsController