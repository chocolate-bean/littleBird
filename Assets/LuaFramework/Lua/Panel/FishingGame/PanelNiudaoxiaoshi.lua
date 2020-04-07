local PanelNiudaoxiaoshi = class("PanelNiudaoxiaoshi")

function PanelNiudaoxiaoshi:ctor(data, callback)
    self.callback = callback
    resMgr:LoadPrefabByRes("FishingGame/UI", { "PanelNiudaoxiaoshi" }, function(objs)
        self:initView(objs, data)
    end)
end

function PanelNiudaoxiaoshi:initView(objs, data)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelNiudaoxiaoshi"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties(data)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelNiudaoxiaoshi:initProperties(data)
    self.config = data
end

function PanelNiudaoxiaoshi:initUIControls()
    self.closeButton   = self.view:findChild("btnClose")

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
        
        if self.callback then
            self.callback()
        end
    end), false)

    self.view:addButtonClick(buttonSoundHandler(self, function()
        self:onBuyButtonClick()
    end))
end

function PanelNiudaoxiaoshi:initUIDatas()
    if self.config.desc_pic1 then
        GameManager.ImageLoader:loadAndCacheImage(self.config.desc_pic1,function (success, sprite)
            if success and sprite then
                if self.view then
                    self.view:setSprite(sprite)
                    self.view:GetComponent('Image'):SetNativeSize()
                end
            end
        end)
    end
end

function PanelNiudaoxiaoshi:show()
    GameManager.PanelManager:addPanel(self, true, 3)
end

function PanelNiudaoxiaoshi:onClose()
    GameManager.PanelManager:removePanel(self, nil,function()
        destroy(self.view)
        self.view = nil
    end)
end


--[[
    evet handle
]]

function PanelNiudaoxiaoshi:onBuyButtonClick()
    self.payPanel = import("Panel.Shop.PanelPay").new(self.config, function()
        self:onClose()
    end)
end


return PanelNiudaoxiaoshi