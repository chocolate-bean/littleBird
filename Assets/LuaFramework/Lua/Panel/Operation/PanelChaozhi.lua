local PanelChaozhi = class("PanelChaozhi")

PanelChaozhi.Event = {
    Show    = 1,
    Success = 2,
    Cancel  = 3,
}

function PanelChaozhi:ctor(callback)
    
    resMgr:LoadPrefabByRes("Operation", { "PanelChaozhi" }, function(objs)
        self:initView(objs, callback)
    end)
end

function PanelChaozhi:initView(objs, callback)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelChaozhi"

    self:initProperties(callback)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelChaozhi:show()
    if self.callback then
        self.callback(PanelChaozhi.Event.Show)
    end
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelChaozhi:initProperties(callback)
    self.callback = callback
end

function PanelChaozhi:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.Title = self.view.transform:Find("Title").gameObject
    self.Money = self.view.transform:Find("Money").gameObject
    self.Hongbao = self.view.transform:Find("Hongbao").gameObject

    self.btnReward = self.view.transform:Find("btnReward").gameObject
    self.btnReward:addButtonClick(buttonSoundHandler(self,self.onBtnRewardClick), false)
end

function PanelChaozhi:initUIDatas()
    http.getPromotionReturn(
        function(callData)
            
            if callData then
                dump(callData)
                self.Money:setText(callData.data.desc_str)
                self.Hongbao:setText(callData.data.desc_str2)
                GameManager.ImageLoader:loadAndCacheImage(callData.data.picture.price,function (success, sprite)
                    
                    if success and sprite then
                        if self.view then
                            self.Title:setSprite(sprite)
                        end
                    end
                end)
                self.payData = callData.data
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelChaozhi:onBtnRewardClick()
    if self.payData then
        self:onClose()
        local PanelPay = import("Panel.Shop.PanelPay").new(self.payData,function()
            
            local PanelChaozhi = import("Panel.Operation.PanelChaozhi").new()
        end)
    end
end

function PanelChaozhi:onClose()
    -- 这里最好写一个控制器控制
    if self.callback then
        self.callback(PanelChaozhi.Event.Cancel)
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelChaozhi