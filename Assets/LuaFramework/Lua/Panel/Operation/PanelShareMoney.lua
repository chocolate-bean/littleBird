local PanelShareMoney = class("PanelShareMoney")

PanelShareMoney.CONST = {
    Count = {
        MaxItem  = 20,
        TureItem = 14,
    },
    Value = {
        BarrageSpeed   = 80,
        GoldIndex      = 6,
        RedpacketIndex = 7,
        LoopTimes      = 3,
        Indexs         = {
            1, 2, 3, 4, 
                     8, 
                     12, 11, 10, 9, 
                                 5,
        },
    },
    Time = {
        Loop         = 0.2,
        BarrageStart = 0.5,
        BarrageShow  = 0.2,
    },
    Cost = {
        Gold      = 1,
        RedPacket = 2,
    }
}

function PanelShareMoney:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelShareMoney" }, function(objs)
        self:initView(objs)
    end)
end

function PanelShareMoney:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelShareMoney"

    self:initProperties()
    self:initUIControls()
    self:show(function()
        self:checkWhellVer2()
    end)
end

function PanelShareMoney:show(callback)
    GameManager.PanelManager:addPanel(self,true,1,callback)
end

function PanelShareMoney:initProperties()
    self.loopIndex       = 1
    self.startLoopTimers = {}
    self.tabIndex        = 1        -- 一个项的下标
    self.isEnableTouchable = true   -- 主要用来判断是否其他按钮是否可以点击
    self.imageSprites = {
        UIHelper.LoadSprite("Images/FishingGame/reward/redpacket_1"),
        UIHelper.LoadSprite("Images/FishingGame/reward/redpacket_2"),
        UIHelper.LoadSprite("Images/FishingGame/reward/redpacket_3"),
    }

end

function PanelShareMoney:initUIControls()
    -- 主界面
    self.main = {}
    self.main.view = self.view:findChild("mainView")
    self.main.closeButton = self.view:findChild("mainView/closeButton")
    self.main.shareButton = self.view:findChild("mainView/shareButton")
    self.main.myButton    = self.view:findChild("mainView/myButton")
    
    self.main.closeButton:addButtonClick(buttonSoundHandler(self, self.onClose), false)
    self.main.shareButton:addButtonClick(buttonSoundHandler(self, self.onShareButtonClick), false)
    self.main.myButton:addButtonClick(buttonSoundHandler(self, self.onMyButtonClick), false)

    -- 分享界面
    self.share = {}
    self.share.view = self.view:findChild("shareView")
    self.share.closeButton = self.view:findChild("shareView/closeButton")
    self.share.buttons = {
        self.view:findChild("shareView/layout/Button (1)"),
        self.view:findChild("shareView/layout/Button (2)"),
        self.view:findChild("shareView/layout/Button (3)"),
    }
    self.share.qrCode = self.view:findChild("shareView/layout/Button (2)/Image")
    self.share.link = self.view:findChild("shareView/layout/Button (3)/Image/link")

    self.share.closeButton:addButtonClick(buttonSoundHandler(self, self.onShareCloseButtonClick), false)
    self.share.buttons[1]:addButtonClick(buttonSoundHandler(self, self.onShareWechatButtonClick), false)
    self.share.buttons[3]:addButtonClick(buttonSoundHandler(self, self.onShareLinkButtonClick), false)

    -- 我的界面
    self.money = {}
    self.money.view = self.view:findChild("moneyView")
    self.money.closeButton = self.view:findChild("moneyView/closeButton")
    self.money.sendButton = self.view:findChild("moneyView/sendButton")
    self.money.leftToggles ={}
    self.money.contents = {}
    for i = 1, 4 do

        -- 减少路径编写
        local content = {}
        content.view = self.view:findChild(string.format("moneyView/contentView/%d", i))
        
        if i == 1 then
            content.infoButton    = content.view:findChild("InfoButton")
            content.loopButton    = content.view:findChild("bg/LoopButton")
            content.loopTimesText = content.view:findChild("bg/LoopButton/Text")
            content.loopInfoText  = content.view:findChild("bg/Info")
            content.tabs = {}
            for j = 1, 3 do
                content.tabs[j] = {}
                local toggle = content.view:findChild(string.format("tabs/Toggle (%d)", j))
                content.tabs[j].toggle        = toggle
                content.tabs[j].highlightText = toggle:findChild("HighlightText")
                content.tabs[j].normalText    = toggle:findChild("NormalText")

                UIHelper.AddToggleClick(toggle, function()
                    self:onContent_1_TabClick(j)
                end)
            end
            content.items = {}
            local allItems = {}
            -- 这里的20个 有六个 是需要隐藏 innerview 为了将抽奖按钮显示出来 7,8,9, 12,13,14
            local trueIndexs = {
                1, 2, 3, 4, 5, 
                            10,
                            15, 
                            20, 19, 18, 17, 16,
                                            11,
                                            6
            }

            local indexString = "_"
            for i, index in ipairs({7,8,9, 12,13,14}) do
                indexString = indexString .. index .. "_"
            end

            for j = 1, 20 do
                allItems[j] = {}
                allItems[j].view      = content.view:findChild(string.format("bg/content/item (%d)", j))
                allItems[j].innerView = content.view:findChild(string.format("bg/content/item (%d)/view", j))
                allItems[j].text      = content.view:findChild(string.format("bg/content/item (%d)/view/text", j))
                allItems[j].icon      = content.view:findChild(string.format("bg/content/item (%d)/view/icon", j))
                allItems[j].highlight = content.view:findChild(string.format("bg/content/item (%d)/view/highlight", j))

                allItems[j].setData = function(data)
                    allItems[j].text:setText(data.name)
                    allItems[j].icon:setSprite(self.imageSprites[tonumber(data.pic_local)])
                end

                if string.find(indexString, string.format("_%d_", j)) then
                    hide(allItems[j].innerView)
                end
            end

            for j, index in ipairs(trueIndexs) do
                content.items[j] = allItems[index]
            end

            content.infoButton:addButtonClick(buttonSoundHandler(self, self.onContent_1_RuleButtonClick), false)
            content.loopButton:addButtonClick(buttonSoundHandler(self, self.onContent_1_LoopButtonClick), false)

        elseif i == 2 then
            content.items = {}
            content.scrollView = content.view
            content.contentView = content.view:findChild("Viewport/Content")
            content.fakePrefab = content.view:findChild("Viewport/Content/item (1)")
            hide(content.fakePrefab)
            content.getItem = function(index)
                local content = self.money.contents[2]
                local item = content.items[index]
                if item then
                    return item
                end
                item = {}
                item.view         = newObject(content.fakePrefab)
                item.icon         = item.view:findChild("Icon")
                item.title        = item.view:findChild("Title")
                item.button       = item.view:findChild("button")
                item.buttonText   = item.view:findChild("button/Text")
                item.progress     = item.view:findChild("progressBar")
                item.progressText = item.view:findChild("progressBar/Text")
                item.rewardIcon_1 = item.view:findChild("Reward (1)")
                item.rewardText_1 = item.view:findChild("Reward (1)/Text")
                item.rewardIcon_2 = item.view:findChild("Reward (2)")
                item.rewardText_2 = item.view:findChild("Reward (2)/Text")
                item.view.transform:SetParent(content.contentView.transform)

                item.setData = function(data)
                    item.title:setText(data.content)
                    item.progress.transform:GetComponent('Slider').maxValue = tonumber(data.process.goal)
                    item.progress.transform:GetComponent('Slider').value = tonumber(data.process.current)
                    item.progressText:setText(string.format("%d/%d", tonumber(data.process.current), tonumber(data.process.goal)))
                    item.rewardText_1:setText(string.format("x%s", formatFiveNumber(data.reward.money)))
                    item.rewardText_2:setText(string.format("x%s", GameManager.GameFunctions.getJewelWithUnit(data.reward.jewel)))
                    GameManager.ImageLoader:loadAndCacheImage(data.icon, function(success, sprite)
                        if success and sprite then
                            if item.icon then
                                item.icon:setSprite(sprite)
                            end
                        end
                    end)

                    if data.status == 1 then
                        item.buttonText:setText(T("去完成"))
                        if tonumber(data.process.current) >= tonumber(data.process.goal) then 
                            item.buttonText:setText(T("领取"))
                        end
                    else
                        item.buttonText:setText(T("已完成"))
                    end
                end

                item.button:addButtonClick(buttonSoundHandler(self, function()
                    self:onContent_2_ItemClick(index)
                end), false)

                show(item.view)
                table.insert(self.money.contents[2].items, item)
                item.view.transform.localScale = Vector3.one
                content.contentView.transform.sizeDelta = Vector3.New(item.view.transform.sizeDelta.x, item.view.transform.sizeDelta.y * #self.money.contents[2].items)
                content.scrollView:GetComponent('ScrollRect').verticalNormalizedPosition = 1
                return item
            end
        elseif i == 3 then
            content.rule = content.view:findChild("Viewport/Content")
        elseif i == 4 then
            content.items = {}
            content.scrollView = content.view:findChild("ScrollView")
            content.contentView = content.view:findChild("ScrollView/Viewport/Content")
            content.fakePrefab = content.view:findChild("ScrollView/Viewport/Content/item (1)")
            hide(content.fakePrefab)
            content.getItem = function(index)
                local content = self.money.contents[4]
                local item = content.items[index]
                if item then
                    return item
                end
                item = {}
                item.view  = newObject(content.fakePrefab)
                item.bg    = item.view:findChild("Image")
                item.index = item.view:findChild("TitleLayout/Index")
                item.id    = item.view:findChild("TitleLayout/ID")
                item.name  = item.view:findChild("TitleLayout/Name")
                item.time  = item.view:findChild("TitleLayout/Time")
                item.done  = item.view:findChild("TitleLayout/Done")
                item.level = item.view:findChild("TitleLayout/Level")
                item.view.transform:SetParent(content.contentView.transform)
                
                item.index:setText(tostring(index))

                item.setData = function(data)
                    if data then
                        item.name:setText(data.invite_name)
                        item.time:setText(os.date("%Y/%m/%d", data.mtime))
                        item.id:setText(data.invite_mid)
                        item.done:setText(T("未完成"))
                        item.level:setText(data.vip)
                        for _, index in ipairs(data.process) do
                            if tonumber(index) == 1 then
                                item.done:setText(T("完成"))
                            end
                        end
                    else
                        item.index: setText("----")
                        item.id   : setText("----")
                        item.name : setText("----")
                        item.time : setText("----")
                        item.done : setText("----")
                        item.level: setText("----")
                    end
                end

                show(item.view)
                showOrHide(index % 2 == 1, item.bg)
                table.insert(self.money.contents[4].items, item)
                item.view.transform.localScale = Vector3.one
                content.contentView.transform.sizeDelta = Vector3.New(item.view.transform.sizeDelta.x, item.view.transform.sizeDelta.y * #self.money.contents[4].items)
                content.scrollView:GetComponent('ScrollRect').verticalNormalizedPosition = 1
                return item
            end
        end

        self.money.contents[i] = content
        self.money.leftToggles[i] = self.view:findChild(string.format("moneyView/left/Toggle (%d)", i))

        UIHelper.AddToggleClick(self.money.leftToggles[i], function()
            self:onLeftToggleClick(i)
        end)
    end
    self.money.closeButton:addButtonClick(buttonSoundHandler(self, self.onMoneyCloseButtonClick), false)
    self.money.sendButton:addButtonClick(buttonSoundHandler(self, self.onMoneySendButtonClick), false)
end

function PanelShareMoney:initUIDatas()

    self.share.link:setText(self.data.link.share_url)
    GameManager.ImageLoader:loadAndCacheImage(self.data.link.qrcode_url,function (success, sprite)
        if success and sprite then
            if self.share.qrCode then
                self.share.qrCode:setSprite(sprite)
            end
        end
    end)

    --[[
        1
    ]]
    self:onContent_1_TabClick(self.tabIndex)
    
    --[[
        2
    ]]
    -- 任务数据
    local missionDatas = self.data.invite_mission
    -- 这个就不判定空了
    for index, data in ipairs(missionDatas) do
        self.money.contents[2].getItem(index).setData(data)
    end

    --[[
        3
    ]]
    GameManager.ImageLoader:loadAndCacheImage(self.data.rule.tip_url,function (success, sprite)
        if success and sprite then
            if self.money.contents[3].rule then
                self.money.contents[3].rule:setSprite(sprite)
            end
        end
    end)

    --[[
        4
    ]]
    -- 邀请数据
    local inviteDatas = self.data.my_invite
    if #inviteDatas == 0 then
        -- 直接强制获取一个 然后复制为空
        self.money.contents[4].getItem(1).setData(nil)
    else
        for index, data in ipairs(inviteDatas) do
            self.money.contents[4].getItem(index).setData(data)
        end
    end
end


--[[
    private method
]]

function PanelShareMoney:enableTouchable(isEnable)

    self.isEnableTouchable = isEnable

    self.money.sendButton:GetComponent('Button').interactable = isEnable
    self.money.closeButton:GetComponent('Button').interactable = isEnable

    for _, toggle in ipairs(self.money.leftToggles) do
        toggle:GetComponent('Toggle').interactable = isEnable
    end

    self.money.contents[1].infoButton:GetComponent('Button').interactable = isEnable
    self.money.contents[1].loopButton:GetComponent('Button').interactable = isEnable

    for _, tab in ipairs(self.money.contents[1].tabs) do
        tab.toggle:GetComponent('Toggle').interactable = isEnable
    end
end


function PanelShareMoney:stopLoopTimer()
    if self.loopTimer then
        self.loopTimer:Stop()
        self.loopTimer = nil
    end
end

function PanelShareMoney:stopNextLoopTimer()
    if self.nextLoopTimer then
        self.nextLoopTimer:Stop()
        self.nextLoopTimer = nil
    end
end

function PanelShareMoney:stopStartLoopTimers()
    for index, timer in ipairs(self.startLoopTimers) do
        if timer then
            timer:Stop()
            timer = nil
        end
    end
end

function PanelShareMoney:showLoopAnimation(animtionIndex, needNext)
    for index, item in ipairs(self.money.contents[1].items) do
        if index == animtionIndex then
            show(item.highlight)

            self:stopLoopTimer()

            if not self.loopTimer then
                self.loopTimer = Timer.New(function()
                    showOrHide(not item.highlight.activeSelf, item.highlight)
                end, PanelShareMoney.CONST.Time.Loop, -1, true)
                self.loopTimer:Start()
            end
            
            if needNext then
                self.nextLoopTimer = Timer.New(function()
                    animtionIndex = animtionIndex + 1 > PanelShareMoney.CONST.Count.TureItem and 1 or animtionIndex + 1
                    self.loopIndex = animtionIndex
                    self:showLoopAnimation(animtionIndex, needNext)
                end, PanelShareMoney.CONST.Time.Loop * 4, 1, true)
                self.nextLoopTimer:Start()
            end
        else
            hide(item.highlight)
        end
    end
end

function PanelShareMoney:startLoopAnimation(startIndex, stopIndex, loopTimes, callback)
    self:stopNextLoopTimer()
    self:stopLoopTimer()
    local offset = stopIndex - startIndex
    if offset < 0 then
        offset = PanelShareMoney.CONST.Count.TureItem + offset
    end
    -- 总共要移动的步数
    local allCount = loopTimes * PanelShareMoney.CONST.Count.TureItem + offset

    local map = {3,2,1,1,1, 1,1,1,1, 1,1,2,3,7}

    -- 取得每一步落在哪个段
    local avgStep = allCount / #map
    local allCountDelayMap = {}
    for j = 1, allCount do
        local jmap = j / avgStep
        local step = math.ceil(jmap)
        -- 理论上向上取整的话 jmap是要比step小的 如果一致 说明靠右边
        local i = 1 - (step - jmap) - 0.5
        if i == 0 then
            i = 1
        end
        local next, current
        if step ~= #map then
            next = map[step + 1]
            current = map[step]
        else
            next = map[step]
            current = map[step - 1]
            i = i + 1
        end

        local value = i * (next - current) + current
        allCountDelayMap[j] = value
    end
    
    local allDelay = 0
    for index = 1, allCount do
        local delayTime = allCountDelayMap[index] / 10
        local showIndex = (startIndex + index) % PanelShareMoney.CONST.Count.TureItem
        if showIndex == 0 then
            showIndex = PanelShareMoney.CONST.Count.TureItem
        end
        self:showIndex(showIndex, delayTime * 0.5, allDelay)
        allDelay = allDelay + delayTime

        if index == allCount then
            local finishTimer = Timer.New(function()
                -- 全部动画完成之后 释放timer 和 播放获奖动画 以及 常驻动画
                -- self:enableControlButton(true, true)
                self.loopIndex = stopIndex
                self:stopStartLoopTimers()
                self:showLoopAnimation(stopIndex, false)
                if callback then
                    callback()
                end
            end, allDelay, 1, true)
            self.startLoopTimers[#self.startLoopTimers + 1] = finishTimer
            finishTimer:Start()
        end
    end
end

function PanelShareMoney:showIndex(showIndex, showTime, delayTime)
    for index, item in ipairs(self.money.contents[1].items) do
        local firstTimer = Timer.New(function()
            showOrHide(index == showIndex, item.highlight)
        end, delayTime, 1, true)
        self.startLoopTimers[#self.startLoopTimers + 1] = firstTimer
        firstTimer:Start()
    end
end

--[[
    Event handle
]]

function PanelShareMoney:onShareButtonClick()
    show(self.share.view)
    hide(self.main.view)
    hide(self.money.view)
end

function PanelShareMoney:onMyButtonClick()
    show(self.money.view)
    hide(self.main.view)
    hide(self.share.view)
end

function PanelShareMoney:onShareWechatButtonClick()
    --[[
        跳转到微信分享 需要内容(链接)
    ]]
    sdkMgr:WechatShareWebpage("0", self.data.link.share_url, self.data.rule.share_title, self.data.rule.share_content)
end

function PanelShareMoney:onShareLinkButtonClick()
    local shareLink = self.data.link.share_url
    sdkMgr:CopyTextToClipboard(shareLink)
    GameManager.TopTipManager:showTopTip(T("复制成功!"))
end

function PanelShareMoney:onShareCloseButtonClick()
    hide(self.share.view)
    show(self.main.view)
end

function PanelShareMoney:onMoneyCloseButtonClick()
    self:onClose()
end

function PanelShareMoney:onMoneySendButtonClick()
    self:onShareButtonClick()
end

function PanelShareMoney:onLeftToggleClick(index)
    for i, content in ipairs(self.money.contents) do
        showOrHide(index == i, content.view)
    end
end

function PanelShareMoney:onContent_1_TabClick(index)
    self.tabIndex = index

    for i, tab in ipairs(self.money.contents[1].tabs) do
        showOrHide(index == i, tab.highlightText)
        showOrHide(index ~= i, tab.normalText)
    end

    -- 填充item数据
    local loopItemDatas = self.data.prize_config[index]
    for jndex, data in ipairs(loopItemDatas) do
        local item = self.money.contents[1].items[jndex].setData(data)
    end

    -- 次数
    local leftTimeData = self.data.left_times[tostring(index)]
    self.money.contents[1].loopTimesText:setText(string.format("剩余 %s 次", leftTimeData))

    -- 规则 的下标用的是 字符串
    local rule = self.data.rule.condition[tostring(index)]
    self.money.contents[1].loopInfoText:setText(rule)
end

function PanelShareMoney:onContent_1_RuleButtonClick()
    self.money.leftToggles[3]:GetComponent('Toggle').isOn = true
end

function PanelShareMoney:onContent_1_LoopButtonClick()

    if tonumber(self.data.left_times[tostring(self.tabIndex)]) <= 0 then
        GameManager.TopTipManager:showTopTip(T("次数不足!"))
        return
    end

    self:stopNextLoopTimer()
    self:stopLoopTimer()
    self:enableTouchable(false)

    self:doWheelVer2(self.tabIndex, function(callData)
        local endIndex = -1
        for index, data in ipairs(self.data.prize_config[tonumber(callData.group)]) do
            if tonumber(data.id) == tonumber(callData.id) then
                endIndex = index
            end
        end

        if endIndex == -1 then
            print("没有找到??")
            endIndex = self.loopIndex
        end

        self:startLoopAnimation(self.loopIndex, endIndex, 1, function()
            GameManager.AnimationManager:playRewardAnimation(T("领取奖励"), callData.rtype, callData.desc, "", function()
                self:checkWhellVer2()
                self:enableTouchable(true)
                GameManager.UserData.money = callData.latest_money
                GameManager.GameFunctions.setJewel(callData.latest_jewel)
            end)
        end)
    end)

end

function PanelShareMoney:onContent_2_ItemClick(index)
    --[[
        请求链接 完成任务的
    ]]

    local data = self.data.invite_mission[index]
    -- 首先判断状态
    if data.status == 1 then

        if tonumber(data.process.current) >= tonumber(data.process.goal) then
            -- 完成了
            self:completeMission(data.id, function(callData)

                -- 自己换算
                callData.desc = string.format(T("x%s金币\nx%s"), formatFiveNumber(data.reward.money), GameManager.GameFunctions.getJewelWithUnit(data.reward.jewel))
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"), callData.rtype, callData.desc, "", function()
                    self:checkWhellVer2()
                    GameManager.UserData.money = callData.latest_money
                    GameManager.GameFunctions.setJewel(callData.latest_jewel)
                end)
            end)
        else
            if data.action_name ~= "unsatified" then
                GameManager.ActivityJumpConfig:Jump(data.action_name)
            else
                self:onShareButtonClick()
            end

        end
    else
        -- 已经领取了
    end
end

function PanelShareMoney:onClose()
    -- 判断是不是在
    if not self.isEnableTouchable then
        return
    end
    GameManager.PanelManager:removePanel(self, nil, function()
        destroy(self.view)
        self.view = nil
        if callback then
            callback()
        end
    end)
end


--[[
    Http
]]

function PanelShareMoney:checkWhellVer2()
    http.checkWheelVer2(
        function(callData)
            if callData and callData.flag == 1 then
                self.data = callData
                self:initUIDatas()
            end
        end,
        function(callData) end
    )
end

function PanelShareMoney:doWheelVer2(group , callback)
    http.doWheelVer2(
        group, GameManager.UserData.mid,
        function(callData)
            if callData and callData.flag == 1 then
                if callback then
                    callback(callData)
                end
            end
        end, 
        function(callData) end)
end


function PanelShareMoney:completeMission(id, callback)
    -- type 给 2
    http.completeMission(id, 2, 
    function(callData)
        if callData and callData.flag == 1 then
            if callback then
                callback(callData)
            end
        end
    end, 
    function(callData) end)
end

return PanelShareMoney