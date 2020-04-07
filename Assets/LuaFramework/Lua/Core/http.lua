local HttpRequest = {}
local http = require("Core/HttpService")

local shJoins = nil
shJoins = function(data,isSig)
    local str = "[";
    local key = {};
    local sig = 0;

    if data == nil then
        str = str .. "]";
        return str;
    end

    for i,v in pairs(data) do
        table.insert(key,i);
    end
    table.sort(key);
    for k=1,table.maxn(key) do
        sig = isSig;
        local b = key[k];
        if sig ~= 1 and string.sub(b,1,4) == "sig_" then
            sig = 1;
        end
        local obj = data[b];
        local oType = type(obj);
        local s = "";
        if sig == 1 and oType ~= "table" then
            str = string.format("%s&%s=%s",str.."",b,obj);
        end
        if oType == "table" then
            str = string.format("%s%s=%s",str.."",b,shJoins(obj,sig));
        end
    end
    str = str .. "]";
    return str;
end

-- 多维数组转一维数组
local toOneDimensionalTable = nil
toOneDimensionalTable = function(table, prefix, root)
    if prefix == nil then
        prefix = ""
        root = table
    end
    for k,v in pairs(clone(table)) do               
        local rootkey = k
        if prefix ~= "" then
            rootkey = prefix.."."..k
        end

        if type(v) == "table" then
            if #v == 0 then --是kv数组
                toOneDimensionalTable(v, rootkey, root)
                if prefix == "" then
                    root[k] = nil
                end
            else
                root[rootkey] = v
            end
        else
            if prefix ~= "" then
                root[rootkey] = v
            end
        end
    end  

end

-- 类型批量转换
function typeFilter(table, types)
    for func,keys in pairs(types) do
        for _,key in ipairs(keys) do
            if table[key] ~= nil then
                table[key] = func(table[key])
            end
        end
    end
end

function HttpRequest.init()
    http.clearDefaultParameters()
end

function HttpRequest.setLoginType_(loginType)
    local lid = 0
    if loginType == "FACEBOOK" then
        lid = 1
    elseif loginType == "GUEST" then
        lid = 2
    elseif loginType == "PHONE" then
        lid = 3
    elseif loginType == "WX" then
        lid = 4
    elseif loginType == "WX_CODE" then
        lid = 4
    elseif loginType == "OPPO" then
        lid = 5
    else
        print("login Type [%s] is wrong")
    end
    http.setDefaultParameter("lid", lid)
    return lid
end

function HttpRequest.setSessionKey(key)
    http.setDefaultParameter("sesskey", key)  
end

-- 登陆请求
-- 独立于其它请求
function HttpRequest.login(loginType,access_token,phone,password,resultCallback, errorCallback)
   
    local getImeiCallback = function(imei)
        print("uuid -------> "..IdentityManager.UUID)
        print("imei/oaid -------> "..imei)
        print("storeid -------> "..IdentityManager.StoreID)
        print("idfa------>"..IdentityManager.IDFA)
        print("sid------->"..IdentityManager.Sid)
        


        local params = {
            uuid        = IdentityManager.UUID,                                   --移动终端UUID
            imei        = imei,                                                   -- IMEI
            idfa        = IdentityManager.IDFA,                                   -- IDFA
            storeid     = IdentityManager.StoreID,
            apkVer      = BM_UPDATE.CURVERSION,                                   --游戏版本号，如"4.0.1",            "4.2.1"
            sdkVer      = UnityEngine.SystemInfo.operatingSystem,                 --移动终端设备操作系统， 例如 "android_4.2.1"， "ios_4.1"
            net         = tonumber(UnityEngine.Application.internetReachability), --移动终端联网接入方式，例如 "wifi(1)",   "2G(2)", "3G(3)", "4G(4)", "离线(-1)"。
            machineType = UnityEngine.SystemInfo.deviceModel,                     --移动终端设备机型.如："iphone 4s TD", "mi 2S", "IPAD mini 2"
            pixel       = string.format("%d*%d", Screen.width, Screen.height),    --移动终端设备屏幕尺寸大小，如“1024*700”
            sid         = IdentityManager.Sid,
            registTime  = os.time(),
            server      = AppConst.ServerId,
        }
    
        local lid = 0
        local sid = IdentityManager.Sid
        local gid = 0
    
        if loginType == "PHONE" then
            params.phone = phone
            params.password = password
            lid = 3
        elseif loginType == "WX" then
            params.access_token = access_token
            lid = 4
        elseif loginType == "WX_CODE" then
            params.code = access_token
            lid = 4
        elseif loginType == "FACEBOOK" then
            params.access_token = access_token
            lid = 1
        elseif loginType == "GUEST" then
            lid = 2
        elseif loginType == "OPPO" then
            lid = 5
            params.ssoid = phone
            params.access_token = access_token
        elseif loginType == "VIVO" then
            lid = 7
            params.access_token = access_token
            params.openId = phone
        end
    
        gid = 7
    
        local jsonParams = json.encode(params)
    
        http.POST_URL(
            BM_UPDATE.LOGIN_URL,
            {
                game_param = jsonParams, 
                sig = crypto.md5(shJoins(params,0)), 
                lid = lid, 
                sid = sid, 
                gid = gid
            },
            function(data)
                print(data)
                local retData = json.decode(data)
                if type(retData) == "table" and retData.code and retData.code == 1 then    
                    toOneDimensionalTable(retData.data)                
                    typeFilter(retData.data, {
                        [tostring] = {
                            'aUser.mavatar', 
                            'aUser.memail', 
                            'aUser.sitemid', 
                            'aUser.valid_sign'
                        },
                        [tonumber] = {
                            'aUser.lid', 
                            'aUser.mid', 
                            'aUser.mlevel', 
                            'aUser.mltime', 
                            'aUser.win', 
                            'aUser.lose',
                            'aUser.money', 
                            'aUser.sitmoney', 
                            'aUser.jewel',
                            'isCreate', 
                            'loginInterval' , 
                            'isFirst', 
                            'mid', 
                            'aUser.exp',
                            'ADCLoginOn',
                            'ADCLeaveOn',
                            'DropActivity',
                            'hallShowNewSign',
                            'newerStatis',
                        }
                    })
    
                    retData.data.uid = retData.data.mid
                    HttpRequest.setSessionKey(retData.data.sesskey)
                    http.setDefaultURL(retData.data.gateway)
    
                    if resultCallback then
                        resultCallback(retData.data) 
                    end
                else
                    if not retData then
                        if errorCallback then
                            errorCallback({errorCode = 1}) 
                         end
                    else
                        if errorCallback then
                            errorCallback({errorCode = retData.code, data=retData.data, errorMsg = retData.codemsg})
                        end
                    end
                end
            end,
            function()
                print("登陆请求失败")
                errorCallback()
            end
        )
    end
  
    --兼容Android10 拿取 oaid
    if isAndorid() and string.getAndroidAPI(UnityEngine.SystemInfo.operatingSystem) >= 29 then
        print("拿的是oaid------>")
        getImeiCallback(IdentityManager.OAID)
    else
        getImeiCallback(IdentityManager.IMEI)
        print("拿的是imei------>"..UnityEngine.PlayerPrefs.GetString(DataKeys.IMEI))
    end
end

-- 普通请求
-- 自动附带参数
function HttpRequest.request_post(method, param, resultCallback, errorCallback)
    param = param or {}

    return http.POST(
        {
            method = method, 
            game_param = json.encode(param), 
            sig = crypto.md5(shJoins(param,0)), 
            lid = 2, 
            sid = IdentityManager.Sid, 
            gid = 1, 
            mid = GameManager.UserData.mid, 
            sign = GameManager.UserData.valid_sign,
            server = AppConst.ServerId,
        },
        function(data)
            dump(data, "HttpRequest response........")
            local retData = json.decode(data)
            if type(retData) == "table" and retData.code and retData.code == 1 then
                if retData.data then
                    if resultCallback then
                        resultCallback(retData.data,retData.codemsg)
                    end    
                end
            else
                if not retData then
                    if errorCallback then
                        errorCallback({errorCode = 1})
                    end
                else
                    if errorCallback then
                        errorCallback({errorCode = retData.code,retData = retData})
                    end
                end
            end
        end, errorCallback
    )
end


-- 拉取商品列表
function HttpRequest.getProduct(resultCallback, errorCallback)
    return HttpRequest.request_post("Payment.getProduct",{},resultCallback, errorCallback)
end

-- 获取好友列表
function HttpRequest.getAllFriendList(resultCallback, errorCallback)
    return HttpRequest.request_post("Friend.getAllFriendList",{},resultCallback, errorCallback)
end

-- 搜索好友
function HttpRequest.searchUser(smid, resultCallback, errorCallback)
    return HttpRequest.request_post("Friend.searchUser",{smid = smid},resultCallback, errorCallback)
end

-- 添加好友
function HttpRequest.applyFriend(fmid, resultCallback, errorCallback)
    return HttpRequest.request_post("Friend.applyFriend",{fmid = fmid},resultCallback, errorCallback)
end

-- 删除好友
function HttpRequest.deleteFriend(fmid, resultCallback, errorCallback)
    return HttpRequest.request_post("Friend.deleteFriend",{fmid = fmid},resultCallback, errorCallback)
end

-- 赠送及邀请
function HttpRequest.sendFriendSpecial(fmid, is_all, special, resultCallback, errorCallback)
    return HttpRequest.request_post("Friend.sendFriendSpecial",{fmid = fmid, is_all = is_all, special = special},resultCallback, errorCallback)
end

-- 拉取活动中心配置
function HttpRequest.activityWindow(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.activityWindow",{},resultCallback, errorCallback)
end

-- 拉取排行数据
function HttpRequest.getRank(type,resultCallback, errorCallback)
    return HttpRequest.request_post("Ranking.getRank",{type = type},resultCallback, errorCallback)
end

-- 获取消息列表
function HttpRequest.getMessageList(tab, resultCallback, errorCallback)
    return HttpRequest.request_post("Message.getMessageList",{tab = tab},resultCallback, errorCallback)
end

-- 消息处理
function HttpRequest.handleOneMessage(id, action_type, resultCallback, errorCallback)
    return HttpRequest.request_post("Message.handleOneMessage",{id = id, action_type = action_type},resultCallback, errorCallback)
end

-- 拉取道具装扮配置
--[[
    1=>"装扮(时间类;)",
    2=>"互动道具(次数类;唯一商品)",
    3=>"老虎机免费抽奖卡(次数类;唯一商品)",
    4=>"广播喇叭(次数类;唯一商品)",
    5=>"记牌器(时间类;唯一商品)",
    6=>"改名卡(时间类;唯一商品)",
]]
function HttpRequest.getUserProp(prop_type,resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.getUserProp",{prop_type = prop_type},resultCallback, errorCallback)
end

-- 拉取玩家信息
function HttpRequest.getUserData(uid, prop, friend, resultCallback, errorCallback)
    return HttpRequest.request_post("Member.getUserData",{uid = uid, prop = prop, friend = friend},resultCallback, errorCallback)
end

-- 查询多人玩家信息
function HttpRequest.getMulUserData(uids, resultCallback, errorCallback)
    return HttpRequest.request_post("Member.getMulUserData",{ uids = uids },resultCallback, errorCallback)
end

-- 佩戴卸下装扮
function HttpRequest.decorateProp(pid,undecorate,resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.decorateProp",{pid = pid,undecorate = undecorate},resultCallback, errorCallback)
end

-- 购买装扮
function HttpRequest.AttirebuyProp(mid,pid,to_mid,resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.buyProp",{mid = mid, pid = pid, to_mid = to_mid},resultCallback, errorCallback)
end

-- 获取房间列表
function HttpRequest.getRoomList(configVersion, resultCallback, errorCallback)
    if configVersion then
        return HttpRequest.request_post("Config.getRoomList", {version = configVersion}, resultCallback, errorCallback)
    else
        return HttpRequest.request_post("Config.getRoomList", {}, resultCallback, errorCallback)
    end
end

-- 获取老虎机房间配置
function HttpRequest.getSlotsConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Slot.slotConfig", {}, resultCallback, errorCallback)
end

-- 获取斗地主房间列表
function HttpRequest.getLandlordsRoomList(configVersion, resultCallback, errorCallback)
    if configVersion then
        return HttpRequest.request_post("Config.getDDZRoomList", {version = configVersion}, resultCallback, errorCallback)
    else
        return HttpRequest.request_post("Config.getDDZRoomList", {}, resultCallback, errorCallback)
    end
end

-- 获取娱乐场房间列表
function HttpRequest.getHappyRoomList(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getCasinoRoomConfig", {}, resultCallback, errorCallback)
end

-- 是否是通过娱乐场进入斗地主
function HttpRequest.setPlayType(type, resultCallback, errorCallback)
    return HttpRequest.request_post("Config.setPlayType", {type = type}, resultCallback, errorCallback)
end

-- 提交反馈
function HttpRequest.sendFeedback(param,resultCallback, errorCallback)
    return HttpRequest.request_post("Feedback.sendFeedback",param,resultCallback, errorCallback)
end

-- 申请破产补助
function HttpRequest.receiveBankrupt(resultCallback, errorCallback)
    return HttpRequest.request_post("Bankrupt.receiveBankrupt",{},resultCallback, errorCallback)
end

-- 拉取注册奖励配置
function HttpRequest.receiveRegisterReward(resultCallback, errorCallback)
    return HttpRequest.request_post("Login.receiveRegisterReward",{},resultCallback, errorCallback)
end


-- 改名
function HttpRequest.modifyPlayerInfo(name,msex,resultCallback, errorCallback)
    return HttpRequest.request_post("Member.modifyUserInfo",{name = name,msex = msex},resultCallback, errorCallback)
end

-- 绑定FB账号
function HttpRequest.bindFacebook(mid, access_token, resultCallback, errorCallback)
    return HttpRequest.request_post("Member.bindFacebook",{mid = mid,access_token = access_token},resultCallback, errorCallback)
end

-- 获取红点
function HttpRequest.checkRedDot(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.checkRedDot",{},resultCallback, errorCallback)
end

-- 消除红点
function HttpRequest.removeRedDot(type,index,resultCallback, errorCallback)
    return HttpRequest.request_post("Config.removeRedDot",{type = type, index = index},resultCallback, errorCallback)
end

--请求支付下单
function HttpRequest.callPayOrder(params,resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.createOrder",params,resultCallback,errorCallback)
end

-- 请求Web支付下单
function HttpRequest.webRedirect(params,resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.webRedirect",params,resultCallback,errorCallback)
end

--请求发货 params:table类型根据需要传参数--必需字段pmode:支付渠道
--[[
        checkout:(signedData,signature)
--]]
function HttpRequest.callClientPayment(params,resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.notifyOrder",params,resultCallback,errorCallback)
end

-- 领取任务奖励
function HttpRequest.completeMission(id,mission_type,resultCallback, errorCallback)
    return HttpRequest.request_post("Mission.completeMission",{id = id,mission_type = mission_type},resultCallback, errorCallback)
end

-- 各种支付
function HttpRequest.promotion(resultCallback, errorCallback)
    return HttpRequest.request_post("Payment.promotion",{},resultCallback, errorCallback)
end

-- 领取活动奖励
function HttpRequest.receiveActivity(aid,resultCallback, errorCallback)
    return HttpRequest.request_post("Config.receiveActivity",{aid = aid},resultCallback, errorCallback)
end

-- 拉取任务列表
function HttpRequest.getUserMissionData(resultCallback, errorCallback)
    return HttpRequest.request_post("Mission.getUserMissionData",{mission_type = 1},resultCallback, errorCallback)
end

-- 牛牛房间配置
function HttpRequest.getNiuNiuRoomConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getNiuNiuRoomConfig",{},resultCallback, errorCallback)
end

function HttpRequest.getNormalNiuConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getNormalNiuConfig",{},resultCallback, errorCallback)
end

-- 获取排行榜
function HttpRequest.getLobbyRank(type,resultCallback,errorCallback)
    return HttpRequest.request_post("Ranking.getLobbyRank",{type = type},resultCallback, errorCallback)
end

-- 消息已读设置
function HttpRequest.readMessage(id,resultCallback,errorCallback)
    return HttpRequest.request_post("Message.readMessage",{id = id},resultCallback, errorCallback)
end

-- 获取推荐好友
function HttpRequest.recommendFriend(resultCallback,errorCallback)
    return HttpRequest.request_post("Friend.recommendFriend",{},resultCallback, errorCallback)
end

-- 新版获取任务列表
function HttpRequest.getUserMissionDataNoReplace(mission_type,resultCallback,errorCallback)
    return HttpRequest.request_post("Mission.getUserMissionDataNoReplace",{mission_type = mission_type},resultCallback, errorCallback)
end

-- 每日挑战任务
function HttpRequest.challengeMission(resultCallback,errorCallback)
    return HttpRequest.request_post("Mission.challengeMission",{},resultCallback, errorCallback)
end

-- 兑换列表
function HttpRequest.getStoreList(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.getStoreList",{},resultCallback, errorCallback)
end

-- 兑换红包
function HttpRequest.jewelExchangeCash(id,resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.jewelExchangeCash",{id = id},resultCallback, errorCallback)
end

-- 兑换历史
function HttpRequest.jewelStoreExchangeLog(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.jewelStoreExchangeLog",{},resultCallback, errorCallback)
end

-- 获取红包配置
function HttpRequest.plazaPublishLimit(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.plazaPublishLimit",{},resultCallback, errorCallback)
end

-- 红包广场
function HttpRequest.plazaList(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.plazaList",{},resultCallback, errorCallback)
end

-- 好友红包
function HttpRequest.getFriendPlazaList(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.getFriendPlazaList",{},resultCallback, errorCallback)
end

-- 领取记录
function HttpRequest.getUserPlazaLog(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.getUserPlazaLog",{},resultCallback, errorCallback)
end

-- 发红包
function HttpRequest.publishBag(title,amount,friend, resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.publishBag",{title = title, amount = amount, friend = friend},resultCallback, errorCallback)
end

-- 领红包
function HttpRequest.receiveBag(id, amount, resultCallback, errorCallback)
    return HttpRequest.request_post("Plaza.receiveBag",{id = id, amount = amount},resultCallback, errorCallback)
end

-- 免费
function HttpRequest.freeConfig(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.freeConfig",{},resultCallback, errorCallback)
end

-- VIP配置
function HttpRequest.VIPConfig(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.VIPConfig",{},resultCallback, errorCallback)
end

-- 互动道具新接口
function HttpRequest.useToolProp(num,resultCallback,errorCallback)
    return HttpRequest.request_post("Prop.useToolProp",{num = num},resultCallback, errorCallback)
end

-- 国内商品配置
function HttpRequest.getInlandProduct(resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.getInlandProduct",{},resultCallback, errorCallback)
end

-- 发送聊天
function HttpRequest.sendChat(tmid,content,resultCallback,errorCallback)
    return HttpRequest.request_post("Chat.sendChat",{tmid = tmid,content = content},resultCallback, errorCallback)
end

-- 发送广播
function HttpRequest.sendBroadcast(content,resultCallback,errorCallback)
    return HttpRequest.request_post("Chat.sendBroadcast",{content = content},resultCallback, errorCallback)
end

-- 聊天记录
function HttpRequest.getChatLog(tmid,resultCallback,errorCallback)
    return HttpRequest.request_post("Chat.getChatLog",{tmid = tmid},resultCallback, errorCallback)
end

-- 获取大厅游戏人数
function HttpRequest.getRoomPlayNum(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.getRoomPlayNum",{},resultCallback, errorCallback)
end

--[[
    运营活动相关
]]

-- 运营活动优先级查询
function HttpRequest.getPriorityConfig(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.iconPriority",{},resultCallback, errorCallback)
end

-- 获取财神送金信息
function HttpRequest.getUserWealthGod(resultCallback,errorCallback)
    return HttpRequest.request_post("WealthGod.getUserWealthGod",{},resultCallback, errorCallback)
end

-- 领取财神送金
function HttpRequest.receiveUserWealthGod(resultCallback,errorCallback)
    return HttpRequest.request_post("WealthGod.receiveUserWealthGod",{},resultCallback, errorCallback)
end

-- 超值返利
function HttpRequest.getPromotionReturn(resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.getPromotionReturn",{},resultCallback, errorCallback)
end

-- 破产特惠
function HttpRequest.getPromotionBankrupt(resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.getPromotionBankrupt",{},resultCallback, errorCallback)
end

-- 限时红包兑金币
function HttpRequest.checkExchangePush(resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.checkExchangePush",{},resultCallback, errorCallback)
end

-- 七日任务
function HttpRequest.checkLoginMission(resultCallback,errorCallback)
    return HttpRequest.request_post("Login.checkLoginMission",{},resultCallback, errorCallback)
end

-- 领取七日任务奖励
function HttpRequest.receiveLoginMission(id,mission_type,resultCallback,errorCallback)
    return HttpRequest.request_post("Login.receiveLoginMission",{id = id, mission_type = mission_type},resultCallback, errorCallback)
end

-- 首充礼包
function HttpRequest.getPromotionFirstBag(resultCallback,errorCallback)
    return HttpRequest.request_post("Payment.getPromotionFirstBag",{},resultCallback, errorCallback)
end

-- 领取登陆奖励
function HttpRequest.receiveLoginReward(resultCallback, errorCallback)
    return HttpRequest.request_post("Login.receiveLoginReward",{},resultCallback, errorCallback)
end

-- 拉取登陆奖励配置
function HttpRequest.showLoginReward(resultCallback, errorCallback)
    return HttpRequest.request_post("Login.showLoginReward",{},resultCallback, errorCallback)
end

-- 拉取牛刀小试
function HttpRequest.showNiudaoxiaoshi(resultCallback, errorCallback)
    return HttpRequest.request_post("Payment.getBankruptNo5",{},resultCallback, errorCallback)
end

-- 领取VIP登陆奖励
function HttpRequest.ddzReceiveReward(day, resultCallback, errorCallback)
    return HttpRequest.request_post("Login.ddzReceiveReward",{day = day},resultCallback, errorCallback)
end

-- 拉取注册奖励配置
function HttpRequest.ddzRegisterConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Login.ddzRegisterConfig",{},resultCallback, errorCallback)
end

-- 拉取VIP登陆奖励
function HttpRequest.ddzLoginReward(resultCallback, errorCallback)
    return HttpRequest.request_post("Login.ddzLoginReward",{},resultCallback, errorCallback)
end

-- 绑定手机号
function HttpRequest.bindPhone(phone, code, resultCallback, errorCallback)
    return HttpRequest.request_post("Member.bindPhone",{phone = phone, code = code},resultCallback, errorCallback)
end

-- 背包
function HttpRequest.getPropBag(resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.getPropBag",{},resultCallback, errorCallback)
end

-- 使用道具
function HttpRequest.splitProp(pid, num, resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.splitProp",{ pid = pid, num = num },resultCallback, errorCallback)
end

-- 赠送道具
function HttpRequest.sendToOther(to, pid, num, resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.sendToOther",{ to = to, pid = pid, num = num },resultCallback, errorCallback)
end

-- 大厅提示语
function HttpRequest.jewelTip(resultCallback, errorCallback)
    return HttpRequest.request_post("Plaza.jewelTip",{},resultCallback, errorCallback)
end

--[[
    牛牛和老虎机累计赢取金额
]]
function HttpRequest.slotNiuNiuwinChallenge(resultCallback, errorCallback)
    return HttpRequest.request_post("Mission.slotNiuNiuwinChallenge",{},resultCallback, errorCallback)
end

--[[
    存钱罐
]]
function HttpRequest.getUserMoneyBox(resultCallback, errorCallback)
    return HttpRequest.request_post("MoneyBox.getUserMoneyBox",{},resultCallback, errorCallback)
end

-- function HttpRequest:createOrder(pmode, product_id, resultCallback, errorCallback)
--     return HttpRequest.request_post("MoneyBox.createOrder",{},resultCallback, errorCallback)
-- end

--[[
    红包 游戏内 任务相关
]]

function HttpRequest.getJewelMission(resultCallback,errorCallback)
    return HttpRequest.request_post("Mission.getJewelMission",{},resultCallback, errorCallback)
end

function HttpRequest.receiveJewelMission(missionId,resultCallback,errorCallback)
    return HttpRequest.request_post("Mission.receiveJewelMission",{id = missionId},resultCallback, errorCallback)
end

function HttpRequest.exchangeJewel(exchangeMoney,resultCallback,errorCallback)
    return HttpRequest.request_post("Plaza.exchangeJewel",{money = exchangeMoney},resultCallback, errorCallback)
end

--[[
    转盘
]]

function HttpRequest.checkWheel(version,resultCallback,errorCallback)
    return HttpRequest.request_post("Wheel.checkWheel",{version = version},resultCallback, errorCallback)
end

function HttpRequest.doWheel(resultCallback,errorCallback)
    return HttpRequest.request_post("Wheel.doWheel",{},resultCallback, errorCallback)
end

--[[
    幸运大抽奖
]]

function HttpRequest.cheeklLottery(resultCallback, errorCallback)
    return HttpRequest.request_post("Wheel.checkWheelLucky",{},resultCallback, errorCallback)
end

function HttpRequest.getLotteryRecord(resultCallback, errorCallback)
    return HttpRequest.request_post("Wheel.wheelLuckyLog",{},resultCallback, errorCallback)
end

function HttpRequest.doWheelLottery(type, num, resultCallback, errorCallback)
    return HttpRequest.request_post("Wheel.doWheelLucky",{type = type, num = num},resultCallback, errorCallback)
end

--[[
    斗牛
]]

function HttpRequest.getNormalNiuTips(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.getNormalNiuTips",resultCallback, errorCallback)
end

function HttpRequest.useNormalNiuTips(resultCallback,errorCallback)
    return HttpRequest.request_post("Config.useNormalNiuTips",{},resultCallback, errorCallback)
end

--[[
    捕鱼
]]

function HttpRequest.upgradeCannon(resultCallback, errorCallback)
    return HttpRequest.request_post("Fishing.upgradeCannon",{},resultCallback, errorCallback)
end

function HttpRequest.getFishingSkill(resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.getFishingSkill",{},resultCallback, errorCallback)
end

function HttpRequest.buyFishingSkill(propType, resultCallback, errorCallback)
    return HttpRequest.request_post("Prop.buyFishingSkill",{type=propType},resultCallback, errorCallback)
end

function HttpRequest.getFishingRoomConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getFishingRoomConfig",{},resultCallback, errorCallback)
end

function HttpRequest.getFishingMoneyRoomConfig(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getFishingMoneyRoomConfig",{},resultCallback, errorCallback)
end

function HttpRequest.getFishingRoomQuitTips(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getFishingRoomQuitTips",{},resultCallback, errorCallback)
end

function HttpRequest.getFishingRedpackReward(missionId, resultCallback, errorCallback)
    return HttpRequest.request_post("Fishing.getFishingRedpackReward",{id = missionId}, resultCallback, errorCallback)
end

function HttpRequest.cliendTraceLog(oper, fps, quality, resultCallback, errorCallback)
    return HttpRequest.request_post("Config.cliendTraceLog",{oper = oper, fps = fps, quality = quality},resultCallback, errorCallback)
end

function HttpRequest.getFishingCannonList(resultCallback, errorCallback)
    return HttpRequest.request_post("Fishing.getFishingCannonList",{},resultCallback, errorCallback)
end

function HttpRequest.changeFishingCannon(style, resultCallback, errorCallback)
    return HttpRequest.request_post("Fishing.changeFishingCannon",{style = style}, resultCallback, errorCallback)
end

function HttpRequest.fishingGuide(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.fishingGuide",{},resultCallback, errorCallback)
end

function HttpRequest.getFishingBomb(resultCallback, errorCallback)
    return HttpRequest.request_post("Fishing.getFishingBomb",{},resultCallback, errorCallback)
end

--[[
    夺宝
]]

-- 商品列表
function HttpRequest.getSnatchList(resultCallback, errorCallback)
    return HttpRequest.request_post("Snatch.getSnatchList",{},resultCallback, errorCallback)
end

-- 参与夺宝
function HttpRequest.entrySnatch(id, resultCallback, errorCallback)
    return HttpRequest.request_post("Snatch.entrySnatch",{id = id},resultCallback, errorCallback)
end

-- 历史列表
function HttpRequest.getSnatchLog(cid, resultCallback, errorCallback)
    return HttpRequest.request_post("Snatch.getSnatchLog",{cid = cid},resultCallback, errorCallback)
end

--[[
    一本万利
]]
function HttpRequest.getUserCapitalProfit(resultCallback, errorCallback)
    return HttpRequest.request_post("CapitalProfit.getUserCapitalProfit",{},resultCallback, errorCallback)
end

function HttpRequest.completeProfitMission(profitId, missionId, resultCallback, errorCallback)
    return HttpRequest.request_post("CapitalProfit.completeProfitMission",{ profit_id = profitId, mission_id = missionId }, resultCallback, errorCallback)
end

--[[
    分享赚钱
]]

function HttpRequest.shareFriend(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.shareFriend",{},resultCallback, errorCallback)
end

--[[
    红包兑换帮助界面
]]

function HttpRequest.wechatOfficial(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.wechatOfficial",{},resultCallback, errorCallback)
end

--[[
    麦乐积分商城
]]

function HttpRequest.mailejifenStore(resultCallback, errorCallback)
    return HttpRequest.request_post("Plaza.mailejifenStore",{},resultCallback, errorCallback)
end

--[[
    钻石积分兑换商城
]]

function HttpRequest.getPointsStoreList(resultCallback, errorCallback)
    return HttpRequest.request_post("PointsStore.getPointsStoreList", {}, resultCallback, errorCallback)
end

function HttpRequest.buyPointProduct(id, resultCallback, errorCallback)
    return HttpRequest.request_post("PointsStore.buyPointProduct", {id = id}, resultCallback, errorCallback)
end

function HttpRequest.getUserPointsLog(resultCallback, errorCallback)
    return HttpRequest.request_post("PointsStore.getUserPointsLog", {}, resultCallback, errorCallback)
end

--[[
    获取刷新数据
]]

function HttpRequest.getLoadSwitchControl(resultCallback, errorCallback)
    return HttpRequest.request_post("Config.getLoadSwitchControl", {}, resultCallback, errorCallback)
end

--[[
    获取分享赚钱的所有数据
]]

function HttpRequest.checkWheelVer2(resultCallback, errorCallback)
    return HttpRequest.request_post("Wheel.checkWheelVer2", {}, resultCallback, errorCallback)
end

function HttpRequest.doWheelVer2(group, mid, resultCallback, errorCallback)
    return HttpRequest.request_post("Wheel.doWheelVer2", {group = group, mid = mid}, resultCallback, errorCallback)
end

--查询广告奖励
function HttpRequest.queryAdvertisementReward(resultCallback,errorCallback)
    return HttpRequest.request_post("Advert.checkAdvertiseReward",{},resultCallback,errorCallback)
end

--获取广告奖励
function HttpRequest.getAdvertisementReward(resultCallback,errorCallback)
    return HttpRequest.request_post("Advert.receiveAdvertiseReward",{},resultCallback,errorCallback) 
end


return HttpRequest