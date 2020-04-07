local PanelHongbao = class("PanelHongbao")

function PanelHongbao:ctor(config, data, index, callback)
    self.config = config
    self.data = data
    self.index = index
    self.callback = callback
    
    resMgr:LoadPrefabByRes("Exchange", { "PanelHongbao" }, function(objs)
        self:initView(objs)
    end)
end

function PanelHongbao:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelHongbao"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelHongbao:show()
    
    -- GameManager.PanelManager:addPanel(self,false,0)
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
end

function PanelHongbao:initProperties()
    self.isChange = false
    self.panels = {}
end

function PanelHongbao:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i = 1,4 do
        local panel = self.view.transform:Find("panel"..i).gameObject
        self.panels[i] = panel
    end

    -- panel1 拆红包
    self.PlayIcon = self.view.transform:Find("panel1/PlayIcon").gameObject:GetComponent('Image')
    self.PlayIconBtn = self.view.transform:Find("panel1/PlayIcon").gameObject
    self.PlayName = self.view.transform:Find("panel1/PlayName").gameObject:GetComponent("Text")
    self.Title = self.view.transform:Find("panel1/Title").gameObject:GetComponent("Text")
    self.ConfigText = self.view.transform:Find("panel1/ConfigText").gameObject:GetComponent("Text")
    self.btnGoto = self.view.transform:Find("panel1/btnGoto").gameObject
    UIHelper.AddButtonClick(self.btnGoto,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self:goPanel2()
    end)

    -- panel2 拆红包具体
    self.input = self.view.transform:Find("panel2/input").gameObject:GetComponent('InputField')
    self.ConfigText1 = self.view.transform:Find("panel2/ConfigText1").gameObject:GetComponent("Text")
    self.btnGet = self.view.transform:Find("panel2/btnGoto").gameObject
    UIHelper.AddButtonClick(self.btnGet,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self:getHongbao()
    end)

    -- panel3 发红包
    self.condition1 = self.view.transform:Find("panel3/condition1").gameObject:GetComponent("Text")
    self.condition2 = self.view.transform:Find("panel3/condition2").gameObject:GetComponent("Text")
    self.condition3 = self.view.transform:Find("panel3/condition3").gameObject:GetComponent("Text")
    self.condition4 = self.view.transform:Find("panel3/condition4").gameObject:GetComponent("Text")
    self.btnSend = self.view.transform:Find("panel3/btnSend").gameObject
    UIHelper.AddButtonClick(self.btnSend,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        if GameManager.UserData.money < (tonumber(self.config.min_amount) + tonumber(self.config.money_line)) then
            GameManager.TopTipManager:showTopTip(T("金额不足"))
            return
        end
        if tonumber(GameManager.UserData.viplevel) < tonumber(self.config.vip_level) then
            GameManager.TopTipManager:showTopTip(T("VIP等级不足"))
            return
        end
        self:goPanel4()
    end)

    -- panel4 发红包具体
    self.condition5 = self.view.transform:Find("panel4/condition5").gameObject:GetComponent("Text")
    self.Toggle = self.view.transform:Find("panel4/Toggle").gameObject:GetComponent("Toggle")
    self.input1 = self.view.transform:Find("panel4/input1").gameObject:GetComponent('InputField')
    self.input2 = self.view.transform:Find("panel4/input2").gameObject:GetComponent('InputField')
    self.btnReady = self.view.transform:Find("panel4/btnGoto").gameObject
    UIHelper.AddButtonClick(self.btnReady,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self:sendHongbao()
    end)
end

function PanelHongbao:initUIDatas()
    self.ConfigText.text = T("金额介于")..(self.config.min_amount/10000)..T("万-")..(self.config.max_amount/10000)..T("万\n每次竞猜消耗")..self.config.receive_free..T("金币")
    self.ConfigText1.text = T("金额介于")..(self.config.min_amount/10000)..T("万-")..(self.config.max_amount/10000)..T("万\n每次竞猜消耗0金币")

    self.condition1.text = "VIP"..self.config.vip_level..T("级以上")
    self.condition2.text = (self.config.min_amount/10000)..T("万-")..(self.config.max_amount/10000)..T("万")
    self.condition3.text = T("注：身上保留金额不得低于")..(self.config.money_line/10000)..T("万")
    self.condition4.text = T("消耗")..self.config.free..T("%的红包材料费")

    -- 1是拆红包
    if self.index == 1 then
        self:goPanel1()
    -- 2是发红包
    elseif self.index == 2 then
        self:goPanel3()
    end
end

function PanelHongbao:goPanel1()
    
    self:setPanelActive(1)
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = self.data.micon,
        sex = tonumber(self.data.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon.sprite = sprite
            end
        end,
    })
    
    self.PlayIconBtn:addButtonClick(buttonSoundHandler(self, function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelOtherInfoSmall = import("Panel.PlayInfo.PanelOtherInfoSmall").new(self.data.mid)
    end), false)

    self.PlayName.text = self.data.name
    self.Title.text = self.data.title
end

function PanelHongbao:goPanel2()
    
    self:setPanelActive(2)
end

function PanelHongbao:goPanel3()
    
    self:setPanelActive(3)
end

function PanelHongbao:goPanel4()
    
    self:setPanelActive(4)
    self.condition5.text = T("可用金额")..formatFiveNumber(GameManager.UserData.money - tonumber(self.config.money_line)) 
end

function PanelHongbao:getHongbao()
    
    if self.input.text == nil or self.input.text == "" then
        GameManager.TopTipManager:showTopTip(T("请输入金额"))
        return
    end

    local id = self.data.id
    local amount = self.input.text

    http.receiveBag(
        id,
        amount,
        function(callData)
            
            if callData and callData.flag == 1 then
                GameManager.UserData.money = callData.latest_money
                GameManager.TopTipManager:showTopTip(T("领取成功"))
                self.isChange = true
                self:onClose()
            elseif callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("猜错了，再试试看"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("猜错了，再试试看"))
        end
    )
end

function PanelHongbao:sendHongbao()
    
    if self.input1.text == nil or self.input1.text == "" then
        GameManager.TopTipManager:showTopTip(T("请输入金额"))
        return
    end

    local amount = self.input1.text
    local title = self.input2.text or ""
    local friend = self.Toggle.isOn == true and 1 or 0

    http.publishBag(
        title,
        amount,
        friend,
        function(callData)
            
            if callData and callData.flag == 1 then
                GameManager.UserData.money = callData.latest_money
                GameManager.TopTipManager:showTopTip(T("发送成功"))
                self.isChange = true
                self:onClose()
            elseif callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("红包范围是50万~5000万"))
            elseif callData.flag == -6 then
                GameManager.TopTipManager:showTopTip(T("身上保留不得低于30万"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("网络问题，请重试"))
        end
    )
end

function PanelHongbao:setPanelActive(index)
    
    for i = 1,4 do
        self.panels[i]:SetActive(false)
    end
    self.panels[index]:SetActive(true)
end

function PanelHongbao:onClose()
    if self.isChange and self.callback then
        self.callback()
    end
    -- 这里最好写一个控制器控制
    destroy(self.view)
    self.view = nil
end

return PanelHongbao