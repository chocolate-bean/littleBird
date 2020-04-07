local NiuniuHelperPanel = class("NiuniuHelperPanel")

NiuniuHelperPanel.INDEX_CONFIG = {
    DEFAULT = 1,
    JACKPOT = 4,
}

function NiuniuHelperPanel:ctor(data,index)
    self.data = data
    if index then
        self.index = index
    end
    resMgr:LoadPrefabByRes("Special", { "PanelNiuniuHelper" }, function(objs)
        self:initView(objs)
    end)
end

function NiuniuHelperPanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NiuniuHelperPanel"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function NiuniuHelperPanel:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function NiuniuHelperPanel:initProperties()
    self.viewItems = {}
    self.btnItems = {}
end

function NiuniuHelperPanel:initUIControls()
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

    self.PlayIcon = self.view.transform:Find("Item2/Icon").gameObject
    self.PlayName = self.view.transform:Find("Item2/Name").gameObject

    self.win = self.view.transform:Find("Item2/Win").gameObject
    self.totle = self.view.transform:Find("Item2/Totle").gameObject
end

function NiuniuHelperPanel:initUIDatas()
    self:refushWinnerInfo(self.data)
    self:onBtnItemClick(self.index or 1)
end

-- 用于外界调用即时刷新
function NiuniuHelperPanel:refushWinnerInfo(data)
    
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = data.micon,
        sex = tonumber(data.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })

    self.PlayName:GetComponent('Text').text = data.name

    self.win:GetComponent('Text').text = formatFiveNumber(data.win) 
    self.totle:GetComponent('Text').text = string.formatNumberThousands(data.totalBonus or 0)
end

function NiuniuHelperPanel:onBtnItemClick(index)
    
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

function NiuniuHelperPanel:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return NiuniuHelperPanel