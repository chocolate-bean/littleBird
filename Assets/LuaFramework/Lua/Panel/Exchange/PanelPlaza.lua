local PanelPlaza = class("PanelPlaza")

function PanelPlaza:ctor(index)
    self.index = index or 1
    
    resMgr:LoadPrefabByRes("Exchange", { "PanelPlaza", "PlazaItem", "PlazaHistoryItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelPlaza:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPlaza"

    self.PlazaItem = objs[1]
    self.PlazaHistoryItem = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelPlaza:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelPlaza:initProperties()
    self.viewItems = {}
    self.btnItems = {}

    self.allData = {}
    self.friendData = {}
    self.historyData = {}
end

function PanelPlaza:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,3 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end

    -- 红包广场列表
    self.allGrid = self.view.transform:Find("Item1/AllList/Grid").gameObject
    -- 好友红包列表
    self.friendGrid = self.view.transform:Find("Item2/FriendList/Grid").gameObject
    -- 领取记录
    self.historyGrid = self.view.transform:Find("Item3/HistoryList/Grid").gameObject

    -- 发红包
    self.btnSend = self.view.transform:Find("btnSend").gameObject
    UIHelper.AddButtonClick(self.btnSend,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelHongbao = import("Panel.Exchange.PanelHongbao").new(self.config, nil, 2,function()
            
            self:reFashPlazaList()
        end)
    end)

    -- 金币数
    self.PlayMoney = self.view.transform:Find("PlayMoney").gameObject
    
end

function PanelPlaza:initUIDatas()
    http.plazaPublishLimit(
        function(callData)
            if callData then
                self.config = callData
                self:reFashPlazaList()
            end
        end,
        function(callData)
        end
    )

    self:onBtnItemClick(self.index)

    self:refashPlayerMoney()
    self.MoneyHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "money", handler(self, self.refashPlayerMoney))
end

function PanelPlaza:refashPlayerMoney()
    
    self.PlayMoney:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
end

-- 刷新列表
function PanelPlaza:reFashPlazaList()
    self.allData = {}
    self.friendData = {}
    self.historyData = {}

    self:GetPlazaList()
end

-- 获取红包广场数据
function PanelPlaza:GetPlazaList()
    
    http.plazaList(
        function(callData)
            if callData then
                self.allData = callData.list
                self:createAllList()
            end
        end,
        function(callData)
        end
    )

    http.getFriendPlazaList(
        function(callData)
            if callData then
                self.friendData = callData.list
                self:createFriendList()
            end
        end,
        function(callData)
        end
    )

    http.getUserPlazaLog(
        function(callData)
            if callData then
                self.historyData = callData.list
                self:createHistoryList()
            end
        end,
        function(callData)
        end
    )
end

function PanelPlaza:createAllList()
    
    if type(self.allData) ~= "table" then
        return
    end
    removeAllChild(self.allGrid.transform)
    for i,data in ipairs(self.allData) do
        local item = newObject(self.PlazaItem)
        item.name = i
        item.transform:SetParent(self.allGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local Title = item.transform:Find("Title").gameObject
        Title:GetComponent("Text").text = data.title
        local PlayName = item.transform:Find("PlayName").gameObject
        PlayName:GetComponent("Text").text = data.name

        UIHelper.AddButtonClick(item,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelHongbao = import("Panel.Exchange.PanelHongbao").new(self.config, data, 1,function()
                
                self:reFashPlazaList()
            end)
        end)
    end
end

function PanelPlaza:createFriendList()
    
    if type(self.friendData)~="table" then
        return
    end
    removeAllChild(self.friendGrid.transform)
    for i,data in ipairs(self.friendData) do
        local item = newObject(self.PlazaItem)
        item.name = i
        item.transform:SetParent(self.friendGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local Title = item.transform:Find("Title").gameObject
        Title:GetComponent("Text").text = data.title
        local PlayName = item.transform:Find("PlayName").gameObject
        PlayName:GetComponent("Text").text = data.name

        UIHelper.AddButtonClick(item,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelHongbao = import("Panel.Exchange.PanelHongbao").new(self.config, data, 1,function()
                
                self:reFashPlazaList()
            end)
        end)
    end
end

function PanelPlaza:createHistoryList()
    
    if type(self.historyData)~="table" then
        return
    end
    removeAllChild(self.historyGrid.transform)
    for i,data in ipairs(self.historyData) do
        local item = newObject(self.PlazaHistoryItem)
        item.name = i
        item.transform:SetParent(self.historyGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local from = item.transform:Find("from").gameObject
        from:GetComponent("Text").text = data.name
        
        local receive = item.transform:Find("receive").gameObject
        if tonumber(data.status) == 1 then
            receive:GetComponent("Text").text = T("<color=#904B39>未领取</color>")
        else
            receive:GetComponent("Text").text = data.receive_name
        end

        local money = item.transform:Find("money").gameObject
        money:GetComponent("Text").text = data.amount
        local time = item.transform:Find("time").gameObject
        time:GetComponent("Text").text = os.date("%Y/%m/%d\n%H:%M", data.ctime or 0)
    end
end

function PanelPlaza:onBtnItemClick(index)
    
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

function PanelPlaza:onClose()
    -- 这里最好写一个控制器控制
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "money", self.MoneyHandleId)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelPlaza