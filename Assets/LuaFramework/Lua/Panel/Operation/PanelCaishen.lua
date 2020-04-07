local PanelCaishen = class("PanelCaishen")

function PanelCaishen:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelCaishen" }, function(objs)
        self:initView(objs)
    end)
end

function PanelCaishen:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelCaishen"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelCaishen:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelCaishen:initProperties()
    self.status = false
end

function PanelCaishen:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.btnReward = self.view.transform:Find("btnReward").gameObject
    self.Des = self.view.transform:Find("des").gameObject
    self.Time = self.view.transform:Find("btnReward/Timer").gameObject

    -- 财神等级 <size=31><color=#ffe632>Lv.888</color></size> 
    self.levelText = self.view:findChild("levelText")
    self.progressBar = self.view:findChild("progressBar")
    self.progressText = self.view:findChild("progressBar/Text")
end

function PanelCaishen:initUIDatas()
    http.getUserWealthGod(
        function(callData)
            
            if callData then
                dump(callData)
                self:reflushPanel(callData)
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelCaishen:reflushPanel(callData)
    
    -- self.Money:setText(callData.wealth)
    -- self.Level:setText(callData.god_level)
    self.levelText:setText(string.format("财神等级 <size=31><color=#ffe632>Lv.%s</color></size> ", tonumber(callData.god_level)))
    self.progressBar.transform:GetComponent('Slider').maxValue = tonumber(callData.wealth)
    
    self.Des:setText(callData.declare)
    self.status = tonumber(callData.status)
    
    if tonumber(callData.god_level) == 0 then
        self.btnReward:addButtonClick(buttonSoundHandler(self,function()
            
            self:onClose()
            GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.CAISHEN
            -- local PanelShop = import("Panel.Shop.PanelShop").new()
            -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
            local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
        end), false)
        self.Time:setText(T("立即激活"))
        self.progressText:setText(string.format("%s/%s", 0, tonumber(callData.wealth)))
        self.progressBar.transform:GetComponent('Slider').value = 0
    else
        self.btnReward:addButtonClick(buttonSoundHandler(self,self.onBtnRewardClick), false)
        if self.status == 0 then
            self.lastTime = tonumber(callData.count_down)
            local time = formatTimer(self.lastTime)
            self.Time:setText(time)
            self:onTimerStart()
        else
            self.Time:setText(T("领取"))
        end
        self.progressText:setText(string.format("%s/%s", tonumber(callData.winFlow), tonumber(callData.wealth)))
        self.progressBar.transform:GetComponent('Slider').value = tonumber(callData.winFlow)
    end
    
end

function PanelCaishen:onTimerStart()
    
    if self.timer then
		self:onTimerEnd()
    end

    self.timer = Timer.New(function()
        self:onTimer()
    end,1,-1,true)
    self.timer:Start()
end

function PanelCaishen:onTimer()
    self.lastTime = self.lastTime - 1

    if self.lastTime == 0 then
        self.status = 1
        self.Time:setText(T("领取"))
    else
        local time = formatTimer(self.lastTime)
        self.Time:setText(time)
    end
end

function PanelCaishen:onTimerEnd()
    
    if self.timer then
		self.timer:Stop()
	end
end

function PanelCaishen:onBtnRewardClick()
    if self.status == 0 then
        return
    end

    http.receiveUserWealthGod(
        function(callData)
            
            if callData and callData.flag == 1 then
                dump(callData)
                self:reflushPanel(callData)
                GameManager.UserData.money = callData.latest_money
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")

                GameManager.UserData.redDotData.wealthGod.dot = 0
                if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
                    GameManager.runningScene.view_:redDotManager()
                end
            elseif callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("时间未到"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelCaishen:onClose()
    -- 这里最好写一个控制器控制
    self:onTimerEnd()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelCaishen