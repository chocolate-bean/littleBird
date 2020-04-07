local EmojiGroupItemView = class("EmojiGroupItemView")

EmojiGroupItemView.WIDTH    = 544
EmojiGroupItemView.HEIGHT   = 133

EmojiGroupItemView.COUNT   = 5

function EmojiGroupItemView:ctor(prefab, data)
    self.data = data
    self.height = self.HEIGHT
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas()
end

function EmojiGroupItemView:initView(prefab)
    self.view = prefab
    self.view.name = "EmojiGroupItemView"
    self.emojiGrops = {}
end

function EmojiGroupItemView:initUIControls()

    for index = 1, EmojiGroupItemView.COUNT do
        local obj = self.view.transform:Find("EmojiItem_"..index).gameObject
        local button = obj.transform:Find("Button").gameObject
        self.emojiGrops[#self.emojiGrops + 1] = obj
        UIHelper.AddButtonClick(button, buttonSoundHandler(self, function()
            self:onButtonClick(index)
        end))
    end
end

function EmojiGroupItemView:initUIDatas(data)
    for index, item in ipairs(self.emojiGrops) do
        local button = item.transform:Find("Button").gameObject
        if index > #self.data then
            hide(button)
        else
            local type  = self.data[index].type
            local index = self.data[index].index
            button.transform:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/Interactive/emojiPreview/emoji_"..type.."_"..index)
            button.transform:GetComponent('Image'):SetNativeSize()
        end
    end
end

--[[
    event handle
]]
    
function EmojiGroupItemView:onButtonClick(index)
    if self.buttonAction then
        self.buttonAction(self.data[index])
    end
end

function EmojiGroupItemView:setButtonClick(action)
    self.buttonAction = action
end

return EmojiGroupItemView