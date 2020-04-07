local PlayTypeItemView = class("PlayTypeItemView")

PlayTypeItemView.HEIGHT   = 87

function PlayTypeItemView:ctor(prefab, data)
    self.data = data
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas(data)
end

function PlayTypeItemView:initView(prefab)
    self.view = prefab
    self.view.name = "PlayTypeItemView"
end

function PlayTypeItemView:initUIControls()
    self.text          = self.view.transform:Find("Text").gameObject
    self.bottomLine    = self.view.transform:Find("bottomLine").gameObject
    self.selectedImage = self.view.transform:Find("selectedImage").gameObject
    
    hide(self.selectedImage)

    UIHelper.AddButtonClick(self.view, buttonSoundHandler(self, self.onButtonClick))

end

function PlayTypeItemView:initUIDatas(data)
    self.text:GetComponent('Text').text = ""..data.text
end

--[[
    event handle
]]
    
function PlayTypeItemView:onButtonClick()
    if self.buttonAction then
        self.buttonAction(self.data)
    end
end

--[[
    something
]]

function PlayTypeItemView:setButtonClick(action)
    self.buttonAction = action
end

function PlayTypeItemView:setSelected(selected)
    self.selected = selected
    if selected then
        show(self.selectedImage)
    else
        hide(self.selectedImage)
    end
end

function PlayTypeItemView:setIsLastOne(isLast)
    if isLast then
        hide(self.bottomLine)
    else
        show(self.bottomLine)
    end
end

return PlayTypeItemView