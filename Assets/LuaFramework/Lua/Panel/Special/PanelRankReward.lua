local PanelRankReward = class("PanelRankReward")

function PanelRankReward:ctor(data,index)
    self.data = data
    if index then
        self.index = index
    end
    resMgr:LoadPrefabByRes("Special", { "PanelRankReward" }, function(objs)
        self:initView(objs)
    end)
end

function PanelRankReward:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelRankReward"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelRankReward:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelRankReward:initProperties()
    self.viewItems = {}
    self.btnItems = {}
end

function PanelRankReward:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,2 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end

end

function PanelRankReward:initUIDatas()
    self:onBtnItemClick(self.index or 1)
end

function PanelRankReward:onBtnItemClick(index)
    
    for k,btn in pairs(self.btnItems) do
        local btnLight = btn.transform:Find("btnLight").gameObject
        btnLight:SetActive(false)
    end

    for k,view in pairs(self.viewItems) do
        view:SetActive(false)
    end

    local curBtnLight = self.btnItems[index].transform:Find("btnLight").gameObject
    curBtnLight:SetActive(true)
    self.viewItems[index]:SetActive(true)
end

function PanelRankReward:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelRankReward