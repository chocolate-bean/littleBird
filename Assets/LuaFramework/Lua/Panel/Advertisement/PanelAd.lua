local PanelAd = class("PanelAd")

function PanelAd:ctor(data,closeCallback)
    dump(data)
    self.closeCallback = closeCallback
    self.data = data
    resMgr:LoadPrefabByRes("Advertisement", { "PanelAd" }, function(objs)
        self:initView(objs)
    end)
end

function PanelAd:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelAd"

    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelAd:initUIControls()
    
end

function PanelAd:initUIDatas()
    
end

function PanelAd:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelAd:_SetAdLeftCounts(counts)
    -- self.leftCounts = tonumber(counts)
    print("asdasdsa ------------> "..counts)
end

return PanelAd
 