local BasePanel = require("Panel.BasePanel").new()
local PanelLimitPay = class("PanelLimitPay", BasePanel)

function PanelLimitPay:ctor(callback)
    self.callback = callback
    self.type = "Operation"
    self.prefabs = { "PanelLimitPay", "PanelLimitPayItem", "PanelLimitPayHistoryItem" }
    self:init()
end

function PanelLimitPay:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLimitPay"

    self.item = objs[1]
    self.historyItem = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
    if self.callback then
        self.callback()
    end
end

function PanelLimitPay:initProperties()
    
end

function PanelLimitPay:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject

    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)

    self.grid = self.view.transform:Find("List/Grid").gameObject

    self.historyPanel = self.view.transform:Find("PanelHistory").gameObject
    self.historyGrid = self.view.transform:Find("PanelHistory/HistoryList/Grid").gameObject
    self.historyName = self.view.transform:Find("PanelHistory/name").gameObject
    self.historyClose = self.view.transform:Find("PanelHistory/btnClose").gameObject
    self.historyClose:addButtonClick(buttonSoundHandler(self,function()
        self:onHistoryClose()
    end), false)
end

function PanelLimitPay:initUIDatas()
    self:GetList()
end

function PanelLimitPay:GetList()
    http.getSnatchList(
        function(callData)
            if callData and callData.flag == 1 then
                self:CreatePropList(callData.list)
            end
        end,
        function(callData)
        end
    )
end

function PanelLimitPay:CreatePropList(list)
    for i,data in ipairs(list) do
        local item = newObject(self.item)
        item.name = i
        item.transform:SetParent(self.grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon          = item.transform:Find("icon").gameObject
        local btnHistory    = item.transform:Find("btnHistory").gameObject
        local btnPay        = item.transform:Find("btnPay").gameObject
        local name          = item.transform:Find("name").gameObject
        local issue         = item.transform:Find("issue").gameObject
        local num           = item.transform:Find("num").gameObject
        local chance        = item.transform:Find("chance").gameObject
        local price         = item.transform:Find("btnPay/price").gameObject
        local curProgress   = item.transform:Find("curProgress").gameObject
        local progressBar   = item.transform:Find("progressBar").gameObject

        GameManager.ImageLoader:loadImageOnlyShop(data.pic_param.pic1,function (success, sprite)
            if success and sprite then
                if self.view and icon then
                    icon:GetComponent('Image').sprite = sprite
                    icon:GetComponent('Image'):SetNativeSize()
                end
            end
        end)

        GameManager.ImageLoader:loadImageOnlyShop(data.pic_param.pic2,function (success, sprite)
            if success and sprite then
                if self.view and name then
                    name:GetComponent('Image').sprite = sprite
                    name:GetComponent('Image'):SetNativeSize()
                end
            end
        end)

        issue:setText(T("期号:")..data.priod)
        num:setText(data.my_entry..T("次"))
        local test = data.my_entry / data.player_num
        test = (test - test % 0.01) * 100
        chance:setText(test.."%")
        price:setText(data.entry_fee)
        curProgress:setText(data.current_player.."/".. data.player_num)
        progressBar:GetComponent("Slider").value = data.current_player/data.player_num

        btnHistory:addButtonClick(function()
            self:OpenHistory(data)
        end)

        btnPay:addButtonClick(function()
            if GameManager.UserData.money < tonumber(data.entry_fee) then
                GameManager.TopTipManager:showTopTip(T("金币不足，抢购失败"))
            else
                self:onBuyClick(data)
            end
        end)
    end
end

function PanelLimitPay:CreateHistoryList(list)
    for i,data in ipairs(list) do
        local item = newObject(self.historyItem)
        item.name = i
        item.transform:SetParent(self.historyGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local issue     = item.transform:Find("issue").gameObject
        local icon      = item.transform:Find("icon").gameObject
        local name      = item.transform:Find("name").gameObject
        local mid       = item.transform:Find("mid").gameObject
        local num       = item.transform:Find("num").gameObject
        local time      = item.transform:Find("time").gameObject

        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = data.winner_micon,
            sex = tonumber(data.winner_msex),
            node = icon,
            callback = function(sprite)
                if self.view and icon then
                    icon:GetComponent('Image').sprite = sprite
                end
            end,
        })
        
        if tonumber(data.online) == 0 then
            time:setText(os.date("%Y/%m/%d %H:%M:%S", data.atime))
            issue:setText(data.priod)
            name:setText(data.winner_name)
            mid:setText(data.winner_mid)
            num:setText(data.winner_entry..T("次"))
        else
            time:setText("<color=#FFFF00>"..T("正在进行").."</color>")
            issue:setText(data.priod)
            name:setText(T("等待开奖"))
            mid:setText(T("等待开奖"))
            num:setText(T("等待开奖"))
        end

    end
end

function PanelLimitPay:OpenHistory(data)
    self.historyGrid:removeAllChildren()
    self.historyPanel:SetActive(true)
    self.historyName:setText(data.name..T(" - 中奖记录"))
    http.getSnatchLog(
        data.cid,
        function(hisData)
            if hisData and hisData.flag == 1 then
                self:CreateHistoryList(hisData.list)
            end
        end,
        function(hisData)
        end
    )
end

function PanelLimitPay:onHistoryClose()
    self.historyPanel:SetActive(false)
    self.historyGrid:removeAllChildren()
end

function PanelLimitPay:onBuyClick(data)
    self:onClose()
    local PanelDialog = import("Panel.Dialog.PanelDialog").new({
        hasFristButton = true,
        hasSecondButton = true,
        hasCloseButton = false,
        title = T("提示"),
        text = T("是否确认购买"),
        firstButtonCallbcak = function()
            -- TODO 去购买
            http.entrySnatch(
                data.id,
                function(callData)
                    if callData and callData.flag == 1 then
                        local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new(function()
                            GameManager.TopTipManager:showTopTip(T("抢购成功"))
                        end)
                    else
                        local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new(function()
                            GameManager.TopTipManager:showTopTip(T("抢购失败"))
                        end)
                    end
                    GameManager.UserData.money = callData.latest_money
                end,
                function(callData)
                    local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new(function()
                        GameManager.TopTipManager:showTopTip(T("抢购失败"))
                    end)
                end
            )
        end,
        secondButtonCallbcak = function()
            local PanelLimitPay = import("Panel.Operation.PanelLimitPay").new()
        end
    })
end

return PanelLimitPay