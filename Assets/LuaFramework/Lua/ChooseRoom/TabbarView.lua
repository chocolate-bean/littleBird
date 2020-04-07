local TabbarView = class("TabbarView")
local TabbarItemView = require("ChooseRoom/TabbarItemView")

function TabbarView:ctor(view, TabbarItemViewPrefab)
    self.TabbarItemViewPrefab = TabbarItemViewPrefab
    self:initView(view)
    self:initUIControls()
end

function TabbarView:initView(view)
    self.view = view
end

function TabbarView:initUIControls()
    self.lightImage  = self.view.transform:Find("lightImage").gameObject
    self.contentView = self.view.transform:Find("Viewport/Content").gameObject
end

function TabbarView:initUIDatas(data)
    
    self.allCount = #data.config
    
    local width = TabbarItemView.WIDTH * self.allCount + TabbarItemView.SPACINGX * (self.allCount - 1)
    
    self.view.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, TabbarItemView.WIDTH * self.allCount + TabbarItemView.SPACINGX * (self.allCount - 1))
    self.view.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, TabbarItemView.HEIGHT)

    -- self.contentView.transform:GetComponent("RectTransform")
    -- :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, TabbarItemView.WIDTH * self.allCount + TabbarItemView.SPACINGX * (self.allCount - 1))
    -- self.contentView.transform:GetComponent("RectTransform")
    -- :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, TabbarItemView.HEIGHT)

    for i, tabbarConfig in ipairs(data.config) do
        tabbarConfig.index = i
        local item = TabbarItemView.new(newObject(self.TabbarItemViewPrefab), tabbarConfig)
        item.view.transform:SetParent(self.contentView.transform)
        item.view.transform.localScale = Vector3.one
        item.view.transform.localPosition = Vector3.zero
        item:setButtonClick(function(data)
            self:onTabbarItemClick(data)
        end)
    end
    -- self:setSelectIndex(data.selectIndex, false)
end

--[[
    event handle
]]

function TabbarView:onTabbarItemClick(data)
    self:setSelectIndex(data.index, true)
end
    
function TabbarView:setSelectIndexChangeCallback(callback)
    self.selectIndexChangeCallback = callback
end

function TabbarView:setSelectIndex(index, isAnimation)

    if self.selectIndex and self.selectIndex == index then
        return
    end

    local mid = self.allCount * 0.5 + 0.5 

    local width = self.view.transform.sizeDelta.x / self.allCount
    local offsetX = (index - mid) * width
    
    local animation = 0
    if isAnimation then
        animation = 0.5
    end
    local moveAction = self.lightImage.transform:DOLocalMoveX(offsetX, animation)
    if isAnimation then
        moveAction:SetEase(DG.Tweening.Ease.OutQuint)
    end

    if self.selectIndexChangeCallback then
        self.selectIndexChangeCallback(index, self.selectIndex)
    end
    self.selectIndex = index
end

return TabbarView