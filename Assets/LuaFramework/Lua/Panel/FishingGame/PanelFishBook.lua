local PanelFishBook = class("PanelFishBook")

function PanelFishBook:ctor()
    resMgr:LoadPrefabByRes("FishingGame/UI", { "PanelFishingGameFishBook" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFishBook:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishBook"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFishBook:initProperties()
    
end

function PanelFishBook:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.image = self.view.transform:Find("Static/ScrollView/Viewport/Image").gameObject
end

function PanelFishBook:initUIDatas(ruleText)
    self.image:SetActive(false)
    http.fishingGuide(
        function(callData)
            if callData then
                GameManager.ImageLoader:loadImageOnlyShop(callData.guidePicture,function (success, sprite)
                    if success and sprite then
                        if self.view and self.image then
                            self.image:GetComponent('Image').sprite = sprite
                            self.image:GetComponent('Image'):SetNativeSize()
                            self.image:SetActive(true)
                        end
                    end
                end)
            end
        end,
        function(callData)
        end
    )
end

function PanelFishBook:show()
    GameManager.PanelManager:addPanel(self, true, 3)
end

function PanelFishBook:onClose()
    GameManager.PanelManager:removePanel(self, nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFishBook