local BasePanel = require("Panel.BasePanel").new()
local PanelActivity = class("PanelActivity", BasePanel)

function PanelActivity:ctor(index)
    self.index = index
    self.type = "Activity"
    self.prefabs = { "PanelActivity", "ActivityTypeItem", "ActivityItem" }
    self:init()
end

function PanelActivity:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelActivity"

    self.activityType = objs[1]
    self.activityItem = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelActivity:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelActivity:initProperties()
    self.curActivity = 1
    self.ActivityData = {}
    self.redDots = {}

    self.ActivityTypes = {}
    self.ActivityViews = {}
end

function PanelActivity:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.Grid = self.view.transform:Find("ActivityType/Grid")
end

function PanelActivity:initUIDatas()
    self:getActivityList()
end

function PanelActivity:getActivityList()
    http.activityWindow(
        function(callData)
            if callData then
                if self.view then
                    self.ActivityData = {}
                    for i,data in ipairs(callData.list) do
                        if data.type == "activity" then
                            table.insert( self.ActivityData, data )
                        end
                    end
                    self:createActivityList()
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
        end
    )
end

function PanelActivity:createActivityList()
    
    for i,data in ipairs(self.ActivityData) do
        local item = newObject(self.activityType)
        item.name = i
        item.transform:SetParent(self.Grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        UIHelper.AddButtonClick(item, function(sender)
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnActivityClick(i)
        end)

        local text = item.transform:Find("btnNormal/Text").gameObject
        text:GetComponent('Text').text = data.title
        local textLight = item.transform:Find("btnLight/Text").gameObject
        textLight:GetComponent('Text').text = data.title

        self:initActivityView(i,data)

        local redDot = item.transform:Find("redDot").gameObject
        if GameManager.UserData.redDotData then
            if GameManager.UserData.redDotData.activity.index[i] then
                redDot:SetActive(true)
            end
        end

        table.insert(self.ActivityTypes,item)
        table.insert(self.redDots,redDot)
    end

    if self.index and self.index <= #self.ActivityData then
        self:onBtnActivityClick(self.index)
    else
        self:onBtnActivityClick(1)
    end
    
end

-- 初始化活动面板
function PanelActivity:initActivityView(index, data)
    local item = newObject(self.activityItem)
    item.name = "activity"..index
    item.transform:SetParent(self.view.transform)
    item.transform.localScale = Vector3.one
    item.transform.localPosition = Vector3.New(120,-20,0)
    item:SetActive(false)

    local btn = item.transform:Find("btnActivity").gameObject
    UIHelper.AddButtonClick(btn,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        if data.data then
            self:onActivityClick(data.data)
        end
    end)

    local imgurl = data.data.picture_url or data.data.content
    print(imgurl)

    GameManager.ImageLoader:loadAndCacheImage(imgurl,function (success, sprite)
        
        if success and sprite then
            if self.view then
                btn:GetComponent('Image').sprite = sprite
            end
        end
    end)

    table.insert(self.ActivityViews,item)
end

function PanelActivity:onBtnActivityClick(index)
    for k,btn in pairs(self.ActivityTypes) do
        local btnLight = btn.transform:Find("btnLight").gameObject
        btnLight:SetActive(false)
    end

    for k,view in pairs(self.ActivityViews) do
        view:SetActive(false)
    end

    local curBtnLight = self.ActivityTypes[index].transform:Find("btnLight").gameObject
    curBtnLight:SetActive(true)

    self.ActivityViews[index]:SetActive(true)

    self.curActivity = index
    self:removeRedDot(index)
end

function PanelActivity:removeRedDot(index)
    
    if GameManager.UserData.redDotData then
        if GameManager.UserData.redDotData.activity.index[index] then
            self.redDots[index]:SetActive(false)
            GameManager.UserData.redDotData.activity.index[index] = nil
            GameManager.GameFunctions.removeRedDot("activity", index)
        end

        if GameManager.UserData.redDotData.activity.index == nil or next(GameManager.UserData.redDotData.activity.index) == nil then
            GameManager.UserData.redDotData.activity.dot = 0
            if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
                GameManager.runningScene.view_:redDotManager()
            end
        end
    end
end

function PanelActivity:onActivityClick(data)
    if data.click_url and data.click_url ~= "" then
        local webview = WebView.new()
        webview:OpenUrl(data.click_url)
        http.receiveActivity(
            data.id,
            function(callData)
            end,
            function(callData)
            end
        )
    elseif data.in_game and data.in_game ~= "" then
        self:onBtnGotoClick(data.in_game)
    end

    self:onClose()
end

function PanelActivity:onBtnGotoClick(data)
    GameManager.ActivityJumpConfig:Jump(data)
end

function PanelActivity:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelActivity