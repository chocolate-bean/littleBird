local HistoryChatItemView = class("HistoryChatItemView")


function HistoryChatItemView:ctor(prefab, data)
    self.data = data
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas(data)
end

function HistoryChatItemView:initView(prefab)
    self.view = prefab
    self.view.name = "HistoryChatItemView"
end

function HistoryChatItemView:initUIControls()
    self.headImage = self.view.transform:Find("headImage").gameObject
    self.name      = self.view.transform:Find("name").gameObject
    self.message   = self.view.transform:Find("message").gameObject

    UIHelper.AddButtonClick(self.headImage, buttonSoundHandler(self, function()
        self:onButtonClick()
    end))
end

function HistoryChatItemView:initUIDatas(data)

    --[[
        info.message = message
        info.name = GameManager.UserData.name
        info.header = GameManager.UserData.mavatar
        info.uid = GameManager.UserData.mid
        info.sex = tonumber(GameManager.UserData.msex)
    ]]
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = data.header,
        sex = data.sex,
        node = self.headImage,
        callback = function(sprite)
            if self.view and self.headImage then
                self.headImage:GetComponent('Image').sprite = sprite
            end
        end,
    })
    self.name.transform:GetComponent('Text').text = data.name
    self.message.transform:GetComponent('Text').text = data.message

    self.height = self.message.transform:GetComponent('Text').preferredHeight + 103
    self.view.transform.sizeDelta = Vector2.New(self.view.transform.sizeDelta.x, self.height)
end

function HistoryChatItemView:getHeight()
    return self.height
end

--[[
    event handle
]]
    
function HistoryChatItemView:onButtonClick()
    if self.buttonAction then
        self.buttonAction(self.data)
    end
end

function HistoryChatItemView:setButtonClick(action)
    self.buttonAction = action
end

return HistoryChatItemView