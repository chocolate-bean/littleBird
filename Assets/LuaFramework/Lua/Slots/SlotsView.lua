local SlotsView         = class("SlotsView")
local ColumnScrollView  = require("Slots.ColumnScrollView")
local SlotsItemView     = require("Slots.SlotsItemView")
local SlotsLineManager  = require("Slots.SlotsLineManager")
local SlotsHelperPanel  = require("Panel.Special.SlotsHelperPanel")
local PanelOtherInfoBig = require("Panel.PlayInfo.PanelOtherInfoBig")

SlotsView.LINE_COUNT       = 9
SlotsView.ROW_COUNT        = 3
SlotsView.COLUMN_COUNT     = 5
SlotsView.OTHER_SEAT_COUNT = 4
SlotsView.SLIDER_TOUCH_TIME = 0.35

SlotsView.BET_TYPE = {
    NORMAL     = 1,
    AUTO_READY = 2,
    AUTOING    = 3,
    BOUND      = 4,
}

SlotsView.SeatPos = {
    {   
        view = {pos = Vector3.New(67, 178, 0), anchors = Vector2.New(0, 0.5)},
    },
    {
        view = {pos = Vector3.New(-67, 178, 0), anchors = Vector2.New(1, 0.5)},
    },
    {   
        view = {pos = Vector3.New(67, 28, 0), anchors = Vector2.New(0, 0.5)},
    },
    {   
        view = {pos = Vector3.New(-67, 28, 0), anchors = Vector2.New(1, 0.5)},
    },
}

function SlotsView:ctor(controller, objs, data)
    self.controller_ = controller
    self.lineManager = SlotsLineManager.new()

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "SlotsView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self:onEnter()

    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()
    self:showAnimation()
end

function SlotsView:onEnter()
    GameManager.SoundManager:playSomething()
    GameManager.SoundManager:ChangeBGM("niuniu/bg")
end

function SlotsView:initProperties(objs)
    self.ColumnScrollViewPrefab = objs[1]
    self.SlotsItemPrefab = objs[2]

    self.lineAnteConfig = GameManager.ChooseRoomManager.slotsConfig.ante_group
    self.lineCount = SlotsView.LINE_COUNT
    self.lineAnteIndex = 1
    self.betState = SlotsView.BET_TYPE.NORMAL
    self.seats = {}
end

function SlotsView:addProperties()
    self.registerProps = {"money"}
    self.registerHandleIds = {}
    for i, key in ipairs(self.registerProps) do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, key, handler(self, self.onUserPropUpdate))
        table.insert(self.registerHandleIds, handleId)    
    end
end

function SlotsView:initUIControls()
    
    self.topView         = self.view.transform:Find("topView").gameObject
    self.backButton      = self.view.transform:Find("topView/topBg/backButton").gameObject
    self.helpButton      = self.view.transform:Find("topView/topBg/helpButton").gameObject
    self.hongbaoButton   = self.view.transform:Find("topView/topBg/HongbaoButton").gameObject
    self.taskButton      = self.view.transform:Find("topView/topBg/TaskButton").gameObject
    self.wifiView        = self.view.transform:Find("topView/topBg/wifiView").gameObject
    self.wifiIcon        = self.view.transform:Find("topView/topBg/wifiView/wifiIcon").gameObject
    self.timeText        = self.view.transform:Find("topView/topBg/wifiView/Text").gameObject
    self.actionView      = self.view.transform:Find("actionView").gameObject
    self.headerButton    = self.view.transform:Find("actionView/actionBg/headerBg/headerButton").gameObject
    self.frameImage      = self.view.transform:Find("actionView/actionBg/headerBg/headerButton/frameImage").gameObject
    self.nameText        = self.view.transform:Find("actionView/actionBg/nameText").gameObject
    self.goldButton      = self.view.transform:Find("actionView/actionBg/goldButton").gameObject
    self.moneyText       = self.view.transform:Find("actionView/actionBg/goldButton/moneyText").gameObject
    self.lineAddButton   = self.view.transform:Find("actionView/actionBg/lineView/addButton").gameObject
    self.lineSubButton   = self.view.transform:Find("actionView/actionBg/lineView/subButton").gameObject
    self.lineNumberText  = self.view.transform:Find("actionView/actionBg/lineView/numberText").gameObject
    self.lineInfoText    = self.view.transform:Find("actionView/actionBg/lineView/infoText").gameObject
    self.anteAddButton   = self.view.transform:Find("actionView/actionBg/anteView/addButton").gameObject
    self.anteSubButton   = self.view.transform:Find("actionView/actionBg/anteView/subButton").gameObject
    self.anteNumberText  = self.view.transform:Find("actionView/actionBg/anteView/numberText").gameObject
    self.anteInfoText    = self.view.transform:Find("actionView/actionBg/anteView/infoText").gameObject
    self.autoToggle      = self.view.transform:Find("actionView/actionBg/autoToggle").gameObject
    self.autoToggleText  = self.view.transform:Find("actionView/actionBg/autoToggle/Text").gameObject
    self.betButton       = self.view.transform:Find("actionView/actionBg/betButton").gameObject
    self.contentView     = self.view.transform:Find("contentView").gameObject
    self.machineLight    = self.view.transform:Find("contentView/machineBg/light").gameObject
    self.jackpotButton   = self.view.transform:Find("contentView/jackpotButton").gameObject
    self.jackpotLight    = self.view.transform:Find("contentView/jackpotButton/lightImage").gameObject
    self.jackpotText     = self.view.transform:Find("contentView/jackpotButton/Text").gameObject
    self.rewardMoneyText = self.view.transform:Find("contentView/moneyBg/Text").gameObject
    self.spinSlider      = self.view.transform:Find("contentView/spinSlider").gameObject
    self.poleImage       = self.view.transform:Find("contentView/spinSlider/poleImage").gameObject
    self.spinShadow      = self.view.transform:Find("contentView/spinSlider/shadow").gameObject
    self.spinButton      = self.view.transform:Find("contentView/spinSlider/spinArea/spinHandle").gameObject
    self.scrollLineView  = self.view.transform:Find("contentView/contentScrollView/lineView").gameObject

    self.seatView        = self.view:findChild("seatView")
    for index = 1, SlotsView.OTHER_SEAT_COUNT do
        local seat = {}
        seat.view = self.view:findChild("seatView/seat ("..index..")")
        seat.normalBg     = seat.view:findChild("normalBg")
        seat.highlightBg  = seat.view:findChild("highlightBg")
        seat.playerView   = seat.view:findChild("playerView")
        seat.headerButton = seat.view:findChild("playerView/headerButton")
        seat.frameImage   = seat.view:findChild("playerView/headerButton/frameImage")
        seat.emoji        = seat.view:findChild("playerView/headerButton/emoji")
        seat.nameText     = seat.view:findChild("playerView/nameText")
        seat.moneyText    = seat.view:findChild("playerView/moneyText")
        seat.emptyView    = seat.view:findChild("emptyView")
        seat.data = nil
        local posConfig = SlotsView.SeatPos[index]
        -- 如果在panel上就已经设置好位置的话 就不需要设置pos
        seat.view.transform.localPosition = posConfig.view.pos
        -- 设置与父控件的对齐方式 
        seat.view.transform:GetComponent('RectTransform').anchorMin = posConfig.view.anchors
        seat.view.transform:GetComponent('RectTransform').anchorMax = posConfig.view.anchors
        seat.headerButton:addButtonClick(function()
            if not seat.data then
                return
            end
            local PanelOtherInfoSmall = import("Panel.PlayInfo.PanelOtherInfoSmall").new(seat.data.uid, nil, nil, 2)
        end)
        self.seats[index] = seat
    end
    -- 红点
    self.redDot1 = self.view.transform:Find("topView/topBg/HongbaoButton/redDot").gameObject
    self.redDot2 = self.view.transform:Find("topView/topBg/TaskButton/redDot").gameObject

    self.lines = {}
    for i = 1, SlotsView.LINE_COUNT do
        self.lines[i] = self.view.transform:Find("contentView/contentScrollView/lineView/line_"..i).gameObject
    end

    self.scrollContentView    = self.view.transform:Find("contentView/contentScrollView/Content").gameObject
    self.highlightContentView = self.view.transform:Find("contentView/highlightScrollView/Content").gameObject

    show(self.frameImage)

    UIHelper.AddButtonClick(self.jackpotButton, buttonSoundHandler(self, self.onJackPotButton))
    UIHelper.AddButtonClick(self.goldButton, buttonSoundHandler(self, self.onGoldButton))
    UIHelper.AddButtonClick(self.backButton, buttonSoundHandler(self, self.onBackButton))
    UIHelper.AddButtonClick(self.helpButton, buttonSoundHandler(self, self.onHelpButtonClick))
    UIHelper.AddButtonClick(self.hongbaoButton, buttonSoundHandler(self, self.onHongbaoButtonClick))
    UIHelper.AddButtonClick(self.taskButton, buttonSoundHandler(self, self.onTaskButtonClick))
    UIHelper.AddButtonClick(self.betButton, buttonSoundHandler(self, self.onBetButtonClick))
    UIHelper.AddButtonClick(self.lineAddButton, buttonSoundHandler(self, self.onLineAddButtonClick))
    UIHelper.AddButtonClick(self.lineSubButton, buttonSoundHandler(self, self.onLineSubButtonClick))
    UIHelper.AddButtonClick(self.anteAddButton, buttonSoundHandler(self, self.onAnteAddButtonClick))
    UIHelper.AddButtonClick(self.anteSubButton, buttonSoundHandler(self, self.onAnteSubButtonClick))

    UIHelper.AddToggleClick(self.autoToggle, function(sender)
        GameManager.SoundManager:PlaySound("clickButton")
        
        -- 老虎机增加限制
        if GameManager.UserData.viplevel < 1 and sender:GetComponent('Toggle').isOn == true then
            GameManager.TopTipManager:showTopTip(T("需要VIP1才能自动下注哦~"))
            sender:GetComponent('Toggle').isOn = false
            return
        end 

        if sender:GetComponent('Toggle').isOn then
            self:betStateChange(SlotsView.BET_TYPE.AUTO_READY)
        else
            if self.betState ~= SlotsView.BET_TYPE.BOUND then
                self:betStateChange(SlotsView.BET_TYPE.NORMAL)
            end
        end
    end)

    UIHelper.AddSliderValueChangedListen(self.spinSlider, function(value)
        self:onSpinSliderValueChange(value)
    end)

    UIHelper.addTouchListener(self.spinSlider, function(eventString, pointerEventData)
        self:onSpinSliderTouch(eventString, pointerEventData)
    end)

end

function SlotsView:initUIDatas()
    self.nameText       :GetComponent('Text').text = GameManager.UserData.name
    self.moneyText      :GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.lineNumberText :GetComponent('Text').text = self.lineCount
    self.lineInfoText   :GetComponent('Text').text = T("连线数量")
    self.anteNumberText :GetComponent('Text').text = self.lineAnteConfig[self.lineAnteIndex]
    self.anteInfoText   :GetComponent('Text').text = T("单线投入")
    self.autoToggleText :GetComponent('Text').text = T("自动")
    self.jackpotText    :GetComponent('Text').text = string.formatNumberThousands(math.random(9999999999))
    self.rewardMoneyText:GetComponent('Text').text = 0
    self.autoToggle:GetComponent('Toggle').isOn  = false
    self.frameImage:GetComponent('Image').sprite = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.headerButton,
        callback = function(sprite)
            if self.view and self.headerButton then
                self.headerButton:GetComponent('Image').sprite = sprite
            end
        end,
    })

    if GameManager.GameConfig.casinoWin == 1 then
        self.hongbaoButton:SetActive(true)
    else
        self.hongbaoButton:SetActive(false)
    end

    self:initContentView()
    self:initHighlightView()
    self:GetRedDot()

    self.timeTimer = Timer.New(function()
        self:updateTimeAndWifi()
    end, 10, 999,true)
    self:updateTimeAndWifi()
    self.timeTimer:Start()
end

-- 刷新用户信息
function SlotsView:onUserPropUpdate()
    self.moneyText:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
end

function SlotsView:GetRedDot()
    -- 检查红点
    http.checkRedDot(
        function(callData)
            
            if callData then
                GameManager.GameFunctions.refashRedDotData(callData)
                
                if callData.winchallenge.dot == 1 then
                    self.redDot1:SetActive(true)
                end

                if callData.task.dot == 1 then
                    self.redDot2:SetActive(true)
                end
            end
        end,
        function (callData)
            
        end
    )
end

function SlotsView:updateDatas(data)
    data = data or {}
    if data.jackpot then
        self.jackpotText:GetComponent('Text').text = string.formatNumberThousands(data.jackpot)
    end
    if data.addMoney then
        self.rewardMoneyText:GetComponent('Text').text = data.addMoney
    end
    self.moneyText:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
end

function SlotsView:updateTimeAndWifi()
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


function SlotsView:initContentView()
    self.cloumnScrollViewArray = {} 
    self.itemArrays = {}

    for column = 1, SlotsView.COLUMN_COUNT do
        local scrollView = ColumnScrollView.new(newObject(self.ColumnScrollViewPrefab), self.SlotsItemPrefab, SlotsItemView)
        scrollView.view.transform:SetParent(self.scrollContentView.transform)
        scrollView.view.transform.localScale = Vector3.one
        scrollView.view.transform.localPosition = Vector3.zero
        self.cloumnScrollViewArray[column] = scrollView
        self.itemArrays[column] = {}

        for row = 1, SlotsView.ROW_COUNT + 6 do
            local singleData = {index = math.random(#SlotsItemView.FRUIT_NAME_CONFIG)}
            local item = scrollView:addItem()
            item:setData(singleData)
            self.itemArrays[column][row] = item
        end
    end
end

function SlotsView:initHighlightView()
    self.highlightItemArrays = {}

    for column = 1, SlotsView.COLUMN_COUNT do
        local scrollView = ColumnScrollView.new(newObject(self.ColumnScrollViewPrefab), self.SlotsItemPrefab, SlotsItemView)
        scrollView.view.transform:SetParent(self.highlightContentView.transform)
        scrollView.view.transform.localScale = Vector3.one
        scrollView.view.transform.localPosition = Vector3.zero
        self.highlightItemArrays[column] = {}

        for row = 1, SlotsView.ROW_COUNT do
            local item = scrollView:addItem()
            item:setData(nil)
            self.highlightItemArrays[column][row] = item
        end
    end
end

function SlotsView:getMoreLineGoalViews(config)
    local moreLineGoalViews = {}
    for lineIndex, goalCount in pairs(config) do
        moreLineGoalViews[lineIndex] = self:getLineGoalViews(lineIndex, goalCount)
    end
    return moreLineGoalViews
end

function SlotsView:getLineGoalViews(lineIndex, goalCount)
    local lineItemView = {}
    local lineConfig = self.lineManager:getLineConfig(lineIndex)
    for column = 1, goalCount do
        local index = lineConfig[column]
        local itemView = self.highlightItemArrays[column][index]
        lineItemView[column] = itemView
    end
    return lineItemView
end

function SlotsView:showLineGoalView(lineIndex)
    self:showLineWithIndex(lineIndex)
    for line, lineGoalViews in pairs(self.moreLineGoalViews) do
        for column, itemView in ipairs(lineGoalViews) do
            itemView:setHighlight(false)
        end
    end

    for column, itemView in ipairs(self.moreLineGoalViews[lineIndex]) do
        itemView:setHighlight(true, self.betState == SlotsView.BET_TYPE.BOUND)
    end
end

function SlotsView:stopShowLineGoalView()
    self:showLineWithCount(0)
    if self.showTimer then
        self.showTimer:Stop()
    end
    if self.moreLineGoalViews then
        for line, lineGoalViews in pairs(self.moreLineGoalViews) do
            for column, itemView in ipairs(lineGoalViews) do
                itemView:setHighlight(false)
            end
        end
    end
end

function SlotsView:showJackPotAnimation()
    local scale = 1.2
    self.jackPotAnimation = self.jackpotButton.transform:DOScale(Vector3.New(scale, scale, scale), 0.3)
    self.jackPotAnimation:SetEase(DG.Tweening.Ease.Linear)
    self.jackPotAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)
end

function SlotsView:stopJackPotAnimation()
    if self.jackPotAnimation then
        self.jackPotAnimation:Kill()
    end
    self.jackpotButton.transform:DOScale(Vector3.New(1, 1, 1), 0.3)
end

function SlotsView:loopShowLineGoalView(lineGoalsDictArray)

    self.lineGoalsDictArray = lineGoalsDictArray

    self.lineGoalsDict = {}
    for _, singleData in ipairs(self.lineGoalsDictArray) do
        self.lineGoalsDict[singleData.lineIndex] = singleData.goalCount 
    end 
    
    self.moreLineGoalViews = self:getMoreLineGoalViews(self.lineGoalsDict)
    self.currentShowIndex = 1

    if #self.lineGoalsDictArray == 0 then
        return
    end

    -- 立即显示先
    function localShowLineGoalView()
        local lineIndex = self.lineGoalsDictArray[self.currentShowIndex].lineIndex
        self:showLineGoalView(lineIndex)
        self.currentShowIndex = self.currentShowIndex + 1
        if self.currentShowIndex > #self.lineGoalsDictArray then
            self.currentShowIndex = 1
        end
    end

    localShowLineGoalView()
    -- 一个的话 就不用交替显示了
    if #self.lineGoalsDictArray == 1 then
        return
    end

    if not self.showTimer then
        local loopTime = 1
        self.showTimer = Timer.New(function()
            localShowLineGoalView()
        end, loopTime, -1, true)
    end
    self.showTimer:Start()
end



function SlotsView:onCleanUp()
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
    if self.showTimer then
        self.showTimer:Stop()
        self.showTimer = nil
    end
    if self.lightLoopTimer then
        self.lightLoopTimer:Stop()
        self.lightLoopTimer = nil    
    end
    GameManager.SoundManager:StopBGM()
    GameManager.SoundManager:StopSoundWithName("WheelLoop")
    for i, columnScrollView in ipairs(self.cloumnScrollViewArray) do
        columnScrollView:onCleanUp()
    end
    destroy(self.view)
    self.view = nil
end

--[[
    外部调用代码
]]

function SlotsView:updateOtherPlayer(player)
    
end

function SlotsView:updateSelfView(userInfo)
    
end


function SlotsView:showOtherPlayerSlotsResult(data)
    
end

function SlotsView:showSelfSlotsResult(data)

end

function SlotsView:sitDown(player)
    for index, seat in ipairs(self.seats) do
        if seat.data == nil then
            seat.data = player
            seat.nameText:setText(player.name)
            seat.moneyText:setText(formatFiveNumber(player.money))
            show(seat.playerView)
            hide(seat.emptyView)
            if player.viplevel and player.viplevel > 0 then
                show(seat.frameImage)
                seat.frameImage:setSprite(GameManager.ImageLoader:getVipFrame(player.viplevel))
            end
            GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                url = player.mavatar,
                sex = tonumber(player.msex),
                node = seat.headerButton,
                callback = function(sprite)
                    if self.view and seat.headerButton then
                        seat.headerButton:setSprite(sprite)
                    end
                end,
            })
            break
        end
    end
end

function SlotsView:updateSeatMoney(playerData)
    for index, seat in ipairs(self.seats) do
        if seat.data and seat.data.uid == playerData.uid then
            if playerData.addMoney > 0 then
                for j = 1, 11 do
                    Timer.New(function()
                        showOrHide(j % 2 == 0, seat.highlightBg)
                        if j == 11 then
                            seat.moneyText:setText(formatFiveNumber(playerData.money))
                        end
                    end, j * 0.1, 1, true):Start()
                end
            else
                seat.moneyText:setText(formatFiveNumber(playerData.money))
            end 
            break
        end
    end
end

function SlotsView:standUp(player)
    local seatIndex = 0
    for index, seat in ipairs(self.seats) do
        if seat.data and seat.data.uid == player.uid then
            seat.data = nil
            seatIndex = index
            show(seat.emptyView)
            hide(seat.playerView)
            break
        end
    end
end

--[[
    animation
]]

function SlotsView:showAnimation()

    local lightLoopTime = 1/3
    self.lightLoopIndex = 1
    
    self.lightLoopTimer = Timer.New(function()
        if self.lightLoopIndex > 3 then
            self.lightLoopIndex = 1
        end
        self.machineLight:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/SGKH_dk_"..self.lightLoopIndex)
        self.jackpotLight:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/SGKH_jcdk_"..self.lightLoopIndex)
        self.lightLoopIndex = self.lightLoopIndex + 1
    end, lightLoopTime, -1, true)

    self.lightLoopTimer:Start()
    GameManager.AnimationManager:addPanelShowAnimation(self.topView, 6, function()
        self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-16,0))
        self:addProperties()
    end)
    GameManager.AnimationManager:addPanelShowAnimation(self.contentView, 5)
    GameManager.AnimationManager:addPanelShowAnimation(self.actionView, 5)
end

function SlotsView:exitSceneAnimation(completeCallback)
    if self.NoticeManager then
        self.NoticeManager:onClean()
    end
    GameManager.AnimationManager:addPanelDismissAnimation(self.topView, 3)
    GameManager.AnimationManager:addPanelDismissAnimation(self.actionView, 2)
    GameManager.AnimationManager:addPanelDismissAnimation(self.contentView, 2, function()
        self:onCleanUp()
        if completeCallback then
            completeCallback()
        end
    end)
end

--[[
    复用代码
]]

function SlotsView:showLineWithCount(count)
    for i, line in ipairs(self.lines) do
        if i <= count then
            show(line)
        else
            hide(line)
        end
    end
end

function SlotsView:showLineWithIndex(index)
    if 1 <= index and index <= SlotsView.LINE_COUNT then
        for i, line in ipairs(self.lines) do
            if i == index then
                show(line)
            else
                hide(line)
            end
        end
    end
end

function SlotsView:lineCountChange()
    if self.lineCount > SlotsView.LINE_COUNT then
        self.lineCount = 1
    elseif self.lineCount < 1 then
        self.lineCount = SlotsView.LINE_COUNT
    end
    self.lineNumberText:GetComponent('Text').text = self.lineCount
    self:showLineWithCount(self.lineCount)
end

function SlotsView:lineAnteIndexChange()
    if self.lineAnteIndex > #self.lineAnteConfig then
        self.lineAnteIndex = 1
    elseif self.lineAnteIndex < 1 then
        self.lineAnteIndex = #self.lineAnteConfig
    end
    self.anteNumberText:GetComponent('Text').text = self.lineAnteConfig[self.lineAnteIndex]
end

function SlotsView:start()
    -- 复原某些
    GameManager.SoundManager:PlaySoundWithNewSource("WheelLoop", true)
    self:stopShowLineGoalView()
    self.rewardMoneyText:GetComponent('Text').text = 0
    self:disableSomething()
    for i, columnScrollView in ipairs(self.cloumnScrollViewArray) do
        columnScrollView:setContentSize()
        Timer.New(function()
            columnScrollView:startScrollLoop()
        end, ColumnScrollView.INTERVAL_TIME * (i - 1), 0, true):Start()
    end
end

function SlotsView:stopWithResults(results, completeCallback)
    -- GameManager.SoundManager:PlaySoundWithNewSource("WheelEnd")
    GameManager.SoundManager:StopSoundWithName("WheelLoop")
    if results and #results == SlotsView.COLUMN_COUNT then
        for column, columnScrollView in ipairs(self.cloumnScrollViewArray) do
            columnScrollView:setContentSize()
            Timer.New(function()
                GameManager.SoundManager:PlaySoundWithNewSource("slotFruitStop"..column)
                if column == SlotsView.COLUMN_COUNT then
                    columnScrollView:stopScrollLoopWithData(results[column], function()
                        if completeCallback then
                            completeCallback()
                        end
                    end)
                else
                    columnScrollView:stopScrollLoopWithData(results[column])
                end
                -- 获取红点数据
                self:GetRedDot()
            end, ColumnScrollView.INTERVAL_TIME * (column - 1), 0, true):Start()
        end
    end
end

function SlotsView:disableSomething()
    self.lineAddButton:GetComponent('Button').interactable = false
    self.lineSubButton:GetComponent('Button').interactable = false
    self.anteAddButton:GetComponent('Button').interactable = false
    self.anteSubButton:GetComponent('Button').interactable = false
    self.betButton    :GetComponent('Button').interactable = false
    self.spinSlider   :GetComponent('Slider').interactable = false

    if self.betState == SlotsView.BET_TYPE.AUTOING then
        self.betButton:GetComponent('Button').interactable = true
        self.autoToggle:GetComponent('Toggle').interactable = false
    end

end

function SlotsView:enableSomething()
    self.lineAddButton:GetComponent('Button').interactable = true
    self.lineSubButton:GetComponent('Button').interactable = true
    self.anteAddButton:GetComponent('Button').interactable = true
    self.anteSubButton:GetComponent('Button').interactable = true
    self.betButton    :GetComponent('Button').interactable = true
    self.spinSlider   :GetComponent('Slider').interactable = true
end

function SlotsView:betStateChange(state)

    -- 之前是自动 变成了 奖励
    if  self.betState == SlotsView.BET_TYPE.AUTOING
    and state == SlotsView.BET_TYPE.BOUND then
        self.betState = state
    end

    -- 之前是奖励 变回了自动
    if self.betState == SlotsView.BET_TYPE.BOUND 
    and state == SlotsView.BET_TYPE.NORMAL then
        if self.autoToggle:GetComponent('Toggle').isOn then
            state = SlotsView.BET_TYPE.AUTO_READY
        end
        self.betState = state
    end

    self.betState = state
    self.autoToggle:GetComponent('Toggle').interactable = true

    local imageName
    local spinImageName = "btn_spin"
    if self.betState == SlotsView.BET_TYPE.NORMAL then
        imageName = "btn_touzhu"
        self.autoToggle:GetComponent('Toggle').isOn = false
    elseif self.betState == SlotsView.BET_TYPE.AUTO_READY then
        imageName = "btn_zidongtou"
    elseif self.betState == SlotsView.BET_TYPE.AUTOING then
        imageName = "btn_stop"
        self.autoToggle:GetComponent('Toggle').interactable = false
    elseif self.betState == SlotsView.BET_TYPE.BOUND then
        imageName = "btn_mianfei"
        spinImageName = "btn_free"
        self.autoToggle:GetComponent('Toggle').interactable = false
    end
    self.betButton:GetComponent('Image').sprite  = UIHelper.LoadSprite("Images/PanelSlots/"..imageName)
    self.spinButton:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/"..spinImageName)
end

--[[
    event handle
]]

function SlotsView:onGoldButton()
    GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.SLOTROOM
    -- local PanelShop = import("Panel.Shop.PanelShop").new()
    -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
    local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
end

function SlotsView:onBackButton()
    self.controller_:exitScene()
end

function SlotsView:onJackPotButton()
    local data = {
        micon = GameManager.ChooseRoomManager.slotsConfig.log.micon,
        msex = GameManager.ChooseRoomManager.slotsConfig.log.msex or 0,
        name = GameManager.ChooseRoomManager.slotsConfig.log.name or "name",
        totle = self.controller_.model.tableInfo.totalAnte,
        win = GameManager.ChooseRoomManager.slotsConfig.log.win or "---",
        index = SlotsHelperPanel.INDEX_CONFIG.JACKPOT,
    }
    SlotsHelperPanel.new(data)
end

function SlotsView:onHongbaoButtonClick()
    self.redDot1:SetActive(false)
    local PanelTotalRedpacket = import("Panel.Operation.PanelTotalRedpacket").new()
end

function SlotsView:onTaskButtonClick()
    self.redDot2:SetActive(false)
    local PanelTask = import("Panel.Task.PanelTask").new(1, 2)
end

function SlotsView:onHelpButtonClick()
    local data = {
        micon = GameManager.ChooseRoomManager.slotsConfig.log.micon,
        msex = GameManager.ChooseRoomManager.slotsConfig.log.msex or 0,
        name = GameManager.ChooseRoomManager.slotsConfig.log.name or "name",
        totle = self.controller_.model.tableInfo.totalAnte,
        win = GameManager.ChooseRoomManager.slotsConfig.log.win or "---",
        index = SlotsHelperPanel.INDEX_CONFIG.JACKPOT,
    }
    dump(data)
    SlotsHelperPanel.new(data)
end

function SlotsView:onBetButtonClick()
    if self.betState == SlotsView.BET_TYPE.AUTOING then
        self.betState = SlotsView.BET_TYPE.AUTO_READY
        self:betStateChange(SlotsView.BET_TYPE.AUTO_READY)
        self:disableSomething()
        return
    end
    
    self:autoSpin()
end

function SlotsView:onLineAddButtonClick()
    self:stopShowLineGoalView()
    self.lineCount = self.lineCount + 1
    self:lineCountChange()
end

function SlotsView:onLineSubButtonClick()
    self:stopShowLineGoalView()
    self.lineCount = self.lineCount - 1
    self:lineCountChange()
end

function SlotsView:onAnteAddButtonClick()
    self.lineAnteIndex = self.lineAnteIndex + 1
    self:lineAnteIndexChange()
end

function SlotsView:onAnteSubButtonClick()
    self.lineAnteIndex = self.lineAnteIndex - 1
    self:lineAnteIndexChange()
end

function SlotsView:onSpinSliderValueChange(value)
    local xAngle = 90 * value
    self.poleImage.transform.localEulerAngles = Vector3.New(xAngle, 0, 0)
    local originY = -20
    local offset = -50
    local poleY = originY + offset * value
    self.poleImage.transform.localPosition = Vector3.New(self.poleImage.transform.localPosition.x, poleY, 0)

    local originY = 140
    local offset = -140
    local shadowY = originY + offset * value
    self.spinShadow.transform.localPosition = Vector3.New(self.spinShadow.transform.localPosition.x, shadowY, 0)
end

function SlotsView:onSpinSliderTouch(string, pointerEventData)
    if string == "" then
    elseif string == "OnPointerUp" then
        if self.spinSlider:GetComponent('Slider').interactable then
            self:autoSpin()
        end
        self.spinSlider:GetComponent('Slider').interactable = false
    end
end

function SlotsView:autoSpin(dontSendBet)

    self:disableSomething()

    GameManager.SoundManager:PlaySoundWithNewSource("SlotAutoBet")
    local currentValue = self.spinSlider:GetComponent('Slider').value
    local time = SlotsView.SLIDER_TOUCH_TIME
    if self.spinSlider:GetComponent('Slider').value >= 0 then
        local sequence = DG.Tweening.DOTween.Sequence()
        sequence:SetEase(DG.Tweening.Ease.Linear)
        local downAnimation = self.spinSlider:GetComponent('Slider'):DOValue(1, (1 - currentValue) * time)
        sequence:Append(downAnimation)
        sequence:Append(self.spinSlider:GetComponent('Slider'):DOValue(0, time))
        downAnimation:OnComplete(function()
            -- self.spinSlider:GetComponent('Slider').interactable = true
            if not dontSendBet then
                if GameManager.UserData.money >= (self.lineCount * self.lineAnteConfig[self.lineAnteIndex]) then
                    GameManager.ServerManager:soltsBet(self.lineCount, self.lineAnteConfig[self.lineAnteIndex], 0)
                else
                    GameManager.TopTipManager:showTopTip(T("您的金币不足"))
                    self:enableSomething()
                    self:betStateChange(SlotsView.BET_TYPE.NORMAL)
                end
            else
                self:start()
            end
        end)
        if currentValue == 1 then
            if not dontSendBet then
                if GameManager.UserData.money >= (self.lineCount * self.lineAnteConfig[self.lineAnteIndex]) then
                    GameManager.ServerManager:soltsBet(self.lineCount, self.lineAnteConfig[self.lineAnteIndex], 0)
                else
                    GameManager.TopTipManager:showTopTip(T("您的金币不足"))
                    self:enableSomething()
                    self:betStateChange(SlotsView.BET_TYPE.NORMAL)
                end
            else
                self:start()
            end
        end
        sequence:OnComplete(function()
            -- self.spinSlider:GetComponent('Slider').interactable = true
        end)
    else
        -- 由于上面判断是>=0 所以就是玩家一点就出发了
        -- local animation = self.spinSlider:GetComponent('Slider'):DOValue(0, currentValue * time)
        -- animation:OnComplete(function()
        --     if not dontSendBet then
        --         GameManager.ServerManager:soltsBet(self.lineCount, self.lineAnteConfig[self.lineAnteIndex], 0)
        --     else
        --         self:start()
        --     end
        -- end)
    end
end


return SlotsView