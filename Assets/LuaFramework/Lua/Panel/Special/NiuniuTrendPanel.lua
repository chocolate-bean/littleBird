local NiuniuTrendPanel = class("NiuniuTrendPanel")

function NiuniuTrendPanel:ctor(data,callback)
    self.data = data
    self.callback = callback
    resMgr:LoadPrefabByRes("Special", { "PanelTrend"}, function(objs)
        self:initView(objs)
    end)
end

function NiuniuTrendPanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NiuniuTrendPanel"
    
    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
    
    self:show()
end

function NiuniuTrendPanel:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function NiuniuTrendPanel:initProperties()
    self.trendItems = {}
end

function NiuniuTrendPanel:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i = 1, 9 do
        local items = {}
        for k = 1, 4 do
            local item = self.view.transform:Find("PanelItem"..i.."/item"..k).gameObject
            items[k] = item
        end
        self.trendItems[i] = items
    end
end

function NiuniuTrendPanel:initUIDatas()
    self:refashTrend(self.data)
end

function NiuniuTrendPanel:refashTrend(data)
    local iconWin = UIHelper.LoadSprite("Images/common/trendWin")
    local iconLos = UIHelper.LoadSprite("Images/common/trendLose")

    for i = 1, 9 do
        for k = 1, 4 do
            if data[i][k] == 1 then
                self.trendItems[i][k]:GetComponent('Image').sprite = iconWin
            else
                self.trendItems[i][k]:GetComponent('Image').sprite = iconLos
            end
        end
    end
end

function NiuniuTrendPanel:onClose()
    self.callback()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return NiuniuTrendPanel