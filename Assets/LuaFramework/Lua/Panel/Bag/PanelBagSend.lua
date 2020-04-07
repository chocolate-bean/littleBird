local BasePanel = require("Panel.BasePanel").new()
local PanelBagSend = class("PanelBagSend", BasePanel)

function PanelBagSend:ctor(data)
    self.data = data
    self.type = "Bag"
    self.prefabs = { "PanelBagSend", "PlayItem" }
    self:init()
end

function PanelBagSend:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelBagSend"

    self.item = objs[1]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelBagSend:initProperties()
    self.friendLights = {}
    self.curPropNum = 0
    self.curSelectMid = nil
end

function PanelBagSend:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.btnFriend = self.view.transform:Find("btnFriend").gameObject
    self.btnFriend:addButtonClick(function()
        self:onBtnFriendClick()
    end)

    self.btnSearch = self.view.transform:Find("btnSearch").gameObject
    self.btnSearch:addButtonClick(function()
        self:onBtnSearchClick()
    end)
    if isMZBY() or isDBBY() then
        self.light = self.view:findChild("tabBg/tabLight")
        self.searchText = self.btnSearch.transform:Find("Text").gameObject
        self.friendText = self.btnFriend.transform:Find("Text").gameObject
    else
        self.searchLight = self.btnSearch.transform:Find("btnLight").gameObject
        self.friendLight = self.btnFriend.transform:Find("btnLight").gameObject
    end

    self.PanelFriend = self.view.transform:Find("PanelFriend").gameObject
    self.PanelSearch = self.view.transform:Find("PanelSearch").gameObject

    self.icon = self.view.transform:Find("PanelRight/prop1/icon").gameObject
    self.Name = self.view.transform:Find("PanelRight/Name").gameObject
    self.Num = self.view.transform:Find("PanelRight/Num").gameObject
    self.SendNum = self.view.transform:Find("PanelRight/SendNum").gameObject

    self.btnSub = self.view.transform:Find("PanelRight/btnSub").gameObject
    self.btnSub:addButtonClick(function()
        self:changePropNum(false)
    end)
    self.btnAdd = self.view.transform:Find("PanelRight/btnAdd").gameObject
    self.btnAdd:addButtonClick(function()
        self:changePropNum(true)
    end)
    self.btnGoto = self.view.transform:Find("PanelRight/btnGoto").gameObject
    self.btnGoto:addButtonClick(function()
        self:onBtnGotoClick()
    end)

    self.searchItem = self.view.transform:Find("PanelSearch/PlayItem").gameObject
    self.input = self.view.transform:Find("PanelSearch/input").gameObject:GetComponent('InputField')
    self.btnSearch = self.view.transform:Find("PanelSearch/btnSearch").gameObject
    self.btnSearch:addButtonClick(function()
        self:onSearchClick()
    end)
end

function PanelBagSend:initUIDatas()
    local imgurl = self.data.pic
    GameManager.ImageLoader:loadAndCacheImage(imgurl,function (success, sprite)
        if success and sprite then
            if self.view then
                self.icon:setSprite(sprite)
            end
        end
    end)
    self.Name:setText(self.data.name)
    self.Num:setText(T("剩余：")..self.data.num)
    self.SendNum:setText(self.curPropNum)

    self:onBtnFriendClick()
    self:GetList()
end

function PanelBagSend:changePropNum(isAdd)
    if isAdd then
        self.curPropNum = self.curPropNum + 1
        if self.curPropNum > tonumber(self.data.num) then
            self.curPropNum = self.data.num
        end
    else
        self.curPropNum = self.curPropNum - 1
        if self.curPropNum < 0 then
            self.curPropNum = 0
        end
    end

    self.SendNum:setText(self.curPropNum)
end

function PanelBagSend:onBtnGotoClick()
    if self.curPropNum == 0 then 
        GameManager.TopTipManager:showTopTip(T("请选择道具数量"))
    elseif self.curSelectMid == nil then
        GameManager.TopTipManager:showTopTip(T("请选择好友"))
    else
        print(self.curSelectMid)
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("您将赠送"..self.curPropNum.."个"..self.data.name),
            firstButtonCallbcak = function()
                self:onClose()
                self:SendProp()
            end,
        })
    end
end

function PanelBagSend:SendProp()
    http.sendToOther(
        self.curSelectMid,
        self.data.pid,
        self.curPropNum,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("赠送成功"))
            else
                GameManager.TopTipManager:showTopTip(T("赠送失败"))
            end
        end,
        function(callData)
        end
    )
end

function PanelBagSend:onBtnFriendClick()
    if isMZBY() or isDBBY() then
        self.light.transform.localPosition = Vector3.New(-159.5, self.light.transform.localPosition.y, 0)
        self.searchText.transform:GetComponent('Text').color = Color.white;
        self.friendText.transform:GetComponent('Text').color = Color.New(164/255, 10/255, 10/255);
    else
        
        self.friendLight:SetActive(true)
        self.searchLight:SetActive(false)
    end
    self.PanelFriend:SetActive(true)
    self.PanelSearch:SetActive(false)
    self:onChangeBtn()
end

function PanelBagSend:onBtnSearchClick()
    if isMZBY() or isDBBY() then
        self.light.transform.localPosition = Vector3.New(159.5, self.light.transform.localPosition.y, 0)
        self.searchText.transform:GetComponent('Text').color = Color.New(164/255, 10/255, 10/255);
        self.friendText.transform:GetComponent('Text').color = Color.white;
    else
        
        self.friendLight:SetActive(false)
        self.searchLight:SetActive(true)
    end
    self.PanelFriend:SetActive(false)
    self.PanelSearch:SetActive(true)
    self:onChangeBtn()
end

function PanelBagSend:onChangeBtn()
    self:RemoveAllLight()
    self.searchItem:SetActive(false)
    self.input.text = ""
    self.curSelectMid = nil
end

function PanelBagSend:GetList()
    http.getAllFriendList(
        function(callData)
            if callData then
                self:CreateList(callData.list)
            end
        end,
        function(callData)
        end
    )
end

function PanelBagSend:CreateList(list)
    local grid = self.view.transform:Find("PanelFriend/PanelList/Grid").gameObject
    for i,data in ipairs(list) do
        local item = newObject(self.item)
        item.name = i
        item.transform:SetParent(grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local light = item.transform:Find("Light").gameObject
        item:addButtonClick(function()
            self:RemoveAllLight()
            light:SetActive(true)
            self.curSelectMid = data.mid
        end)

        local Icon = item.transform:Find("Icon").gameObject
        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = data.micon,
            sex = tonumber(data.msex),
            node = Icon,
            callback = function(sprite)
                
                if self.view and Icon then
                    Icon:GetComponent('Image').sprite = sprite
                end
            end,
        })

        local Name = item.transform:Find("Name").gameObject
        Name:setText(data.name)
        local Mid = item.transform:Find("Mid").gameObject
        Mid:setText(data.mid)

        table.insert( self.friendLights, light )
    end
end

function PanelBagSend:onSearchClick()
    -- 查找成功
    if self.input.text == "" or self.input.text == nil then
        return
    end

    http.searchUser(
        self.input.text,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self:onSearchSuccess(callData.info)
                end
            elseif callData.flag == -1 then
                GameManager.TopTipManager:showTopTip(T("查无此人"))    
                if self.view then
                    self:onSearchFailed()
                end            
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
                if self.view then
                    self:onSearchFailed()
                end
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelBagSend:onSearchSuccess(data)
    self.searchItem:SetActive(true)
    self.curSelectMid = data.mid

    local Icon = self.searchItem.transform:Find("Icon").gameObject
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = data.micon,
        sex = tonumber(data.msex),
        node = Icon,
        callback = function(sprite)
            
            if self.view and Icon then
                Icon:GetComponent('Image').sprite = sprite
            end
        end,
    })

    local Name = self.searchItem.transform:Find("Name").gameObject
    Name:setText(data.name)
    local Mid = self.searchItem.transform:Find("Mid").gameObject
    Mid:setText(data.mid)

end

function PanelBagSend:onSearchFailed()
    self.searchItem:SetActive(false)
    self.curSelectMid = nil
end

function PanelBagSend:RemoveAllLight()
    for i, light in pairs(self.friendLights) do
        light:SetActive(false)
    end
end

return PanelBagSend