local PanelLoginReward = class("PanelLoginReward")

function PanelLoginReward:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelLoginReward" }, function(objs)
        self:initView(objs)
    end)
end

function PanelLoginReward:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLoginReward"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelLoginReward:show()
    
    GameManager.UserData.login_reward_status = 0
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelLoginReward:initProperties()
    self.loginItems = {}
    self.vipItems = {}
end

function PanelLoginReward:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    for i = 1,7 do
        local item = self.view.transform:Find("Item"..i).gameObject
        self.loginItems[i] = item
    end

    for i = 1,5 do
        local item = self.view.transform:Find("VipBtn"..i).gameObject
        self.vipItems[i] = item
    end

    self.day1 = self.view.transform:Find("Day1").gameObject
    self.day2 = self.view.transform:Find("Day2").gameObject

    if isDBBY() then
        self.btnShop = self.view.transform:Find("btnShop").gameObject
        self.btnShop:addButtonClick(buttonSoundHandler(self,function()
            self:onClose()
            local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
        end), false)
    end
end

function PanelLoginReward:initUIDatas()
    -- 登陆奖励
    http.ddzLoginReward(
        function(callData)
            if callData then
                dump(callData)
                self.loginDay = tonumber(callData.normal.day)
                self:refashPanel(callData)
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelLoginReward:refashPanel(data)
    
    for i = 1,7 do
        local title = self.loginItems[i].transform:Find("Title").gameObject
        title:setText(data.normal.config[i].title)
        local Num = self.loginItems[i].transform:Find("Num").gameObject
        Num:setText(data.normal.config[i].content)

        if data.normal.status == 1 then
            self.day1:setText(self.loginDay - 1)
            if i < tonumber(data.normal.day) then
                if isDBBY() then
                    local Ready = self.loginItems[i].transform:Find("Ready").gameObject
                    Ready:SetActive(false)
                else
                    local Ready = self.loginItems[i].transform:Find("Ready").gameObject
                    Ready:SetActive(true)
                end
            end
    
            if i == tonumber(data.normal.day) then
                local Light = self.loginItems[i].transform:Find("Light").gameObject
                Light:SetActive(true)
            end
    
            self.loginItems[i]:addButtonClick(buttonSoundHandler(self, function()
                
                if i == data.normal.day then
                    self:getNormalReward(i)
                end
            end), false)
        elseif data.normal.status == 0 then
            self.day1:setText(self.loginDay)
            if i <= tonumber(data.normal.day) then
                if isDBBY() then
                    local Ready = self.loginItems[i].transform:Find("Ready").gameObject
                    Ready:SetActive(false)
                else
                    local Ready = self.loginItems[i].transform:Find("Ready").gameObject
                    Ready:SetActive(true)
                end
            end
        end
    end

    for i = 1,5 do
        local titleText = self.vipItems[i].transform:Find("Title/Text").gameObject
        titleText:setText(data.vip.config[i].days)

        local Icon = self.vipItems[i].transform:Find("Icon").gameObject
        local Num = self.vipItems[i].transform:Find("Num").gameObject
        
        if data.vip.config[i].type == "money" then
            Icon:setSprite("Images/SenceMainHall/loginGold")
            Num:setText(data.vip.config[i].money)
        elseif data.vip.config[i].type == "jewel" then
            Icon:setSprite("Images/SenceMainHall/loginHongbao")
            Num:setText(GameManager.GameFunctions.getJewel(data.vip.config[i].jewel))
        elseif data.vip.config[i].type == "diamon" then
            Icon:setSprite("Images/SenceMainHall/loginDiamond")
            Num:setText( data.vip.config[i].diamon)
        end

        local titleLight = self.vipItems[i].transform:Find("Title/Light").gameObject
        local Ready = self.vipItems[i].transform:Find("Ready").gameObject
        local Light = self.vipItems[i].transform:Find("Light").gameObject
        local isReady = false

        for k,v in pairs(data.vip.status.receive) do
            local day = tonumber(v)
            local curDay = tonumber(data.vip.config[i].days)
            if curDay == day then
                isReady = true
                Ready:SetActive(true)
            end
        end

        if tonumber(data.vip.status.continue) >= tonumber(data.vip.config[i].days) then
            titleLight:SetActive(true)
            if isReady == false then
                Light:SetActive(true)
            end
        end

        self.vipItems[i]:addButtonClick(buttonSoundHandler(self, function()
            
            if tonumber(GameManager.UserData.viplevel) > 0 then
                self:getVipReward(data.vip.config[i].days,i)
            else
                local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                    hasFristButton = true,
                    hasSecondButton = true,
                    hasCloseButton = false,
                    title = T("提示"),
                    text = T("需要VIP1才可以领取"),
                    firstButtonCallbcak = function()
                        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.LOGINREWARD
                        -- local PanelShop = import("Panel.Shop.PanelShop").new()
                        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
                        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
                    end,
                })
            end
        end), false)
    end

    self.day2:setText(data.vip.status.continue)
end

function PanelLoginReward:getNormalReward(index)
    http.receiveLoginReward(
        function(callData)
            
            if callData and callData.flag == 1 then
                local Light = self.loginItems[index].transform:Find("Light").gameObject
                Light:SetActive(false)

                if isDBBY() then
                    local Ready = self.loginItems[index].transform:Find("Ready").gameObject
                    Ready:SetActive(false)
                else
                    local Ready = self.loginItems[index].transform:Find("Ready").gameObject
                    Ready:SetActive(true)
                end

                self.day1:setText(self.loginDay)
                GameManager.UserData.money = tonumber(callData.latest_money)
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                GameManager.GameFunctions.removeRedDot("free",nil)

                GameManager.UserData.redDotData.free.dot = 0
                if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
                    GameManager.runningScene.view_:redDotManager()
                end
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelLoginReward:getVipReward(day,index)
    http.ddzReceiveReward(
        day,
        function(callData)
            
            if callData and callData.flag == 1 then
                local Ready = self.vipItems[index].transform:Find("Ready").gameObject
                Ready:SetActive(true)

                GameManager.UserData.money = tonumber(callData.latest_money)
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelLoginReward:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelLoginReward