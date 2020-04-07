local PanelOneToMillion = class("PanelOneToMillion")


function PanelOneToMillion:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelOneToMillion", "OtmTaskItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelOneToMillion:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelOneToMillion"

    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelOneToMillion:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelOneToMillion:initProperties(objs)
    self.taskItemPrefab = objs[1]
    self.taskItems = {}
end


function PanelOneToMillion:initUIControls()
    self.bg = self.view:findChild("bg")
    self.closeButton     = self.view:findChild("bg/closeButton")
    self.phaseText       = self.view:findChild("bg/phaseText")
    self.timeText        = self.view:findChild("bg/timeText")
    self.ruleText        = self.view:findChild("bg/ruleText")
    self.activeButton    = self.view:findChild("bg/activeButton")
    self.activeText      = self.view:findChild("bg/activeButton/Text")
    self.taskViewContent = self.view:findChild("bg/taskView/Viewport/Content")
    self.totalText       = self.view:findChild("bg/totalText")
    self.rewardItems = {}
    for i = 1, 2 do
        local item = {}
        item.view = self.view:findChild(string.format("bg/rewardView/rewardItem (%d)", i))
        item.icon = item.view:findChild("icon")
        item.name = item.view:findChild("name")
        self.rewardItems[i] = item
    end
    self.numbers = {}
    for i = 1, 10 do
        self.numbers[i] = self.view:findChild(string.format("bg/totalView/number (%d)/Text", i))
    end

    self.closeButton:addButtonClick(buttonSoundHandler(self, function()
        self:onCloseButtonClick()
    end))

    self.activeButton:addButtonClick(buttonSoundHandler(self, function()
        self:onActiveButtonClick()
    end))
end

function PanelOneToMillion:initUIDatas()
    self:getUserCapitalProfit(function()
        self.phaseText:setText(self.data.description.level_desc)
        self.timeText:setText(self.data.description.expire)
        self.ruleText:setText(self.data.description.tips)
        self.activeText:setText(self.data.description.button)
        if self.data.valid == 1 then
            self.activeText:setText(T("已激活"))
            self.activeButton:GetComponent('Button').interactable = false
        else
            self.activeButton:GetComponent('Button').interactable = true
        end
        self.rewardItems[1].name:setText(self.data.description.activate)
        self.rewardItems[2].name:setText(self.data.description.complete)
        GameManager.ImageLoader:loadAndCacheImage(self.data.description.activatePic,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.rewardItems[1].icon:setSprite(sprite)
                    self.rewardItems[1].icon:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
        GameManager.ImageLoader:loadAndCacheImage(self.data.description.completePic,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.rewardItems[2].icon:setSprite(sprite)
                    self.rewardItems[2].icon:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
        self:setNumber(self.data.description.win_money .. "")

        if #self.taskItems == 0 then
            for i = 1, #self.data.mission do
                local item = self:newOtmTaskItem(i)
                self.taskItems[#self.taskItems + 1] = item
                self:setItemData(item, self.data.mission[i])
            end
        else
            for i = 1, #self.data.mission do
                self:setItemData(self.taskItems[i], self.data.mission[i])
            end
        end
    end)
end

function PanelOneToMillion:reloadData()
    self:initUIDatas()
end

function PanelOneToMillion:onClose(callback)
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
        if callback then
            callback()
        end
    end)
end


function PanelOneToMillion:setNumber(number)
    local numberList = {}
    for i = string.len(number), 1, -1 do
        numberList[#numberList + 1] = string.sub(number, i, i)
    end
    
    local doneIndex = 1
    for i = #self.numbers, 1, -1 do
        local item = self.numbers[i]
        if doneIndex > #numberList then
            item:setText("0")
        else
            item:setText(numberList[doneIndex])
        end
        doneIndex = doneIndex + 1
    end
end

--[[
    event handle
]]

function PanelOneToMillion:onActiveButtonClick()
    -- 判断是否激活
    if self.data.valid == 0 then
        self.data.product.from = "capitalProfit"
        local PanelPay = import("Panel.Shop.PanelPay").new(self.data.product)
        self:onClose()
    end
end

function PanelOneToMillion:onCloseButtonClick( )
    self:onClose()
end


--[[
    http
]]

function PanelOneToMillion:getUserCapitalProfit(callback)
    http.getUserCapitalProfit(
        function(callData)
            if callData then
                dump(callData)
                print(json.encode(callData))
                if callData.flag == 1 then
                    self.data = callData
                    if callback then
                        callback()
                    end
                end
            end
        end,
        function(callData)
            dump(callData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败！"))
        end
    )
end

function PanelOneToMillion:completeProfitMission(profitId, missionId, callback)
    http.completeProfitMission(
        profitId,
        missionId,
        function(callData)
            if callData and callData.flag == 1 then
                if callback then
                    callback(callData)
                end
            end
        end,
        function(callData)
            dump(callData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败！"))
        end
    )
end

--[[
    Task Item
]]

function PanelOneToMillion:newOtmTaskItem(index)
    local item = {}
    item.view = newObject(self.taskItemPrefab)
    item.view.transform:SetParent(self.taskViewContent.transform)
    item.view:scale(Vector3.one)

    item.receiveButton = item.view:findChild("receiveButton")
    item.receiveText   = item.view:findChild("receiveButton/Text")
    item.infoText      = item.view:findChild("infoText")
    item.rewardText    = item.view:findChild("rewardText")
    item.icon          = item.view:findChild("icon")
    item.progress      = item.view:findChild("progressBar")
    item.progressText  = item.view:findChild("progressBar/Text")

    item.receiveButton:addButtonClick(buttonSoundHandler(self, function()
        self:onItemReceiveButtonClick(index)
    end))

    return item
end

function PanelOneToMillion:setItemData(item, data)
    item.data = data
    item.infoText:setText(data.title)
    item.progress.transform:GetComponent('Slider').maxValue = tonumber(data.process.goal)
    item.progress.transform:GetComponent('Slider').value = tonumber(data.process.current)
    item.progressText:setText(string.format("%s/%s", tostring(data.process.current), tostring(data.process.goal)))

    if data.reward_type == CONSTS.PROPS.GOLD then
        item.rewardText:setText(string.format("x%s", tostring(data.reward.money)))
    elseif data.reward_type == CONSTS.PROPS.JEWEL_REDPACKET then
        item.rewardText:setText(string.format("%s", GameManager.GameFunctions.getJewelWithUnit(data.reward.jewel)))
    elseif data.reward_type == CONSTS.PROPS.DECORATE then
        item.rewardText:setText(string.format("x%s", tostring(data.reward.prop.num)))
    end
    item.icon:setSprite("Images/SenceMainHall/fuliItem"..data.reward_type)

    --[[
        1-激活状态
        0-待激活
    ]]
    if self.data.valid == 0 then
        item.receiveText:setText(T("未激活"))
        item.receiveButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGrayMiddle")
        item.receiveButton:GetComponent('Button').interactable = false
    else
        --[[
            0. 已领取
            1. 准备完成
            ]]
        -- item.receiveButton:SetActive(false)
        if data.status == 0 then
            item.receiveText:setText(T("已领取"))
            item.receiveButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGrayMiddle")
            item.receiveButton:GetComponent('Button').interactable = false
        elseif data.status == 1 then
            item.receiveText:setText(T("去完成"))
            item.receiveButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnOrangeMiddle")
            item.receiveButton:GetComponent('Button').interactable = true
            -- 这里判断是不是可以领取了
            if tonumber(data.process.current) >= tonumber(data.process.goal) then
                item.receiveText:setText(T("领取"))
                item.receiveButton.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGreenMiddle")
            end
        end
    end

end

function PanelOneToMillion:onItemReceiveButtonClick(index)
    -- GameManager.TopTipManager:showTopTip("当前点击了第"..index.."个")
    local item = self.taskItems[index]
    local data = item.data

    if data.status == 1 then
        if tonumber(data.process.current) >= tonumber(data.process.goal) then
            -- 跳转去请求领取
            print("pid:"..self.data.profit_id.." mid"..data.id)
            self:completeProfitMission(self.data.profit_id, data.id, function(callData)
                GameManager.UserData.money = tonumber(callData.latest_money)
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                if self.view then
                    self:reloadData()
                end
            end)
        else
            if data.action_name == "unsatified" then
            else
                GameManager.ActivityJumpConfig:Jump(data.action_name)
            end
        end
    end
end

return PanelOneToMillion