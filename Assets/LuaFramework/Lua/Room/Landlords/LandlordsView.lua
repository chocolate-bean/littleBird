local LandlordsView        = class("LandlordsView")
local LandlordsController  = require("Room.Landlords.LandlordsController")
local LandlordsModel       = require("Room.Landlords.LandlordsModel")
local SelfCardView         = require("Room.Landlords.SelfCardView")
local LandlordsCard        = require("Room.Landlords.LandlordsCard")
local Card                 = require("Room.Landlords.Card")
local LandlordsAnimation   = require("Room.Landlords.LandlordsAnimation")
local InteractiveAnimation = require("Room.InteractiveAnimation")
local PanelOtherInfoBig    = require("Panel.PlayInfo.PanelOtherInfoBig")
local PanelShop            = require("Panel.Shop.PanelShop")
local PanelExchange        = require("Panel.Shop.PanelSmallShop")--require("Panel.Exchange.PanelExchange")

LandlordsView.handCardsViewHeight = 245

LandlordsView.Alignment = {
    LEFT   = 1,
    CENTER = 2,
    RIGHT  = 3,
}

LandlordsView.ActionType = {
    jiaodizhu = {
        Yes = "jiaodizhu_Yes",
        No  = "jiaodizhu_No",
    },
    qiangdizhu = {
        Yes = "qiangdizhu_Yes",
        No  = "qiangdizhu_No",
    },
    qishou = {
        Yes = "qishou_Yes",
    },
    yaodeqi = {
        Yes  = "yaodeqi_Yes",
        No   = "yaodeqi_No",
        Tips = "yaodeqi_Tips",
    },
    yaobuqi = {
        No  = "yaobuqi_No",
    },
}

LandlordsView.AnimaitionTime = {
    DealCard         = 1.697,
    RealignCard      = 0.2,
    ShowCard         = 0.2,
    MulitipleChanged = 0.2,
    HeaderChanged    = 0.2,
    RedpacketDismiss = 0.2,
    RedpacketShow    = 0.2,
}

function LandlordsView:ctor(controller, objs, data)
    self.controller_ = controller
    self.model = controller.model

    local animationName = {
        LandlordsAnimation.Animation.Liandui.prefab,
        LandlordsAnimation.Animation.Shunzi.prefab,
        LandlordsAnimation.Animation.Zhadan.prefab,
        LandlordsAnimation.Animation.Wangzha.prefab,
        LandlordsAnimation.Animation.Chuntian.prefab,
        LandlordsAnimation.Animation.Feiji.prefab,}

    self.landlordsAnimation = LandlordsAnimation.new(animationName)
    self.interactiveAnimation = InteractiveAnimation.new()
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "LandlordsView"
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

function LandlordsView:onEnter()
    GameManager.SoundManager:playSomething()
    GameManager.SoundManager:ChangeBGM("landlords/bgm_normal")
end


function LandlordsView:initProperties(objs)
    self.SelfCardPrefab      = objs[1]
    self.LandlordsCardPrefab = objs[2]
    self.cardsArray          = {}
    self.handCardsArray      = {}
    self.addCardsArray       = {}
    self.selectCardsArray    = {}
    self.unSelectCardsArray  = {}

    self.sjCardsArray = {}
    self.xjCardsArray = {}
    self.zjCardsArray = {}
end

function LandlordsView:initUIControls()
    
    self:initTopViewControls()
    self:initHandCardViewControls()
    self:initTableInfoControls()
    self:initSelfPlayerControls()
    self:initOtherPlayerControls()
    self:initActionControls()
    self:initGameoverViewControls()
    self:initCoverCardControls()
    self:initTableControls()
    self:initRobotViewControls()
    self:initRedpackControls()

    self:hideTableInfo()
    self:addPropertyObserver()
end

function LandlordsView:initUIDatas()
    for index = 1, LandlordsModel.MaxCardsCount do
        local selfCard = SelfCardView.new(newObject(self.SelfCardPrefab), {index = index, status = SelfCardView.STATUS.IN_PILE})
        self.cardsArray[#self.cardsArray + 1] = selfCard
        selfCard.view.transform:SetParent(self.handCardsView.transform)
        selfCard.view:scale(Vector3.one)
    end
end

function LandlordsView:addPropertyObserver(type)
    self.registerProps = {"money", "jewel"}
    self.registerHandleIds = {}
    for i = 1, #self.registerProps do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handler(self, self.refreshSelfPlayerInfo))
        table.insert(self.registerHandleIds, handleId)
    end
end

function LandlordsView:showTableInfo()
    show(self.infoView)
end

function LandlordsView:hideTableInfo()
    hide({self.infoView})
end

function LandlordsView:onCleanUp()
    if self.registerHandleIds then
	    for i = 1, #self.registerHandleIds do
	    	local handleId = self.registerHandleIds[i]
	    	GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handleId)
	    end
	    self.registerHandleIds = nil
    end

    function cleanCard(array)
        for index, card in ipairs(array) do
            hide(card.view)
            destroy(card.view)
        end
    end
    cleanCard(self.cardsArray)
    cleanCard(self.sjCardsArray)
    cleanCard(self.xjCardsArray)
    cleanCard(self.zjCardsArray)

    if self.timeTimer then
        self.timeTimer:Stop()
        self.timeTimer = nil
    end
    if self.clockTimer then
        self.clockTimer:Stop()
        self.clockTimer = nil
    end
    if self.NoticeManager then
        self.NoticeManager:onClean()
    end
    destroy(self.view)
    self.view = nil
end


--[[
    房间内相关
]]

function LandlordsView:initTopViewControls()
    self.bgButton    = self.view.transform:Find("bg").gameObject
    self.topView     = self.view.transform:Find("topView").gameObject
    self.backButton  = self.view.transform:Find("topView/topBg/backButton").gameObject
    self.wifiView    = self.view.transform:Find("topView/topBg/wifiView").gameObject
    self.wifiIcon    = self.view.transform:Find("topView/topBg/wifiView/wifiIcon").gameObject
    self.timeText    = self.view.transform:Find("topView/topBg/wifiView/Text").gameObject
    self.taskButton  = self.view.transform:Find("topView/topBg/taskButton").gameObject
    self.taskRedDot  = self.view.transform:Find("topView/topBg/taskButton/redDot").gameObject
    self.moreButton  = self.view.transform:Find("topView/topBg/moreButton").gameObject
    self.moreBg      = self.view.transform:Find("topView/topBg/moreBg").gameObject
    self.ruleButton  = self.view.transform:Find("topView/topBg/moreBg/vLayout/ruleButton").gameObject
    self.robotButton = self.view.transform:Find("topView/topBg/moreBg/vLayout/robotButton").gameObject

    UIHelper.AddButtonClick(self.bgButton, handler(self, self.onBackgroundClick))
    UIHelper.AddButtonClick(self.backButton, buttonSoundHandler(self, self.onBackButtonClick))
    UIHelper.AddButtonClick(self.taskButton, buttonSoundHandler(self, self.onTaskButtonClick))
    UIHelper.AddButtonClick(self.moreButton, buttonSoundHandler(self, self.onMoreButtonClick))
    UIHelper.AddButtonClick(self.ruleButton, buttonSoundHandler(self, self.onRuleButtonClick))
    UIHelper.AddButtonClick(self.robotButton, buttonSoundHandler(self, self.onRobotButtonClick))

    self.timeTimer = Timer.New(function()
        self:updateTimeAndWifi()
    end, 10, 999,true)
    self:updateTimeAndWifi()
    self.timeTimer:Start()
    
    self:showTaskRedDot(false)

    -- 添加喇叭
    self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-80,0))
end

function LandlordsView:updateTimeAndWifi()
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
    self.wifiIcon:GetComponent('Image').sprite = UIHelper.LoadSprite(wifiIconImageName)
end

function LandlordsView:showTaskRedDot(isShow)
    showOrHide(isShow, self.taskRedDot)
end

--[[
    桌子上的信息
]]

function LandlordsView:initTableInfoControls()
    self.info = {}
    self.info.tableText   = self.view.transform:Find("bg/infoText").gameObject
    self.info.mulitiple   = self.view.transform:Find("topView/topBg/infoView/multipleNumber").gameObject
    self.hddjMoveView     = self.view.transform:Find("hddjMoveView").gameObject
    self.animationView_zj = self.view.transform:Find("hddjMoveView/animationView_zj").gameObject
    self.animationView_xj = self.view.transform:Find("hddjMoveView/animationView_xj").gameObject
    self.animationView_sj = self.view.transform:Find("hddjMoveView/animationView_sj").gameObject
end

function LandlordsView:updateTableInfo(isAnimation)
    self.info.tableText:setText(self.model:getTableInfoText())
    if isAnimation then
        self.info.mulitiple.transform.localScale = Vector3.one
        self.info.mulitiple:GetComponent('Text').text = self.model.mulitiple
        local scaleAnimation = self.info.mulitiple.transform:DOScale(Vector3.New(2, 2, 2), LandlordsView.AnimaitionTime.MulitipleChanged)
        scaleAnimation:SetEase(DG.Tweening.Ease.Linear)
        scaleAnimation:SetLoops(2, DG.Tweening.LoopType.Yoyo)
        scaleAnimation:OnComplete(function()

        end)
        -- status:GetComponent('Image').sprite = UIHelper.LoadSprite(imageName)
        -- "Images/SceneLandlords/headicon/DDZ_nongmin_nv"
        if self.model.currentMulitiple ~= -1
        and self.model.currentMulitiple ~= 0 then
            local imageName = "Images/SceneLandlords/image_"..self.model.currentMulitiple.."bei"
            local sprite = UIHelper.LoadSprite(imageName)
            if sprite then
                self.beishuImage:GetComponent('Image').sprite = sprite
                show(self.beishuImage)
                self.beishuImage.transform.localPosition = Vector3.zero
                local moveAnimation = self.beishuImage.transform:DOLocalMoveY(64, LandlordsView.AnimaitionTime.MulitipleChanged * 2)
                moveAnimation:OnComplete(function()
                    hide(self.beishuImage)
                end)
            end
        end
    else
        self.info.mulitiple:GetComponent('Text').text = self.model.mulitiple
    end
    -- TODO: 提交
end

--[[
    牌桌上别的玩家
]]

function LandlordsView:initOtherPlayerControls()
    self.xj = {}
    self.xj.view          = self.view.transform:Find("xiajia").gameObject
    self.xj.headerBg      = self.view.transform:Find("xiajia/headerBg").gameObject
    self.xj.header        = self.view.transform:Find("xiajia/headerBg/headerButton").gameObject
    self.xj.frameImage    = self.view.transform:Find("xiajia/headerBg/headerButton/frameImage").gameObject
    self.xj.statusButton  = self.view.transform:Find("xiajia/headerBg/statusButton").gameObject
    self.xj.robotIcon     = self.view.transform:Find("xiajia/headerBg/robotIcon").gameObject
    self.xj.chatBubble    = self.view.transform:Find("xiajia/chatBubble").gameObject
    self.xj.name          = self.view.transform:Find("xiajia/goldButton/nameText").gameObject
    self.xj.money         = self.view.transform:Find("xiajia/goldButton/moneyText").gameObject
    self.xj.handCard      = self.view.transform:Find("xiajia/handCardBg").gameObject
    self.xj.handCardText  = self.view.transform:Find("xiajia/handCardBg/Text").gameObject

    self.sj = {}
    self.sj.view          = self.view.transform:Find("shangjia").gameObject
    self.sj.headerBg      = self.view.transform:Find("shangjia/headerBg").gameObject
    self.sj.header        = self.view.transform:Find("shangjia/headerBg/headerButton").gameObject
    self.sj.frameImage    = self.view.transform:Find("shangjia/headerBg/headerButton/frameImage").gameObject
    self.sj.statusButton  = self.view.transform:Find("shangjia/headerBg/statusButton").gameObject
    self.sj.robotIcon     = self.view.transform:Find("shangjia/headerBg/robotIcon").gameObject
    self.sj.chatBubble    = self.view.transform:Find("shangjia/chatBubble").gameObject
    self.sj.name          = self.view.transform:Find("shangjia/goldButton/nameText").gameObject
    self.sj.money         = self.view.transform:Find("shangjia/goldButton/moneyText").gameObject
    self.sj.handCard      = self.view.transform:Find("shangjia/handCardBg").gameObject
    self.sj.handCardText  = self.view.transform:Find("shangjia/handCardBg/Text").gameObject


    UIHelper.AddButtonClick(self.xj.header, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.XiaJia)
    end))
    UIHelper.AddButtonClick(self.xj.statusButton, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.XiaJia)
    end))

    UIHelper.AddButtonClick(self.sj.header, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.ShangJia)
    end))
    UIHelper.AddButtonClick(self.sj.statusButton, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.ShangJia)
    end))

    show(self.sj.frameImage)
    show(self.xj.frameImage)
    self.sj.robotIcon:GetComponent('Image').raycastTarget = false
    self.xj.robotIcon:GetComponent('Image').raycastTarget = false

    self:updateOtherPlayer()
end

function LandlordsView:updateOtherPlayer()
    if self.model and self.model.xj then
        show(self.xj.view)
        self.xj.name:GetComponent('Text').text = self.model.xj.name
        self.xj.money:GetComponent('Text').text = formatFiveNumber(self.model.xj.money)
        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = self.model.xj.mavatar,
            sex = tonumber(self.model.xj.msex),
            node = self.xj.header,
            callback = function(sprite)
                if self.view and self.xj.header then
                    self.xj.header:GetComponent('Image').sprite = sprite
                end
            end,
        })
        self.xj.frameImage:GetComponent('Image').sprite = GameManager.ImageLoader:getVipFrame(self.model.xj.viplevel)

        if self.model.xj.cardsCnt == 0 then
            hide(self.xj.handCard)
        else
            show(self.xj.handCard)
            self.xj.handCardText:GetComponent('Text').text = self.model.xj.cardsCnt
        end
    else
        hide(self.xj.view)
    end
    if self.model and self.model.sj then
        show(self.sj.view)
        self.sj.name:GetComponent('Text').text = self.model.sj.name
        self.sj.money:GetComponent('Text').text = formatFiveNumber(self.model.sj.money)
        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = self.model.sj.mavatar,
            sex = tonumber(self.model.sj.msex),
            node = self.sj.header,
            callback = function(sprite)
                if self.view and self.sj.header then
                    self.sj.header:GetComponent('Image').sprite = sprite
                end
            end,
        })
        self.sj.frameImage:GetComponent('Image').sprite = GameManager.ImageLoader:getVipFrame(self.model.sj.viplevel)

        if self.model.sj.cardsCnt == 0 then
            hide(self.sj.handCard)
        else
            show(self.sj.handCard)
            self.sj.handCardText:GetComponent('Text').text = self.model.sj.cardsCnt
        end
    else
        hide(self.sj.view)
    end
end

function LandlordsView:updateOtherPlayerHandCard()
    if self.model.xj then
        show(self.xj.view)
        self.xj.money:GetComponent('Text').text = formatFiveNumber(self.model.xj.money)
        if self.model.xj.cardsCnt == 0 then
            hide(self.xj.handCard)
        else
            show(self.xj.handCard)
            self.xj.handCardText:GetComponent('Text').text = self.model.xj.cardsCnt
        end
    else
        hide(self.xj.view)
    end
    if self.model.sj then
        show(self.sj.view)
        self.sj.money:GetComponent('Text').text = formatFiveNumber(self.model.sj.money)
        if self.model.sj.cardsCnt == 0 then
            hide(self.sj.handCard)
        else
            show(self.sj.handCard)
            self.sj.handCardText:GetComponent('Text').text = self.model.sj.cardsCnt
        end
    else
        hide(self.sj.view)
    end
end


--[[
    成为地主的动画相关
]]

function LandlordsView:whoBecomeDizhu(dizhuPlayer)
    local allHeader = {
        [LandlordsModel.Player.Ziji]     = self.zj.header,
        [LandlordsModel.Player.ShangJia] = self.sj.header,
        [LandlordsModel.Player.XiaJia]   = self.xj.header,
    }
    local allPlayer = {
        [LandlordsModel.Player.Ziji]     = self.model.zj,
        [LandlordsModel.Player.ShangJia] = self.model.sj,
        [LandlordsModel.Player.XiaJia]   = self.model.xj,
    }
    local allStatus = {
        [LandlordsModel.Player.Ziji]     = self.zj.statusButton,
        [LandlordsModel.Player.ShangJia] = self.sj.statusButton,
        [LandlordsModel.Player.XiaJia]   = self.xj.statusButton,
    }
    for player, status in ipairs(allStatus) do
        local imageName = ""
        local sex = tonumber(allPlayer[player].msex)
        if player == dizhuPlayer then
            if sex == 1 then
                imageName = "Images/SceneLandlords/headicon/DDZ_dizhu_nan"
            else
                imageName = "Images/SceneLandlords/headicon/DDZ_dizhu_nv"
            end
        else
            if sex == 1 then
                imageName = "Images/SceneLandlords/headicon/DDZ_nongmin_nan"
            else
                imageName = "Images/SceneLandlords/headicon/DDZ_nongmin_nv"
            end
        end
        status:GetComponent('Image').sprite = UIHelper.LoadSprite(imageName)
    end
    hide(allHeader)
    show(allStatus)
end

function LandlordsView:becomeDizhuAnimation(dizhuPlayer, isAnimation)
    local allHeaderBg = {
        [LandlordsModel.Player.Ziji]     = self.zj.headerBg,
        [LandlordsModel.Player.ShangJia] = self.sj.headerBg,
        [LandlordsModel.Player.XiaJia]   = self.xj.headerBg,
    }
    if isAnimation then
        for player, headerBg in ipairs(allHeaderBg) do
            local sequenceRotate = DG.Tweening.DOTween.Sequence()
            -- sequenceRotate:SetEase(DG.Tweening.Ease.OutQuint)
            local flipBackAction = headerBg.transform:DOScale(Vector3.New(0,1,1), LandlordsView.AnimaitionTime.HeaderChanged)
            flipBackAction:OnComplete(function()
                if player == LandlordsModel.Player.Ziji then
                    self:whoBecomeDizhu(dizhuPlayer)
                end
            end)
            sequenceRotate:Append(flipBackAction)
            sequenceRotate:Append(headerBg.transform:DOScale(Vector3.New(-1,1,0), LandlordsView.AnimaitionTime.HeaderChanged))
            sequenceRotate:OnComplete(function()
                
            end)
        end
    else
        for player, headerBg in ipairs(allHeaderBg) do
            headerBg:scale(Vector3.New(-1, 1, 0))
        end
        self:whoBecomeDizhu(dizhuPlayer)
    end
end

function LandlordsView:allBecomePlayer()
    local allHeader = {
        [LandlordsModel.Player.Ziji]     = self.zj.header,
        [LandlordsModel.Player.ShangJia] = self.sj.header,
        [LandlordsModel.Player.XiaJia]   = self.xj.header,
    }
    local allStatus = {
        [LandlordsModel.Player.Ziji]     = self.zj.statusButton,
        [LandlordsModel.Player.ShangJia] = self.sj.statusButton,
        [LandlordsModel.Player.XiaJia]   = self.xj.statusButton,
    }
    show(allHeader)
    hide(allStatus)
end

function LandlordsView:becomePlayerAnimation(isAnimation)
    local allHeaderBg = {
        [LandlordsModel.Player.Ziji]     = self.zj.headerBg,
        [LandlordsModel.Player.ShangJia] = self.sj.headerBg,
        [LandlordsModel.Player.XiaJia]   = self.xj.headerBg,
    }
    if isAnimation then
        for player, headerBg in ipairs(allHeaderBg) do
            local sequenceRotate = DG.Tweening.DOTween.Sequence()
            -- sequenceRotate:SetEase(DG.Tweening.Ease.OutQuint)
            local flipBackAction = headerBg.transform:DOScale(Vector3.New(0,1,0), LandlordsView.AnimaitionTime.HeaderChanged)
            flipBackAction:OnComplete(function()
                if player == LandlordsModel.Player.Ziji then
                    self:allBecomePlayer()
                end
            end)
            sequenceRotate:Append(flipBackAction)
            sequenceRotate:Append(headerBg.transform:DOScale(Vector3.one, LandlordsView.AnimaitionTime.HeaderChanged))
            sequenceRotate:OnComplete(function()
                
            end)
        end
    else
        for player, headerBg in ipairs(allHeaderBg) do
            headerBg:scale(Vector3.one)
        end
        self:allBecomePlayer()
    end
end

function LandlordsView:showChatBubbleView(player, chatData)
    local bubbleView = nil
    if player == LandlordsModel.Player.Ziji then
        bubbleView = self.zj.chatBubble
    elseif player == LandlordsModel.Player.XiaJia then
        bubbleView = self.xj.chatBubble
    elseif player == LandlordsModel.Player.ShangJia then
        bubbleView = self.sj.chatBubble
    end
    -- 显示中 的话 那么就不显示
    if bubbleView.activeSelf then
        return
    end

    show(bubbleView)
    local bubbleText = bubbleView.transform:Find("bubbleImage/Text").gameObject
    bubbleText:GetComponent('Text').text = chatData

    Timer.New(function()
        hide(bubbleView)
    end,3,1,true):Start()
end

function LandlordsView:getAnimationView(player)
    local animationView = nil
    if player == LandlordsModel.Player.Ziji then
        animationView = self.animationView_zj
    elseif player == LandlordsModel.Player.XiaJia then
        animationView = self.animationView_xj
    elseif player == LandlordsModel.Player.ShangJia then
        animationView = self.animationView_sj
    end
    return animationView
end

function LandlordsView:showEmojiView(player, emoji)
    local animationView = self:getAnimationView(player)
    -- 显示中 的话 那么就不显示
    if animationView.activeSelf then
        return
    end

    show(animationView)
    self.interactiveAnimation:playEmoji(emoji.type, emoji.index, animationView)
end

function LandlordsView:showHDDJView(sourcePlayer, aimPlayer, hddj)
    local sourceAnimationView = self:getAnimationView(sourcePlayer)
    local aimAnimationView = self:getAnimationView(aimPlayer)
    self.interactiveAnimation:playHDDJ(hddj, sourceAnimationView, aimAnimationView, self.hddjMoveView)
end

--[[
    自己的相关信息
]]

function LandlordsView:initSelfPlayerControls()
    self.zj = {}
    self.zj.view            = self.view.transform:Find("bottomView").gameObject
    self.zj.headerBg        = self.view.transform:Find("bottomView/bg/headerBg").gameObject
    self.zj.header          = self.view.transform:Find("bottomView/bg/headerBg/headerButton").gameObject
    self.zj.frameImage      = self.view.transform:Find("bottomView/bg/headerBg/headerButton/frameImage").gameObject
    self.zj.statusButton    = self.view.transform:Find("bottomView/bg/headerBg/statusButton").gameObject
    self.zj.robotIcon       = self.view.transform:Find("bottomView/bg/headerBg/robotIcon").gameObject
    self.zj.chatBubble      = self.view.transform:Find("bottomView/bg/chatBubble").gameObject
    self.zj.name            = self.view.transform:Find("bottomView/bg/nameText").gameObject
    self.zj.goldButton      = self.view.transform:Find("bottomView/bg/goldButton").gameObject
    self.zj.money           = self.view.transform:Find("bottomView/bg/goldButton/moneyText").gameObject
    self.zj.name            = self.view.transform:Find("bottomView/bg/nameText").gameObject
    self.zj.redPacketButton = self.view.transform:Find("bottomView/bg/redPacketButton").gameObject
    self.zj.redPacket       = self.view.transform:Find("bottomView/bg/redPacketButton/moneyText").gameObject
    self.zj.cardRecord      = self.view.transform:Find("bottomView/bg/cardRecord").gameObject
    self.zj.countBg         = self.view.transform:Find("bottomView/bg/cardRecord/countBg").gameObject
    self.zj.chatButton      = self.view.transform:Find("bottomView/bg/chatButton").gameObject

    self.zj.countItems = {}
    for index = 1, 15 do
        self.zj.countItems[index] = self.view.transform:Find("bottomView/bg/cardRecord/countBg/countView/countText_"..index).gameObject
    end

    UIHelper.AddButtonClick(self.zj.header, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.Ziji)
    end))
    UIHelper.AddButtonClick(self.zj.statusButton, buttonSoundHandler(self, function()
        self:onUserHeaderButtonClick(LandlordsModel.Player.Ziji)
    end))
    UIHelper.AddButtonClick(self.zj.cardRecord, buttonSoundHandler(self, self.onCardRecordButtonClick))

    UIHelper.AddButtonClick(self.zj.goldButton, buttonSoundHandler(self, self.onGoldButtonClick))
    UIHelper.AddButtonClick(self.zj.redPacketButton, buttonSoundHandler(self, self.onRedPacketButtonClick))
    UIHelper.AddButtonClick(self.zj.chatButton, buttonSoundHandler(self, self.onChatButtonClick))

    self:updateSelfPlayer()

    self.zj.robotIcon:GetComponent('Image').raycastTarget = false
    hide(self.zj.cardRecord)
    hide(self.zj.countBg)
    show(self.zj.frameImage)
end

function LandlordsView:showCardRecordCount(isShow)
    showOrHide(isShow, self.zj.countBg)
end

function LandlordsView:showCardRecordButton(isShow)
    showOrHide(isShow, self.zj.cardRecord)
end

function LandlordsView:updateSelfPlayer()
    self.zj.name:GetComponent('Text').text = GameManager.UserData.name
    self.zj.money:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.zj.redPacket:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.zj.header,
        callback = function(sprite)
            if self.view and self.zj.header then
                self.zj.header:GetComponent('Image').sprite = sprite
            end
        end,
    })
    self.zj.frameImage:GetComponent('Image').sprite = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
end

function LandlordsView:refreshSelfPlayerInfo()
    self.zj.money:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.zj.redPacket:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
end

function LandlordsView:updateCardRecord(knownCards)
    local countArray = {}
    for _, card in ipairs(knownCards) do
        local count = Card.getCount(card)
        if not countArray[count] then
            countArray[count] = 1
        else
            countArray[count] = countArray[count] + 1
        end
    end
    
    for index, item in ipairs(self.zj.countItems) do
        local allCount = 4
        if index >= 14 then
            allCount = 1
        end
        if countArray[index] then
            allCount = allCount - countArray[index]
        end
        item:GetComponent('Text').text = allCount
        if allCount == 4 then
            item:GetComponent('Text').color = Color.New(255/255,68/255,43/255,1)
        else
            item:GetComponent('Text').color = Color.New(129/255,70/255,40/255,1)
        end
    end
end

--[[
    自己手牌相关方法
]]

function LandlordsView:getHandCardSpace(count)
    count = count or #self.handCardsArray
    if count <= LandlordsModel.NormalCardsCount then
        return SelfCardView.SPACINGX
    elseif LandlordsModel.NormalCardsCount < count and count <= LandlordsModel.MaxCardsCount then
        local subCount    = LandlordsModel.MaxCardsCount - LandlordsModel.NormalCardsCount
        local offsetSpace = SelfCardView.SPACINGX - SelfCardView.SPACINGX_MIN
        local offsetCount = count - LandlordsModel.NormalCardsCount
        return SelfCardView.SPACINGX - offsetSpace / subCount * offsetCount
    end
end

function LandlordsView:sliderValueToIndex(value)
    local padding = self:getHandCardSpace()
    local cardCount = #self.handCardsArray
    local index = 0
    if value > (cardCount - 1) * padding then
        index = #self.handCardsArray
    elseif value == 0 then
        index = 1
    else
        index = math.ceil(value / padding)
    end
    return index
end

function LandlordsView:resetHandCardsViewSize(cardsCount)
    cardsCount = cardsCount or LandlordsModel.NormalCardsCount
    local width  = SelfCardView.WIDTH + self:getHandCardSpace() * (cardsCount - 1)
    local height = LandlordsView.handCardsViewHeight
    self:reloadHandCardsViewSize(width, height)
end

function LandlordsView:reloadHandCardsViewSize(width, height)
    width = width or SelfCardView.WIDTH + self:getHandCardSpace() * (#self.handCardsArray - 1)
    height = height or LandlordsView.handCardsViewHeight

    self.handCardsSlider.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, width)
    self.handCardsSlider.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, height)

    self.handCardsSlider:GetComponent('Slider').maxValue = width
    self.handCardsSlider:GetComponent('Slider').minValue = 0
end

function LandlordsView:valueToCardView(cardValues)
    
end

function LandlordsView:cardViewToValue(cardViews)
    local cards = {}
    for index, cardView in ipairs(cardViews) do
        cards[index] = cardView:getCard()
    end
    return cards
end

function LandlordsView:addCardsInHand(cards)
    
    if #self.handCardsArray + #cards ~= #self.cardsArray then
        print("创建的手牌数和新增牌数不符合")
        return
    end
    self.addCardsArray = {}

    local originCards = {}
    for index, cardView in ipairs(self.handCardsArray) do
        originCards[index] = cardView:getCard()
    end
    local allCards = table.append(clone(originCards) , cards)
    
    table.sort(allCards, function(a, b)
        return Card.getIndex(a) < Card.getIndex(b)
    end)
    local insertIndexs = {}
    for index, card in ipairs(allCards) do
        for _, findCard in ipairs(cards) do
            if findCard == card then
                insertIndexs[#insertIndexs + 1] = {index = index, card = findCard}
                break
            end
        end
    end
    local newHandCards = originCards

    table.insert(newHandCards, insertIndexs[1].index, insertIndexs[1].card)
    table.insert(newHandCards, insertIndexs[2].index, insertIndexs[2].card)
    table.insert(newHandCards, insertIndexs[3].index, insertIndexs[3].card)

    -- 把倒数三个安插在对应的位置上
    table.insert(self.cardsArray, insertIndexs[1].index, self.cardsArray[#self.cardsArray])
    table.insert(self.cardsArray, insertIndexs[2].index, self.cardsArray[#self.cardsArray - 1])
    table.insert(self.cardsArray, insertIndexs[3].index, self.cardsArray[#self.cardsArray - 2])

    self.cardsArray[#self.cardsArray] = nil
    self.cardsArray[#self.cardsArray] = nil
    self.cardsArray[#self.cardsArray] = nil

    self.handCardsArray = self.cardsArray
    local count = #newHandCards
    local mid = count * 0.5 + 0.5
    for index, card in ipairs(newHandCards) do
        local isNewCard = false
        for j, newCard in ipairs(cards) do
            if newCard == card then
                isNewCard = true
                break
            end
        end
        -- show()
        self.cardsArray[index]:setCard(card)
        self.cardsArray[index]:setStatus(SelfCardView.STATUS.IN_HAND)
        self.cardsArray[index]:resetIndex(index)
        self.cardsArray[index].view.transform:SetSiblingIndex(index)
        local aimPosition = Vector3.New(self:getHandCardSpace() * (index - mid), 0, 0)
        if isNewCard then
            self.cardsArray[index].view.transform.localPosition = aimPosition
            self.cardsArray[index].view:GetComponent('Toggle').isOn = true
        else
            self.cardsArray[index].view.transform:DOLocalMove(aimPosition, LandlordsView.AnimaitionTime.RealignCard)
        end
    end
    
    self:resetHandCardsViewSize(#self.handCardsArray)
    self:realignHandCard(0.5,function()
        self:unSelectHandCards()
    end)
end

function LandlordsView:subCardsInHand(cards)
    self.selectCardsArray = {}
    self.unSelectCardsArray = {}
    for index, cardView in ipairs(self.handCardsArray) do
        local isSubCard = false
        for _, card in ipairs(cards) do
            if cardView:getCard() == card then
                self.selectCardsArray[#self.selectCardsArray + 1] = cardView
                isSubCard = true
                break
            end
        end
        if not isSubCard then
            self.unSelectCardsArray[#self.unSelectCardsArray + 1] = cardView
        end
    end
    self:subSelectCards()
end

function LandlordsView:subSelectCards()
    for index, selfCard in ipairs(self.selectCardsArray) do
        hide(selfCard.view)
    end
    self.handCardsArray = self.unSelectCardsArray
    self:realignHandCard(LandlordsView.AnimaitionTime.RealignCard, function()
        self:reloadHandCardsViewSize()
    end)
end

function LandlordsView:showSelectedCards(selectCardValues)
    -- 首先把所有牌按下去

    self:unSelectHandCards()
    for index, card in ipairs(self.handCardsArray) do
        for _, cardValue in ipairs(selectCardValues) do
            if card:getCard() == cardValue then
                card.view:GetComponent('Toggle').isOn = true
                break
            end
        end
    end
end

function LandlordsView:unSelectHandCards()
    for index, card in ipairs(self.cardsArray) do
        card.view:GetComponent('Toggle').isOn = false
    end
end

function LandlordsView:cardToValue(cardsArray)
    local values = {}
    for index, card in ipairs(cardsArray) do
        values[index] = card:getCard()
    end
    return values
end

--[[
    打牌动画相关
]]

function LandlordsView:realignHandCard(animationTime, completeCallback)
    for index, card in ipairs(self.handCardsArray) do
        self:realignCardWithIndex(card, index, #self.handCardsArray, self:getHandCardSpace(), animationTime, function()
            if index == #self.handCardsArray and completeCallback then
                completeCallback()
            end
        end)
        if index == #self.handCardsArray and self.model:isDizhu() then
            card:setCardType(LandlordsCard.CardType.Hand_dizhu)
        else
            card:setCardType(LandlordsCard.CardType.Hand_nongmin)
        end
        local scale = card.view.transform.localScale
    end
end

function LandlordsView:showCardAnimationZero(dataArray, allAnimationTime)
    for index = 1, LandlordsModel.NormalCardsCount do
        Timer.New(function()
            local animationTime = allAnimationTime - allAnimationTime / LandlordsModel.NormalCardsCount * (index - 1)
            local card = self.cardsArray[index]
            self.handCardsArray[#self.handCardsArray + 1] = card
            card:setStatus(SelfCardView.STATUS.IN_HAND)
            card.landlordsCard:setCard(dataArray[index])
            local width = SelfCardView.WIDTH + self:getHandCardSpace() * (#self.handCardsArray - 1)
            local position = Vector3.New((width - SelfCardView.WIDTH) * 0.5,0,0)
            card.view.transform.localPosition = position
            local count = LandlordsModel.NormalCardsCount
            local mid = count * 0.5 + 0.5
            local animation = card.view.transform:DOLocalMove(Vector3.New(self:getHandCardSpace() * (index - mid), 0, 0), animationTime)
            animation:SetEase(DG.Tweening.Ease.Linear)
        end, allAnimationTime / LandlordsModel.NormalCardsCount * (index - 1), 1, true):Start()
    end
end

function LandlordsView:showCardAnimationLv_1(dataArray, allAnimationTime)
    local animaitionTime = allAnimationTime / LandlordsModel.NormalCardsCount
    local index = 1
    self.indexPut = function(index)
        if index > #dataArray then
            return
        end
        local card = self.cardsArray[index]
        self.handCardsArray[#self.handCardsArray + 1] = card
        card:setStatus(SelfCardView.STATUS.IN_HAND)
        card:setCard(dataArray[index])
        local width = SelfCardView.WIDTH + self:getHandCardSpace() * (#self.handCardsArray - 1)
        local position = Vector3.New((width - SelfCardView.WIDTH) * 0.5,0,0)
        self.handCardsArray[#self.handCardsArray].view.transform.localPosition = position
        self:realignHandCard(animaitionTime, function()
            self.indexPut(index + 1)
        end)
    end
    self.indexPut(index)
end

function LandlordsView:showCardAnimationLv_2(dataArray, allAnimationTime)
    local animaitionTime = allAnimationTime * 0.1
    for index = 1, LandlordsModel.NormalCardsCount do
        local animationTime = allAnimationTime - allAnimationTime / LandlordsModel.NormalCardsCount * (index - 1)
        local card = self.cardsArray[index]
        self.handCardsArray[#self.handCardsArray + 1] = card
        card:setStatus(SelfCardView.STATUS.IN_HAND)
        card.landlordsCard:setCard(dataArray[index])
        local width = SelfCardView.WIDTH + self:getHandCardSpace() * (#self.handCardsArray - 1)
        card.view.transform.localPosition = Vector3.zero
    end
    Timer.New(function()
        self:realignHandCard(animaitionTime, nil)
    end,1,0,true):Start()
end

function LandlordsView:dealHandCard(dataArray, isAnimation, isDizhu, completeCallback)
    local scale = self.cardsArray[1].view.transform.localScale

    self:resetHandCardsViewSize(#dataArray)
    show(self.xj.handCard)
    show(self.sj.handCard)

    self:unSelectHandCards()
    -- 重置手牌
    for index, card in ipairs(self.cardsArray) do
        card:setCardType(LandlordsCard.CardType.Hand_nongmin)
        local scale = card.view.transform.localScale
    end

    if isAnimation then
        local allAnimationTime = LandlordsView.AnimaitionTime.DealCard
        self:showCard(dataArray, self.cardsArray, LandlordsView.Alignment.LEFT, self:getHandCardSpace(), allAnimationTime, isDizhu, function(showCardsArray)
            self.handCardsArray = showCardsArray
            if completeCallback then
                completeCallback()
            end
        end)
        for index = 1, LandlordsModel.NormalCardsCount do
            Timer.New(function()
                self.sj.handCardText:GetComponent('Text').text = index
                self.xj.handCardText:GetComponent('Text').text = index
            end, LandlordsView.AnimaitionTime.DealCard / LandlordsModel.NormalCardsCount * (index - 1), 1, true):Start()
        end
    else
        self:updateOtherPlayer()
        self:showCard(dataArray, self.cardsArray, LandlordsView.Alignment.LEFT, self:getHandCardSpace(#dataArray), 0, isDizhu, function(showCardsArray)
            self.handCardsArray = showCardsArray
            if completeCallback then
                completeCallback()
            end
        end)
    end
end

--[[
    桌子上的出牌
]]

function LandlordsView:initTableControls() 
    self.tableView       = self.view.transform:Find("tableView").gameObject
    self.sjClock         = self.view.transform:Find("tableView/shangjia/clock").gameObject
    self.sjClockText     = self.view.transform:Find("tableView/shangjia/clock/Text").gameObject
    self.sjActionImage   = self.view.transform:Find("tableView/shangjia/actionImage").gameObject
    self.sjReadyImage    = self.view.transform:Find("tableView/shangjia/readyImage").gameObject
    self.sjMingpaiView   = self.view.transform:Find("tableView/shangjia/mingpaiView").gameObject
    self.sjMingpaiList_2 = self.view.transform:Find("tableView/shangjia/mingpaiView/list_2").gameObject
    self.sjMingpaiList_1 = self.view.transform:Find("tableView/shangjia/mingpaiView/list_1").gameObject
    self.sjDapaiView     = self.view.transform:Find("tableView/shangjia/dapaiView").gameObject
    self.sjDapaiContent  = self.view.transform:Find("tableView/shangjia/dapaiView/contentView").gameObject
    
    self.xjClock         = self.view.transform:Find("tableView/xiajia/clock").gameObject
    self.xjClockText     = self.view.transform:Find("tableView/xiajia/clock/Text").gameObject
    self.xjActionImage   = self.view.transform:Find("tableView/xiajia/actionImage").gameObject
    self.xjReadyImage    = self.view.transform:Find("tableView/xiajia/readyImage").gameObject
    self.xjMingpaiView   = self.view.transform:Find("tableView/xiajia/mingpaiView").gameObject
    self.xjMingpaiList_2 = self.view.transform:Find("tableView/xiajia/mingpaiView/list_2").gameObject
    self.xjMingpaiList_1 = self.view.transform:Find("tableView/xiajia/mingpaiView/list_1").gameObject
    self.xjDapaiView     = self.view.transform:Find("tableView/xiajia/dapaiView").gameObject
    self.xjDapaiContent  = self.view.transform:Find("tableView/xiajia/dapaiView/contentView").gameObject

    self.zjClock         = self.view.transform:Find("tableView/ziji/clock").gameObject
    self.zjClockText     = self.view.transform:Find("tableView/ziji/clock/Text").gameObject
    self.zjActionImage   = self.view.transform:Find("tableView/ziji/actionImage").gameObject
    self.zjReadyImage    = self.view.transform:Find("tableView/ziji/readyImage").gameObject
    self.zjDapaiView     = self.view.transform:Find("tableView/ziji/dapaiView").gameObject

    self.beishuImage     = self.view.transform:Find("tableView/beishuImage").gameObject

    show(self.tableView)
    self:initTableCardsViewArray()
end

function LandlordsView:initTableCardsViewArray()

    local createCardToArray = function(index, array)
        local card = LandlordsCard.new(newObject(self.LandlordsCardPrefab))
        hide(card.view)
        array[index] = card
        card:setCardType(LandlordsCard.CardType.Table_nongmin)
        return card
    end
    self.sjMingpaiCardsArray = {}
    self.xjMingpaiCardsArray = {}
    for index = 1, LandlordsModel.MaxCardsCount do
        local sjCard = createCardToArray(index, self.sjCardsArray)
        sjCard.view.transform:SetParent(self.sjDapaiContent.transform)
        sjCard.view:scale(Vector3.one)

        local xjCard = createCardToArray(index, self.xjCardsArray)
        xjCard.view.transform:SetParent(self.xjDapaiContent.transform)
        xjCard.view:scale(Vector3.one)

        local zjCard = createCardToArray(index, self.zjCardsArray)
        zjCard.view.transform:SetParent(self.zjDapaiView.transform)
        zjCard.view:scale(Vector3.one)

        -- TODO: sjMingpaiCard 都可以删掉

        local sjMingpaiCard = createCardToArray(index, self.sjMingpaiCardsArray)
        sjMingpaiCard.view.transform:SetParent(self.sjMingpaiView.transform)
        sjMingpaiCard.view:scale(Vector3.one)

        local xjMingpaiCard = createCardToArray(index, self.xjMingpaiCardsArray)
        xjMingpaiCard.view.transform:SetParent(self.xjMingpaiView.transform)
        xjMingpaiCard.view:scale(Vector3.one)
    end
end

function LandlordsView:showCard(dataArray, cardsArray, alignment, space, allAnimationTime, isDizhu, doneCallback)

    for index, card in ipairs(cardsArray) do
        hide(card.view)
    end
    -- 提前设置parent的宽度 否则永远居中 同时parent的锚点要设置正确
    if cardsArray and #cardsArray > 0 then
        local anyCard = cardsArray[1]
        local cardsParent = anyCard.view.transform.parent
        local width = anyCard.WIDTH + space * (#dataArray - 1)
        local height = anyCard.HEIGHT
        cardsParent:GetComponent("RectTransform")
        :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, width)
        cardsParent:GetComponent("RectTransform")
        :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, height)
    end

    local count = #dataArray
    local showCardsArray = {}
    for index = 1, count do
        local card = cardsArray[index]
        showCardsArray[index] = card
        local animationTime = 0
        card:setCard(dataArray[index])
        card.view.transform:SetSiblingIndex(index)
        if allAnimationTime and allAnimationTime > 0 and count ~= 1 then
            local startPoint = Vector3.zero
            if alignment == LandlordsView.Alignment.CENTER then
                local midValue = count * 0.5 + 0.5
                local time = math.abs(index - midValue) * allAnimationTime / midValue
                animationTime = time
            elseif alignment == LandlordsView.Alignment.LEFT then
                animationTime = allAnimationTime / count * (index - 1)
                startPoint = Vector3.New((card.WIDTH + space * (count - 1) - card.WIDTH) * -0.5,0,0)
            elseif alignment == LandlordsView.Alignment.RIGHT then
                animationTime = allAnimationTime - allAnimationTime / count * (index - 1)
                startPoint = Vector3.New((card.WIDTH + space * (count - 1) - card.WIDTH) * 0.5,0,0)
            end
            card.view.transform.localPosition = startPoint
        else
            show(card.view)
        end
        self:realignCardWithIndex(card, index, count, space, animationTime, function()
            local endIndex = count
            if allAnimationTime and allAnimationTime > 0 then
                if alignment == LandlordsView.Alignment.CENTER then
                    endIndex = 1
                    if index == count * 0.5 then
                        show(card.view)
                    end
                    if index - 1 >= 1 then
                        show(cardsArray[index - 1].view)
                    end
                    if index + 1 <= count then
                        show(cardsArray[index + 1].view)
                    end
                elseif alignment == LandlordsView.Alignment.LEFT then
                    endIndex = count
                    if index == 1 then
                        show(card.view)
                    end
                    if index + 1 <= count then
                        show(cardsArray[index + 1].view)
                    end
                elseif alignment == LandlordsView.Alignment.RIGHT then
                    endIndex = 1
                    if index == count then
                        show(card.view)
                    end
                    if index - 1 >= 1 then
                        show(cardsArray[index - 1].view)
                    end
                end
            end
            if index == endIndex and doneCallback then
                doneCallback(showCardsArray)
            end
        end)
    end
end

function LandlordsView:realignCardWithIndex(card, index, count, space, animationTime, completeCallback)
    local mid = count * 0.5 + 0.5
    local aimPosition = Vector3.New(space * (index - mid), 0, 0)
    if not animationTime or animationTime == 0 then
        card.view.transform.localPosition = aimPosition
        if completeCallback then
            completeCallback()
        end
    else
        local animation = card.view.transform:DOLocalMove(aimPosition, animationTime)
        animation:SetEase(DG.Tweening.Ease.Linear)
        animation:OnComplete(function()
            if completeCallback then
                completeCallback()
            end
        end)
    end
end

function LandlordsView:tableShowDapaiCard(player, dataArray, needAnimation, isDizhu)
    local animationTime = needAnimation and LandlordsView.AnimaitionTime.ShowCard or 0
    if dataArray and #dataArray > 0 then
        -- 出牌了
        local isShow = false
        self:tableShowActionImage(player, isShow)
        self:tableShowDapaiView(player, not isShow)

        function showDizhuType(showCardsArray, isDizhu)
            for index, card in ipairs(showCardsArray) do
                if isDizhu and index == #showCardsArray then
                    card:setCardType(LandlordsCard.CardType.Table_dizhu)
                else
                    card:setCardType(LandlordsCard.CardType.Table_nongmin)
                end
            end
        end

        local space = LandlordsCard.SPACINGX
        if player == LandlordsModel.Player.Ziji then
            self:showCard(dataArray, self.zjCardsArray, LandlordsView.Alignment.CENTER, space, animationTime, isDizhu, function(showCardsArray)
                showDizhuType(showCardsArray,isDizhu)
            end)
        elseif player == LandlordsModel.Player.XiaJia then
            for index, card in ipairs(self.xjCardsArray) do
                card.view.transform:SetParent(self.xjDapaiContent.transform)
                card.view:scale(Vector3.one)
            end
            self:showCard(dataArray, self.xjCardsArray, LandlordsView.Alignment.RIGHT, space, animationTime, isDizhu, function(showCardsArray)
                showDizhuType(showCardsArray,isDizhu)
            end)
        elseif player == LandlordsModel.Player.ShangJia then
            for index, card in ipairs(self.sjCardsArray) do
                card.view.transform:SetParent(self.sjDapaiContent.transform)
                card.view:scale(Vector3.one)
            end
            self:showCard(dataArray, self.sjCardsArray, LandlordsView.Alignment.LEFT, space, animationTime, isDizhu, function(showCardsArray)
                showDizhuType(showCardsArray,isDizhu)
            end)
        end
    else
        local isShow = true
        self:tableShowActionImage(player, isShow, LandlordsModel.ActionResult.yaobuqi)
        self:tableShowDapaiView(player, not isShow)
    end
end

function LandlordsView:tableShowDapaiView(player, isShow)
    if player == LandlordsModel.Player.Ziji then
        showOrHide(isShow, self.zjDapaiView)
    elseif player == LandlordsModel.Player.XiaJia then
        showOrHide(isShow, self.xjDapaiView)
    elseif player == LandlordsModel.Player.ShangJia then
        showOrHide(isShow, self.sjDapaiView)
    end
end

function LandlordsView:tableShowMingpaiCard(player, dataArray, isDizhu)

    function showPlayerMingpaiCard(param)

        if not dataArray or #dataArray == 0 then
            hide(param.mingpaiView)
            return
        end

        show(param.mingpaiView)
        if #dataArray > 10 then
            show({param.list_1, param.list_2})
        else
            show(param.list_1)
            hide(param.list_2)
        end
        -- 把桌子上的牌拿过来
        local cardsList_1 = {
            cards = {},
            datas = {},
        }
        local cardsList_2 = {
            cards = {},
            datas = {},
        }

        for index, card in ipairs(param.cardArray) do
            hide(card.view) 
        end

        for index, hex in ipairs(dataArray) do
            local card = param.cardArray[index]
            card:setCard(hex)
            show(card.view)
            if index <= 10 then
                card.view.transform:SetParent(param.list_1.transform)
                card.view:scale(Vector3.one)
                cardsList_1.cards[#cardsList_1.cards + 1] = card
                cardsList_1.datas[#cardsList_1.datas + 1] = hex
            else
                cardsList_2.cards[#cardsList_2.cards + 1] = card
                cardsList_2.datas[#cardsList_2.datas + 1] = hex
                card.view.transform:SetParent(param.list_2.transform)
                card.view:scale(Vector3.one)
            end
        end
        local space = LandlordsCard.SPACINGX
        self:showCard(cardsList_1.datas,cardsList_1.cards,LandlordsView.Alignment.LEFT,space,0,isDizhu,nil)
        self:showCard(cardsList_2.datas,cardsList_2.cards,LandlordsView.Alignment.LEFT,space,0,isDizhu,nil)
    end

    -- 自己不用明牌
    if player == LandlordsModel.Player.Ziji then
        return
    elseif player == LandlordsModel.Player.XiaJia then
        local param = {
            mingpaiView = self.xjMingpaiView,
            list_1 = self.xjMingpaiList_1,
            list_2 = self.xjMingpaiList_2,
            cardArray = self.xjMingpaiCardsArray,
        }
        showPlayerMingpaiCard(param)
    elseif player == LandlordsModel.Player.ShangJia then
        local param = {
            mingpaiView = self.sjMingpaiView,
            list_1 = self.sjMingpaiList_1,
            list_2 = self.sjMingpaiList_2,
            cardArray = self.sjMingpaiCardsArray,
        }
        showPlayerMingpaiCard(param)
    end
end

function LandlordsView:tableShowActionImage(player, isShow, result)

    local setImageWithResult = function(isShow, imageView, result)
        if not isShow then
            hide(imageView)
            return
        end
        show(imageView)
        local actionName = ""
        local imagName = ""
        if result == LandlordsModel.ActionResult.jiaodizhu then
            imagName = "Images/SceneLandlords/text_jiaodizhu"
            actionName = "jiaodizhu"
        elseif result == LandlordsModel.ActionResult.bujiao then
            imagName = "Images/SceneLandlords/text_bujiao"
            actionName = "bujiao"
        elseif result == LandlordsModel.ActionResult.qiangdizhu then
            imagName = "Images/SceneLandlords/text_qiangdizhu"
            actionName = "qiangdizhu"
        elseif result == LandlordsModel.ActionResult.buqiang then
            imagName = "Images/SceneLandlords/text_buqiang"
            actionName = "buqiang"
        elseif result == LandlordsModel.ActionResult.yaobuqi then
            imagName = "Images/SceneLandlords/text_buyao"
            actionName = "yaobuqi"
        end
        imageView:GetComponent('Image').sprite = UIHelper.LoadSprite(imagName)
        imageView:GetComponent('Image'):SetNativeSize()
        print("player:"..player.."图片名字："..actionName)
    end

    if player == LandlordsModel.Player.Ziji then
        setImageWithResult(isShow, self.zjActionImage, result)
    elseif player == LandlordsModel.Player.XiaJia then
        setImageWithResult(isShow, self.xjActionImage, result)
    elseif player == LandlordsModel.Player.ShangJia then
        setImageWithResult(isShow, self.sjActionImage, result)
    end
end

function LandlordsView:tableShowReadyImage(player, isShow)
    if player == nil then
        showOrHide(isShow, self.zjReadyImage)
        showOrHide(isShow, self.xjReadyImage)
        showOrHide(isShow, self.sjReadyImage)
        return
    end

    if player == LandlordsModel.Player.Ziji then
        showOrHide(isShow, self.zi)
        showOrHide(isShow, self.zjReadyImage)
    elseif player == LandlordsModel.Player.XiaJia then
        showOrHide(isShow, self.xjReadyImage)
    elseif player == LandlordsModel.Player.ShangJia then
        showOrHide(isShow, self.sjReadyImage)
    end
end

function LandlordsView:tableShowClock(player, isShow, countTime)
    local clockText = nil
    if player == LandlordsModel.Player.Ziji then
        hide({self.xjClock, self.sjClock})
        showOrHide(isShow, self.zjClock)
        clockText = self.zjClockText
    elseif player == LandlordsModel.Player.XiaJia then
        hide({self.zjClock, self.sjClock})
        showOrHide(isShow, self.xjClock)
        clockText = self.xjClockText
    elseif player == LandlordsModel.Player.ShangJia then
        hide({self.xjClock, self.zjClock})
        showOrHide(isShow, self.sjClock)
        clockText = self.sjClockText
    end
    if isShow and clockText then
        if self.clockTimer then
            self.clockTimer:Stop()
            self.clockTimer = nil
        end
        clockText:GetComponent('Text').text = countTime
        self.clockTimer = Timer.New(function()
            countTime = countTime - 1
            clockText:GetComponent('Text').text = countTime

            if countTime <= 3 and player == LandlordsModel.Player.Ziji then
                GameManager.SoundManager:PlaySoundWithNewSource("sound_remind")
            end

            if countTime == 0 then
                if player == LandlordsModel.Player.Ziji then
                    self:timeOver()
                end
                self:tableShowClock(player,false)
            end
        end,1,countTime,true)
        self.clockTimer:Start()
    else
        if self.clockTimer then
            self.clockTimer:Stop()
            self.clockTimer = nil
        end
    end
end

function LandlordsView:adjustZijiClockPosition(actionStatus)
    if not self.zijiClockPositions then
        self.zijiClockPositions = {
            Center = Vector3.zero,
            Left   = Vector3.New(-110,0,0)      
        }
    end
    if actionStatus == LandlordsModel.ActionStatus.Jiaodizhu then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Center
    elseif actionStatus == LandlordsModel.ActionStatus.Qiangdizhu then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Center
    elseif actionStatus == LandlordsModel.ActionStatus.Qishou then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Left
    elseif actionStatus == LandlordsModel.ActionStatus.Yaodeqi then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Left
    elseif actionStatus == LandlordsModel.ActionStatus.Yaobuqi then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Left
    elseif actionStatus == LandlordsModel.ActionStatus.Tuoguan then
        self.zjClock.transform.localPosition = self.zijiClockPositions.Center
    end
end


function LandlordsView:showCardTypeAnimation(player, cardType, doneCallback)
    local params = {}
    if player == LandlordsModel.Player.Ziji then
        params.parent = self.zjDapaiView
    elseif player == LandlordsModel.Player.XiaJia then
        params.parent = self.xjDapaiContent
    elseif player == LandlordsModel.Player.ShangJia then
        params.parent = self.sjDapaiContent
    end

    if cardType == LandlordsModel.CardsType.DOUBLE_JOKER then         --双王炸
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Wangzha)
    elseif cardType == LandlordsModel.CardsType.LINE then             --顺子(底牌3张算顺子)
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Shunzi, params)
    elseif cardType == LandlordsModel.CardsType.PAIR_LINE then        --连对
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Liandui, params)
    elseif cardType == LandlordsModel.CardsType.THREE_LINE then       --飞机
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Feiji)
    elseif cardType == LandlordsModel.CardsType.BOMB then             --四张炸弹
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Zhadan, params)
    elseif cardType == "Chuntian" then                                  --春天
        self.landlordsAnimation:playLandlordsAnimation(LandlordsAnimation.Animation.Chuntian, {}, doneCallback)
    end
end

--[[
    顶部三张牌
]]

function LandlordsView:initCoverCardControls()
    self.infoView           = self.view.transform:Find("topView/topBg/infoView").gameObject
    self.landlordsCardsView = self.view.transform:Find("topView/topBg/infoView/landlordsCardsView").gameObject
    self.multipleImage      = self.view.transform:Find("topView/topBg/infoView/multipleImage").gameObject
    self.coverCard_1        = LandlordsCard.new(self.view.transform:Find("topView/topBg/infoView/landlordsCardsView/LandlordsCard (1)").gameObject)
    self.coverCard_2        = LandlordsCard.new(self.view.transform:Find("topView/topBg/infoView/landlordsCardsView/LandlordsCard (2)").gameObject)
    self.coverCard_3        = LandlordsCard.new(self.view.transform:Find("topView/topBg/infoView/landlordsCardsView/LandlordsCard (3)").gameObject)
    self.coverCards = {self.coverCard_1, self.coverCard_2, self.coverCard_3}

    for index, card in ipairs(self.coverCards) do
        -- card.view.transform:SetParent(self.landlordsCardsView.transform)
        card:setCardType(LandlordsCard.CardType.Cover)
    end
end

function LandlordsView:showCoverCards(dataArray, mulitiple)
    for index, card in ipairs(self.coverCards) do
        card:setCardType(LandlordsCard.CardType.Cover_show)
        card:setCard(dataArray[index])
        card:flip(function()
            if index == 1 then
                local imageName = ""
                show(self.multipleImage)
                if mulitiple == 2 then
                    imageName = "Images/SceneLandlords/DDZ_2bei"
                elseif mulitiple == 3 then
                    imageName = "Images/SceneLandlords/DDZ_3bei"
                elseif mulitiple == 4 then
                    imageName = "Images/SceneLandlords/DDZ_4bei"
                else
                    hide(self.multipleImage)
                end
                self.multipleImage:GetComponent('Image').sprite = UIHelper.LoadSprite(imageName)
                self.multipleImage:scale(Vector3.New(2,2,2))
                local scaleAnimation = self.multipleImage.transform:DOScale(Vector3.one, LandlordsView.AnimaitionTime.MulitipleChanged)
                scaleAnimation:SetEase(DG.Tweening.Ease.Linear)
            end
        end)
    end
end

function LandlordsView:rebackCoverCards()
    for index, card in ipairs(self.coverCards) do
        card:setCardType(LandlordsCard.CardType.Cover)
    end
    hide(self.multipleImage)
end


--[[
    操作相关
]]
function LandlordsView:initActionControls()
    -- 叫地主
    self.jiaodizhu     = self.view.transform:Find("actionView/jiaodizhu").gameObject
    self.jiaodizhu_yes = self.view.transform:Find("actionView/jiaodizhu/yes").gameObject
    self.jiaodizhu_no  = self.view.transform:Find("actionView/jiaodizhu/no").gameObject
    -- 抢地主
    self.qiangdizhu     = self.view.transform:Find("actionView/qiangdizhu").gameObject
    self.qiangdizhu_yes = self.view.transform:Find("actionView/qiangdizhu/yes").gameObject
    self.qiangdizhu_no  = self.view.transform:Find("actionView/qiangdizhu/no").gameObject
    -- 起手出牌
    self.qishou     = self.view.transform:Find("actionView/qishou").gameObject
    self.qishou_yes = self.view.transform:Find("actionView/qishou/yes").gameObject
    -- 后手出牌——要得起
    self.yaodeqi      = self.view.transform:Find("actionView/yaodeqi").gameObject
    self.yaodeqi_yes  = self.view.transform:Find("actionView/yaodeqi/yes").gameObject
    self.yaodeqi_no   = self.view.transform:Find("actionView/yaodeqi/no").gameObject
    self.yaodeqi_tips = self.view.transform:Find("actionView/yaodeqi/tips").gameObject
    -- 后手出牌——要不起
    self.yaobuqi     = self.view.transform:Find("actionView/yaobuqi").gameObject
    self.yaobuqi_no  = self.view.transform:Find("actionView/yaobuqi/no").gameObject

    self.actionViews = {self.jiaodizhu, self.qiangdizhu, self.qishou, self.yaodeqi, self.yaobuqi}

    self:addActionButtonHandler(self.jiaodizhu_yes, LandlordsView.ActionType.jiaodizhu.Yes)
    self:addActionButtonHandler(self.jiaodizhu_no, LandlordsView.ActionType.jiaodizhu.No)

    self:addActionButtonHandler(self.qiangdizhu_yes, LandlordsView.ActionType.qiangdizhu.Yes)
    self:addActionButtonHandler(self.qiangdizhu_no, LandlordsView.ActionType.qiangdizhu.No)

    self:addActionButtonHandler(self.qishou_yes, LandlordsView.ActionType.qishou.Yes)

    self:addActionButtonHandler(self.yaodeqi_yes, LandlordsView.ActionType.yaodeqi.Yes)
    self:addActionButtonHandler(self.yaodeqi_no, LandlordsView.ActionType.yaodeqi.No)
    self:addActionButtonHandler(self.yaodeqi_tips, LandlordsView.ActionType.yaodeqi.Tips)

    self:addActionButtonHandler(self.yaobuqi_no, LandlordsView.ActionType.yaobuqi.No)
end

--[[
    结算操作
]]
function LandlordsView:initGameoverViewControls()
    self.gameoverView     = self.view.transform:Find("gameoverView").gameObject
    self.changeRoomButton = self.view.transform:Find("gameoverView/changeRoomButton").gameObject
    self.readyButton      = self.view.transform:Find("gameoverView/readyButton").gameObject

    UIHelper.AddButtonClick(self.changeRoomButton, buttonSoundHandler(self, function()
        self.controller_:changeRoom()
        self:showGameoverView(false)
    end))

    UIHelper.AddButtonClick(self.readyButton, buttonSoundHandler(self, function()
        self.controller_:ready()
        self:showGameoverView(false)
    end))

end

function LandlordsView:showGameoverView(isShow)
    showOrHide(isShow, self.gameoverView)
end

--[[
    红包相关
]]

function LandlordsView:initRedpackControls()
    self.missionButton    = self.view.transform:Find("missionButton").gameObject
    self.missionInfoBg    = self.view.transform:Find("missionButton/bg").gameObject
    self.missionInfoText  = self.view.transform:Find("missionButton/bg/Text").gameObject

    self.redpacketView    = self.view.transform:Find("redpacketView").gameObject
    self.receivedButton   = self.view.transform:Find("redpacketView/receivedButton").gameObject
    self.receivedInfoText = self.view.transform:Find("redpacketView/receivedButton/infoText").gameObject
    self.receivedSlider   = self.view.transform:Find("redpacketView/receivedButton/progressSlider").gameObject
    self.receivedText     = self.view.transform:Find("redpacketView/receivedButton/progressSlider/Text").gameObject

    UIHelper.AddButtonClick(self.missionButton, buttonSoundHandler(self, function()
        self:onMissionButtonClick()
    end))

    UIHelper.AddButtonClick(self.receivedButton, buttonSoundHandler(self, function()
        self:onReceivedButtonClick()
    end))

    local landlordsType = UnityEngine.PlayerPrefs.GetInt(DataKeys.CHOOSEROOM_TYPE)
    if landlordsType == 1 then
        showOrHide(false, self.missionButton)
        showOrHide(false, self.redpacketView)
    end
end

function LandlordsView:showRedpackMissionButton(isShow)
    local landlordsType = UnityEngine.PlayerPrefs.GetInt(DataKeys.CHOOSEROOM_TYPE)
    if landlordsType == 0 then
        showOrHide(isShow, self.missionButton)
    else
        showOrHide(false, self.missionButton)
    end
    -- showOrHide(isShow, self.missionButton)
    -- showOrHide(not isShow, self.receivedButton)
end

function LandlordsView:showRedpackReceivedButton(isShow)
    local landlordsType = UnityEngine.PlayerPrefs.GetInt(DataKeys.CHOOSEROOM_TYPE)
    if landlordsType == 0 then
        showOrHide(isShow, self.receivedButton)
    else
        showOrHide(false, self.receivedButton)
    end
    -- showOrHide(isShow, self.receivedButton)
    -- showOrHide(not isShow, self.missionButton)
end

function LandlordsView:updateRedpackMissionInfo(current, goal, isAllDone, tips)
    self.missionInfoText:GetComponent('Text').text = current.."/"..goal
    self.receivedText   :GetComponent('Text').text = current.."/"..goal

    if current >= goal then
        self.receivedInfoText:GetComponent('Text').text = T("有红包拿啦!")
        self.receivedSlider:GetComponent('Slider').value = 1
        if isAllDone then
            self.receivedInfoText:GetComponent('Text').text = T("全部任务完成!")
            return
        end
    else
        local string = string.format(tips, (goal - current))
        self.receivedInfoText:GetComponent('Text').text = string
        self.receivedSlider:GetComponent('Slider').value = current / goal
    end

    self:showShakeAnimation(self.missionButton, -595, current >= goal)
end

function LandlordsView:realignRedpackButton(isFront)
    local landlordsType = UnityEngine.PlayerPrefs.GetInt(DataKeys.CHOOSEROOM_TYPE)
    if landlordsType == 0 then
        if isFront then
            local parent = UnityEngine.GameObject.Find("Canvas")
            self.redpacketView.transform:SetParent(parent.transform)
            self:showMissionAnimation()
        else
            self.redpacketView.transform:SetParent(self.view.transform)
            self:dismissMissionAnimation()
        end
    end
end

function LandlordsView:showShakeAnimation(obj, originX, isOpen)
    if not isOpen then
        obj.transform:DOKill()
        return
    end
    local moveAnimation = obj.transform:DOLocalMoveX(originX+10, 0.2)
    moveAnimation:SetLoops(1000, DG.Tweening.LoopType.Yoyo)
end

function LandlordsView:showMissionAnimation()
    -- local scaleAnimation = self.missionButton.transform:DOScale(Vector3.zero, LandlordsView.AnimaitionTime.RedpacketDismiss)
    -- scaleAnimation:OnComplete(function()
    show(self.receivedButton)
    local parentWidth = self.redpacketView.transform.sizeDelta.x
    local width       = self.receivedButton.transform.sizeDelta.x
    self.receivedButton.transform.localPosition = Vector3.New((parentWidth + width) * -0.5, self.receivedButton.transform.localPosition.y, 0)
    self.receivedButton.transform:DOLocalMoveX((width - parentWidth) * 0.5, LandlordsView.AnimaitionTime.RedpacketShow)
    -- end)
end

function LandlordsView:dismissMissionAnimation()
    local parentWidth = self.redpacketView.transform.sizeDelta.x
    local width       = self.receivedButton.transform.sizeDelta.x
    local moveAnimation = self.receivedButton.transform:DOLocalMoveX((parentWidth + width) * -0.5, LandlordsView.AnimaitionTime.RedpacketShow)
    -- moveAnimation:OnComplete(function()
    --     self.missionButton.transform:DOScale(Vector3.one, LandlordsView.AnimaitionTime.RedpacketDismiss)
    -- end)
end

--[[
    托管相关
]]

function LandlordsView:initRobotViewControls()
    self.robotView         = self.view.transform:Find("robotView").gameObject
    self.cancelRobotButton = self.view.transform:Find("robotView/cancelRobotButton").gameObject

    UIHelper.AddButtonClick(self.cancelRobotButton, buttonSoundHandler(self, self.onCancelRobotButtonClick))

end

function LandlordsView:showRobotView(player, isShow)
    if player == LandlordsModel.Player.Ziji then
        showOrHide(isShow, self.zj.robotIcon)
        showOrHide(isShow, self.robotView)
    elseif player == LandlordsModel.Player.XiaJia then
        showOrHide(isShow, self.xj.robotIcon)
    elseif player == LandlordsModel.Player.ShangJia then
        showOrHide(isShow, self.sj.robotIcon)
    end
end

--[[
    操作相关的点击事件
]]

function LandlordsView:initHandCardViewControls()
    
    self.cardView        = self.view.transform:Find("cardView").gameObject
    self.handCardsView   = self.view.transform:Find("cardView/handCardsView").gameObject
    self.handCardsSlider = self.view.transform:Find("cardView/handCardsSlider").gameObject
    self.cantPlayView    = self.view.transform:Find("cardView/cantPlayView").gameObject
    self.tipsText        = self.view.transform:Find("cardView/cantPlayView/tipsText").gameObject

    UIHelper.AddSliderValueChangedListen(self.handCardsSlider, function(value)
        self:sliderValueChangedListen(value)
    end)

    UIHelper.addTouchListener(self.handCardsSlider, function(eventString, pointerEventData)
        self:onHandCardsSliderTouch(eventString, pointerEventData)
    end)
end


function LandlordsView:addActionButtonHandler(button, actionType)
    UIHelper.AddButtonClick(button, buttonSoundHandler(self, function()
        self:onActionButtonClick(actionType)
    end))
end

function LandlordsView:timeOver()
    -- 通知控制器那边处理 涉及到托管
    self.controller_:timeOver()
end

function LandlordsView:showCantPlayView(isShow, isError)
    
    showOrHide(isShow, self.cantPlayView)
    if not isShow then
        return
    end
    local imageName = "Images/SceneLandlords/text_yaobuqi_info"
    if isError then
        imageName = "Images/SceneLandlords/text_error_info"
    end
    self.tipsText:GetComponent('Image').sprite = UIHelper.LoadSprite(imageName)
    self.cantPlayView:GetComponent('Image').raycastTarget = not isError
    self.tipsText    :GetComponent('Image').raycastTarget = not isError

    if isError then
        Timer.New(function()
            hide(self.cantPlayView)
        end, 1.5, 1, true):Start()
    end
end


function LandlordsView:showActionView(isShow, actionStatus)
    -- 这里会动态修改自己的clock位置位置
    hide(self.actionViews)
    self:showCantPlayView(false)
    if not isShow then
        self:adjustZijiClockPosition(actionStatus)
        return 
    end
    
    local actionStatus = actionStatus
    if actionStatus == LandlordsModel.ActionStatus.Jiaodizhu then
        show(self.jiaodizhu)
    elseif actionStatus == LandlordsModel.ActionStatus.Qiangdizhu then
        show(self.qiangdizhu)
    elseif actionStatus == LandlordsModel.ActionStatus.Qishou then
        show(self.qishou)
    elseif actionStatus == LandlordsModel.ActionStatus.Yaodeqi then
        show(self.yaodeqi)
    elseif actionStatus == LandlordsModel.ActionStatus.Yaobuqi then
        show(self.yaobuqi)
        self:showCantPlayView(isShow)
    end
    -- 调整自己时钟的位置
    self:adjustZijiClockPosition(actionStatus)
end


--[[
    event handle
]]

function LandlordsView:onActionButtonClick(actionType)
    self.controller_:action()

    --立刻暂停倒计时
    -- self:tableShowClock(LandlordsModel.Player.Ziji, false, 0)
    self.selectCardsArray = {}
    self.unSelectCardsArray = {}
    for index, card in ipairs(self.handCardsArray) do
        if card.view:GetComponent('Toggle').isOn then
            self.selectCardsArray[#self.selectCardsArray + 1] = card
        else
            self.unSelectCardsArray[#self.unSelectCardsArray + 1] = card
        end
    end
   
    local string = ""
    for index, card in ipairs(self.selectCardsArray) do
        string = string..card.landlordsCard.card.name
    end
    print("打出的牌"..string)

    local yes = 1
    local no  = 0
    if actionType == LandlordsView.ActionType.jiaodizhu.Yes then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.CALL, yes, {})
    elseif actionType == LandlordsView.ActionType.jiaodizhu.No then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.CALL, no, {})
    elseif actionType == LandlordsView.ActionType.qiangdizhu.Yes then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.GRAB, yes, {})
    elseif actionType == LandlordsView.ActionType.qiangdizhu.No then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.GRAB, no, {})
    elseif actionType == LandlordsView.ActionType.qishou.Yes then
        local cards = self:cardViewToValue(self.selectCardsArray)
        if #cards == 0 then
            self:showCantPlayView(true, true)
        end
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.OUTCARD, yes, cards)
    elseif actionType == LandlordsView.ActionType.yaodeqi.Yes then
        local cards = self:cardViewToValue(self.selectCardsArray)
        if #cards == 0 then
            self:showCantPlayView(true, true)
        end
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.FOLLOW, yes, cards)
    elseif actionType == LandlordsView.ActionType.yaodeqi.No then
        self:unSelectHandCards()
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes, {})
    elseif actionType == LandlordsView.ActionType.yaodeqi.Tips then
        self:unSelectHandCards()
        if self.model.hintCards and #self.model.hintCards ~= 0 then
            self:showSelectedCards(self.model.hintCards)
        end
        -- 请求下一次的提示
        GameManager.ServerManager:getHint()
    elseif actionType == LandlordsView.ActionType.yaobuqi.No then
        self:unSelectHandCards()
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.PASS, yes, {})
    end
end

function LandlordsView:onUserHeaderButtonClick(player)
    local model = nil
    if player == LandlordsModel.Player.Ziji then
        model = self.model.zj
    elseif player == LandlordsModel.Player.XiaJia then
        model = self.model.xj
    elseif player == LandlordsModel.Player.ShangJia then
        model = self.model.sj
    end
    local PanelOtherInfoBig = PanelOtherInfoBig.new(model.uid, function(index)
        local times = 1
        http.useToolProp(
            times,   
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.ServerManager:sendProp(index, model.seatId, times)
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
end


function LandlordsView:onGoldButtonClick()
    GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.LANDLORDROOM
    PanelShop.new()
end

function LandlordsView:onRedPacketButtonClick()
    PanelExchange.new()
end

function LandlordsView:onMissionButtonClick()
    self.controller_:showRedpacketMission()
end

function LandlordsView:onReceivedButtonClick()
    self.controller_:showRedpacketMission()
end

function LandlordsView:onChatButtonClick()
    self.controller_:chatButtonClick()
end

function LandlordsView:onCardRecordButtonClick()
    -- TODO: 相关请求
    if self.model:isPlayingGame() then
        showOrHide(not self.zj.countBg.activeSelf, self.zj.countBg)
    end
end

function LandlordsView:onBackgroundClick()
    hide(self.moreBg)
    self:unSelectHandCards()
    if self.yaobuqi.activeSelf then
        self:onActionButtonClick(LandlordsView.ActionType.yaobuqi.No)
    end
end

function LandlordsView:onBackButtonClick()
    self.controller_:exitScene()
end

function LandlordsView:onTaskButtonClick()
    hide(self.taskRedDot)
    local PanelTask = import("Panel.Task.PanelTask").new(1, 2)
end

function LandlordsView:onMoreButtonClick()
    showOrHide(not self.moreBg.activeSelf, self.moreBg)
end

function LandlordsView:onRuleButtonClick()
    local PanelLandLordsHelper = import("Panel.Special.PanelLandLordsHelper").new()
    self:onMoreButtonClick()
end

function LandlordsView:onRobotButtonClick()
    self:unSelectHandCards()
    self:onMoreButtonClick()
    if self.model.isSelfInGame and self.model:isPlayingGame() then
        GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.AI, 1, {})

        -- 如果这个人的手牌大于1张
        if not self.model:isDizhu() then
            self:showChatBubbleView(LandlordsModel.Player.Ziji, T("本局累计托管")..self.model.roomConfig.drop_line..T("回合，输赢包赔金币"))
        end
    else
        GameManager.TopTipManager:showTopTip(T("你还没在游戏中")) 
    end
end

function LandlordsView:onCancelRobotButtonClick()
    GameManager.ServerManager:setBet(CONSTS.LANDLORDS.ACTION_TYPE.AI, 0, {})
end

function LandlordsView:sliderValueChangedListen(value)
    local cardCount = #self.handCardsArray
    if cardCount == 0 then
        return
    end

    if not self.downValue then
        return
    end

    local downIndex    = self:sliderValueToIndex(self.downValue)
    local currentIndex = self:sliderValueToIndex(value)

    for index, selfCard in ipairs(self.handCardsArray) do
        if (downIndex <= index and index <= currentIndex) or (downIndex >= index and index >= currentIndex) then
            self.handCardsArray[index]:setSelected(true)
        else
            self.handCardsArray[index]:setSelected(false)
        end
    end
end

function LandlordsView:onHandCardsSliderTouch(eventString, pointerEventData)
    if #self.handCardsArray == 0 then
        return
    end
    if eventString == "OnPointerDown" then
        -- 开始选牌
        self.downValue = self.handCardsSlider:GetComponent('Slider').value
        local downIndex = self:sliderValueToIndex(self.downValue)
        self.handCardsArray[downIndex]:setSelected(true)
    elseif eventString == "OnPointerUp" then
        -- 结束选牌
        self.downValue = nil
        self:getSelectedCards()
    end
end

--[[
    智能选牌
]]
function LandlordsView:getSelectedCards()
    for _, selfCard in ipairs(self.handCardsArray) do
        if selfCard.isSelected then
            selfCard.view:GetComponent('Toggle').isOn = not selfCard.view:GetComponent('Toggle').isOn
            selfCard:setSelected(false)
        end
    end
end


return LandlordsView