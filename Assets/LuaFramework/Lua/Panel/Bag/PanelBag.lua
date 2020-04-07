local BasePanel = require("Panel.BasePanel").new()
local PanelBag = class("PanelBag", BasePanel)

function PanelBag:ctor()
    self.type = "Bag"
    self.prefabs = { "PanelBag", "PropItem" }
    self:init()
end

function PanelBag:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelBag"

    self.item = objs[1]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelBag:initProperties()
    
end

function PanelBag:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.grid = self.view.transform:Find("PanelProp/Grid").gameObject
end

function PanelBag:initUIDatas()
    self:GetList()
end

function PanelBag:GetList()
    http.getPropBag(
        function(callData)
            if callData and callData.flag == 1 then
                self:CreateList(callData.list)
            end
        end,
        function(callData)
        end
    )
end

function PanelBag:CreateList(list)
    for i,data in ipairs(list) do
        local item = newObject(self.item)
        item.name = i
        item.transform:SetParent(self.grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("prop1/icon").gameObject
        local imgurl = data.pic
        GameManager.ImageLoader:loadAndCacheImage(imgurl,function (success, sprite)
            if success and sprite then
                if self.view then
                    icon:setSprite(sprite)
                end
            end
        end)
        local Name = item.transform:Find("Name").gameObject
        Name:setText(data.name)
        local Num = item.transform:Find("Num").gameObject
        Num:setText(T("剩余：")..data.num)
        local Des = item.transform:Find("Des").gameObject
        Des:setText(data.des)

        if tonumber(data.action_type) == 0 then
            local panelSkill = item.transform:Find("panelSkill").gameObject
            panelSkill:SetActive(true)

            local btnGoto = item.transform:Find("panelSkill/btnGoto").gameObject
            btnGoto:addButtonClick(function()
                self:onClose()
                -- local PanelShop = import("Panel.Shop.PanelShop").new(3)
                -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
                local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
            end)
        elseif tonumber(data.action_type) == 1 then
            local panelProp = item.transform:Find("panelProp").gameObject
            panelProp:SetActive(true)

            local btnSend = item.transform:Find("panelProp/btnSend").gameObject
            local btnReward = item.transform:Find("panelProp/btnReward").gameObject

            if tonumber(data.num) == 0 then
                btnSend:addButtonClick(function()
                    GameManager.TopTipManager:showTopTip(T("您的道具不足"))
                end)

                btnReward:addButtonClick(function()
                    GameManager.TopTipManager:showTopTip(T("您的道具不足"))
                end)
            else
                btnSend:addButtonClick(function()
                    if GameManager.UserData.viplevel < data.send_vip then
                        GameManager.TopTipManager:showTopTip(T("VIP"..data.send_vip.."方可赠送"))
                    else
                        self:onClose()
                        local PanelBagSend = import("Panel.Bag.PanelBagSend").new(data)
                    end
                end)
    
                btnReward:addButtonClick(function()
                    self:onClose()
                    local PanelBagReward = import("Panel.Bag.PanelBagReward").new(data)
                    -- self:ShowDialog(data)
                end)
            end
        end
    end
end

function PanelBag:UseProp(data)
    http.splitProp(
        data.pid,
        1,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                GameManager.UserData.money = callData.latest_money
            elseif callData.flag == -7 then
                GameManager.TopTipManager:showTopTip(T("VIP等级不足"))
            end
        end,
        function(callData)
        end
    )
end

function PanelBag:ShowDialog(data)
    local PanelDialog = import("Panel.Dialog.PanelDialog").new({
        hasFristButton = true,
        hasSecondButton = true,
        hasCloseButton = false,
        title = T("提示"),
        text = T(data.des),
        firstButtonCallbcak = function()
            self:UseProp(data)
        end,
        secondButtonCallbcak = function()
            local PanelBag = import("Panel.Bag.PanelBag").new()
        end,
    })
end

return PanelBag