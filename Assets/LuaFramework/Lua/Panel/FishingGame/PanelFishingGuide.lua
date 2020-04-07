local BasePanel = require("Panel.BasePanel").new()
local PanelFishingGuide = class("PanelFishingGuide", BasePanel)

function PanelFishingGuide:ctor(need, callback)
    self.need = need
    self.callback = callback
    self.type = "FishingGame/UI"
    self.prefabs = { "PanelFishingGuide" }
    self:init()
end

function PanelFishingGuide:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishingGuide"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view:scale(Vector3.one)
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
end

function PanelFishingGuide:initProperties()
    
end

function PanelFishingGuide:initUIControls()
    self.closeButton   = self.view:findChild("btnClose")

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.allText   = self.view:findChild("allText")
    self.tips   = self.view:findChild("tips")
end

function PanelFishingGuide:initUIDatas()
    TMPHelper.setText(self.allText, self.need)
    self.tips:setText("首个红包需："..self.need.."炮")
end

function PanelFishingGuide:onClose()
    -- 这里最好写一个控制器控制
    destroy(self.view)
    self.view = nil
    if self.callback then
        self.callback()
    end
end

return PanelFishingGuide