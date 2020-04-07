-- 获得总点数(牌值)
local function getPoint(card)
    return bit.band(card, 0x0F)
end

-- 获得最小点数
local function getMinPoint(card)
    return bit.band(card, 0xF0) / 16
end

local function getSuit(card)
    return bit.band(card, 0xF0) / 16
end

local function getCount(card)
    return bit.band(card, 0x0F)
end

local CARD_WIDTH      = 65
local CARD_HEIGHT     = 82

local PokerCard = class("PokerCard")

PokerCard.ANIMATION_TIME = 0.2

function PokerCard:ctor(prefab, params)
    self:initView(prefab, params)
end

function PokerCard:initProperties()
    -- 自带属性
    self.cardUint_  = 0x00
    self.cardPoint_ = nil
    self.cardMin_   = 0
    self.cardMax_   = 0
    self.isBack_    = true
    self:showBack()
end


function PokerCard:initView(prefab, params)
    self.view = prefab
    self:initUIControls()
    self.view.name = "PokerCard"
    local parent = UnityEngine.GameObject.Find("Canvas/RoomView")
    if parent then
        self.roomParent = parent
        self.view.transform:SetParent(parent.transform)
        self.view.transform.localScale = Vector3.one
        self.view.transform.localPosition = Vector3.zero
    end    
    self:initProperties()
end

function PokerCard:initUIControls()
    self.backImage      = self.view.transform:Find("backImage").gameObject
    self.frontImage     = self.view.transform:Find("frontImage").gameObject
    self.numberImage    = self.view.transform:Find("frontImage/numberImage").gameObject
    self.smallTypeImage = self.view.transform:Find("frontImage/smallTypeImage").gameObject
    self.bigTypeImage   = self.view.transform:Find("frontImage/bigTypeImage").gameObject
    -- self.frontShadow_ = display.newSprite("room/poker/self/poker_font_shadow.png"):pos(0, 0):addTo(self.frontImage):hide()
end

function PokerCard:setSelfStyle(isSelf)
    if isSelf then
        self.backImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SenceRoom/pokerCard/pokerCard_bg_big")
    else
        self.backImage:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SenceRoom/pokerCard/pokerCard_bg_small")
    end
end

-- 返回server定的牌值
function PokerCard:getCardUnit()
    return self.cardUint_
end

-- 获取当前牌的点数
function PokerCard:getCardPoint()
    return self.cardPoint_
end

-- 设置扑克牌面
function PokerCard:setCard(cardUint)
    self.cardUint_  = cardUint
    self.cardSuit_  = getSuit(cardUint)
    self.cardCount_ = getCount(cardUint)

    -- 确定数字
    local numberName
    if self.cardSuit_ == 0 or self.cardSuit_ == 2 then
        numberName = "Images/SenceRoom/02/"..self.cardCount_
    else
        numberName = "Images/SenceRoom/13/"..self.cardCount_
    end
    self.numberImage:GetComponent('Image').sprite = UIHelper.LoadSprite(numberName)
    -- 确定小花色
    local smallName = "Images/SenceRoom/type/"..self.cardSuit_.."_small"
    self.smallTypeImage:GetComponent('Image').sprite = UIHelper.LoadSprite(smallName)
    
    -- 确定大花色
    local bigName = "Images/SenceRoom/type/"..self.cardSuit_.."_big"
    self.bigTypeImage:GetComponent('Image').sprite = UIHelper.LoadSprite(bigName)

    return self
end

-- 翻牌动画
function PokerCard:flip(flipDoneCallback)
    if not self.isBack_ then
        return
    end
    -- 首先显示牌背，0.5s后开始翻牌动画
    self:showBack()
    self.isBack_ = false
    local rotateTime = PokerCard.ANIMATION_TIME
    local sequenceRotate = DG.Tweening.DOTween.Sequence()
    -- sequenceRotate:SetEase(DG.Tweening.Ease.OutQuint)
    local flipBackAction = self.view.transform:DOLocalRotate(Vector3.New(0,90,0), rotateTime)
    flipBackAction:OnComplete(function()
        hide(self.backImage)
        show(self.frontImage)
    end)
    sequenceRotate:Append(flipBackAction)
    sequenceRotate:Append(self.view.transform:DOLocalRotate(Vector3.New(0,180,0), rotateTime))
    sequenceRotate:OnComplete(function()
        self:showFront()
        if flipDoneCallback then
            flipDoneCallback()
        end
    end)
    return self
end


function PokerCard:flipBack(noSound, flipBackDoneCallback)
    if self.isBack_ then
        return
    end

    self:showFront()
    self.isBack_ = true
    local rotateTime = PokerCard.ANIMATION_TIME
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

function PokerCard:playSoundDelayCall_()
    -- ninek.SoundManager:playSound(ninek.SoundManager.FLIP_CARD)
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    self:showFront_()
end

function PokerCard:showFront_()
    self.view.transform.localEulerAngles = Vector3.New(0, 180, 0)
    show(self.frontImage)
    hide(self.backImage)
end

-- 显示背面
function PokerCard:showBack()
    self.isBack_ = true
    self:showBack_()
end

function PokerCard:showBack_()
    self.view.transform.localEulerAngles = Vector3.New(0, 0, 0)
    show(self.backImage)
    hide(self.frontImage)
end

function PokerCard:isBack()
    return self.isBack_
end


--暗化牌
function PokerCard:addDark()
    self.frontImage:GetComponent('Image').color = Color.New(200/255,200/255,200/255,1)
    self.backImage :GetComponent('Image').color = Color.New(200/255,200/255,200/255,1)
end

-- 移除暗化
function PokerCard:removeDark()
    self.frontImage:GetComponent('Image').color = Color.New(255/255,255/255,255/255,1)
    self.backImage :GetComponent('Image').color = Color.New(255/255,255/255,255/255,1)
end


function PokerCard:resetCard()
    -- 初始数值
    self.cardUint_   = 0x00
    self.cardPoint_  = nil
    self.cardMin_ = 0
    self.cardMax_ = 0
    self:showBack()
    self:removeDark()
end

function PokerCard:destroy()
    destroy(self.view)
    self.view = nil
end

return PokerCard