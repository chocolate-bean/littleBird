local PanelBossComing = class("PanelBossComing")

PanelBossComing.Time = {
    Duration = 3,
    Blood    = 0.6,
    Effect   = 0.1,
    InfoBg   = 0.3,
    InfoView = 0.7,
    Fish     = 2,
    Dismiss  = 0.5,
}

function PanelBossComing:ctor(fishType, multiple)
    resMgr:LoadPrefabByRes("FishingGame/UI", { "PanelBossComing" }, function(objs)
        self:initView(objs, fishType, multiple)
    end)
end

function PanelBossComing:initView(objs, fishType, multiple)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelBossComing"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self:initProperties(fishType, multiple)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelBossComing:initProperties(fishType, multiple)
    self.fishType = fishType
    self.multiple = multiple
end

function PanelBossComing:initUIControls()
    self.blood        = self.view:findChild("blood")
    self.infoBg       = self.view:findChild("infoBg")
    self.fish         = self.view:findChild("fish")
    self.infoView     = self.view:findChild("infoView")
    self.info         = self.view:findChild("infoView/info")
    self.multipleText = self.view:findChild("infoView/allText")
    self.effect       = self.view:findChild("effect")

    hide({self.blood, self.infoBg, self.fish, self.infoView, self.effect})

end

function PanelBossComing:initUIDatas()
    if self.fishType then
        self.fish:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/FishingGame/fish/"..self.fishType)
        self.fish:GetComponent('Image'):SetNativeSize()
    end
    if self.multiple and self.multiple ~= 0 then
        TMPHelper.setText(self.multipleText, self.multiple)
    end
end

function PanelBossComing:showAnimation()
    -- 1.1 先是blood
    show(self.blood)
    local bloodColor = self.blood.transform:GetComponent('Image').color
    self.blood.transform:GetComponent('Image').color = Color.New(bloodColor.r, bloodColor.g, bloodColor.b, 0)
    local colorAnimation = self.blood.transform:GetComponent('Image'):DOColor(Color.New(bloodColor.r, bloodColor.g, bloodColor.b, 1), PanelBossComing.Time.Blood)
    colorAnimation:SetEase(DG.Tweening.Ease.Linear)
    colorAnimation:SetLoops(PanelBossComing.Time.Duration/PanelBossComing.Time.Blood, DG.Tweening.LoopType.Yoyo)


    -- 2.1 光效结束之后 infoBg出来
    local infoBgAnimation = function()
        show(self.infoBg)
        self.infoBg.transform.localScale = Vector3.New(1, 0, 1)
        local scaleAnimation = self.infoBg.transform:DOScale(Vector3.one, PanelBossComing.Time.InfoBg)
    end

    -- 2.2 view出来
    local infoViewAnimation = function()
        show(self.infoView)
        self.infoView.transform.localScale = Vector3.New(1.5, 1.5, 1.5)
        local scaleAnimation = self.infoView.transform:DOScale(Vector3.one, PanelBossComing.Time.InfoView)
    end

    -- 1.2 一起的是光效的动画
    show(self.effect)
    doFadeShow(self.effect, 'Image', PanelBossComing.Time.Effect, 0)
    local effectScale = self.effect.transform:DOScale(Vector3.New(40, 1.3, 1), PanelBossComing.Time.Effect * 2)
    effectScale:OnComplete(function()
        self.effect.transform:DOScale(Vector3.New(40, 0, 1), PanelBossComing.Time.Effect * 1.5):OnComplete(function()
            infoBgAnimation()
            infoViewAnimation()
        end)
    end)
    
    -- 1.3 还有boos的图片动画
    show(self.fish)
    doFadeShow(self.fish, 'Image', PanelBossComing.Time.Fish, 0)

    Timer.New(function()
        self:onClose()
    end, PanelBossComing.Time.Duration, 1, true):Start()
end


function PanelBossComing:show()
    GameManager.PanelManager:addPanel(self, true)
    self:showAnimation()
end

function PanelBossComing:onClose()
    GameManager.PanelManager:removePanel(self, nil, function()

        doFadeDismiss(self.blood, 'Image', PanelBossComing.Time.Effect, 0)
        doFadeDismiss(self.fish, 'Image', PanelBossComing.Time.Effect, 0)
        doFadeDismiss(self.infoBg, 'Image', PanelBossComing.Time.Effect, 0)
        doFadeDismiss(self.info, 'Image', PanelBossComing.Time.Effect, 0)
        doFadeDismiss(self.multipleText, 'TextMeshProUGUI', PanelBossComing.Time.Effect, 0)
        doFadeDismiss(self.effect, 'Image', PanelBossComing.Time.Effect, 0, function()
            destroy(self.view)
            self.view = nil
        end)
    end)
end

return PanelBossComing