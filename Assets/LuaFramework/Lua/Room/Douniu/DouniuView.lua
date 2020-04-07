local DouniuView           = class("DouniuView")
local DouniuController     = require("Room.Douniu.DouniuController")
local DouniuModel          = require("Room.Douniu.DouniuModel")
local PanelOtherInfoBig    = require("Panel.PlayInfo.PanelOtherInfoBig")
-- local PanelShop            = require("Panel.Shop.PanelShop")
local PanelShop            = require("Panel.Shop.PanelNewShop")--require("Panel.Shop.PanelSmallShop")
local PanelExchange        = require("Panel.Shop.PanelSmallShop")--require("Panel.Exchange.PanelExchange")
local PanelTask            = require("Panel.Task.PanelTask")
local Card                 = require("Room.Landlords.Card")
local LandlordsAnimation   = require("Room.Landlords.LandlordsAnimation")
local InteractiveAnimation = require("Room.InteractiveAnimation")
local PanelLandLordsHelper = require("Panel.Special.PanelLandLordsHelper")
DouniuView.Consts = {
    SeatCount      = 5,
    SelfSeatIndex  = 5,
    CardCount      = 5,
    BetButtonCount = 4,
    IntervalIndex  = 3,
    CountCount     = 3,
    ChipCount      = 40,
    RandomAera     = 60,
    RandomAngle    = 60,
    CardType = {
        Hide = 1,
        Deal = 2,
        Back = 3,
        Hand = 4,
        Show = 5,
    },
    Time = {
        Deal          = 0.7,
        DealInterval  = 0.05,
        FilpFront     = 0.15,
        Banker        = 0.5,
        RandomLoop    = 1.5,
        ChipMove      = 0.5,
        ChipDelay     = 0.01,
        ChipText      = 1.5,
        ChipMoveDelay = 0.3,
    },
}

DouniuView.CardConfig = {
    [DouniuView.Consts.CardType.Hide] = {
        offset = 0,
        scale  = 0.46,
    },
    [DouniuView.Consts.CardType.Deal] = {
        offset = 0,
        scale  = 0.46,
    },
    [DouniuView.Consts.CardType.Back] = {
        offset = 33,
        scale  = 0.46,
    },
    [DouniuView.Consts.CardType.Hand] = {
        offset  = 153,
        offsetY = -20,
        scale   = 0.8,
    },
    [DouniuView.Consts.CardType.Show] = {
        offset = 33,
        scale  = 0.46,
        interval = 10,
    },
}

DouniuView.LoopConfig = {
    [2] = 12,
    [3] = 18,
    [4] = 24,
    [5] = 30,
}

--[[
        1   2
    3           4
        5
]]
DouniuView.SeatPos = {
    {   
        view   = {pos = Vector3.New(74, 0, 0), anchors = Vector2.New(0, 0.5)},
        bet    = {pos = Vector3.New(133, 50, 0), pivot = Vector2.New(0, 0.5)},
        arrow  = {pos = Vector3.New(68.5, 50, 0), rotation = Vector3.New(0, 0, -180)},
        bubble = {pos = Vector3.New(120.5, 35, 0), pivot = Vector2.New(0.5, 1)},
        card   = {pos = Vector3.New(205, -25, 0)},
    },
    {
        view   = {pos = Vector3.New(168, 186, 0), anchors = Vector2.New(0, 0.5)},
        bet    = {pos = Vector3.New(133, 50, 0), pivot = Vector2.New(0, 0.5)},
        arrow  = {pos = Vector3.New(68.5, 50, 0), rotation = Vector3.New(0, 0, -180)},
        bubble = {pos = Vector3.New(120.5, 35, 0), pivot = Vector2.New(0.5, 1)},
        card   = {pos = Vector3.New(205, -25, 0)},
    },
    {   
        view   = {pos = Vector3.New(-168, 186, 0), anchors = Vector2.New(1, 0.5), },
        bet    = {pos = Vector3.New(-133, 50, 0), pivot = Vector2.New(1, 0.5)},
        arrow  = {pos = Vector3.New(-68.5, 50, 0), rotation = Vector3.New(0, 0, 0)},
        bubble = {pos = Vector3.New(-120.5, 35, 0), pivot = Vector2.New(0.5, 1)},
        card   = {pos = Vector3.New(-205, -25, 0)},
    },
    {   
        view   = {pos = Vector3.New(-74, 0, 0), anchors = Vector2.New(1, 0.5)},
        bet    = {pos = Vector3.New(-133, 50, 0), pivot = Vector2.New(1, 0.5)},
        arrow  = {pos = Vector3.New(-68.5, 50, 0), rotation = Vector3.New(0, 0, 0)},
        bubble = {pos = Vector3.New(-120.5, 35, 0), pivot = Vector2.New(0.5, 1)},
        card   = {pos = Vector3.New(-205, -25, 0)},
    },
    {       
        view   = {pos = Vector3.New(168, -186, 0), anchors = Vector2.New(0, 0.5)},
        bet    = {pos = Vector3.New(0, 94, 0), pivot = Vector2.New(0.5, 0.5)},
        arrow  = {pos = Vector3.New(0, 78, 0), rotation = Vector3.New(0, 0, -90)},
        bubble = {pos = Vector3.New(98, 4.5, 0), pivot = Vector2.New(0.5, 0)},
        card   = {pos = Vector3.New(472, 24, 0)},
    },
}


function DouniuView:ctor(controller, objs, data)
    self.controller_ = controller
    self.model = controller.model
    local animationName = {
        LandlordsAnimation.Animation.Lose.prefab,
        LandlordsAnimation.Animation.Normal.prefab,
        LandlordsAnimation.Animation.Special.prefab,}
    self.animation = LandlordsAnimation.new(animationName)
    self.interactiveAnimation = InteractiveAnimation.new()
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "DouniuView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view:scale(Vector3.one)
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    
    self:onEnter()
    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()
end

function DouniuView:onEnter()
    GameManager.SoundManager:playSomething()
    GameManager.SoundManager:ChangeBGM("niuniu/bg")
end


function DouniuView:initProperties(objs)
    self.chipPrefab      = objs[1]
    self.allSeats        = {}
    self.uidSeats        = {}
    self.betItems        = {}
    self.countTexts      = {}
    self.selectedCard    = {}
    self.chipAreas       = {}
    self.hddjSeats       = {}
    self.canSelectCard   = false
    self.isLoose         = false
end

function DouniuView:initUIControls()
    self:initTopViewAndTableInfoControls()
    self:initStartViewControls()
    self:initClockViewControls()
    self:initSeatViewControls()
    self:initActionViewControls()
    self:initBottomViewControls()
    self:initChipChangeViewControls()
    self:initHDDJViewControls()
    -- 监听数据变化
    self:addPropertyObserver()
end

function DouniuView:initUIDatas()
    
end

function DouniuView:onCleanUp()
    if self.registerHandleIds then
	    for i = 1, #self.registerHandleIds do
	    	local handleId = self.registerHandleIds[i]
	    	GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handleId)
	    end
	    self.registerHandleIds = nil
    end

    if self.timeTimer then
        self.timeTimer:Stop()
        self.timeTimer = nil
    end

    destroy(self.view)
    self.view = nil
end

function DouniuView:addPropertyObserver()
    self.registerProps = {"money", "jewel"}
    self.registerHandleIds = {}
    for i = 1, #self.registerProps do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handler(self, self.refreshSelfPlayerInfo))
        table.insert(self.registerHandleIds, handleId)
    end
end

function DouniuView:refreshSelfPlayerInfo()
    self:updataBottomInfoDatas()
    local selfData = GameManager.GameFunctions.getUserInfo()
    selfData.seatIndex = DouniuView.Consts.SelfSeatIndex
    self.allSeats[DouniuView.Consts.SelfSeatIndex]:setData(selfData)
end

--[[
    method
]]

function DouniuView:getSelfSeatIndex()
    return DouniuView.Consts.SelfSeatIndex
end

function DouniuView:setSeatIndexToSeatData(player)
    player.seatIndex = self.uidSeats[player.uid].data.seatIndex
end

--[[
    顶上控件 -- 以及桌子相关
]]

function DouniuView:initTopViewAndTableInfoControls()
    self.tableInfo   = self.view:findChild("bg/tableInfoText")
    self.topView     = self.view:findChild("topView")
    self.backButton  = self.view:findChild("topView/backButton")
    self.ruleButton  = self.view:findChild("topView/ruleButton")
    self.taskButton  = self.view:findChild("topView/taskButton")
    self.hongbaoButton  = self.view:findChild("topView/hongbaoButton")
    self.taskRedDot  = self.view:findChild("topView/taskButton/redDot")
    self.hongbaoRedDot  = self.view:findChild("topView/hongbaoButton/redDot")
    self.wifiIcon    = self.view:findChild("topView/wifiView/wifiIcon")
    self.timeText    = self.view:findChild("topView/wifiView/Text")

    self.backButton:addButtonClick(buttonSoundHandler(self, self.onBackButtonClick), false)
    self.taskButton:addButtonClick(buttonSoundHandler(self, self.onTaskButtonClick), false)
    self.hongbaoButton:addButtonClick(buttonSoundHandler(self, self.onHongbaoButtonClick), false)
    self.ruleButton:addButtonClick(buttonSoundHandler(self, self.onRuleButtonClick), false)

    self.timeTimer = Timer.New(function()
        self:updateTimeAndWifi()
    end, 10, 999,true)
    self:updateTimeAndWifi()
    self.timeTimer:Start()
    
    self:showHongbaoRedDot(false)
    self:showTaskRedDot(false)

    self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-16,0))

    if GameManager.GameConfig.casinoWin == 1 then
        self.hongbaoButton:SetActive(true)
    else
        self.hongbaoButton:SetActive(false)
    end
end

function DouniuView:updateTimeAndWifi()
    if not self.timeTimer then
        return
    end
    self.timeText:GetComponent('Text').text = os.date("%H:%M", os.time())

    local wifiIconImageName = ""
    if Util.NetAvailable then
        if Util.IsWifi then
            wifiIconImageName = "Images/common/wifi_icon_1"
        else
            wifiIconImageName = "Images/common/wifi_icon_3"
        end
    else
        wifiIconImageName = "Images/common/wifi_icon_4"
    end
    self.wifiIcon:setSprite(wifiIconImageName)
end

function DouniuView:showTaskRedDot(isShow)
    showOrHide(isShow, self.taskRedDot)
end

function DouniuView:showHongbaoRedDot(isShow)
    showOrHide(isShow, self.hongbaoRedDot)
end

function DouniuView:showTableInfoText(text)
    self.tableInfo:setText(text)
end

--[[
    时钟相关
]]

function DouniuView:initClockViewControls()
    self.clockView = self.view:findChild("clockView")
    self.clock     = self.view:findChild("clockView/clock")
    self.clockText = self.view:findChild("clockView/clock/Text")
    self.clockTips = self.view:findChild("clockView/Text")

    self:showClock(false)
end

function DouniuView:showClock(isShow, countTime, tipsFormat)
    if self.clockTimer then
        self.clockTimer:Stop()
        self.clockTimer = nil
    end

    -- 判断当前是不是发牌阶段 如果是的话 就等待发牌结束才显示
    if self.model.tableInfo and self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL then
        -- 延时时间是 开场动画时间 + 发牌时间 + 2倍的 90°翻牌时间
        showOrHide(false, self.clockView)
        Timer.New(function()
            show(self.clockView)
        end, self.startDuration + DouniuView.Consts.Time.Deal + 2 * DouniuView.Consts.Time.FilpFront, 1, true):Start()
    elseif self.model.tableInfo and self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL then
        showOrHide(false, self.clockView)
        Timer.New(function()
            show(self.clockView)
        end, 3, 1, true):Start()
    else
        showOrHide(isShow, self.clockView)
    end

    if countTime and countTime > 0 then
        show(self.clock)
        self.clockTips:setText(string.format(tipsFormat, countTime))
        self.clockText:setText(countTime)
        self.clockTimer = Timer.New(function()
            if not self.view or not self.clockText then
                return
            end

            countTime = countTime - 1
            self.clockText:setText(countTime)
            self.clockTips:setText(string.format(tipsFormat, countTime))
            
            -- if countTime <= 3 then
            --     GameManager.SoundManager:PlaySoundWithNewSource("sound_remind")
            -- end

            if countTime == 0 then
                self:onClockTimeOver()
                self:showClock(false)
            end
        end,1,countTime,true)
        self.clockTimer:Start()
    else
        if countTime and countTime < 0 then
            countTime = 0
        end
        hide(self.clock)
        if tipsFormat then
            self.clockTips:setText(string.format(tipsFormat, countTime))
        end
    end
end

--[[
    游戏开始动画相关
]]

function DouniuView:initStartViewControls()

    function getAnimation(view, itemName)
        local UnityArmatureComponent = view:GetComponent('UnityArmatureComponent')
        local Animation              = UnityArmatureComponent.animation
        local AnimationData          = Animation.animations:get_Item(itemName)
        local duration               = AnimationData.duration
        return Animation, duration
    end

    self.startView        = self.view:findChild("startView")
    self.startDragonBones = self.view:findChild("startView/MovieClip")
    self.startAnimation, self.startDuration = getAnimation(self.startDragonBones, "newAnimation")
    hide(self.startView)

    self.winView        = self.view:findChild("winView")
    self.winDragonBones = self.view:findChild("winView/fla_winner_4")
    self.winInfoText    = self.view:findChild("winView/infoText")
    self.winAnimation, self.winDuration = getAnimation(self.winDragonBones, "play")
    hide(self.winView)

    self.bigWinView        = self.view:findChild("bigWinView")
    self.bigWinDragonBones = self.view:findChild("bigWinView/fla_winner_4")
    self.bigWinInfoText    = self.view:findChild("bigWinView/infoText")
    self.bigWinAnimation, self.bigWinDuration = getAnimation(self.bigWinDragonBones, "play")
    hide(self.bigWinView)
end

function DouniuView:playStartAnimation(callback)
    show(self.startView)
    GameManager.SoundManager:PlaySoundWithNewSource("douniu/gameStart")
    self.startAnimation:Play("newAnimation")
    Timer.New(function()
        hide(self.startView)
        if callback then
            callback()
        end
    end, self.startDuration, 0, true):Start()
end

function DouniuView:playWinAnimation(callback, money)
    show(self.winView)
    GameManager.SoundManager:PlaySoundWithNewSource("win")
    self.winAnimation:Play("play")
    self.winInfoText:setText(money)
    doFadeAutoShow(self.winInfoText, 'Text', self.bigWinDuration * 0.5, 0)
    Timer.New(function()
        hide(self.winView)
        if callback then
            callback()
        end
    end, self.winDuration, 0, true):Start()
end

function DouniuView:playBigWinAnimation(callback, money)
    show(self.bigWinView)
    GameManager.SoundManager:PlaySoundWithNewSource("win")
    self.bigWinAnimation:Play("play")
    self.bigWinInfoText:setText(money)
    doFadeAutoShow(self.bigWinInfoText, 'Text', self.bigWinDuration * 0.5, 0)
    Timer.New(function()
        hide(self.bigWinView)
        if callback then
            callback()
        end
    end, self.bigWinDuration, 0, true):Start()
end

--[[
    座位相关
]]

function DouniuView:initSeatViewControls()
    self.seatView = self.view:findChild("seatView")
    for index = 1, DouniuView.Consts.SeatCount do
        local seat = {}
        seat.view           = self.seatView:findChild(string.format("seat (%d)",index))
        seat.normalBg       = seat.view:findChild("normalBg")
        seat.highlightBg    = seat.view:findChild("highlightBg")
        seat.playerView     = seat.view:findChild("playerView")
        seat.headerButton   = seat.view:findChild("playerView/headerButton")
        seat.frameImage     = seat.view:findChild("playerView/headerButton/frameImage")
        seat.nameText       = seat.view:findChild("playerView/nameText")
        seat.moneyText      = seat.view:findChild("playerView/moneyText")
        seat.playingView    = seat.view:findChild("playingView")
        seat.banker         = seat.view:findChild("playingView/banker")
        seat.betImage       = seat.view:findChild("playingView/betImage")
        seat.betText        = seat.view:findChild("playingView/betText")
        seat.chatBubble     = seat.view:findChild("playingView/chatBubble")
        seat.chatArrow      = seat.view:findChild("playingView/chatBubble/arrowImage")
        seat.chatBg         = seat.view:findChild("playingView/chatBubble/bubbleImage")
        seat.chatText       = seat.view:findChild("playingView/chatBubble/bubbleImage/Text")
        seat.chipChangeText = seat.view:findChild("playingView/chipChangeText")
        seat.cardView       = seat.view:findChild("playingView/cardView")
        seat.cardTypeAni    = seat.view:findChild("playingView/cardView/cardTypeAnimation")
        seat.cardTypeImage  = seat.view:findChild("playingView/cardView/cardTypeImage")
        seat.emptyView      = seat.view:findChild("emptyView")
        seat.index          = index
        seat.cards = {}

        for j = 1, DouniuView.Consts.CardCount do
            local card = {}
            card.view           = seat.cardView:findChild(string.format("card (%s)", j))
            card.backImage      = card.view:findChild("backImage")
            card.frontImage     = card.view:findChild("frontImage")
            card.numberImage    = card.view:findChild("frontImage/numberImage")
            card.bigTypeImage   = card.view:findChild("frontImage/bigTypeImage")
            card.smallTypeImage = card.view:findChild("frontImage/smallTypeImage")
            card.isFront        = nil
            card.isSelect       = nil
            card.frontImage:addButtonClick(buttonSoundHandler(self, function()
                if card.isFront and self.canSelectCard then
                    self:onCardClick(j)
                end
            end), false)
            seat.cards[#seat.cards + 1] = card
        end

        seat.headerButton:addButtonClick(buttonSoundHandler(self, function()
            if not seat.data then
                return
            end
            local PanelOtherInfoBig = PanelOtherInfoBig.new(seat.data.uid, function(index)
                local times = 1
                http.useToolProp(
                    times,   
                    function(callData)
                        if callData and callData.flag == 1 then
                            GameManager.ServerManager:sendProp(index, seat.data.seatId, times)
                            GameManager.UserData.money = callData.latest_money
                        else
                            GameManager.TopTipManager:showTopTip(T("发送失败"))
                        end
                    end,
                    function(errData)
                        GameManager.TopTipManager:showTopTip(T("发送失败"))
                    end
                )
            end)
        end), false)

        seat.setData = function(seat, data)
            -- 根据数据放到uid数组里面去
            if seat.data then
                self.uidSeats[seat.data.uid] = nil
            end
            if data then
                data.seatIndex = seat.index
                self.uidSeats[data.uid] = seat
            end

            seat.data = data
            if data then
                show(seat.playerView)
                show(seat.playingView)
                hide(seat.emptyView)
                seat.moneyText:setText(formatFiveNumber(data.money))
                seat.nameText:setText(data.name)
                if data.viplevel and data.viplevel > 0 then
                    show(seat.frameImage)
                    seat.frameImage:setSprite(GameManager.ImageLoader:getVipFrame(data.viplevel))
                end
                GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                    url = data.mavatar,
                    sex = tonumber(data.msex),
                    node = seat.headerButton,
                    callback = function(sprite)
                        if self.view and seat.headerButton then
                            seat.headerButton:setSprite(sprite)
                        end
                    end,
                })
            else
                hide(seat.playerView)
                show(seat.emptyView)
            end
        end

        seat.reset = function(seat)
            seat:setCardType(DouniuView.Consts.CardType.Hide)
            seat:showBetView(false)
            seat:showBankerIcon(false)
            seat:showCardType(false)
            self.selectedCard = {}
            for index, card in ipairs(seat.cards) do
                card.isSelect = false
            end
            if seat.animation then
                destroy(seat.animation)
                seat.animation = nil
            end
            seat.headerButton.transform:GetComponent('Image').color = Color.white
            seat.cardTypeAni:removeAllChildren()
        end

        seat.showCardType = function(seat, isShow, cardType)
            if seat.animation then
                destroy(seat.animation)
                seat.animation = nil
            end
            showOrHide(isShow, seat.cardTypeAni)
            showOrHide(isShow, seat.cardTypeImage)
            if not isShow then
                return
            end
            local params = {parent = seat.cardTypeAni}
            params.dontDestroy = true
            local type = 0
            if cardType == 0 then
                type = LandlordsAnimation.Animation.Lose
            elseif cardType > 0 and cardType < DouniuModel.SpecialCardType.DoubleTen then
                type = LandlordsAnimation.Animation.Normal
            elseif cardType >= DouniuModel.SpecialCardType.DoubleTen then
                type = LandlordsAnimation.Animation.Special
            end
            seat.animation = self.animation:playAnimation(type, params)
            seat.cardTypeImage:setSprite(string.format("Images/SceneDouniu/text_%s", cardType))
            GameManager.SoundManager:PlaySoundWithNewSource("niuniu/niu_"..cardType)
        end

        seat.showBetView = function(seat, isShow, state, type)
            if not isShow then
                hide(seat.betImage)
                hide(seat.betText)
                return
            end
            if state == CONSTS.DOUNIU.USER_STATE.CALL then
                show(seat.betImage)
                hide(seat.betText)
                local imagePath = "Images/SceneDouniu/image_call_"..type
                seat.betImage:setSprite(imagePath)
            elseif state == CONSTS.DOUNIU.USER_STATE.BET then
                hide(seat.betImage)
                show(seat.betText)
                -- 这里的type 是用来text的下标的
                seat.betText:setText("x"..type)
            end
        end

        seat.setChatText = function(seat, text)
            show(seat.chatBubble)
            seat.chatText:setText(text)
            local preferredHeight = seat.chatText.transform:GetComponent('Text').preferredHeight + 10
            seat.chatBg.transform.sizeDelta = Vector2.New(seat.chatBg.transform.sizeDelta.x, preferredHeight)
            Timer.New(function()
                hide(seat.chatBubble)
            end,3,1,true):Start()
        end

        seat.showBankerIcon = function(seat, isShow)
            if not isShow then
                hide(seat.highlightBg)
                hide(seat.banker)    
                return 
            end
            show(seat.highlightBg)
            show(seat.banker)
            seat.banker.transform.localScale = Vector3.New(0.1, 0.1, 1)
            local scaleAnimation = seat.banker.transform:DOScale(Vector3.New(1, 1, 1), DouniuView.Consts.Time.Banker)
            scaleAnimation:SetEase(DG.Tweening.Ease.OutBounce)
            if isShow then
                GameManager.SoundManager:PlaySoundWithNewSource("douniu/banker")
            end
        end

        seat.getCardTypePosition = function(seat, type, index)
            local config = DouniuView.CardConfig[type]
            if type ~= DouniuView.Consts.CardType.Deal then
                local mid = math.ceil(DouniuView.Consts.CardCount * 0.5)
                local offset = index - mid
                local interval = 0
                if index > DouniuView.Consts.IntervalIndex then
                    interval = config.interval or 0
                end
                local offsetY = config.offsetY or 0
                return Vector3.New(offset * config.offset + interval, offsetY, 0)
            else
                local seatConfig = DouniuView.SeatPos[seat.index]
                local w, h = getScreenSize()
                local px, py = seat.cardView.transform.localPosition.x, seat.cardView.transform.localPosition.y
                local x = (seatConfig.view.pos.x + px) * -1 + w * 0.5 * (seatConfig.view.pos.x < 0 and -1 or 1)
                local y = (seatConfig.view.pos.y + py) * -1
                return Vector3.New(x, y)
            end
        end

        seat.showCardBack = function(seat, index)
            local card = seat.cards[index]
            card.isFront = false
            show(card.backImage)
            hide(card.frontImage)
        end

        seat.showCardFront = function(seat, index)
            local card = seat.cards[index]
            card.isFront = true
            show(card.frontImage)
            hide(card.backImage)
        end

        seat.setCardData = function(seat, index, data)
            local card = seat.cards[index]
            card.cardClass = Card.new(data)
            card.smallTypeImage:setSprite(card.cardClass.imagePaths.small)
            card.bigTypeImage:setSprite(card.cardClass.imagePaths.big)
            card.numberImage:setSprite(card.cardClass.imagePaths.number)
        end

        seat.setCardType = function(seat, type, data, isAnimation)
            showOrHide(type ~= DouniuView.Consts.CardType.Hide, seat.cardView)
            local config = DouniuView.CardConfig[type]

            local cardValues = data and data.cards or nil
            local cardType   = data and data.cardType or nil

            for index, card in ipairs(seat.cards) do
                if cardValues and cardValues[index] then
                    seat:setCardData(index, cardValues[index])
                end
                local pos = seat:getCardTypePosition(type, index)
                -- 默认没有动画的代码
                local noAnimationFunction = function()
                    card.view.transform.localScale = Vector3.New(config.scale, config.scale, 0)
                    card.view.transform.localPosition = pos
                end
                if type == DouniuView.Consts.CardType.Deal then
                    seat:showCardBack(index)
                    noAnimationFunction()
                elseif type == DouniuView.Consts.CardType.Back then
                    seat:showCardBack(index)
                    if isAnimation then
                        local currentPos = seat:getCardTypePosition(DouniuView.Consts.CardType.Deal, index)
                        local aimPos = seat:getCardTypePosition(DouniuView.Consts.CardType.Back, index)
                        card.view.transform.localPosition = currentPos
                        Timer.New(function()
                            local moveAnimation = card.view.transform:DOLocalMove(aimPos, DouniuView.Consts.Time.Deal)
                            moveAnimation:SetEase(DG.Tweening.Ease.OutQuart)
                        end, DouniuView.Consts.Time.DealInterval * index, 1, true):Start()
                    else
                        noAnimationFunction()
                    end
                elseif type == DouniuView.Consts.CardType.Hand 
                or type == DouniuView.Consts.CardType.Show then
                    -- 判断是否需要动画 
                    if isAnimation then
                        card.view.transform:DOScale(Vector3.New(config.scale, config.scale, 0), DouniuView.Consts.Time.FilpFront * 2)
                        local moveAnimation = card.view.transform:DOLocalMove(pos, DouniuView.Consts.Time.FilpFront * 2)
                        if type == DouniuView.Consts.CardType.Show and cardType then
                            moveAnimation:OnComplete(function()
                                if index == #seat.cards then
                                    seat:showCardType(true, cardType)
                                end
                            end)
                        end

                        -- 是否有数据 是否数据里有他的数据 是否当前是前景图了
                        if cardValues and cardValues[index] and not card.isFront then
                            local sequence = DG.Tweening.DOTween.Sequence()
                            local flipBackAction = card.view.transform:DOLocalRotate(Vector3.New(0,90,0), DouniuView.Consts.Time.FilpFront)
                            flipBackAction:OnComplete(function()
                                seat:showCardFront(index)
                            end)
                            sequence:Append(flipBackAction)
                            sequence:Append(card.view.transform:DOLocalRotate(Vector3.New(0,0,0), DouniuView.Consts.Time.FilpFront))
                            if type == DouniuView.Consts.CardType.Show and cardType then
                                sequence:OnComplete(function()
                                    if index == #seat.cards then
                                        seat:showCardType(true, cardType)
                                    end
                                end)
                            end
                        end
                    else
                        if cardValues and cardValues[index] and not card.isFront then
                            seat:showCardFront(index)
                            card.view.transform.localEulerAngles = Vector3.zero
                        end
                        noAnimationFunction()
                        if type == DouniuView.Consts.CardType.Show and cardType then
                            if index == #seat.cards then
                                seat:showCardType(true, cardType)
                            end
                        end
                    end
                end
            end
        end

        seat.showChipChangeText = function(seat, addMoney)
            local originPos = seat.chipChangeText.transform.localPosition
            local format = "<color=#FFFF00>+%d</color>"
            if addMoney < 0 then
                format = "<color=#999999>%d</color>"
            end
            show(seat.chipChangeText)
            seat.chipChangeText:setText(string.format(format, addMoney))
            seat.chipChangeText.transform:DOLocalMoveY(originPos.y + 30, DouniuView.Consts.Time.ChipText / 3)
            Timer.New(function()
                seat.chipChangeText.transform.localPosition = originPos
                hide(seat.chipChangeText)
            end, DouniuView.Consts.Time.ChipText, 1, true):Start()
        end

        self.allSeats[#self.allSeats + 1] = seat

        local posConfig = DouniuView.SeatPos[index]
        -- 如果在panel上就已经设置好位置的话 就不需要设置pos
        seat.view.transform.localPosition = posConfig.view.pos
        -- 设置与父控件的对齐方式 
        seat.view.transform:GetComponent('RectTransform').anchorMin = posConfig.view.anchors
        seat.view.transform:GetComponent('RectTransform').anchorMax = posConfig.view.anchors
        -- 设置操作显示
        seat.betImage.transform.localPosition = posConfig.bet.pos
        seat.betImage.transform:GetComponent('RectTransform').pivot = posConfig.bet.pivot

        seat.betText.transform.localPosition = posConfig.bet.pos
        seat.betText.transform:GetComponent('RectTransform').pivot = posConfig.bet.pivot
        -- 设置聊天气泡
        seat.chatBubble.transform.localPosition   = posConfig.arrow.pos
        seat.chatArrow.transform.localEulerAngles = posConfig.arrow.rotation
        seat.chatBg.transform.localPosition       = posConfig.bubble.pos
        seat.chatBg.transform:GetComponent('RectTransform').pivot = posConfig.bubble.pivot

        if index ~= self:getSelfSeatIndex() then
            self:seatStandUp(index)
            -- 设置其他玩家手牌位置手牌
            seat.cardView.transform.localPosition = fitX(posConfig.card.pos)
        else
            -- 自己的手牌 需要居中
            local w, h = getScreenSize()
            seat.cardView.transform.localPosition = Vector3.New(w * 0.5 - posConfig.view.pos.x, posConfig.card.pos.y)
            local selfData = GameManager.GameFunctions.getUserInfo()
            selfData.seatIndex = DouniuView.Consts.SelfSeatIndex
            seat:setData(selfData)
        end
        seat:setCardType(DouniuView.Consts.CardType.Hide)
    end
end

function DouniuView:seatSitDown(data, isPlaying)
    
    local emptySeat = nil
    for index, seat in ipairs(self.allSeats) do
        if not seat.data then
            emptySeat = seat
            break
        end
    end
    emptySeat:setData(data)

    if isPlaying then
        self:seatGray(data)
    end 
end

function DouniuView:seatStandUp(data)
    local seatIndex = data
    if type(data) == "table" then
        local uid = data.uid
        seatIndex = self.uidSeats[uid]
        seatIndex:setData(nil)
    else
        self.allSeats[seatIndex]:setData(nil)
    end
end

function DouniuView:seatGray(player)
    local seat = self.uidSeats[player.uid]
    seat.headerButton.transform:GetComponent('Image').color = Color.New(100/255,100/255,100/255,1)
end

function DouniuView:showChatBubbleView(player, message)
    local seat = self.uidSeats[player.uid]
    seat:setChatText(message)
end

function DouniuView:dealCards(player, isAnimation)
    local seat = self.uidSeats[player.uid]

    -- 经常人没了位置
    if not seat then
        return
    end

    seat:setCardType(DouniuView.Consts.CardType.Deal, nil)
    seat:setCardType(DouniuView.Consts.CardType.Back, nil, isAnimation)
    GameManager.SoundManager:PlaySound("niuniu/send_poker")
    if player.uid == GameManager.UserData.mid then
        if isAnimation then
            -- 如果是动画的话 是需要展示callActionde
            Timer.New(function()
                GameManager.SoundManager:PlaySound("flipCard")
                seat:setCardType(DouniuView.Consts.CardType.Hand, {cards = player.cards}, isAnimation)
            end, DouniuView.Consts.Time.Deal, 1, true):Start()
            Timer.New(function()
                self:showCallAction()
            end, DouniuView.Consts.Time.Deal + DouniuView.Consts.Time.FilpFront * 2, 1, true):Start()
        else
            seat:setCardType(DouniuView.Consts.CardType.Hand, {cards = player.cards}, isAnimation)
        end
    end
end

function DouniuView:showLeftCards(player)
    local seat = self.uidSeats[player.uid]
    seat:setCardType(DouniuView.Consts.CardType.Hand, {cards = player.cards}, true)
    seat:setData(player)
end

function DouniuView:showCards(player)
    local seat = self.uidSeats[player.uid]
    seat:setCardType(DouniuView.Consts.CardType.Show, {cards = player.cards, cardType = player.curAnte}, true)
    if player.uid == GameManager.UserData.mid then
        self.canSelectCard = false
    end
end

function DouniuView:showSeatBetView(player, isShow)
    local seat = self.uidSeats[player.uid]
    if player.isBanker then
        seat:showBetView(isShow, CONSTS.DOUNIU.USER_STATE.CALL, player.curAnte)
    else
        seat:showBetView(isShow, player.userStatus, player.curAnte)
    end
end

function DouniuView:resetAllSeat(playerList)
    for index, player in pairs(playerList) do
        local seat = self.uidSeats[player.uid]
        seat:setData(player)
        if player.uid == GameManager.UserData.mid then
            GameManager.UserData.money = player.money
        end
    end
    for index, seat in ipairs(self.allSeats) do
        seat:reset()
    end
    for index, item in ipairs(self.betItems) do
        show(item.button)
    end
    self.tipsButton:GetComponent('Button').interactable = true
    self.resultImage:setSprite("Images/SceneDouniu/text_loose")
end

function DouniuView:onCardClick(index)
    local seat = self.uidSeats[GameManager.UserData.mid]
    local card = seat.cards[index]

    if self.selectedCard[index] then
        -- 把牌弄下去
        card.view.transform:DOLocalMoveY(-20, 0.2)
        self.selectedCard[index] = nil
        card.isSelect = false
    else
        local count = 0
        local result = 0
        for index, card in pairs(self.selectedCard) do
            count = count + 1
        end
        if count == 3 then
            return
        end
        card.view.transform:DOLocalMoveY(-10, 0.2)
        self.selectedCard[index] = card
        card.isSelect = true
    end
    self:showCountResultText()
end

function DouniuView:showCountResultText()
    local seat = self.uidSeats[GameManager.UserData.mid]
    local result = 0
    local textIndex = 1
    local niuResult = 0
    for index, card in ipairs(seat.cards) do
        local cardCount = card.cardClass.count
        if cardCount > 10 then
            cardCount = 10
        end
        if card.isSelect then
            show(self.countTexts[textIndex])
            self.countTexts[textIndex]:setText(card.cardClass.countName)
            if textIndex < 3 then
                hide(self.countTexts[textIndex + 1])
            end
            textIndex = textIndex + 1
            result = result + cardCount
        else
            niuResult = niuResult + cardCount
        end
    end
    showOrHide(result > 0, self.countTexts[1])
    showOrHide(result > 0, self.countResult)
    self.countResult:setText(tostring(result))

    if result % 10 == 0 and textIndex == 4 then
        self.resultImage:setSprite("Images/SceneDouniu/text_one")
        self.isLoose = false
        local nameConfig = {
            T("十带一"),
            T("十带二"),
            T("十带三"),
            T("十带四"),
            T("十带五"),
            T("十带六"),
            T("十带七"),
            T("十带八"),
            T("十带九"),
            T("双十"),
        }
        niuResult = niuResult % 10
        if niuResult == 0 then
            niuResult = 10
        end
        self.countResult:setText(nameConfig[niuResult])
    else
        self.resultImage:setSprite("Images/SceneDouniu/text_loose")
        self.isLoose = true
        if textIndex == 4 then
            self.countResult:setText(T("散牌"))
        end
    end
end

function DouniuView:showSeatBankerIcon(bankerPlayer, sameAntePlayers)
    if not sameAntePlayers or (sameAntePlayers and #sameAntePlayers == 1) then
        local seat = self.uidSeats[bankerPlayer.uid]
        seat:showBankerIcon(true)
    else
        local sameSeats = {}
        for index, player in ipairs(sameAntePlayers) do
            local seat = self.uidSeats[player.uid]
            sameSeats[#sameSeats + 1] = seat
        end
        table.sort(sameSeats, function(a, b)
            local result = a.data.seatIndex < b.data.seatIndex
            return result
        end)
        local bankerIndex = 0 -- 这个下标是轮庄动画里面的下标
        for index, seat in ipairs(sameSeats) do
            if seat.data.uid == bankerPlayer.uid then
                bankerIndex = index
                break
            end
        end

        local allCount = #sameAntePlayers
        local times = DouniuView.LoopConfig[allCount]
        local allLoop = times + bankerIndex

        local k = DouniuView.Consts.Time.RandomLoop / allLoop / (allLoop - 1)
        for index = 1, allLoop do
            local time = (index * k) * (index - 1)
            Timer.New(function()
                GameManager.SoundManager:PlaySoundWithNewSource("notice")
                local showIndex = index % allCount
                if showIndex == 0 then
                    showIndex = allCount
                end
                local lastIndex = showIndex - 1
                if lastIndex == 0 then
                    lastIndex = allCount
                end
                -- dump(sameSeats, "同样的位置有哪几个")
                -- print("这里老是报错 看看原因 总数数%d 循环下标%d 当前下标%d 上一个下标%d", allCount, index, showIndex, lastIndex)
                local lastSeat = sameSeats[lastIndex]
                if lastSeat then
                    hide(lastSeat.highlightBg)
                end
                local showSeat = sameSeats[showIndex]
                if showSeat then
                    show(showSeat.highlightBg)
                end
                -- 最后一个人的时候
                if index == allLoop then
                    Timer.New(function()
                        if showSeat then
                            showSeat:showBankerIcon(true)
                        end
                    end, DouniuView.Consts.Time.Banker, 1, true):Start()
                end
            end, time, 1, true):Start()
        end
    end
end

function DouniuView:hideOtherBetView(bankerPlayer)
    for index, seat in pairs(self.uidSeats) do
        if seat.data.uid ~= bankerPlayer.uid then
            seat:showBetView(false)
        end
    end
end

--[[
    用户操作按钮
]]

function DouniuView:initActionViewControls()
    self.actionView = self.view:findChild("actionView")
    self.betAction  = self.view:findChild("actionView/betAction")
    self.callButton = self.view:findChild("actionView/betAction/callButton")

    self.callButton:addButtonClick(buttonSoundHandler(self, function()
        self:onBetButtonClick(0)
    end), false)

    for index = 1, DouniuView.Consts.BetButtonCount do
        local item = {}
        item.button      = self.view:findChild(string.format("actionView/betAction/betButton (%d)", index))
        item.multipleTmp = item.button:findChild("allText")
        TMPHelper.setTexture(item.multipleTmp, "Face")
        TMPHelper.setTexture(item.multipleTmp, "Outline", "Images/FishingGame/fontColor/color_yellow")
        self.betItems[#self.betItems + 1] = item
        item.button:addButtonClick(buttonSoundHandler(self, function()
            self:onBetButtonClick(index)
        end), false)
    end

    self.doneAction   = self.view:findChild("actionView/doneAction")
    self.resultButton = self.view:findChild("actionView/doneAction/resultButton")
    self.resultImage  = self.view:findChild("actionView/doneAction/resultButton/Image")
    self.tipsText     = self.view:findChild("actionView/doneAction/tipsText")
    self.tipsButton   = self.view:findChild("actionView/doneAction/tipsButton")

    self.resultButton:addButtonClick(buttonSoundHandler(self, function()
        self:onResultButtonClick()
    end), false)

    self.tipsButton:addButtonClick(buttonSoundHandler(self, function()
        self:onTipsButtonClick()
    end), false)

    self.countAction = self.view:findChild("actionView/countAction")
    self.countResult = self.view:findChild("actionView/countAction/Text")

    for index = 1, DouniuView.Consts.CountCount do
        self.countTexts[#self.countTexts + 1] = self.view:findChild(string.format("actionView/countAction/Text (%d)", index))
    end

    self:hideAction()
end

function DouniuView:hideAction()
    hide(self.betAction)
    hide(self.doneAction)
    hide(self.countAction)
end

function DouniuView:showCallAction()
    show(self.betAction)
    show(self.callButton)
    hide(self.doneAction)
    hide(self.countAction)
    local bankGroup = self.model.roomConfig.bankGroup
    for index, item in ipairs(self.betItems) do
        TMPHelper.setText(item.multipleTmp, string.format(T("%d倍"), bankGroup[index].mul))
        if GameManager.UserData.money < bankGroup[index].limit then
            item.button:GetComponent('Button').interactable = false
            TMPHelper.setTextColor(item.multipleTmp, Color.New(200/255,200/255,200/255,1))
        else
            item.button:GetComponent('Button').interactable = true
            TMPHelper.setTextColor(item.multipleTmp, Color.New(255/255,255/255,255/255,1))
        end
    end
end

function DouniuView:showBetAction(betArray)
    show(self.betAction)
    hide(self.callButton)
    hide(self.doneAction)
    hide(self.countAction)
    for index, item in ipairs(self.betItems) do
        TMPHelper.setTextColor(item.multipleTmp, Color.New(255/255,255/255,255/255,1))
        item.button:GetComponent('Button').interactable = true
        if index <= #betArray then
            TMPHelper.setText(item.multipleTmp, string.format(T("%d倍"), betArray[index]))
            show(item.button)
        else
            hide(item.button)
        end
    end
end

function DouniuView:showDoneAction(tipsData)
    hide(self.betAction)
    show(self.doneAction)
    show(self.countAction)
    self.countResult:setText(0)
    hide(self.countResult)
    for index, text in ipairs(self.countTexts) do
        text:setText(0)
        hide(text)
    end
    self.canSelectCard = true

    if tipsData then
        self.tipsText:setText(tipsData.text)
    end

end

--[[
    底下用户信息相关
]]

function DouniuView:initBottomViewControls()
    self.bottomView      = self.view:findChild("bottomView")
    self.moneyButton     = self.bottomView:findChild("goldButton")
    self.moneyText       = self.bottomView:findChild("goldButton/moneyText")
    self.redpacketButton = self.bottomView:findChild("redPacketButton")
    self.redpacketText   = self.bottomView:findChild("redPacketButton/moneyText")
    self.chatButton      = self.bottomView:findChild("chatButton")

    self.moneyButton:addButtonClick(buttonSoundHandler(self, self.onMoneyButtonClick), false)
    self.redpacketButton:addButtonClick(buttonSoundHandler(self, self.onRedPacketButtonClick), false)
    self.chatButton:addButtonClick(buttonSoundHandler(self, self.onChatButtonClick), false)
    self:updataBottomInfoDatas()
end

function DouniuView:updataBottomInfoDatas()
    self.moneyText:setText(formatFiveNumber(GameManager.UserData.money))
    self.redpacketText:setText(GameManager.GameFunctions.getJewel())
end

--[[
    金币变化
]]

function DouniuView:initChipChangeViewControls()
    local w, h = getScreenSize()
    self.chipChangeView = self.view:findChild("chipChangeView")
    for index, seat in ipairs(self.allSeats) do
        local seatPos = seat.headerButton.transform.position
        local area = {}
        area.pos = seat.headerButton.transform.position
        area.chips = {}
        for index = 1, DouniuView.Consts.ChipCount do
            local chip = newObject(self.chipPrefab)
            chip.transform:SetParent(self.chipChangeView.transform)
            chip.transform.position = area.pos
            area.chips[index] = chip
            hide(chip)
        end
        self.chipAreas[index] = area
    end
end

function DouniuView:showChipChangeAnimation(bankerPlayer, losePlayers, winnerPlayers, doneCallback)
    -- 动画
    local moveAnimation = function(originSeatIndex, aimSeatIndex, resouceSeatInex)
        -- 设置随机位置和角度
        local originArea  = self.chipAreas[originSeatIndex]
        local aimArea     = self.chipAreas[aimSeatIndex]
        local resouceArea = self.chipAreas[resouceSeatInex]
        for index, chip in ipairs(resouceArea.chips) do
            Timer.New(function()
                show(chip)
                if index % 4 == 0 then
                    -- 20个金币 播放5叠声音
                    GameManager.SoundManager:PlaySoundWithNewSource("niuniu/setrategold")
                end
                local randomArea = DouniuView.Consts.RandomAera
                local randomAngle = DouniuView.Consts.RandomAngle
                local randomOriginPos = Vector3.New(
                originArea.pos.x + math.random(randomArea) - randomArea * 0.5, 
                originArea.pos.y + math.random(randomArea) - randomArea * 0.5, 
                0)
                local randomOriginAngle = Vector3.New(
                0, 0, math.random(randomAngle) - randomAngle * 0.5)
        
                local randomAimPos = Vector3.New(
                aimArea.pos.x + math.random(randomArea) - randomArea * 0.5, 
                aimArea.pos.y + math.random(randomArea) - randomArea * 0.5, 
                0)
                local randomAimAngle = Vector3.New(
                0, 0, math.random(randomAngle) - randomAngle * 0.5)
        
                chip.transform.position         = randomOriginPos
                chip.transform.localEulerAngles = randomOriginAngle
                local moveAnimation = chip.transform:DOMove(randomAimPos, DouniuView.Consts.Time.ChipMove)
                moveAnimation:SetEase(DG.Tweening.Ease.Linear)
                chip.transform:DOLocalRotate(randomAimAngle, DouniuView.Consts.Time.ChipMove)
                Timer.New(function()
                    hide(chip)
                end, DouniuView.Consts.Time.ChipMove + DouniuView.Consts.Time.ChipDelay * 3, 1, true):Start()
            end, DouniuView.Consts.Time.ChipDelay * index, 1, true):Start()
        end
    end

    -- 如果输庄的人没有 说明庄家通赔
    local allPlayer = table.append(table.append({bankerPlayer}, losePlayers), winnerPlayers)
    local moveOnceTime = DouniuView.Consts.Time.ChipMove + DouniuView.Consts.ChipCount * DouniuView.Consts.Time.ChipDelay

    if #losePlayers == 0 then
        for index, player in ipairs(winnerPlayers) do
            moveAnimation(bankerPlayer.seatIndex, player.seatIndex, player.seatIndex)
        end
    else
        for index, player in ipairs(losePlayers) do
            moveAnimation(player.seatIndex, bankerPlayer.seatIndex, player.seatIndex)
        end
        if #winnerPlayers == 0 then
            -- 如果赢庄的人没有 说明庄家通杀
        else
            -- 等待之前的移动动画 和 其他金币的延时时间
            Timer.New(function()
                for index, player in ipairs(winnerPlayers) do
                    moveAnimation(bankerPlayer.seatIndex, player.seatIndex, player.seatIndex)
                end
            end, moveOnceTime + DouniuView.Consts.Time.ChipMoveDelay, 1, true):Start()
            -- 双倍时间
            moveOnceTime = moveOnceTime * 2 + DouniuView.Consts.Time.ChipMoveDelay
        end
    end
    -- 播放金币文字飘字动画
    Timer.New(function()
        for index, player in ipairs(allPlayer) do
            local seat = self.allSeats[player.seatIndex]
            seat:showChipChangeText(player.addMoney)
        end
    end, moveOnceTime, 1, true):Start()
    -- 最后结束时间
    if doneCallback then
        Timer.New(function()
            doneCallback()
        end, moveOnceTime + DouniuView.Consts.Time.ChipText, 1, true):Start()
    end
end

--[[
    互动道具 HDDJ
]]

function DouniuView:initHDDJViewControls()
    local w, h = getScreenSize()
    self.hddjView = self.view:findChild("hddjView")
    for index, seat in ipairs(self.allSeats) do
        local hddjSeat = self.view:findChild(string.format("hddjView/seat_hddj (%s)", index))
        hide(hddjSeat)
        self.hddjSeats[index] = hddjSeat
        local seatPos = seat.headerButton.transform.position
        hddjSeat.transform.position = seat.headerButton.transform.position
    end
end

function DouniuView:showEmojiView(player, emoji)
    local animationView = self:getAnimationView(player)
    -- 显示中 的话 那么就不显示
    if animationView.activeSelf then
        return
    end

    show(animationView)
    self.interactiveAnimation:playEmoji(emoji.type, emoji.index, animationView)
end

function DouniuView:showHDDJView(sourcePlayer, aimPlayer, hddj)
    local sourceAnimationView = self:getAnimationView(sourcePlayer)
    local aimAnimationView = self:getAnimationView(aimPlayer)
    self.interactiveAnimation:playHDDJ(hddj, sourceAnimationView, aimAnimationView, self.hddjMoveView)
end

function DouniuView:getAnimationView(player)
    local seat = self.uidSeats[player.uid]
    local seatIndex = seat.data.seatIndex
    local animationView = self.hddjSeats[seatIndex]
    return animationView
end

--[[
    event handle 点击事件处理
]]

function DouniuView:onBackButtonClick()
    self.controller_:exitScene()
end

function DouniuView:onTaskButtonClick()
    hide(self.taskRedDot)
    PanelTask.new(1, 2)
end

function DouniuView:onHongbaoButtonClick()
    hide(self.hongbaoRedDot)
    local PanelTotalRedpacket = import("Panel.Operation.PanelTotalRedpacket").new()
end

function DouniuView:onRuleButtonClick()
    PanelLandLordsHelper.new("Images/SceneDouniu/text_rule")
end

function DouniuView:onBetButtonClick(index)
    -- 抢庄
    if self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.CALL then
        if index == 0 then
            GameManager.ServerManager:setBet(CONSTS.DOUNIU.ACTION_TYPE.CALL, 0, nil)
        else
            GameManager.ServerManager:setBet(CONSTS.DOUNIU.ACTION_TYPE.CALL, self.model.roomConfig.bankGroup[index].mul, nil)
        end
    elseif self.model.tableInfo.tableStatus == CONSTS.DOUNIU.TABLE_STATE.BET then
        GameManager.ServerManager:setBet(CONSTS.DOUNIU.ACTION_TYPE.BET, self.model.betArray[index], nil)
    end
end

function DouniuView:onResultButtonClick()
    -- 计算当前牌型
    local seat = self.uidSeats[GameManager.UserData.mid]
    local selectCard = {}
    local unSelectCard = {}
    local count = 0
    for index, card in ipairs(seat.cards) do
        if card.isSelect then
            selectCard[#selectCard + 1] = card.cardClass.hex
        else
            local currentCount = card.cardClass.count
            if currentCount > 10 then
                currentCount = 10
            end
            count = count + currentCount
            unSelectCard[#unSelectCard + 1] = card.cardClass.hex
        end
    end
    if #selectCard ~= 3 then
        GameManager.TopTipManager:showTopTip(T("请选择三张牌"))
        return
    end
    local count = count % 10
    if count == 0 then
        count = 10
    end
    local sortCard = table.append(selectCard, unSelectCard)
    if self.isLoose then
        GameManager.ServerManager:setBet(CONSTS.DOUNIU.ACTION_TYPE.CONFIRM,     0, sortCard)
    else
        GameManager.ServerManager:setBet(CONSTS.DOUNIU.ACTION_TYPE.CONFIRM, count, sortCard)
    end
end

function DouniuView:onTipsButtonClick()
    self.tipsButton:GetComponent('Button').interactable = false
    self.controller_:useNormalNiuTips(function(isSuccess)
        if isSuccess then
            self.tipsButton:GetComponent('Button').interactable = not isSuccess
            -- 选中对应的牌 然后给到server
            -- 把所有牌给消掉
            for index, card in pairs(self.selectedCard) do
                self:onCardClick(index)
            end

            -- 判断是不是散牌
            local seat = self.allSeats[DouniuView.Consts.SelfSeatIndex]
            function getCount(card)
                local count = card.cardClass.count
                return count >= 10 and 10 or count
            end
            -- 神奇算法。。。
            for i = 1, DouniuView.Consts.CardCount - 2  do
                for j = i + 1, DouniuView.Consts.CardCount - 1 do
                    for k = j + 1, DouniuView.Consts.CardCount do
                        local a = getCount(seat.cards[i])
                        local b = getCount(seat.cards[j])
                        local c = getCount(seat.cards[k])
                        if (a + b + c) % 10 == 0 then
                            self:onCardClick(i)
                            self:onCardClick(j)
                            self:onCardClick(k)
                            return
                        end
                    end
                end
            end 
            for index = 1, DouniuView.Consts.IntervalIndex do
                self:onCardClick(index)
            end
        else
            GameManager.TopTipManager:showTopTip()
        end
    end)
end

function DouniuView:onMoneyButtonClick()
    GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.DOUNIUROOM
    PanelShop.new()
end

function DouniuView:onRedPacketButtonClick()
    PanelExchange.new()
end

function DouniuView:onChatButtonClick()
    self.controller_:chatButtonClick()
end

function DouniuView:onClockTimeOver()
    -- 判断当前玩家有没有选择牌
    if self.selectedCard then
        local count = 0
        for index, card in pairs(self.selectedCard) do
            count = count + 1
        end
        if count == DouniuView.Consts.IntervalIndex then
            self:onResultButtonClick()
        end
    end
    self.controller_:clockTimeOver()
end

return DouniuView