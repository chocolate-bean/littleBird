local PanelPochan = class("PanelPochan")

PanelPochan.Event = {
    Show    = 1,
    Success = 2,
    Cancel  = 3,
}

function PanelPochan:ctor(callback)
    
    resMgr:LoadPrefabByRes("Operation", { "PanelPochan" }, function(objs)
        self:initView(objs, callback)
    end)
end

function PanelPochan:initView(objs, callback)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPochan"

    self:initProperties(callback)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelPochan:show()
    if self.callback then
        self.callback(PanelPochan.Event.Show)
    end
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelPochan:initProperties(callback)
    self.callback = callback
end

function PanelPochan:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.Title = self.view.transform:Find("Title").gameObject
    self.Money = self.view.transform:Find("Money").gameObject
    self.Time = self.view.transform:Find("Time").gameObject

    self.btnReward = self.view.transform:Find("btnReward").gameObject
    self.btnReward:addButtonClick(buttonSoundHandler(self,self.onBtnRewardClick), false)
end

function PanelPochan:initUIDatas()
    http.getPromotionBankrupt(
        function(callData)
            
            if callData then
                dump(callData)
                self.Money:setText(callData.data.desc_str)
                GameManager.ImageLoader:loadAndCacheImage(callData.data.picture.price,function (success, sprite)
                    
                    if success and sprite then
                        if self.view then
                            self.Title:setSprite(sprite)
                        end
                    end
                end)
                self.payData = callData.data

                self.lastTime = tonumber(callData.data.count_down)
                local time = formatTimer(self.lastTime)
                self.Time:setText(T("倒计时")..time)
                self:onTimerStart()
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelPochan:onTimerStart()
    
    if self.timer then
		self:onTimerEnd()
    end

    self.timer = Timer.New(function()
        self:onTimer()
    end,1,-1,true)
    self.timer:Start()
end

function PanelPochan:onTimer()
    self.lastTime = self.lastTime - 1

    if self.lastTime == 0 then
        self.Time:setText("")
    else
        local time = formatTimer(self.lastTime)
        self.Time:setText(T("倒计时")..time)
    end
end

function PanelPochan:onTimerEnd()
    
    if self.timer then
		self.timer:Stop()
	end
end

function PanelPochan:onBtnRewardClick()
    if self.payData then
        self:onTimerEnd()
        GameManager.PanelManager:removePanel(self,nil,function()
            destroy(self.view)
            self.view = nil
        end)
        if not self.payData.id then
            self.payData.id = self.payData.product_id
        end
        local PanelPay = import("Panel.Shop.PanelPay").new(self.payData,function()
            local PanelPochan = import("Panel.Operation.PanelPochan").new()
        end)
    end
end

function PanelPochan:onClose()
    if self.callback then
        self.callback(PanelPochan.Event.Cancel)
    end
    self:onTimerEnd()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelPochan