local SlotsHelperPanel = class("SlotsHelperPanel")

SlotsHelperPanel.ItemTypeIamge = {
    [1] = "Images/PanelSlots/HelperItem3_1",
    [2] = "Images/PanelSlots/HelperItem3_2",
    [3] = "Images/PanelSlots/HelperItem3_3",
}


SlotsHelperPanel.INDEX_CONFIG = {
    DEFAULT = 1,
    JACKPOT = 4,
}

function SlotsHelperPanel:ctor(params)
    self.data = params
    resMgr:LoadPrefabByRes("Special", { "PanelSlotsHelper" }, function(objs)
        self:initView(objs)
    end)
end

function SlotsHelperPanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "SlotsHelperPanel"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function SlotsHelperPanel:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function SlotsHelperPanel:initProperties()
    self.viewItems = {}
    self.btnItems = {}

    self.curItemType = 1
end

function SlotsHelperPanel:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,4 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem, buttonSoundHandler(self,function()
            self:onBtnItemClick(i)
        end))
        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end

    self.btnLeft = self.view.transform:Find("Item3/btnLeft").gameObject
    UIHelper.AddButtonClick(self.btnLeft,buttonSoundHandler(self,self.onBtnLeftClick))
    self.btnRight = self.view.transform:Find("Item3/btnRight").gameObject
    UIHelper.AddButtonClick(self.btnRight,buttonSoundHandler(self,self.onBtnRightClick))

    self.PlayIcon = self.view.transform:Find("Item4/Icon").gameObject
    self.PlayName = self.view.transform:Find("Item4/Name").gameObject

    self.win = self.view.transform:Find("Item4/Win").gameObject
    self.totle = self.view.transform:Find("Item4/Totle").gameObject
end

function SlotsHelperPanel:initUIDatas()
    self:refushWinnerInfo(self.data)
    self:onBtnItemClick(self.data.index or 1)
end

-- 用于外界调用即时刷新
function SlotsHelperPanel:refushWinnerInfo(data)
    
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
    self.totle:GetComponent('Text').text = string.formatNumberThousands(data.totle)
end

function SlotsHelperPanel:onBtnItemClick(index)
    
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

function SlotsHelperPanel:onBtnLeftClick()
    
    local image = self.view.transform:Find("Item3").gameObject:GetComponent('Image')
    self.curItemType = self.curItemType - 1
    if self.curItemType < 1 then
        self.curItemType = 3
    end

    local sp = UIHelper.LoadSprite(SlotsHelperPanel.ItemTypeIamge[self.curItemType])
    image.sprite = sp
end

function SlotsHelperPanel:onBtnRightClick()
    
    local image = self.view.transform:Find("Item3").gameObject:GetComponent('Image')
    self.curItemType = self.curItemType + 1
    if self.curItemType > 3 then
        self.curItemType = 1
    end

    local sp = UIHelper.LoadSprite(SlotsHelperPanel.ItemTypeIamge[self.curItemType])
    image.sprite = sp
end

function SlotsHelperPanel:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return SlotsHelperPanel