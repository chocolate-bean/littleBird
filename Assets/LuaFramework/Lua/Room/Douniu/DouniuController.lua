local DouniuController = class("DouniuController")
local DouniuModel      = require("Room.Douniu.DouniuModel")
local QuickChatView    = require("Room.QuickChatView")
local SP               = require("Server.SERVER_PROTOCOL")
local PanelDialog      = require("Panel.Dialog.PanelDialog")

function DouniuController:ctor(scene, data)
    self.scene_ = scene
    self.model = DouniuModel.new()
    if type(data) == "table" then
        self.loginRoomData = data
    else
        local tid = data
        self.loginRoomTid = tid
    end
end

function DouniuController:prefabDidLoad()
    self.view = self.scene_.view
    self.quickChatView = QuickChatView.new({type = QuickChatView.Type.Default})
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
    -- 添加model值改变回调
    self.model:addModelChangeListener(function(type, data)
        if type == DouniuModel.ModelChange.TableStatus then
            self.view:showClock(true, data.time, data.format)
        end
    end)

    if self.loginRoomData then
        self:loginRoomResponse(self.loginRoomData)
    elseif self.loginRoomTid then
        GameManager.ServerManager:loginRoom(self.loginRoomTid)
    end
end

function DouniuController:exitScene()
    function logoutRoom()
        GameManager.ServerManager:logoutRoom()
    end
    if self.model.kickOutSelf then
        self:onCleanUp()
        GameManager:enterScene("HallScene", 2)
    end
    if self.model:isSelfPlayingGame() then
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

function DouniuController:onReturnKeyClick()
    self:exitScene()
end

function DouniuController:onCleanUp()
    self.scene_:onCleanUp()
    if self.view.onCleanUp then
        self.view:onCleanUp()
    end
    self:setServerResponseStop(true)
    self.quickChatView:removeServerListener()
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end


function DouniuController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function DouniuController:onServerResponse(cmd, data)
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
            
            [SP.SVR_SIT_DOWN]           = self.svrSitDownResponse,
            [SP.SVR_GAME_START]         = self.svrGameStartResponse,
            [SP.SVR_OTHER_STAND_UP]     = self.svrStandUpResponse,
            [SP.SVR_KICK_OUT]           = self.svrKickOutResoponse,
            [SP.SVR_BC_START_BET]       = self.svrStartBetResoponse,
            [SP.SVR_SEND_SHOW_CARD]     = self.svrStartShowCardResoponse,
            [SP.SVR_COMMON_BROADCAST]   = self.commonBroadcastResponse,
            [SP.SVR_BET]                = self.svrBetResponse,
            [SP.SVR_BC_BANKER_INFO]     = self.svrBankerInfoResponse,
            [SP.SVR_GAME_OVER]          = self.svrGameOverResponse,
            [SP.SVN_AUTO_ADD_MIN_CHIPS] = self.xxxxxxxxx,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        action(self, data)
    else
        print(string.format("DouniuController 没有找到Action cmd:%#x", cmd))
    end
end



--[[
    server
]]
    
function DouniuController:heartBeatResponse(data)
    -- print("斗牛内心跳")
end

function DouniuController:loginRoomResponse(data)
    -- http请求开始
    self:getNormalNiuTips()

    if self.model.needChangeRoom or self.model.needChangeLevel then
        local roomType = CONSTS.ROOM_TYPE.DOUNIU
        self.gameOverAutoAction = nil
    end

    -- 初始化model
    self.model:loginRoom(data)
    for index, roomConfig in ipairs(GameManager.ChooseRoomManager.douniuConfig) do
        if tonumber(roomConfig.room.level) == tonumber(data.table.level) then
            self.model.roomConfig = roomConfig
        end
    end


    self.view:showTableInfoText(self.model:getTableInfoText())

    for index, player in pairs(self.model.playerList) do
        if player.uid ~= GameManager.UserData.mid then
            self.view:seatSitDown(player)
        end
    end

    if not self.model:isSelfPlayingGame() then
        local emptySeatId = self.model:getEmptySeatId()
        GameManager.ServerManager:sitDown(emptySeatId, GameManager.UserData.money, true)
    end

    if self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.STOPED then
        
    else
        -- 抢庄进来
        for index, player in pairs(self.model.playerList) do
            if player.isPlaying then
                self.view:dealCards(player, false)
            end
            if player.isBanker then
                -- 抢庄的标志
                self.view:showSeatBankerIcon(player, nil)
                -- 抢庄的倍数
                self.view:showSeatBetView(player, true)
            end
            if player.userStatus then
                -- 正常下注倍数
                self.view:showSeatBetView(player, true)
            end
        end
        if self.model:isSelfPlayingGame() then
            -- 判断当前的用户状态
        end
    end
end

function DouniuController:changeRoomResponse(data)
    if data.ret == 0 then
        if data.tid then
            self.model.needChangeRoom = true
            self.model:clean()
            GameManager.ServerManager:loginRoom(data.tid)
        else
            GameManager.TopTipManager:showTopTip(T("换桌失败"))
        end
    else
        GameManager.TopTipManager:showTopTip(T("换桌失败"))
    end
end

function DouniuController:sitDownResponse(data)
    if data.ret ~= 0 then
        self:sitDownFail()
    end
end

function DouniuController:standupResponse(data)
    
end

function DouniuController:logoutRoomResponse(data)
    self:onCleanUp()
    GameManager:enterScene("HallScene", 2)
end

function DouniuController:sendRoomMsgResponse(data)
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
                    self.view:showHDDJView(fromPlayer, self.model.playerList[seatId], index)
                end
            else
                self.view:showHDDJView(fromPlayer, self.model.playerList[info.toSeatIds], index)
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

function DouniuController:syncTableResponse(data)
    
end

function DouniuController:setBetResponse(data)
    if data.ret == 0 then
        -- 自己下注成功 隐藏一些东西
        self.view:hideAction()
    else
    end
end

function DouniuController:svrSitDownResponse(data)
    local currentPlayer = self.model:someoneSitDown(data)
    -- 判断当前桌子状态 如果当前桌子状态是在玩状态的话 就灰度位置
    local isPlaying = false
    if self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL 
    or self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.BET
    or self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CONFIRM then
        isPlaying = true
    end
    if currentPlayer.uid ~= GameManager.UserData.mid then
        self.view:seatSitDown(currentPlayer, isPlaying)
    else
        if isPlaying then
            self.view:seatGray(currentPlayer)
        end
    end
end

function DouniuController:svrStandUpResponse(data)
    local currentPlayer = self.model:someoneStandUp(data)
    self.view:seatStandUp(currentPlayer)
end

function DouniuController:svrGameStartResponse(data)
    self.model:gameStart(data)
    self.view:playStartAnimation(function()
        for index, player in pairs(self.model.playerList) do
            if player.isPlaying then
                self.view:dealCards(player, true)
            end
        end
    end)
end

function DouniuController:svrBetResponse(data)
    local currentPlayer = self.model:operate(data)
    if self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL 
    or self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.BET then
        if currentPlayer.uid == GameManager.UserData.mid then
            self.view:hideAction()
        end
        self.view:showSeatBetView(currentPlayer, true)
    elseif self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CONFIRM then
        if currentPlayer.uid == GameManager.UserData.mid then
            self.view:hideAction()
        end
        self.view:showCards(currentPlayer, true)
    end
    -- 播放抢庄声音
    if self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL and currentPlayer.curAnte > 0 then
        if tonumber(currentPlayer.msex) == 1 then
            GameManager.SoundManager:PlaySoundWithNewSource("douniu/call_nan")
        else
            GameManager.SoundManager:PlaySoundWithNewSource("douniu/call_nv")
        end
    end
end

function DouniuController:svrBankerInfoResponse(data)
    local bankerPlayer, sameAntePlayers = self.model:callBanker(data)
    self.view:showSeatBankerIcon(bankerPlayer, sameAntePlayers)
    self.view:showClock(false)
end

function DouniuController:svrGameOverResponse(data)
    self:getRedDot()
    self.model:gameOver(data)
    
    local bankerPlayer  = {}
    local losePlayers   = {}
    local winnerPlayers = {}
    for index, player in pairs(self.model.playerList) do
        -- 提前把座位index放到对应的player里面去 -- 不然用户离开 会报错
        self.view:setSeatIndexToSeatData(player)
        if player.isPlaying then
            if player.isBanker then
                bankerPlayer = player
            elseif player.addMoney > 0 then
                winnerPlayers[#winnerPlayers + 1] = player
            else
                losePlayers[#losePlayers + 1] = player
            end
        end
    end

    if #winnerPlayers == 0 and self.model:isSelfBanker() and #losePlayers > 1 then
        self.view:playBigWinAnimation(function()
            self.view:showChipChangeAnimation(bankerPlayer, losePlayers, winnerPlayers, function()
                self:reset()
            end)
        end, string.formatNumberThousands(self.model.selfData.addMoney))
    elseif self.model:isSelfPlayingGame() and self.model:isSelfWin() then
        self.view:playWinAnimation(function()
            self.view:showChipChangeAnimation(bankerPlayer, losePlayers, winnerPlayers, function()
                self:reset()
            end)
        end, string.formatNumberThousands(self.model.selfData.addMoney))
    else
        Timer.New(function()
            -- 预留时间给 输家的动画
            self.view:showChipChangeAnimation(bankerPlayer, losePlayers, winnerPlayers, function()
                self:reset()
            end)
        end, 1, 1, true):Start()
    end
    -- 等待动画结束 复原桌面
end

function DouniuController:svrStartBetResoponse(data)
    self.model:startBet(data)
    local isSelfPlayingGame = self.model:isSelfPlayingGame()
    local isSelfBanker = self.model:isSelfBanker()
    if isSelfPlayingGame and not isSelfBanker then
        self.view:showBetAction(self.model.betArray)
    end
    self.view:hideOtherBetView(self.model:getBankerPlayer())
end

function DouniuController:svrStartShowCardResoponse(data)
    self.model:showCard(data)
    if self.model:isSelfPlayingGame() then
        self.view:showLeftCards(self.model.selfData)
        if self.model.selfData.specialCardArray then
            GameManager.ServerManager:setBet(
                CONSTS.DOUNIU.ACTION_TYPE.CONFIRM,
                self.model.selfData.specialCard,
                self.model.selfData.specialCardArray)
        else
            self.view:showDoneAction(self.model.tips)
        end
    end
end

function DouniuController:svrKickOutResoponse(data)
    self.model.kickOutSelf = true
    self:onCleanUp()
    GameManager:enterScene("HallScene", 2)
end

function DouniuController:commonBroadcastResponse(data)
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

function DouniuController:xxxxxxxxx(data)
    
end 

--[[
    私有方法
]]

function DouniuController:sitDownFail()
    GameManager.TopTipManager:showTopTip(T("获取房间配置失败\n请重新尝试！"))
    Timer.New(function()
        self:exitScene()
    end, 1, 0, true):Start()
end

function DouniuController:reset()
    self.model:reset()
    self.view:resetAllSeat(self.model.playerList)
end

--[[
    暂停复原
]]

function DouniuController:resume()

end

--[[
    view 回调
]]

function DouniuController:chatButtonClick()
    self.quickChatView:show()
end

function DouniuController:clockTimeOver()
    -- self.quickChatView:show()
end


--[[
    声音相关
]]


--[[
    Http请求相关
]]

function DouniuController:getRedDot()
    -- 检查红点
    http.checkRedDot(
        function(callData)
            
            if callData then
                if callData.winchallenge.dot == 1 then
                    self.view:showHongbaoRedDot(true)
                end
                
                if callData.task.dot == 1 then
                    self.view:showTaskRedDot(true)
                end
            end
        end,
        function (callData)
            
        end
    )
end

function DouniuController:getNormalNiuTips()
    http.getNormalNiuTips(
        function(callData)
            if callData then
                self.model:getNormalNiuTips(callData)
            end
        end,
        function (callData)
        end
    )
end

function DouniuController:useNormalNiuTips(callback)
    http.useNormalNiuTips(
        function(callData)
            if callData then
                if callData.flag == 1 then
                    self.model:getNormalNiuTips(callData)
                    self.view:showDoneAction(self.model.tips)
                    GameManager.UserData.money = tonumber(callData.latest_money)
                    callback(true)
                else
                    callback(false)
                end
            end
        end,
        function (callData)
            callback(false)
        end
    )
end

return DouniuController