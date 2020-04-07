local PanelManager = class("PanelManager")

function PanelManager:ctor()
    -- self.parent = UnityEngine.GameObject.Find("Canvas")
    resMgr:LoadPrefabByRes("Common", { "PanelMask" }, function(objs)
        self:initMask(objs)
    end)

    self:initProperties()
end

function PanelManager:initProperties()
    -- 活动中的Panel列表
    self.panelList = {}
    Event.AddListener(EventNames.RETURN_CLICK,handler(self,self.onReturnKeyClick))
end

function PanelManager:initMask(objs)
    
    self.maskPrefab = objs[0] -- UnityEngine.GameObject.Instantiate(objs[0])
end

function PanelManager:onClean()
    -- 写了也没意义
    -- 一辈子不会调用的
    Event.RemoveListener(EventNames.RETURN_CLICK)
end

-- 在我看来只需要是否遮罩和动画类型就可以
-- 默认动画类型为空，即直接闪现出来
-- 遮罩始终应该只有一个，只是需要设置他的zOrder
function PanelManager:addPanel(viewOwner,isMask,animType,callback)
    local parent = UnityEngine.GameObject.Find("Canvas")
    
    if isMask then
        -- 如果当前Sence下没有Mask，那么挂载一个Mask控件到Canvas下
        if UnityEngine.GameObject.Find("Mask") == nil then
            self.mask = UnityEngine.GameObject.Instantiate(self.maskPrefab)
            self.mask.name = "Mask"
            self.mask.transform:SetParent(parent.transform)
            self.mask.transform.localScale = Vector3.one
            self.mask.transform.localPosition = Vector3.zero
            
            local parent = UnityEngine.GameObject.Find("Canvas")
            local count = parent.transform.childCount
            self.mask.transform:SetSiblingIndex(count - 1)
            
            self.mask:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
            self.mask:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
            
            UIHelper.AddButtonClick(self.mask, function()
                -- self:removePanel(viewOwner,animType)
                -- viewOwner = nil
                if viewOwner.onClose then
                    viewOwner:onClose()
                end
            end)
        end
        
        local count = parent.transform.childCount
        self.mask.transform:SetSiblingIndex(count - 1)
    end
    
    viewOwner.view.transform:SetParent(parent.transform)
    local parent = UnityEngine.GameObject.Find("Canvas")
    local count = parent.transform.childCount
    viewOwner.view.transform:SetSiblingIndex(count - 1)
    
    -- 根据animType处理Panel显示的动画
    if animType == nil or animType == 0 then
        viewOwner.view.transform.localScale = Vector3.one
        viewOwner.view.transform.localPosition = Vector3.zero
    else
        viewOwner.animType = animType
        GameManager.AnimationManager:addPanelShowAnimation(viewOwner.view, animType, callback)
    end
    viewOwner.panelManagerIndex = #self.panelList + 1
    self.panelList[#self.panelList + 1] = viewOwner
    self.panelList[#self.panelList].name = viewOwner.__cname
end

-- 移除Panel
-- 注意遮罩的处理，这里其实是有问题的，只适用于所有有遮罩的panel
-- 无遮罩的panel建议自行处理显示
function PanelManager:removePanel(viewOwner, animType, completeCallback, mask)
    animType = animType or viewOwner.animType
    if animType then
        GameManager.AnimationManager:addPanelDismissAnimation(viewOwner.view, animType, function()
            -- 这里做一个容错的处理，防止同时或者先后移除相同的panel
            if self.panelList[viewOwner.panelManagerIndex] then
                self.panelList[viewOwner.panelManagerIndex] = nil
            end
            if completeCallback then
                completeCallback()
            end
        end)
    else
        if self.panelList[viewOwner.panelManagerIndex] then
            self.panelList[viewOwner.panelManagerIndex] = nil
        end
        if completeCallback then
            completeCallback()
        end
    end

    destroy(self.mask)
end

-- 隐藏Panel
function PanelManager:hidePanel(viewOwner, animType)
    if self.panelList[viewOwner.panelManagerIndex] then
        self.panelList[viewOwner.panelManagerIndex] = nil
    end
    if animType then
        GameManager.AnimationManager:addPanelDismissAnimation(viewOwner.view, animType, function()
        end)
    else
        hide(viewOwner.view)
    end
    destroy(self.mask)
end

function PanelManager:removeMask()
    
    local parent = UnityEngine.GameObject.Find("Canvas")
    local count = parent.transform.childCount
    local index = self.mask.transform:GetSiblingIndex()
    
    if index > 4 then
        self.mask.transform:SetSiblingIndex(index - 1)
    end

    -- 如果遮罩层级为最上层，则需要置于最下层
    if index <= 4 then
        self.mask.transform:SetSiblingIndex(0)
    end
end

-- 移除全部Panel
function PanelManager:removeAllPanel()
    
    for i,v in ipairs(self.panelList) do
        self:removePanel(v)
    end
end

-- 暂停（隐藏）所有Panel
function PanelManager:pauseAllPanel()
    
    for i,v in ipairs(self.panelList) do
        v:SetActive(false)
    end
end

-- 恢复所有Panel
function PanelManager:resumeAllPanel()
    
    for i,v in ipairs(self.panelList) do
        v:SetActive(true)
    end
end

function PanelManager:onReturnKeyClick()
    print("点击了返回键！")
    if self.panelList and #self.panelList > 0 then
        print("有panel")
        if self.panelList[#self.panelList].onClose then
            self.panelList[#self.panelList]:onClose()
            self.panelList = {}
        end
    else
        print("无panel")
        GameManager:onReturnKeyClick()
    end
end

return PanelManager