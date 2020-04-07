local PanelShareDialog = class("PanelShareDialog")

function PanelShareDialog:ctor()
    resMgr:LoadPrefabByRes("LuckyWheel", { "PanelShareDialog" }, function(objs)
        self:initView(objs)
    end)
end

function PanelShareDialog:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelShareDialog"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelShareDialog:initProperties()
    
end

function PanelShareDialog:initUIControls()
    self.closeButton    = self.view.transform:Find("closeButton").gameObject
    self.wechatButton   = self.view.transform:Find("wechatButton").gameObject
    self.timelineButton = self.view.transform:Find("timelineButton").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.wechatButton:addButtonClick(buttonSoundHandler(self,function()
        local config = GameManager.GameConfig.SHARE_CONFIG
        sdkMgr:WechatShareWebpage("0",config.URL,config.TITLE,config.CONTENT)
    end), false)

    self.timelineButton:addButtonClick(buttonSoundHandler(self,function()
        local config = GameManager.GameConfig.SHARE_CONFIG
        sdkMgr:WechatShareWebpage("1",config.URL,config.TITLE,config.CONTENT)
    end), false)
end

function PanelShareDialog:initUIDatas(ruleText)
    
end

function PanelShareDialog:show()
    GameManager.PanelManager:addPanel(self, true, 3)
end

function PanelShareDialog:onClose()
    GameManager.PanelManager:removePanel(self, nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelShareDialog