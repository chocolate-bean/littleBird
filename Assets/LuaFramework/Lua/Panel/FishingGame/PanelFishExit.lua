local BasePanel = require("Panel.BasePanel").new()
local PanelFishExit = class("PanelFishExit", BasePanel)

function PanelFishExit:ctor(text1, text2, callback)
    self.text1 = text1
    self.text2 = text2
    self.callback = callback

    self.type = "FishingGame/UI"
    self.prefabs = { "PanelFishingExit" }
    self:init()
end

function PanelFishExit:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishExit"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFishExit:initProperties()
    
end

function PanelFishExit:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.textObj1    = self.view.transform:Find("text1").gameObject
    self.textObj2    = self.view.transform:Find("text2").gameObject

    self.item1    = self.view.transform:Find("item1").gameObject
    self.item2    = self.view.transform:Find("item2").gameObject

    self.btn1    = self.view.transform:Find("btn1").gameObject
    self.btn1:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)
    self.btn2    = self.view.transform:Find("btn2").gameObject
    self.btn2:addButtonClick(buttonSoundHandler(self,function()
        if self.callback then
            self.callback()
        end
        self:onClose()
    end), false)
end

function PanelFishExit:initUIDatas()
    -- self.textObj1:setText(self.text1)
    -- self.textObj2:setText(self.text2)

    TMPHelper.setText(self.textObj1, self.text1)
    TMPHelper.setText(self.textObj2, self.text2)

    http.getFishingRoomQuitTips(
        function(callData)
            if callData and callData.flag == 1 then
                self:create(1,callData.merchandise[1])
                self:create(2,callData.merchandise[2])
            end
        end,
        function(callData)
        end
    )
end

function PanelFishExit:create(index,data)
    local item

    if index == 1 then
        item = self.item1
    else
        item = self.item2
    end

    local icon = item.transform:Find("icon").gameObject
    GameManager.ImageLoader:loadImageOnlyShop(data.desc_pic1,function (success, sprite)
        
        if success and sprite then
            if self.view and icon then
                icon:GetComponent('Image').sprite = sprite
                icon.transform.localScale = Vector3.New(1, 1, 1)
            end
        end
    end)

    local text = item.transform:Find("text").gameObject
    text:GetComponent("Text").text = data.getname

    local add = item.transform:Find("Add").gameObject
    if data.desc_str and data.desc_str ~= "" then
        add:SetActive(true)
        local text = item.transform:Find("Add/Text").gameObject
        text:GetComponent("Text").text = data.desc_str
    else
        add:SetActive(false)
    end

    local hot = item.transform:Find("hot").gameObject
    if tonumber(data.label) == 2 then
        hot:SetActive(true)
    else
        hot:SetActive(false)
    end

    -- TODO判断是否是金币购买
    if data.pay_method == 1 then
        -- 金币购买
        item:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..data.pamount.."金币购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end,
            })
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("金币")
    elseif data.pay_method == 2 then
        -- 人民币购买
        item:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelPay = import("Panel.Shop.PanelPay").new(data)
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = "￥"..data.pamount
    elseif data.pay_method == 3 then
        -- 红包购买
        item:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..data.pamount.."红包购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end,
            })
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("红包")
    elseif data.pay_method == 4 then
        -- 钻石购买
        item:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..data.pamount.."钻石购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end,
            })
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("钻石")
    end
end

function PanelFishExit:onLocalItemBuyClick(data)
    if data.pay_method == 1 then
        if GameManager.UserData.money < tonumber(data.pamount) then
            GameManager.TopTipManager:showTopTip(T("金币不足"))
            return
        end
    elseif data.pay_method == 3 then
        if GameManager.UserData.jewel < tonumber(data.pamount) then
            GameManager.TopTipManager:showTopTip(T("红包不足"))
            return
        end
    elseif data.pay_method == 4 then
        if GameManager.UserData.diamond < tonumber(data.pamount) then
            GameManager.TopTipManager:showTopTip(T("钻石不足"))
            return
        end
    end

    http.AttirebuyProp(
        GameManager.UserData.mid,
        data.id,
        GameManager.UserData.mid,
        function(callData)
            
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("购买成功"))

                GameManager.UserData.money = callData.latest_money
                GameManager.UserData.diamond = callData.latest_diamon
                GameManager.GameFunctions.setJewel(callData.latest_jewel)
            elseif callData and callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("金币不足"))
            else
                GameManager.TopTipManager:showTopTip(T("配置错误"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("购买失败"))
        end
    )
end

return PanelFishExit