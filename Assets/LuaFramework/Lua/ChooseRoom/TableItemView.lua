local TableItemView = class("TableItemView")

TableItemView.WIDTH  = 483
TableItemView.HEIGHT = 174
TableItemView.SPACINGX = 14

function TableItemView:ctor(prefab, data)
    self.data = data
    self:initView(prefab)
    self:initUIControls()
    self:initUIDatas(data)
end


function TableItemView:initView(prefab)
    self.view = prefab
    self.view.name = "TableItemView"
end

function TableItemView:initUIControls()
    self.button      = self.view.transform:Find("button").gameObject
    self.adviceImage = self.view.transform:Find("button/adviceImage").gameObject
    self.anteText    = self.view.transform:Find("button/anteText").gameObject
    self.peopleText  = self.view.transform:Find("button/peopleImage/Text").gameObject
    self.chipText    = self.view.transform:Find("button/chipImage/Text").gameObject
    hide(self.adviceImage)

    UIHelper.AddButtonClick(self.button, buttonSoundHandler(self, self.onButtonClick))
end

function TableItemView:initUIDatas(data)
    self.peopleText:GetComponent('Text').text = "0"
    self.button:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SenceChooseRoom/ground/choose_room_board_"..data.index)
    self.anteText:GetComponent('Text').text = ""..data.ante
    if data.isAdvice then
        show(self.adviceImage)
    end
    local maxString
    if data.max_limit_money == 0 then
        maxString = "∞"
        --<size=50>นักเที่ยว275</size><size=white>:สวัสดีค่ะ!</color>
    else
        maxString = formatFiveNumber(data.max_limit_money)
    end
    self.chipText:GetComponent('Text').text = string.format("%s/%s", formatFiveNumber(data.min_money), maxString)
end

function TableItemView:updatePeopleCount(data)
    if self.data.level == data.level then
        self.peopleText:GetComponent('Text').text = data.count or 0
    end
end

--[[
    event handle
]]
    
function TableItemView:onButtonClick()
    if self.buttonAction then
        self.buttonAction(self.data)
    end
end

function TableItemView:setButtonClick(action)
    self.buttonAction = action
end

return TableItemView