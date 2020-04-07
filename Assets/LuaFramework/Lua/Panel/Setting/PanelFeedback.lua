local PanelFeedback = class("PanelFeedback")

function PanelFeedback:ctor()
    
    resMgr:LoadPrefabByRes("Setting", { "PanelFeedback" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFeedback:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFeedback"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFeedback:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelFeedback:initProperties()
    self.toggles = {}
end

function PanelFeedback:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.OnCloseClick))

    self.toggle1 = self.view.transform:Find("PanelToggle/1").gameObject:GetComponent("Toggle")
    self.toggle2 = self.view.transform:Find("PanelToggle/2").gameObject:GetComponent("Toggle")
    self.toggle3 = self.view.transform:Find("PanelToggle/3").gameObject:GetComponent("Toggle")

    self.Text = self.view.transform:Find("InputField").gameObject:GetComponent('InputField')

    self.toggles = {self.toggle1,self.toggle2,self.toggle3}

    self.btnYes = self.view.transform:Find("btnYes").gameObject
    UIHelper.AddButtonClick(self.btnYes,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self:onBtnSendClick()
    end)
end

function PanelFeedback:initUIDatas()

end

function PanelFeedback:onBtnSendClick()
    
    local curSelect 

    for i,v in pairs(self.toggles) do
        if v.isOn then
            curSelect = i
        end
    end

    if self.Text.text == "" or self.Text.text == nil then
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = false,
            hasCloseButton = false,
            text = T("请输入反馈内容"),
        })
    else
        local param = {
            mid = GameManager.UserData.mid,
            uuid = GetUUID(),
            feed_type = curSelect,
            content = self.Text.text or "",
            version = BM_UPDATE.CURVERSION or "1.0.0",
            network = tonumber(UnityEngine.Application.internetReachability),
            operator = UnityEngine.SystemInfo.deviceModel
        }

        http.sendFeedback(
            param,
            function(callData)
                if callData then
                    GameManager.TopTipManager:showTopTip(T("反馈成功"))
                    self:onClose()
                end
            end,
            function(callData)
            end
        )
    end
end

function PanelFeedback:OnCloseClick()
    
    -- 没有输入直接关闭界面
    if self.Text.text == "" or self.Text.text == nil then
        self:onClose()
    else
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            text = T("确认退出?"),
            firstButtonCallbcak = handler(self,self.onClose),
        })
    end
end

function PanelFeedback:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFeedback