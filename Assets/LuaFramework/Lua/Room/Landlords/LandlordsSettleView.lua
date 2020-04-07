local LandlordsSettleView = class("LandlordsSettleView")
local InteractiveAnimation = require("Room/InteractiveAnimation")

--[[
    //1地主赢 2农民赢
]]
LandlordsSettleView.WinnerResult = {
    Landlords = 1,
    Farmer    = 2,
}

LandlordsSettleView.Event = {
    Ready     = 1,
    Change    = 2,
    Back      = 3,
    InitDone  = 4,
    Dismiss   = 5,
    Gold      = 6,
    Redpacket = 7,
    LevelUp   = 8,
}

LandlordsSettleView.AnimationTime = {
    FirstShow  = 0.5,
    SecondShow = 0.5,
    Interval   = 1,
    Delay      = 0.05,
}

LandlordsSettleView.ColorConfig = {
    Other     = Color.white,
    Self      = Color.New(255/255,231/255,97/255,1),
    WinTitle  = Color.New(255/255,223/255,192/255,1),
    LoseTitle = Color.New(152/255,188/255,255/255,1),
}

LandlordsSettleView.NormalColor = Color.white
LandlordsSettleView.SelfColor   = Color.New(255/255,231/255,97/255,1)

function LandlordsSettleView:ctor(param, callback)
    resMgr:LoadPrefabByRes("Room", { "SettlePanel" }, function(objs)
        self:initView(objs, param, callback)
    end)
end

function LandlordsSettleView:initView(objs, param, callback)

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "LandlordsSettleView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self:initProperties(callback)
    self:initUIControls()
    self:initUIDatas(param)
    self:show()
end

function LandlordsSettleView:initProperties(callback)
    self.callback = callback
end

function LandlordsSettleView:initUIControls()
    self.winnerResultView  = self.view.transform:Find("winnerResultView").gameObject
    self.winnerIcon        = self.view.transform:Find("winnerResultView/winnerIcon").gameObject
    self.settleView        = self.view.transform:Find("settleView").gameObject
    self.contentBg         = self.view.transform:Find("settleView/contentBg").gameObject
    self.contentView       = self.view.transform:Find("settleView/contentBg/contentView").gameObject
    self.titleImage        = self.view.transform:Find("settleView/contentBg/contentView/titleImage").gameObject
    self.rightPoker        = self.view.transform:Find("settleView/contentBg/contentView/titleImage/rightPoker").gameObject
    self.leftPoker         = self.view.transform:Find("settleView/contentBg/contentView/titleImage/leftPoker").gameObject
    self.star              = self.view.transform:Find("settleView/contentBg/contentView/titleImage/star").gameObject
    self.changeRoomButton  = self.view.transform:Find("settleView/contentBg/contentView/changeRoomButton").gameObject
    self.changeRoomImage   = self.view.transform:Find("settleView/contentBg/contentView/changeRoomButton/Image").gameObject
    self.readyButton       = self.view.transform:Find("settleView/contentBg/contentView/readyButton").gameObject
    self.readyImage        = self.view.transform:Find("settleView/contentBg/contentView/readyButton/Image").gameObject
    self.goldButton        = self.view.transform:Find("settleView/contentBg/contentView/goldButton").gameObject
    self.goldText          = self.view.transform:Find("settleView/contentBg/contentView/goldButton/Text").gameObject
    self.goldInfoText      = self.view.transform:Find("settleView/contentBg/contentView/goldButton/infoText").gameObject
    self.redpacketButton   = self.view.transform:Find("settleView/contentBg/contentView/redpacketButton").gameObject
    self.redpacketText     = self.view.transform:Find("settleView/contentBg/contentView/redpacketButton/Text").gameObject
    self.redpacketInfoText = self.view.transform:Find("settleView/contentBg/contentView/redpacketButton/infoText").gameObject
    self.resultView        = self.view.transform:Find("settleView/contentBg/contentView/resultView").gameObject
    self.levelUpButton     = self.view.transform:Find("settleView/contentBg/contentView/levelUpButton").gameObject
    self.girlImage         = self.view.transform:Find("settleView/girlImage").gameObject
    self.backButton        = self.view.transform:Find("settleView/backButton").gameObject

    self.titleName      = self.resultView.transform:Find("infoView/name").gameObject
    self.titleAnte      = self.resultView.transform:Find("infoView/ante").gameObject
    self.titleMulitiple = self.resultView.transform:Find("infoView/mulitiple").gameObject
    self.titleMoney     = self.resultView.transform:Find("infoView/money").gameObject

    self.infoItems = {}
    for index = 1, 3 do
        local infoView = self.resultView.transform:Find("infoView ("..index..")").gameObject
        local item = {}
        item.name           = infoView.transform:Find("name").gameObject
        item.money          = infoView.transform:Find("money").gameObject
        item.mulitiple      = infoView.transform:Find("mulitiple").gameObject
        item.ante           = infoView.transform:Find("ante").gameObject
        item.dizhuIcon      = infoView.transform:Find("name/dizhuIcon").gameObject
        item.settleIcon     = infoView.transform:Find("money/settleState/settleIcon").gameObject
        item.settleTips     = infoView.transform:Find("money/settleState/settleIcon/tips").gameObject
        item.settleTipsText = infoView.transform:Find("money/settleState/settleIcon/tips/Text").gameObject
        item.bokenIcon      = infoView.transform:Find("money/settleState/bokenIcon").gameObject
        self.infoItems[index] = item

        UIHelper.AddButtonClick(item.settleIcon, buttonSoundHandler(self,function()
            showOrHide(not item.settleTips.activeSelf, item.settleTips)
        end))

        UIHelper.AddButtonClick(item.settleTips, buttonSoundHandler(self,function()
            showOrHide(not item.settleTips.activeSelf, item.settleTips)
        end))
    end

    UIHelper.AddButtonClick(self.readyButton, buttonSoundHandler(self, function()
        if self.callback then
            self.callback(LandlordsSettleView.Event.Ready)
        end
        self:onClose()
    end))

    UIHelper.AddButtonClick(self.changeRoomButton, buttonSoundHandler(self, function ()
        if self.callback then
            self.callback(LandlordsSettleView.Event.Change)
        end
        self:onClose()
    end))

    UIHelper.AddButtonClick(self.goldButton, buttonSoundHandler(self, function ()
        if self.callback then
            self.callback(LandlordsSettleView.Event.Gold)
        end
        self:dismissExchangeRedpacket()
    end))

    UIHelper.AddButtonClick(self.redpacketButton, buttonSoundHandler(self, function ()
        if self.callback then
            self.callback(LandlordsSettleView.Event.Redpacket)
        end

        local getRedpacket = self.redpacketText:GetComponent('Text').text
        if GameManager.UserData.jewelGain + tonumber(getRedpacket) > GameManager.UserData.jewelLimit then
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("红包上限提示"),
                text = T(string.format("赢太多啦!达到今日领取上限%s\n请去提升VIP等级！", GameManager.UserData.jewelLimit)),
                firstButtonCallbcak = function()
                    if self.callback then
                        self.callback(LandlordsSettleView.Event.LevelUp)
                    end
                end,
            })
            return
        end

        if self.param and self.param.userInfo[1] then
            http.exchangeJewel(self.param.userInfo[1].addMoney,
            function(retData)
                if retData.flag == 1 then
                    GameManager.UserData.money = GameManager.UserData.money - self.param.userInfo[1].addMoney
                    GameManager.GameFunctions.setJewel(tonumber(retData.latest_jewel))
                    GameManager.UserData.jewelGain = GameManager.UserData.jewelGain + retData.jewel
                    GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),"3",T("红包券x")..retData.jewel,"")
                    self:dismissExchangeRedpacket()
                else
                    GameManager.TopTipManager:showTopTip(T("兑换红包失败")) 
                end
            end,
            function(callbackData)
                GameManager.TopTipManager:showTopTip(T("兑换红包失败")) 
            end)
        end
    end))

    UIHelper.AddButtonClick(self.levelUpButton, buttonSoundHandler(self, function ()
        if self.callback then
            self.callback(LandlordsSettleView.Event.LevelUp)
        end
    end))

    UIHelper.AddButtonClick(self.backButton, buttonSoundHandler(self, function ()
        if self.callback then
            self.callback(LandlordsSettleView.Event.Back)
        end
        self:onClose()
    end))
end

function LandlordsSettleView:initUIDatas(param)
    -- self.result.winnerResult = data.result
    -- self.result.selfResult
    -- userInfo[player] = {
        --         name        = self.playerList[index].name,
        --         addMoney    = playInfo.addMoney,
        --         userMoney   = playInfo.userMoney,
        --         settleState = playInfo.settleState, --结算状态 0正常结算 1封顶 2包赔
        --         isDizhu     = isDizhu,
        --         mulitiple   = isDizhu and self.mulitiple * 2 or self.mulitiple,
        --         uid         = playInfo.uid,
        --     }
    -- self.result.userInfo = userInfo

    self.param = param
    
    local showStateImage = ""
    if param.isSelfWinner then
        if param.isSelfDizhu then
            showStateImage = "Images/SceneLandlords/settle/image_win_dz"
        else
            showStateImage = "Images/SceneLandlords/settle/image_win_nm"
        end
    else
        if param.isSelfDizhu then
            showStateImage = "Images/SceneLandlords/settle/image_lose_dz"
        else
            showStateImage = "Images/SceneLandlords/settle/image_lose_nm"
        end
    end
    self.winnerIcon:GetComponent('Image').sprite = UIHelper.LoadSprite(showStateImage)
    self.winnerIcon:GetComponent('Image'):SetNativeSize()
    
    if param.isSelfWinner then
        self.contentView.transform.localPosition = Vector3.New(168,-51,0)
        self.contentBg:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SceneLandlords/settle/bg_win")
        self.titleImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SceneLandlords/settle/title_win")
        self:setTextColor(
            {self.titleName,
            self.titleMoney,
            self.titleMulitiple,
            self.titleAnte,
            }, LandlordsSettleView.ColorConfig.WinTitle)

        -- 0是关闭 无法兑换
        if param.redpacketExchangeSwitch == 1 then
            self:showExchangeRedpacket()
        else
            self:dismissExchangeRedpacket()
        end
    else
        self.contentView.transform.localPosition = Vector3.New(0,-51,0)
        self.contentBg:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SceneLandlords/settle/bg_lose")
        self.titleImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SceneLandlords/settle/title_lose")
        self:setTextColor(
            {self.titleName,
            self.titleMoney,
            self.titleMulitiple,
            self.titleAnte,
            }, LandlordsSettleView.ColorConfig.LoseTitle)
        self:dismissExchangeRedpacket()
    end

    local result = param
    for index, userInfo in ipairs(result.userInfo) do
        local infoItem = self.infoItems[index]
        infoItem.name     :GetComponent('Text').text = userInfo.name
        infoItem.money    :GetComponent('Text').text = userInfo.addMoney
        infoItem.mulitiple:GetComponent('Text').text = userInfo.mulitiple
        infoItem.ante     :GetComponent('Text').text = userInfo.ante
        local color = LandlordsSettleView.ColorConfig.Other
        if userInfo.uid == GameManager.UserData.mid then
            color = LandlordsSettleView.ColorConfig.Self
            GameManager.UserData.money = userInfo.userMoney
        end
        self:setTextColor(
            {infoItem.name,
            infoItem.money,
            infoItem.mulitiple,
            infoItem.ante,
            }, color)
        showOrHide(userInfo.isDizhu, infoItem.dizhuIcon)

        -- 封顶 包赔 这些
        if userInfo.settleState ~= 0 then
            showOrHide(true, infoItem.settleIcon)
            showOrHide(true, infoItem.settleTips)
            local settleTipsString = ""
            local settleStateImage = ""
            if userInfo.settleState == 1 then
                settleStateImage = "Images/SceneLandlords/settle/icon_fd"
                settleTipsString = T("封顶为携带上限\n携带:")..formatFiveNumber(userInfo.addMoney)
            elseif userInfo.settleState == 2 then
                settleStateImage = "Images/SceneLandlords/settle/icon_bp"
                local baopeiTime = result.baopeiTime
                settleTipsString = T("超时或托管回合数大于")..baopeiTime..T("次")
            else
                showOrHide(false, infoItem.settleIcon)
                showOrHide(false, infoItem.settleTips)
            end
            infoItem.settleIcon:GetComponent('Image').sprite = UIHelper.LoadSprite(settleStateImage)
            infoItem.settleTipsText:GetComponent('Text').text = settleTipsString
        else
            showOrHide(false, infoItem.settleIcon)
            showOrHide(false, infoItem.settleTips)
        end
        showOrHide(userInfo.isBankrupt, infoItem.bokenIcon)
    end        

end

function LandlordsSettleView:updateUIDatas(type)

end

function LandlordsSettleView:showExchangeRedpacket()
    local selfResult = self.param.userInfo[1]
    self.goldText:setText(selfResult.addMoney)

    local redpacketCountNumber = math.floor(selfResult.addMoney / self.param.redpacketExchangeRate)
    self.redpacketText:setText(redpacketCountNumber)

    self.redpacketInfoText:setText(string.format(T("每日可领红包  <color=#FFFF00>%d/%d</color>"), GameManager.UserData.jewelGain, GameManager.UserData.jewelLimit))

    self.timeNumber = 10
    self.countTime = Timer.New(function()
        self.goldInfoText:setText(string.format(T("请选择奖励(%d)"), self.timeNumber))
        self.timeNumber = self.timeNumber - 1
        if self.timeNumber == 1 then
            self:dismissExchangeRedpacket()
        end
    end,1,10,true)
    self.countTime:Start()
end

function LandlordsSettleView:dismissExchangeRedpacket()
    show({self.readyButton, self.changeRoomButton})
    hide({self.goldButton, self.redpacketButton})
    if self.countTime then
        self.countTime:Stop()
        self.countTime = nil
    end
end

function LandlordsSettleView:show()
    GameManager.PanelManager:addPanel(self, true)
    self:showAnimation()
end

function LandlordsSettleView:onClose()
    if self.callback then
        self.callback(LandlordsSettleView.Event.Dismiss)
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

--[[
    private method
]]

function LandlordsSettleView:setTextColor(objOrList, color)
    if type(objOrList) == "userdata" then
		objOrList:GetComponent('Text').color = color
	elseif type(objOrList) == "table" then
		for _, v in ipairs(objOrList) do
			v:GetComponent('Text').color = color
		end
	end
end

--[[
    animation
]]

function LandlordsSettleView:showAnimation()
    --[[
        第一幅动画
    ]]

    local param = self.param

    show(self.winnerResultView)
    local animationTime = LandlordsSettleView.AnimationTime.FirstShow

    self.winnerIcon.transform.localScale = Vector3.New(3,3,3);
    self.winnerIcon:GetComponent('Image').color = Color.New(255/255,255/255,255/255,0)

    local scaleAnimation = self.winnerIcon.transform:DOScale(Vector3.one, animationTime)
    scaleAnimation:SetEase(DG.Tweening.Ease.OutQuint)
    local colorAnimation = self.winnerIcon:GetComponent('Image'):DOColor(Color.New(255/255,255/255,255/255,1), animationTime)
    colorAnimation:SetEase(DG.Tweening.Ease.OutQuint)
    
    Timer.New(function()
        --[[
            第二幅动画
        ]]
        hide(self.winnerResultView)
        show(self.settleView)

        if self.callback then
            self.callback(LandlordsSettleView.Event.InitDone)
        end

        local animationTime = LandlordsSettleView.AnimationTime.SecondShow
        local delayTime     = LandlordsSettleView.AnimationTime.Delay
        
        if param.isSelfWinner then
            show(self.girlImage)
            show(self.star)
            hide({self.rightPoker, self.leftPoker})
            self.girlImage.transform.localPosition = Vector3.New(-453 - 1280, -41.5, 0)
            self.girlImage.transform:DOLocalMoveX(-453, animationTime)

            self.contentBg.transform.localPosition = Vector3.New(1280, 0, 0)
            self.contentBg.transform:DOLocalMoveX(0, animationTime)

            doFadeShow(self.titleImage, 'Image', animationTime, delayTime)
            doFadeShow(self.contentBg, 'Image', animationTime + delayTime * 6, delayTime * 2)

            doFadeShow(self.titleName, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleAnte, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleMulitiple, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleMoney, 'Text', animationTime, delayTime * 2)

            for index, item in ipairs(self.infoItems) do
                doFadeShow(item.name, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.money, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.mulitiple, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.ante, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.dizhuIcon, 'Image', animationTime, delayTime * (3 + index))
                doFadeShow(item.settleIcon, 'Image', animationTime, delayTime * (3 + index))
            end

            -- 0是关闭 无法兑换
            if param.redpacketExchangeSwitch == 0 then
                doFadeShow(self.changeRoomButton, 'Image', animationTime, delayTime * 6)
                doFadeShow(self.changeRoomImage, 'Image', animationTime, delayTime * 6)
                doFadeShow(self.readyButton, 'Image', animationTime, delayTime * 6)
                doFadeShow(self.readyImage, 'Image', animationTime, delayTime * 6)
            else
                doFadeAutoShow(self.goldButton, 'Image', animationTime, delayTime * 6)
                doFadeAutoShow(self.goldText, 'Text', animationTime, delayTime * 6)
                doFadeAutoShow(self.redpacketButton, 'Image', animationTime, delayTime * 6)
                doFadeAutoShow(self.redpacketText, 'Text', animationTime, delayTime * 6)
                doFadeAutoShow(self.levelUpButton, 'Image', animationTime, delayTime * 6)

                doFadeAutoShow(self.goldInfoText, 'Text', animationTime, delayTime * 7)
                doFadeAutoShow(self.redpacketInfoText, 'Text', animationTime, delayTime * 7)
            end
            self.starScaleAnimation = self.star.transform:DOScale(Vector3.New(0.2,0.2,0.2), animationTime * math.random(3, 5))
            self.starScaleAnimation:SetEase(DG.Tweening.Ease.Linear)
            self.starScaleAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)

            self.starRotateAnimation = self.star.transform:DOLocalRotate(Vector3.New(0,0, math.random(135) + 90), animationTime * math.random(2, 5))
            self.starRotateAnimation:SetEase(DG.Tweening.Ease.Linear)
            self.starRotateAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)

        else
            hide(self.girlImage)
            hide(self.star)
            show({self.rightPoker, self.leftPoker})
            doFadeShow(self.titleImage, 'Image', animationTime, delayTime)
            doFadeShow(self.contentBg, 'Image', animationTime + delayTime * 6, delayTime * 2)

            doFadeShow(self.titleName, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleAnte, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleMulitiple, 'Text', animationTime, delayTime * 2)
            doFadeShow(self.titleMoney, 'Text', animationTime, delayTime * 2)

            for index, item in ipairs(self.infoItems) do
                doFadeShow(item.name, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.money, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.mulitiple, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.ante, 'Text', animationTime, delayTime * (3 + index))
                doFadeShow(item.dizhuIcon, 'Image', animationTime, delayTime * (3 + index))
                doFadeShow(item.settleIcon, 'Image', animationTime, delayTime * (3 + index))
            end

            doFadeShow(self.changeRoomButton, 'Image', animationTime, delayTime * 6)
            doFadeShow(self.changeRoomImage, 'Image', animationTime, delayTime * 6)
            doFadeShow(self.readyButton, 'Image', animationTime, delayTime * 6)
            doFadeShow(self.readyImage, 'Image', animationTime, delayTime * 6)

            self.leftPokerAnimation = self.leftPoker.transform:DOLocalMove(Vector3.New(-199.6,51.5,0), animationTime * math.random(3, 5))
            self.leftPokerAnimation:SetEase(DG.Tweening.Ease.Linear)
            self.leftPokerAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)

            self.rightPokerAnimation = self.rightPoker.transform:DOLocalMove(Vector3.New(166.8, 0, 0), animationTime * math.random(3, 5))
            self.rightPokerAnimation:SetEase(DG.Tweening.Ease.Linear)
            self.rightPokerAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)
        end
    end, LandlordsSettleView.AnimationTime.Interval, 1, true):Start()
end

return LandlordsSettleView