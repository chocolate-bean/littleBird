local PanelInvite = class("PanelInvite")


PanelInvite.CONST = {
    Time = {
        Show         = 0.3,
        Dismiss      = 0.2,
        BarrageStart = 0.5,
        BarrageShow  = 0.2,
    },
    Size = {
        HelpW = 1077,
        HelpH = 431,
    },
    Value = {
        BarrageSpeed   = 80,
    }
}

function PanelInvite:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelInvite" }, function(objs)
        self:initView(objs)
    end)
end

function PanelInvite:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelInvite"

    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelInvite:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelInvite:initProperties(objs)

end

-- function PanelInvite:getRecordAndShow()
--     self:getLotteryRecord(function()
--         self.barrageArray = self.recordData.broadcast
--         if self.barrageNeedWait == nil then
--             self.barrageNeedWait = false
--             self:showLoopBarrage(1)
--         else
--             self.barrageNeedWait = true
--         end
--     end)
-- end

function PanelInvite:showLoopBarrage(index)
    self:showBarrageAnimation(self.barrageArray[index], function()
        index = index + 1
        if index > #self.barrageArray then
            index = 1
        end
        -- 等待完成 判断是否需要更新
        if self.barrageNeedWait then
            self.barrageNeedWait = false
            index = 1 
        end
        self:showLoopBarrage(index)
    end)
end

function PanelInvite:showBarrageAnimation(text, doneCallback)
    self.barrageText:setText(text)
    -- 首先拿到父控件的长度 和 自身的长度 width
    local parentW = self.barrage.transform.sizeDelta.x
    local selfW = self.barrageText.transform:GetComponent('Text').preferredWidth
    self.barrageText.transform.localPosition = Vector3.New((parentW + selfW) * 0.5, 0, 0)

    -- 先展示出来 然后在消失
    -- local startAnimation = self.barrageText.transform:DOLocalMoveX(parentW * -0.5 + selfW * 0.5 + 30, PanelInvite.CONST.Time.BarrageStart)
    -- startAnimation:SetEase(DG.Tweening.Ease.OutBack)
    -- startAnimation:OnComplete(function()
    --     -- 展示等待
    --     local waitAnimation = self.barrageText.transform:DOLocalMoveX(parentW * -0.5 + selfW * 0.5 + 30, PanelInvite.CONST.Time.BarrageShow)
    --     waitAnimation:OnComplete(function()
    --  消失按照长度计算时间
    local duration = (selfW + parentW) / PanelInvite.CONST.Value.BarrageSpeed
    local barrageAnimation = self.barrageText.transform:DOLocalMoveX((parentW + selfW) * -0.5, duration)
    barrageAnimation:SetEase(DG.Tweening.Ease.Linear)
    barrageAnimation:OnComplete(function()
        if doneCallback then
            doneCallback()
        end
    end)
    --     end)
    -- end)
end

function PanelInvite:initUIControls()
    self.bg = self.view:findChild("bg")
    self.closeButton       = self.view:findChild("bg/closeButton")
    self.showHelpButton    = self.view:findChild("bg/showHelpButton")
    self.copyPublicButton  = self.view:findChild("bg/copyPublicButton")
    self.publicText        = self.view:findChild("bg/publicText")
    self.barrage           = self.view:findChild("bg/barrage")
    self.barrageText       = self.view:findChild("bg/barrage/Text")
    self.helpView          = self.view:findChild("helpView")
    self.helpContent       = self.view:findChild("helpView/contentImage")
    self.dismissHelpButton = self.view:findChild("helpView/dismissHelpButton")
    self.publicTextBalck   = self.view:findChild("helpView/publicText_black")
    self.publicTextYellow  = self.view:findChild("helpView/publicText_yellow")

    hide(self.helpView)

    self.closeButton:addButtonClick(buttonSoundHandler(self, function()
        self:onCloseButtonClick()
    end))

    self.showHelpButton:addButtonClick(buttonSoundHandler(self, function()
        self:onShowHelpButtonClick()
    end))

    self.copyPublicButton:addButtonClick(buttonSoundHandler(self, function()
        self:onCopyPublicButtonClick()
    end))

    self.dismissHelpButton:addButtonClick(buttonSoundHandler(self, function()
        self:onDismissHelpButtonClick()
    end))
end

function PanelInvite:initUIDatas()
    self:shareFriend(function()
        self.barrageArray = self.data.log
        self:showLoopBarrage(1)
        self.publicText:setText(self.data.config.wechatName)
        self.publicTextBalck:setText(self.data.config.wechatName)
        self.publicTextYellow:setText(self.data.config.wechatName)
        GameManager.ImageLoader:loadAndCacheImage(self.data.config.picUrl,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.bg:setSprite(sprite)
                    self.bg:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
    
        -- self.taskItems = {}
        -- for i = 1, 8 do
        --     local item = self:newOtmTaskItem(i)
        --     self.taskItems[#self.taskItems + 1] = item
        -- end
    end)
end

function PanelInvite:onClose(callback)
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

function PanelInvite:onCopyPublicButtonClick()
    local text = T("王炸捕鱼服务号")
    if isMZBY() then
        text = T("拇指派科技")
    elseif isDBBY() then
        text = T("掌心趣科技")
    elseif isDFBY() then
        text = T("巅峰捕鱼经典版")
    end
    if self.data and self.data.config and self.data.config.wechatName then
        text = self.data.config.wechatName
    end

    sdkMgr:CopyTextToClipboard(text)
    self:onClose(function()
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("复制成功，是否立即跳转到微信"),
            firstButtonCallbcak = function()
                sdkMgr:JumpToWX()
            end,
            secondButtonCallbcak = function()
                local PanelInvite = import("Panel.Operation.PanelInvite").new()
            end
        })
    end)
end

function PanelInvite:onShowHelpButtonClick()
    show(self.helpView)
    self.helpView.transform.sizeDelta = Vector2.New(PanelInvite.CONST.Size.HelpW, 0)
    self.helpView.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(PanelInvite.CONST.Size.HelpW, PanelInvite.CONST.Size.HelpH), PanelInvite.CONST.Time.Show)
end

function PanelInvite:onDismissHelpButtonClick()
    local animation = self.helpView.transform:GetComponent('RectTransform'):DOSizeDelta(Vector2.New(PanelInvite.CONST.Size.HelpW, 0), PanelInvite.CONST.Time.Dismiss)
    animation:OnComplete(function()
        hide(self.helpView)
    end)
end

function PanelInvite:onCloseButtonClick( )
    self:onClose()
end


--[[
    http
]]

function PanelInvite:shareFriend(callback)
    http.shareFriend(
        function(callData)
            if callData then
                dump(callData)
                self.data = callData
                if callback then
                    callback()
                end
            end
        end,
        function(callData)
            dump(callData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败！"))
        end
    )
end


return PanelInvite