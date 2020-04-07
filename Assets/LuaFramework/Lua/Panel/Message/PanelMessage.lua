local PanelMessage = class("PanelMessage")

function PanelMessage:ctor()
    
    resMgr:LoadPrefabByRes("Message", { "PanelMessage", "MessageItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelMessage:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelMessage"

    self.systemItem = objs[1]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelMessage:show()
    
    GameManager.UserData.redDotData.message.dot = 0
    if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
        GameManager.runningScene.view_:redDotManager()
    end
    GameManager.GameFunctions.removeRedDot("message", nil)
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelMessage:initProperties()
end

function PanelMessage:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.Grid = self.view.transform:Find("MessageList/Grid").gameObject
end

function PanelMessage:initUIDatas()
    self:reFashSystemList()
end

function PanelMessage:reFashSystemList()
    
    self.SystemData = {}
    self:GetSystemList()
end

-- 获取邮件
function PanelMessage:GetSystemList()
    http.getMessageList(
        1,
        function(callData)
            if callData then
                if self.view then
                    self.SystemData = callData.list
                    self:DestroySystemList()
                    self:createSystemList()
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end
    )
end

function PanelMessage:DestroySystemList()
    
    removeAllChild(self.Grid.transform)
end

-- 创建系统列表
function PanelMessage:createSystemList()
    
    for i,data in ipairs(self.SystemData) do
        local item = newObject(self.systemItem)
        item.name = i
        item.transform:SetParent(self.Grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local Title = item.transform:Find("Title").gameObject
        Title:GetComponent('Text').text = data.title

        local Time = item.transform:Find("Time").gameObject
        Time:GetComponent('Text').text = os.date("%Y-%m-%d %H:%M", data.create_time or 0)

        local btnGoto = item.transform:Find("btnGoto").gameObject
        local btnReady = item.transform:Find("btnReady").gameObject

        UIHelper.AddButtonClick(btnGoto,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            http.readMessage(
                data.id,
                function()
                end,
                function()
                end
            )
            local PanelReadMessage = import("Panel.Message.PanelReadMessage").new(data)
            btnGoto:SetActive(false)
            btnReady:SetActive(true)
        end)

        UIHelper.AddButtonClick(btnReady,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelReadMessage = import("Panel.Message.PanelReadMessage").new(data)
        end)

        if tonumber(data.is_read) == 1 then
            btnReady:SetActive(true)
        else
            btnGoto:SetActive(true)
        end
    end
end


function PanelMessage:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelMessage