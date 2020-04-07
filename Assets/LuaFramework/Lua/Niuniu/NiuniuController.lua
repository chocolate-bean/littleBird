local NiuniuController = class("NiuniuController")
local SP              = require("Server.SERVER_PROTOCOL")
local InteractiveAnimation = require("Room.InteractiveAnimation")
local QuickChatView        = require("Room.QuickChatView")

function NiuniuController:ctor(scene, data)
    self.scene_ = scene
    self.loginRoomData = data
    self.interactiveAnimation = InteractiveAnimation.new()
    -- 0 下注，1 结算
    self.state = 1

    if GameManager.ChooseRoomManager.niuniuConfig then
        self.config = GameManager.ChooseRoomManager.niuniuConfig
    else
        self.config = {
            tendency = {
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
                {1,1,1,1},
            },
            time_control ={
                action_time = 15,
                show_time = 15,
            },
            log = {
                name = "User Name",
                msex = nil,
                micon = 1,
                win = 123456789.
            },
            defultBtnMoney = {
                [1] = 100000000,
                [2] = 10000000,
                [3] = 1000000,
                [4] = 100000,
            },
        }
    end

    self.areaParams = {}
    for i,data in pairs(self.config.tendency) do
        table.insert(self.areaParams,1,data)
    end
end

function NiuniuController:prefabDidLoad()
    self.view = self.scene_.view
    -- 开始和Server相关的逻辑
    self.quickChatView = QuickChatView.new({type = QuickChatView.Type.Custom})
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
    self:loginRoomResponse(self.loginRoomData)
end

function NiuniuController:exitScene()
    GameManager.ServerManager:logoutRoom()
end

function NiuniuController:onReturnKeyClick()
    self:exitScene()
end

function NiuniuController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function NiuniuController:onServerResponse(cmd, data)
    if self.serverResponseStop_ then
        return
    end

    if not self.responseAction then
        self.responseAction = {
            [SP.CLISVR_HEART_BEAT]      = self.heartBeatResponse,

            [SP.CLI_LOGIN_ROOM]         = self.loginRoomResponse,
            [SP.CLI_SIT_DOWN]           = self.sitDownResponse,
            [SP.CLI_STAND_UP]           = self.standupResponse,
            [SP.CLI_LOGOUT_ROOM]        = self.logoutRoomResponse,
            [SP.CLI_SEND_ROOM_MSG]      = self.sendRoomMsgResponse,
            [SP.CLI_TABLE_SYNC]         = self.syncTableResponse,

            [SP.CLI_SLOT_BET]           = self.getSlotBetResponse,
            [SP.CLI_SEND_GET_VIPSEAT]   = self.getVipSeatResponse,
            [SP.CLI_SEND_GET_USERLIST]  = self.getUserListResponse,
            [SP.CLI_SEND_GET_SLOTLIST]  = self.getSlotListResponse,
            [SP.CLI_SEND_APPLY_BANKER]  = self.applyBankerResponse,
            [SP.CLI_SEND_GET_BANKERLIST]= self.getBankerListResponse,

            [SP.SVR_GAME_START]         = self.svrGameStartResponse,
            [SP.SVR_SIT_DOWN]           = self.svrSitDownResponse,
            [SP.SVN_AUTO_ADD_MIN_CHIPS] = self.xxxxxxxxx,
            [SP.SVR_OTHER_STAND_UP]     = self.svrStandUpResponse,
            [SP.SVR_BROADCAST_RESULT]   = self.svrBroadcastResultResponse,
            [SP.SVR_KICK_OUT]           = self.svrKickOutResoponse,
            [SP.SVR_COMMON_BROADCAST]   = self.commonBroadcastResponse,
            
            [SP.SVR_BC_USER_BETON]      = self.onUserBetonResponse,
            [SP.SVR_BC_NIUNIU_RESULT]   = self.onNiuniuResultResponse,
            [SP.SVR_BC_VIPSEAT_INFO]    = self.onVipSeatInfoResponse,
            [SP.SVR_BC_BANKER_INFO]     = self.changeBankerResponse,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        if data then
            print(string.format("NiuniuController cmd:%#x -> %s",cmd, json.encode(data)))
        else
            -- print(string.format("NiuniuController cmd:%#x -> null",cmd))
        end
        action(self, data)
    else
        print(string.format("NiuniuController 没有找到Action cmd:%#x", cmd))
    end
end

--[[
    server
]]
    
function NiuniuController:heartBeatResponse(data)
end

function NiuniuController:svrGameStartResponse(data)
    self.view:onGameStart(self.config.time_control.action_time)
    self.state = 0
end

function NiuniuController:loginRoomResponse(data)
    GameManager.ServerManager:sitDown(0, GameManager.UserData.money, true)

    if data.table.tableStatus == 3 then
        self.view:onGameStart(data.table.leftTime or self.config.time_control.action_time)
        self.state = 0
    else
        self.view:SetStateType(3, data.table.leftTime)
        self.state = 1
    end
 
    self.view:UpdateSeatView(data.playerList)
    self.bankerMID = data.table.bankUserId
    self.view:refashBankerInfo(data.table.bankUserId)
    self.view.RewardText:GetComponent('Text').text = string.formatNumberThousands(data.table.totalAnte)
    self.view.curTotalBonus = data.table.totalAnte
    self.config.totalBonus = data.table.totalAnte
end

function NiuniuController:sitDownResponse(data)
    if data.ret ~= 0 then
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = false,
            hasCloseButton = false,
            title = T("提示"),
            text = T("金币不足"),
            firstButtonCallbcak = function()
                self:onReturnKeyClick()
            end,
        })
    end
end

function NiuniuController:changeBankerResponse(data)
    self.bankerMID = data.uid
    self.view:refashBankerInfo(data.uid)
end

-- 牛牛下注
function NiuniuController:getSlotBetResponse(data)
    if data.ret == 0 then
        GameManager.UserData.money = data.userMoney
        self.view:playSelfChipAnim(data.lines + 1, data.chips)
        self.view:refashPlayerMoney()
    elseif data.ret == 110 then
        GameManager.TopTipManager:showTopTip(T("庄家金币不足"))
    else
        if self.state == 1 then
            
        else
            GameManager.TopTipManager:showTopTip(T("金币不足，请更换下注金额"))
        end
    end
end

--牛牛请求vip座位
function NiuniuController:getVipSeatResponse(data)
    if data.ret ~= 0 then
    else
    end
end

--牛牛请求玩家列表
function NiuniuController:getUserListResponse(data)
    local NiuniuPlayerListPanel = import("Panel.Special.NiuniuPlayerListPanel").new(data.playerList)
end

--牛牛请求注池信息
function NiuniuController:getSlotListResponse(data)
    self.view:UpdateSlotListInfo(data)
end

--牛牛获取庄家列表
function NiuniuController:getBankerListResponse(data)
    if self.NiuniuBankerListPanel and self.NiuniuBankerListPanel.isShowing then
        self.NiuniuBankerListPanel:refashBankerList(data.playerList)
    else
        self.NiuniuBankerListPanel = import("Panel.Special.NiuniuBankerListPanel").new(data.playerList,function()
            
            if self.NiuniuBankerListPanel then
                self.NiuniuBankerListPanel.isShowing = false
                self.NiuniuBankerListPanel = nil
            end
        end)
    
        self.NiuniuBankerListPanel.isShowing = true
    end
end

--牛牛请求上庄
function NiuniuController:applyBankerResponse(data)
    if data.ret ~= 0 then
        if data.ret == 109 then
            GameManager.TopTipManager:showTopTip(T("金币不足上庄失败"))
        end
    else
        GameManager.TopTipManager:showTopTip(T("上庄成功，您已经在队列中"))
        GameManager.ServerManager:getBankerList()
    end
end

function NiuniuController:standupResponse(data)

end

function NiuniuController:logoutRoomResponse(data)
    if data.ret ~= 0 then
        GameManager.TopTipManager:showTopTip(T("本轮结算后将自动离开"))
        -- if GameManager.UserData.mid == self.bankerMID then
        --     GameManager.TopTipManager:showTopTip("本轮结算后将自动离开")
        -- else
        --     GameManager.TopTipManager:showTopTip("本轮结算后将自动离开")
        -- end
    else
        self:QuitServer()
        self.view:onCleanUp()
        GameManager:enterScene("HallScene", 2)
    end
end

function NiuniuController:sendRoomMsgResponse(data)
    local mtype = data.mtype
    local info = json.decode(data.info)
    local uid = tonumber(data.uid)

    info.mtype = mtype

    if mtype == 1 then
        -- 聊天
        local message = info.message -- 发送的消息

        self.view:playChatAnmi(uid,message)
    elseif mtype == 2 then
        -- 用户换头像
    elseif mtype == 3 then
        -- 赠送礼物
    elseif mtype == 4 then
        -- 设置礼物
    elseif mtype == 5 then
        --发送表情
        local faceId = info.faceId
        local fType = info.fType

        self.view:PlayEmojiAnmi(uid,faceId,fType)
    elseif mtype == 6 then
        --互动道具
        local tarMid = info.toSeatIds -- 目标mid
        local fromMid = uid           -- 发送的mid
        local index = info.index
        local count = info.count or 1

        self.view:playHDDJAnmi(count, index, fromMid, tarMid)
    elseif mtype == 7 then
        --给荷官赠送筹码
    elseif mtype == 8 then
        --老虎机大奖广播
    elseif mtype == 9 then
        --广播加好友动画
    end
end

function NiuniuController:syncTableResponse(data)
    
end

function NiuniuController:svrSitDownResponse(data)

end

function NiuniuController:svrStandUpResponse(data)
    
end

function NiuniuController:svrBroadcastResultResponse(data)
    
end

function NiuniuController:svrKickOutResoponse(data)
    self:QuitServer()
    self.view:onCleanUp()
    GameManager:enterScene("HallScene", 2)
end

function NiuniuController:commonBroadcastResponse(data)
    local infoData = json.decode(data.info)
    if infoData and infoData.latest_money then
        GameManager.UserData.money = tonumber(infoData.latest_money)
    end
    if infoData and infoData.message then
        GameManager.TopTipManager:showTopTip({msg = infoData.message, type = 1})
    end
end

function NiuniuController:xxxxxxxxx(data)
    
end

function NiuniuController:dealWithLogin(data, isSyncTable)
    
end

-- 广播下注（NIUNIU
-- 六个座位的玩家
function NiuniuController:onUserBetonResponse(data)
    self.view:onUserBetonResponse(data)
end

-- 广播结算（NIUNIU
function NiuniuController:onNiuniuResultResponse(data)
    self.view:OnBalance(data)
    self.state = 1
end

-- 广播公共座位信息（NIUNIU
-- 换人了
function NiuniuController:onVipSeatInfoResponse(data)
    self.view:UpdateSeatView(data.playerList)
end

--[[
    server 外逻辑代码
]]

function NiuniuController:showTrendPanel()
    if self.NiuniuTrendPanel then
        return
    end

    self.NiuniuTrendPanel = import("Panel.Special.NiuniuTrendPanel").new(self.areaParams,function()
        
        if self.NiuniuTrendPanel then
            self.NiuniuTrendPanel.isShowing = false
            self.NiuniuTrendPanel = nil
        end
    end)

    self.NiuniuTrendPanel.isShowing = true
end

function NiuniuController:showChatView()
    self.quickChatView:show()
end

function NiuniuController:refashTrend(areaParams)
    
    if #self.areaParams == 9 then
        table.remove(self.areaParams,1)
        table.insert(self.areaParams,areaParams)
    else
        table.insert(self.areaParams,areaParams)
    end

    if self.NiuniuTrendPanel and self.NiuniuTrendPanel.isShowing then
        self.NiuniuTrendPanel:refashTrend(self.areaParams)
    end
end

function NiuniuController:QuitServer()
    
    self:setServerResponseStop(true)
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end

function NiuniuController:onCleanUp()
    print("NiuniuController:onCleanUp")
    self.scene_:onCleanUp()
end

return NiuniuController