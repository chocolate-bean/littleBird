local PanelNewVipHelper = class("PanelNewVipHelper")

function PanelNewVipHelper:ctor(hideBtn)
    self.hideBtn = hideBtn
    self.NoticeList = clone(GameManager.GameConfig.NoticeList)
    resMgr:LoadPrefabByRes("Special", { "PanelNewVipHelper" }, function(objs)
        self:initView(objs)
    end)
end

function PanelNewVipHelper:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelNewVipHelper"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    self.view.transform:SetParent(parent.transform)
    self.view:scale(Vector3.one)
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
end

function PanelNewVipHelper:show()
    
    GameManager.PanelManager:addPanel(self,true,0)
end

function PanelNewVipHelper:initProperties()
    self.vipItems     = {}
    self.specialItems = {}
    self.curVipLevel  = 1
    self.redpacketUIs = {}
end

function PanelNewVipHelper:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    -- 初始化VIPItem
    self:initPanelVipItem()
    -- 初始化PanelSpecial
    self:initPanelSpecial()
    -- 初始化VIP描述
    self:initPanelVipDes()

    self.btnSub = self.view.transform:Find("btnLeft").gameObject
    self.btnSub:addButtonClick(function()
        self:changePropNum(false)
    end)
    self.btnAdd = self.view.transform:Find("btnRight").gameObject
    self.btnAdd:addButtonClick(function()
        self:changePropNum(true)
    end)

    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelSpecial/Bg/Text (1)").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelSpecial/text1").gameObject

    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function PanelNewVipHelper:initUIDatas()
    http.VIPConfig(
        function(callData)
            if callData and callData.flag == 1 then
                local current = tonumber(callData.user.vip_current) 
                local goal = tonumber(callData.upgrade) 

                if tonumber(callData.user.vip_level == 10) then
                    self.progressBar:GetComponent("Slider").value = 1
                    self.LevelProgress:GetComponent("Text").text = "MAX"

                    self.curVip:GetComponent("Text").text = "VIP10"
                    self.wantVip:SetActive(false)
                    self.desText:SetActive(false)
                else
                    local process = ""..current.."/"..goal
                    self.progressBar:GetComponent("Slider").value = current/goal
                    self.LevelProgress:GetComponent("Text").text = process
    
                    self.curVip:GetComponent("Text").text = "VIP"..callData.user.vip_level
                    self.wantVip:GetComponent("Text").text = "VIP"..(tonumber(callData.user.vip_level) + 1)
                    self.desText:GetComponent("Text").text = T("还差 ")..(goal - current)..T(" 元，即可获得更高级的VIP权限")
                end

                self.vipData = callData.cannon
                self:initSelfVipData()
            end
        end,
        function(callData)
        end
    )

    if self.hideBtn then
        self.btnGoto:SetActive(false)
    end
end

function PanelNewVipHelper:initSelfVipData()
    self.curVipLevel = GameManager.UserData.viplevel
    Timer.New(function()
        if isFKBY() then
            self:changeVip()
        else
            self:moveGrid()
        end
    end,0.1,1,true):Start()

    for i = 1, 10 do 
        if GameManager.UserData.viplevel < i then
            local lock = self.vipItems[i].transform:Find("Item/lock").gameObject
            lock:SetActive(true)
        end
    end

    if GameManager.UserData.viplevel <= 2 then
        self.VipIcon:setSprite("Images/SenceMainHall/Vip/1")
    elseif GameManager.UserData.viplevel <= 4 then
        self.VipIcon:setSprite("Images/SenceMainHall/Vip/2")
    elseif GameManager.UserData.viplevel <= 6 then
        self.VipIcon:setSprite("Images/SenceMainHall/Vip/3")
    elseif GameManager.UserData.viplevel <= 8 then
        self.VipIcon:setSprite("Images/SenceMainHall/Vip/4")
    elseif GameManager.UserData.viplevel <= 10 then
        self.VipIcon:setSprite("Images/SenceMainHall/Vip/5")
    end
end

function PanelNewVipHelper:changePropNum(isAdd)
    if isAdd then
        self.curVipLevel = self.curVipLevel + 1
        if self.curVipLevel > 10 then
            self.curVipLevel = 10
        end
    else
        self.curVipLevel = self.curVipLevel - 1
        if self.curVipLevel < 1 then
            self.curVipLevel = 1
        end
    end

    if isFKBY() then
        self:changeVip()
    else
        self:moveGrid()
    end
end

function PanelNewVipHelper:changeVip()
    if self.curVipLevel == 0 then
        self.curVipLevel = 1
    end

    for k,vipItem in pairs(self.vipItems) do
        vipItem:SetActive(false)
    end

    self.vipItems[self.curVipLevel]:SetActive(true)

    -- 终止当前的http请求，主要是图片相关的请求，减少www压力
    wwwMgr:StopHttp();
    self:setSpecialData()
end

function PanelNewVipHelper:moveGrid()
    if self.curVipLevel == 0 then
        self.curVipLevel = 1
    end
    local itemPos = self.vipItems[self.curVipLevel].transform.localPosition
    self.grid.transform:DOLocalMove(Vector3.New(-itemPos.x,60,0), 0.5)

    for i = 1 ,10 do
        local item = self.vipItems[i].transform:Find("Item").gameObject
        item.transform:DOScale(Vector3.New(0.8, 0.8, 0), 0.5)
        local bg = self.vipItems[i].transform:Find("Item/bg").gameObject
        bg:GetComponent('Image').color = Color.New(0.5, 0.5, 0.5, 0.7)
        local icon = self.vipItems[i].transform:Find("Item/icon").gameObject
        icon:GetComponent('Image').color = Color.New(0.5, 0.5, 0.5, 0.7)
    end

    local curItem = self.vipItems[self.curVipLevel].transform:Find("Item").gameObject
    curItem.transform:DOScale(Vector3.New(1.1, 1.1, 0), 0.5)
    local curBg = self.vipItems[self.curVipLevel].transform:Find("Item/bg").gameObject
    curBg:GetComponent('Image').color = Color.New(1, 1, 1, 1)
    local curIcon = self.vipItems[self.curVipLevel].transform:Find("Item/icon").gameObject
    curIcon:GetComponent('Image').color = Color.New(1, 1, 1, 1)

    -- 终止当前的http请求，主要是图片相关的请求，减少www压力
    wwwMgr:StopHttp();
    self:setSpecialData()
end

function PanelNewVipHelper:setSpecialData()
    if isFKBY() then
        self.SpecialVipText:setText("VIP"..self.curVipLevel)
        self.VipTitle:setText("VIP"..self.curVipLevel)
    else
        TMPHelper.setText(self.SpecialVip, "VIP"..self.curVipLevel..T("特权"))
    end
    
    self.SpecialMoney:setText(self.vipData[self.curVipLevel].wealthGod)
    self.SpecialText1:setText(self.vipData[self.curVipLevel].jewelLimit..T("次"))
    self.SpecialText2:setText(self.vipData[self.curVipLevel].loginReward..T("次"))
    self.SpecialText3:setText(self.vipData[self.curVipLevel].degree)

    -- 0是不显示(没有冰冻效果) 1是显示(有冰冻效果)
    showOrHide(self.vipData[self.curVipLevel].iceSwitch == 1, self.iceInfo)

    for i = 1, 4 do
        local icon = self.specialItems[i].transform:Find("Image").gameObject
        GameManager.ImageLoader:loadImage(self.vipData[self.curVipLevel].list[i].pic,function (success, sprite)
            if success and sprite then
                if self.view and icon then
                    icon:GetComponent('Image').sprite = sprite
                    icon:GetComponent('Image'):SetNativeSize()
                end
            end
        end)

        local text = self.specialItems[i].transform:Find("Text").gameObject
        text:setText(self.vipData[self.curVipLevel].list[i].text)
    end
end

-- 初始化VIP Item
function PanelNewVipHelper:initPanelVipItem()
    self.grid = self.view.transform:Find("PanelVipItem/Grid").gameObject
    for i = 1, 10 do
        local vipItem = self.view.transform:Find("PanelVipItem/Grid/VipItem"..i).gameObject
        table.insert(self.vipItems, vipItem)

        if isFKBY() then
        else
            vipItem:addButtonClick(function()
                self.curVipLevel = i
                self:moveGrid()
            end)
        end
    end
end

-- 初始化VIP特权
function PanelNewVipHelper:initPanelSpecial()
    for i = 1, 4 do
        local specialItem = self.view.transform:Find("PanelSpecial/item"..i).gameObject
        table.insert(self.specialItems, specialItem)
    end

    self.SpecialVip = self.view.transform:Find("PanelSpecial/VipLevel").gameObject
    self.SpecialMoney = self.view.transform:Find("PanelSpecial/Money").gameObject
    self.SpecialText1 = self.view.transform:Find("PanelSpecial/text1").gameObject
    self.SpecialText2 = self.view.transform:Find("PanelSpecial/text2").gameObject
    self.SpecialText3 = self.view.transform:Find("PanelSpecial/text3").gameObject
    self.iceInfo      = self.view.transform:Find("PanelSpecial/Bg/iceInfo").gameObject
    hide(self.iceInfo)

    if isFKBY() then
        self.SpecialVipText = self.view.transform:Find("PanelSpecial/VipText").gameObject
        self.VipTitle = self.view.transform:Find("PanelSpecial/VipTitle").gameObject
    end
end

-- 初始化VIP描述
function PanelNewVipHelper:initPanelVipDes()
    -- 升级进度
    self.LevelProgress = self.view.transform:Find("PanelVipDes/progressBar/Text").gameObject
    -- 进度条
    self.progressBar = self.view.transform:Find("PanelVipDes/progressBar").gameObject
    -- 当前VIP等级
    self.curVip = self.view.transform:Find("PanelVipDes/curVip").gameObject
    -- 下一级
    self.wantVip = self.view.transform:Find("PanelVipDes/wantVip").gameObject
    -- 描述
    self.desText = self.view.transform:Find("PanelVipDes/DesText").gameObject
    -- Vip图标
    self.VipIcon = self.view.transform:Find("PanelVipDes/icon").gameObject

    -- 提升btnGoto
    self.btnGoto = self.view.transform:Find("PanelVipDes/btnGoto").gameObject
    UIHelper.AddButtonClick(self.btnGoto,function()
        GameManager.SoundManager:PlaySound("clickButton")
        self:onClose()
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.VIP
        -- local PanelShop = import("Panel.Shop.PanelShop").new()
        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
    end)
end

function PanelNewVipHelper:onClose()
    wwwMgr:StopHttp();
    destroy(self.view)
    self.view = nil
end

return PanelNewVipHelper