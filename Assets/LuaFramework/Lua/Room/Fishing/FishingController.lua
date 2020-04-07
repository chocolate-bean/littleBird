local FishingController  = class("FishingController")
local FishingModel       = require("Room.Fishing.FishingModel")
local QuickChatView      = require("Room.QuickChatView")
local SP                 = require("Server.SERVER_PROTOCOL")
local PanelDialog        = require("Panel.Dialog.PanelDialog")
local PanelNiudaoxiaoshi = require("Panel.FishingGame.PanelNiudaoxiaoshi")

function FishingController:ctor(scene, data)
    self.scene_ = scene
    self.model = FishingModel.new()
    if type(data) == "table" then
        self.loginRoomData = data
    else
        local tid = data
        self.loginRoomTid = tid
    end
end

function FishingController:prefabDidLoad()
    self.view = self.scene_.view
    -- self.quickChatView = QuickChatView.new({type = QuickChatView.Type.Default})
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
    
    if self.loginRoomData then
        self:loginRoomResponse(self.loginRoomData)
    elseif self.loginRoomTid then
        GameManager.ServerManager:loginRoom(self.loginRoomTid)
    end
end

function FishingController:exitScene()
    function logoutRoom()
        GameManager.ServerManager:logoutRoom()
    end

    if self.model.kickOutSelf then
        GameManager:enterScene("HallScene", 2)
    end
    
    logoutRoom()
    -- 统计FPS
    -- if FishingGameControl.Instance.deltaTime >= FishingGameControl.Instance.fpsTime then
    --     local deviceModel = UnityEngine.SystemInfo.deviceModel
    --     local fps = FishingGameControl.Instance.fpsCount / FishingGameControl.Instance.deltaTime
    --     local quality = UnityEngine.PlayerPrefs.GetInt(DataKeys.FISH_QUALITY)
    --     http.cliendTraceLog(
    --         deviceModel,
    --         fps,
    --         quality,
    --         function(callData)
    --         end,
    --         function (callData)
    --         end
    --     )
    -- end
end

function FishingController:onReturnKeyClick()
    -- self:exitScene()
    self.view:onClose()
end

function FishingController:onCleanUp()
    self.scene_:onCleanUp()
    if self.view.onCleanUp then
        self.view:onCleanUp()
    end
    self:setServerResponseStop(true)
    -- self.quickChatView:removeServerListener()
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end


function FishingController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function FishingController:onServerResponse(cmd, data)
    if self.serverResponseStop_ then
        return
    end

    if not self.responseAction then
        self.responseAction = {
            [SP.CLISVR_HEART_BEAT] = self.heartBeatResponse,

            [SP.CLI_LOGIN_ROOM]       = self.loginRoomResponse,
            [SP.CLI_LOGOUT_ROOM]      = self.logoutRoomResponse,
            [SP.CLI_SET_BET]          = self.setBetResponse,
            [SP.CLI_SEND_FISHING_MSG] = self.sendFishingResponse,
            [SP.CLI_SEND_ROOM_MSG]    = self.sendRoomMsgResponse,
            [SP.CLI_TABLE_SYNC]       = self.tableSyncResponse,

            [SP.SVR_KICK_OUT]         = self.svrKickOutResoponse,
            [SP.SVR_SIT_DOWN]         = self.svrSitDownResponse,
            [SP.SVR_OTHER_STAND_UP]   = self.svrStandUpResponse,
            [SP.SVR_BC_CREATE_FISH]   = self.svrCreateFishResponse,
            [SP.CLI_SEND_SHOOTING]    = self.svrSendShootingResponse,
            [SP.SVR_COMMON_BROADCAST] = self.commonBroadcastResponse,
            [SP.SVR_BET]              = self.svrBetResponse,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        action(self, data)
    else
        print(string.format("FishingController 没有找到Action cmd:%#x", cmd))
    end
end


--[[
    自己坐下的方法
]]
function FishingController:readySitDown()
    self.view:seatSitDown(self.model.selfData)
    self:installCannon(self.model.selfData.seatId, self.model.selfData.cannonLevel, self.model.selfData.cannonStyle)
    self.view:seatCannonChanged(self.model.selfData)
    if self.model:isRedpacketRoom() then
        self.view:updateRedpacketProgress(true)
    else
        self.view:updateNormalRoomProgress()
    end
    
    self:setMySeat(self.model.selfData.seatId)
    for index, player in pairs(self.model.playerList) do
        if player.uid ~= GameManager.UserData.mid then
            self.view:seatSitDown(player)
            self:installCannon(player.seatId, player.cannonLevel, player.cannonStyle)
            self.view:seatCannonChanged(player)
        end
    end

    -- 有可能自己的数据
    if self.model:isCannonMulSwitchOpen() then
        -- 更新倍数选择数据
        self.view:updateChooseMenuData()
    end
end

--[[
    server
]]
    
function FishingController:heartBeatResponse(data)
    -- print("斗牛内心跳")
end

function FishingController:loginRoomResponse(data)
    -- 判断自己的位置 然后需不需要翻转

    -- 传递数据给C#
    -- 其所需要的数据 路线 炮样式 鱼样式
    -- http 请求开始
    self:getFishingSkill()
    self:getFirstPayShow()
    self:getNuclearBombNumber()
    self:getNiudaoxiaoshiConfig()

    -- self.model.needChangeRoom or self.model
    self.model.fishConfig = clone(GameManager.ChooseRoomManager.fishingConfig)

    if GameManager.ChooseRoomManager.fishingMoneyRoomConfig then
        for index, config in ipairs(GameManager.ChooseRoomManager.fishingMoneyRoomConfig) do
            if config.level == data.table.level then
                self.model.roomConfig = config
                break
            end
        end
    end
    if GameManager.ChooseRoomManager.fishingRoomConfig then
        for index, config in ipairs(GameManager.ChooseRoomManager.fishingRoomConfig) do
            if config.level == data.table.level then
                self.model.roomConfig = config                
                dump(config.redpack_mission)
                break
            end
        end
    end
    self.model.fishConfig.room = self.model.roomConfig

    -- 这里的roomConfig 要区分场次在做删减
    local allowCannons = {}
    for index, cannonConfig in ipairs(self.model.fishConfig.cannon[self.model.defaultCannonStyle].list) do
        for jndex, allowCannon in ipairs(self.model.roomConfig.cannon) do
            if cannonConfig.level == tonumber(allowCannon) then
                allowCannons[#allowCannons + 1] = cannonConfig
            end
        end
    end
    self.model.fishConfig.cannon[self.model.defaultCannonStyle].list = allowCannons

    self.model:loginRoom(data)
    -- 初始化房间界面
    self.view:showPropsView()
    self.view:updateCannonUpgradeInfo()
    
    Timer.New(function()
        self:setFishConfig()
        local csharpData = protobuf.encode("nkclient.SendTableInfo", data)
        FishingGameControl.Instance:LoginRoomResponse(csharpData)
        -- 先判断自己有没有在位置上
        if self.model.roomConfig.ice_vip_limit then
            self:setBulletIsIce(GameManager.UserData.viplevel >= tonumber(self.model.roomConfig.ice_vip_limit))
        else
            self:setBulletIsIce(false)
        end
        if self.model.selfData then
            self:readySitDown()
        else
            local cannonLevel = GameManager.ChooseRoomManager:getCannonLevel()
            if self.model:isRedpacketRoom() then
                cannonLevel = self.model.fishConfig.cannon[self.model.defaultCannonStyle].list[1].level
            else
                if cannonLevel > GameManager.UserData.maxCannonLevel then
                    cannonLevel = GameManager.UserData.maxCannonLevel
                    GameManager.ChooseRoomManager:setCannonLevel(cannonLevel)
                end
            end
            GameManager.ServerManager:sitDown(self.model:getEmptySeatId(), GameManager.UserData.money, true, cannonLevel)
        end
        -- 然后判断哪些人是开了急速的
        for i, player in pairs(self.model.playerList) do
            if player.userStatus == CONSTS.FISHING.USER_STATE.SPINT then
                -- 这些人是开了急速的
                if player.uid == GameManager.UserData.mid then
                    self:usePrivilegeAutoSprintSkill(true)
                else
                    self.view:seatShowSprintEffect(player.seatId, 1)
                end
            end
        end
        -- 第一次登录红包场准备弹出说明规则弹窗
        if self.model:isRedpacketRoom() then
            local firstPlayFishing = UnityEngine.PlayerPrefs.GetInt(DataKeys.FISHING_FIRST_PLAY)
            if firstPlayFishing == nil or firstPlayFishing == 0 then
                self.view:onRedpacketInfoButtonClick()
                UnityEngine.PlayerPrefs.SetInt(DataKeys.FISHING_FIRST_PLAY, 1)
            end
        end
        -- 是否第一次登陆捕鱼
        if UnityEngine.PlayerPrefs.GetString(DataKeys.FIRST_LOGIN) == "True" then
            if self.model:isRedpacketRoom() then
                self.view:showGuide(true)
            else
                self.view:showGuide(false)
            end
        end
    end, 0.1, 1, true):Start()
end

function FishingController:logoutRoomResponse(data)
    GameManager:enterScene("HallScene", 2)
end

function FishingController:svrSitDownResponse(data)
    local currentPlayer = self.model:someoneSitDown(data)
    if currentPlayer.uid == GameManager.UserData.mid then
        self:readySitDown()
    else
        self.view:seatSitDown(currentPlayer)
        self:installCannon(currentPlayer.seatId, currentPlayer.cannonLevel, currentPlayer.cannonStyle)
        self.view:seatCannonChanged(currentPlayer)
    end
end

function FishingController:svrStandUpResponse(data)
    local currentPlayer = self.model:someoneStandUp(data)
    self:hideCannon(currentPlayer.seatId)
    self.view:seatStandUp(currentPlayer)
end

function FishingController:setBetResponse(data)
    if data.ret == 0 then
        if data.operate == CONSTS.FISHING.ACTION_TYPE.PROPS then
            local propIndex
            for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
                if config.id == data.opera_data then
                    propIndex = index
                    break
                end
            end
            if GameManager.UserData.fishingSkillConfig[propIndex].num ~= 0 then
                GameManager.UserData.fishingSkillConfig[propIndex].num = GameManager.UserData.fishingSkillConfig[propIndex].num - 1
            end
            self.view:updataPropsView()
        end
    else
        GameManager.TopTipManager:showTopTip(T("道具不足！"))
    end
end

function FishingController:svrKickOutResoponse(data)
    GameManager:enterScene("HallScene", 2)
end

function FishingController:svrCreateFishResponse(data)
    -- 如果现在有 boss鱼出来了 那么就准备播放动画
    local fishList = data.fishList
    if data.sort == 1 then
        -- 鱼潮时会短暂的没有鱼，需要播放动画并且关闭自动瞄准
        self.view:showFishTideComingAnimation()
        self:usePrivilegeAimSkill(false)
    end

    for index, fishInfo in ipairs(fishList) do
        if fishInfo.fishType == 301 or fishInfo.fishType == 302 or fishInfo.fishType == 401 then
            self.view:showBossComingAnimation(fishInfo.fishType, self.model:getFishMultipleWithFishType(fishInfo.fishType))
        end
    end
end

function FishingController:tableSyncResponse(data)
    self.model:loginRoom(data)
    self:readySitDown()
end

function FishingController:sendRoomMsgResponse(data)
    local mtype = data.mtype
    local info = json.decode(data.info)
    local uid = tonumber(data.uid)

    local fromPlayer = self.model:getPlayerByUid(uid)
    info.mtype = mtype
    info.fromPlayer = fromPlayer
    
    if mtype == 1 then
        --聊天消息
    elseif mtype == 2 then
        -- 用户换头像
    elseif mtype == 3 then
        -- 赠送礼物
    elseif mtype == 4 then
        -- 设置礼物
    elseif mtype == 5 then
        --发送表情
    elseif mtype == 6 then
        --互动道具info.toSeatIds
    elseif mtype == 7 then
        --给荷官赠送筹码
    elseif mtype == 8 then
        -- 钻石更新或者红包数量更新等等
        fromPlayer.jewel = info.jewel
        fromPlayer.diamond = info.diamond
        fromPlayer.money = info.money
        self.view:updateUserInfo(fromPlayer)
    elseif mtype == 9 then
        --广播加好友动画
    end
end

--[[
    发射子弹
]]
function FishingController:svrSendShootingResponse(data)
    if data.ret == 0 then
        local currentPlayer = self.model:shooting(data)
        self.view:updateUserInfo(currentPlayer)
        if currentPlayer.uid == GameManager.UserData.mid then
            if self.model:isRedpacketRoom() then
                self.view:updateRedpacketProgress()
            else
                self.view:updateNormalRoomProgress()
            end
        end
    elseif data.ret == 108 then
        GameManager.TopTipManager:showTopTip(T("您的金币不足"))
        self:usePrivilegeAimSkill(false)
        self:usePrivilegeAutoShootSkill(false)
        -- 这里判断当前用户的金币  和  当前场次的最低炮倍数进行比较
        local currentMoney = GameManager.UserData.money
        local minCannonMoney = self.model:cannonLevelToCannonMultipleWithValue(self.model.selfData.cannonLevel)
        
        if minCannonMoney > currentMoney then
            self:getNiudaoxiaoshiConfig(function()
                local callback = function()
                    local PanelDuihuan = require("Panel.Operation.PanelDuihuan").new()
                end
                
                if self.model.niudaoxiaoshiConfig and self.model.niudaoxiaoshiConfig.open == 1 then
                    if self.niudaoxiaoshiPanel and self.niudaoxiaoshiPanel.view and self.niudaoxiaoshiPanel.view.activeSelf then
                        self.niudaoxiaoshiPanel:onClose()
                        return
                    end
                    self.niudaoxiaoshiPanel = PanelNiudaoxiaoshi.new(self.model.niudaoxiaoshiConfig, callback)
                elseif self.view:isFirstPayShow() then
                    self.view:onOperationButtonClick(2, callback)
                else
                    self.view:onOperationButtonClick(1, callback)            
                end
            end)
        end
    end
end

--[[
    捕获到鱼了
]]
function FishingController:sendFishingResponse(data)
    local curentPlayer = self.model:fishing(data)
    self.view:updateUserInfo(curentPlayer)
    if self.model:isRedpacketRoom() then
    else
        self.view:updateNormalRoomProgress()
        self.view:updataPropsView()
    end
    --[[
        如果捕获的鱼是 红包鱼
    ]]
    if curentPlayer.uid == GameManager.UserData.mid then
        for index, fishInfo in ipairs(data.killList) do
            if fishInfo.fishType == 204 or fishInfo.fishType % 1000 == 204 then
                local showString = nil
                for index, propInfo in ipairs(fishInfo.propInfo) do
                    if propInfo.propId == 3 then -- 3是红包
                        showString = GameManager.GameFunctions.getJewelWithUnit(propInfo.propCount)
                    end
                end
                if showString ~= nil then
                    GameManager.TopTipManager:showTopTip(string.format(T("恭喜你捕获%s红包（获得的红包倍数＝红包数量×炮台倍率÷100）"), showString))
                end
                -- local showCount = self.model.fishConfig
            end
        end
    end
end

function FishingController:svrBetResponse(data)
    local currentPlayer = self.model:operate(data)
    if currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.CANNON then
        -- 说明在切换炮台
        self:switchCannon(currentPlayer.seatId, currentPlayer.curAnte, currentPlayer.cannonStyle)
        self.view:seatCannonChanged(currentPlayer)

        -- 如果切换炮台的人是我
        if currentPlayer.uid == GameManager.UserData.mid then
            GameManager.ChooseRoomManager:setCannonLevel(self.model.selfData.cannonLevel)
            if self.model:isRedpacketRoom() then
                self.view:updateRedpacketProgress(true)
            end
        end
    elseif currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.PROPS then
        if currentPlayer.propType ~= CONSTS.PROPS.FISHING_SKILL_SPRINT then
            -- 可以点击状态
            -- self.view:enableSkillButtons(true)
            self.view:seatShowEffect(currentPlayer.seatId, currentPlayer.countDownTime, currentPlayer.propType)
            -- 如果使用道具的是我
            if currentPlayer.uid == GameManager.UserData.mid then
                -- 使用的是什么道具 准备道具的倒计时
                self.view:showPropProgress(currentPlayer.propType, currentPlayer.countDownTime)
            end
        end
    elseif currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.SPRINT then
        self.view:seatShowSprintEffect(currentPlayer.seatId, currentPlayer.curAnte == 1)
    elseif currentPlayer.operate == CONSTS.FISHING.ACTION_TYPE.MUL then
        self.view:updateSeatCannonMul(currentPlayer.seatId, currentPlayer.multiple)
    end
end

function FishingController:commonBroadcastResponse(data)
    local infoData = json.decode(data.info)
    if infoData then
        if infoData.latest_money then
            GameManager.UserData.money = tonumber(infoData.latest_money)
            GameManager.ServerManager:sendSyncOther()
        end

        if infoData.vip_level then
            GameManager.UserData.viplevel = tonumber(infoData.vip_level)
        end

        if infoData.latest_jewel then
            GameManager.GameFunctions.setJewel(tonumber(infoData.latest_jewel))
            GameManager.ServerManager:sendSyncOther()
        end

        if infoData.message then
            GameManager.TopTipManager:showTopTip({msg = infoData.message, type = 1})
        end

        if infoData.latest_diamon then
            GameManager.UserData.diamond = tonumber(infoData.latest_diamon)
            GameManager.ServerManager:sendSyncOther()
        end

        -- 房间内同步炮台样式，需要重新进入捕鱼场方可生效
        if infoData.cannon_style then
            GameManager.UserData.cannonStyle = tonumber(infoData.cannon_style)
        end

        if infoData.props then
            local propIndex
            for index, prop in ipairs(infoData.props) do
                for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
                    if config.id == prop.id then
                        propIndex = index
                        break
                    end
                end
                if GameManager.UserData.fishingSkillConfig[propIndex] then
                    GameManager.UserData.fishingSkillConfig[propIndex].num = prop.num
                end
                self.view:updataPropsView()
            end
        end
    end
    
    if data.mtype == 1 then
        -- mtype 1.是金币到账的
        GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),infoData.rtype,infoData.desc,"")
    elseif data.mtype == 2 then
        -- mtype 2. 跑马灯信息
    elseif data.mtype == 3 then
        -- mtype 3. 限时礼包购买成功信息
        -- if self.scene_.view_ and self.scene_.view_.removeTopIcon then
        --     if self.scene_.view_.onTimerEnd then
        --         self.scene_.view_:onTimerEnd()
        --     end
        --     self.scene_.view_:removeTopIcon(2, true)
        -- end
        -- -- 购买之后窗口关闭
        -- if self.scene_.view_.LimitPayPanel and self.scene_.view_.LimitPayPanel.isShowing then
        --     self.scene_.view_.LimitPayPanel:onClose()
        --     self.scene_.view_.LimitPayPanel.isShowing = false
        -- end
    elseif data.mtype == 4 then
        -- mtype 4. 首充礼包购买成功信息
        -- if self.scene_.view_ and self.scene_.view_.removeTopIcon then
        --     self.scene_.view_:removeTopIcon(3, true)
        -- end
        -- -- 购买之后窗口关闭
        -- if self.scene_.view_.FirstPayPanel and self.scene_.view_.FirstPayPanel.isShowing then
        --     self.scene_.view_.FirstPayPanel:onClose()
        --     self.scene_.view_.FirstPayPanel.isShowing = false
        -- end
    elseif data.mtype == 5 then
        -- mtype 5 破产特惠购买成功
        -- hide(self.scene_.view_.IconList.iconBroken)
    elseif data.mtype == 10 then
        -- 聊天信息推送
        -- Event.Brocast(EventNames.CHAT_MESSAGE,data)
    end
end

--[[
    调用c#
    注意事项：
        lua的seatId都是以1开始的
        c# 的seatId都是以0开始的
        每次调用都需要+1, -1
]]

function FishingController:setMySeat(seatId)
    FishingGameControl.Instance:setMyInfo(seatId - 1, GameManager.UserData.mid, self.model.selfData.cannonLevel)
end

function FishingController:switchCannon(seatId, cannonLevel, style)
    FishingGameControl.Instance:switchCannon(seatId - 1, cannonLevel, style)
end

function FishingController:installCannon(seatId, cannonLevel, style)
    FishingGameControl.Instance:installCannon(seatId - 1, cannonLevel, style)
end

function FishingController:setFishConfig()
    local configJson = json.encode(self.model.fishConfig)
    FishingGameControl.Instance:setFishConfig(configJson)
end

function FishingController:setBulletIsIce(value)
    FishingGameControl.Instance:setBulletIsIce(value)
end

function FishingController:hideCannon(seatId)
    FishingGameControl.Instance:hideCannon(seatId - 1)
end

function FishingController:enableAimSkill(isEnable)
    FishingGameControl.Instance:enableAimSkill(isEnable)
end

function FishingController:enableAutoShootSkill(isEnable)
    FishingGameControl.Instance:enableAutoShootSkill(isEnable)
end

function FishingController:enableAutoSprintSkill(isEnable)
    FishingGameControl.Instance:enableAutoSprintSkill(isEnable)
end

function FishingController:playGoldAnimationByPosition(position, count, line, seatId)
    FishingGameControl.Instance:playGoldAnimationByPosition(position, count, line, seatId - 1);
end

function FishingController:playAnyItemAnimationByPosition(position, itemType, seatId)
    FishingGameControl.Instance:playAnyItemAnimationByPosition(position, itemType, seatId - 1);
end

-- 获取鱼潮状态
function FishingController:getFishTideState()
    return FishingGameControl.Instance:getFishTideState()
end

--[[
    C# 调用
]]

function FishingController:playSound(type, param)
    if type == "FIRE" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/fire")
    elseif type == "OPEN_WEB" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/open_web")
    elseif type == "DROP_DIAMOND" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/drop_diamond")
    elseif type == "DROP_GOLD" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/drop_gold")
    elseif type == "GET_GOLD" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/get_gold")
    elseif type == "ICE" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/ice")
    elseif type == "SPRINT" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/sprint")
    elseif type == "FISH_SAY" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/fish/"..param)
    elseif type == "FISH_WHEEl" then
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/fish_wheel")
    end
end

function FishingController:onApplicationFocus(focus)
    if focus then
        -- 如果进入到前台了 走断线重连
        GameManager.ServerManager:tableSYNC()
    else
        -- 如果进入到后台 走home键点击
        GameManager.ServerManager:userEnterBackground()
    end
end

--[[
    view 回调回来
]]
function FishingController:viewOnAddButtonClcik()
    local addLevel
    local list = self.model.fishConfig.cannon[self.model.defaultCannonStyle].list

    for index, config in ipairs(list) do
        if self.model.selfData.cannonLevel == tonumber(config.level) then
            if index == #list then
                addLevel = tonumber(list[1].level)
            else
                addLevel = tonumber(list[index + 1].level)
                if not self.model:isRedpacketRoom() and addLevel > GameManager.UserData.maxCannonLevel and GameManager.GameConfig.HasDiamond == 1 then
                    addLevel = tonumber(list[1].level)
                    if addLevel == self.model.selfData.cannonLevel then
                        return
                    end
                end
            end
            break
        end
    end
    GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.CANNON, addLevel)
end

function FishingController:viewOnSubButtonClick()
    local subLevel
    local list = self.model.fishConfig.cannon[self.model.defaultCannonStyle].list

    for index, config in ipairs(list) do
        if self.model.selfData.cannonLevel == tonumber(config.level) then
            if index == 1 then
                subLevel = tonumber(list[#list].level)
                if not self.model:isRedpacketRoom() and subLevel > GameManager.UserData.maxCannonLevel  and GameManager.GameConfig.HasDiamond == 1 then
                    subLevel = GameManager.UserData.maxCannonLevel
                    if subLevel == self.model.selfData.cannonLevel then
                        return
                    end
                end
            else
                subLevel = tonumber(list[index - 1].level)
            end
            break
        end
    end
    GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.CANNON, subLevel)
end

function FishingController:viewOnMulChooseItemClick(index)
    local config = self.model.roomConfig.cannon_mul[index]
    if config.vip > GameManager.UserData.viplevel then
        GameManager.TopTipManager:showTopTip(string.format(T("VIP %s 方可解锁"), config.vip))
    else
        GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.MUL, config.mul)
    end
end

function FishingController:usedProp(type)

    local propConfig
    for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
        if config.id == type then
            propConfig = config
            break
        end
    end

    -- 1 金币 2 人民币 3 红包 4 钻石
    if propConfig.pmode == 1 then
        if propConfig.num <= 0 then
            -- 准备购买提示
            if propConfig.price > GameManager.UserData.money then
                GameManager.TopTipManager:showTopTip(T("金币数量不足, 无法购买"))
            else
                PanelDialog.new({
                    hasFristButton = true,
                    hasSecondButton = true,
                    hasCloseButton = false,
                    title = T("确认购买"),
                    text = string.format(T("是否要花费%s金币购买道具并使用？"), formatFiveNumber(propConfig.price)),
                    firstButtonCallbcak = function()
                        self:buyFishingSkill(type, function(isSuccess)
                            if isSuccess then
                                GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)                
                            else
                                -- 回复可以点击状态
                            end
                        end)
                    end,
                })
            end
        else
            GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)
        end
    elseif propConfig.pmode == 2 then
        -- 人民币支付回唤起支付，这里是不被支持的
    elseif propConfig.pmode == 3 then
        if propConfig.num <= 0 then
            -- 准备购买提示
            if propConfig.price > GameManager.UserData.money then
                GameManager.TopTipManager:showTopTip(T("红包数量不足, 无法购买"))
            else
                PanelDialog.new({
                    hasFristButton = true,
                    hasSecondButton = true,
                    hasCloseButton = false,
                    title = T("确认购买"),
                    text = string.format(T("是否要花费%s元红包购买道具并使用？"), GameManager.GameFunctions.getJewel(propConfig.price)),
                    firstButtonCallbcak = function()
                        self:buyFishingSkill(type, function(isSuccess)
                            if isSuccess then
                                GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)                
                            else
                                -- 回复可以点击状态
                            end
                        end)
                    end,
                })
            end
        else
            GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)
        end
    elseif propConfig.pmode == 4 then
        if propConfig.num <= 0 then
            -- 准备购买提示
            if propConfig.price > GameManager.UserData.diamond then
                GameManager.TopTipManager:showTopTip(T("钻石数量不足, 无法购买"))
            else
                PanelDialog.new({
                    hasFristButton = true,
                    hasSecondButton = true,
                    hasCloseButton = false,
                    title = T("确认购买"),
                    text = string.format(T("是否要花费%s钻石购买道具并使用？"), propConfig.price),
                    firstButtonCallbcak = function()
                        self:buyFishingSkill(type, function(isSuccess)
                            if isSuccess then
                                GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)                
                            else
                                -- 回复可以点击状态
                            end
                        end)
                    end,
                })
            end
        else
            GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.PROPS, type)
        end
    end
end

function FishingController:usePrivilegeAimSkill(isEnable)
    if isEnable == nil then
        local limitVip = self.model.roomConfig.aim_privilege_vip
        if limitVip > GameManager.UserData.viplevel then
            GameManager.TopTipManager:showTopTip(string.format(T("自动瞄准需要VIP%d方可解锁"), limitVip))
            return
        end
    end

    if self.isAim == nil then
        self.isAim = false
    end

    self.isAim = not self.isAim
    if isEnable ~= nil then
        self.isAim = isEnable
    end
    self.view:showAimEffect(self.isAim)
    self:enableAimSkill(self.isAim)
end

-- 判断是否有剩余自动射击
function FishingController:getAutoShootEnable()
    return UnityEngine.PlayerPrefs.GetString(DataKeys.HAS_AUTOSHOT) == "True" and UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_CURTIME) > 0
end

-- 将是否有自动设计设置为没有
function FishingController:setAutoShootEnd()
    UnityEngine.PlayerPrefs.SetString(DataKeys.HAS_AUTOSHOT, "False")
    UnityEngine.PlayerPrefs.SetInt(DataKeys.HAS_AUTOSHOT_CURTIME, -1)
end

-- 检测自动射击是否达到vip等级，如果达到了，直接关闭倒计时功能
function FishingController:isVipAutoShoot()
    local limitVip = self.model.roomConfig.auto_privilege_vip
    local hasVip = limitVip > GameManager.UserData.viplevel

    if hasVip == false then
        self:setAutoShootEnd()
    end
end

function FishingController:usePrivilegeAutoShootSkill(isEnable)
    local hasTime = self:getAutoShootEnable()
    local limitVip = self.model.roomConfig.auto_privilege_vip
    local hasVip = limitVip > GameManager.UserData.viplevel

    if isEnable == nil then
        -- 需要同时判断vip等级以及是否还有新人时间
        if hasVip and hasTime == false then
            GameManager.TopTipManager:showTopTip(string.format(T("自动射击需要VIP%d方可解锁"), limitVip))
            return
        end
    end
    
    if self.isAutoShoot == nil then
        self.isAutoShoot = false
    end

    self.isAutoShoot = not self.isAutoShoot
    if isEnable ~= nil then
        self.isAutoShoot = isEnable
    end
    
    -- 如果有剩余时间
    -- 那么要刷新倒计时
    if hasTime then
        -- 设置倒计时显示 
        self.view:showAutoShootProgress(self.isAutoShoot)
    end
    self.view:showAutoShootEffect(self.isAutoShoot)
    self:enableAutoShootSkill(self.isAutoShoot)
end

function FishingController:usePrivilegeAutoSprintSkill(isEnable)
    if isEnable == nil then
        local limitVip = tonumber(self.model.roomConfig.supper_speed_vip)
        if limitVip > GameManager.UserData.viplevel then
            GameManager.TopTipManager:showTopTip(string.format(T("自动瞄准需要VIP%d方可解锁"), limitVip))
            return
        end
    end

    if self.isAutoSprint == nil then
        self.isAutoSprint = false
    end

    self.isAutoSprint = not self.isAutoSprint
    if isEnable ~= nil then
        self.isAutoSprint = isEnable
    end

    self.view:showAutoSprintEffect(self.isAutoSprint)
    self:enableAutoSprintSkill(self.isAutoSprint)
    -- 通知其他人 我开启了急速
    if self.isAutoSprint then
        GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.SPRINT, 1)
    else
        GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.SPRINT, 0)
    end
end

function FishingController:onUpgradeCannonClick(isShow)
    
    if isShow ~= nil then
        -- 仅仅是展示
        if self.isCannonUpgradeOpen and isShow == self.isCannonUpgradeOpen then
            -- 如果当前是展开的 那么就不管
            return
        end
        self.isCannonUpgradeOpen = isShow
        self.view:showCannonUpgradeView(self.isCannonUpgradeOpen)
        return
    end

    -- 如果点开了 没有达到那么就收
    if self.isCannonUpgradeOpen == nil then
        self.isCannonUpgradeOpen = false
    end
    self.isCannonUpgradeOpen = not self.isCannonUpgradeOpen

    local nextConfig = self.model:getNextCannonConfig()
    if nextConfig then
        -- 这里取反了 所以要 not
        if not self.isCannonUpgradeOpen and nextConfig.upgrade_diamon <= GameManager.UserData.diamond then
            -- 去升级炮台
            self:upgradeCannon()
            return
        end
    end
    self.view:showCannonUpgradeView(self.isCannonUpgradeOpen)
end

--[[
    http 请求
]]

function FishingController:getFirstPayShow()
    http.getPromotionFirstBag(
        function(callData)
            if callData and callData.flag == 1 then
                for i = 1, 3 do
                    if callData.data.list and callData.data.list[i].status == 1 then
                        self.view:showFirstPayButton()
                    end
                end
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取相关配置失败！"))
        end
    )
end

function FishingController:upgradeCannon()

    -- 获取当前钻石的数量以及下一级炮台的配置

    local nextConfig = self.model:getNextCannonConfig()

    if not nextConfig then
        GameManager.TopTipManager:showTopTip(T("当前已经达到最大级别"))
        return
    end

    if GameManager.UserData.diamond < nextConfig.upgrade_diamon then
        GameManager.TopTipManager:showTopTip(T("钻石数不足"))
        return
    end


    http.upgradeCannon(
        function(retData)
            if retData.flag == 1 then
                GameManager.UserData.diamond        = tonumber(retData.latest_diamon)
                GameManager.UserData.maxCannonLevel = tonumber(retData.cannon_level)
                GameManager.ServerManager:sendSyncOther()
                GameManager.ServerManager:setBet(CONSTS.FISHING.ACTION_TYPE.CANNON, GameManager.UserData.maxCannonLevel)
                -- 播放金币动画 和提示
                for index, reward in ipairs(retData.reward_list) do
                    GameManager.TopTipManager:showTopTip(T(string.format("炮台升级成功！恭喜获得%s%s", reward.num, reward.name)))
                    if reward.id == CONSTS.PROPS.GOLD then
                        self:playGoldAnimationByPosition(self.view:getCannonButtonPosition(), reward.row, reward.col, self.model.selfData.seatId)
                    else
                        for i=1,reward.num do
                            self:playAnyItemAnimationByPosition(self.view:getCannonButtonPosition(), reward.id, self.model.selfData.seatId)
                        end
                        if reward.id == CONSTS.PROPS.FISHING_SKILL_SPRINT 
                        or reward.id == CONSTS.PROPS.FISHING_SKILL_FROZE then
                            local propIndex
                            for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
                                if config.id == reward.id then
                                    propIndex = index
                                    break
                                end
                            end
                            if GameManager.UserData.fishingSkillConfig[propIndex] then
                                GameManager.UserData.fishingSkillConfig[propIndex].num = GameManager.UserData.fishingSkillConfig[propIndex].num + reward.num
                            end
                            self.view:updataPropsView()
                        end
                    end
                end
            elseif retData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("钻石数不足"))
            else
                GameManager.TopTipManager:showTopTip(T("升级炮台失败"))
            end
            self.view:updateCannonUpgradeInfo()
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("升级炮台失败"))
            self.view:updateCannonUpgradeInfo()
        end
    )
end

function FishingController:getFishingSkill()
    http.getFishingSkill(
        function(retData)
            if retData.flag == 1 then
                GameManager.UserData.fishingSkillConfig = retData.list
                self.view:updataPropsView()
            else
                GameManager.TopTipManager:showTopTip(T("获取技能数目失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取技能数目失败"))
        end
    )
end

function FishingController:buyFishingSkill(propType, callback)
    http.buyFishingSkill(
        propType,
        function(retData)
            if retData.flag == 1 then
                GameManager.UserData.diamond = retData.latest_diamon
                GameManager.UserData.money = retData.latest_money
                GameManager.GameFunctions.setJewel(tonumber(retData.latest_jewel))

                self.model.selfData.diamond = retData.latest_diamon
                self.model.selfData.money = retData.latest_money
                self.model.selfData.jewel = GameManager.GameFunctions.getJewel(tonumber(retData.latest_jewel))

                GameManager.ServerManager:sendSyncOther()
                callback(true)
            else
                GameManager.TopTipManager:showTopTip(T("购买技能失败"))
                callback(false)
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("购买技能失败"))
            callback(false)
        end
    )
end

function FishingController:getFishingRedpackReward(missionID)
    local PanelFishHongbao = require("Panel.FishingGame.PanelFishHongbao").new(missionID,function(retData)
        GameManager.GameFunctions.setJewel(retData.latest_jewel)
        self.model.roomConfig.redpack_mission = retData.config
        self.model.selfData.jewel = GameManager.UserData.jewel
        self.model.selfData.consume = 0
        self.view:updateRedpacketProgress(true, true)
        self.view:refreshSelfPlayerInfo()
        GameManager.ServerManager:sendSyncOther()
    end)
end

function FishingController:getNuclearBombNumber()
    http.getFishingBomb(
        function(callData)
            if callData and callData.flag == 1 then
                self.model.nuclearBombConfig = callData.list
            end
            self.view:updataNuclearBombInfo()
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取鱼雷数据失败！"))
        end
    )
end

function FishingController:useNuclearBomb(index)
    local data = self.model.nuclearBombConfig[index]
    http.splitProp(
        data.pid,
        1,
        function(callData)
            if callData and callData.flag == 1 then
                self.model.nuclearBombConfig[index].num = self.model.nuclearBombConfig[index].num - 1
                self.view:updataNuclearBombInfo()
                self.view:playNuclearBombAnimation(function()
                    GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                    GameManager.UserData.money = callData.latest_money
                    GameManager.ServerManager:sendSyncOther()
                end)
            end
        end,
        function(callData)
        end
    )
end

function FishingController:getNiudaoxiaoshiConfig(callback)
    http.showNiudaoxiaoshi(
        function(callData)
            if callData then
                dump(callData)
                self.model:setNiudaoxiaoshi(callData)
                if callback then
                    callback()
                end
            end
        end,
        function(callData)
            dump(callData)
        end
    )
end

return FishingController