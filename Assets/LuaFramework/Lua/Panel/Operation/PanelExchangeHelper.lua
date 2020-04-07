local PanelExchangeHelper = class("PanelExchangeHelper")

function PanelExchangeHelper:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelExchangeHelper" }, function(objs)
        self:initView(objs)
    end)
end

function PanelExchangeHelper:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelExchangeHelper"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelExchangeHelper:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelExchangeHelper:initProperties()
    self.status = false
end

function PanelExchangeHelper:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.btnCopy = self.view.transform:Find("btnCopy").gameObject
    self.btnCopy:addButtonClick(buttonSoundHandler(self,self.onBtnCopyClick), false)

    self.Bg = self.view.transform:Find("Bg").gameObject
    self.Bg:SetActive(false)
end

function PanelExchangeHelper:initUIDatas()
    http.wechatOfficial(
        function(callData)
            if callData and callData.flag == 1 then
                print(callData.flag)
                GameManager.ImageLoader:loadImageOnlyShop(callData.config.picUrl,function (success, sprite)
                    if success and sprite then
                        if self.view and self.Bg then
                            self.Bg:GetComponent('Image').sprite = sprite
                            self.Bg:SetActive(true)
                        end
                    end
                end)
                self.text = callData.config.wechatName
            end
        end,
        function(callData)
        end
    )
end

function PanelExchangeHelper:onBtnCopyClick()
    -- local text = T("王炸捕鱼服务号")
    -- if isMZBY() then
    --     text = T("拇指派科技")
    -- elseif isDBBY() then
    --     text = T("掌心趣科技")
    -- elseif isDFBY() then
    --     text = T("巅峰捕鱼经典版")
    -- end
    sdkMgr:CopyTextToClipboard(self.text)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
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
            local PanelExchangeHelper = import("Panel.Operation.PanelExchangeHelper").new()
        end
    })
end

function PanelExchangeHelper:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new(2)
    end)
end

return PanelExchangeHelper