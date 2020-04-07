local PanelLandLordsHelper = class("PanelLandLordsHelper")

function PanelLandLordsHelper:ctor(imagePath)
    
    resMgr:LoadPrefabByRes("Special", { "PanelLandLordsHelper" }, function(objs)
        self:initView(objs, imagePath)
    end)
end

function PanelLandLordsHelper:initView(objs, imagePath)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLandLordsHelper"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas(imagePath)

    self:show()
end

function PanelLandLordsHelper:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelLandLordsHelper:initProperties()
end

function PanelLandLordsHelper:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.helperImage = self.view:findChild("Des/Grid/helper")
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))
end

function PanelLandLordsHelper:initUIDatas(imagePath)
    if imagePath then
        self.helperImage:setSprite(imagePath)
        self.helperImage.transform:GetComponent("Image"):SetNativeSize()
    end
end

function PanelLandLordsHelper:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelLandLordsHelper