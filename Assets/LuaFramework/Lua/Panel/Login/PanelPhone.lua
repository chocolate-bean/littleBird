local PanelPhone = class("PanelPhone")

function PanelPhone:ctor(index,controller)
    self.index = index
    self.controller = controller
    
    resMgr:LoadPrefabByRes("Login", { "PanelPhone" }, function(objs)
        self:initView(objs)
    end)
end

function PanelPhone:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPhone"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelPhone:show()
    GameManager.PanelManager:addPanel(self,true,1)
    -- local parent = UnityEngine.GameObject.Find("Canvas")
    -- self.view.transform:SetParent(parent.transform)
    -- self.view.transform.localScale = Vector3.one
    -- self.view.transform.localPosition = Vector3.zero
end

function PanelPhone:initProperties()
    self.panels = {}
end

function PanelPhone:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,handler(self,self.onClose))

    for i = 1,5 do
        -- 1 登陆 2 忘记密码 3 密码重置 4 注册
        local panel = self.view.transform:Find("panel"..i).gameObject
        self.panels[i] = panel
    end

    -- panel1
    self.input1 = self.view.transform:Find("panel1/input1").gameObject:GetComponent('InputField')
    self.input2 = self.view.transform:Find("panel1/input2").gameObject:GetComponent('InputField')
    self.btn1 = self.view.transform:Find("panel1/btn1").gameObject
    UIHelper.AddButtonClick(self.btn1,function()
        
        self:goPanel(2)
    end)
    local btnYes1 = self.view.transform:Find("panel1/btnYes").gameObject
    UIHelper.AddButtonClick(btnYes1,function()
        -- 登陆
        btnYes1:GetComponent('Button').interactable = false
        self:onLoginClick(btnYes1)
    end)
    local btnNo1 = self.view.transform:Find("panel1/btnNo").gameObject
    UIHelper.AddButtonClick(btnNo1,function()
        
        self:goPanel(4)
    end)

    -- panel2
    self.input3 = self.view.transform:Find("panel2/input3").gameObject:GetComponent('InputField')
    local btnYes2 = self.view.transform:Find("panel2/btnYes").gameObject
    UIHelper.AddButtonClick(btnYes2,function()
        -- 到Panel3
        if self.input3.text == "" then
            GameManager.TopTipManager:showTopTip(T("请输入手机号"))
            return
        end
        self.curPhone = self.input3.text
        self:goPanel(3)
    end)
    local btnNo2 = self.view.transform:Find("panel2/btnNo").gameObject
    UIHelper.AddButtonClick(btnNo2,function()
        
        self:goPanel(1)
    end)

    -- panel3
    -- 验证码
    self.input4 = self.view.transform:Find("panel3/input4").gameObject:GetComponent('InputField')
    -- 密码
    self.input5 = self.view.transform:Find("panel3/input5").gameObject:GetComponent('InputField')
    self.timer1 = self.view.transform:Find("panel3/timer1").gameObject
    self.btn2 = self.view.transform:Find("panel3/btn2").gameObject
    UIHelper.AddButtonClick(self.btn2,function()
        -- 获取验证码
        self:getResetCode()
    end)
    local btnYes3 = self.view.transform:Find("panel3/btnYes").gameObject
    UIHelper.AddButtonClick(btnYes3,function()
        -- 重置密码并回到panel1
        self:onResetClick()
    end)
    local btnNo3 = self.view.transform:Find("panel3/btnNo").gameObject
    UIHelper.AddButtonClick(btnNo3,function()
        
        self:goPanel(2)
    end)

    -- panel4
    -- 手机号
    self.input6 = self.view.transform:Find("panel4/input6").gameObject:GetComponent('InputField')
    -- 密码
    self.input7 = self.view.transform:Find("panel4/input7").gameObject:GetComponent('InputField')
    -- 验证码
    self.input8 = self.view.transform:Find("panel4/input8").gameObject:GetComponent('InputField')
    -- 倒计时
    self.timer2 = self.view.transform:Find("panel4/timer2").gameObject
    self.btn3 = self.view.transform:Find("panel4/btn3").gameObject
    UIHelper.AddButtonClick(self.btn3,function()
        -- 获取验证码
        self:getRegCode()
    end)
    local btnYes4 = self.view.transform:Find("panel4/btnYes").gameObject
    UIHelper.AddButtonClick(btnYes4,function()
        -- 注册
        btnYes4:GetComponent('Button').interactable = false
        self:onRegClick(btnYes4)
    end)
    local btnNo4 = self.view.transform:Find("panel4/btnNo").gameObject
    UIHelper.AddButtonClick(btnNo4,function()
        
        self:goPanel(1)
    end)

    -- panel5
    -- 绑定手机号
    -- 手机号
    self.input9 = self.view.transform:Find("panel5/input9").gameObject:GetComponent('InputField')
    -- 验证码
    self.input10 = self.view.transform:Find("panel5/input10").gameObject:GetComponent('InputField')
    -- 倒计时
    self.timer3 = self.view.transform:Find("panel5/timer3").gameObject
    self.btn4 = self.view.transform:Find("panel5/btn4").gameObject
    UIHelper.AddButtonClick(self.btn4,function()
        -- 获取绑定验证码
        self:getBindCode()
    end)
    local btnYes5 = self.view.transform:Find("panel5/btnYes").gameObject
    UIHelper.AddButtonClick(btnYes5,function()
        -- 绑定手机号
        btnYes5:GetComponent('Button').interactable = false
        self:onBindClick(btnYes5)
    end)
    local btnNo5 = self.view.transform:Find("panel5/btnNo").gameObject
    UIHelper.AddButtonClick(btnNo5,function()
        
        self:onClose()
        -- local PanelExchange = import("Panel.Exchange.PanelExchange").new()
    end)
end

function PanelPhone:initUIDatas()
    self:goPanel(self.index or 1)
    if self.index and self.index == 5 then
        self.btnClose:SetActive(false)
    end
end

function PanelPhone:goPanel(index)
    
    self:setPanelActive(index)
end

function PanelPhone:getResetCode()
    
    local params = {
        act = "resetSms",
        phone = self.curPhone,
    }

    self:sendHTTP(
        params,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("验证码发送成功"))
                self:onResetTimerStart()
            else
                GameManager.TopTipManager:showTopTip(T("手机号有误"))
            end
        end
    )
end

function PanelPhone:getRegCode()
    
    if self.input6.text == "" then
        GameManager.TopTipManager:showTopTip(T("请输入手机号"))
        return
    end

    local params = {
        act = "regSms",
        phone = self.input6.text,
    }

    self:sendHTTP(
        params,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("验证码发送成功"))
                self:onRegTimerStart()
            else
                GameManager.TopTipManager:showTopTip(T("验证码发送失败"))
            end
        end
    )
end

function PanelPhone:getBindCode()
    
    if self.input9.text == "" then
        GameManager.TopTipManager:showTopTip(T("请输入手机号"))
        return
    end

    local params = {
        act = "regSms",
        phone = self.input9.text,
    }

    self:sendHTTP(
        params,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("验证码发送成功"))
                self:onBindTimerStart()
            else
                GameManager.TopTipManager:showTopTip(T("验证码发送失败"))
            end
        end
    )
end

function PanelPhone:onLoginClick(btn)
    local phone = self.input1.text
    local password = self.input2.text

    if phone == "" then
        GameManager.TopTipManager:showTopTip(T("请输入手机号"))
        return
    end

    if password == "" then
        GameManager.TopTipManager:showTopTip(T("请输入密码"))
        return
    end

    self.controller:loginWithPhone(phone,password,function()
        
        btn:GetComponent('Button').interactable = true
    end)
end

function PanelPhone:onResetClick()
    local phone = self.curPhone
    local password = self.input5.text
    local code = self.input4.text

    if string.len(password) < 6 then
        GameManager.TopTipManager:showTopTip(T("密码不得少于6位"))
        return
    elseif string.len(password) > 16 then
        GameManager.TopTipManager:showTopTip(T("密码不得超出16位"))
        return
    end 

    if string.len(code) ~= 6 then
        GameManager.TopTipManager:showTopTip(T("验证码错误"))
        return
    end

    local params = {
        act = "forget",
        phone = phone,
        password = password,
        code = code,
    }

    self:sendHTTP(
        params,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("重置密码成功"))
                self:goPanel(1)
            else
                GameManager.TopTipManager:showTopTip(T("重置密码失败，请检查手机号或验证码"))
            end
        end
    )
end

function PanelPhone:onRegClick(btn)
    local password = self.input7.text
    local code = self.input8.text

    if string.len(password) < 6 then
        GameManager.TopTipManager:showTopTip(T("密码不得少于6位"))
        return
    elseif string.len(password) > 16 then
        GameManager.TopTipManager:showTopTip(T("密码不得超出16位"))
        return
    end

    if string.len(code) ~= 6 then
        GameManager.TopTipManager:showTopTip(T("验证码错误"))
        return
    end

    local params = {
        act = "register",
        phone = self.input6.text,
        password = self.input7.text,
        code = self.input8.text,
    }

    self:sendHTTP(
        params,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("注册成功"))
                self.controller:loginWithPhone(self.input6.text,self.input7.text)
                self:onClose()
            else
                GameManager.TopTipManager:showTopTip(T("注册失败"))
                btn:GetComponent('Button').interactable = true
            end
        end
    )
end

function PanelPhone:onBindClick(btn)
    
    local phone = self.input9.text
    local code = self.input10.text

    if phone == "" then
        GameManager.TopTipManager:showTopTip(T("请输入手机号"))
        btn:GetComponent('Button').interactable = true
        return
    end

    if string.len(code) ~= 6 then
        GameManager.TopTipManager:showTopTip(T("验证码错误"))
        btn:GetComponent('Button').interactable = true
        return
    end

    http.bindPhone(
        phone,
        code,
        function(callData)
            if callData and callData.flag == 1 then
                self:onClose()
                GameManager.GameConfig.isBind = 1
                -- local PanelExchange = import("Panel.Exchange.PanelExchange").new()
                local PanelNewShop = import("Panel.Shop.PanelNewShop").new(2)
            elseif callData and callData.flag == -1 then
                btn:GetComponent('Button').interactable = true
                GameManager.TopTipManager:showTopTip(T("验证码错误"))
            elseif callData and callData.flag == -8 then
                btn:GetComponent('Button').interactable = true
                GameManager.TopTipManager:showTopTip(T("微信账号重复"))
            elseif callData and callData.flag == -9 then
                btn:GetComponent('Button').interactable = true
                GameManager.TopTipManager:showTopTip(T("手机账号重复"))
            else
                btn:GetComponent('Button').interactable = true
                GameManager.TopTipManager:showTopTip(T("绑定失败"))
            end
        end,
        function(callData)
            btn:GetComponent('Button').interactable = true
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelPhone:setPanelActive(index)
    
    for i = 1,4 do
        self.panels[i]:SetActive(false)
    end
    self.panels[index]:SetActive(true)
end

function PanelPhone:onResetTimerStart()
    
    self.resetTime = 60
    self.btn2:SetActive(false)
    self.timer1:SetActive(true)
    self.timer1:GetComponent("Text").text = self.resetTime..T(" 秒")

    self.resetTimer = Timer.New(function()
        self:onResetTimer()
    end,1,-1,true)
    self.resetTimer:Start()
end

function PanelPhone:onResetTimer()
    
    self.resetTime = self.resetTime - 1
    self.timer1:GetComponent("Text").text = self.resetTime..T(" 秒")

    if self.resetTime == 0 then
        self:onResetTimerEnd()
        self.btn2:SetActive(true)
        self.timer1:SetActive(false)
    end
end

function PanelPhone:onResetTimerEnd()
    
    if self.resetTimer then
        self.resetTimer:Stop()
    end
end

function PanelPhone:onRegTimerStart()
    
    self.regTime = 60
    self.btn3:SetActive(false)
    self.timer2:SetActive(true)
    self.timer2:GetComponent("Text").text = self.regTime..T(" 秒")

    self.regTimer = Timer.New(function()
        self:onRegTimer()
    end,1,-1,true)
    self.regTimer:Start()
end

function PanelPhone:onRegTimer()
    
    self.regTime = self.regTime - 1
    self.timer2:GetComponent("Text").text = self.regTime..T(" 秒")

    if self.regTime == 0 then
        self:onRegTimerEnd()
        self.btn3:SetActive(true)
        self.timer2:SetActive(false)
    end
end

function PanelPhone:onRegTimerEnd()
    
    if self.regTimer then
        self.regTimer:Stop()
    end
end

function PanelPhone:onBindTimerStart()
    
    self.bindTime = 60
    self.btn4:SetActive(false)
    self.timer3:SetActive(true)
    self.timer3:GetComponent("Text").text = self.bindTime..T(" 秒")

    self.bindTimer = Timer.New(function()
        self:onBindTimer()
    end,1,-1,true)
    self.bindTimer:Start()
end

function PanelPhone:onBindTimer()
    
    self.bindTime = self.bindTime - 1
    self.timer3:GetComponent("Text").text = self.bindTime..T(" 秒")

    if self.bindTime == 0 then
        self:onBindTimerEnd()
        self.btn4:SetActive(true)
        self.timer3:SetActive(false)
    end
end

function PanelPhone:onBindTimerEnd()
    
    if self.bindTimer then
        self.bindTimer:Stop()
    end
end

function PanelPhone:sendHTTP(params,resultCallback)
    
    local url = BM_UPDATE.PHONE_REG

    for k,v in pairs(params) do
        url = url.."&"..k.."="..v
    end

    wwwMgr:RequestHttpGET(url,function(error,data)
        
        if error then
           GameManager.TopTipManager:showTopTip(T("获取数据失败"))
        else
            local retData = json.decode(data)
            if resultCallback then
                resultCallback(retData)
            end
        end
    end)
end

function PanelPhone:onClose()
    -- 这里最好写一个控制器控制
    self:onResetTimerEnd()
    self:onRegTimerEnd()
    self:onBindTimerEnd()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelPhone