local PanelLoginDialog = class("PanelLoginDialog")

function PanelLoginDialog:ctor(hasSecondButton, text, firstButtonCallbcak, secondButtonCallbcak)
    self.hasSecondButton = hasSecondButton
    self.desText = text

    self.firstButtonCallbcak = firstButtonCallbcak or nil
    self.secondButtonCallbcak = secondButtonCallbcak or nil

    resMgr:LoadPrefabByRes("Dialog", { "PanelLoginDialog" }, function(objs)
        self:initView(objs)
    end)
end

function PanelLoginDialog:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLoginDialog"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelLoginDialog:initProperties()

end

function PanelLoginDialog:initUIControls()
    print("initUIControls")
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:SetActive(false)

    -- 确认按钮
    self.btnYes = self.view.transform:Find("btnYes").gameObject
    UIHelper.AddButtonClick(self.btnYes,function()
        self:onBtnYesClick()
    end)

    -- 取消按钮
    self.btnNo = self.view.transform:Find("btnNo").gameObject
    UIHelper.AddButtonClick(self.btnNo,function()
        self:onBtnNoClick()
    end)

    self.des = self.view.transform:Find("des").gameObject
    self.des:GetComponent('Text').text = self.desText

    if not self.hasSecondButton then
        self.btnYes:SetActive(true)
        self.btnNo:SetActive(false)
        -- 第二个按钮居中
        self.btnYes.transform.localPosition = Vector3.New(0,-120,0)
    -- 如果都有
    else
        self.btnYes:SetActive(true)
        self.btnNo:SetActive(true)
    end
end

function PanelLoginDialog:initUIDatas()
end

function PanelLoginDialog:show()
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
end

function PanelLoginDialog:onBtnYesClick()
    
    if self.firstButtonCallbcak then
        self.firstButtonCallbcak()
    end

    self:onClose()
end

function PanelLoginDialog:onBtnNoClick()
    
    if self.secondButtonCallbcak then
        self.secondButtonCallbcak()
    end

    self:onClose()
end

function PanelLoginDialog:onClose()
    destroy(self.view)
    self.view = nil
end

return PanelLoginDialog