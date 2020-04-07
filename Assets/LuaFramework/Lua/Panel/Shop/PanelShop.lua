local PanelShop = class("PanelShop")

PanelShop.ShopType = {
    money       = 1,
    diamond     = 2,
    prop        = 3,
}

function PanelShop:ctor(index)
    self.index = index
    
    resMgr:LoadPrefabByRes("Shop", { "PanelShop", "ShopItemBig", "ShopItemSmall" }, function(objs)
        self:initView(objs)
    end)
end

function PanelShop:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelShop"

    self.ShopItemBig = objs[1]
    self.ShopItemSmall = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view:scale(Vector3.one)
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    
end

function PanelShop:initProperties()
    self.viewItems = {}
    self.btnItems = {}

    -- 商城配置表
    self.shopList = {}
    -- 数据观察
    self.registerProps = {"money", "jewel", "diamond"}
end

function PanelShop:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,3 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
    end

    self.moneySpecialGrid = self.view.transform:Find("Item1/Content/SpecialGrid").gameObject
    self.moneyNormalGrid = self.view.transform:Find("Item1/Content/NormalGrid").gameObject

    self.diamondSpecialGrid = self.view.transform:Find("Item2/Content/SpecialGrid").gameObject
    self.diamondNormalGrid = self.view.transform:Find("Item2/Content/NormalGrid").gameObject

    self.propSpecialGrid = self.view.transform:Find("Item3/Content/SpecialGrid").gameObject
    self.propNormalGrid = self.view.transform:Find("Item3/Content/NormalGrid").gameObject

    self.PlayMoneyText  = self.view.transform:Find("PanelTop/btnGold/Text").gameObject
    self.PlayDiamondText  = self.view.transform:Find("PanelTop/btnDiamond/Text").gameObject
    self.PlayHongbaoText  = self.view.transform:Find("PanelTop/btnHongbao/Text").gameObject

    self.btnVip = self.view.transform:Find("btnVip").gameObject
    UIHelper.AddButtonClick(self.btnVip,function()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelNewVipHelper = import("Panel.Special.PanelNewVipHelper").new(true)
    end)
end

function PanelShop:initUIDatas()
    -- 此处顺序必须和PanelShop.ShopType一致
    self.shopList = {
        [1]    = {content = "Item1/Content",   config = {},    specialGrid = self.moneySpecialGrid,    normalGrid = self.moneyNormalGrid},
        [2]    = {content = "Item2/Content",   config = {},    specialGrid = self.diamondSpecialGrid,  normalGrid = self.diamondNormalGrid},
        [3]    = {content = "Item3/Content",   config = {},    specialGrid = self.propSpecialGrid,     normalGrid = self.propNormalGrid},
    }

    http.getInlandProduct(
        function(callData)
            if callData and callData.flag == 1 then
                self.shopList[PanelShop.ShopType.money].config = callData.list["1"]
                self.shopList[PanelShop.ShopType.diamond].config = callData.list["3"]
                -- self.shopList[PanelShop.ShopType.prop].config = callData.list["2"]
                
                self:CreateShopList()
                self:onBtnItemClick(self.index or 1)
            end
        end,
        function(callData)
        end
    )

    self.registerHandleIds = {}
    for i = 1, #self.registerProps do
        local handleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handler(self, self.refashPlayerMoney))
        table.insert(self.registerHandleIds, handleId)
    end
end

function PanelShop:refashPlayerMoney()
    self.PlayMoneyText:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    self.PlayDiamondText:GetComponent('Text').text = GameManager.UserData.diamond
    self.PlayHongbaoText:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
end

function PanelShop:CreateShopList()
    for i, type in pairs(PanelShop.ShopType) do
        self:CreateList(type)
    end
end

function PanelShop:CreateList(type)
    local data = table.remove(self.shopList[type].config,1)
    self:createBigItem(self.shopList[type].specialGrid,data)

    local data2 = table.remove(self.shopList[type].config,1)
    if data2.header == 1 then
        self:createBigItem(self.shopList[type].specialGrid,data2)
    else
        self:createSmallItem(self.shopList[type].specialGrid,data2)
        local data3 = table.remove(self.shopList[type].config,1)
        if data3 then
            self:createSmallItem(self.shopList[type].specialGrid,data3)
        end
    end

    for i,v in ipairs(self.shopList[type].config) do
        self:createSmallItem(self.shopList[type].normalGrid,v)
    end
end

function PanelShop:createBigItem(perent,data,type)
    
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
            
            local PanelPay = import("Panel.Shop.PanelPay").new(data)
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

function PanelShop:createSmallItem(perent,data,type)
    
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
            
            local PanelPay = import("Panel.Shop.PanelPay").new(data)
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

function PanelShop:onLocalItemBuyClick(data)
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

function PanelShop:onBtnItemClick(index)
    
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

    Timer.New(function()
        local ItemContent = self.view.transform:Find(self.shopList[index].content).gameObject
        local NormalSzie = self.shopList[index].normalGrid:GetComponent("RectTransform").sizeDelta
        ItemContent:GetComponent("RectTransform").sizeDelta = Vector3.New(911,237 + NormalSzie.y + 55,0)
    end,0.3,1,true):Start()
end

function PanelShop:onClose()
    -- 这里最好写一个控制器控制
    if self.registerHandleIds then
	    for i = 1, #self.registerHandleIds do
	    	local handleId = self.registerHandleIds[i]
	    	GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, self.registerProps[i], handleId)
	    end
	    self.registerHandleIds = nil
    end
    destroy(self.view)
    self.view = nil
end

return PanelShop