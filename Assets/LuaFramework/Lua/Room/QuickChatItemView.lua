local QuickChatItemView = class("QuickChatItemView")

QuickChatItemView.WIDTH    = 544
QuickChatItemView.HEIGHT   = 82

function QuickChatItemView:ctor(prefab, data)
    self.data = data
    self.height = self.HEIGHT
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas(data)
end

function QuickChatItemView:initView(prefab)
    self.view = prefab
    self.view.name = "QuickChatItemView"
end

function QuickChatItemView:initUIControls()
    self.text = self.view.transform:Find("Text").gameObject

    UIHelper.AddButtonClick(self.view, buttonSoundHandler(self, self.onButtonClick))

end

function QuickChatItemView:initUIDatas(data)
    self.text.transform:GetComponent('Text').text = data.text
end

--[[
    event handle
]]
    
function QuickChatItemView:onButtonClick()
    if self.buttonAction then
        self.buttonAction(self.data)
    end
end

function QuickChatItemView:setButtonClick(action)
    self.buttonAction = action
end

return QuickChatItemView