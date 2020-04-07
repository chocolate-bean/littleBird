local PanelDialog = class("PanelDialog")

function PanelDialog:ctor(param)
    self.hasFristButton = param.hasFristButton
    self.hasSecondButton = param.hasSecondButton
    self.hasCloseButton = param.hasCloseButton

    self.firstButtonText = param.firstButtonText or T("确认")
    self.secondButtonText = param.secondButtonText or T("取消")

    self.titleText = param.title or T("提示")
    self.desText = param.text

    self.firstButtonCallbcak = param.firstButtonCallbcak or nil
    self.secondButtonCallbcak = param.secondButtonCallbcak or nil

    self.closeWithSecondButtonCallback = param.closeWithSecondButtonCallback or false

    resMgr:LoadPrefabByRes("Dialog", { "PanelDialog" }, function(objs)
        self:initView(objs)
        self:show()
    end)
end

function PanelDialog:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelDialog"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
end

function PanelDialog:initProperties()

end

function PanelDialog:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onCloseClick))

    -- 确认按钮
    self.btnYes = self.view.transform:Find("btnYes").gameObject
    UIHelper.AddButtonClick(self.btnYes,buttonSoundHandler(self,self.onBtnYesClick))

    -- 取消按钮
    self.btnNo = self.view.transform:Find("btnNo").gameObject
    UIHelper.AddButtonClick(self.btnNo,buttonSoundHandler(self,self.onBtnNoClick))

    self.title = self.view.transform:Find("title").gameObject
    self.title:GetComponent('Text').text = self.titleText

    self.des = self.view.transform:Find("des").gameObject
    self.des:GetComponent('Text').text = self.desText

    self.btnYesText = self.view.transform:Find("btnYes/Text").gameObject
    self.btnYesText:GetComponent('Text').text = self.firstButtonText
    self.btnNoText = self.view.transform:Find("btnNo/Text").gameObject
    self.btnNoText:GetComponent('Text').text = self.secondButtonText

    -- 是否有关闭按钮
    if not self.hasCloseButton then
        self.btnClose:SetActive(false)
    end

    -- 如果两个按钮都没有
    if not self.hasFristButton and not self.hasSecondButton then
        self.btnYes:SetActive(false)
        self.btnNo:SetActive(false)
    -- 如果只有第一个
    elseif self.hasFristButton and not self.hasSecondButton then
        self.btnYes:SetActive(true)
        self.btnNo:SetActive(false)
        -- 第一个按钮居中
        self.btnYes.transform.localPosition = Vector3.New(0,-120,0)
    -- 如果只有第二个
    elseif not self.hasFristButton and self.hasSecondButton then
        self.btnYes:SetActive(false)
        self.btnNo:SetActive(true)
        -- 第二个按钮居中
        self.btnNo.transform.localPosition = Vector3.New(0,-120,0)
    -- 如果都有
    else
        self.btnYes:SetActive(true)
        self.btnNo:SetActive(true)
    end
end

function PanelDialog:initUIDatas()

end

function PanelDialog:show(isAnimation)
    -- local parent = UnityEngine.GameObject.Find("Canvas")
    -- self.view.transform:SetParent(parent.transform)
    -- self.view.transform.localScale = Vector3.one
    -- self.view.transform.localPosition = Vector3.New(0,720,0)

    -- local sequence = DG.Tweening.DOTween.Sequence()
    -- sequence:Append(self.view.transform:DOLocalMove(Vector3.zero, 0.5))
    GameManager.PanelManager:addPanel(self,true,3)
end

function PanelDialog:onBtnYesClick()
    self:onClose()
    
    if self.firstButtonCallbcak then
        self.firstButtonCallbcak()
    end
end

function PanelDialog:onBtnNoClick()
    self:onClose()
    
    if self.secondButtonCallbcak then
        self.secondButtonCallbcak()
    end
end

function PanelDialog:onCloseClick()
    self:onClose()
    
    if self.closeWithSecondButtonCallback then
        if self.secondButtonCallbcak then
            self.secondButtonCallbcak()
        end
    end
end

function PanelDialog:onClose()
    -- destroy(self.view)
    -- self.view = nil
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelDialog