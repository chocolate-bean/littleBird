local PanelRedpacketRule = class("PanelRedpacketRule")

function PanelRedpacketRule:ctor()
    resMgr:LoadPrefabByRes("FishingGame/UI", { "PanelFishingGameRedpacketRule" }, function(objs)
        self:initView(objs)
    end)
end

function PanelRedpacketRule:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelRedpacketRule"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelRedpacketRule:initProperties()
    
end

function PanelRedpacketRule:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)
end

function PanelRedpacketRule:initUIDatas(ruleText)
    
end

function PanelRedpacketRule:show()
    GameManager.PanelManager:addPanel(self, true, 3)
end

function PanelRedpacketRule:onClose()
    GameManager.PanelManager:removePanel(self, nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelRedpacketRule