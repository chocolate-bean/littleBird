local BasePanel = require("Panel.BasePanel").new()
local PanelNewShop = class("PanelNewShop", BasePanel)

function PanelNewShop:ctor(index, hideDiamond, callback)
    self.index = index or 1
    self.hideDiamond = hideDiamond
    self.callback = callback

    self.type = "Shop"
    self.prefabs = { "PanelNewShop", "ShopItemBig", "ShopItemSmall", "HongbaoItem", "HistoryItem", "DiamondItem" }
    self:init()
end

function PanelNewShop:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelNewShop"

    self.ShopItemBig = objs[1]
    self.ShopItemSmall = objs[2]

    self.HongbaoItem = objs[3]
    self.HistoryItem = objs[4]

    self.DiamondItem = objs[5]

    GameManager.LoadingManager:setLoading(true, self.view)
    Timer.New(function()
        self:initProperties()
        self:initUIControls()
        self:initUIDatas()
    end,0.5,1,true):Start() 
    
    self:show()

    Timer.New(function()
        if self.view then
            wwwMgr:StopHttp()
            GameManager.LoadingManager:setLoading(false, self.view)
        end
    end,3,1,true):Start() 
end

function PanelNewShop:initProperties()
    self.viewItems    = {}
    self.btnItems     = {}
    self.redpacketUIs = {}

    -- 商城配置表
    self.shopList = {}
    -- 数据观察
    self.registerProps = {"money", "jewel", "diamond"}
end

function PanelNewShop:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,function ()
        self:onClose()
        if self.callback then
            self.callback()
        end
    end)

    for i=1,3 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnGrid/btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end


    showOrHide(GameManager.GameConfig.HasDiamond == 1, self.btnItems[3])
    
    -- 商品列表
    if isFKBY() then
        self.shopGrid = self.view.transform:Find("Item1/ShopView/Grid").gameObject
    else
        self.moneySpecialGrid = self.view.transform:Find("Item1/ShopView/Content/SpecialGrid").gameObject
        self.moneyNormalGrid = self.view.transform:Find("Item1/ShopView/Content/NormalGrid").gameObject
    end

    self.exchangeView = self.view:findChild("Item2")
    -- 兑换列表
    self.hongbaoGrid = self.view.transform:Find("Item2/Hongbao/HongbaoView/Grid").gameObject
    -- 剩余兑换次数
    self.LeftTimeText = self.view.transform:Find("Item2/Hongbao/LeftTime").gameObject
    -- 历史列表
    self.historyGrid = self.view.transform:Find("Item2/History/HistoryList/Grid").gameObject

    -- 兑换界面
    self.hongbaoView = self.view.transform:Find("Item2/Hongbao").gameObject
    -- 历史界面
    self.historyView = self.view.transform:Find("Item2/History").gameObject

    -- 跳转历史界面
    self.gotoHistory = self.view.transform:Find("Item2/Hongbao/btnHistory").gameObject
    self.gotoHistory:addButtonClick(function()
        -- body
        self:setHistoryView(true)
    end)
    -- 跳转兑换界面
    self.gotoHongbao = self.view.transform:Find("Item2/History/btnReturn").gameObject
    self.gotoHongbao:addButtonClick(function()
        -- body
        self:setHistoryView(false)
    end)

    self.moneyNum = self.view.transform:Find("Item1/btnMoney/TextNum").gameObject
    self.hongbaoNum = self.view.transform:Find("Item2/btnHongbao/TextNum").gameObject

    self.btnHelp = self.view.transform:Find("Item2/Hongbao/btnHelp").gameObject
    self.btnHelp:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
        local PanelExchangeHelper = import("Panel.Operation.PanelExchangeHelper").new()
    end), false)

    --[[
        钻石兑换界面
    ]]
    self.diamondMoneyNum           = self.view:findChild("Item3/btnMoney/TextNum")
    self.diamondNum                = self.view:findChild("Item3/btnDiamond/TextNum")
    self.diamondGotoHistory        = self.view:findChild("Item3/Diamond/btnHistory")
    self.diamondGotoDiamond        = self.view:findChild("Item3/History/btnReturn")
    self.diamondView               = self.view:findChild("Item3/Diamond")
    self.diamondHistoryView        = self.view:findChild("Item3/History")
    self.diamondContentGrid        = self.view:findChild("Item3/Diamond/Content/Grid")
    self.diamondHistoryContentGrid = self.view:findChild("Item3/History/Content/Grid")
    self.diamondLeftTimeText       = self.view:findChild("Item3/Diamond/LeftTime")

    self.diamondGotoHistory:addButtonClick(function()
        self:getUserPointsLog(function()
            self:setDiamondHistoryView(true)
        end)
    end)
    self.diamondGotoDiamond:addButtonClick(function()
        self:setDiamondHistoryView(false)
    end)

    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("btnGrid/btnItem2").gameObject
    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
    if self.hideDiamond == true then
        self.btnItems[3]:SetActive(false);
    end
end

function PanelNewShop:initUIDatas()
    self.shopList = {
        content = "Item1/ShopView/Content",   
        config = {},    
        specialGrid = self.moneySpecialGrid,    
        normalGrid = self.moneyNormalGrid,
    }

    http.getInlandProduct(
        function(callData)
            if callData and callData.flag == 1 then
                self.shopList.config = callData.list["1"]
                self:CreateShopList()
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
        end
    )

    self.JewelHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "jewel", handler(self, self.refashPlayerData))
    self.MoneyHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "money", handler(self, self.refashPlayerData))
    self.DiamondHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "diamond", handler(self, self.refashPlayerData))

    self:reFashExchangeList()
    self:refashPlayerData()
    self:onBtnItemClick(self.index)
    self:getPointsStoreList()
end

function PanelNewShop:refashPlayerData()
    self.moneyNum:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.hongbaoNum:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
    self.diamondMoneyNum:setText(formatFiveNumber(GameManager.UserData.money))
    self.diamondNum:setText(GameManager.UserData.diamond)
end

-- 设置历史界面可见性
function PanelNewShop:setHistoryView(isShow)
    self.hongbaoView:SetActive(not isShow)
    self.historyView:SetActive(isShow)
end

-- 设置历史界面可见性
function PanelNewShop:setDiamondHistoryView(isShow)
    self.diamondView:SetActive(not isShow)
    self.diamondHistoryView:SetActive(isShow)
end

-- 刷新列表
function PanelNewShop:reFashExchangeList()
    self.hongbaoData = {}
    self.historyData = {}

    self:GetExchangeList()
end

-- 获取兑换中心数据
function PanelNewShop:GetExchangeList()
    http.getStoreList(
        function(callData)
            if callData then
                self.hongbaoData = callData.list
                self:DestroyHongbaoList()
                self:createHongbaoList()
                self.leftTime = tonumber(callData.left_times)
                self.LeftTimeText:setText(self.leftTime.."次")
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

function PanelNewShop:DestroyHongbaoList()
    
    removeAllChild(self.hongbaoGrid.transform)
end

function PanelNewShop:DestroyHistoryList()
    
    removeAllChild(self.historyGrid.transform)
end

function PanelNewShop:createDiamondList(listData)
    for i=1, #listData do
        local item = {}
        item.view = newObject(self.DiamondItem)
        item.view.transform:SetParent(self.diamondContentGrid.transform)
        item.view.transform.localScale = Vector3.one
        item.view.transform.localPosition = Vector3.zero
        
        item.vip            = item.view:findChild("Vip")
        item.vipText        = item.view:findChild("Vip/Text")
        item.title          = item.view:findChild("Title")
        item.icon           = item.view:findChild("icon")
        item.moneyText      = item.view:findChild("moneyIcon/des")
        item.diamondText    = item.view:findChild("diamondIcon/des")
        item.exchangeButton = item.view:findChild("btnSend")

        item.exchangeButton:addButtonClick(buttonSoundHandler(self, function()
            if self.diamondLeftTime <= 0 then
                GameManager.TopTipManager:showTopTip(T("您的兑换次数不足"))
                return
            end
            if GameManager.UserData.viplevel < tonumber(item.data.exchange_param.vip) then
                GameManager.TopTipManager:showTopTip(T("您的VIP等级不够"))
                return
            end
            if GameManager.UserData.money < item.data.exchange_param.money then
                GameManager.TopTipManager:showTopTip(T("您的金币不足！"))
                return
            end
            if GameManager.UserData.diamond < item.data.exchange_param.diamon then
                GameManager.TopTipManager:showTopTip(T("您的钻石不足！"))
                return
            end
            self:buyPointProduct(item.data.id)
        end))

        item.setData = function(data)
            item.data = data
            item.title:setText(data.getname)
            if isFKBY() then
                item.moneyText:setText(formatFiveNumber(data.exchange_param.money))
                item.diamondText:setText(formatFiveNumber(data.exchange_param.diamon))
            else
                item.moneyText:setText(data.exchange_param.money)
                item.diamondText:setText(data.exchange_param.diamon)
            end
            GameManager.ImageLoader:loadAndCacheImage(data.picture, function(success, sprite)
                if success and sprite then
                    if self.view and item.icon then
                        item.icon:GetComponent('Image').sprite = sprite
                        -- item.icon:GetComponent('Image'):SetNativeSize()
                    end
                end
            end)

            if data.exchange_param.vip and tonumber(data.exchange_param.vip) ~= 0 then
                item.vip:SetActive(true)
                item.vipText:GetComponent("Text").text = "VIP "..data.exchange_param.vip
            else
                item.vip:SetActive(false)
            end
        end
        item.setData(listData[i])
    end
end

function PanelNewShop:createDiamondHistoryList(logData)
    removeAllChild(self.diamondHistoryContentGrid.transform)
    for i,data in ipairs(logData) do
        local item = newObject(self.HistoryItem)
        item.name = i
        item.transform:SetParent(self.diamondHistoryContentGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local time = item.transform:Find("time").gameObject
        local des = item.transform:Find("des").gameObject
        local code = item.transform:Find("code").gameObject
        local btnCopy = item.transform:Find("btnCopy").gameObject

        time:GetComponent("Text").text = os.date("%Y/%m/%d %H:%M", data.ctime or 0)
        code:GetComponent("Text").text = data.getname

        hide({des, btnCopy})
    end
end

function PanelNewShop:createHongbaoList()
    
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
                    GameManager.SoundManager:PlaySound("clickButton")

                    if self.leftTime <= 0 then
                        GameManager.TopTipManager:showTopTip(T("您的兑换次数不足"))
                        return
                    end

                    if GameManager.UserData.viplevel < tonumber(data.vip) then
                        GameManager.TopTipManager:showTopTip(T("您的VIP等级不够"))
                        return
                    end

                    local lastLoginType = UnityEngine.PlayerPrefs.GetString(DataKeys.LAST_LOGIN_TYPE)
                    -- 如果是微信登陆并且没有绑定手机号
                    if lastLoginType == "WX" and GameManager.GameConfig.isBind == 0 then
                        self:onClose()
                        local PanelPhone = import("Panel.Login.PanelPhone").new(5)
                        return
                    end

                    if current >= goal then
                        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                            hasFristButton = true,
                            hasSecondButton = true,
                            hasCloseButton = false,
                            title = T("兑换红包"),
                            text = string.format(T("你确定花费%s红包兑换【%s】吗？"),GameManager.GameFunctions.getJewelWithUnit(data.jewel), data.title),
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
                end
            ), false)
        -- end
    end
end

function PanelNewShop:createHistoryList()
    
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

        time:GetComponent("Text").text = os.date("%Y/%m/%d %H:%M", data.time or 0)
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

function PanelNewShop:jewelExchangeCash(data)
    http.jewelExchangeCash(
        data.id,
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.UserData.money = tonumber(callData.latest_money)
                self:reFashExchangeList()
                GameManager.TopTipManager:showTopTip(T("兑换成功"))
                self.leftTime = self.leftTime - 1
                self.LeftTimeText:setText(self.leftTime.."次")
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

function PanelNewShop:CreateShopList()
    if isFKBY() then
        self:CreateFkShopList()
    else
        self:CreateList()
        self:refashGridSize()
    end
end

function PanelNewShop:CreateFkShopList()
    for i,data in ipairs(self.shopList.config) do
        local item = newObject(self.ShopItemSmall)
        item.transform:SetParent(self.shopGrid.transform)
        item.name = "Small"
        item.transform.localPosition = Vector3.zero
        item.transform.localScale = Vector3.one

        GameManager.ImageLoader:loadImageOnlyShop(data.desc_pic1,function (success, sprite)
            local icon = item.transform:Find("icon").gameObject
        
            if self.view and icon then
                if success and sprite then
                    if isFKBY() then
                        icon:GetComponent('Image').sprite = sprite
                    else
                        icon:GetComponent('Image'):SetNativeSize()
                        icon:GetComponent('Image').sprite = sprite
                        icon.transform.localScale = Vector3.New(0.7, 0.7, 0.7)
                    end
                end
            end
        end)

        local price = item.transform:Find("price").gameObject
        price:GetComponent("Text").text = data.getname

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

        local btnBuy = item.transform:Find("btnBuy").gameObject
        if data.pay_method == 1 then
            -- 金币购买
            btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..data.pamount.."金币购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end})
            end), false)
            local playGods = item.transform:Find("btnBuy/Text").gameObject
            playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("金币")
        elseif data.pay_method == 2 then
            -- 人民币购买
            btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
                local PanelPay = import("Panel.Shop.PanelPay").new(data, function()
                    self:onClose()
                end)
            end), false)
            local playGods = item.transform:Find("btnBuy/Text").gameObject
            playGods:GetComponent("Text").text = "￥"..data.pamount
        elseif data.pay_method == 3 then
            -- 红包购买
            btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
                local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                    hasFristButton = true,
                    hasSecondButton = true,
                    hasCloseButton = false,
                    title = T("确认购买"),
                    text = T("是否花费"..GameManager.GameFunctions.getJewelWithUnit(data.pamount).."红包购买"..data.getname),
                    firstButtonCallbcak = function()
                        self:onLocalItemBuyClick(data)
                    end,
                })
            end), false)
            local playGods = item.transform:Find("btnBuy/Text").gameObject
            playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("红包")
        elseif data.pay_method == 4 then
            -- 钻石购买
            btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
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
end

function PanelNewShop:CreateList()
    -- TODO 疯狂捕鱼的创建商品列表
    local data = table.remove(self.shopList.config,1)
    self:createBigItem(self.shopList.specialGrid,data)

    local data2 = table.remove(self.shopList.config,1)
    if data2.header == 1 then
        self:createBigItem(self.shopList.specialGrid,data2)
    else
        self:createSmallItem(self.shopList.specialGrid,data2)
        local data3 = table.remove(self.shopList.config,1)
        if data3 then
            self:createSmallItem(self.shopList.specialGrid,data3)
        end
    end

    for i,v in ipairs(self.shopList.config) do
        self:createSmallItem(self.shopList.normalGrid,v)
    end
end

function PanelNewShop:createBigItem(perent,data,type)
    
    local item = newObject(self.ShopItemBig)
    item.name = "Big"
    item.transform:SetParent(perent.transform)
    item.transform.localScale = Vector3.one
    item.transform.localPosition = Vector3.zero

    local icon = item.transform:Find("icon").gameObject
    GameManager.ImageLoader:loadImageOnlyShop(data.desc_pic1,function (success, sprite)
        if success and sprite then
            if self.view and icon then
                icon:GetComponent('Image').sprite = sprite
                icon:GetComponent('Image'):SetNativeSize()
                icon.transform.localScale = Vector3.New(1, 1, 1)
            end
        end
    end)

    local price = item.transform:Find("price").gameObject
    price:GetComponent("Text").text = data.getname

    local Text = item.transform:Find("Text").gameObject
    Text:GetComponent("Text").text = data.desc_str2

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
    local btnBuy = item.transform:Find("btnBuy").gameObject
    if data.pay_method == 1 then
        -- 金币购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
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
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelPay = import("Panel.Shop.PanelPay").new(data, function()
                self:onClose()
            end)
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = "￥"..data.pamount
    elseif data.pay_method == 3 then
        -- 红包购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..GameManager.GameFunctions.getJewelWithUnit(data.pamount).."红包购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end,
            })
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("红包")
    elseif data.pay_method == 4 then
        -- 钻石购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
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

function PanelNewShop:createSmallItem(perent,data,type)
    
    local item = newObject(self.ShopItemSmall)
    item.name = "Small"
    item.transform:SetParent(perent.transform)
    item.transform.localScale = Vector3.one
    item.transform.localPosition = Vector3.zero

    local icon = item.transform:Find("icon").gameObject
    GameManager.ImageLoader:loadImageOnlyShop(data.desc_pic1,function (success, sprite)
        
        if success and sprite then
            if self.view and icon then
                icon:GetComponent('Image').sprite = sprite
                icon:GetComponent('Image'):SetNativeSize()
                icon.transform.localScale = Vector3.New(0.7, 0.7, 0.7)
            end
        end
    end)

    local price = item.transform:Find("price").gameObject
    price:GetComponent("Text").text = data.getname

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

    local btnBuy = item.transform:Find("btnBuy").gameObject
    if data.pay_method == 1 then
        -- 金币购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
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
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelPay = import("Panel.Shop.PanelPay").new(data, function()
                self:onClose()
            end)
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = "￥"..data.pamount
    elseif data.pay_method == 3 then
        -- 红包购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = true,
                hasCloseButton = false,
                title = T("确认购买"),
                text = T("是否花费"..GameManager.GameFunctions.getJewelWithUnit(data.pamount).."红包购买"..data.getname),
                firstButtonCallbcak = function()
                    self:onLocalItemBuyClick(data)
                end,
            })
        end), false)
        local playGods = item.transform:Find("btnBuy/Text").gameObject
        playGods:GetComponent("Text").text = formatFiveNumber(data.pamount)..T("红包")
    elseif data.pay_method == 4 then
        -- 钻石购买
        btnBuy:addButtonClick(buttonSoundHandler(self, function()
            
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

function PanelNewShop:onLocalItemBuyClick(data)
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

function PanelNewShop:onBtnItemClick(index)
    
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

    self:setHistoryView(false)
    self:setDiamondHistoryView(false)
    if isFKBY() then
    else
        self:refashGridSize()
    end
end

function PanelNewShop:refashGridSize()
    Timer.New(function()
        local ItemContent = self.view.transform:Find(self.shopList.content).gameObject
        local NormalSzie = self.shopList.normalGrid:GetComponent("RectTransform").sizeDelta
        ItemContent:GetComponent("RectTransform").sizeDelta = Vector3.New(911,237 + NormalSzie.y + 55,0)
    end,0.3,1,true):Start()
end

function PanelNewShop:onClose()
    -- 这里最好写一个控制器控制
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "jewel", self.JewelHandleId)
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "money", self.MoneyHandleId)
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "diamond", self.DiamondHandleId)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end


--[[
    http 请求
]]

function PanelNewShop:getPointsStoreList()
    http.getPointsStoreList(
        function(callData)
            if callData and callData.flag == 1 then
                self:createDiamondList(callData.list)
                dump(callData)
                self.diamondLeftTime = tonumber(callData.left_times)
                self.diamondLeftTimeText:setText(self.diamondLeftTime.."次")
            else
                GameManager.TopTipManager:showTopTip(T("网络请求失败!"))    
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败!"))
        end
    )
end

function PanelNewShop:buyPointProduct(id)
    http.buyPointProduct(
        id,
        function(callData)
            if callData and callData.flag == 1 then
                dump(callData)
                GameManager.UserData.money   = tonumber(callData.latest_money)
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.UserData.diamond = tonumber(callData.latest_diamon)
                GameManager.AnimationManager:playRewardAnimation(T("恭喜获得"),callData.rtype, callData.desc, "")
                self.diamondLeftTime = self.diamondLeftTime - 1
                self.diamondLeftTimeText:setText(self.diamondLeftTime.."次")
            else
                GameManager.TopTipManager:showTopTip(T("兑换失败！"))
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("兑换失败！"))
        end
    )
end

function PanelNewShop:getUserPointsLog(callback)
    http.getUserPointsLog(
        function(callData)
            if callData and callData.flag == 1 then
                self:createDiamondHistoryList(callData.log)
                if callback then
                    callback()
                end
            else
                GameManager.TopTipManager:showTopTip(T("网络请求失败!"))    
            end
        end,
        function(errorData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败!"))
        end
    )
end

return PanelNewShop