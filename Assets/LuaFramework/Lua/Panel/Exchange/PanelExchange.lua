local PanelExchange = class("PanelExchange")

function PanelExchange:ctor(index)
    self.index = index or 1
    
    resMgr:LoadPrefabByRes("Exchange", { "PanelExchange", "HongbaoItem", "HistoryItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelExchange:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelExchange"

    self.HongbaoItem = objs[1]
    self.HistoryItem = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelExchange:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelExchange:initProperties()
    self.viewItems = {}
    self.btnItems = {}

    self.hongbaoData = {}
    self.historyData = {}

    self.leftTime = 0
end

function PanelExchange:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i = 1,2 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end

    -- 兑换列表
    self.hongbaoGrid = self.view.transform:Find("Item1/HongbaoList/Grid").gameObject
    -- 历史列表
    self.historyGrid = self.view.transform:Find("Item2/HistoryList/Grid").gameObject
    
    self.btnGoto = self.view.transform:Find("btnGoto").gameObject
    self.hongbaoNum = self.view.transform:Find("btnGoto/Text").gameObject

    self.btnHelp = self.view.transform:Find("btnHelp").gameObject
    self.btnHelp:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
        local PanelExchangeHelper = import("Panel.Operation.PanelExchangeHelper").new()
    end), false)

    self.LeftTimeText = self.view.transform:Find("LeftTime").gameObject
end

function PanelExchange:initUIDatas()
    self.hongbaoNum:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
    self:reFashExchangeList()
    self:onBtnItemClick(self.index)

    self.JewelHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "jewel", handler(self, self.refashPlayerJewel))
end

function PanelExchange:refashPlayerJewel()
    
    self.hongbaoNum:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
end

-- 刷新好友列表
function PanelExchange:reFashExchangeList()
    self.hongbaoData = {}
    self.historyData = {}

    self:GetExchangeList()
end

-- 获取兑换中心数据
function PanelExchange:GetExchangeList()
    http.getStoreList(
        function(callData)
            if callData then
                self.hongbaoData = callData.list
                self:DestroyHongbaoList()
                self:createHongbaoList()
                self.leftTime = tonumber(callData.left_times)
                self.LeftTimeText:setText(self.leftTime)
            end
        end,
        function(callData)
        end
    )

    http.jewelStoreExchangeLog(
        function(callData)
            if callData then
                self.historyData = callData.list
                self:DestroyHistoryList()
                self:createHistoryList()
            end
        end,
        function(callData)
        end
    )
end

function PanelExchange:createHongbaoList()
    
    for i,data in ipairs(self.hongbaoData) do
        local item = newObject(self.HongbaoItem)
        item.name = i
        item.transform:SetParent(self.hongbaoGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("icon").gameObject
        local vip = item.transform:Find("Vip").gameObject
        local vipText = item.transform:Find("Vip/Text").gameObject
        local Title = item.transform:Find("Title").gameObject
        local progressBar = item.transform:Find("progressBar").gameObject
        local progressText = item.transform:Find("progressBar/Text").gameObject
        local des = item.transform:Find("des").gameObject

        if tonumber(data.exchange_type) == 1 then
            -- 现金
            icon:setSprite("Images/common/exchange1")
        elseif tonumber(data.exchange_type) == 2 then
            -- 金币
            icon:setSprite("Images/common/exchange2")
        end

        if tonumber(data.vip) == 0 then
            vip:SetActive(false)
        else
            vip:SetActive(true)
            vipText:GetComponent("Text").text = "VIP "..data.vip
        end

        Title:GetComponent("Text").text = data.title

        local current = GameManager.UserData.jewel
        local goal = tonumber(data.jewel) 
        local process = string.format("%s/%s", GameManager.GameFunctions.getJewel(current), GameManager.GameFunctions.getJewel(goal))

        progressBar:GetComponent("Slider").value = current/goal
        progressText:GetComponent("Text").text = process

        des:GetComponent("Text").text = data.content

        local btn = item.transform:Find("btnSend").gameObject
        -- if data.status == 0 then
        --     btn:SetActive(false)
        -- else
            btn:addButtonClick(buttonSoundHandler(self,
                function()
                    if self.leftTime < 0 then
                        GameManager.TopTipManager:showTopTip(T("您的兑换次数不足"))
                        return
                    end

                    GameManager.SoundManager:PlaySound("clickButton")
                    local lastLoginType = UnityEngine.PlayerPrefs.GetString(DataKeys.LAST_LOGIN_TYPE)
                    -- 如果是微信登陆并且没有绑定手机号
                    if lastLoginType == "WX" and GameManager.GameConfig.isBind == 0 then
                        self:onClose()
                        local PanelPhone = import("Panel.Login.PanelPhone").new(5)
                        return
                    end

                    if GameManager.UserData.viplevel >= tonumber(data.vip) then
                        if current >= goal then
                            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                                hasFristButton = true,
                                hasSecondButton = true,
                                hasCloseButton = false,
                                title = T("兑换红包"),
                                text = string.format(T("你确定花费%d红包兑换【%s】吗？"),GameManager.GameFunctions.getJewel(data.jewel), data.title),
                                firstButtonCallbcak = function()
                                    self:jewelExchangeCash(data)
                                end,
                            })
                        else
                            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                                hasFristButton = true,
                                hasSecondButton = true,
                                hasCloseButton = false,
                                title = T("兑换红包"),
                                text = T("红包不足，去玩游戏赢取红包"),
                                firstButtonCallbcak = function()
                                    GameManager.ChooseRoomManager:getLandlordsRoomList(function()
                                        GameManager.ServerManager:getLandlordsRoomAndLogin()
                                    end)
                                end,
                            })
                        end
                    else
                        GameManager.TopTipManager:showTopTip(T("您的VIP等级不够"))
                    end
                end
            ), false)
        -- end
    end
end

function PanelExchange:createHistoryList()
    
    for i,data in ipairs(self.historyData) do
        local item = newObject(self.HistoryItem)
        item.name = i
        item.transform:SetParent(self.historyGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local time = item.transform:Find("time").gameObject
        local des = item.transform:Find("des").gameObject
        local code = item.transform:Find("code").gameObject
        local btnCopy = item.transform:Find("btnCopy").gameObject

        time:GetComponent("Text").text = os.date("%Y/%m/%d\n%H:%M", data.time or 0)
        if data.code == nil or data.code == "" then
            code:GetComponent("Text").text = "/             "
            btnCopy:SetActive(false)
        else
            code:GetComponent("Text").text = data.code
            AutoTextSize(code,300)
            btnCopy:SetActive(true)
            btnCopy:addButtonClick(buttonSoundHandler(self, function()
                sdkMgr:CopyTextToClipboard(data.code)
                GameManager.TopTipManager:showTopTip(T("内容已复制到粘贴板"))
            end), false)
        end

        des:GetComponent("Text").text = data.title

    end
end

function PanelExchange:DestroyHongbaoList()
    
    removeAllChild(self.hongbaoGrid.transform)
end

function PanelExchange:DestroyHistoryList()
    
    removeAllChild(self.historyGrid.transform)
end

function PanelExchange:jewelExchangeCash(data)
    http.jewelExchangeCash(
        data.id,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.UserData.money = callData.latest_money
                self:reFashExchangeList()
                GameManager.TopTipManager:showTopTip(T("兑换成功"))
                self.leftTime = self.leftTime - 1
                self.LeftTimeText:setText(self.leftTime)
                -- local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                --     hasFristButton = true,
                --     hasSecondButton = false,
                --     hasCloseButton = false,
                --     title = T("兑换红包"),
                --     text = T("兑换成功"),
                -- })
            elseif callData.flag == -2 then
                GameManager.TopTipManager:showTopTip(T("商品不存在"))
            elseif callData.flag == -3 then
                GameManager.TopTipManager:showTopTip(T("兑换超过上限"))
            elseif callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("红包券不足"))
            elseif callData.flag == -7 then
                GameManager.TopTipManager:showTopTip(T("今日兑换次数不足，请提升VIP等级"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("兑换失败"))
        end
    )
end

function PanelExchange:onBtnItemClick(index)
    
    for k,btn in pairs(self.btnItems) do
        local btnLight = btn.transform:Find("btnLight").gameObject
        btnLight:SetActive(false)
    end

    for k,view in pairs(self.viewItems) do
        view:SetActive(false)
    end

    local curBtnLight = self.btnItems[index].transform:Find("btnLight").gameObject
    curBtnLight:SetActive(true)
    self.viewItems[index]:SetActive(true)
end

function PanelExchange:onClose()
    -- 这里最好写一个控制器控制
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "jewel", self.JewelHandleId)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelExchange