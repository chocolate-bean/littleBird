local TabbarItemView = class("TabbarItemView")

TabbarItemView.WIDTH    = 229
TabbarItemView.HEIGHT   = 55
TabbarItemView.SPACINGX = 0

function TabbarItemView:ctor(prefab, data)
    self.data = data
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas(data)
end

function TabbarItemView:initView(prefab)
    self.view = prefab
    self.view.name = "TabbarItemView"
end

function TabbarItemView:initUIControls()
    self.text = self.view.transform:Find("Text").gameObject

    UIHelper.AddButtonClick(self.view, buttonSoundHandler(self, self.onButtonClick))

end

function TabbarItemView:initUIDatas(data)
    self.text:GetComponent('Text').text = ""..data.text
end

--[[
    event handle
]]
    
function TabbarItemView:onButtonClick()
    if self.buttonAction then
        self.buttonAction(self.data)
    end
end

function TabbarItemView:setButtonClick(action)
    self.buttonAction = action
end

return TabbarItemView