local LandlordsCard = class("LandlordsCard")
local Card          = require("Room.Landlords.Card")

LandlordsCard.ANIMATION_TIME = 0.2

LandlordsCard.MASK_COLOR   = Color.New(200/255.0,200/255.0,200/255.0,1)
LandlordsCard.NORMAL_COLOR = Color.New(255/255.0,255/255.0,255/255.0,1)

LandlordsCard.ImagePath = "Images/SceneLandlords/poker/"

LandlordsCard.Size = {
    HandCard = {
        Width  = 162,
        Height = 214,
    },
    TableCard = {
        Width  = 80,
        Height = 102,
    },
    CoveCard  = {
        Width  = 50,
        Height = 64,
    },
}


LandlordsCard.CardType = {
    Cover         = 1,
    Cover_show    = 2,
    Table_dizhu   = 3,
    Table_nongmin = 4,
    Hand_dizhu    = 5,
    Hand_nongmin  = 6,
}

LandlordsCard.WIDTH  = LandlordsCard.Size.TableCard.Width
LandlordsCard.HEIGHT = LandlordsCard.Size.TableCard.Height
LandlordsCard.SPACINGX = 38

function LandlordsCard:ctor(prefab, params)
    self:initView(prefab, params)
end

function LandlordsCard:initView(prefab, params)
    self.view = prefab
    self:initUIControls()
    self:initProperties()
end

function LandlordsCard:initProperties()
    -- 自带属性
    self.cardType   = nil
    self.cardUint_  = 0x00
    self.cardPoint_ = nil
    self.cardMin_   = 0
    self.cardMax_   = 0
    self.isBack_    = true
    self:showBack()
end

function LandlordsCard:initUIControls()
    self.backImage      = self.view.transform:Find("backImage").gameObject
    self.frontImage     = self.view.transform:Find("frontImage").gameObject
    self.numberImage    = self.view.transform:Find("frontImage/numberImage").gameObject
    self.jokerImage     = self.view.transform:Find("frontImage/jokerImage").gameObject
    self.smallTypeImage = self.view.transform:Find("frontImage/numberImage/smallTypeImage").gameObject
    self.bigTypeImage   = self.view.transform:Find("frontImage/bigTypeImage").gameObject
    self.landlordsImage = self.view.transform:Find("frontImage/landlordsImage").gameObject
end

-- 设置扑克牌面
function LandlordsCard:setCard(cardUint)

    self.card = Card.new(cardUint)
    self.cardUint_  = cardUint
    self.cardSuit_  = self.card.suit
    self.cardCount_ = self.card.count

    if self.cardCount_ >= 14 then
        -- 为大小王
        self.jokerImage:GetComponent('Image').sprite = UIHelper.LoadSprite(self.card.imagePaths.joker)
        hide(self.numberImage)
        show(self.jokerImage)
        if self.cardType == LandlordsCard.CardType.Table_dizhu
        or self.cardType == LandlordsCard.CardType.Table_nongmin
        or self.cardType == LandlordsCard.CardType.Cover
        or self.cardType == LandlordsCard.CardType.Cover_show then
            show(self.bigTypeImage)
            hide(self.smallTypeImage)
        end
    else
        self.numberImage:GetComponent('Image').sprite = UIHelper.LoadSprite(self.card.imagePaths.number)
        show(self.numberImage)
        hide(self.jokerImage)
        if self.cardType == LandlordsCard.CardType.Table_dizhu
        or self.cardType == LandlordsCard.CardType.Table_nongmin
        or self.cardType == LandlordsCard.CardType.Cover
        or self.cardType == LandlordsCard.CardType.Cover_show then
            hide(self.bigTypeImage)
            show(self.smallTypeImage)
        end
    end
    
    self.smallTypeImage:GetComponent('Image').sprite = UIHelper.LoadSprite(self.card.imagePaths.small)
    self.bigTypeImage:GetComponent('Image').sprite = UIHelper.LoadSprite(self.card.imagePaths.big)
    self.bigTypeImage:GetComponent('Image'):SetNativeSize()
    return self
end

--[[
    对应的类型
]]

function LandlordsCard:setCardType(cardType)

    if self.cardType and self.cardType == cardType then
        return
    else
        self.cardType = cardType
    end

    if cardType == LandlordsCard.CardType.Cover then
        self:showBack()

    elseif cardType == LandlordsCard.CardType.Cover_show then
        show({self.bigTypeImage})
        hide({self.smallTypeImage, self.landlordsImage})

    elseif cardType == LandlordsCard.CardType.Table_dizhu then
        show({self.numberImage, self.smallTypeImage, self.landlordsImage, self.bigTypeImage})
        self:showFront()
    elseif cardType == LandlordsCard.CardType.Table_nongmin then
        show({self.numberImage, self.smallTypeImage, self.bigTypeImage})
        hide({self.landlordsImage})
        self:showFront()
    elseif cardType == LandlordsCard.CardType.Hand_dizhu then
        show({self.numberImage, self.bigTypeImage, self.smallTypeImage, self.landlordsImage})
        self:showFront()
    elseif cardType == LandlordsCard.CardType.Hand_nongmin then
        show({self.numberImage, self.bigTypeImage, self.smallTypeImage})
        hide({self.landlordsImage})
        self:showFront()
    end
    -- 重置大小王这些
    if self.cardUint_ ~= 0x00 then
        self:setCard(self.cardUint_)
    end
end

function LandlordsCard:getCard()
    return self.cardUint_ or 0
end


-- 翻牌动画
function LandlordsCard:flip(flipDoneCallback)
    if not self.isBack_ then
        return
    end
    -- 首先显示牌背，0.5s后开始翻牌动画
    self:showBack()
    self.isBack_ = false
    local rotateTime = LandlordsCard.ANIMATION_TIME
    local sequenceRotate = DG.Tweening.DOTween.Sequence()
    -- sequenceRotate:SetEase(DG.Tweening.Ease.OutQuint)
    local flipBackAction = self.view.transform:DOLocalRotate(Vector3.New(0,90,0), rotateTime)
    flipBackAction:OnComplete(function()
        hide(self.backImage)
        show(self.frontImage)
    end)
    sequenceRotate:Append(flipBackAction)
    sequenceRotate:Append(self.view.transform:DOLocalRotate(Vector3.New(0,0,0), rotateTime))
    sequenceRotate:OnComplete(function()
        self:showFront()
        if flipDoneCallback then
            flipDoneCallback()
        end
    end)
    return self
end


function LandlordsCard:flipBack(noSound, flipBackDoneCallback)
    if self.isBack_ then
        return
    end

    self:showFront()
    self.isBack_ = true
    local rotateTime = LandlordsCard.ANIMATION_TIME
    local sequenceRotate = DG.Tweening.DOTween.Sequence()
    -- sequenceRotate:SetEase(DG.Tweening.Ease.OutQuint)
    local flipBackAction = self.view.transform:DOLocalRotate(Vector3.New(0,270,0), rotateTime)
    flipBackAction:OnComplete(function()
        hide(self.frontImage)
        show(self.backImage)
    end)
    sequenceRotate:Append(flipBackAction)
    sequenceRotate:Append(self.view.transform:DOLocalRotate(Vector3.New(0,360,0), rotateTime))
    sequenceRotate:OnComplete(function()
        self:showBack()
        if flipBackDoneCallback then
            flipBackDoneCallback()
        end
    end)
    return self
end

-- 显示正面
function LandlordsCard:showFront()
    self.isBack_ = false
    self:showFront_()
end

function LandlordsCard:showFront_()
    self.view.transform.localEulerAngles = Vector3.New(0, 0, 0)
    show(self.frontImage)
    hide(self.backImage)
end

-- 显示背面
function LandlordsCard:showBack()
    self.isBack_ = true
    self:showBack_()
end

function LandlordsCard:showBack_()
    self.view.transform.localEulerAngles = Vector3.New(0, 180, 0)
    show(self.backImage)
    hide(self.frontImage)
end

function LandlordsCard:isBack()
    return self.isBack_
end

--暗化牌
function LandlordsCard:addDark()
    self.frontImage    :GetComponent('Image').color = LandlordsCard.MASK_COLOR
    self.backImage     :GetComponent('Image').color = LandlordsCard.MASK_COLOR
    self.numberImage   :GetComponent('Image').color = LandlordsCard.MASK_COLOR
    self.smallTypeImage:GetComponent('Image').color = LandlordsCard.MASK_COLOR
    self.bigTypeImage  :GetComponent('Image').color = LandlordsCard.MASK_COLOR
    
end

-- 移除暗化
function LandlordsCard:removeDark()
    self.frontImage    :GetComponent('Image').color = LandlordsCard.NORMAL_COLOR
    self.backImage     :GetComponent('Image').color = LandlordsCard.NORMAL_COLOR
    self.numberImage   :GetComponent('Image').color = LandlordsCard.NORMAL_COLOR
    self.smallTypeImage:GetComponent('Image').color = LandlordsCard.NORMAL_COLOR
    self.bigTypeImage  :GetComponent('Image').color = LandlordsCard.NORMAL_COLOR
end


function LandlordsCard:resetCard()
    
end

function LandlordsCard:destroy()
    
end

return LandlordsCard