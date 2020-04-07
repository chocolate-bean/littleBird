local ColumnScrollView = class("ColumnScrollView")

ColumnScrollView.WIDTH  = 173
ColumnScrollView.HEIGHT = 376.75

ColumnScrollView.INTERVAL_TIME = 0.3

function ColumnScrollView:ctor(view, ItemViewPrefab, ItemViewClass)
    self.ItemViewClass  = ItemViewClass
    self.ItemViewPrefab = ItemViewPrefab
    self:initProperties()
    self:initView(view)
    self:initUIControls()    
end

function ColumnScrollView:initProperties()
    self.items = {}
    self.needStop = false
end

function ColumnScrollView:initView(view)
    self.view = view
end

function ColumnScrollView:initUIControls()
    self.contentView = self.view.transform:Find("Content").gameObject
end

function ColumnScrollView:initUIDatas(data)
 
end

function ColumnScrollView:onCleanUp()
    self:removeListener()
end

function ColumnScrollView:Update()
    local rect = self.view:GetComponent('ScrollRect')
    if rect.verticalNormalizedPosition > 1 then
        rect.verticalNormalizedPosition = 0
        self:changeRandomItem()
        if self.needStop then
            self:changeLastItem()
            self:removeListener()
            self:scrollToIndex(#self.items - 3, function()
                if self.stopCallback then
                    self.stopCallback()
                end
            end)
            return
        end
    end
    rect.verticalNormalizedPosition = rect.verticalNormalizedPosition + 0.005 * #self.items
end

--[[
    私有方法
]]

function ColumnScrollView:removeListener()
    if self.updateHandle then
        UpdateBeat:RemoveListener(self.updateHandle)
    end
end

-- 水果机
function ColumnScrollView:changeRandomItem()
    -- 只要更换中间的 头三个和尾三个不用更换
    -- for i = 3, #self.items - 3 do
    --     self.items[i]:setData({index = math.random(11)})
    -- end
    for i = 1, #self.items do
        self.items[i]:setData({index = math.random(11)})
    end
end

function ColumnScrollView:changeLastItem()
    -- for i = #self.items - #self.data, #self.items do
    --     local item = self.items[i]
    --     local index = #self.items + i
    -- end
    local lastCount = #self.data
    for i = 1, lastCount do
        local singleData = self.data[i]
        local index = #self.items - lastCount + i - 1
        local item = self.items[index]
        item:setData(singleData)
    end
end

--[[
    外部调用方法
]]

function ColumnScrollView:addItem()
    local item = self.ItemViewClass.new(newObject(self.ItemViewPrefab), nil)
    item.view.transform:SetParent(self.contentView.transform)
    item.view.transform.localScale = Vector3.one
    item.view.transform.localPosition = Vector3.zero
    self.items[#self.items + 1] = item
    return item
end

function ColumnScrollView:startScrollLoop()
    self.needStop = false
    if not self.updateHandle then
        self.updateHandle = UpdateBeat:CreateListener(self.Update, self)
        UpdateBeat:AddListener(self.updateHandle)
    elseif self.updateHandle.removed then
        UpdateBeat:AddListener(self.updateHandle)
    end
end


function ColumnScrollView:stopScrollLoopWithData(data, stopCallback)
    self.needStop = true
    self.data = data
    self.stopCallback = stopCallback
end

function ColumnScrollView:setContentSize()
    local childCount = self.contentView.transform.childCount
    self.contentView.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, ColumnScrollView.WIDTH)
    self.contentView.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, self.ItemViewClass.HEIGHT * childCount + self.ItemViewClass.SPACINGX * (childCount - 1))
end

function ColumnScrollView:scrollToIndex(index, completeCallback)
    self:setContentSize()
    local offsetY = (self.ItemViewClass.HEIGHT + self.ItemViewClass.SPACINGX) * (index - 1)
    local animation = 1
    local moveAction = self.contentView.transform:DOLocalMoveY(offsetY + ColumnScrollView.HEIGHT * 0.5, animation) 
    moveAction:SetEase(DG.Tweening.Ease.OutBack)
    moveAction:OnComplete(function()
        if completeCallback then
            completeCallback()
        end
    end)
end


--[[
    event handle
]]


return ColumnScrollView