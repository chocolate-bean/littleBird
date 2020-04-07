local LandlordsCardsGroup  = class("LandlordsCardsGroup")
local LandlordsCard = require("Room.Landlords.LandlordsCard")

function LandlordsCardsGroup:ctor(prefab, params)
    self:initView(prefab, params)
end

function LandlordsCardsGroup:initProperties()
   self.status = LandlordsCardsGroup.STATUS.NONE
   self.isSelected = false
end

function LandlordsCardsGroup:initView(prefab, params)
    self.view = prefab
    self.data = params
    self.view.name = "LandlordsCardsGroup"..(self.data.index or 0)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero  
    self:initProperties()
    self:initUIControls()
    self:initUIData()
end

function LandlordsCardsGroup:initUIControls()
    
end

function LandlordsCardsGroup:initUIData()
    
end

return LandlordsCardsGroup