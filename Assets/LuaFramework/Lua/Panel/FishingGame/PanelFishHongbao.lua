local BasePanel = require("Panel.BasePanel").new()
local PanelFishHongbao = class("PanelFishHongbao", BasePanel)

PanelFishHongbao.MissonReward = {
    [1] = {title = T("1级红包"), des = string.format(T("可获奖励:%s/%s/%s"),GameManager.GameFunctions.getJewelWithUnit(10), GameManager.GameFunctions.getJewelWithUnit(20),GameManager.GameFunctions.getJewelWithUnit(30))},
    [2] = {title = T("2级红包"), des = string.format(T("可获奖励:%s/%s/%s"),GameManager.GameFunctions.getJewelWithUnit(200), GameManager.GameFunctions.getJewelWithUnit(400),GameManager.GameFunctions.getJewelWithUnit(600))},
    [3] = {title = T("3级红包"), des = string.format(T("可获奖励:%s/%s/%s"),GameManager.GameFunctions.getJewelWithUnit(800), GameManager.GameFunctions.getJewelWithUnit(1200),GameManager.GameFunctions.getJewelWithUnit(1600))},
}

function PanelFishHongbao:ctor(missionID,callbcak)
    self.missionID = missionID
    self.callback = callbcak

    self.type = "FishingGame/UI"
    self.prefabs = { "PanelFishingHongbao" }
    self:init()
end

function PanelFishHongbao:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishHongbao"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFishHongbao:initProperties()
    
end

function PanelFishHongbao:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.text1 = self.view.transform:Find("panel1/text1").gameObject
    self.text2 = self.view.transform:Find("panel1/text2").gameObject
    self.text3 = self.view.transform:Find("panel2/text3").gameObject
    self.text4 = self.view.transform:Find("panel2/text4").gameObject

    self.panel1 = self.view.transform:Find("panel1").gameObject
    self.panel2 = self.view.transform:Find("panel2").gameObject

    self.btnGoto = self.view.transform:Find("panel1/btnGoto").gameObject
    self.btnGoto:addButtonClick(function()
        self:getMissonReward()
    end)
end

function PanelFishHongbao:initUIDatas()
    self.panel1:SetActive(true)
    self.text1:setText(PanelFishHongbao.MissonReward[tonumber(self.missionID)].title)
    self.text2:setText(PanelFishHongbao.MissonReward[tonumber(self.missionID)].des)
    self.text3:setText(PanelFishHongbao.MissonReward[tonumber(self.missionID)].title)
end

function PanelFishHongbao:getMissonReward()
    http.getFishingRedpackReward(
        self.missionID,
        function(retData)
            if retData.flag == 1 then
                self:onGetReward(retData)
            else
                GameManager.TopTipManager:showTopTip(T("领取红包失败"))
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("领取红包失败"))
        end
    )
end

function PanelFishHongbao:onGetReward(retData)
    self.panel2:SetActive(true)
    TMPHelper.setText(self.text4, GameManager.GameFunctions.getJewelWithUnit(retData.jewel))
    if self.callback then
        self.callback(retData)
    end
end

return PanelFishHongbao