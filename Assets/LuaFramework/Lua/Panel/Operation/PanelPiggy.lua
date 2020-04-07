local PanelPiggy = class("PanelPiggy")


function PanelPiggy:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelPiggy" }, function(objs)
        self:initView(objs)
    end)
end

function PanelPiggy:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPiggy"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelPiggy:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelPiggy:initProperties(data)
    self.data = {}
end


function PanelPiggy:initUIControls()
    self.closeButton     = self.view:findChild("btnClose")
    self.tipImage        = self.view:findChild("tipImage")
    self.rewardButton    = self.view:findChild("btnReward")
    self.inMoneyText     = self.view:findChild("inMoney")
    self.rewardInfoText  = self.view:findChild("btnReward/infoText")
    self.rewardPriceText = self.view:findChild("btnReward/priceText")
    self.currentVipText  = self.view:findChild("bottomBg/currentLevel/allText")
    self.limtText        = self.view:findChild("bottomBg/limit/allText")
    self.ruleButton      = self.view:findChild("bottomBg/rule/btnRule")
    self.ruleView        = self.view:findChild("ruleView")
    self.ruleImage       = self.view:findChild("ruleView/ruleImage")
    self.ruleCloseButton = self.view:findChild("ruleView/btnClose")


    self.closeButton:addButtonClick(buttonSoundHandler(self, function()
        self:onCloseButtonClick()
    end))

    self.rewardButton:addButtonClick(buttonSoundHandler(self, function()
        self:onRewardButtonClick()
    end))

    self.ruleButton:addButtonClick(buttonSoundHandler(self, function()
        self:onRuleButtonClick()
    end))

    self.ruleCloseButton:addButtonClick(buttonSoundHandler(self, function()
        self:onRuleCloseButtonClick()
    end))

end

function PanelPiggy:initUIDatas()
    self:getUserMoneyBox(function()
        self.rewardPriceText:setText(string.format(T("%d元"), self.data.price))
        self.rewardInfoText:setText(string.format(T("今日可砸：%d次"), self.data.number))
        TMPHelper.setText(self.limtText, self.data.moneyFull)
        TMPHelper.setText(self.currentVipText, string.format(T("VIP%s"), GameManager.UserData.viplevel))
        self.inMoneyText:setText(self.data.money)
        GameManager.ImageLoader:loadAndCacheImage(self.data.tips,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.tipImage:setSprite(sprite)
                    self.tipImage:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
        GameManager.ImageLoader:loadAndCacheImage(self.data.ruleUrl,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.ruleImage:setSprite(sprite)
                    self.ruleImage:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
    end)
end

function PanelPiggy:onClose(callback)
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
        if callback then
            callback()
        end
    end)
end


--[[
    event handle
]]

function PanelPiggy:onRewardButtonClick()
    local callback = function()
        local tipsString = string.format(T("存钱罐还未存满，是否花费\n%d元砸开存钱罐领取%d金币"), self.data.price, self.data.money)
        if self.data.money == self.data.moneyFull then
            tipsString = string.format(T("存钱罐已存满，是否花费\n%d元砸开存钱罐领取%d金币"), self.data.price, self.data.money)
        end
        if self.data.number == 0 then
            tipsString = T("今日次数已用完，明日再来吧！")
        end
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = tipsString,
            firstButtonCallbcak = function()
                self.data.product.from = "moneyBox"
                local PanelPay = import("Panel.Shop.PanelPay").new(self.data.product)
            end,
            secondButtonCallbcak = function()
                PanelPiggy.new()
            end
        })
    end
    self:onClose(callback)
end

function PanelPiggy:onCloseButtonClick( )
    self:onClose()
end

function PanelPiggy:onRuleButtonClick()
    showOrHide(not self.ruleView.activeSelf, self.ruleView)
end

function PanelPiggy:onRuleCloseButtonClick()
    hide(self.ruleView)
end

--[[
    http
]]

function PanelPiggy:getUserMoneyBox(callback)
    http.getUserMoneyBox(
        function(callData)
            if callData then
                dump(callData)
                if callData.flag == 1 then
                    self.data = callData
                    if callback then
                        callback()
                    end
                end
            end
        end,
        function(callData)
            dump(callData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败！"))
        end
    )
end

return PanelPiggy