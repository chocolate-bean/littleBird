local LuckyWheelInviteItem = class("LuckyWheelInviteItem")

LuckyWheelInviteItem.WIDTH   = 544
LuckyWheelInviteItem.HEIGHT  = 80
LuckyWheelInviteItem.SPEINGX = 15

function LuckyWheelInviteItem:ctor(prefab, data)
    self.data = data
    self.height = self.HEIGHT
    self:initView(prefab)
    self:initUIControls()
    -- self:initUIDatas(data)
end

function LuckyWheelInviteItem:initView(prefab)
    self.view = prefab
    self.view.name = "LuckyWheelInviteItem"
end

function LuckyWheelInviteItem:initUIControls()
    self.name  = self.view.transform:Find("name").gameObject
    self.time  = self.view.transform:Find("time").gameObject
    self.aim   = self.view.transform:Find("aim").gameObject
    self.index = self.view.transform:Find("index").gameObject
end

function LuckyWheelInviteItem:setData(data)
    self:initUIDatas(data)
end

function LuckyWheelInviteItem:initUIDatas(data)
    self.name:setText(data.name)
    self.index:setText(data.index)
    self.time:setText(os.date("%Y/%m/%d", data.mtime))
    if data.status == 1 then
        self.aim:setText(T("成功兑换"))
        self.aim:GetComponent('Text').color = Color.New(99/255.0,242/255.0,156/255.0,1)
    else
        self.aim:setText(T("未兑换"))
        self.aim:GetComponent('Text').color = Color.white
    end
end

local PanelLuckyWheel = class("PanelLuckyWheel")

local PanelLuckyWheelRuleDialog = require("Panel.LuckyWheel.PanelLuckyWheelRuleDialog")
local PanelShareDialog          = require("Panel.LuckyWheel.PanelShareDialog")
local PanelNewVipHelper            = require("Panel.Special.PanelNewVipHelper")

PanelLuckyWheel.Event = {
    Show    = 1,
    Success = 2,
    Cancel  = 3,
}

PanelLuckyWheel.ITEM_COUNT = 10 -- 转盘个数
PanelLuckyWheel.ANGLE = 360
PanelLuckyWheel.ITEM_ANGLE = PanelLuckyWheel.ANGLE / PanelLuckyWheel.ITEM_COUNT

PanelLuckyWheel.TOTAL_COUNT = 6-- 累计任务个数

PanelLuckyWheel.Tabs = {
    Info   = 1,
    Total  = 2,
    Invite = 3,
}

PanelLuckyWheel.TIME = {
    heightLight = 1/3,
    lamp        = 1/4,
    reward      = 1/3,
    startButton = 1,
    quickLamp   = 2,
}

function PanelLuckyWheel:ctor(callback)
    resMgr:LoadPrefabByRes("Operation", { "PanelLuckyWheel", "LuckyWheelInviteItem"}, function(objs)
        self:initView(objs, callback)
    end)
end

function PanelLuckyWheel:initView(objs, callback)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLuckyWheel"
    self:initProperties(objs, callback)
    self:initUIControls()
    -- self:initUIDatas()
    self:show()
    self:showHeightLightAnimation()
    self:showLampAnimation()
    self:showStartButtonAnimation()
    self:getDatas()
    local wheelAnimatin = self.wheelBg.transform:GetComponent('Animator')
    wheelAnimatin.speed = 0
end

function PanelLuckyWheel:show()
    if self.callback then
        self.callback(PanelLuckyWheel.Event.Show)
    end
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelLuckyWheel:initProperties(objs, callback)
    self.LuckyWheelInviteItemPrefab = objs[1]

    self.callback = callback
    self.wheelItems = {}
    self.slowLamp = true
    self.rewardDatas = {}
    self.lampLoopIndex = 1
    self.rewardLoopIndex = 1
    self.selectIndex = 1
    local dataString = UnityEngine.PlayerPrefs.GetString(DataKeys.LUCKY_WHEEL_CONFIG)
    if dataString and dataString ~= "" then
        self.datas = json.decode(dataString)
    else
        self.datas = {}
    end
    self.tabs = {}
    self.actions = {}
    self.totalItems = {}
    self.inviteItems = {}
end

function PanelLuckyWheel:initUIControls()
    self.bg               = self.view.transform:Find("bg").gameObject
    self.closeButton      = self.view.transform:Find("bg/closeButton").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
    end), false)

    self:initWheelViewControls()
    self:initActionViewControls()
end

function PanelLuckyWheel:initWheelViewControls()
    self.wheelView        = self.view.transform:Find("wheelView").gameObject
    self.wheelBg          = self.view.transform:Find("wheelView/wheelBg").gameObject
    self.heightLightImage = self.view.transform:Find("wheelView/wheelBg/heightLightImage").gameObject
    self.rewardImage      = self.view.transform:Find("wheelView/wheelBg/rewardImage").gameObject
    self.effect           = self.view.transform:Find("wheelView/effect").gameObject
    self.lamp             = self.view.transform:Find("wheelView/lamp").gameObject
    self.startButton      = self.view.transform:Find("wheelView/startButton").gameObject
    self.residueDegree    = self.view.transform:Find("wheelView/startButton/Text").gameObject
    self.centerImage      = self.view.transform:Find("wheelView/centerImage").gameObject

    for index = 1, PanelLuckyWheel.ITEM_COUNT do
        local item = {}
        item.view = self.view.transform:Find("wheelView/wheelBg/item ("..index..")").gameObject
        item.text = item.view.transform:Find("Text").gameObject
        item.icon = item.view.transform:Find("icon").gameObject
        item.view:rotation(0, 0, PanelLuckyWheel.ITEM_ANGLE * (index - 1))
        item.text:rotation(0, 0, PanelLuckyWheel.ANGLE * 0.5)
        item.icon:rotation(0, 0, PanelLuckyWheel.ANGLE * 0.5)
        item.text:setText(index)
        self.wheelItems[#self.wheelItems + 1] = item
    end

    self.startButton:addButtonClick(buttonSoundHandler(self, function()
        self:onStartButtonClick()
    end), false)
end

function PanelLuckyWheel:initActionViewControls()
    self.actionView = self.view.transform:Find("actionView").gameObject
    self.infoTab    = self.view.transform:Find("actionView/tabs/infoTab").gameObject
    self.totalTab   = self.view.transform:Find("actionView/tabs/totalTab").gameObject
    self.inviteTab  = self.view.transform:Find("actionView/tabs/inviteTab").gameObject
    self.ruleButton = self.view.transform:Find("actionView/ruleButton").gameObject
    self.tabs = {self.infoTab, self.totalTab, self.inviteTab}

    self.infoView   = self.view.transform:Find("actionView/actions/infoView").gameObject
    self.infoText_1 = self.view.transform:Find("actionView/actions/infoView/info (1)/Text").gameObject
    self.infoText_2 = self.view.transform:Find("actionView/actions/infoView/info (2)/Text").gameObject
    
    self.totalView       = self.view.transform:Find("actionView/actions/totalView").gameObject
    self.totalScrollView = self.view.transform:Find("actionView/actions/totalView/scrollView").gameObject
    self.totalText       = self.view.transform:Find("actionView/actions/totalView/totalText").gameObject
    for index = 1, PanelLuckyWheel.TOTAL_COUNT do
        local item = {}
        item.view = self.view.transform:Find("actionView/actions/totalView/scrollView/Viewport/Content/item ("..index..")").gameObject
        item.aimCount        = item.view.transform:Find("aimCount").gameObject
        item.redpacketButton = item.view.transform:Find("redpacketButton").gameObject
        item.redpacketCount  = item.view.transform:Find("redpacketButton/Text").gameObject
        item.redpacketReady  = item.view.transform:Find("redpacketButton/Ready").gameObject
        item.aimToggle       = item.view.transform:Find("aimToggle").gameObject
        item.aimToggle:GetComponent('Toggle').interactable = false
        self.totalItems[#self.totalItems + 1] = item
    end

    self.inviteView        = self.view.transform:Find("actionView/actions/inviteView").gameObject
    self.inviteScrollView  = self.view.transform:Find("actionView/actions/inviteView/scrollView").gameObject
    self.inviteContentView = self.view.transform:Find("actionView/actions/inviteView/scrollView/Viewport/Content").gameObject
    self.actions = {self.infoView, self.totalView, self.inviteView}

    self.countView    = self.view.transform:Find("actionView/countView").gameObject
    self.countText    = self.view.transform:Find("actionView/countView/countBg/Text").gameObject
    self.inviteButton = self.view.transform:Find("actionView/countView/inviteButton").gameObject

    -- 添加点击事件
    for index, tab in ipairs(self.tabs) do
        tab:addButtonClick(buttonSoundHandler(self, function()
            self:onTabButtonClick(index)
        end), false)
    end

    self.ruleButton:addButtonClick(buttonSoundHandler(self, function()
        self:onRuleButtonClick()
    end), false)

    for index, totalItem in ipairs(self.totalItems) do
        totalItem.redpacketButton:addButtonClick(buttonSoundHandler(self, function()
            self:onTotalItemButtonClick(index)
        end), false)
    end
    
    self.inviteButton:addButtonClick(buttonSoundHandler(self, function()
        self:onInviteButtonClick()
    end), false)
end

function PanelLuckyWheel:initUIDatas()
    self:onSelectIndex(self.selectIndex)

    for index, item in ipairs(self.wheelItems) do
        local data
        if self.datas.prize_config then
            data = self.datas.prize_config[index]
        end
        if not data then
            return
        end
        data = data or {name = index, pic = ""}
        item.text:setText(data.name)
        GameManager.ImageLoader:loadAndCacheImage(data.pic,function (success, sprite)
            if success and sprite then
                if self.view then
                    item.icon:GetComponent('Image').sprite = sprite
                    item.icon.transform.sizeDelta = Vector3.New(80,80,0)
                end
            end
        end)
    end
    if self.datas.left_times then
        self.residueDegree:setText(self.datas.left_times)
        self.countText:setText(T("抽奖券 <color=#fff156>X")..self.datas.left_times.."</color>")
    end

    local methods = self.datas.methods
    if not methods then
        methods = {
            T("今日在百人大战场\n累计赢金10万"),
            T("邀请好友下载登录\n在微信兑换红包一次"),
        }
    end 
    self.infoText_1:setText(methods[1])
    self.infoText_2:setText(methods[2])

    local missionDatas = self.datas.invite_mission
    local currentGoal = tonumber(missionDatas[#missionDatas].process.goal)
    local current = tonumber(missionDatas[1].process.current)

    for index, mission in ipairs(missionDatas) do
        local item = self.totalItems[index]
        item.aimCount:setText(mission.title)
        item.redpacketCount:setText(GameManager.GameFunctions.getJewel(mission.reward.jewel))
        if current < tonumber(mission.process.goal) 
        and currentGoal == tonumber(missionDatas[#missionDatas].process.goal) then
            currentGoal = tonumber(mission.process.goal)
            item.aimToggle:GetComponent('Toggle').isOn = false
            item.redpacketButton:GetComponent('Button').interactable = false
        else
            if current >= tonumber(mission.process.goal) then
                item.aimToggle:GetComponent('Toggle').isOn = true
                item.redpacketButton:GetComponent('Button').interactable = mission.status == 1
            else
                item.aimToggle:GetComponent('Toggle').isOn = false
                item.redpacketButton:GetComponent('Button').interactable = false
            end
            showOrHide(mission.status == 0, item.redpacketReady)
        end
    end
    local content = missionDatas[1].content
    self.totalText:setText(string.format("%s:  <color=#f4de73>%d/%d</color>", content, current, currentGoal))

    local inviteData = self.datas.my_invite
    table.sort(inviteData, function(a, b)
        return a.status > b.status
    end)
    for index, data in ipairs(inviteData) do
        data.index = index
        if #self.inviteItems < index  then
            local item = LuckyWheelInviteItem.new(newObject(self.LuckyWheelInviteItemPrefab), data)
            item.view.transform:SetParent(self.inviteContentView.transform)
            item.view:scale(Vector3.one)
            self.inviteItems[#self.inviteItems + 1] = item
        else
            item = self.inviteItems[index]
            item:setData(data)
        end
    end
    local height = LuckyWheelInviteItem.HEIGHT * #inviteData + LuckyWheelInviteItem.SPEINGX * (#inviteData - 1)
    self.inviteContentView.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, height)
end

function PanelLuckyWheel:onClose()
    if self.callback then
        self.callback(PanelLuckyWheel.Event.Cancel)
    end
    if self.heightLightTimer then
        self.heightLightTimer:Stop()
        self.heightLightTimer = nil
    end
    if self.lampTimer then
        self.lampTimer:Stop()
        self.lampTimer = nil
    end
    if self.rewardTimer then
        self.rewardTimer:Stop()
        self.rewardTimer = nil
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end


--[[
    private method
]]

function PanelLuckyWheel:showHeightLightAnimation()
    show(self.heightLightImage)
    hide(self.rewardImage)

    if not self.heightLightTimer then
        self.heightLightTimer = Timer.New(function()
            local currentAngle = self.heightLightImage.transform.localEulerAngles.z
            if currentAngle == -PanelLuckyWheel.ANGLE then
                currentAngle = 0
            end
            self.heightLightImage:rotation(0, 0, currentAngle - PanelLuckyWheel.ITEM_ANGLE)
            self.heightLightTimer:Start()
        end, PanelLuckyWheel.TIME.heightLight, -1, true)
        self.heightLightTimer:Start() 
    end
end

function PanelLuckyWheel:showRewardAnimation()
    hide(self.heightLightImage)
    show(self.rewardImage)
    if not self.rewardTimer then
        self.rewardTimer = Timer.New(function()
            if self.rewardLoopIndex > 2 then
                self.rewardLoopIndex = 1
            end
            self.rewardImage:setSprite(string.format("Images/Operation/LuckyWheel/image_reward_%d",self.rewardLoopIndex))
            self.rewardLoopIndex = self.rewardLoopIndex + 1
        end, PanelLuckyWheel.TIME.reward, -1, true)
        self.rewardTimer:Start()
    end
end

function PanelLuckyWheel:showLampAnimation()
    show(self.lamp)
    if not self.lampTimer then
        self.lampTimer = Timer.New(function()
            showOrHide(not self.slowLamp, self.effect)
            local lampLoopIndex = self.lampLoopIndex
            if self.slowLamp then
                if self.lampLoopIndex > 4 then
                    self.lampLoopIndex = 1
                    lampLoopIndex = 1
                elseif self.lampLoopIndex == 1 or self.lampLoopIndex == 2 then
                    lampLoopIndex = 1
                elseif self.lampLoopIndex == 3 or self.lampLoopIndex == 4 then
                    lampLoopIndex = 2
                end
            else
                if self.lampLoopIndex > 2 then
                    self.lampLoopIndex = 1
                    lampLoopIndex = 1
                end
                self.effect:setSprite(string.format("Images/Operation/LuckyWheel/image_effect_%d", lampLoopIndex))
            end
            self.lamp:setSprite(string.format("Images/Operation/LuckyWheel/image_lamp_%d", lampLoopIndex))
            self.lampLoopIndex = self.lampLoopIndex + 1
        end, PanelLuckyWheel.TIME.lamp, -1, true)
        self.lampTimer:Start()
    end
end

function PanelLuckyWheel:showStartButtonAnimation()
    local ratateAnimation = self.centerImage.transform:DOLocalRotate(Vector3.New(0, 0, PanelLuckyWheel.ANGLE * 0.5), PanelLuckyWheel.TIME.startButton)
    ratateAnimation:SetEase(DG.Tweening.Ease.Linear)
    ratateAnimation:SetLoops(1000, DG.Tweening.LoopType.Incremental)
end

function PanelLuckyWheel:showWheelAnimation()
    hide(self.heightLightImage)
    hide(self.rewardImage)
    self.slowLamp = true

    local wheelAnimatin = self.wheelBg.transform:GetComponent('Animator')
    wheelAnimatin.speed = 1
    wheelAnimatin:PlayInFixedTime("wheel", 0, 0)
    GameManager.SoundManager:PlaySoundWithNewSource("luckyWheel")

    local clips = wheelAnimatin.runtimeAnimatorController.animationClips
    local duration = 0
    for index = 0, clips.Length do
        local clip = clips[index]
        if clip.name == "wheel" then
            duration = clip.length
            break
        end    
    end
    Timer.New(function()
        self:resetRewardItemIndex(self.rewardDatas.id)
    end, duration * 0.5, 0, true):Start()
    
    Timer.New(function()
        -- 播放快速动画
        self.slowLamp = false
        self:showRewardAnimation()

        -- 展示获奖内容
        local rewardData = self.datas.prize_config[tonumber(self.rewardDatas.id)]
        rewardData = rewardData or {name = self.rewardDatas.id}
        GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),{url = rewardData.pic, size = Vector3.New(80,80,0)},rewardData.name,"")
        GameManager.UserData.money = tonumber(self.rewardDatas.latest_money)
        GameManager.GameFunctions.setJewel(tonumber(self.rewardDatas.latest_jewel))

        Timer.New(function()
            -- 回复到原来的样子
            self.slowLamp = true
            self.startButton.transform:GetComponent('Button').interactable = true
            -- show(self.maskImage)
            show(self.heightLightImage)
            hide(self.rewardImage)
        end, PanelLuckyWheel.TIME.quickLamp, 0, true):Start()
    end, duration, 0, true):Start()
end

function PanelLuckyWheel:resetRewardItemIndex(rewardIndex)
    -- 中奖的一定是六号位置的 因为转动总角度是3600
    rewardIndex = rewardIndex
    for index, item in ipairs(self.wheelItems) do
        local angle = ((index - rewardIndex) + 5) * -PanelLuckyWheel.ITEM_ANGLE
        item.view:rotation(0, 0, angle)
    end
end

function PanelLuckyWheel:onSelectIndex(index)
    self.selectIndex = index
    for i, button in ipairs(self.tabs) do
        local selectImage = button.transform:Find("selectImage").gameObject
        local selectText  = button.transform:Find("Text").gameObject
        if index == i then
            show(selectImage)
            selectText.transform:GetComponent('Outline').effectColor = Color.New(97/255,132/255,28/255,1)
        else
            hide(selectImage)
            selectText.transform:GetComponent('Outline').effectColor = Color.New(106/255,103/255,111/255,1)
        end
    end

    hide(self.actions)
    show(self.actions[index])
    showOrHide(index ~= PanelLuckyWheel.Tabs.Invite,self.countView)
end

--[[
    event handle
]]
function PanelLuckyWheel:onStartButtonClick()
    -- 判断次数
    if self.datas.left_times <= 0 then
        GameManager.TopTipManager:showTopTip(T("剩余转奖次数不足！"))
        return
    end
    self.startButton.transform:GetComponent('Button').interactable = false
    http.doWheel(
        function(retData)
            if retData.flag == 1 then
                self.residueDegree:setText(retData.left_times)
                self.countText:setText(T("抽奖券 <color=#fff156>X")..retData.left_times.."</color>")
                self.rewardDatas = retData
                -- hide(self.maskImage)
                self.startButton.transform:GetComponent('Button').interactable = false
                self:showWheelAnimation()
            else
                GameManager.TopTipManager:showTopTip(T("转奖失败"))
                self.startButton.transform:GetComponent('Button').interactable = true
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("转奖失败"))
            self.startButton.transform:GetComponent('Button').interactable = true
        end
    )
end

function PanelLuckyWheel:onTabButtonClick(tag)
    if self.selectIndex == tag then
        return
    end
    self:onSelectIndex(tag)
    -- self:updateUIDatas(tag)
end

function PanelLuckyWheel:onRuleButtonClick()
    PanelLuckyWheelRuleDialog.new(self.datas.rule)
end

function PanelLuckyWheel:onTotalItemButtonClick(index)
    local mission      = self.datas.invite_mission[index]
    local id           = mission.id
    local mission_type = mission.mission_type
    local reward_type  = mission.reward_type

    if reward_type == 3 then
        if GameManager.UserData.jewelGain + tonumber(mission.reward.jewel) > GameManager.UserData.jewelLimit then
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("红包上限提示"),
                text = T(string.format("达到今日领取上限%s\n请去提升VIP等级！", GameManager.UserData.jewelLimit)),
                firstButtonCallbcak = function()
                    PanelNewVipHelper.new()
                end,
            })
            return
        end
    end

    http.completeMission(
        id, 
        mission_type,
        function(retData)
            if retData and retData.flag == 1 then
                self:getDatas()
                GameManager.UserData.money = tonumber(retData.latest_money)
                GameManager.GameFunctions.setJewel(tonumber(retData.latest_jewel))
                if reward_type == 1 then
                    GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),reward_type,(T("金币x")..mission.reward.money),"")
                elseif reward_type == 3 then
                    GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),reward_type,(T("红包券x")..GameManager.GameFunctions.getJewel(mission.reward.jewel)),"")
                else
                    GameManager.TopTipManager:showTopTip(T("恭喜你获得对应道具！"))
                end
            else
                GameManager.TopTipManager:showTopTip(T("领取失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager.showTopTip(T("获取数据失败！"))
        end)
end

function PanelLuckyWheel:onInviteButtonClick()
    PanelShareDialog.new()
end
--[[
    获取数据
]]
function PanelLuckyWheel:getDatas()
    local currentVersion = UnityEngine.PlayerPrefs.GetString(DataKeys.LUCKY_WHEEL_VERSION)
    currentVersion = currentVersion or 0
    http.checkWheel(
        currentVersion,
        function(retData)
            if retData.flag == 1 then
                self.datas = retData
                UnityEngine.PlayerPrefs.SetString(DataKeys.LUCKY_WHEEL_CONFIG, json.encode(retData))
                UnityEngine.PlayerPrefs.SetString(DataKeys.LUCKY_WHEEL_VERSION, retData.version)
                self:initUIDatas()
            else
                GameManager.TopTipManager:showTopTip(T("获取转盘数据失败！"))
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("获取转盘数据失败！"))
        end
    )
end

return PanelLuckyWheel