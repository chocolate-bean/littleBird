local PanelFKBYBossComing = class("PanelFKBYBossComing")

function PanelFKBYBossComing:ctor(fishType)
    resMgr:LoadPrefabByRes("FishingGame/Other", { tostring(fishType) }, function(objs)
        self:initView(objs, fishType)
    end)
end

function PanelFKBYBossComing:initView(objs, fishType)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFKBYBossComing"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self:initProperties(fishType)
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFKBYBossComing:initProperties(fishType)
    self.fishType = fishType
end

function PanelFKBYBossComing:initUIControls()
    self.blood        = self.view:findChild("blood")
end

function PanelFKBYBossComing:initUIDatas()
end

function PanelFKBYBossComing:showAnimation()
    -- 1.1 先是blood
    show(self.blood)
    self.blood.transform.localScale = Vector3.New(1, 1, 1)
    local scaleAnimation = self.blood.transform:DOScale(Vector3.New(1.1, 1.1, 1.1), 0.6)
    scaleAnimation:SetEase(DG.Tweening.Ease.Linear)
    scaleAnimation:SetLoops(3.5/0.6, DG.Tweening.LoopType.Yoyo)

    Timer.New(function()
        self:onClose()
    end, 3.5, 1, true):Start()
end

function PanelFKBYBossComing:show()
    GameManager.PanelManager:addPanel(self, false)
    self:showAnimation()
end

function PanelFKBYBossComing:onClose()
    GameManager.PanelManager:removePanel(self, nil, function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFKBYBossComing