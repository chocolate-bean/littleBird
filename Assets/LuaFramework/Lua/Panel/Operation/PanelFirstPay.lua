local PanelFirstPay = class("PanelFirstPay")

PanelFirstPay.Event = {
    Show    = 1,
    Success = 2,
    Cancel  = 3,
}


function PanelFirstPay:ctor(callback)
    self.callback = callback
    resMgr:LoadPrefabByRes("Operation", { "PanelFirstPay" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFirstPay:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFirstPay"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFirstPay:show()
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelFirstPay:initProperties()
    self.btns = {}
    self.images = {}
    self.texts = {}
end

function PanelFirstPay:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
        
        if self.callback then
            self.callback()
        end
    end),false)

    for i = 1, 3 do
        local btn = self.view.transform:Find("btn"..i).gameObject
        btn:SetActive(false)
        table.insert(self.btns, btn)

        local Image = self.view.transform:Find("Item"..i).gameObject
        table.insert(self.images, Image)
        local Text = self.view.transform:Find("Item"..i.."/Text").gameObject
        table.insert(self.texts, Text)
    end
end

function PanelFirstPay:initUIDatas()
    http.getPromotionFirstBag(
        function(callData)
            if callData then
                dump(callData)
                for i = 1, 3 do
                    if callData.data.list[i].status == 1 then
                        self.btns[i]:SetActive(true)
                        self.btns[i]:addButtonClick(buttonSoundHandler(self, function()
                            -- self:onClose()
                            local PanelPay = import("Panel.Shop.PanelPay").new(callData.data.list[i],function()
                                -- local PanelFirstPay = require("Panel.Operation.PanelFirstPay").new()
                                self:onClose()
                            end)
                        end), false)

                        local price = self.btns[i].transform:Find("Text").gameObject
                        price:setText("￥"..callData.data.list[i].pamount)                  
                    end

                    GameManager.ImageLoader:loadImageOnlyShop(callData.data.list[i].desc_pic1,function (success, sprite)
                        
                        if success and sprite then
                            if self.view and self.images[i] then
                                self.images[i]:GetComponent('Image').sprite = sprite
                            end
                        end
                    end)

                    self.texts[i]:setText(callData.data.list[i].desc_str)
                end
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelFirstPay:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFirstPay