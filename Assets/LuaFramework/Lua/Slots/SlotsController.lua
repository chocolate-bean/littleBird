local SlotsController = class("SlotsController")
local SlotsView            = require("Slots.SlotsView")
local SP                   = require("Server.SERVER_PROTOCOL")
local InteractiveAnimation = require("Room.InteractiveAnimation")


local SeatMaxCount = 5

SlotsController.RESULT_DELAY_TIME = 2

function SlotsController:ctor(scene, data)
    self.scene_ = scene
    self.loginRoomData = data
    self.model = {}
    self.bonusCnt = 0
    self.interactiveAnimation = InteractiveAnimation.new()
end

function SlotsController:prefabDidLoad()
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
    self.view = self.scene_.view

    self:loginRoomResponse(self.loginRoomData)

end

function SlotsController:exitScene()
    GameManager:enterScene("HallScene", 2)
    GameManager.ServerManager:logoutRoom()
end

function SlotsController:onReturnKeyClick()
    self:exitScene()
end


function SlotsController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function SlotsController:onServerResponse(cmd, data)
    if self.serverResponseStop_ then
        return
    end

    if not self.responseAction then
        self.responseAction = {
            [SP.CLISVR_HEART_BEAT]      = self.heartBeatResponse,

            [SP.CLI_LOGIN_ROOM]         = self.loginRoomResponse,
            [SP.CLI_SIT_DOWN]           = self.sitDownResponse,
            [SP.CLI_STAND_UP]           = self.standupResponse,
            [SP.CLI_SLOT_BET]           = self.sendSlotBetResponse,
            [SP.CLI_LOGOUT_ROOM]        = self.logoutRoomResponse,
            [SP.CLI_SEND_ROOM_MSG]      = self.sendRoomMsgResponse,
            [SP.CLI_TABLE_SYNC]         = self.syncTableResponse,
            
            [SP.SVR_SIT_DOWN]           = self.svrSitDownResponse,
            [SP.SVN_AUTO_ADD_MIN_CHIPS] = self.xxxxxxxxx,
            [SP.SVR_OTHER_STAND_UP]     = self.svrStandUpResponse,
            [SP.SVR_BROADCAST_RESULT]   = self.svrBroadcastResultResponse,
            [SP.SVR_KICK_OUT]           = self.svrKickOutResoponse,
            [SP.SVR_COMMON_BROADCAST]   = self.commonBroadcastResponse,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        if data then
            print(string.format("SlotsController cmd:%#x -> %s",cmd, json.encode(data)))
        else
            -- print(string.format("SlotsController cmd:%#x -> null",cmd))
        end
        action(self, data)
    else
        print(string.format("SlotsController 没有找到Action cmd:%#x", cmd))
    end
end



--[[
    server
]]
    
function SlotsController:heartBeatResponse(data)
    -- print("水果机内心跳")
end

function SlotsController:loginRoomResponse(data)
    -- 五个位置里面的空位置
    self.model.tableInfo  = data.table
    self.model.playerList = {}
    for i, playerInfo in ipairs(data.playerList) do
        self.model.playerList[playerInfo.seatId]        = json.decode(playerInfo.userInfo)
        self.model.playerList[playerInfo.seatId].uid    = playerInfo.uid
        self.model.playerList[playerInfo.seatId].seatId = playerInfo.seatId
        if playerInfo.uid ~= GameManager.UserData.mid then
            self.view:sitDown(self.model.playerList[playerInfo.seatId])
        end
    end

    if not self:isSelfInGame() then
        local seatId = self:getEmptySeatId()
        if seatId ~= -1 then
            GameManager.ServerManager:sitDown(seatId, GameManager.UserData.money, true)
        else
            self:sitDownFail()
        end
    end
    self.view:updateDatas({jackpot = self.model.tableInfo.totalAnte})
end

function SlotsController:sitDownResponse(data)
    if data.ret ~= 0 then
        self:sitDownFail()
    end
end

function SlotsController:sitDownFail()
    GameManager.TopTipManager:showTopTip(T("获取房间配置失败\n请重新尝试！"))
        Timer.New(function()
            self:exitScene()
        end, 1, 0, true):Start()
end

function SlotsController:standupResponse(data)
    dump(data)
end

function SlotsController:sendSlotBetResponse(data)
    if data.ret == 0 then
        if self.view.betState == SlotsView.BET_TYPE.AUTO_READY then
            self.view:betStateChange(SlotsView.BET_TYPE.AUTOING)
        end
        GameManager.UserData.money = data.userMoney
        self.view:updateDatas()
        if self.bonusCnt > 0 then
            local dontSendBet = true
            self.view:autoSpin(true)
        else
            self.view:start()
        end
    else
        -- 判断破产
        if self.view.betState == SlotsView.BET_TYPE.AUTOING then
            self.view:betStateChange(SlotsView.BET_TYPE.NORMAL)
        end
        self.view:enableSomething()
        
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
                            -- UnityEngine.Application.Quit()
                        end,
                    })   
                end 
            end)
        else

        end
    end
end

function SlotsController:logoutRoomResponse(data)
    
end

function SlotsController:sendRoomMsgResponse(data)
    
end

function SlotsController:syncTableResponse(data)
    
end

function SlotsController:svrSitDownResponse(data)
    if data.uid == GameManager.UserData.mid then
        GameManager.UserData.money = data.userMoney
        self.model.selfSeatId = data.seatId
        self.model.playerList[data.seatId]        = json.decode(data.userInfo)
        self.model.playerList[data.seatId].uid    = data.uid
        self.model.playerList[data.seatId].seatId = data.seatId
        self.view:updateSelfView(json.decode(data.userInfo))
    else
        self.model.playerList[data.seatId]        = json.decode(data.userInfo)
        self.model.playerList[data.seatId].uid    = data.uid
        self.model.playerList[data.seatId].seatId = data.seatId
        self.view:updateOtherPlayer(self.model.playerList)
    end
end

function SlotsController:svrStandUpResponse(data)
    self.view:standUp(self.model.playerList[data.seatId])
end

function SlotsController:svrBroadcastResultResponse(data)
    self.model.playerList[data.seatId].money    = data.userMoney
    self.model.playerList[data.seatId].addMoney = data.addMoney
    if self.model.selfSeatId == data.seatId then
        
        self.bonusCnt = data.bonusCnt

        local results = {}
        for i, card in ipairs(data.cards) do
            local row = (math.floor((i - 1) / SlotsView.COLUMN_COUNT)) + 1
            local column = ((i - 1) % SlotsView.COLUMN_COUNT) + 1
            if row == 1 then
                results[column] = {}
            end
            results[column][row] = {index = card.card}
        end

        local lineGoalsDictArray = {}
        for i, pot in ipairs(data.pots) do
            lineGoalsDictArray[i] = {lineIndex = pot.line, goalCount = pot.count}
        end
        self.view:stopWithResults(results, function()
            GameManager.UserData.money = data.userMoney
            if self.bonusCnt > 0 then
                self.view:betStateChange(SlotsView.BET_TYPE.BOUND)
                self.view:disableSomething()
            elseif self.view.betState == SlotsView.BET_TYPE.BOUND then
                self.view:enableSomething()
                self.view:betStateChange(SlotsView.BET_TYPE.NORMAL)
            elseif self.view.betState == SlotsView.BET_TYPE.NORMAL then
                self.view:enableSomething()
            elseif self.view.betState == SlotsView.BET_TYPE.AUTO_READY then
                self.view:enableSomething()
            end
            self.view:updateDatas({jackpot = data.totalBonus, addMoney = data.addMoney})
            self.view:loopShowLineGoalView(lineGoalsDictArray)

            local autoAction = function()
                if self.view.betState == SlotsView.BET_TYPE.AUTOING then
                    self.view:autoSpin()
                end
            end

            if data.addMoney > 0 then
                local type = InteractiveAnimation.ANIMATION_CONFIG.Winner.Small
                if data.addMoney >= self.view.lineCount * self.view.lineAnteConfig[self.view.lineAnteIndex] then
                    type = InteractiveAnimation.ANIMATION_CONFIG.Winner.Mid
                end
                if data.specialCard ~= -1 then
                    if data.specialCard == 100 then
                        type = InteractiveAnimation.ANIMATION_CONFIG.Winner.Big
                    elseif data.specialCard == 101 then
                        type = InteractiveAnimation.ANIMATION_CONFIG.Winner.Huge
                    elseif data.specialCard == 102 then
                        type = InteractiveAnimation.ANIMATION_CONFIG.Winner.Huge
                        self.view:showJackPotAnimation()
                    end
                end

                self.interactiveAnimation:playWinnerAnimation(type, data.addMoney, function()
                    if self.bonusCnt and self.bonusCnt > 0 then
                        GameManager.TopTipManager:showTopTip(T("获得免费抽奖机会，剩余次数："..self.bonusCnt))
                    end
                    autoAction()
                    self.view:stopJackPotAnimation()
                end)
            else
                autoAction()
            end
        end)
        -- Timer.New(function()
        --     -- 获得2次免费
        --     -- if self.bonusCnt == 0 then
        --     --     self.bonusCnt = self.bonusCnt + 2
        --     -- end
        -- end, SlotsController.RESULT_DELAY_TIME, 0, true):Start()
    else
        self.view:updateSeatMoney(self.model.playerList[data.seatId])
    end
end

function SlotsController:svrKickOutResoponse(data)
    self:exitScene()
end

function SlotsController:commonBroadcastResponse(data)
    local infoData = json.decode(data.info)
    if infoData and infoData.latest_money then
        GameManager.UserData.money = tonumber(infoData.latest_money)
    end
    if infoData and infoData.message then
        GameManager.TopTipManager:showTopTip({msg = infoData.message, type = 1})
    end
    if data.mtype == 1 then
        -- mtype 1.是金币到账的
        -- if self.view_ and self.view_.getRedDogConfig then
        --     self.view_:getRedDogConfig()
        -- end
        -- if infoData.tip_type and infoData.tips then
        --     ninek.InterfaceConfig:getInterface("RewardDialogView").new(infoData.tip_type,infoData.tips,false,2,true):show()
        -- end
    elseif data.mtype == 2 then
        -- mtype 2. 跑马灯信息
    elseif data.mtype == 3 then
        -- mtype 3. 限时礼包购买成功信息
        -- 1 FB邀请 2 破产 3 限时礼包 4 首充
        if self.view_ and self.view_.removeTopIcon then
            -- if self.view_.onTimerEnd then
            --     self.view_:onTimerEnd()
            -- end
            -- ninek.userData["isShowPromotion"] = false
            -- self.view_:removeTopIcon(3, true)
            -- -- 购买之后窗口关闭
            -- if self.view_.limitPayView and self.view_.limitPayView.isShowing then
            --     self.view_.limitPayView:onClose()
            -- end
        end
    elseif data.mtype == 4 then
        -- mtype 4. 首充礼包购买成功信息
        -- if self.view_ and self.view_.removeTopIcon then
        --     self.view_:removeTopIcon(4, true)
        -- end
    end
end

function SlotsController:xxxxxxxxx(data)
    
end

function SlotsController:dealWithLogin(data, isSyncTable)
    
end


--[[
    私有方法
]]

function SlotsController:isSelfInGame()
    -- 判断自己有没有在游戏里面
    for i, player in ipairs(self.model.playerList) do
        if player.uid == GameManager.UserData.mid then
            self.model.selfSeatId = player.seatId
            return true
        end
    end
    return false
end

function SlotsController:getEmptySeatId()
    for seatId = 1, self.model.tableInfo.maxSeatCnt do
        local havePlayer = false
        for i, player in ipairs(self.model.playerList) do
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

--[[
    server 外逻辑代码
]]

function SlotsController:onCleanUp()
    self.scene_:onCleanUp()
    if self.scene_.view.onCleanUp then
        self.scene_.view:onCleanUp()
    end
    self:setServerResponseStop(true)
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end

function SlotsController:exitSceneAnimation(completeCallback)
    if self.scene_.view.exitSceneAnimation then
        self.scene_.view:exitSceneAnimation(function()
            self.scene_:onCleanUp()
            completeCallback()
        end)
    else
        if self.scene_.view.onCleanUp then
            self.scene_.view:onCleanUp()
            self.scene_:onCleanUp()
            completeCallback()
        end
    end
    self:setServerResponseStop(true)
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end


return SlotsController