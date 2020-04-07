local BasePanel = require("Panel.BasePanel").new()
local PanelSmallShop = class("PanelSmallShop", BasePanel)

function PanelSmallShop:ctor(index)
    self.type = "Shop"
    self.prefabs = { "PanelSmallShop", "ShopItemBig", "ShopItemSmall" }
    self:init()
end

function PanelSmallShop:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelSmallShop"

    self.ShopItemBig = objs[1]
    self.ShopItemSmall = objs[2]

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

function PanelSmallShop:initProperties()
    self.viewItems = {}
    self.btnItems = {}

    -- 商城配置表
    self.shopList = {}
    -- 数据观察
    self.registerProps = {"money", "jewel", "diamond"}
end

function PanelSmallShop:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.moneySpecialGrid = self.view.transform:Find("Item1/Content/SpecialGrid").gameObject
    self.moneyNormalGrid = self.view.transform:Find("Item1/Content/NormalGrid").gameObject
end

function PanelSmallShop:initUIDatas()
    -- 此处顺序必须和PanelSmallShop.ShopType一致
    self.shopList = {
        content = "Item1/Content",   
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
end

function PanelSmallShop:CreateShopList()
    self:CreateList()
    self:refashGridSize()
end

function PanelSmallShop:CreateList()
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

function PanelSmallShop:createBigItem(perent,data,type)
    
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

function PanelSmallShop:createSmallItem(perent,data,type)
    
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

function PanelSmallShop:onLocalItemBuyClick(data)
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

function PanelSmallShop:refashGridSize()
    Timer.New(function()
        local ItemContent = self.view.transform:Find(self.shopList.content).gameObject
        local NormalSzie = self.shopList.normalGrid:GetComponent("RectTransform").sizeDelta
        ItemContent:GetComponent("RectTransform").sizeDelta = Vector3.New(911,237 + NormalSzie.y + 55,0)
    end,0.3,1,true):Start()
end

return PanelSmallShop