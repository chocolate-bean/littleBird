local PanelLottery = class("PanelLottery")

PanelLottery.CONST = {
    Count = {
        MaxItem  = 12,
        TureItem = 10,
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


--[[
     1-- 2-- 3-- 4       1-- 2-- 3-- 4  
     5-- 6-- 7-- 8  =>  10--GB--RB-- 5
     9--10--11--12       9-- 8-- 7-- 6
]]

function PanelLottery:ctor()
    resMgr:LoadPrefabByRes("Operation", { "PanelLottery" }, function(objs)
        self:initView(objs)
    end)
end

function PanelLottery:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLottery"

    self:initProperties()
    self:initUIControls()
    self:cheeklLottery(function()
        self:initUIDatas()
        self:show()
    end)
end

function PanelLottery:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelLottery:initProperties()
    self.items           = {}
    self.loopIndex       = 1
    self.startLoopTimers = {}
    self.config          = nil
    self.recordData      = nil
    self.goldCost        = 0
    self.redpacketCost   = 0
    self.isTenTimes      = false
end

function PanelLottery:initUIControls()
    self.closeButton  = self.view:findChild("closeButton")
    self.recordButton = self.view:findChild("recordButton")
    self.ruleButton   = self.view:findChild("ruleButton")
    self.barrage      = self.view:findChild("barrage")
    self.barrageText  = self.view:findChild("barrage/text")
    self.tenTimes     = self.view:findChild("tenTimes")
    self.tenTimesText = self.view:findChild("tenTimes/text")
    
    self.closeButton:addButtonClick(buttonSoundHandler(self,self.onCloseButtonClick))
    self.recordButton:addButtonClick(buttonSoundHandler(self,self.onRecordButtonClick))
    self.ruleButton:addButtonClick(buttonSoundHandler(self,self.onRuleButtonClick))
    self.tenTimes:addButtonClick(buttonSoundHandler(self,self.onTenTimesButtonClick))

    self:initContentViewControls()
    self:initOtherViewControls()
end

function PanelLottery:initUIDatas()

    self:initContentViewData()
    self:getRecordAndShow()
end

function PanelLottery:getRecordAndShow()
    self:getLotteryRecord(function()
        self.barrageArray = self.recordData.broadcast
        if self.barrageNeedWait == nil then
            self.barrageNeedWait = false
            self:showLoopBarrage(1)
        else
            self.barrageNeedWait = true
        end
    end)
end

function PanelLottery:showLoopBarrage(index)
    self:showBarrageAnimation(self.barrageArray[index], function()
        index = index + 1
        if index > #self.barrageArray then
            index = 1
        end
        -- 等待完成 判断是否需要更新
        if self.barrageNeedWait then
            self.barrageNeedWait = false
            index = 1 
        end
        self:showLoopBarrage(index)
    end)
end

function PanelLottery:showBarrageAnimation(text, doneCallback)
    self.barrageText:setText(text)
    -- 首先拿到父控件的长度 和 自身的长度 width
    local parentW = self.barrage.transform.sizeDelta.x
    local selfW = self.barrageText.transform:GetComponent('Text').preferredWidth
    self.barrageText.transform.localPosition = Vector3.New((parentW + selfW) * 0.5, 0, 0)

    -- 先展示出来 然后在消失
    -- local startAnimation = self.barrageText.transform:DOLocalMoveX(parentW * -0.5 + selfW * 0.5 + 30, PanelLottery.CONST.Time.BarrageStart)
    -- startAnimation:SetEase(DG.Tweening.Ease.OutBack)
    -- startAnimation:OnComplete(function()
    --     -- 展示等待
    --     local waitAnimation = self.barrageText.transform:DOLocalMoveX(parentW * -0.5 + selfW * 0.5 + 30, PanelLottery.CONST.Time.BarrageShow)
    --     waitAnimation:OnComplete(function()
    --  消失按照长度计算时间
    local duration = (selfW + parentW) / PanelLottery.CONST.Value.BarrageSpeed
    local barrageAnimation = self.barrageText.transform:DOLocalMoveX((parentW + selfW) * -0.5, duration)
    barrageAnimation:SetEase(DG.Tweening.Ease.Linear)
    barrageAnimation:OnComplete(function()
        if doneCallback then
            doneCallback()
        end
    end)
    --     end)
    -- end)
end

function PanelLottery:onClose()
    self:stopLoopTimer()
    self:stopNextLoopTimer()
    self:stopStartLoopTimers()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

function PanelLottery:stopLoopTimer()
    if self.loopTimer then
        self.loopTimer:Stop()
        self.loopTimer = nil
    end
end

function PanelLottery:stopNextLoopTimer()
    if self.nextLoopTimer then
        self.nextLoopTimer:Stop()
        self.nextLoopTimer = nil
    end
end

function PanelLottery:stopStartLoopTimers()
    for index, timer in ipairs(self.startLoopTimers) do
        if timer then
            timer:Stop()
            timer = nil
        end
    end
end

--[[
    other View
]]
function PanelLottery:initOtherViewControls()
    local other = {}
    other.view       = self.view:findChild("otherView")
    other.title      = self.view:findChild("otherView/title")
    other.upLine     = self.view:findChild("otherView/upLine")
    other.content    = self.view:findChild("otherView/content")
    other.text       = self.view:findChild("otherView/content/text")
    other.downLine   = self.view:findChild("otherView/downLine")
    other.backButton = self.view:findChild("otherView/backButton")

    other.backButton:addButtonClick(buttonSoundHandler(self, self.onOtherBackButtonClick))

    self.other = other
end

function PanelLottery:showRuleView()
    show(self.other.view)
    self.other.title:setText(T("抽奖规则"))
    self.other.text:setText(self.config and self.config.rule or T("加载失败"))
end

function PanelLottery:showRecordView()
    show(self.other.view)
    self.other.title:setText(T("中奖纪录"))
    local mylog = ""
    for index, log in ipairs(self.recordData.mylog) do
        mylog = mylog .. string.format(T("恭喜您在 %s，获得奖品：%s"), os.date("%Y/%m/%d %H:%M",log.wtime), log.pname)
        if index ~= #mylog then
            mylog = mylog .. "\n"
        end
    end
    if mylog == "" then
        mylog = T("暂无中奖记录")
    end
    self.other.text:setText(mylog)

    -- 获取当前content的高度 和 text 的高度
    local parentH = self.other.content.transform.sizeDelta.y
    local textH   = self.other.text.transform:GetComponent('Text').preferredHeight
    local offset  = (textH - parentH) * 0.5
    if offset > 0 then
        self.other.text.transform.localPosition = Vector3.New(self.other.text.transform.localPosition.x, -offset, 0)
    end
end

--[[
    content View
]]

function PanelLottery:initContentViewControls()
    self.contentView = self.view:findChild("content")
    local allItems = {}
    for index = 1, PanelLottery.CONST.Count.MaxItem do
        local item = {}
        item.item          = self.view:findChild(string.format("content/item (%d)", index))
        item.view          = item.item:findChild("view")
        item.normal        = item.item:findChild("view/normal")
        item.text          = item.item:findChild("view/text")
        item.icon          = item.item:findChild("view/icon")
        item.highlight     = item.item:findChild("view/highlight")
        item.dark          = item.item:findChild("view/dark")
        item.goldView      = item.item:findChild("goldView")
        item.goldText      = item.item:findChild("goldView/text")
        item.redpacketView = item.item:findChild("redpacketView")
        item.redpacketText = item.item:findChild("redpacketView/text")
        allItems[index] = item
    end

    self.goldItem      = allItems[PanelLottery.CONST.Value.GoldIndex]
    self.redpacketItem = allItems[PanelLottery.CONST.Value.RedpacketIndex]

    for i, index in ipairs(PanelLottery.CONST.Value.Indexs) do
        self.items[i] = allItems[index]
    end
end

function PanelLottery:initContentViewData()
    hide({self.goldItem.view, self.redpacketItem.view})
    show({self.goldItem.goldView, self.redpacketItem.redpacketView})
    self.goldItem.goldView:addButtonClick(buttonSoundHandler(self, self.onGoldButtonClick))
    self.redpacketItem.redpacketView:addButtonClick(buttonSoundHandler(self, self.onRedpacketButtonClick))

    if self.config and self.config.cost then
        for key, cost in pairs(self.config.cost) do
            if tonumber(key) == PanelLottery.CONST.Cost.Gold then
                self.goldCost = tonumber(cost)
                self.goldItem.goldText:setText(cost)
            end
            if tonumber(key) == PanelLottery.CONST.Cost.RedPacket then
                self.redpacketCost = tonumber(cost)
                self.redpacketItem.redpacketText:setText(GameManager.GameFunctions.getJewelWithUnit(cost))
            end
        end
    end

    if self.config and self.config.prize_config then
        for index, item in ipairs(self.items) do
            local itemConfig = self.config.prize_config[index]
            local name = itemConfig.name
            local pic  = itemConfig.pic
            item.text:setText(name)
            GameManager.ImageLoader:loadImageOnlyShop(pic,function (success, sprite)
                if success and sprite then
                    if self.view and item.icon then
                        item.icon:setSprite(sprite)
                        item.icon:GetComponent('Image'):SetNativeSize()
                    end
                end
            end)
        end
    end
    -- 顺时针方向转动
    -- self:showLoopAnimation(self.loopIndex, true)
end

function PanelLottery:enableControlButton(goldEnable, redpacketEnable)
    self.goldItem.goldView           :GetComponent('Button').interactable = goldEnable
    self.redpacketItem.redpacketView:GetComponent('Button').interactable  = redpacketEnable
    self.closeButton                 :GetComponent('Button').interactable = goldEnable
end


function PanelLottery:showLoopAnimation(animtionIndex, needNext)
    for index, item in ipairs(self.items) do
        if index == animtionIndex then
            hide(item.dark)
            show(item.highlight)

            self:stopLoopTimer()

            if not self.loopTimer then
                self.loopTimer = Timer.New(function()
                    showOrHide(not item.highlight.activeSelf, item.highlight)
                end, PanelLottery.CONST.Time.Loop, -1, true)
                self.loopTimer:Start()
            end
            
            if needNext then
                self.nextLoopTimer = Timer.New(function()
                    animtionIndex = animtionIndex + 1 > PanelLottery.CONST.Count.TureItem and 1 or animtionIndex + 1
                    self.loopIndex = animtionIndex
                    self:showLoopAnimation(animtionIndex, needNext)
                end, PanelLottery.CONST.Time.Loop * 4, 1, true)
                self.nextLoopTimer:Start()
            end
        else
            if needNext then
                show(item.dark)
                hide(item.highlight)
            else
                hide(item.dark)
                hide(item.highlight)
            end
        end
    end
end

function PanelLottery:startLoopAnimation(startIndex, stopIndex, loopTimes, callback)
    local offset = stopIndex - startIndex
    if offset < 0 then
        offset = PanelLottery.CONST.Count.TureItem + offset
    end
    -- 总共要移动的步数
    local allCount = loopTimes * PanelLottery.CONST.Count.TureItem + offset

    local map = {3,2,1,1,1,1,1,2,3,7}

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
        local showIndex = (startIndex + index) % PanelLottery.CONST.Count.TureItem
        if showIndex == 0 then
            showIndex = PanelLottery.CONST.Count.TureItem
        end
        self:showIndex(showIndex, delayTime * 0.5, allDelay)
        allDelay = allDelay + delayTime

        if index == allCount then
            local finishTimer = Timer.New(function()
                -- 全部动画完成之后 释放timer 和 播放获奖动画 以及 常驻动画
                self:enableControlButton(true, true)
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

function PanelLottery:showIndex(showIndex, showTime, delayTime)
    for index, item in ipairs(self.items) do
        local firstTimer = Timer.New(function()
            if index == showIndex then
                hide(item.dark)
                show(item.highlight)
            else
                show(item.dark)
                hide(item.highlight)
            end
        end, delayTime, 1, true)
        self.startLoopTimers[#self.startLoopTimers + 1] = firstTimer
        firstTimer:Start()
    end
end

--[[
    event handle
]]

function PanelLottery:onCloseButtonClick()
    self:onClose()
end

function PanelLottery:onRecordButtonClick()
    self:showRecordView()
end

function PanelLottery:onRuleButtonClick()
    self:showRuleView()
end

function PanelLottery:onTenTimesButtonClick()
    self.isTenTimes = not self.isTenTimes
    if self.isTenTimes then
        self.tenTimesText:setText(T("抽\n一\n次"))
    else
        self.tenTimesText:setText(T("抽\n十\n次"))
    end

    if self.config and self.config.cost then
        for key, cost in pairs(self.config.cost) do
            if tonumber(key) == PanelLottery.CONST.Cost.Gold then
                self.goldCost = tonumber(cost)
                self.goldItem.goldText:setText(string.format("%s", formatFiveNumber(tonumber(cost) * (self.isTenTimes and 10 or 1))))
            end
            if tonumber(key) == PanelLottery.CONST.Cost.RedPacket then
                self.redpacketCost = tonumber(cost)
                self.redpacketItem.redpacketText:setText(GameManager.GameFunctions.getJewelWithUnit(cost))
                self.redpacketItem.redpacketText:setText(string.format("%s", GameManager.GameFunctions.getJewelWithUnit(tonumber(cost) * (self.isTenTimes and 10 or 1))))
            end
        end
    end
end

function PanelLottery:onOtherBackButtonClick()
    hide(self.other.view)
end

function PanelLottery:onGoldButtonClick()
    self:doWheelAndAnimation(PanelLottery.CONST.Cost.Gold)
end

function PanelLottery:onRedpacketButtonClick()
    self:doWheelAndAnimation(PanelLottery.CONST.Cost.RedPacket)
end

function PanelLottery:doWheelAndAnimation(type)
    if type == PanelLottery.CONST.Cost.Gold then
        if self.isTenTimes then
            if self.goldCost * 10 > GameManager.UserData.money then
                GameManager.TopTipManager:showTopTip(T("金币数量不足！"))
                return
            end
        else
            if self.goldCost > GameManager.UserData.money then
                GameManager.TopTipManager:showTopTip(T("金币数量不足！"))
                return
            end
        end
    elseif type == PanelLottery.CONST.Cost.RedPacket then
        if self.isTenTimes then
            if self.redpacketCost * 10 > GameManager.UserData.jewel then
                GameManager.TopTipManager:showTopTip(T("红包数量不足！"))
                return
            end
        else
            if self.redpacketCost > GameManager.UserData.jewel then
                GameManager.TopTipManager:showTopTip(T("红包数量不足！"))
                return
            end
        end
    end

    self:enableControlButton(false, false)
    self:doWheelLottery(type, function(isSuccess, data)
        if isSuccess then
            -- 帮他扣钱
            if type == PanelLottery.CONST.Cost.Gold then
                GameManager.UserData.money = GameManager.UserData.money - self.goldCost
            elseif type == PanelLottery.CONST.Cost.RedPacket then
                GameManager.GameFunctions.setJewel(GameManager.UserData.jewel - self.redpacketCost)
            end
            local stopIndex = 0
            for index, itemConfig in ipairs(self.config.prize_config) do
                if data.num > 1 then
                    if itemConfig.id == data.rewardGroup[1].id then
                        stopIndex = index
                    end
                else
                    if itemConfig.id == data.id then
                        stopIndex = index
                    end
                end
            end
            self:stopNextLoopTimer()
            self:stopLoopTimer()
            self:startLoopAnimation(self.loopIndex, stopIndex, PanelLottery.CONST.Value.LoopTimes, function()
                GameManager.UserData.money = tonumber(data.latest_money)
                GameManager.UserData.diamond = tonumber(data.latest_diamon)
                GameManager.GameFunctions.setJewel(tonumber(data.latest_jewel))
                if data.num > 1 then
                    self:showRewardAnimation(data.rewardGroup, 1)
                else
                    GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),data.rtype,data.desc,"")
                end
                self:getRecordAndShow()
            end)
        else
            self:enableControlButton(true, true)
        end
    end)
end

function PanelLottery:showRewardAnimation(group, index)
    if index > #group then
        return
    end
    local data = group[index]
    GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),data.rtype,data.desc,"", function()
        index = index + 1
        self:showRewardAnimation(group, index)
    end)
end

--[[
    http 请求
]]
function PanelLottery:cheeklLottery(doneCallback)
    http.cheeklLottery(
        function(retData)
            if retData.flag == 1 then
                self.config = retData
                if doneCallback then
                    doneCallback()
                end
            else
                GameManager.TopTipManager:showTopTip(T("获取配置失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取配置失败"))
        end
    )
end

function PanelLottery:getLotteryRecord(doneCallback)
    http.getLotteryRecord(
        function(retData)
            if retData.flag == 1 then
                self.recordData = retData
                if doneCallback then
                    doneCallback()
                end
            else
                GameManager.TopTipManager:showTopTip(T("获取记录失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取记录失败"))
        end
    )
end

function PanelLottery:doWheelLottery(type, doneCallback)
    http.doWheelLottery(
        type,
        self.isTenTimes and 10 or 1,
        function(retData)
            if retData.flag == 1 then
                
            else
                GameManager.TopTipManager:showTopTip(T("请求失败"))
            end
            if doneCallback then
                doneCallback(retData.flag == 1, retData)
            end
        end,
        function(callData)
            if doneCallback then
                doneCallback(false, nil)
            end
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

return PanelLottery