local PanelLuckyWheelRuleDialog = class("PanelLuckyWheelRuleDialog")

function PanelLuckyWheelRuleDialog:ctor(ruleText)
    resMgr:LoadPrefabByRes("LuckyWheel", { "PanelLuckyWheelRuleDialog" }, function(objs)
        self:initView(objs, ruleText)
    end)
end

function PanelLuckyWheelRuleDialog:initView(objs, ruleText)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLuckyWheelRuleDialog"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas(ruleText)

    self:show()
end

function PanelLuckyWheelRuleDialog:initProperties()
    
end

function PanelLuckyWheelRuleDialog:initUIControls()
    self.closeButton   = self.view.transform:Find("closeButton").gameObject
    self.ruleText      = self.view.transform:Find("scrollView/Viewport/Content/Text").gameObject
    self.confirmButton = self.view.transform:Find("confirmButton").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.confirmButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)
end

function PanelLuckyWheelRuleDialog:initUIDatas(ruleText)
    if ruleText then
        self.ruleText:setText(ruleText)
    end
end

function PanelLuckyWheelRuleDialog:show()
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
end

function PanelLuckyWheelRuleDialog:onClose()
    destroy(self.view)
    self.view = nil
end

return PanelLuckyWheelRuleDialog