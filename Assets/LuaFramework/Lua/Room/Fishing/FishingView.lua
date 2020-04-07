local FishingView          = class("FishingView")
local FishingController    = require("Room.Fishing.FishingController")
local FishingModel         = require("Room.Fishing.FishingModel")
local PanelOtherInfoSmall  = require("Panel.PlayInfo.PanelOtherInfoSmall")
local PanelShop            = require("Panel.Shop.PanelShop")
local PanelExchange        = require("Panel.Shop.PanelSmallShop")--require("Panel.Exchange.PanelExchange")
local PanelTask            = require("Panel.Task.PanelTask")
local Card                 = require("Room.Landlords.Card")
local InteractiveAnimation = require("Room.InteractiveAnimation")
local PanelRedpacketRule   = require("Panel.FishingGame.PanelRedpacketRule")
local PanelFishBook        = require("Panel.FishingGame.PanelFishBook")
local PanelFishingSetting  = require("Panel.FishingGame.PanelFishingSetting")
local PanelFishExit        = require("Panel.FishingGame.PanelFishExit")
local PanelBossComing      = require("Panel.FishingGame.PanelBossComing")
local PanelSmallShop       = require("Panel.Shop.PanelNewShop")--require("Panel.Shop.PanelSmallShop")
local PanelFirstPay        = require("Panel.Operation.PanelFirstPay")
--[[
    3       4

    1       2
]]
FishingView.SeatPos = {
    {   
        view   = {pos = Vector3.New(230, 40, 0), anchors = Vector2.New(0, 0)},
    },
    {
        view   = {pos = Vector3.New(-230, 40, 0), anchors = Vector2.New(1, 0)},
    },
    {   
        view   = {pos = Vector3.New(230, -40, 0), anchors = Vector2.New(0, 1)},
    },
    {   
        view   = {pos = Vector3.New(-230, -40, 0), anchors = Vector2.New(1, 1)},
    },
}

FishingView.CONST = {
    Time = {
        MoreAnimation = 0.7,
        CannonUpgrade = 0.7,
        Redpacket     = 0.7,
        NuClearBomb   = 0.7,
    },
    Count = {
        SeatMidIndex   = 2,
        SeatCount      = 4,
        OperationCount = 2,
        NuClearBombMax = 4,
    },
    Value = {
        MoreOpenX       = 103,
        MoreCloseX      = -195,
        RedpacketUpY    = 95,
        RedpacketDownY  = -8.5,
        NormalTaskUpY   = 95,
        NormalTaskDownY = -8.5,
        PropWidth       = 125,
        UpgradeWidth    = 345,
    }
}


function FishingView:ctor(controller, objs, data)
    self.controller_ = controller
    self.model = controller.model
    
    self.interactiveAnimation = InteractiveAnimation.new()

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "FishingView"
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

function FishingView:onEnter()
    GameManager.SoundManager:playSomething()
    GameManager.SoundManager:ChangeBGM("fishingGame/bgm_Login")
end


function FishingView:initProperties(objs)

    self.selfSeatTips = objs[1]
    self.seatCannonSprint = objs[2]

    self.redpacketUIs     = {}
    self.seats            = {}
    self.isTurnUpsideDown = false
    self.moreButtonIsOpen = false
    self.selfSeat         = nil
    self.doneMissionId    = 0
    self.currentMissionId = 0

    resMgr:LoadPrefabByRes("FishingGame/Effect", {"NuclearBombDragonbones"}, function(objs)
        self.NuclearBombDragonbonesPrefab = objs[0]
    end)
end

function FishingView:initUIControls()
    self:initSkillsView()
    self:initPropsView()
    self:initSeatView()
    self:initAroundView()
    self:addPropertyObserver()
end

function FishingView:initUIDatas()
    
end

function FishingView:onCleanUp()
    if self.auotShootTimer then
        self:onAutoShootTimerEnd()
    end

    if self.registerHandleIds then
	    for i = 1, #self.registerHandleIds do
	    	local handleId = self.registerHandleIds[i]
	    	GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handleId)
	    end
	    self.registerHandleIds = nil
    end

    if self.diamondRegisterHandleIds then
        for i = 1, #self.diamondRegisterHandleIds do
            local handleId = self.diamondRegisterHandleIds[i]
            GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.diamondRegisiter[i], handleId)
        end
        self.diamondRegisterHandleIds = nil
    end

    if self.NoticeManager then
        self.NoticeManager:onClean()
    end
    destroy(self.view)
    self.view = nil
end

function FishingView:onClose()
    if self.model:isRedpacketRoom() then
        local needTimes, rewardJewel = self:getLogoutTips()
        needTimes = needTimes and needTimes or 0
        rewardJewel = rewardJewel and rewardJewel or 0
        local PanelFishExit = PanelFishExit.new(needTimes, GameManager.GameFunctions.getJewelWithUnit(rewardJewel),function()
            self.controller_:exitScene()
        end)
        self:onMoreButtonClick()
    else
        self.controller_:exitScene()
    end
end

function FishingView:addPropertyObserver()
    self.registerProps = {"money", "diamond", "jewel"}
    self.registerHandleIds = {}
    for i = 1, #self.registerProps do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handler(self, self.refreshSelfPlayerInfo))
        table.insert(self.registerHandleIds, handleId)
    end

    self.diamondRegisiter = {"diamond"}
    self.diamondRegisterHandleIds = {}
    for i = 1, #self.diamondRegisiter do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.diamondRegisiter[i], handler(self, self.refreshSelfPlayerInfoWithDiamond))
        table.insert(self.diamondRegisterHandleIds, handleId)
    end

end

function FishingView:refreshSelfPlayerInfo()
    if self.selfSeat and self.selfSeat.moneyText then
        self.selfSeat.moneyText:setText(GameManager.UserData.money)
        self.selfSeat.otherText:setText(GameManager.GameFunctions.getJewel())
    end
end

function FishingView:refreshSelfPlayerInfoWithDiamond( )
    self:updateCannonUpgradeInfo()
end

--[[
    top\left\--right--\bottom
]]

function FishingView:initAroundView()
    self.topView              = self.view:findChild("topBg")
    self.normalTaskView       = self.view:findChild("topBg/normalTaskBg")
    self.normalTaskInfo       = self.view:findChild("topBg/normalTaskBg/Text")
    self.normalTaskProgress   = self.view:findChild("topBg/normalTaskBg/progressBar")
    self.normalTaskInfoButton = self.view:findChild("topBg/normalTaskBg/taskButton")
    self.normalTaskText       = self.view:findChild("topBg/normalTaskBg/allText")
    -- self.taskProgress = self.view:findChild("topBg/normalTaskBg/Text/number")

    self.redpacketTaskView   = self.view:findChild("topBg/redpacketTaskBg")
    self.redpacketTextInfo   = self.view:findChild("topBg/redpacketTaskBg/Text")
    self.redpacketProgress   = self.view:findChild("topBg/redpacketTaskBg/progressBar")
    self.redpacketInfoButton = self.view:findChild("topBg/redpacketTaskBg/infoButton")
    self.redpacketTaskButton = self.view:findChild("topBg/redpacketTaskBg/taskButton")
    self.redpacketTaskEffect = self.view:findChild("topBg/redpacketTaskBg/taskButton/effect")
    self.redpacketText       = self.view:findChild("topBg/redpacketTaskBg/allText")

    self.redpacketProgress.transform:GetComponent('Slider').value = 0
    TMPHelper.setText(self.redpacketText, 0)

    self.leftView      = self.view:findChild("leftView")
    self.moreButton    = self.view:findChild("leftView/moreBg")
    self.backButton    = self.view:findChild("leftView/moreBg/backButton")
    self.settingButton = self.view:findChild("leftView/moreBg/settingButton")
    self.bookButton    = self.view:findChild("leftView/moreBg/bookButton")
    self.arrwoImage    = self.view:findChild("leftView/moreBg/arrowImage")

    self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-80,0))

    self.leftButton = {}
    for index = 1, FishingView.CONST.Count.OperationCount do
        self.leftButton[index] = self.view:findChild(string.format("leftView/layout/button (%d)", index))
        self.leftButton[index]:addButtonClick(buttonSoundHandler(self, function()
            self:onOperationButtonClick(index)
        end))
    end

    self.redpacketTaskView:addButtonClick(buttonSoundHandler(self, self.onRedpacketInfoButtonClick))
    self.redpacketInfoButton:addButtonClick(buttonSoundHandler(self, self.onRedpacketInfoButtonClick))
    self.redpacketTaskButton:addButtonClick(buttonSoundHandler(self, self.onRedpacketTaskButtonClick))
    
    self.moreButton:addButtonClick(buttonSoundHandler(self, self.onMoreButtonClick))
    self.backButton:addButtonClick(buttonSoundHandler(self, self.onClose))
    self.settingButton:addButtonClick(buttonSoundHandler(self, self.onSettingButtonClick))
    self.bookButton:addButtonClick(buttonSoundHandler(self, self.onBookButtonClick))
end

function FishingView:showFirstPayButton()
    show(self.leftButton[2])
end

function FishingView:isFirstPayShow()
    return self.leftButton[2].activeSelf
end

function FishingView:updateNormalRoomProgress(noAnimation)
    local roomConfig = self.model.roomConfig
    local maxValue = roomConfig.reward_fish_kill_index

    -- local testString = (self.model.tableInfo.totalAnte == maxValue and 0 or self.model.tableInfo.totalAnte).."/"..maxValue
    local testString = self.model.tableInfo.totalAnte == maxValue and "0%" or string.format("%.2f%%", self.model.tableInfo.totalAnte / maxValue * 100)

    TMPHelper.setText(self.normalTaskText, testString)

    self.normalTaskProgress.transform:GetComponent('Slider').maxValue = maxValue
    self.normalTaskProgress.transform:GetComponent('Slider').value = self.model.tableInfo.totalAnte == maxValue and 0 or self.model.tableInfo.totalAnte

    self.normalTaskView.transform:DOLocalMoveY(FishingView.CONST.Value.NormalTaskDownY, FishingView.CONST.Time.Redpacket)
end

function FishingView:updateRedpacketProgress(noAnimation, rewardClick)

    local consumeConfig = self.model.roomConfig.redpack_mission

    -- 获取当前炮的等级 
    local cannonLevel = self.model.selfData.cannonMultiple
    -- 获取当前消耗
    local currentConsume = self.model.selfData.consume

    local lastMissionId = self.currentMissionId

    local needTimes, allTimes = 0, 0
    local nextLevel = false
    for index, config in ipairs(consumeConfig) do
        local limit = config.amount
        if currentConsume < limit then
            if index ~= 1 then
                limit = limit - consumeConfig[index - 1].amount
                currentConsume = currentConsume - consumeConfig[index - 1].amount
                self.doneMissionId = consumeConfig[index - 1].id
                nextLevel = true
            end
            self.currentMissionId = config.id
            if index == 1 then
                self.doneMissionId = 0
            end

            allTimes  = math.ceil(limit / cannonLevel)
            needTimes = math.ceil((limit - currentConsume) / cannonLevel)
            self.redpacketTaskButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/FishingGame/reward/redpacket_"..(self.doneMissionId == 0 and self.currentMissionId or self.doneMissionId))
            break
        end
    end
    self.needTimes = needTimes

    local resetInfo = function()
        if needTimes == 0 and allTimes == 0 then
            self.redpacketProgress.transform:GetComponent('Slider').maxValue = 1
            self.redpacketProgress.transform:GetComponent('Slider').value = 1
            self.redpacketTextInfo:setText(T("       任务完成！"))
            hide(self.redpacketText)
    
            self.doneMissionId = consumeConfig[#consumeConfig].id
            self.currentMissionId = self.doneMissionId
            self.redpacketTaskButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/FishingGame/reward/redpacket_"..self.doneMissionId)
            show(self.redpacketTaskEffect)
        else
            self.redpacketProgress.transform:GetComponent('Slider').maxValue = allTimes
            self.redpacketProgress.transform:GetComponent('Slider').value = allTimes - needTimes
            show(self.redpacketText)
            self.redpacketTextInfo:setText(T("还需炮数:"))
            TMPHelper.setText(self.redpacketText, needTimes)
            if self.doneMissionId ~= 0 then
                show(self.redpacketTaskEffect)
            else
                hide(self.redpacketTaskEffect)
            end
        end
    end

    local upDownAnimation = function()
        self.upAnimation = self.redpacketTaskView.transform:DOLocalMoveY(FishingView.CONST.Value.RedpacketUpY, FishingView.CONST.Time.Redpacket)
        self.upAnimation:OnComplete(function()
            self.redpacketTaskView.transform:DOLocalMoveY(FishingView.CONST.Value.RedpacketDownY, FishingView.CONST.Time.Redpacket)
            resetInfo()
        end)
    end

    -- 如果点击了领奖之后
    if rewardClick then
        upDownAnimation()
    else
        if nextLevel and not noAnimation then
            if lastMissionId ~= self.currentMissionId then
                -- 达到下一个等级了 可以做对应的动画了
                upDownAnimation()
            else
                resetInfo()    
            end
        else
            self.redpacketTaskView.transform:DOLocalMoveY(FishingView.CONST.Value.RedpacketDownY, FishingView.CONST.Time.Redpacket)
            resetInfo()
        end
    end
end

--[[
    道具相关
]]

function FishingView:initPropsView()
    self.propsView                  = self.view:findChild("propsView")
    self.cannonUpgradeView          = self.view:findChild("propsView/layout/cannonUpgrade")
    self.cannonUpgradeTitle         = self.view:findChild("propsView/layout/cannonUpgrade/Title")
    self.cannonUpgradeIcon          = self.view:findChild("propsView/layout/cannonUpgrade/icon")
    self.cannonUpgradeBg            = self.view:findChild("propsView/layout/cannonUpgrade/bg")
    self.cannonUpgradeInfo          = self.view:findChild("propsView/layout/cannonUpgrade/bg/textInfo")
    self.cannonUpgradeLevel         = self.view:findChild("propsView/layout/cannonUpgrade/bg/allText")
    self.cannonUpgradeInfoIcon      = self.view:findChild("propsView/layout/cannonUpgrade/bg/icon")
    self.cannonUpgradeProgress      = self.view:findChild("propsView/layout/cannonUpgrade/bg/progressBar")
    self.cannonUpgradeProgressInner = self.view:findChild("propsView/layout/cannonUpgrade/bg/progressBar/bar")
    self.cannonUpgradeProgressText  = self.view:findChild("propsView/layout/cannonUpgrade/bg/progressBar/Text")
    self.frozeButton                = self.view:findChild("propsView/layout/frozeButton")
    self.frozeCount                 = self.view:findChild("propsView/layout/frozeButton/allText")
    self.frozeConsumeIcon           = self.view:findChild("propsView/layout/frozeButton/allText/icon")
    self.frozeProgress              = self.view:findChild("propsView/layout/frozeButton/progress")
    self.sprintButton               = self.view:findChild("propsView/layout/sprintButton")
    self.sprintCount                = self.view:findChild("propsView/layout/sprintButton/allText")
    self.sprintConsumeIcon          = self.view:findChild("propsView/layout/sprintButton/allText/icon")
    self.sprintProgress             = self.view:findChild("propsView/layout/sprintButton/progress")
    self.nuclearBombButton          = self.view:findChild("propsView/layout/nuclearBombButton")
    self.nuclearBombBg              = self.view:findChild("propsView/layout/nuclearBombButton/bg")
    self.nuclearBombIcon            = self.view:findChild("propsView/layout/nuclearBombButton/icon")
    self.nuclearBombContent         = self.view:findChild("propsView/layout/nuclearBombButton/bg/content")
    self.nuclearBombArrow           = self.view:findChild("propsView/layout/nuclearBombButton/bg/arrow")
    self.nuclearBombTitle           = self.view:findChild("propsView/layout/nuclearBombButton/bg/Title")
    self.nuclearBombs = {}
    for index = 1, FishingView.CONST.Count.NuClearBombMax do
        local item = {}
        item.view = self.view:findChild(string.format("propsView/layout/nuclearBombButton/bg/content/nuclearBomb (%d)", index))
        item.bg   = item.view:findChild("bg")
        item.icon = item.view:findChild("Image")
        item.text = item.view:findChild("allText")
        self.nuclearBombs[index] = item
    end

    -- 把self.cannonUpgradeLevel
    TMPHelper.setTexture(self.cannonUpgradeLevel, "Face", "Images/FishingGame/fontColor/color_green")
    TMPHelper.setTexture(self.cannonUpgradeLevel, "Outline")
    TMPHelper.setTextColor(self.cannonUpgradeLevel, Color.New(49/255,66/255,75/255,1), "Outline")
    TMPHelper.setTextColor(self.cannonUpgradeLevel, Color.New(211/255,114/255,0/255,1), "Underlay")

    hide({self.frozeConsumeIcon, self.sprintConsumeIcon})

    self.cannonUpgradeBg:addButtonClick(buttonSoundHandler(self, self.onCannonUpgradeBgClick))
    self.frozeButton:addButtonClick(buttonSoundHandler(self, self.onFrozeButtonClick))
    self.sprintButton:addButtonClick(buttonSoundHandler(self, self.onSprintButtonClick))
    self.nuclearBombBg:addButtonClick(buttonSoundHandler(self, self.onNuclearBombBgClick))
    self.nuclearBombArrow:addButtonClick(buttonSoundHandler(self, self.onNuclearBombBgClick))
    for index, item in ipairs(self.nuclearBombs) do
        item.view:addButtonClick(buttonSoundHandler(self, function()
            self:onNuclearBombClick(index)
        end))
    end

    self:updataPropsView()
    self:updateCannonUpgradeInfo()
end

function FishingView:updataPropsView()
    if GameManager.UserData.fishingSkillConfig then
        for index, config in ipairs(GameManager.UserData.fishingSkillConfig) do
            if config.id == CONSTS.PROPS.FISHING_SKILL_SPRINT then
                if tonumber(config.switch) == 0 then
                    hide(self.sprintButton)
                else
                    dump(config)
                    self.sprintConsumeIcon:setSprite("Images/SenceMainHall/fuliItem"..config.pmode)
                    
                    local price
                    if config.pmode == 1 then
                        price = formatFiveNumber(config.price)
                    elseif config.pmode == 2 then
                        price = "￥"..config.price
                    elseif config.pmode == 3 then
                        price = GameManager.GameFunctions.getJewel(config.price)
                    elseif config.pmode == 4 then
                        price = config.price
                    end

                    if tonumber(config.num) ~= 0 then
                        hide(self.sprintConsumeIcon)
                        TMPHelper.setText(self.sprintCount, config.num)
                    else
                        show(self.sprintConsumeIcon)
                        TMPHelper.setText(self.sprintCount, price)
                    end
                end
            elseif config.id == CONSTS.PROPS.FISHING_SKILL_FROZE then
                if tonumber(config.switch) == 0 then
                    hide(self.frozeButton)
                else
                    self.frozeConsumeIcon:setSprite("Images/SenceMainHall/fuliItem"..config.pmode)
                    
                    local price
                    if config.pmode == 1 then
                        price = formatFiveNumber(config.price)
                    elseif config.pmode == 2 then
                        price = "￥"..config.price
                    elseif config.pmode == 3 then
                        price = GameManager.GameFunctions.getJewel(config.price)
                    elseif config.pmode == 4 then
                        price = config.price
                    end

                    if tonumber(config.num) ~= 0 then
                        hide(self.frozeConsumeIcon)
                        TMPHelper.setText(self.frozeCount, config.num)
                    else
                        show(self.frozeConsumeIcon)
                        TMPHelper.setText(self.frozeCount, price)
                    end
                end
            end
        end
    end
end

function FishingView:getCannonButtonPosition()
    return self.cannonUpgradeIcon.transform.position
end

function FishingView:showCannonUpgradeView(isShow)

    local time = FishingView.CONST.Time.CannonUpgrade
    if isShow then
        self.cannonUpgradeTitle:setText("")
        self.cannonUpgradeBg.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(FishingView.CONST.Value.UpgradeWidth, FishingView.CONST.Value.PropWidth), time)
        local showTime, delayTime = time * 0.6, time * 0.4
        doFadeAutoShow(self.cannonUpgradeInfoIcon, 'Image', showTime, delayTime)
        doFadeAutoShow(self.cannonUpgradeProgress, 'Image', showTime, delayTime)
        doFadeAutoShow(self.cannonUpgradeProgressInner, 'Image', showTime, delayTime)
        doFadeAutoShow(self.cannonUpgradeProgressText, 'Text', showTime, delayTime)
        doFadeAutoShow(self.cannonUpgradeInfo, 'Image', showTime, delayTime)
        doFadeAutoShow(self.cannonUpgradeLevel, 'TextMeshProUGUI', showTime, delayTime, function()
            self.cannonUpgradeBg.transform:GetComponent('Button').interactable = true
        end)
    else
        self.cannonUpgradeTitle:setText(T("炮台升级"))
        self.cannonUpgradeBg.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(FishingView.CONST.Value.PropWidth, FishingView.CONST.Value.PropWidth), time)
        local showTime, delayTime = time * 0.6, time * 0
        doFadeDismiss(self.cannonUpgradeInfoIcon, 'Image', showTime, delayTime)
        doFadeDismiss(self.cannonUpgradeProgress, 'Image', showTime, delayTime)
        doFadeDismiss(self.cannonUpgradeProgressInner, 'Image', showTime, delayTime)
        doFadeDismiss(self.cannonUpgradeProgressText, 'Text', showTime, delayTime)
        doFadeDismiss(self.cannonUpgradeInfo, 'Image', showTime, delayTime)
        doFadeDismiss(self.cannonUpgradeLevel, 'TextMeshProUGUI', showTime, delayTime, function()
            self.cannonUpgradeBg.transform:GetComponent('Button').interactable = true
        end)
    end
end

function FishingView:updateCannonUpgradeInfo()
    -- 获取当前用户的炮台等级
    local nextConfig = self.model:getNextCannonConfig()
    if nextConfig then
        show(self.cannonUpgradeBg)
        show(self.cannonUpgradeIcon)
        self.cannonUpgradeProgress.transform:GetComponent('Slider').maxValue = nextConfig.upgrade_diamon
        self.cannonUpgradeProgress.transform:GetComponent('Slider').value = GameManager.UserData.diamond
        self.cannonUpgradeProgressText:setText(string.format("%d/%d", GameManager.UserData.diamond, nextConfig.upgrade_diamon))
        TMPHelper.setText(self.cannonUpgradeLevel, nextConfig.multiple)

        -- 如果够了 那么就弹出来
        if nextConfig.upgrade_diamon <= GameManager.UserData.diamond then
            self.controller_:onUpgradeCannonClick(true)
        else
            self.controller_:onUpgradeCannonClick(false)
        end
    else
        -- 说明升级升完了
        hide(self.cannonUpgradeIcon)
        hide(self.cannonUpgradeBg)
        hide(self.cannonUpgradeTitle)
        hide(self.cannonUpgradeView)
    end
end

function FishingView:enablePropsButtons(isEnable)
    self.frozeButton.transform:GetComponent('Button').interactable = isEnable
    self.sprintButton.transform:GetComponent('Button').interactable = isEnable
end

function FishingView:showPropsView()
    --[[现在怎么样都隐藏]]
    showOrHide(self.model.roomConfig.skill_switch == 1, {self.cannonUpgradeView, self.frozeButton, self.sprintButton})
    -- 检测自动射击
    self:getAutoShootEnable()
end

-- 新手红包引导功能
function FishingView:showGuide(isJewel)
    UnityEngine.PlayerPrefs.SetString(DataKeys.FIRST_LOGIN, "False")

    local showAutoShootTips = function()
        local time = UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_TOTALTIME)
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = false,
            hasCloseButton = false,
            title = T("温馨提示"),
            text = T("您获得" .. time/60 .. "分钟自动射击\n点击技能后开始计时"),
        })
    end

    if isJewel then
        -- 红包场第一次进入
        local need = tonumber(self.model.roomConfig.redpack_mission[1].amount) / 100
        local PanelFishingGuide = require("Panel.FishingGame.PanelFishingGuide").new(need, showAutoShootTips)
    else
        -- 金币场第一次进入
        showAutoShootTips()
    end
end

function FishingView:showPropProgress(type, countDownTime)
    local progressView
    if type == CONSTS.PROPS.FISHING_SKILL_FROZE then
        progressView = self.frozeProgress
    elseif type == CONSTS.PROPS.FISHING_SKILL_SPRINT then
        progressView = self.sprintProgress
    end
    show(progressView)
    local fillAmount = progressView.transform:GetComponent('Image'):DOFillAmount(0, countDownTime)
    fillAmount:SetEase(DG.Tweening.Ease.Linear)
    fillAmount:OnComplete(function()
        hide(progressView)
        progressView.transform:GetComponent('Image').fillAmount = 1
    end)
end

function FishingView:showNuclearBombView(isShow)
    local time = FishingView.CONST.Time.NuClearBomb
    if isShow then
        show(self.nuclearBombContent)
        self.nuclearBombBg.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(FishingView.CONST.Value.PropWidth * FishingView.CONST.Count.NuClearBombMax, FishingView.CONST.Value.PropWidth), time)
        local showTime, delayTime = time * 0.6, time * 0.4
        self.nuclearBombTitle:setText(T("鱼雷选择"))
        doFadeDismiss(self.nuclearBombIcon, 'Image', delayTime, 0)
        doFadeAutoShow(self.nuclearBombArrow, 'Image', showTime, delayTime)
        for index, item in ipairs(self.nuclearBombs) do
            local completeFunc = nil
            if index == #self.nuclearBombs then
                completeFunc = function()
                    self.nuclearBombBg.transform:GetComponent('Button').interactable = true
                end
            end
            doFadeAutoShow(item.view, 'Image', showTime, delayTime)
            doFadeAutoShow(item.bg, 'Image', showTime, delayTime)
            doFadeAutoShow(item.icon, 'Image', showTime, delayTime)
            doFadeAutoShow(item.text, 'TextMeshProUGUI', showTime, delayTime, completeFunc)
        end
    else
        self.nuclearBombBg.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(FishingView.CONST.Value.PropWidth, FishingView.CONST.Value.PropWidth), time)
        local showTime, delayTime = time * 0.6, time * 0
        self.nuclearBombTitle:setText(T("鱼雷"))
        doFadeAutoShow(self.nuclearBombIcon, 'Image', showTime, 0)
        doFadeDismiss(self.nuclearBombArrow, 'Image', showTime, delayTime)
        for index, item in ipairs(self.nuclearBombs) do
            local completeFunc = nil
            if index == #self.nuclearBombs then
                completeFunc = function()
                    self.nuclearBombBg.transform:GetComponent('Button').interactable = true
                    hide(self.nuclearBombContent)
                end
            end
            doFadeDismiss(item.view, 'Image', showTime, delayTime)
            doFadeDismiss(item.bg, 'Image', showTime, delayTime)
            doFadeDismiss(item.icon, 'Image', showTime, delayTime)
            doFadeDismiss(item.text, 'TextMeshProUGUI', showTime, delayTime, completeFunc)
        end
    end
end

function FishingView:updataNuclearBombInfo()
    if self.model.nuclearBombConfig then
        for index, item in ipairs(self.nuclearBombs) do
            TMPHelper.setText(item.text, self.model.nuclearBombConfig[index].num)
        end
    end
end


function FishingView:playNuclearBombAnimation(callback)
    local nbAnimation = newObject(self.NuclearBombDragonbonesPrefab)
    nbAnimation.name = "NBAnimation"
    local parent = UnityEngine.GameObject.Find("Canvas")
    nbAnimation.transform:SetParent(parent.transform)
    nbAnimation.transform.localScale = Vector3.one
    nbAnimation.transform.localPosition = Vector3.zero
    nbAnimation.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    nbAnimation.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/nuclear_countdown")
    Timer.New(function()
        GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/nuclear_setup")
        Timer.New(function()
            GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/nuclear_shot")
        end, 0.2, 1, true):Start()
    end, 1.5, 1, true):Start()
    
    local dragonBones = nbAnimation.transform:Find("MovieClip").gameObject
    local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    local Animation = UnityArmatureComponent.animation 
    local AnimationData = Animation.animations:get_Item("newAnimation")
    local duration = AnimationData.duration
    Animation:Play("play")

    Timer.New(function()
        destroy(nbAnimation)
        nbAnimation = nil
        if callback then
            callback()
        end
    end, duration, 0, true):Start()
end

--[[
    技能相关
]]
function FishingView:initSkillsView()
    self.skillsView         = self.view:findChild("skillsView")

    self.aimButton          = self.view:findChild("skillsView/aimButton")
    self.aimEffect          = self.view:findChild("skillsView/aimButton/effect")
    self.aimButton:addButtonClick(buttonSoundHandler(self, self.onAimButtonClick))

    self.autoShootButton    = self.view:findChild("skillsView/autoShootButton")
    self.autoShootEffect    = self.view:findChild("skillsView/autoShootButton/effect")
    self.autoShootProgress  = self.view:findChild("skillsView/autoShootButton/progress")
    self.autoShootButton:addButtonClick(buttonSoundHandler(self, self.onAutoShootButtonClick))

    self.autoSprintButton   = self.view:findChild("skillsView/sprintButton")
    self.autoSprintEffect   = self.view:findChild("skillsView/sprintButton/effect")
    self.autoSprintButton:addButtonClick(buttonSoundHandler(self, self.onAutoSprintButtonClick))
end

-- 新手自动射击相关功能
function FishingView:getAutoShootEnable()
    -- 先要筛选玩家是否已经是vip
    self.controller_:isVipAutoShoot()
    -- 如果有新手自动射击
    if self.controller_:getAutoShootEnable() then
        local cur = UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_CURTIME)
        local total = UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_TOTALTIME)
        self.autoShootProgress:GetComponent('Image').fillAmount = cur/total
        show(self.autoShootProgress)
    else
        hide(self.autoShootProgress)
    end
end

-- 如果要显示自动射击的倒计时，会根据curtime和totaltime计算进度条
function FishingView:showAutoShootProgress(isShow)
    if isShow then
        self:onAutoShootTimeStart()
    else
        self:onAutoShootTimerEnd()
    end
end

function FishingView:onAutoShootTimeStart()
    self.auotShootTimer = Timer.New(function()
        self:onAuotShootTimer()
    end,1,-1,true)
    self.auotShootTimer:Start()
end

function FishingView:onAuotShootTimer()
    local cur = UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_CURTIME) - 1
    local total = UnityEngine.PlayerPrefs.GetInt(DataKeys.HAS_AUTOSHOT_TOTALTIME)
    self.autoShootProgress:GetComponent('Image').fillAmount = cur/total
    UnityEngine.PlayerPrefs.SetInt(DataKeys.HAS_AUTOSHOT_CURTIME, cur)

    if cur < 0 then
        self:onAutoShootTimerEnd()
        hide(self.autoShootProgress)
        self.controller_:setAutoShootEnd()
        self.controller_:usePrivilegeAutoShootSkill(false)
    end
end

function FishingView:onAutoShootTimerEnd()
    if self.auotShootTimer then
        self.auotShootTimer:Stop()
    end
end

function FishingView:showAimEffect(isShow)
    showOrHide(isShow, self.aimEffect)
end

function FishingView:showAutoShootEffect(isShow)
    showOrHide(isShow, self.autoShootEffect)
end

function FishingView:showAutoSprintEffect(isShow)
    showOrHide(isShow, self.autoSprintEffect)
end

--[[
    座位相关
]]
function FishingView:initSeatView()
    for index = 1, FishingView.CONST.Count.SeatCount do
        local seat = {}
        seat.view          = self.view:findChild(string.format("seat (%d)", index))
        seat.headerView    = seat.view:findChild("headerView")
        if isFKBY() then
            seat.bgUser        = seat.view:findChild("headerView/bgUser")
            seat.headerButton  = seat.view:findChild("headerView/headerButton")
            seat.frameImage    = seat.view:findChild("headerView/headerButton/frameImage")
            seat.emoji         = seat.view:findChild("headerView/headerButton/emoji")
            seat.infoView      = seat.view:findChild("headerView")
            seat.nameBg        = seat.view:findChild("headerView/nameBg")
            seat.nameText      = seat.view:findChild("headerView/nameBg/text")
            seat.moneyBg       = seat.view:findChild("headerView/moneyBg")
            seat.moneyText     = seat.view:findChild("headerView/moneyBg/text")
            seat.moneyIcon     = seat.view:findChild("headerView/moneyBg/icon")
            seat.otherBg       = seat.view:findChild("headerView/otherBg")
            seat.otherText     = seat.view:findChild("headerView/otherBg/text")
            seat.otherIcon     = seat.view:findChild("headerView/otherBg/icon")
            seat.mulChooseBut  = seat.view:findChild("headerView/mulChooseButton")
            seat.mulChooseBg   = seat.view:findChild("headerView/mulChooseButton/bg")
            seat.mulChooseText = seat.view:findChild("headerView/mulChooseButton/allText")
            seat.chooseMenu    = seat.view:findChild("headerView/chooseMenu")
        else
            seat.headerButton  = seat.view:findChild("headerView/headerButton")
            seat.frameImage    = seat.view:findChild("headerView/headerButton/frameImage")
            seat.emoji         = seat.view:findChild("headerView/headerButton/emoji")
            seat.infoView      = seat.view:findChild("infoView")
            seat.moneyBg       = seat.view:findChild("infoView/moneyBg")
            seat.moneyText     = seat.view:findChild("infoView/moneyBg/text")
            seat.moneyIcon     = seat.view:findChild("infoView/moneyBg/icon")
            seat.otherBg       = seat.view:findChild("infoView/otherBg")
            seat.otherText     = seat.view:findChild("infoView/otherBg/text")
            seat.otherIcon     = seat.view:findChild("infoView/otherBg/icon")
            seat.mulChooseBut  = seat.view:findChild("infoView/mulChooseButton")
            seat.mulChooseBg   = seat.view:findChild("infoView/mulChooseButton/bg")
            seat.mulChooseText = seat.view:findChild("infoView/mulChooseButton/allText")
            seat.chooseMenu    = seat.view:findChild("infoView/chooseMenu")
        end
        
        seat.gunInfoView   = seat.view:findChild("gunInfoView")
        seat.gunInfoBg     = seat.view:findChild("gunInfoView/bg")
        seat.gunLevelText  = seat.view:findChild("gunInfoView/bg/gunLevelText")
        seat.waitImage     = seat.view:findChild("gunInfoView/waitImage")
        seat.subButton     = seat.view:findChild("gunInfoView/subButton")
        seat.addButton     = seat.view:findChild("gunInfoView/addButton")

        self.redpacketUIs[#self.redpacketUIs + 1] = seat.otherBg

        seat.chooseMenuItems = {}
        for i = 1, 5 do
            local item = {}
            item.view = seat.chooseMenu:findChild(string.format("item (%d)", i))
            item.text = item.view:findChild("allText")
            item.line = item.view:findChild("line")
            item.lock = item.view:findChild("lock")
            seat.chooseMenuItems[i] = item
            item.view:addButtonClick(buttonSoundHandler(self, function()
                self:onMulChooseItemClick(i)
            end))
        end

        seat.seatData = nil
        if isFKBY() then
            seat.nameText:setText("")
        end
        seat.moneyText:setText("")
        seat.otherText:setText("")
        seat.gunLevelText:setText("")
        seat.subButton:addButtonClick(buttonSoundHandler(self, function()
            self:onSubButtonClick()
        end))

        seat.addButton:addButtonClick(buttonSoundHandler(self, function()
            self:onAddButtonClick()
        end))
        seat.mulChooseBut:addButtonClick(buttonSoundHandler(self, function()
            if index == self.selfSeat.seatData.seatId then
                self:onMulChooseButtonClick()
            end
        end))

        seat.headerButton:addButtonClick(buttonSoundHandler(self, function()
            local PanelOtherInfoSmall = PanelOtherInfoSmall.new(seat.seatData.uid, function(index)
                
            end)
        end))

        --调整三大控件的顺序
        if index == 1 or index == 3 then
            seat.headerView.transform:SetSiblingIndex(0)
            seat.infoView.transform:SetSiblingIndex(1)
            seat.gunInfoView.transform:SetSiblingIndex(2)
        elseif index == 2 or index == 4 then
            seat.gunInfoView.transform:SetSiblingIndex(0)
            seat.infoView.transform:SetSiblingIndex(1)
            seat.headerView.transform:SetSiblingIndex(2)
        end

        self.seats[#self.seats + 1] = seat
    end
    -- showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function FishingView:setSeatGunPosition()
    local indexs = {1, 2, 3, 4}
    if self.isTurnUpsideDown then
        indexs = {3, 4, 1, 2}
    end
    for i, index in ipairs(indexs) do
        local seat = self.seats[i]

        local posConfig = FishingView.SeatPos[index]
        seat.view.transform.localPosition = posConfig.view.pos
        seat.view.transform:GetComponent('RectTransform').anchorMin = posConfig.view.anchors
        seat.view.transform:GetComponent('RectTransform').anchorMax = posConfig.view.anchors

        seat.cannonView = UnityEngine.GameObject.Find("Canvas"):findChild("CannonViews/SeatCannon ("..i..")")
        seat.cannonView.transform.position = seat.gunInfoView.transform.position

        seat.cannon       = seat.cannonView:findChild("Cannon")
        seat.base         = seat.cannonView:findChild("Base")
        seat.sprintEffect = newObject(self.seatCannonSprint)
        seat.sprintEffect.transform:SetParent(seat.gunInfoView.transform)
        seat.sprintEffect.transform.localScale = Vector3.one
        seat.sprintEffect.transform.localPosition = Vector3.zero
        hide(seat.sprintEffect)

        -- 调整倍数选择的上下位置
        if index == 1 or index == 2 then
            seat.mulChooseBut.transform.localPosition = Vector3(0, 56, 0)
        elseif index == 3 or index == 4 then
            seat.mulChooseBut.transform.localPosition = Vector3(0, -56, 0)
        end
        if not seat.seatData or seat.seatData.uid ~= GameManager.UserData.mid then
            hide(seat.mulChooseBg)
        end
        
        -- 遍历获取他下面的所有子控件 然后找到颠倒的 反向
        local childs = seat.cannonView:getChilds()
        if (not self.isTurnUpsideDown and i > 2) or (self.isTurnUpsideDown and i <= 2) then
            for j = 0, childs.Length - 1 do
                local child = childs[j] 
                child.transform.rotation = Quaternion.New(0,0,180,0)
            end
            seat.sprintEffect.transform.localPosition = Vector3.New(seat.sprintEffect.transform.localPosition.x, seat.sprintEffect.transform.localPosition.y + 13, 0)
            seat.sprintEffect.transform.rotation = Quaternion.New(0,0,180,0)
            if isFKBY() then
                seat.gunInfoView.transform.rotation = Quaternion.New(0,0,180,0)
            end
        else
            seat.sprintEffect.transform.localPosition = Vector3.New(seat.sprintEffect.transform.localPosition.x, seat.sprintEffect.transform.localPosition.y - 13, 0)
        end
        
        seat.goldCollect = UnityEngine.GameObject.Find("Canvas"):findChild("GoldViews/GoldCollect ("..i..")")
        seat.goldCollect.transform.position = seat.moneyIcon.transform.position
        seat.goldCollect.transform.sizeDelta = seat.moneyIcon.transform.sizeDelta
        show(seat.view)
        hide(seat.cannonView)
    end
end

function FishingView:updateSeatCannonMul(seatId, cannonMul)
    local seat = self.seats[seatId]
    TMPHelper.setText(seat.mulChooseText, string.format("X%d倍", cannonMul))
end

function FishingView:updateChooseMenuData()
    if not self.model:isCannonMulSwitchOpen() then
        for index, seat in ipairs(self.seats) do
            hide(seat.mulChooseBut)
        end
        return
    end
    local seat = self.selfSeat
    for index, item in ipairs(seat.chooseMenuItems) do
        local config = self.model.roomConfig.cannon_mul[#seat.chooseMenuItems + 1 - index]
        if config.vip <= GameManager.UserData.viplevel then
            hide(item.lock)
        end
        TMPHelper.setText(item.text, string.format("%d倍", config.mul))
    end
    TMPHelper.setText(seat.mulChooseText, string.format("X%d倍", self.model.roomConfig.cannon_mul[1].mul))
    self.model.selfData.multiple = self.model.roomConfig.cannon_mul[1].mul
end

function FishingView:seatShowEffect(seatId, countDownTime, propType)
    local seat = self.seats[seatId]
    local time = countDownTime
    local effect
    if propType == CONSTS.PROPS.FISHING_SKILL_SPRINT then
        effect = seat.sprintEffect
    end

    show(effect)
    Timer.New(function()
        if effect then
            hide(effect)
        end
    end, countDownTime, 1, true):Start()
end

function FishingView:seatShowSprintEffect(seatId, isShow)
    showOrHide(isShow, self.seats[seatId].sprintEffect)
end

function FishingView:seatSitDown(currentPlayer)
    local seat = self.seats[currentPlayer.seatId]
    seat.seatData = currentPlayer
    local isSelfSitDown = currentPlayer.uid == GameManager.UserData.mid
    if isSelfSitDown and not self.selfSeat then
        self.isTurnUpsideDown = currentPlayer.seatId > FishingView.CONST.Count.SeatMidIndex
        self:setSeatGunPosition()
        self.selfSeat = seat
        -- 自己座位的话 显示自己在哪里的提示
        local tips = newObject(self.selfSeatTips)
        tips.transform:SetParent(self.selfSeat.gunLevelText.transform)
        tips.transform.localScale = Vector3.one
        tips.transform.localPosition = Vector3.zero
        Timer.New(function()
            destroy(tips)
        end, 3, 1, true):Start()
    end

    -- 更新这个位置对应的座位信息
    self:updateUserInfo(currentPlayer)
    if currentPlayer.viplevel and tonumber(currentPlayer.viplevel) > 0 then
        show(seat.frameImage)
        seat.frameImage:setSprite(GameManager.ImageLoader:getVipFrame(currentPlayer.viplevel))
    else
        hide(seat.frameImage)
    end
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = currentPlayer.mavatar,
        sex = tonumber(currentPlayer.msex),
        node = seat.headerButton,
        callback = function(sprite)
            if self.view and seat.headerButton then
                seat.headerButton:setSprite(sprite)
            end
        end,
    })

    seat.gunLevelText:setText(currentPlayer.cannonMultiple)

    if isFKBY() then
        show(seat.bgUser)
        show(seat.nameBg)
    end
    show(seat.headerButton)
    show(seat.gunInfoBg)
    show(seat.gunLevelText)
    show(seat.cannonView)
    show(seat.base)
    show(seat.otherBg)
    if not GameManager.GameConfig.SensitiveSwitch.showRedpacket then
        hide(seat.otherBg)
    end
    show(seat.moneyBg)
    if self.model:isCannonMulSwitchOpen() then
        show(seat.mulChooseBut)
        TMPHelper.setText(seat.mulChooseText, string.format("X%d倍", self.model.roomConfig.cannon_mul[1].mul))
    end

    hide(seat.waitImage)
    if isSelfSitDown then
        show(seat.addButton)
        show(seat.subButton)
    end
end

function FishingView:seatStandUp(currentPlayer)
    local seat = self.seats[currentPlayer.seatId]
    seat.seatData = nil
    if isFKBY() then
        seat.nameText:setText("")
    end
    seat.moneyText:setText("")
    seat.gunLevelText:setText("")
    self:seatShowSprintEffect(currentPlayer.seatId, false)
    if isFKBY() then
        hide(seat.bgUser)
        hide(seat.nameBg)
    end
    hide(seat.headerButton)
    hide(seat.frameImage)
    hide(seat.cannonView)
    hide(seat.base)
    hide(seat.gunLevelText)
    hide(seat.gunInfoBg)
    hide(seat.addButton)
    hide(seat.subButton)
    hide(seat.moneyBg)
    hide(seat.otherBg)
    hide(seat.mulChooseBut)

    show(seat.waitImage)
end

function FishingView:seatCannonChanged(currentPlayer)
    local seat = self.seats[currentPlayer.seatId]
    seat.gunLevelText:setText(currentPlayer.cannonMultiple)
end

function FishingView:updateUserInfo(currentPlayer)
    local seat = self.seats[currentPlayer.seatId]
    seat.moneyText:setText(currentPlayer.money)
    if isFKBY() then
        seat.nameText:setText(currentPlayer.name)
    end
    if  GameManager.GameConfig.SensitiveSwitch.showRedpacket then
        seat.otherText:setText(GameManager.GameFunctions.getJewel(currentPlayer.jewel))
        seat.otherIcon:setSprite("Images/SenceMainHall/loginHongbao")
    else
        if GameManager.GameConfig.HasDiamond == 0 then
            seat.otherText:setText(currentPlayer.diamond)
            seat.otherIcon:setSprite("Images/SenceMainHall/loginDiamond")
        else
            hide(seat.otherBg)
        end
    end
end

--[[
    鱼潮来的提示
]]

function FishingView:showFishTideComingAnimation()
    local PanelFishTideComing = import("Panel.FishingGame.PanelFishTideComing").new()
end

--[[
    BOSS来的提示
]]

function FishingView:showBossComingAnimation(fishType, multiple)
    local isFishTide = self.controller_:getFishTideState()
    if isFishTide then
        -- 预留功能，鱼潮状态下BossComing如何处理
    else
        -- 非鱼潮状态才显示bossComing
        if isFKBY() then
            -- 疯狂捕鱼根据boss的类型使用对应的prefab
            print("疯狂捕鱼 boss")
            GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/boss_come")
            local PanelFKBYBossComing      = require("Panel.FishingGame.PanelFKBYBossComing")
            PanelFKBYBossComing.new(fishType)
        else
            GameManager.SoundManager:PlaySoundWithNewSource("fishingGame/boss_come")
            PanelBossComing.new(fishType, multiple)
        end
    end
end

--[[
    event handle
]]

function FishingView:onAimButtonClick()
    self.controller_:usePrivilegeAimSkill()
end

function FishingView:onAutoShootButtonClick()
    self.controller_:usePrivilegeAutoShootSkill()
end

function FishingView:onAutoSprintButtonClick()
    self.controller_:usePrivilegeAutoSprintSkill()
end

function FishingView:onSprintButtonClick()
    if self.sprintProgress.activeSelf then
        return
    end
    self.controller_:usedProp(CONSTS.PROPS.FISHING_SKILL_SPRINT)
end

function FishingView:onFrozeButtonClick()
    if self.frozeProgress.activeSelf then
        return
    end
    self.controller_:usedProp(CONSTS.PROPS.FISHING_SKILL_FROZE)
end

function FishingView:onCannonUpgradeBgClick()
    self.cannonUpgradeBg.transform:GetComponent('Button').interactable = false
    self.controller_:onUpgradeCannonClick()
end

function FishingView:onNuclearBombBgClick()
    self.nuclearBombBg.transform:GetComponent('Button').interactable = false
    self:showNuclearBombView(self.nuclearBombContent.activeSelf == false)
end

function FishingView:onNuclearBombClick(index)
    -- GameManager.TopTipManager:showTopTip(string.format(T("点击了第%d个"), index))
    -- 判断核弹数量
    local num = self.model.nuclearBombConfig[index].num
    if num == 0 then
        GameManager.TopTipManager:showTopTip(T("道具数量不足"))
        return
    end

    self.controller_:useNuclearBomb(index)
    self:onNuclearBombBgClick()
end

function FishingView:onSubButtonClick()
    self.controller_:viewOnSubButtonClick()
end

function FishingView:onMoreButtonClick()
    -- 展开他
    self.moreButton.transform:GetComponent('Button').interactable = false
    
    self.moreButtonIsOpen = not self.moreButtonIsOpen 
    
    local x = self.moreButtonIsOpen and FishingView.CONST.Value.MoreOpenX or FishingView.CONST.Value.MoreCloseX
    local angle = self.moreButtonIsOpen and 180 or 360
    self.arrwoImage.transform:DOLocalRotate(Vector3.New(0,angle,0), FishingView.CONST.Time.MoreAnimation)
    local moveAnimation = self.moreButton.transform:DOLocalMoveX(x, FishingView.CONST.Time.MoreAnimation)
    moveAnimation:OnComplete(function()
        self.moreButton.transform:GetComponent('Button').interactable = true
    end)
end

function FishingView:onRedpacketInfoButtonClick()
    PanelRedpacketRule.new()
end

function FishingView:onRedpacketTaskButtonClick()
    if self.doneMissionId == 0 then
        GameManager.TopTipManager:showTopTip(T("未达成条件！"))
    else
        self.controller_:getFishingRedpackReward(self.doneMissionId)
    end
end

function FishingView:onSettingButtonClick()
    PanelFishingSetting.new()
    self:onMoreButtonClick()
end

function FishingView:onBookButtonClick()
    PanelFishBook.new()
    self:onMoreButtonClick()
end

function FishingView:onOperationButtonClick(index, callback)
    
    if index == 1 then
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.FISHINGROOM
        if self.samllShopPanel and self.samllShopPanel.view and self.samllShopPanel.view.activeSelf then
            self.samllShopPanel:onClose()
            return
        end
        self.samllShopPanel = PanelSmallShop.new(nil, true, callback)
    elseif index == 2 then
        if self.firstPayPanel and self.firstPayPanel.view and self.firstPayPanel.view.activeSelf then
            self.firstPayPanel:onClose()
            return
        end
        self.firstPayPanel = PanelFirstPay.new(callback)
    else
        GameManager.TopTipManager:showTopTip(string.format(T("点击了左边按钮, 下标是:%d"), index))
    end
end

function FishingView:onAddButtonClick()
    self.controller_:viewOnAddButtonClcik()
end

function FishingView:onMulChooseButtonClick()
    showOrHide(not self.selfSeat.chooseMenu.activeSelf, self.selfSeat.chooseMenu)
end

function FishingView:onMulChooseItemClick(index)
    self.controller_:viewOnMulChooseItemClick(#self.selfSeat.chooseMenuItems + 1 - index)
    self:onMulChooseButtonClick()
end

function FishingView:getLogoutTips()

    if self.needTimes == nil then
        return
    end

    if self.currentMissionId == 0 then
        return self.needTimes, 0
    end

    local configs = self.model.roomConfig.redpack_mission
    if configs then
        for index, config in ipairs(configs) do
            if config.id == self.currentMissionId then
                return self.needTimes, config.max_jewel
            end
        end
    end
    return
end

return FishingView