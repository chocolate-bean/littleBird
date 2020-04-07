local SlotsItemView = class("SlotsItemView")

SlotsItemView.WIDTH  = 173 * 0.75 --129.75
SlotsItemView.HEIGHT = 155 * 0.75 --116.25
SlotsItemView.SPACINGX = 14

SlotsItemView.FRUIT_NAME_CONFIG = {
    "SGKH_SG_xiangjiao",        --香蕉
    "SGKH_SG_xigua",            --西瓜
    "SGKH_SG_ningmeng",         --柠檬
    "SGKH_SG_putao",            --葡萄
    "SGKH_SG_juzi",             --蓝色的
    "SGKH_SG_sz",               --铃铛
    "SGKH_SG_yingtao",          --樱桃
    "SGKH_SG_caomei",           --bar
    "SGKH_SG_7",                --7
    "SGKH_SG_scatter",          --bonus
    "SGKH_SG_wild",             --章鱼
}

SlotsItemView.SCALE_TIME = 0.3

function SlotsItemView:ctor(prefab)
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas()
end

function SlotsItemView:initView(prefab)
    self.view = prefab
    self.view.name = "SlotsItemView"
end

function SlotsItemView:initUIControls()
    self.highlightImage = self.view.transform:Find("highlightImage").gameObject
    self.fruitImage     = self.view.transform:Find("fruitImage").gameObject

    self:setHighlight(false)
end

function SlotsItemView:initUIDatas()
    
end

function SlotsItemView:setData(data)
    if data then
        local index = data.index
        local imageName = SlotsItemView.FRUIT_NAME_CONFIG[index]
        self.fruitImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/"..imageName)
    else
        hide(self.fruitImage)
    end
end

function SlotsItemView:setHighlight(isHighlight, feeType)
    if self.highlightAnimation then
        self.highlightAnimation:Kill()
    end
    if feeType then
        self.highlightImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/SGKH_QT_win")
    else
        self.highlightImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/PanelSlots/SGKH_zjk")
    end

    self.highlightImage.transform.localScale = Vector3.one
    if isHighlight then
        self:startHighlightAnimation()
        show(self.highlightImage)
    else
        hide(self.highlightImage)
    end
end

function SlotsItemView:startHighlightAnimation()
    local scale = 1.1
    self.highlightAnimation = self.highlightImage.transform:DOScale(Vector3.New(scale, scale, scale), SlotsItemView.SCALE_TIME)
    self.highlightAnimation:SetEase(DG.Tweening.Ease.Linear)
    self.highlightAnimation:SetLoops(999, DG.Tweening.LoopType.Yoyo)
end

return SlotsItemView