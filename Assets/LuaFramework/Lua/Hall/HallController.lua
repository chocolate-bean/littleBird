local HallController = class("HallController")
local SP = require("Server.SERVER_PROTOCOL")
-- 视图类型
HallController.FIRST_OPEN      = 0
HallController.LOGIN_GAME_VIEW = 1
HallController.MAIN_HALL_VIEW  = 2
HallController.CHOOSE_NOR_VIEW = 3

HallController.AnimTime = 0.5

function HallController:ctor(scene)
    self.scene_ = scene 
    Event.AddListener(EventNames.HALL_LOGOUT_SUCC,handler(self,self.handleLogoutSucc_))
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
end

function HallController:processUserData(data)

    local GameConfig = {}   
    local userData = {}
    -- 整理用户数据
    -- 我懒得弄了，直接用全局变量userData了
    GameConfig.uid = data['aUser.mid']
    GameConfig.chatRecord = {} --聊天记录
    GameConfig.payTypeList = nil

    -- 配置表用到的地址
    GameConfig.LEVEL_JSON   = data["config_urls.level_config"] --等级配置Json
    GameConfig.PROP_JSONS   = data["config_urls.prop_config"] --道具配置Json
    GameConfig.FISHING_JSON = data["config_urls.fishing_config"] --捕鱼配置Json

    GameConfig.UPLOAD_AVATAR = data["uploadAvatar"]-- 头像上传地址
    GameConfig.FB_PAGE = data.fb_page --FB粉丝页
    GameConfig.GAME_URL = data.game_url --五星好评地址
    GameConfig.SHARE_CONFIG = {
        URL = data["wechat_share.url"],
        TITLE = data["wechat_share.title"],
        CONTENT = data["wechat_share.content"],
    }

    -- 配置地址
    -- userData.UPLOAD_PIC = userData["urls.updateicon"] -- 头像上传地址（暂无）

    -- 姓名
    userData.name = data["aUser.name"]
    -- 性别
    userData.msex = tonumber(data["aUser.msex"])
    -- 头像
    userData.micon = data["aUser.micon"]
    -- 金币
    userData.money = data["aUser.money"]
    -- 经验值
    userData.exp = data["aUser.exp"]
    -- 改名次数
    userData.modify_name = data["aUser.modify_name"]
    -- 胜场
    userData.win = data["aUser.win"]
    -- 负场
    userData.lose = data["aUser.lose"]
    -- UID
    userData.mid = data["aUser.mid"]
    --新的类似Token
    userData.valid_sign = data["aUser.valid_sign"]
    -- 玩家配置的装扮标记
    userData.attire = data["aUser.prop_decoration"]
    -- 玩家是否绑定fb
    userData.isBindFb = data["aUser.isBindFb"]
    -- 用户等级
    userData.mlevel = data["aUser.mlevel"]
    userData.nlevel = data["aUser.nlevel"]

    -- 奖励配置
    userData.login_reward_status = data.login_reward_status
    userData.register_reward_status = data.register_reward_status

    -- 多少局显示引导
    userData.course_num = data.course_num

    -- 红点配置
    userData.redDotData = {}

    -- 支付场景
    userData.pay_scene = nil

    -- 红包数据
    userData.jewel      = data["aUser.jewel"]       -- 当前红包数目
    userData.jewelGain  = data["aUser.jewel_gain"]  -- 当日红包获取数目
    userData.jewelLimit = data["aUser.jewel_limit"] -- 当日红包获取上限
    -- Vip等级
    userData.viplevel = data["aUser.vip_level"]

    -- 炮台样式
    userData.cannonStyle = tonumber(data["aUser.fishing.cannon_style"])

    -- 缓存等级列表和道具列表
    -- 缓存等级
    GameManager.Level = import("Panel.util.LoadLevelControl").new()
    -- GameManager.Level:loadConfig(GameConfig.LEVEL_JSON,function(success,levelData)
    --     if success then
    --         --计算是否可升级
    --         local exp = checkint(data["aUser.exp"])
    --         local level = checkint(data["aUser.mlevel"])          
    --         local maxLevel = GameManager.Level:getLevelByExp(exp);
    --         local dsLevel = maxLevel- level
    --         if (maxLevel > level) and (dsLevel >= 1) then
    --             GameConfig.nextRwdLevel = level + 1
    --         else
    --             GameConfig.nextRwdLevel = 0
    --         end

    --         userData.level = data["aUser.nlevel"]--GameManager.Level:getLevelByExp(tonumber(checkint(data["aUser.exp"])))
    --     end
    -- end)
    
    -- 破产补助的限制和次数
    GameConfig.bankruptcyGrant = {
        allTime  = data["bankrupt_status.total_times"],
        num      = data["bankrupt_status.left_times"],
        deadline = data["bankrupt_status.deadline"],
    }

    -- 捕鱼相关配置
    userData.diamond        = tonumber(data["aUser.diamon"])
    userData.maxCannonLevel = tonumber(data["aUser.fishing.cannon_level"])
    userData.fishingSkillConfig = data["aUser.fishing_skill"]
    GameManager.ChooseRoomManager:getFishingConfigJson(GameConfig.FISHING_JSON)

    GameConfig.login_reward_status = data.login_reward_status
    GameConfig.register_reward_status = data.register_reward_status
    GameConfig.push_activity = tonumber(data.push_activity)

    GameConfig.canCreateRoomCount = data.priLimit or 1

    GameConfig.five_star =  {
        switch = data["five_star.switch"],
        win_money = data["five_star.win_money"],
    }

    GameConfig.casinoWin = data["switch.casinoWin"]
    GameConfig.fishingRoom = data["switch.fishing_room"]
    -- GameConfig.HasDiamond = data["switch.platform_core"] -- 0是没有钻石 1是有钻石
    GameConfig.HasDiamond = 1 -- 0是没有钻石 1是有钻石
    GameConfig.LimitPay = data["switch.snatch"] -- 夺宝活动开关
    GameConfig.isBind = data["aUser.isBind"]

    -- 水果机 和 牛牛的显示开关 1是关 0是开
    GameConfig.closeSlot   = data["switch.closeSlot"]
    GameConfig.closeNiuniu = data["switch.closeNiuniu"]
    GameConfig.closeRedpacket = data["switch.closeRedpacket"]

    -- 敏感功能开关
    GameConfig.SensitiveSwitch = {
        showRedpacket    = data["switch.closeRedpacket"] == 0,      -- 红包相关
        -- showRedpacket    = false,      -- 红包相关
        showLottery      = data["switch.closeWheelLucky"] == 0,     -- 十连抽的 抽奖功能
        showShare        = data["switch.closeShare"] == 0,          -- 带有分享的大转盘
        showShareFriend  = data["switch.closeShareFriend"] == 0,    -- 跳转公众号的分享
        showOneToMillion = data["switch.closeCapticalProfit"] == 0, -- 一本万利
    }

    -- 疯狂捕鱼百人场开关
    GameConfig.closeHundredRoom   = data["switch.closeHundredRoom"]

    -- 麦乐积分网站
    GameConfig.MLJurl = data["mailejifenStore"]

    GameConfig.AFInit = sdkMgr.AFInit
    GameConfig.UmengInit = sdkMgr.UmengInit
    GameConfig.NoticeList = {}

    GameManager.DataProxy:setData(DataKeys.USER_DATA, userData, true)
    GameManager.UserData = GameManager.DataProxy:getData(DataKeys.USER_DATA)
    GameManager.GameConfig = GameConfig

    -- 如果是新用户，会把HAS_AUTOSHOT设置为true，并且HAS_AUTOSHOT_TIME要设置为1800s
    -- 在进入捕鱼场时，会先判断HAS_AUTOSHOT是否为true
    -- 如果是true，将会直接开启自动射击，并展示自动射击的倒计时
    if tonumber( data["isCreate"] )== 1 then
        UnityEngine.PlayerPrefs.SetString(DataKeys.HAS_AUTOSHOT, "True")
        UnityEngine.PlayerPrefs.SetString(DataKeys.FIRST_LOGIN, "True")
        UnityEngine.PlayerPrefs.SetInt(DataKeys.HAS_AUTOSHOT_CURTIME, tonumber(data["aUser.fishing_auto_free"]))
        UnityEngine.PlayerPrefs.SetInt(DataKeys.HAS_AUTOSHOT_TOTALTIME, tonumber(data["aUser.fishing_auto_free"]))
    end
end

-- 登陆成功
function HallController:onLoginSucc_(data)
    
    self:processUserData(data)
    -- 链接server（俊鸿处理）
    GameManager.ServerManager:connect(data.hallip)

    -- TODO 谷歌支付相关
    -- GP包才需要
    -- 未完成的订单重新请求发货
    -- self:paymentAgain()
    
    -- 设置视图
    self.scene_:onLoginSucc()
end

-- 谷歌支付未完成订单的重请求
function HallController:paymentAgain()
    local paymentJson = UnityEngine.PlayerPrefs.GetString(DataKeys.PAYMENT)
    if paymentJson and paymentJson ~= "" then
        local payment = json.decode(paymentJson)
        for k,params in pairs(payment) do
            payment[k].isDone = false
            payment[k].result = false

            local retryTimes = 6
            local allOrderDone 
            local callClientPayment

            allOrderDone = function()
                -- body
                -- 如果还有没返回的订单，等待所有订单完成订
                for k,params in pairs(payment) do
                    if payment[k].isDone == false then
                        return
                    end
                end

                -- 所有订单完成了，清理掉成功的订单，重新保存至本地
                for k,params in pairs(payment) do
                    if payment[k].result then
                        payment[k] = nil
                    end
                end

                if payment == nil or next(payment) == nil then
                    UnityEngine.PlayerPrefs.SetString(DataKeys.PAYMENT,"")
                else
                    local paymentJson = json.encode(payment)
                    UnityEngine.PlayerPrefs.SetString(DataKeys.PAYMENT,paymentJson)
                end
            end
            
            callClientPayment = function()
                -- body
                http.callClientPayment(
                    params,
                    function(callData)
                        if callData and callData.flag == 1 then
                            -- 成功就把当前的删除，失败不用管
                            payment[k].isDone = true
                            payment[k].result = true

                            allOrderDone()
                        else
                            retryTimes = retryTimes - 1
                            if retryTimes > 0 then
                                callClientPayment()
                            else
                                payment[k].isDone = true
                                payment[k].result = false

                                allOrderDone()
                            end
                        end
                    end,
                    function(errData)
                        retryTimes = retryTimes - 1
                        if retryTimes > 0 then
                            callClientPayment()
                        else
                            payment[k].isDone = true
                            payment[k].result = false

                            allOrderDone()
                        end
                    end
                )
            end

            callClientPayment()
        end
    end
end

function HallController:handleLogoutSucc_()
    -- 设置视图
    GameManager.GameFunctions.logout()
    self.scene_:onLogoutSucc()
end

function HallController:setServerResponseStop(isStop)
    self.serverResponseStop_ = isStop
end

function HallController:onServerResponse(cmd, data)
    if self.serverResponseStop_ then
        return
    end

    if not self.responseAction then
        self.responseAction = {
            [SP.CLI_LOGIN]            = self.loginServerResponse,
            [SP.CLISVR_HEART_BEAT]    = self.heartBeatResponse,
            [SP.CLI_GET_ROOM]         = self.getRoomResponse,
            [SP.CLI_LOGIN_ROOM]       = self.loginRoomResponse,
            [SP.SVR_COMMON_BROADCAST] = self.commonBroadcastResponse,
            [SP.TRACE_FRIEND]         = self.traceFriendResponse,
        }
    end
    local action = self.responseAction[cmd]
    if action then
        if data then
            print(string.format("HallController cmd:%#x -> %s",cmd,json.encode(data)))
        else
            -- print(string.format("HallController cmd:%#x -> null",cmd))
        end
        action(self, data)
    else
        print(string.format("HallController 没有找到Action cmd:%#x", cmd))
    end
end

-- 回包处理
function HallController:loginServerResponse(data)
    if data.ret then
        print("Server登录大厅成功..")
        -- 开启心跳
        GameManager.ServerManager:heartBeatStart()
        if data.tid == 0 then
        else
            print("重连桌子"..data.tid)
            self.reloginTableId = data.tid
        end
    else
        print("Server登录大厅失败")
    end
end

function HallController:heartBeatResponse(data)
    -- print("心跳回包")
end

function HallController:getRoomResponse(data)
    local ret = data.ret
    if ret == 0 or not ret then
        if data.tid > 0 then
            print("获取房间成功"..data.tid)
            local gameId = GameManager.GameFunctions.getGameIdFormTableId(data.tid)
            if gameId == CONSTS.GAME_ID.LANDLORDS then
                GameManager:enterScene("RoomScene", {data = data.tid, roomType = CONSTS.ROOM_TYPE.LANDLORDS})
            elseif gameId == CONSTS.GAME_ID.DOUNIU then
                GameManager:enterScene("RoomScene", {data = data.tid, roomType = CONSTS.ROOM_TYPE.DOUNIU})
            else
                GameManager.ServerManager:loginRoom(data.tid)
            end
        else
            GameManager.TopTipManager:showTopTip(T("网络不给力，获取数据失败，请重试")) 
        end
    else
        GameManager.TopTipManager:showTopTip(T("网络不给力，获取数据失败，请重试"))   
    end
end

function HallController:loginRoomResponse(data)
    local ret = data.ret
    print("登录房间成功"..data.ret)
    if ret == 0 or not ret then
        -- 切换Sence时注意清理当前Sence
        local roomType = CONSTS.ROOM_TYPE.NORMAL
        local gameId = GameManager.GameFunctions.getGameIdFormTableId(data.table.tid)
        if gameId == CONSTS.GAME_ID.SLOTS then
            roomType = CONSTS.ROOM_TYPE.SLOTS
        elseif gameId == CONSTS.GAME_ID.LANDLORDS then
            roomType = CONSTS.ROOM_TYPE.LANDLORDS
        elseif gameId == CONSTS.GAME_ID.NIUNIU then
            roomType = CONSTS.ROOM_TYPE.NIUNIU
        elseif gameId == CONSTS.GAME_ID.FISHING then
            roomType = CONSTS.ROOM_TYPE.FISHING
        end
        print("房间的类型 "..roomType)
        if roomType ~= CONSTS.ROOM_TYPE.NORMAL then
            GameManager:enterScene("RoomScene", {data = data, roomType = roomType})
        end
    end
end


function HallController:commonBroadcastResponse(data)
    local infoData = json.decode(data.info)
    if infoData then
        if infoData.latest_money then
            GameManager.UserData.money = tonumber(infoData.latest_money)
        end

        if infoData.vip_level then
            GameManager.UserData.viplevel = tonumber(infoData.vip_level)
        end

        if infoData.latest_jewel then
            GameManager.GameFunctions.setJewel(tonumber(infoData.latest_jewel))
        end

        if infoData.message then
            GameManager.TopTipManager:showTopTip({msg = infoData.message, type = 1})
        end

        if infoData.latest_diamon then
            GameManager.UserData.diamond = tonumber(infoData.latest_diamon)
        end

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
        if self.scene_.view_ and self.scene_.view_.removeTopIcon then
            if self.scene_.view_.onTimerEnd then
                self.scene_.view_:onTimerEnd()
            end
            self.scene_.view_:removeTopIcon(2, true)
        end
        -- -- 购买之后窗口关闭
        if self.scene_.view_.LimitPayPanel and self.scene_.view_.LimitPayPanel.isShowing then
            self.scene_.view_.LimitPayPanel:onClose()
            self.scene_.view_.LimitPayPanel.isShowing = false
        end
    elseif data.mtype == 4 then
        -- mtype 4. 首充礼包购买成功信息
        if self.scene_.view_ and self.scene_.view_.removeTopIcon then
            self.scene_.view_:removeTopIcon(3, true)
        end
        -- -- 购买之后窗口关闭
        if self.scene_.view_.FirstPayPanel and self.scene_.view_.FirstPayPanel.isShowing then
            self.scene_.view_.FirstPayPanel:onClose()
            self.scene_.view_.FirstPayPanel.isShowing = false
        end
    elseif data.mtype == 5 then
        -- mtype 5 破产特惠购买成功
        hide(self.scene_.view_.IconList.iconBroken)
    elseif data.mtype == 10 then
        -- 聊天信息推送
        Event.Brocast(EventNames.CHAT_MESSAGE,data)
    end
end

function HallController:traceFriendResponse(data)
    local uid       = data.uid
    local status    = data.status
    local tid       = data.tid
    local roomLevel = data.roomLevel
    if status == 3 or status == 4 then
       if tid > 0 then
            GameManager.ServerManager:loginRoom(data.tid)
        else
            GameManager.TopTipManager:showTopTip({msg = T("无法追踪好友，请确认好友是否在线并正在进行游戏"),type = 0})
        end 
    else
        GameManager.TopTipManager:showTopTip({msg = T("无法追踪好友，请确认好友是否在线并正在进行游戏"),type = 0})
    end
end

function HallController:exitSceneAnimation(completeCallback)
    if self.scene_.view_ and self.scene_.view_.exitSceneAnimation then
        self.scene_.view_:exitSceneAnimation(completeCallback)
    else
        if self.scene_.view_ and self.scene_.view_.onCleanUp then
            self.scene_.view_:onCleanUp()
        end
    end
    self:setServerResponseStop(true)
    Event.RemoveListener(EventNames.HALL_LOGOUT_SUCC)
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end

function HallController:onReturnKeyClick()
    -- 判断当前是不是 选场
    if self.scene_.view_.isChooseRoom then
        self.scene_.view_:dismissLandlordsChooseRoomView()
    else
        GameManager:exitGame()
    end
end


return HallController