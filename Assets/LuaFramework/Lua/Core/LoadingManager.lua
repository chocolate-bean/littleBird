local LoadingManager = class("LoadingManager")

function LoadingManager:ctor()
    -- self.parent = UnityEngine.GameObject.Find("Canvas")
    resMgr:LoadPrefabByRes("Common", { "PanelLoading" }, function(objs)
        self:initPanelLoading(objs)
    end)
end

function LoadingManager:initPanelLoading(objs)
    
    self.panelLoadingPrefab = objs[0]
end

function LoadingManager:setLoading(isLoading,panel)
    
    if isLoading then
        self:createLoading(panel)
    else
        self:destroyLoading(panel)
    end
end

function LoadingManager:createLoading(panel)
    
    local parent = panel
    local panelLoading = panel.transform:Find("PanelLoading")

    if panelLoading == nil then
        panelLoading = UnityEngine.GameObject.Instantiate(self.panelLoadingPrefab)
        panelLoading.name = "PanelLoading"
        
        local canvas = UnityEngine.GameObject.Find("Canvas")
        panelLoading.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, canvas.transform.sizeDelta.x)
        panelLoading.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, canvas.transform.sizeDelta.y)
        panelLoading.transform:SetParent(parent.transform)

        panelLoading.transform.localScale = Vector3.one
        panelLoading.transform.localPosition = Vector3.zero
    end

    local count = parent.transform.childCount
    panelLoading.transform:SetSiblingIndex(count - 1)
end

function LoadingManager:destroyLoading(panel)
    
    local panelLoading = panel.transform:Find("PanelLoading")
    if panelLoading then
        destroy(panelLoading.gameObject)
    end
end

return LoadingManager