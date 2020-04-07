local BasePanel = require("Panel.BasePanel").new()
local PanelBagReward = class("PanelBagReward", BasePanel)

function PanelBagReward:ctor(data)
    self.data = data
    self.type = "Bag"
    self.prefabs = { "PanelBagReward"}
    self:init()
end

function PanelBagReward:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelBagReward"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelBagReward:initProperties()
    self.curPropNum = 0
end

function PanelBagReward:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,self.onBtnNoClick))

    -- 确认按钮
    self.btnYes = self.view.transform:Find("btnYes").gameObject
    self.btnYes:addButtonClick(buttonSoundHandler(self,self.onBtnYesClick))

    -- 取消按钮
    self.btnNo = self.view.transform:Find("btnNo").gameObject
    self.btnNo:addButtonClick(buttonSoundHandler(self,self.onBtnNoClick))

    self.SendNum = self.view.transform:Find("SendNum").gameObject
    self.total = self.view.transform:Find("total").gameObject
    self.des = self.view.transform:Find("des").gameObject

    self.btnSub = self.view.transform:Find("btnSub").gameObject
    self.btnSub:addButtonClick(function()
        self:changePropNum(false)
    end)
    self.btnAdd = self.view.transform:Find("btnAdd").gameObject
    self.btnAdd:addButtonClick(function()
        self:changePropNum(true)
    end)
end

function PanelBagReward:initUIDatas()
    self.SendNum:setText(self.curPropNum)
    self.total:setText("当前剩余："..self.data.num.."个")
    self.des:setText(self.data.des.."，清选择数量")
end

function PanelBagReward:changePropNum(isAdd)
    if isAdd then
        self.curPropNum = self.curPropNum + 1
        if self.curPropNum > tonumber(self.data.num) then
            self.curPropNum = self.data.num
        end
    else
        self.curPropNum = self.curPropNum - 1
        if self.curPropNum < 0 then
            self.curPropNum = 0
        end
    end

    self.SendNum:setText(self.curPropNum)
end

function PanelBagReward:onBtnYesClick()
    self:onClose()
    self:UseProp()
end

function PanelBagReward:onBtnNoClick()
    self:onClose()
    local PanelBag = import("Panel.Bag.PanelBag").new()
end

function PanelBagReward:UseProp()
    if self.curPropNum == 0 then
        GameManager.TopTipManager:showTopTip(T("请选择数量"))
        return
    end

    http.splitProp(
        self.data.pid,
        self.curPropNum,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                GameManager.UserData.money = callData.latest_money
            elseif callData.flag == -7 then
                GameManager.TopTipManager:showTopTip(T("VIP等级不足"))
            end
        end,
        function(callData)
        end
    )
end

return PanelBagReward