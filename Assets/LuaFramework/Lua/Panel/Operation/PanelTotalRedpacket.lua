local PanelTotalRedpacket = class("PanelTotalRedpacket")
local PanelNewVipHelper      = require("Panel.Special.PanelNewVipHelper")

PanelTotalRedpacket.ITEM_COUNT = 7

PanelTotalRedpacket.Event = {
    Show    = 1,
    Success = 2,
    Cancel  = 3,
}

function PanelTotalRedpacket:ctor(callback)
    resMgr:LoadPrefabByRes("Operation", { "PanelTotalRedpacket" }, function(objs)
        self:initView(objs, callback)
    end)
end

function PanelTotalRedpacket:initView(objs, callback)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelTotalRedpacket"

    self:initProperties(callback)
    self:initUIControls()
    self:initUIDatas()
    self:getSlotNiuNiuwinChallenge()
    self:show()
end

function PanelTotalRedpacket:show()
    if self.callback then
        self.callback(PanelTotalRedpacket.Event.Show)
    end
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelTotalRedpacket:initProperties(callback)
    self.callback = callback
    self.items = {}
    self.datas = nil
end

function PanelTotalRedpacket:initUIControls()
    self.closeButton       = self.view.transform:Find("bg/topView/closeButton").gameObject
    self.currentItemMoney  = self.view.transform:Find("bg/contentView/currentItem/money").gameObject
    self.currentItemInfo   = self.view.transform:Find("bg/contentView/currentItem/info").gameObject
    self.nextItemMoney     = self.view.transform:Find("bg/contentView/nextItem/money").gameObject
    self.nextItemInfo      = self.view.transform:Find("bg/contentView/nextItem/info").gameObject
    self.scrollView        = self.view.transform:Find("bg/contentView/scrollView").gameObject
    self.scrollContentView = self.view.transform:Find("bg/contentView/scrollView/Viewport/Content").gameObject
    self.layout            = self.view.transform:Find("bg/contentView/scrollView/Viewport/Content/layout").gameObject
    self.slider            = self.view.transform:Find("bg/contentView/scrollView/Viewport/Content/slider").gameObject

    for index = 1, PanelTotalRedpacket.ITEM_COUNT do
        local item = {}
        item.view       = self.layout.transform:Find("item ("..index..")").gameObject
        item.money      = item.view.transform:Find("aimMoney").gameObject
        item.redpacket  = item.view.transform:Find("redpacketBg/Text").gameObject
        item.button     = item.view.transform:Find("button").gameObject
        item.buttonText = item.view.transform:Find("button/Text").gameObject
        item.aimToggle  = item.view.transform:Find("aim").gameObject

        item.button:addButtonClick(buttonSoundHandler(self,function()
            self:onItemButtonClick(index)
        end), false)

        self.items[index] = item
    end

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)
end

function PanelTotalRedpacket:initUIDatas()

    if not self.datas then
        return
    end

    --[[
        mission_type:2
        title:"100万"
        id:37
        status:1 已经领取了
        goal:1000000
        reward_jewel:50 
    ]]

    self.currentItemMoney:setText(formatFiveNumber(self.datas.process))
    local nextMoney = self.datas.currentGoal - self.datas.process
    if nextMoney >= 0 then
        self.nextItemMoney:setText(formatFiveNumber(nextMoney))
    else
        self.nextItemMoney:setText(T("全部完成"))
    end

    for index, item in ipairs(self.items) do
        local mission = self.datas.mission[index]
        item.money:setText(mission.title)
        item.redpacket:setText(mission.reward_jewel)

        if mission.status == 0 then
            item.buttonText:setText(T("已领取"))
            item.aimToggle:GetComponent('Toggle').isOn = true
            item.button:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGraySmallx")
        else
            if self.datas.process < mission.goal then
                item.buttonText:setText(T("未完成"))
                item.aimToggle:GetComponent('Toggle').isOn = false
                item.button:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGraySmallx")
            else
                item.buttonText:setText(T("领取"))
                item.aimToggle:GetComponent('Toggle').isOn = true
                item.button:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/btnGreenSmallx")
            end
            
        end
    end

    --[[
        计算slider
    ]]
    local sliderConfig = {
        8,
        22,
        36,
        50,
        65,
        79,
        93,
    }

    local datas = self.datas
    local currentSliderValue = sliderConfig[#sliderConfig]
    for index, value in ipairs(sliderConfig) do
        -- 需不需要限制住
        local goal = datas.process -- 不限制 有多少是多少
        -- local goal = datas.currentGoal -- 限制 没完成这个 下一个就不过去

        if goal < datas.mission[index].goal then

            local minValue = 0
            local maxValue = value
            local minGoal  = 0
            local maxGoal  = datas.mission[index].goal

            if index ~= 1 then
                minGoal  = datas.mission[index - 1].goal
                minValue = sliderConfig[index - 1]
            end

            local rateValue = (maxValue - minValue) / (maxGoal - minGoal)
            currentSliderValue = (goal - minGoal) * rateValue + minValue

            break
        elseif goal == datas.mission[index].goal then
            currentSliderValue = value
            break
        end
    end
    if currentSliderValue == sliderConfig[#sliderConfig] then
        currentSliderValue = self.slider:GetComponent('Slider').maxValue
    end
    self.slider:GetComponent('Slider').value = currentSliderValue
end

function PanelTotalRedpacket:onClose()
    if self.callback then
        self.callback(PanelTotalRedpacket.Event.Cancel)
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

--[[
    event handle
]]

function PanelTotalRedpacket:onItemButtonClick(index)

    local mission = self.datas.mission[index]
    if mission.status == 0 then
        GameManager.TopTipManager:showTopTip(T("已经领取过了"))
        return
    end
    -- 判断上限提示
    -- GameManager.UserData.jewelGain + tonumber(getRedpacket) > GameManager.UserData.jewelLimit
    if GameManager.UserData.jewelGain + tonumber(mission.reward_jewel) > GameManager.UserData.jewelLimit then
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

    if self.datas.process >= mission.goal then
        self:completeMission(mission.id, mission.mission_type, function()
            self.datas.mission[index].status = 0
            self:initUIDatas()
            GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),"3",(T("红包券x")..mission.reward_jewel),"")
        end)
    else
        GameManager.TopTipManager:showTopTip(T("还未达到条件"))
    end
end


--[[
    网络相关
]]

function PanelTotalRedpacket:updateRedpacketMission()
    --[[
        mission_type:2
        title:"100万"
        id:37
        status:1
        goal:5000000000
        reward_jewel:50 
    ]]
    for index, mission in ipairs(self.datas.mission) do
        if self.datas.process < mission.goal then
            self.datas.currentGoal = mission.goal
            break
        end
        if index == PanelTotalRedpacket.ITEM_COUNT and not self.datas.currentGoal then
            self.datas.currentGoal = mission.goal
        end
    end
end


function PanelTotalRedpacket:getSlotNiuNiuwinChallenge()
    http.slotNiuNiuwinChallenge(
        function(retData)
            if retData.flag then
                dump(retData)
                self.datas = retData.data
                self:updateRedpacketMission()
                self:initUIDatas()
            end
        end,
        function(callData)
            GameManager.TopTipManager.showTopTip(T("获取数据失败！"))
        end)
end

function PanelTotalRedpacket:completeMission(id, mission_type, callback)
    http.completeMission(
        id, 
        mission_type,
        function(retData)
            if retData and retData.flag == 1 then
                GameManager.UserData.money = tonumber(retData.latest_money)
                GameManager.GameFunctions.setJewel(tonumber(retData.latest_jewel))
                if callback then
                    callback()
                end
            else
                GameManager.TopTipManager:showTopTip(T("领取失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager.showTopTip(T("获取数据失败！"))
        end)
end


return PanelTotalRedpacket