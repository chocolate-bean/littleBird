local MainHall = class("MainHall")

MainHall.REDDOTKEY = {
    MESSAGE     = 1,
    FRIEND      = 2,
    FREE        = 3,
    ACTIVITY    = 4,
    TASK        = 5,
    CAISHEN     = 6,
}

MainHall.Time = {
    BottomShow        = 0.5,
    BottomDismiss     = 0.5,
    RankShow          = 0.5,
    RankDismiss       = 0.5,
    BackButtonShow    = 0.5,
    BackButtonDismiss = 0.5,
    GameButtonShow    = 0.5,
    GameButtonDismiss = 0.6,
    ChooseRoomShow    = 0.5,
    ChooseRoomDelay   = 0.07,
    ChooseRoomDismiss = 0.5,
}

MainHall.IconList = {
    iconHongbao    = nil, -- 红包广场
    iconFirstPay   = nil, -- 每日首充
    iconCaishen    = nil, -- 财神送礼
    iconBroken     = nil, -- 破产特惠
    iconChaozhi    = nil, -- 超值礼包
    iconFuli       = nil, -- 七日福利
    iconPiggy      = nil, -- 存钱罐
    iconLuckywheel = nil, -- 幸运大转盘
    iconLottery    = nil, -- 核弹抽奖
    iconVip        = nil, -- Vip特权
    iconLimitPay   = nil, -- 夺宝
    iconOTM        = nil, -- 一本万利
}

MainHall.ChooseRoomType = {
    normal          = 1,-- 试玩场
    happy           = 2,-- 娱乐场
    fish            = 3,-- 捕鱼场
}

function MainHall:ctor(controller)
    self.controller_ = controller

    self.animTime = self.controller_.AnimTime

    self.view = UnityEngine.GameObject.Find("Canvas/PanelHall")
    self:onEnter()

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
end 

function MainHall:onEnter()
    GameManager.SoundManager:playSomething("bgMusic")
    GameManager.SoundManager:ChangeBGM("bgMusic")
end

function MainHall:initProperties()
    self.redDotofUI        = {}
    self.normalRoomList = nil
    self.isChooseRoom      = false
    self.playNums          = {}
    self.rankIcons         = {}
    self.redpacketUIs      = {}
    self.justShowChooseRoom = false
end

-- -- 播放广告
-- function MainHall:_PlayAdvertisement()

--     -- 调用Android的plugin中的播放广告的方法
--     nativeMgr.FormLua("plugin_base",json.decode({
--         method = "PlayAdvertisement",
--         send   = {"播放广告"}
--         }),
--     function (remandBoxString)
        
--     end)
    
-- end

--为了适配高分辨率大厅的背景动画做的缩放处理
-- function MainHall:_AdaptationHallAnim()
--         -- CanvasEffect
--         local screen = UnityEngine.GameObject.Find("CanvasEffect")
--         self.dragonBone = UnityEngine.GameObject.Find("CanvasEffect/Anim/MovieClip")
    
--         -- local rate = screen.transform.sizeDelta.x / (1280 * (self.dragonBone.transform.localScale.x / 100))
--         local rate = screen.transform.sizeDelta.x / 1280 * (self.dragonBone.transform.localScale.x / 100)
--         local rateY = screen.transform.sizeDelta.y / 720 * (self.dragonBone.transform.localScale.y / 100)
--         print("rate  >>>>>>>>>>>>>>>>>>>> "..rate)
       
--         if rate > 1 then
--             self.dragonBone.transform.localScale = self.dragonBone.transform.localScale * rate  
--             else

--         end
    
    
-- end


function MainHall:initUIControls()
    -- 设置
    self.btnSetting = self.view.transform:Find("PanelTop/Bg/btnSetting").gameObject
    UIHelper.AddButtonClick(self.btnSetting,function()
        local PanelSetting = import("Panel.Setting.PanelSetting").new()
    end)
    self.PanelGame   = self.view.transform:Find("PanelGame").gameObject
    self.PanelBottom = self.view.transform:Find("PanelBottom").gameObject
    self.PanelTop    = self.view.transform:Find("PanelTop").gameObject
    -- UIHelper.AddButtonClick(self.btnAdver,function ()
    --     -- 怎么将数值传过去
    --     local PanelAd = import("Panel.Advertisement.PanelAd").new()
    --     PanelAd:_SetAdLeftCounts(self.leftCounts)
    -- end)


    self.gameButtons = {}
    self.gameView    = self.view.transform:Find("PanelGame")
    for i = 1,4 do 
        if i == 3 or i == 4 then
            self.gameButtons[i] = self.view.transform:Find("PanelGame/game34/game"..i).gameObject
        else 
            self.gameButtons[i] = self.view.transform:Find("PanelGame/game"..i).gameObject
        end
        UIHelper.AddButtonClick(self.gameButtons[i],function()
            GameManager.SoundManager:PlaySound("clickButton")

            -- 马甲包的金币场和红包场

            if isMZBY() then
                local indexChanges = {2, 1, 3, 4}
                if i ~= 3 then
                    self:onGameClick(indexChanges[i])
                else 
                    local PanelLottery = import("Panel.Operation.PanelLottery").new()
                end
            elseif isDBBY() then
                local indexChanges = {1, 2, 3, 4}
                if i ~= 3 then
                    self:onGameClick(indexChanges[i])
                else 
                    local PanelLottery = import("Panel.Operation.PanelLottery").new()
                end
            elseif isDFBY() then
                local indexChanges = {2, 1, 4, 3}
                self:onGameClick(indexChanges[i])
            elseif isFKBY() then
                self:onFKBYGameClick(i)
            else
                self:onGameClick(i)
            end

        end)
    end

    if GameManager.GameConfig.closeSlot == 1 then
        hide(self.gameButtons[4])
    end

    if GameManager.GameConfig.closeNiuniu == 1 then
        hide(self.gameButtons[3])
    end

    if GameManager.GameConfig.closeRedpacket == 1 then
        hide(self.gameButtons[2])
    end

    -- 如果这里 红包场和 百人和水果隐藏了之后 那么就把第一个也隐藏
    if GameManager.GameConfig.closeSlot == 1
    and GameManager.GameConfig.closeNiuniu == 1
    and GameManager.GameConfig.closeRedpacket == 1 then
        hide(self.gameButtons[1])
        self.justShowChooseRoom = true;
    end


    for i = 1,3 do
        local rankIcon = self.view.transform:Find("PanelCenter/PanelRank/Grid/play"..i.."/Icon").gameObject
        table.insert(self.rankIcons, rankIcon)
    end

    self.playNums[1] = self.view.transform:Find("PanelGame/game1/Num").gameObject
    self.playNums[2] = self.view.transform:Find("PanelGame/game2/Num").gameObject
    if isMZBY() then
        self.playTipsBg = self.view.transform:Find("PanelTop/Bg/btnHongbao/TipsBg").gameObject
        self.playTipsBg:addButtonClick(buttonSoundHandler(self, function()
            hide(self.playTipsBg)
        end))
        self.playTips = self.view.transform:Find("PanelTop/Bg/btnHongbao/TipsBg/Text").gameObject
        self.playTipsCloseButton = self.view:findChild("PanelTop/Bg/btnHongbao/TipsBg/closeButton")
        self.playTipsCloseButton:addButtonClick(buttonSoundHandler(self, function()
            hide(self.playTipsBg)
        end))
        show(self.playTipsBg)
    elseif isDBBY() or isDFBY() or isFKBY() then
        -- self.playTipsBg = self.view.transform:Find("PanelTop/Bg/btnHongbao/TipsBg").gameObject
        -- self.playTipsBg:addButtonClick(buttonSoundHandler(self, function()
        --     hide(self.playTipsBg)
        -- end))
        self.playTips = self.view.transform:Find("PanelTop/Bg/btnHongbao/TipsBg/Text").gameObject
        show(self.playTipsBg)
    else
        self.playTips = self.view.transform:Find("PanelTop/TipsBg/Text").gameObject
        self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelTop/TipsBg").gameObject
    end

    -- 信息
    self.btnMessage = self.view.transform:Find("PanelTop/Bg/btnMessage").gameObject
    UIHelper.AddButtonClick(self.btnMessage,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelMessage = import("Panel.Message.PanelMessage").new()
    end)

    -- 好友
    self.btnFriend = self.view.transform:Find("PanelBottom/btnFriend").gameObject
    UIHelper.AddButtonClick(self.btnFriend,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelFriend = import("Panel.Friend.PanelFriend").new()
    end)

    --免费
    self.btnFree = self.view.transform:Find("PanelBottom/btnFree").gameObject
    UIHelper.AddButtonClick(self.btnFree,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelFree = import("Panel.Free.PanelFree").new()
    end)

    -- 活动
    self.btnActivity = self.view.transform:Find("PanelBottom/btnActivity").gameObject
    UIHelper.AddButtonClick(self.btnActivity,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelActivity = import("Panel.Activity.PanelActivity").new()
    end)

    -- 任务
    self.btnTask = self.view.transform:Find("PanelBottom/btnTask").gameObject
    UIHelper.AddButtonClick(self.btnTask,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelTask = import("Panel.Task.PanelTask").new(1, 1)
    end)

    -- 商城
    self.btnShop = self.view.transform:Find("PanelBottom/btnShop").gameObject
    UIHelper.AddButtonClick(self.btnShop,function()
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.MAINHALL
        -- local PanelShop = import("Panel.Shop.PanelShop").new()
        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
    end)

    if isDBBY() then
        self.btnBag = self.view:findChild("PanelBottom/btnBag")
        self.btnBag:addButtonClick(buttonSoundHandler(self, function()
            local PanelBag = import("Panel.Bag.PanelBag").new()
        end))
    end

    if isMZBY() or isDFBY() or isFKBY() then
        self.btnVip = self.view:findChild("PanelBottom/btnVip")
        self.btnVip:addButtonClick(buttonSoundHandler(self, function()
            local PanelNewVipHelper = import("Panel.Special.PanelNewVipHelper").new()
        end))
        
        self.btnBackpack = self.view:findChild("PanelBottom/btnBackpack")
        self.btnBackpack:addButtonClick(buttonSoundHandler(self, function()
            local PanelBag = import("Panel.Bag.PanelBag").new()
        end))

        self.btnFriends = self.view.transform:Find("PanelTop/Bg/btnFriends").gameObject
        self.btnFriends:addButtonClick(buttonSoundHandler(self, function()
            local PanelFriend = import("Panel.Friend.PanelFriend").new()
        end))
    end

    self.topUserInfoView = self.view.transform:Find("PanelTop/userInfoView").gameObject
    self.PlayIcon   = self.view.transform:Find("PanelTop/userInfoView/PlayIcon").gameObject
    UIHelper.AddButtonClick(self.PlayIcon,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelPlayInfoBig = import("Panel.PlayInfo.PanelPlayInfoBig").new()
    end)
    self.PlayIconFrame = self.view.transform:Find("PanelTop/userInfoView/PlayIcon/PlayIconFrame").gameObject
    self.Playname   = self.view.transform:Find("PanelTop/userInfoView/PlayName").gameObject
    self.PlayLevel  = self.view.transform:Find("PanelTop/userInfoView/PlayLevel").gameObject
    self.PlayMoneyText  = self.view.transform:Find("PanelTop/Bg/btnGold/Text").gameObject
    self.PlayDiamondText  = self.view.transform:Find("PanelTop/Bg/btnDiamond/Text").gameObject
    self.PlayHongbaoText  = self.view.transform:Find("PanelTop/Bg/btnHongbao/Text").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelTop/Bg/btnHongbao").gameObject

    if isDBBY() then
        self.PlayIconBg   = self.view.transform:Find("PanelTop/userInfoView/PlayIconBg").gameObject
        self.PlaynameBg   = self.view.transform:Find("PanelTop/userInfoView/PlayNameBg").gameObject
    end

    -- if isFKBY() then
    if false then
        self.btnRank  = self.view.transform:Find("PanelBottom/btnRank").gameObject
        UIHelper.AddButtonClick(self.btnRank,function()
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelRank = import("Panel.Rank.PanelRank").new(3)
        end)
    else
        self.btnRank  = self.view.transform:Find("PanelCenter/PanelRank").gameObject
        UIHelper.AddButtonClick(self.btnRank,function()
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelRank = import("Panel.Rank.PanelRank").new(3)
        end)
    end

    self.btnMoney  = self.view.transform:Find("PanelTop/Bg/btnGold").gameObject
    UIHelper.AddButtonClick(self.btnMoney,function()
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.MAINHALL
        -- local PanelShop = import("Panel.Shop.PanelShop").new()
        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
    end)

    self.btnDiamond  = self.view.transform:Find("PanelTop/Bg/btnDiamond").gameObject
    UIHelper.AddButtonClick(self.btnDiamond,function()
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.MAINHALL
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new(3)
    end)

    self.btnHongbao  = self.view.transform:Find("PanelTop/Bg/btnHongbao").gameObject
    UIHelper.AddButtonClick(self.btnHongbao,function()
        GameManager.SoundManager:PlaySound("clickButton")
        -- local PanelExchange = import("Panel.Exchange.PanelExchange").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new(2)
    end)
    
    MainHall.IconList.iconHongbao   = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnPlaza").gameObject
    MainHall.IconList.iconHongbao:addButtonClick(buttonSoundHandler(self, function()
        local PanelBag = import("Panel.Bag.PanelBag").new()
    end), false)
    MainHall.IconList.iconFirstPay  = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnFirstPay").gameObject
    MainHall.IconList.iconFirstPay:addButtonClick(buttonSoundHandler(self, function()
        local PanelFirstPay = import("Panel.Operation.PanelFirstPay").new()
    end), false)
    MainHall.IconList.iconFirstPay:SetActive(false)
    MainHall.IconList.iconCaishen   = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnCaishen").gameObject
    MainHall.IconList.iconCaishen:addButtonClick(buttonSoundHandler(self, function()
        local PanelCaishen = import("Panel.Operation.PanelCaishen").new()
    end), false)
    if isMZBY() or isDFBY() or isFKBY() then
        MainHall.IconList.iconLottery = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnLottery").gameObject
    else
        MainHall.IconList.iconLottery = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnLottery").gameObject
    end
    MainHall.IconList.iconLottery:addButtonClick(buttonSoundHandler(self, function()
        local PanelLottery = import("Panel.Operation.PanelLottery").new()
    end), false)

    MainHall.IconList.iconOTM = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnOtm").gameObject
    MainHall.IconList.iconOTM:addButtonClick(buttonSoundHandler(self, function()
        local PanelOneToMillion = import("Panel.Operation.PanelOneToMillion").new()
    end), false)

    if isMZBY() or isDFBY() then
        MainHall.IconList.iconLimitPay = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnLimitPay").gameObject
        MainHall.IconList.iconLimitPay:addButtonClick(buttonSoundHandler(self, function()
            local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new()
        end), false)

        MainHall.IconList.iconPiggy   = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnPiggy").gameObject
        MainHall.IconList.iconPiggy:addButtonClick(buttonSoundHandler(self, function()
            local PanelPiggy = import("Panel.Operation.PanelPiggy").new()
        end), false)
    else
        MainHall.IconList.iconLimitPay = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnLimitPay").gameObject
        MainHall.IconList.iconLimitPay:addButtonClick(buttonSoundHandler(self, function()
            local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new()
        end), false)

        MainHall.IconList.iconPiggy   = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnPiggy").gameObject
        MainHall.IconList.iconPiggy:addButtonClick(buttonSoundHandler(self, function()
            local PanelPiggy = import("Panel.Operation.PanelPiggy").new()
        end), false)
    end

    MainHall.IconList.iconLuckywheel = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnLuckyWheel").gameObject
    MainHall.IconList.iconLuckywheel:addButtonClick(buttonSoundHandler(self, function()
        -- local PanelLuckyWheel = import("Panel.Operation.PanelLuckyWheel").new()
        -- local PanelInvite = import("Panel.Operation.PanelInvite").new()
        local PanelShareMoney = import("Panel.Operation.PanelShareMoney").new()
    end), false)

    MainHall.IconList.iconVip = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnVip").gameObject
    MainHall.IconList.iconVip:addButtonClick(buttonSoundHandler(self, function()
        local PanelNewVipHelper = import("Panel.Special.PanelNewVipHelper").new()
    end), false)


    MainHall.IconList.iconBroken    = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnPochan").gameObject
    MainHall.IconList.iconBroken:addButtonClick(buttonSoundHandler(self, function()
        local PanelPochan = import("Panel.Operation.PanelPochan").new()
    end), false)
    MainHall.IconList.iconChaozhi     = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnChaozhi").gameObject
    MainHall.IconList.iconChaozhi:addButtonClick(buttonSoundHandler(self, function()
        local PanelChaozhi = import("Panel.Operation.PanelChaozhi").new()
    end), false)
    MainHall.IconList.iconFuli   = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnFuli").gameObject
    MainHall.IconList.iconFuli:addButtonClick(buttonSoundHandler(self, function()
        local PanelFuli = import("Panel.Operation.PanelFuli").new()
    end), false)

    self.redDotofUI[MainHall.REDDOTKEY.MESSAGE]     = self.view.transform:Find("PanelTop/Bg/btnMessage/redDot").gameObject
    self.redDotofUI[MainHall.REDDOTKEY.FRIEND]      = self.view.transform:Find("PanelBottom/btnFriend/redDot").gameObject
    self.redDotofUI[MainHall.REDDOTKEY.FREE]        = self.view.transform:Find("PanelBottom/btnFree/redDot").gameObject
    self.redDotofUI[MainHall.REDDOTKEY.ACTIVITY]    = self.view.transform:Find("PanelBottom/btnActivity/redDot").gameObject
    self.redDotofUI[MainHall.REDDOTKEY.TASK]        = self.view.transform:Find("PanelBottom/btnTask/redDot").gameObject
    self.redDotofUI[MainHall.REDDOTKEY.CAISHEN]     = self.view.transform:Find("PanelCenter/PanelIcon/Grid/btnCaishen/redDot").gameObject

    self.BrokenTime = self.view.transform:Find("PanelCenter/PanelIconCenter/Grid/btnPochan/Text").gameObject
    self.BrokenTime:SetActive(false)

    hide({MainHall.IconList.iconBroken,
        MainHall.IconList.iconChaozhi,
        MainHall.IconList.iconFuli,})

    self.btnBack = self.view.transform:Find("PanelTop/btnBack").gameObject
    UIHelper.AddButtonClick(self.btnBack, buttonSoundHandler(self, self.dissmissChooseRoomView))

    for i, type in pairs(MainHall.ChooseRoomType) do
        self:initChooseRoomViewControls(type)
    end

    if isMZBY() or isDBBY() then
        hide(MainHall.IconList.iconLottery)
    end

    --[[
        showRedpacket    = data["switch.closeRedpacket"] == 0,      -- 红包相关
        showLottery      = data["switch.closeWheelLucky"] == 0,     -- 十连抽的 抽奖功能
        showShare        = data["switch.closeShare"] == 0,          -- 带有分享的大转盘
        showShareFriend  = data["switch.closeShareFriend"] == 0,    -- 跳转公众号的分享
        showOneToMillion = data["switch.closeCapticalProfit"] == 0, -- 一本万利
    ]]

    showOrHide(GameManager.GameConfig.SensitiveSwitch.showLottery, MainHall.IconList.iconLottery)
    -- showOrHide(GameManager.GameConfig.SensitiveSwitch.showShare, MainHall.IconList.iconLuckywheel)
    showOrHide(GameManager.GameConfig.SensitiveSwitch.showShareFriend, MainHall.IconList.iconLuckywheel)
    showOrHide(GameManager.GameConfig.SensitiveSwitch.showOneToMillion, MainHall.IconList.iconOTM)
    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function MainHall:initUIDatas()
    self:reflushPlayInfo()

    for i, type in pairs(MainHall.ChooseRoomType) do
        self:initChooseRoomViewData(type)
    end

    http.getRoomPlayNum(
        function(callData)
            if callData and callData.flag == 1 then
                self.playNums[1]:setText(callData.fishing_money)
                self.playNums[2]:setText(callData.fishing_redpack)
            else
                self.playNums[1]:setText(1653)
                self.playNums[2]:setText(1235)
            end
        end,
        function(callData)
            for i = 1,3 do
                self.playNums[1]:setText(1653)
                self.playNums[2]:setText(1235)
            end
        end
    )

    http.jewelTip(
        function(callData)
            if callData and callData.flag == 1 then
                self.playTips:setText(callData.tips)
            else
                self.playTips:setText(T("红包场海量红包等你来拿！"))
            end
        end,
        function(callData)
            self.playTips:setText(T("红包场海量红包等你来拿！"))
        end
    )

    -- 获取可看广告的次数来决定广告点击按钮的显示
    -- http.queryAdvertisementReward(
    --     function (callData)
    --     if callData and callData.flag == 1 then
    --         if callData.left_times and callData.left_times >0 then
    --            --显示点击进入广告的view
    --            self.leftCounts = callData.left_times
               
    --         else
    --           --隐藏进入广告的view

    --         end
    --     end

    -- end,function (calldata)
    --     print("错误回调")
    -- end)

    if isFKBY() then
        if GameManager.GameConfig.closeHundredRoom == 1 then
            local niuniu = self.view.transform:Find("PanelHappyChooseRoom/contentView/itemButton (1)").gameObject
            niuniu:SetActive(false)
        end
    else
        http.getLobbyRank(
            4,
            function(callData)
                if callData and callData.flag == 1 then
                    local count = #callData.list
                    if count > 3 then
                        count = 3
                    end
                    for i = 1, count do
                        local data = callData.list[i]
                        local icon = self.rankIcons[i]
                        GameManager.ImageLoader:loadIconOnlyRank({
                            url = data.micon,
                            sex = tonumber(data.msex),
                            node = icon,
                            callback = function(sprite)
                                if self.view and icon then
                                    icon:GetComponent('Image').sprite = sprite
                                end
                            end,
                        })
                    end
                end
            end,
            function(callData)
            end
        )
    end

    showOrHide(GameManager.GameConfig.HasDiamond == 1, self.btnDiamond)
    if isMZBY() or isDFBY() or isFKBY() then
        if not GameManager.GameConfig.SensitiveSwitch.showRedpacket then
            self.btnDiamond.transform.localPosition = self.btnHongbao.transform.localPosition
        end
    else
        if GameManager.GameConfig.HasDiamond == 0 then
            local BG = self.view.transform:Find("PanelTop/Bg").gameObject
            BG:setSprite("Images/SenceMainHall/topBg")
            BG:GetComponent('Image'):SetNativeSize()
        end

        if not GameManager.GameConfig.SensitiveSwitch.showRedpacket then
            -- 缩小bg 
            local bg = self.view:findChild("PanelTop/Bg")
            if GameManager.GameConfig.HasDiamond == 1 then
                bg.transform.sizeDelta = Vector3.New(580, bg.transform.sizeDelta.y, 0)
            else
                bg.transform.sizeDelta = Vector3.New(399, bg.transform.sizeDelta.y, 0)
            end
        end
    end


    if GameManager.GameConfig.LimitPay == 1 then
        MainHall.IconList.iconLimitPay:SetActive(true)
    end

    self:checkOtherMission()

    self:setShowState()
    self:playShowAnim()
end


--[[
    选场界面
]]

-- 初始化选场界面
function MainHall:initChooseRoomViewControls(type)
    local viewName
    local maxCount
    local controls = {}

    if type == MainHall.ChooseRoomType.normal then
        self.normalChooseRoomControls = {}
        viewName = "PanelNomalChooseRoom"
        -- if isWZBY() then
        --     viewName = "PanelLandlordsChooseRoom"
        -- end
        maxCount = 2
    elseif type == MainHall.ChooseRoomType.happy then
        self.happyChooseRoomControls = {}
        viewName = "PanelHappyChooseRoom"
        maxCount = 2
    elseif type == MainHall.ChooseRoomType.fish then
        self.fishChooseRoomControls = {}
        viewName = "PanelFishChooseRoom"
        maxCount = 3
    end
    -- "PanelHall/PanelNomalChooseRoom"
    controls.view             = self.view.transform:Find(viewName).gameObject
    controls.contentView      = self.view.transform:Find(viewName.."/contentView").gameObject
    controls.items = {}
    for index = 1, maxCount do
        controls.items[index] = {}
        local view = controls.contentView.transform:Find("itemButton ("..index..")").gameObject
        controls.items[index].view = view
        controls.items[index].dollImage = view.transform:Find("dollImage").gameObject
        controls.items[index].nameImage = view.transform:Find("nameImage").gameObject
        controls.items[index].anteText  = view.transform:Find("anteText").gameObject
        controls.items[index].carryText = view.transform:Find("carryText").gameObject
        if isDFBY() and type == MainHall.ChooseRoomType.fish then  
            controls.items[index].armatureName = view.transform:Find("armatureName"..index).gameObject
            controls.items[index].infoBg = view.transform:Find("Bg").gameObject
        end
        
        if type == MainHall.ChooseRoomType.happy then
            UIHelper.AddButtonClick(view, buttonSoundHandler(self,function()
                self:onHappyItemClick(index)
            end))
        elseif type == MainHall.ChooseRoomType.fish then
            UIHelper.AddButtonClick(view, buttonSoundHandler(self,function()
                self:onFishItemClick(index)
            end))
        end
    end

    if type == MainHall.ChooseRoomType.normal then
        self.normalChooseRoomControls = controls
    elseif type == MainHall.ChooseRoomType.happy then
        self.happyChooseRoomControls = controls
    elseif type == MainHall.ChooseRoomType.fish then
        self.fishChooseRoomControls = controls
    end
end

-- 初始化选场数据
function MainHall:initChooseRoomViewData(type)
    local controls
    local setData = function(index, data)
        local item = controls.items[index]
        item.anteText:GetComponent('Text').text = string.format(T("解锁%s倍炮"), formatFiveNumber(data.ante))
        if tonumber(data.max_limit_money) == 0 then
            item.carryText:GetComponent('Text').text = formatFiveNumber(data.min_money)..T("以上")
        else
            item.carryText:GetComponent('Text').text = formatFiveNumber(data.min_money).."-"..formatFiveNumber(data.max_limit_money)
        end
    end

    if type == MainHall.ChooseRoomType.normal then 
        controls = self.normalChooseRoomControls
    elseif type == MainHall.ChooseRoomType.happy then
        controls = self.happyChooseRoomControls
    elseif type == MainHall.ChooseRoomType.fish then
        controls = self.fishChooseRoomControls
        GameManager.ChooseRoomManager:getFishingMoneyRoomList(function()
            -- TODO 捕鱼房间列表
            local roomList = GameManager.ChooseRoomManager.fishingMoneyRoomConfig
            self.fishRoomList = roomList
            for index, data in ipairs(roomList) do
                setData(index,data)
            end
            if self.justShowChooseRoom then
                self:justShowChooseRoomView(type)
            end
        end)
    end
end

-- 选场动画
function MainHall:showChooseRoomView(type)
    self.curChooseRoomType = type
    local showView = function()
        self.isChooseRoom = true
        for i, button in ipairs(self.gameButtons) do
            button:GetComponent('Button').interactable = false
        end
        self:gameViewAnimation(false, false, function()
            self:bottomViewAnimation(false)
            self:rankViewAnimation(false)
            self:backButtonAnimation(true)
            self:iconAnimation(false)
        end)

        Timer.New(function()
            self:chooseRoomViewAnimation(true, self.curChooseRoomType)
        end, MainHall.Time.GameButtonDismiss, 1, true):Start()
    end

    if type == MainHall.ChooseRoomType.fish then
        GameManager.ChooseRoomManager:getFishingMoneyRoomList(function()
            showView()
        end)
    else
        showView()
    end
end

function MainHall:justShowChooseRoomView(type)
    self.curChooseRoomType = type
    self:chooseRoomViewAnimation(true, self.curChooseRoomType)
end


-- 选厂界面退场动画
function MainHall:dissmissChooseRoomView()
    self.isChooseRoom = false
    self:chooseRoomViewAnimation(false, self.curChooseRoomType)
    
    self:backButtonAnimation(false)
    Timer.New(function()
        for i, button in ipairs(self.gameButtons) do
            button:GetComponent('Button').interactable = true
        end
        self:gameViewAnimation(self.curChooseRoomType == MainHall.ChooseRoomType.normal, true)
        self:bottomViewAnimation(true)
        self:rankViewAnimation(true)
        self:iconAnimation(true)
    end, MainHall.Time.ChooseRoomDismiss, 1, true):Start()
end

--[[
    animation
]]
function MainHall:showAnimation()
    
end

function MainHall:dismissAnimation()
    
end

function MainHall:bottomViewAnimation(isShow)
    local sw, sh = getScreenSize()
    if isShow then
        show(self.PanelBottom)
        local moveAnimation = self.PanelBottom.transform:DOLocalMoveY(0, MainHall.Time.BottomShow)
        -- moveAnimation:SetEase(DG.Tweening.Ease.OutQuint)
        moveAnimation:OnComplete(function()

        end)
    else
        local moveAnimation = self.PanelBottom.transform:DOLocalMoveY(sh * -0.1, MainHall.Time.BottomDismiss)
        -- moveAnimation:SetEase(DG.Tweening.Ease.InBack)
        moveAnimation:OnComplete(function()
            hide(self.PanelBottom)
        end)
        -- Timer.New(function()
        --     hide(self.PanelBottom)
        -- end, MainHall.Time.BottomDismiss, 1, true):Start()
    end
end

function MainHall:rankViewAnimation(isShow)
    if isFKBY() then
    else
        local sw, sh = getScreenSize()
        local gridRank = self.view.transform:Find("PanelCenter/PanelRank").gameObject
        if isShow then
            show(gridRank)
            local moveAnimation = gridRank.transform:DOLocalMoveX(-sw / 2, MainHall.Time.BottomShow)
            moveAnimation:OnComplete(function()
    
            end)
        else
            local moveAnimation = gridRank.transform:DOLocalMoveX( -sw / 2 - 100, MainHall.Time.BottomDismiss)
            moveAnimation:OnComplete(function()
                hide(gridRank)
            end)
        end
    end
end

function MainHall:backButtonAnimation(isShow)
    if isShow then
        doFadeDismiss(self.PlayIcon, "Image", MainHall.Time.BackButtonDismiss, 0)
        doFadeDismiss(self.PlayIconFrame, "Image", MainHall.Time.BackButtonDismiss, 0)
        show(self.btnBack)
        self.btnBack.transform.localPosition = Vector3.New(self.btnBack.transform.localPosition.x, 550, 0)
        Timer.New(function()
            hide(self.PlayIcon)
            hide(self.PlayIconFrame)
            if isDBBY() then
                hide(self.topUserInfoView)
            end
            local moveAnimation = self.btnBack.transform:DOLocalMoveY(320, MainHall.Time.BackButtonDismiss * 0.5)
            moveAnimation:OnComplete(function()
    
            end)
        end, MainHall.Time.BackButtonDismiss * 0.5, 1, true):Start()
    else
        show(self.PlayIcon)
        show(self.PlayIconFrame)
        if isDBBY() then
            show(self.topUserInfoView)
        end
        local moveAnimation = self.btnBack.transform:DOLocalMoveY(550, MainHall.Time.BackButtonDismiss)
        moveAnimation:OnComplete(function()
            hide(self.btnBack)
        end)
        Timer.New(function()
            doFadeAutoShow(self.PlayIcon, "Image", MainHall.Time.BackButtonDismiss, 0)
            doFadeAutoShow(self.PlayIconFrame, "Image", MainHall.Time.BackButtonDismiss, 0)
        end, MainHall.Time.BackButtonDismiss * 0.5, 1, true):Start()
    end
end

function MainHall:iconAnimation(isShow)
    -- body
    local grid = self.view.transform:Find("PanelCenter/PanelIcon").gameObject
    local gridCenter = self.view.transform:Find("PanelCenter/PanelIconCenter").gameObject
    -- local gridRank = self.view.transform:Find("PanelCenter/PanelRank").gameObject

    if isShow then
        show({grid, gridCenter})
        grid:fadeIn(1)
        gridCenter:fadeIn(1)
    else
        grid:fadeOut(MainHall.Time.GameButtonDismiss)
        gridCenter:fadeOut(MainHall.Time.GameButtonDismiss)
        Timer.New(function()
            hide({grid, gridCenter})
        end, MainHall.Time.GameButtonDismiss, 1, true):Start()
    end
end

function MainHall:gameViewAnimation(isNormal, isShow, midCallback)
    --[[
        11 22
        11 33
    ]]
    local sw, sh = getScreenSize()
    if isShow then
        for index, gameButton in ipairs(self.gameButtons) do
            show(gameButton)
        end
        if GameManager.GameConfig.closeSlot == 1 then
            hide(self.gameButtons[4])
        end
    
        if GameManager.GameConfig.closeNiuniu == 1 then
            hide(self.gameButtons[3])
        end
    
        if GameManager.GameConfig.closeRedpacket == 1 then
            hide(self.gameButtons[2])
        end
        local moveAnimation = self.gameView.transform:DOLocalMoveX(self.gameView.transform.localPosition.x - sw, MainHall.Time.GameButtonShow)
        moveAnimation:OnComplete(function()
        end)
    else
        if midCallback and not isNormal then
            midCallback()
        end
        local moveAnimation = self.gameView.transform:DOLocalMoveX(self.gameView.transform.localPosition.x + sw, MainHall.Time.GameButtonDismiss)
        moveAnimation:SetEase(DG.Tweening.Ease.OutQuint)
        moveAnimation:OnComplete(function()
            for index, gameButton in ipairs(self.gameButtons) do
                hide(gameButton)
            end
        end)
    end
end

function MainHall:normalIconLoopAnimation(obj)
    local scaleAniamtion = obj.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.7 + math.random(2)/10)
    scaleAniamtion:SetEase(DG.Tweening.Ease.Linear)
    scaleAniamtion:SetLoops(1000, DG.Tweening.LoopType.Yoyo)
end

function MainHall:chooseRoomViewAnimation(isShow, type)
    local Controls
    local Config
    
    if type and type == MainHall.ChooseRoomType.normal then
        Controls = self.normalChooseRoomControls
        Config = self.normalRoomList
    elseif type == MainHall.ChooseRoomType.happy then
        Controls = self.happyChooseRoomControls
        Config = self.happyRoomList
    elseif type == MainHall.ChooseRoomType.fish then
        Controls = self.fishChooseRoomControls
        Config = self.fishRoomList
    end

    if isShow then
        if type == MainHall.ChooseRoomType.fish and self.justShowChooseRoom then
            UIHelper.SetHorizontalLayoutGroupSpacing(Controls.contentView, -64)
        end

        -- Common
        show(Controls.view)
        for index, item in ipairs(Controls.items) do
            local isClose

            if type == MainHall.ChooseRoomType.fish then
                isClose = Config[index].status == 0
            elseif type == MainHall.ChooseRoomType.happy and GameManager.GameConfig.closeHundredRoom == 1 and index == 1 then
                isClose = true
            else
                isClose = false
            end
            
            if not isClose then
                doFadeAutoShow(item.view, "Image", MainHall.Time.ChooseRoomShow, 0)
                doFadeAutoShow(item.dollImage, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay)
                doFadeAutoShow(item.nameImage, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay * 2)
                if type == 2 and index == 1 then
                    hide(item.anteText)
                else
                    -- 不展示炮台倍数
                    -- doFadeAutoShow(item.anteText, "Text", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay * 3)
                end
                doFadeAutoShow(item.carryText, "Text", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay * 4)
                if isDFBY() and type == MainHall.ChooseRoomType.fish then
                    doFadeAutoShow(item.infoBg, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay * 3)
                    show(item.armatureName)
                end
            else
                hide(item.view)
            end
        end
        -- Deffient
        -- 斗地主有快速开始，其它的没有
        if type and type == MainHall.ChooseRoomType.normal then
            doFadeAutoShow(Controls.quickStartButton, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay * 5)
        end
        
    else
        -- Common
        for index, item in ipairs(Controls.items) do
            doFadeDismiss(item.carryText, "Text", MainHall.Time.ChooseRoomDismiss, 0)
            doFadeDismiss(item.anteText, "Text", MainHall.Time.ChooseRoomDismiss, MainHall.Time.ChooseRoomDelay )
            doFadeDismiss(item.nameImage, "Image", MainHall.Time.ChooseRoomDismiss, MainHall.Time.ChooseRoomDelay * 2)
            doFadeDismiss(item.dollImage, "Image", MainHall.Time.ChooseRoomDismiss, MainHall.Time.ChooseRoomDelay * 3)
            doFadeDismiss(item.view, "Image", MainHall.Time.ChooseRoomDismiss, MainHall.Time.ChooseRoomDelay * 4)
            if isDFBY() and type == MainHall.ChooseRoomType.fish then
                doFadeDismiss(item.infoBg, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay)
                Timer.New(function()
                    hide(item.armatureName)
                end, MainHall.Time.ChooseRoomDelay * 3, 1, true):Start()
            end
        end
        -- Deffient
        -- 斗地主有快速开始，其它的没有
        if type and type == MainHall.ChooseRoomType.normal then
            doFadeDismiss(Controls.quickStartButton, "Image", MainHall.Time.ChooseRoomShow, MainHall.Time.ChooseRoomDelay)
        end
        
    end
end

--[[
    http 请求
]]

function MainHall:checkLoginMission()
    -- 七日福利的相关
    http.checkLoginMission(
        function(callData)
            if callData and callData.mission then
                show(MainHall.IconList.iconFuli)
            else
                hide(MainHall.IconList.iconFuli)
            end
        end,
        function(callData)
            hide(MainHall.IconList.iconFuli)
        end
    )
end

function MainHall:checkOtherMission()
    self:checkLoginMission()
    GameManager.ODialogManager:getPriorityConfig(function(isSuccess)
        -- 破产特惠
        if isSuccess then
            showOrHide(GameManager.ODialogManager:canShow(GameManager.ODialogManager.plans.A.Chaozhi), MainHall.IconList.iconChaozhi)
            local isCanShowPochan = GameManager.ODialogManager:canShow(GameManager.ODialogManager.plans.A.Pochan)
            showOrHide(isCanShowPochan, MainHall.IconList.iconBroken)
            if isCanShowPochan then
                http.getPromotionBankrupt(
                    function(callData)
                        if callData then
                            dump(callData)
                            self:onTimerStart(tonumber(callData.data.count_down))
                        end
                    end,
                    function(callData)
                        GameManager.TopTipManager:showTopTip(T("查询破产特惠失败"))
                    end
                )   
            end
        else
            hide(MainHall.IconList.iconBroken)
        end
    end)
end

function MainHall:reflushPlayInfo()
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })

    if GameManager.UserData.viplevel and tonumber(GameManager.UserData.viplevel) > 0 then
        local sp = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
        self.PlayIconFrame:GetComponent('Image').sprite = sp
        self.PlayIconFrame:SetActive(true)
    else
        self.PlayIconFrame:SetActive(false)
    end

    self.Playname:GetComponent('Text').text = GameManager.UserData.name
    self.PlayLevel:GetComponent('Text').text = "VIP "..GameManager.UserData.viplevel--"Lv."..GameManager.Level:getLevelByExp(GameManager.UserData.exp)
    self.PlayMoneyText:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.PlayDiamondText:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.diamond)
    self.PlayHongbaoText:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
end

-- 疯狂捕鱼的子游戏点击事件
function MainHall:onFKBYGameClick(index)
    local gameFunc = {
        [1] = function()
            self:showChooseRoomView(MainHall.ChooseRoomType.fish)
        end,
        [2] = function()
            self:onRedpacketFishItemClick()
        end,
        [3] = function()
            self:showChooseRoomView(MainHall.ChooseRoomType.happy)
        end,
        [4] = function()
            self:showChooseRoomView(MainHall.ChooseRoomType.happy)
        end
    }

    if gameFunc[index] then
        gameFunc[index]()
    else
        print("传的啥玩意")
    end
end

-- 子游戏点击事件
function MainHall:onGameClick(index)
    
    local gameFunc = {
        [1] = function()
            self:showChooseRoomView(MainHall.ChooseRoomType.fish)
        end,
        [2] = function()
            self:onRedpacketFishItemClick()
        end,
        [3] = function()
            self:getNiuniuRoomAndLogin()
        end,
        [4] = function()
            self:getSlotsRoomAndLogin()
        end,
    }

    if gameFunc[index] then
        gameFunc[index]()
    else
        print("传的啥玩意")
    end
end

-- 通知PHP玩家进入方式
function MainHall:sendChooseRoomTypeToPHP()
    if self.curChooseRoomType == MainHall.ChooseRoomType.normal then
        http.setPlayType(
            0,
            function(retData)
            end,
            function(callData)
            end
        )  
    elseif self.curChooseRoomType == MainHall.ChooseRoomType.happy then
        http.setPlayType(
            1,
            function(retData)
            end,
            function(callData)
            end
        ) 
    end
end

-- 斗地主登陆
function MainHall:getNormalRoomAndLogin(index)
    local config = self.normalRoomList[index]
    local userMoney = GameManager.UserData.money
    --[[
        破产
    ]]

    function showTips(tips)
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = tips,
            firstButtonCallbcak = function()

            end,
        })
    end

    if GameManager.UserData.viplevel < tonumber(config.vip_limit) then
        showTips(T("VIP等级")..config.vip_limit..T("方可进入"))
        return
    end

    if tonumber(config.min_money) > userMoney then
        -- 提示钱不足
        showTips(T("金币不足, 无法进入该场次"))
        return
    end
    if tonumber(config.max_limit_money) < userMoney 
    and tonumber(config.max_limit_money) ~= 0 then
        -- 提示钱太多
        showTips(T("您的金币过多,\n 请更换更高级的场次"))
        return
    end

    -- 通知PHP玩家的进场类型
    self:sendChooseRoomTypeToPHP()

    GameManager.ServerManager:getNormalRoomAndLogin(tonumber(config.level))
end

-- 牛牛登陆
function MainHall:getNiuniuRoomAndLogin()
    GameManager.ChooseRoomManager:getNiuniuConfig(function()
        local roomConfig = GameManager.ChooseRoomManager.niuniuConfig
        local minLimitMoney = tonumber(roomConfig.room.min_money)
        if GameManager.UserData.money < minLimitMoney then
            GameManager.TopTipManager:showTopTip(T("金币不足无法进入!"))
        else
            GameManager.ServerManager:getNiuniuRoomAndLogin()
        end
    end)
end

-- 老虎机登陆
function MainHall:getSlotsRoomAndLogin()
    GameManager.ChooseRoomManager:getSlotsConfig(function()
        local roomConfig = GameManager.ChooseRoomManager.slotsConfig
        local minLimitMoney = tonumber(roomConfig.room.min_money)
        if GameManager.UserData.money < minLimitMoney then
            GameManager.TopTipManager:showTopTip(T("金币不足无法进入!"))
        else
            GameManager.ServerManager:getSoltsRoomAndLogin()
        end
    end)
end

-- 捕鱼登陆
function MainHall:getFishRoomAndLogin(index)
    GameManager.ChooseRoomManager:getFishingMoneyRoomList(function()
        local roomLists  = GameManager.ChooseRoomManager.fishingMoneyRoomConfig
        local roomConfig = roomLists[index]
        local minLimitMoney = tonumber(roomConfig.min_money)
        local maxLimitMoney = tonumber(roomConfig.max_limit_money)

        if GameManager.UserData.money > maxLimitMoney and maxLimitMoney ~= 0 then
            GameManager.TopTipManager:showTopTip(T("金币数量过多，请选择其他房间!"))
            return
        end

        if GameManager.UserData.money < minLimitMoney then
            GameManager.TopTipManager:showTopTip(T("金币不足无法进入!"))
            return
        end
        GameManager.ServerManager:getFishingRoomAndLogin(roomConfig.level)
    end)
end

-- 红包捕鱼登陆
function MainHall:getRedPacketFishRoomAndLogin()
    GameManager.ChooseRoomManager:getFishRoomList(function()
        -- 遍历 找到红包场
        local roomList = GameManager.ChooseRoomManager.fishingRoomConfig
        local roomConfig
        for index, config in ipairs(roomList) do
            if config.redpack_ground == 1 then
                roomConfig = config
                break
            end
        end
        if roomConfig then
            local minLimitMoney = tonumber(roomConfig.min_money)
            if GameManager.UserData.money < minLimitMoney then
                GameManager.TopTipManager:showTopTip(T("金币不足无法进入!"))
            else
                GameManager.ServerManager:getFishingRoomAndLogin(roomConfig.level)
            end
        else
            GameManager.TopTipManager:showTopTip(T("没有找到相应配置!"))
        end
    end)
end

-- 斗地主选场点击事件
function MainHall:onNormalItemClick(index)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.CHOOSEROOM_TYPE, 0)
    self.curChooseRoomType = MainHall.ChooseRoomType.normal
    self:getNormalRoomAndLogin(index)
end

-- 娱乐场选场点击事件
function MainHall:onHappyItemClick(index)
    UnityEngine.PlayerPrefs.SetInt(DataKeys.CHOOSEROOM_TYPE, 1)
    self.curChooseRoomType = MainHall.ChooseRoomType.happy
    if index == 1 then
        self:getNiuniuRoomAndLogin()
    elseif index == 2 then
        self:getSlotsRoomAndLogin()
    end
end

-- 捕鱼场选场点击事件
function MainHall:onFishItemClick(index)
    self.curChooseRoomType = MainHall.ChooseRoomType.fish
    self:getFishRoomAndLogin(index)
end

function MainHall:onRedpacketFishItemClick()
    GameManager.ChooseRoomManager:getFishRoomList(function()    
        self.curChooseRoomType = MainHall.ChooseRoomType.fish
        self:getRedPacketFishRoomAndLogin()
    end)
end

function MainHall:onNormalQuickStartClick()
    --[[快速开始]]
    GameManager.ChooseRoomManager:getNormalRoomList(function()
        GameManager.ServerManager:getNormalRoomAndLogin()
    end)
end

--[[
    @desc: 破产倒计时相关
    author:{author}
    time:2018-09-14 11:10:00
    --@lastTime: 倒计时时间
    @return:
]]
function MainHall:onTimerStart(lastTime)
    
    show(self.BrokenTime)
    self.lastTime = lastTime
    local time = formatTimerForHour(self.lastTime)
    self.BrokenTime:setText(T("倒计时")..time)
    
    if self.timer then
		self:onTimerEnd()
    end

    self.timer = Timer.New(function()
        self:onTimer()
    end,1,-1,true)
    self.timer:Start()
end

function MainHall:onTimer()
    self.lastTime = self.lastTime - 1

    if self.lastTime == 0 then
        self:onTimerEnd()
        self.BrokenTime:SetActive(false)
    else
        local time = formatTimerForHour(self.lastTime)
        self.BrokenTime:setText(T("倒计时")..time)
    end
end

function MainHall:onTimerEnd()
    
    if self.timer then
		self.timer:Stop()
	end
end

function MainHall:setShowState()
    
    print("setShowState")
end

function MainHall:playShowAnim()
    
    self:normalIconLoopAnimation(MainHall.IconList.iconFirstPay)
    print("playShowAnim")
    Timer.New(function()
        if self.controller_.reloginTableId then
            local gameId = GameManager.GameFunctions.getGameIdFormTableId(self.controller_.reloginTableId)
            if gameId == CONSTS.GAME_ID.SLOTS then
                GameManager.ChooseRoomManager:getSlotsConfig(function()
                    GameManager.ServerManager:loginRoom(self.controller_.reloginTableId)
                    self.controller_.reloginTableId = nil
                end)
            elseif gameId == CONSTS.GAME_ID.LANDLORDS then
                GameManager.ChooseRoomManager:getNormalRoomList(function()
                    GameManager:enterScene("RoomScene", {data = self.controller_.reloginTableId, roomType = CONSTS.ROOM_TYPE.LANDLORDS})
                    self.controller_.reloginTableId = nil
                end)
            elseif gameId == CONSTS.GAME_ID.NIUNIU then
                GameManager.ChooseRoomManager:getNiuniuConfig(function()
                    GameManager.ServerManager:loginRoom(self.controller_.reloginTableId)
                    self.controller_.reloginTableId = nil
                end)
            elseif gameId == CONSTS.GAME_ID.DOUNIU then
                GameManager.ChooseRoomManager:getDouniuConfig(function()
                    GameManager:enterScene("RoomScene", {data = self.controller_.reloginTableId, roomType = CONSTS.ROOM_TYPE.DOUNIU})
                    self.controller_.reloginTableId = nil
                end)
            elseif gameId == CONSTS.GAME_ID.FISHING then
                GameManager.ChooseRoomManager:getFishRoomList(function()
                    GameManager:enterScene("RoomScene", {data = self.controller_.reloginTableId, roomType = CONSTS.ROOM_TYPE.FISHING})
                    self.controller_.reloginTableId = nil
                end)
            else
                GameManager.ChooseRoomManager:updateRoomList(function()
                    GameManager.ServerManager:loginRoom(self.controller_.reloginTableId)
                    self.controller_.reloginTableId = nil
                end)
            end
        else
            self.isPlayShowAnimDone = true
            self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-90,0))

            -- 添加数据观察期
            -- 大厅需要检测到1姓名，2头像（性别），3钱，4等级，5装扮
            -- TODO 红包券监视器
            self.registerProps = {"name", "msex", "micon", "money", "exp", "jewel", "viplevel", "diamond"}
            self.registerHandleIds = {}
            for i = 1, #self.registerProps do
                local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handler(self, self.reflushPlayInfo))
                table.insert(self.registerHandleIds, handleId)
            end

            if GameManager.GameConfig.push_activity ~= 0 then
                local PanelActivity = import("Panel.Activity.PanelActivity").new(GameManager.GameConfig.push_activity)
                GameManager.GameConfig.push_activity = 0
            end

            if GameManager.UserData.register_reward_status == 1 then
                local PanelRegReward = import("Panel.Operation.PanelRegReward").new()
            end

            if GameManager.UserData.login_reward_status == 1 then
                local PanelLoginReward = import("Panel.Operation.PanelLoginReward").new()
            end

            local loginModel = UnityEngine.PlayerPrefs.GetString(DataKeys.LOGIN_MODEL)

            if loginModel == "BACK" then
                if GameManager.ODialogManager.judegeIsBankrupt() then
                    GameManager.ODialogManager:showBankruptDialogs()
                end
            end

            http.getPromotionFirstBag(
                function(callData)
                    
                    if callData and callData.flag == 1 then
                        for i = 1, 3 do
                            if callData.data.list and callData.data.list[i].status == 1 then
                                MainHall.IconList.iconFirstPay:SetActive(true)
                            end
                        end
                    end
                end,
                function(callData)
                    
                    GameManager.TopTipManager:showTopTip(T("领取失败"))
                end
            )

            -- 检查红点
            http.checkRedDot(
                function(callData)
                    
                    GameManager.GameFunctions.refashRedDotData(callData)
                    if self.redDotManager then
                        self:redDotManager()
                    end
                end,
                function (callData)
                    
                end
            )

            UnityEngine.PlayerPrefs.SetString(DataKeys.LOGIN_MODEL,"BACK")
        end
    end, self.animTime, 1, true):Start()
end

function MainHall:redDotManager()
    
    if next(GameManager.UserData.redDotData) == nil then
        return
    end

    if GameManager.UserData.redDotData and self.redDotofUI and self.view then
        local redDotData = GameManager.UserData.redDotData
        self.redDotofUI[MainHall.REDDOTKEY.MESSAGE]:SetActive(redDotData.message.dot == 1 and true or false)
		self.redDotofUI[MainHall.REDDOTKEY.FRIEND]:SetActive(redDotData.friend.dot == 1 and true or false)
		self.redDotofUI[MainHall.REDDOTKEY.FREE]:SetActive(redDotData.free.dot == 1 and true or false)
		self.redDotofUI[MainHall.REDDOTKEY.ACTIVITY]:SetActive(redDotData.activity.dot == 1 and true or false)
		self.redDotofUI[MainHall.REDDOTKEY.TASK]:SetActive(redDotData.task.dot == 1 and true or false)
		self.redDotofUI[MainHall.REDDOTKEY.CAISHEN]:SetActive(redDotData.wealthGod.dot == 1 and true or false)
    end
end

function MainHall:exitSceneAnimation(completeCallback)
    if self.NoticeManager then
        self.NoticeManager:onClean()
    end
    -- 退场动画
    self:onCleanUp()
    completeCallback()
end

function MainHall:onCleanUp()
    
    self:onTimerEnd()
    GameManager.SoundManager.currentBGMName = ""
    if self.registerHandleIds then
	    for i = 1, #self.registerHandleIds do
	    	local handleId = self.registerHandleIds[i]
	    	GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handleId)
	    end
	    self.registerHandleIds = nil
    end
end

return MainHall