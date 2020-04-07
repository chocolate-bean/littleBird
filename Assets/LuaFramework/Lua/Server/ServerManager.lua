local PROTOCOL = require("Server.SERVER_PROTOCOL")
local PacketBuilder = require("Server.PacketBuilder")
local PacketParser = require("Server.PacketParser")
local ServerManager = class("ServerManager")

function ServerManager:ctor()
    self:initProtobufFile("client")
    self.isConnected = false
    self.hallipList = nil
end

function ServerManager:initProtobufFile(file)
    local path = Util.DataPath.."lua/3rd/pbc/"..file..".pb"
    print(path)
    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)
end

function ServerManager:send(buffer)
    NetFramework.SendMessage(buffer)
end

function ServerManager:receiveCallBack(receiveValue)
    local pack = PacketParser.new(receiveValue)
    local cmd,ret = pack:read()

    -- 直接分发出去给所有监听者 让他们在里面自己做处理
    if cmd and ret then
        Event.Brocast(EventNames.SERVER_RESPONSE,cmd,ret)
    end
end

function ServerManager:connect(hallipList)
    self.hallipList = hallipList
    if not self.isConnected then --若断开了
        local address, port = string.match(hallipList[1], "([%d%.]+):(%d+)")  
        print("ServerManeger:connect >>>>>>>>>>>>>>>>>>>> ip and port ", address, port)
        self:sendConnect(address, port)
    else
        self:loginGame()
    end
end

function ServerManager:brokenConnect()
    
    print("断开和server的链接")
    NetFramework.BrokenConnect()
end

function ServerManager:sendConnect(address, port)
    NetFramework.Connect(address, port)
end

function ServerManager:onConnect()
    self.isConnected = true
    self:loginGame()
end

function ServerManager:networkErrorCallBack()
    -- 准备重新登录
    GameManager.TopTipManager:showTopTip(T("网络已经重新连接"))
    self.isConnected = false
    if self.hallipList then
        self:connect(self.hallipList)
    end
end

--[[
    游戏逻辑开始
]]
function ServerManager:loginGame()
    local uid = GameManager.GameConfig.uid
    local pack = PacketBuilder.new(PROTOCOL.CLI_LOGIN)
            :setParameter("uid", uid)
            :setParameter("uuid", GetUUID())
            :setParameter("did", 0)
            :setParameter("clientVer", 1000)
            :setParameter("userLevel", GameManager.UserData.mlevel)
            :setParameter("userMoney", GameManager.UserData.money)
            :build()
    self:send(pack)
end

function ServerManager:heartBeat()
    local pack = PacketBuilder.new(PROTOCOL.CLISVR_HEART_BEAT):build()
    self:send(pack)
end

function ServerManager:heartBeatStart()
    local loopTime = 5
    if self.heartBeatTimer then
        self.heartBeatTimer:Start()
    else
        self.heartBeatTimer = Timer.New(function()
            self:heartBeat()
        end, loopTime, -1, true)
        self.heartBeatTimer:Start()
    end
end

function ServerManager:heartBeatStop()
    if self.heartBeatTimer then
        self.heartBeatTimer:Stop()
        self.heartBeatTimer = nil
    end
end

function ServerManager:getRoomAndLogin(roomLevel, tid)
    
    --判断用户金币能不能进游戏
    local config = GameManager.ChooseRoomManager:getRoomConfigByLevel(roomLevel)
    if GameManager.UserData.money > config.max_limit_money then
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("你的筹码太多了, 不能坐下来。"),
            firstButtonCallbcak = function()
                -- UnityEngine.Application.Quit()
            end,
        })
        return
    end
    
    if GameManager.UserData.money < config.min_money then
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("您的金币不足当前房间的最小携带，请前往免费金币看看。"),
            firstButtonCallbcak = function()
                -- UnityEngine.Application.Quit()
            end,
        })
        return
    end

    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", tid)
            :build()
    self:send(pack)
end

function ServerManager:loginRoom(tid)
    local pack = PacketBuilder.new(PROTOCOL.CLI_LOGIN_ROOM)
            :setParameter("uid", GameManager.UserData.mid)
            :setParameter("tid", tid)
            :setParameter("did", 0)
            :setParameter("clientVer", 1000)
            :setParameter("mtkey", GameManager.UserData.valid_sign)
            :setParameter("username", GameManager.UserData.name)
            :setParameter("baseInfo", json.encode(GameManager.GameFunctions.getUserInfo()))
            :build()
    self:send(pack)
end

function ServerManager:changeRoomAndLogin(roomLevel,userLevel,userMoney,tid)
    local pack = PacketBuilder.new(PROTOCOL.CLI_CHANGE_ROOM)
        :setParameter("roomLevel", roomLevel)
        :setParameter("userLevel", userLevel) 
        :setParameter("userMoney", userMoney) 
        :setParameter("tid", tid) 
        :build()
    self:send(pack)
end

function ServerManager:traceFriend(uid)
    local pack = PacketBuilder.new(PROTOCOL.TRACE_FRIEND)
       :setParameter("uid", uid)
       :build()
   self:send(pack)
end

function ServerManager:requestCountOfTable()
    local pack = PacketBuilder.new(PROTOCOL.CLI_REQUEST_COUNT_OF_TABLE) 
        :build()
    self:send(pack)
end

function ServerManager:sitDown(seatId, bet, autoBuyin, param)
    if autoBuyin then
        autoBuyin = 1
    else
        autoBuyin = 0
    end
    if not param then
        param = 1
    end
    -- print("请求坐下"..seatId)
    local pack = PacketBuilder.new(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :setParameter("ante", bet)
        :setParameter("autoBuyin", autoBuyin)
        :setParameter("param", param)
        :build()
    self:send(pack)   
end

 --普通房间站起
 function ServerManager:standUp()
    local pack = PacketBuilder.new(PROTOCOL.CLI_STAND_UP)      
        :build()
    self:send(pack)   
end

--type 1是表情，2是互動道具
function ServerManager:sendRoomCostProp(money,type,id,targetSeatId,count)
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_ROOM_COST_PROP)
        :setParameter("money",money)
        :setParameter("type",type)
        :setParameter("id",id)
        :setParameter("seatId",targetSeatId)
        :setParameter("count",count)
        :build()
    self:send(pack)
end

function ServerManager:logoutRoom()
    local pack = PacketBuilder.new(PROTOCOL.CLI_LOGOUT_ROOM):build()
    self:send(pack) 
end

function ServerManager:dropCards(cards)
    local cardsProtocal = {}
    for i,v in ipairs(cards) do
        cardsProtocal[i] = {}
        cardsProtocal[i].card = v
    end
    local pack = PacketBuilder.new(PROTOCOL.CLI_DROP_CARDS)
        :setParameter("cards", cardsProtocal)   
        :build()
    self:send(pack) 
end

function ServerManager:setBet(type,bet,cards)
    --[[ 
        三公 --> 1.看牌 2.弃牌 3.跟注 4.加注
        博定 --> 1.下注 2.要牌 3.比牌
        地主 --> 1.叫地 2.抢地 3.出牌 4.过 5.托管
        双十 --> 1.抢庄 2.下倍 3.亮牌 ]]
    local cardsProtocal = {}
    cards = cards or {}
    for i,v in ipairs(cards) do
        cardsProtocal[i] = {}
        cardsProtocal[i].card = v
    end
    bet = bet or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_SET_BET)
        :setParameter("operate", type) 
        :setParameter("ante", bet)      
        :setParameter("cards", cardsProtocal)      
        :build()
    self:send(pack)   
end

function ServerManager:userEnterBackground()
    local pack = PacketBuilder.new(PROTOCOL.CLI_USER_IN_BACKGROUND):build()
    self:send(pack) 
end

function ServerManager:tableSYNC()
    local pack = PacketBuilder.new(PROTOCOL.CLI_TABLE_SYNC):build()
    self:send(pack) 
end

function ServerManager:sendTipToGirl(money)
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_TIP_TO_GIRL)
        :setParameter("money", money):build()
    self:send(pack)
end

function ServerManager:sendRoomToBroadcastMsg_(type, jsonString)
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_ROOM_MSG)
        :setParameter("mtype", type)
        :setParameter("info", jsonString)
        :setParameter("uid", GameManager.UserData.mid)
        :build()
    self:send(pack)
end

function ServerManager:sendRoomChat(message, toName)
    local info = {}
    info.message = message
    info.name = GameManager.UserData.name
    info.header = GameManager.UserData.mavatar
    info.uid = GameManager.UserData.mid
    info.sex = tonumber(GameManager.UserData.msex)
    self:sendRoomToBroadcastMsg_(1 ,json.encode(info))
end

function ServerManager:sendExpression(fType, faceId, toName)
    local info = {}
    info.fType = fType
    info.faceId = faceId
    info.name = GameManager.UserData.name
    info.toName = toName or ""
    self:sendRoomToBroadcastMsg_(5, json.encode(info))
end

function ServerManager:sendProp(index, toSeatIds, count)
    local info = {}
    info.index     = index --客户端道具标示
    info.toSeatIds = toSeatIds
    info.count     = count
    self:sendRoomToBroadcastMsg_(6, json.encode(info))
end

function ServerManager:sendDealerChip(fee, num)
    local info = {}
    info.fee = fee
    info.num = num
    self:sendRoomToBroadcastMsg_(7, json.encode(info))
end

function ServerManager:sendSyncOther()
    local info = {}
    info.jewel = GameManager.UserData.jewel
    info.diamond = GameManager.UserData.diamond
    info.money = GameManager.UserData.money
    self:sendRoomToBroadcastMsg_(8, json.encode(info))
end

--[[
    水果机相关
]]

function ServerManager:getSoltsRoomAndLogin()
    local roomLevel = GameManager.ChooseRoomManager.slotsConfig.room.level
    local tid = 0
    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", 0)
            :build()
    self:send(pack)
end

function ServerManager:soltsBet(lines, chips, isUseProps)
    local pack = PacketBuilder.new(PROTOCOL.CLI_SLOT_BET)
            :setParameter("lines", lines)
            :setParameter("chips", chips)
            :setParameter("isUseProps", isUseProps)
            :build()
    self:send(pack)
end

--[[
    斗地主相关
]]

function ServerManager:getLandlordsRoomAndLogin(roomLevel)
    local roomConfig = GameManager.ChooseRoomManager:getLandlordsRoomConfigByMoney()
    local roomLevel = roomLevel or roomConfig.level
    local tid = 0
    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", 0)
            :build()
    self:send(pack)
end

function ServerManager:getHint()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_REQ_HINT)
            :build()
    self:send(pack)   
end

function ServerManager:sendReady()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_USER_READY)
            :build()
    self:send(pack)  
end

--[[
    牛牛相关
]]
function ServerManager:getNiuniuRoomAndLogin()
    local roomLevel = GameManager.ChooseRoomManager.niuniuConfig.room.level
    local tid = 0
    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", 0)
            :build()
    self:send(pack)
end

function ServerManager:getNiuniuVipSeat()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_GET_VIPSEAT)
            :build()
    self:send(pack)        
end

function ServerManager:getNiuniuUserList()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_GET_USERLIST)
            :build()
    self:send(pack)        
end

function ServerManager:getNiuniuSlotList()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_GET_SLOTLIST)
            :build()
    self:send(pack)        
end

function ServerManager:applyBanker()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_APPLY_BANKER)
            :build()
    self:send(pack)
end

function ServerManager:getBankerList()
    local pack = PacketBuilder.new(PROTOCOL.CLI_SEND_GET_BANKERLIST)
            :build()
    self:send(pack)
end

--[[
    斗牛相关
]]

function ServerManager:getDouniuRoomAndLogin(roomLevel)
    local roomConfig = {} --GameManager.ChooseRoomManager:getLandlordsRoomConfigByMoney()
    local roomLevel = roomLevel or roomConfig.level
    local tid = 0
    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", 0)
            :build()
    self:send(pack)
end

--[[
    捕鱼相关
]]

function ServerManager:getFishingRoomAndLogin(roomLevel)
    local roomList = GameManager.ChooseRoomManager.fishingRoomConfig
    local roomConfig
    if roomLevel == nil then
        for index, config in ipairs(roomList) do
            if config.redpack_ground == 1 then
                roomConfig = config
                break
            end
        end
    end
    local roomLevel = roomLevel or roomConfig.level
    local tid = 0
    local userLevel = GameManager.UserData.mlevel or 0
    local userMoney = GameManager.UserData.money or 0
    local pack = PacketBuilder.new(PROTOCOL.CLI_GET_ROOM)
            :setParameter("roomLevel", roomLevel)
            :setParameter("userLevel", userLevel)
            :setParameter("userMoney", userMoney)
            :setParameter("tid", 0)
            :build()
    self:send(pack)
end

return ServerManager