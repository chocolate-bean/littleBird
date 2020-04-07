local BasePanel = class("BasePanel")

function BasePanel:ctor()
end

function BasePanel:init()
    resMgr:LoadPrefabByRes(self.type, self.prefabs, function(objs)
        self:initView(objs)
    end)
end

function BasePanel:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = self.__cname

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function BasePanel:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function BasePanel:initProperties()
end

function BasePanel:initUIControls()
end

function BasePanel:initUIDatas()
end

function BasePanel:Translate()
    for i, name in pairs(self.translateobjs) do
        local obj = self.view.transform:Find(name).gameObject
        local curText = obj:GetComponent("Text").text
        obj:setText(T(curText))
    end
end

function BasePanel:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return BasePanel