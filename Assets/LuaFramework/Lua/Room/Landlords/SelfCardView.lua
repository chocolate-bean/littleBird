local SelfCardView  = class("SelfCardView")
local LandlordsCard = require("Room.Landlords.LandlordsCard")

SelfCardView.WIDTH        = LandlordsCard.Size.HandCard.Width
SelfCardView.HEIGHT       = LandlordsCard.Size.HandCard.Height
SelfCardView.SPACINGX     = 68
SelfCardView.SPACINGX_MIN = 58
SelfCardView.SPACINGY     = 22.4

SelfCardView.SELECTED_VECTOR = Vector3.New(0, SelfCardView.SPACINGY, 0)
SelfCardView.NORMAL_VECTOR   = Vector3.zero

-- SelfCardView.MASK_COLOR   = Color.New(200/255.0,200/255.0,200/255.0,1)
-- SelfCardView.NORMAL_COLOR = Color.New(255/255.0,255/255.0,255/255.0,1)

SelfCardView.STATUS = {
    NONE     = 0,
    IN_PILE  = 1, -- 在牌堆
    IN_HAND  = 2,
    IN_TABLE = 3,
    IN_DROP  = 4,
}

function SelfCardView:ctor(prefab, params)
    self:initView(prefab, params)
end

function SelfCardView:initProperties()
   self.status = SelfCardView.STATUS.NONE
   self.isSelected = false
end

function SelfCardView:initView(prefab, params)
    self.view = prefab
    self.data = params
    self.view.name = "SelfCardView"..(self.data.index or 0)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero  
    self:initProperties()
    self:initUIControls()
    self:initUIData()
end

function SelfCardView:initUIControls()
    self.background     = self.view.transform:Find("Background").gameObject
    self.landlordsCard  = LandlordsCard.new(self.view.transform:Find("Background/LandlordsCard").gameObject)
    self.landlordsCard:setCardType(LandlordsCard.CardType.Hand_nongmin)
    self.view:GetComponent('Toggle').interactable = false
    UIHelper.AddToggleClick(self.view, function(sender)
        GameManager.SoundManager:PlaySoundWithNewSource("landlords/selectCard")
        self:onSelfToggleValueChange(sender)
    end)
end

function SelfCardView:initUIData()
    self.view:GetComponent('Toggle').isOn = false

    self.index = self.data.index
    self:setStatus(self.data.status)
end

--[[
    public method
]]

function SelfCardView:resetIndex(index)
    self.index = index
    self.view.name = "SelfCardView"..(self.index or 0)
end


function SelfCardView:setSelected(isSelected)

    if self.isSelected == isSelected then
        return
    end

    self.isSelected = isSelected
    if isSelected then
        self.landlordsCard:addDark()
    else
        self.landlordsCard:removeDark()
    end
end

function SelfCardView:setCard(cardUnit)
    self.landlordsCard:setCard(cardUnit)
end

function SelfCardView:getCard()
    return self.landlordsCard:getCard()
end

function SelfCardView:setCardType(cardType)
    self.landlordsCard:setCardType(cardType)
end

--[[
    event handle
]]

function SelfCardView:onSelfToggleValueChange(sender)
    if sender:GetComponent('Toggle').isOn then
        self.landlordsCard.view.transform.localPosition = SelfCardView.SELECTED_VECTOR
    else
        self.landlordsCard.view.transform.localPosition = SelfCardView.NORMAL_VECTOR
    end
end


function SelfCardView:setStatus(status)
    self.status = status
    if self.status == SelfCardView.STATUS.IN_PILE then
        hide(self.view)
    elseif self.status == SelfCardView.STATUS.IN_HAND then
        show(self.view)
    elseif self.status == SelfCardView.STATUS.IN_TABLE then
        show(self.view)
    elseif self.status == SelfCardView.STATUS.IN_DROP then
        hide(self.view)
    end
end

return SelfCardView