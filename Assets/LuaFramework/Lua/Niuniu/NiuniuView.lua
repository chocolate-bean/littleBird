local NiuniuView    = class("NiuniuView")
local PokerCard     = require("Niuniu/PokerCard")
local SeatView      = require("Niuniu/SeatView")
local HDDJController = require("Niuniu/HDDJController")

NiuniuView.CardPos = {
    [1] = {x = -60 + 50,     y = 313},
    [2] = {x = -30 + 50,     y = 313},
    [3] = {x =   0 + 50,     y = 313},
    [4] = {x =  30 + 50,     y = 313},
    [5] = {x =  60 + 50,     y = 313},

    [6] = {x = -390  - 10,    y = -140},
    [7] = {x = -360  - 10,    y = -140},
    [8] = {x = -330  - 10,    y = -140},
    [9] = {x = -300  - 10,    y = -140},
    [10] = {x = -270 - 10,   y = -140},

    [11] = {x = -170,   y = -140},
    [12] = {x = -140,   y = -140},
    [13] = {x = -110,   y = -140},
    [14] = {x = -80,    y = -140},
    [15] = {x = -50,    y = -140},

    [16] = {x = 50,     y = -140},
    [17] = {x = 80,     y = -140},
    [18] = {x = 110,    y = -140},
    [19] = {x = 140,    y = -140},
    [20] = {x = 170,    y = -140},

    [21] = {x = 270 + 10,    y = -140},
    [22] = {x = 300 + 10,    y = -140},
    [23] = {x = 330 + 10,    y = -140},
    [24] = {x = 360 + 10,    y = -140},
    [25] = {x = 390 + 10,    y = -140},
}

NiuniuView.ChipAreaPos = {
    [1] = {x = -419 + 30, y = -90 + 60},
    [2] = {x = -198 + 30, y = -90 + 60},
    [3] = {x = 25   + 30, y = -90 + 60},
    [4] = {x = 243  + 30, y = -90 + 60},
}

NiuniuView.SeatPos = {
    [1] = {x = -570,    y = 200},-- 左1
    [2] = {x = -570,    y = 55},-- 左2
    [3] = {x = -570,    y = -85},-- 左3
    [4] = {x =  570,    y = 200},-- 右1
    [5] = {x =  570,    y = 55},-- 右2
    [6] = {x =  570,    y = -85},-- 右3
    [7] = {x = -580,    y = -310},-- 剩余
    [8] = {x = -420,    y = -310},-- 自己
    [9] = {x = -200,    y = 320},-- 庄家
    [10] = {x = -0,     y = -202},-- 奖池
}

NiuniuView.SelectChipItem = {
    [1] = 100,
    [2] = 1000,
    [3] = 10000,
    [4] = 100000,
    [5] = 1000000,
}

NiuniuView.SpecialCardText = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 2,
    [9] = 2,
    [10] = 2,
    [11] = 3,
    [12] = 3,
    [13] = 3,
    [14] = 3,
}

function NiuniuView:ctor(controller,objs)
    self.controller_ = controller
    self.HDDJController = HDDJController.new()

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NiuniuView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self:onEnter()
    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()
end

function NiuniuView:onEnter()
    GameManager.SoundManager:playSomething()
    GameManager.SoundManager:ChangeBGM("niuniu/bg")
end

function NiuniuView:initProperties(objs)
    self.pokerCard = objs[1]
    self.chip = objs[2]
    self.seat = objs[3]

    self.PokerCards         = {}
    self.ChipAreas          = {}
    self.PlayerWinChip      = {}
    self.SeatViews          = {}
    self.Timers             = {}
    self.SlotListNumTexts   = {}
    self.SelfChipItems      = {}
    self.SpecialCards       = {}

    -- 庄家是否要退出
    self.bankerIsWantQuit = false

    -- 存储当前奖池数据
    self.CurSlotListNum   = {}
    -- 下注金额按钮
    self.SlotBtnChip      = {}
    -- 高亮
    self.ChipAreaLights   = {}
    -- 当前选中的下注金额
    self.curSelectChip    = 100

    -- 计时器剩余时间
    self.endTime = 15
    -- 当前状态
    -- 1 下注
    -- 2 结算
    -- 2 等待
    self.state   = 1

    self.SelfChipNum = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }

    self.ChipItems = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
    }

    self.pokerCardItems = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
    }

    self.getSlotListTimer = Timer.New(function()
        GameManager.ServerManager:getNiuniuSlotList()
    end, 0.5, -1, true)
end

function NiuniuView:initUIControls()
    self.PanelPoken   = self.view.transform:Find("PanelPoken").gameObject
    self.PanelSeat    = self.view.transform:Find("PanelSeat").gameObject

    for i = 1, 4 do
        local ChipArea = self.view.transform:Find("PanelChip/ChipArea"..i).gameObject
        self.ChipAreas[i] = ChipArea

        local SlotListNumText = self.view.transform:Find("PanelCenter/AreaBg"..i.."/Title").gameObject
        SlotListNumText:GetComponent('Text').text = ""
        self.SlotListNumTexts[i] = SlotListNumText
        
        local SelfChipNum = self.view.transform:Find("PanelCenter/AreaBg"..i.."/Money").gameObject
        SelfChipNum:GetComponent('Text').text = ""
        self.SelfChipItems[i] = SelfChipNum
        
        local ChipAreaLight = self.view.transform:Find("PanelCenter/AreaBg"..i.."/Light").gameObject
        self.ChipAreaLights[i] = ChipAreaLight

        local SlotBtn = self.view.transform:Find("PanelSlotBtn/btnArea"..i).gameObject
        UIHelper.AddButtonClick(SlotBtn,function()
            self:onSlotBtnClick(i)
        end)
    end

    for i = 1, 5 do
        local SlotBtnChip = self.view.transform:Find("PanelSlotBtn/btnSelectChip"..i).gameObject
        UIHelper.AddButtonClick(SlotBtnChip,function()
            self.currentSelectIndex = i
            self:onSlotBtnChipClick(i)
        end)
        self.SlotBtnChip[i] = SlotBtnChip

        local specialCardImage = self.view.transform:Find("PanelSpecialCard/SpecialCardBg"..i).gameObject
        self.SpecialCards[i] = specialCardImage
    end

    self.StateText          = self.view.transform:Find("StateText").gameObject
    self.RewardText          = self.view.transform:Find("RewardBg/Text").gameObject
    self.btnReward          = self.view.transform:Find("RewardBg").gameObject
    UIHelper.AddButtonClick(self.btnReward,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        local data = self.controller_.config.log
        data.totalBonus = self.curTotalBonus
        local NiuniuHelperPanel = require("Panel.Special.NiuniuHelperPanel").new(data,2)
    end)
    
    self.PanelChip          = self.view.transform:Find("PanelChip").gameObject
    self.PanelPoken         = self.view.transform:Find("PanelPoken").gameObject
    self.CenterLight         = self.view.transform:Find("PanelCenter/centerLight").gameObject

    -- 玩家自己的相关信息
    self.playIcon           = self.view.transform:Find("PanelSeat/seatPlayer/playIcon").gameObject
    self.playName           = self.view.transform:Find("PanelSeat/seatPlayer/playName").gameObject
    self.playMoney          = self.view.transform:Find("PanelSeat/seatPlayer/MoneyBg/playMoney").gameObject
    self.playWinText        = self.view.transform:Find("PanelSeat/seatPlayer/WinChip").gameObject
    self.playChatPanel      = self.view.transform:Find("PanelSeat/seatPlayer/chatPanel").gameObject

    -- 地主的相关信息
    self.bankerIcon             = self.view.transform:Find("PanelSeat/seatBanker/playIcon").gameObject
    self.bankerIconFrame        = self.view.transform:Find("PanelSeat/seatBanker/playIcon/iconFrame").gameObject
    self.bankerName             = self.view.transform:Find("PanelSeat/seatBanker/playName").gameObject
    self.bankerMoney            = self.view.transform:Find("PanelSeat/seatBanker/playMoney").gameObject
    self.bankerWinText          = self.view.transform:Find("PanelSeat/seatBanker/WinChip").gameObject
    self.bankerChatPanel        = self.view.transform:Find("PanelSeat/seatBanker/chatPanel").gameObject
    self.bankerIcon:addButtonClick(buttonSoundHandler(self,self.onBankerClick), false)

    self.redDot1 = self.view.transform:Find("btnHongbao/redDot").gameObject
    self.redDot2 = self.view.transform:Find("btnTask/redDot").gameObject

    self.btnMoney       = self.view.transform:Find("PanelSeat/seatPlayer/MoneyBg").gameObject
    UIHelper.AddButtonClick(self.btnMoney,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.NIUNIUROOM
        -- local PanelShop = import("Panel.Shop.PanelShop").new()
        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
    end)

    self.btnOtherPlayer = self.view.transform:Find("PanelSlotBtn/btnOtherPlayer").gameObject
    UIHelper.AddButtonClick(self.btnOtherPlayer,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.ServerManager:getNiuniuUserList()
    end)

    self.btnTrend = self.view.transform:Find("PanelSlotBtn/btnTrend").gameObject
    UIHelper.AddButtonClick(self.btnTrend,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self.controller_:showTrendPanel()
    end)

    self.btnChat = self.view.transform:Find("PanelSlotBtn/btnChat").gameObject
    UIHelper.AddButtonClick(self.btnChat, buttonSoundHandler(self, function()
        self.controller_:showChatView()
    end))

    self.btnBanker = self.view.transform:Find("PanelSlotBtn/btnBanker").gameObject
    UIHelper.AddButtonClick(self.btnBanker, buttonSoundHandler(self, function()
        if GameManager.UserData.money < self.controller_.config.banker_base then
            GameManager.TopTipManager:showTopTip(T("需要")..formatFiveNumber(self.controller_.config.banker_base)..T("金币才可以上庄"))
        else
            GameManager.ServerManager:getBankerList()
        end
    end))

    self.btnHelp      = self.view.transform:Find("btnHelp").gameObject
    UIHelper.AddButtonClick(self.btnHelp,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        local data = self.controller_.config.log
        data.totalBonus = self.curTotalBonus
        local NiuniuHelperPanel = require("Panel.Special.NiuniuHelperPanel").new(data)
    end)

    self.btnTask      = self.view.transform:Find("btnTask").gameObject
    UIHelper.AddButtonClick(self.btnTask,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self.redDot2:SetActive(false)
        local PanelTask = import("Panel.Task.PanelTask").new(1, 2)
    end)

    self.btnHongbao   = self.view.transform:Find("btnHongbao").gameObject
    UIHelper.AddButtonClick(self.btnHongbao,function()
        GameManager.SoundManager:PlaySound("clickButton")
        self.redDot1:SetActive(false)
        local PanelTotalRedpacket = import("Panel.Operation.PanelTotalRedpacket").new()
    end)
    if GameManager.GameConfig.casinoWin == 1 then
        self.btnHongbao:SetActive(true)
    else
        self.btnHongbao:SetActive(false)
    end

    self.btnClose     = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self.controller_:onReturnKeyClick()
        if GameManager.UserData.mid == self.controller_.bankerMID then
            self.bankerIsWantQuit = true
        end
    end)
end

function NiuniuView:initUIDatas()
    self:CreateSeatView()
    self:onTimerStart()

    self:refashPlayerInfo()
    self:refashPlayerMoney()

    self:GetRedDot()
    
    self.MoneyHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "money", handler(self, self.refashPlayerMoney))
    self.NoticeManager = require("Core/NoticeManager").new(Vector3.New(0,-90,0))
end

function NiuniuView:refashPlayerMoney()
    
    self.playMoney:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    for i = 1 , 5 do 
        self.SlotBtnChip[i]:GetComponent('Button').interactable = true
    end

    if GameManager.UserData.mid == self.controller_.bankerMID then
        for i,item in ipairs(self.SlotBtnChip) do
            local btnLight = item.transform:Find("Light").gameObject
            btnLight:SetActive(false)

            item:GetComponent('Button').interactable = false
        end

        return
    end

    -- 限制不够陪时强制置灰
    local btnInteractable = {
        [1] = 4000,
        [2] = 40000,
        [3] = 400000,
        [4] = 4000000,
    }
    if GameManager.UserData.money < btnInteractable[1] then
        self.SlotBtnChip[5]:GetComponent('Button').interactable = false
        self.SlotBtnChip[4]:GetComponent('Button').interactable = false
        self.SlotBtnChip[3]:GetComponent('Button').interactable = false
        self.SlotBtnChip[2]:GetComponent('Button').interactable = false
    elseif GameManager.UserData.money < btnInteractable[2] then
        self.SlotBtnChip[5]:GetComponent('Button').interactable = false
        self.SlotBtnChip[4]:GetComponent('Button').interactable = false
        self.SlotBtnChip[3]:GetComponent('Button').interactable = false
    elseif GameManager.UserData.money < btnInteractable[3] then
        self.SlotBtnChip[5]:GetComponent('Button').interactable = false
        self.SlotBtnChip[4]:GetComponent('Button').interactable = false
    elseif GameManager.UserData.money < btnInteractable[4] then
        self.SlotBtnChip[5]:GetComponent('Button').interactable = false
    end

    -- 默认下注配置
    local defultBtnMoney
    if self.controller_.config.defultBtnMoney then
        defultBtnMoney = self.controller_.config.defultBtnMoney
    else
        defultBtnMoney = {
            [1] = 100000000,
            [2] = 10000000,
            [3] = 1000000,
            [4] = 100000,
        }
    end
    
    if self.currentSelectIndex then
        if self.SlotBtnChip[self.currentSelectIndex]:GetComponent('Button').interactable then
            return
        else
            self.currentSelectIndex = nil
        end
    end
    if GameManager.UserData.money > defultBtnMoney[1] then
        self:onSlotBtnChipClick(5)
    elseif GameManager.UserData.money > defultBtnMoney[2] then
        self:onSlotBtnChipClick(4)
    elseif GameManager.UserData.money > defultBtnMoney[3] then
        self:onSlotBtnChipClick(3)
    elseif GameManager.UserData.money > defultBtnMoney[4] then
        self:onSlotBtnChipClick(2)
    else
        self:onSlotBtnChipClick(1)
    end
end

function NiuniuView:refashPlayerInfo()
    
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.playIcon,
        callback = function(sprite)
            
            if self.view and self.playIcon then
                self.playIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })
    self.playName:GetComponent('Text').text = GameManager.UserData.name
end

function NiuniuView:refashBankerMoney(money)
    
    self.bankerMoney:GetComponent('Text').text = formatFiveNumber(money)
end

function NiuniuView:refashBankerInfo(uid)
    
    if GameManager.UserData.mid == uid then
        GameManager.TopTipManager:showTopTip(T("您已成功上庄"))
        for i,item in ipairs(self.SlotBtnChip) do
            local btnLight = item.transform:Find("Light").gameObject
            btnLight:SetActive(false)

            item:GetComponent('Button').interactable = false
        end
    end

    http.getUserData(
        uid,
        0,
        0,
        function(callData)
            if callData and callData.flag == 1 then
                dump(callData)
                if self.view then
                    -- 设置玩家头像
                    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                        url = callData.user.micon,
                        sex = tonumber(callData.user.msex),
                        node = self.bankerIcon,
                        callback = function(sprite)
                            
                            if self.view and self.bankerIcon then
                                self.bankerIcon:GetComponent('Image').sprite = sprite
                            end
                        end,
                    })

                    if callData.user.vip_level and tonumber(callData.user.vip_level) ~= 0 then
                        local sp = GameManager.ImageLoader:getVipFrame(callData.user.vip_level)
                        self.bankerIconFrame:GetComponent('Image').sprite = sp
                        self.bankerIconFrame:SetActive(true)
                    else
                        self.bankerIconFrame:SetActive(false)
                    end
                    self.bankerName:GetComponent('Text').text = callData.user.name
                    self.bankerMoney:GetComponent('Text').text = formatFiveNumber(callData.user.money)
                end
            end
        end,
        function(callData)
        end
    )    
end

function NiuniuView:onGameStart(time)
    
    self:SetStateType(1,time)
    self.CenterLight:SetActive(true)
    GameManager.SoundManager:PlaySound("niuniu/start_setRate")
    self.getSlotListTimer:Start()
end

-- 更新座位信息
function NiuniuView:UpdateSeatView(data)
    
    for i = 1,6 do
        self:SetSeatViewPlayer(i,false)
    end

    for i,seatData in pairs(data) do
        local index = seatData.index + 1
        self:SetSeatViewPlayer(index,true,seatData.uid,seatData.seatId - 1)
    end
end

-- 更新注池信息
function NiuniuView:UpdateSlotListInfo(data)
    
    local curSlotList = {}

    for i = 1,4 do
        local moneyPool = data.anteList[i].moneyPool
        self.SlotListNumTexts[i]:GetComponent('Text').text = moneyPool
        curSlotList[i] = moneyPool
    end

    if self.CurSlotListNum == nil or #self.CurSlotListNum == 0 then
        for i = 1,4 do
            if curSlotList[i] > 0 then
                self:MoveChipToArea(7,i,10)
            end
        end
    else
        for i = 1,4 do
            local num = curSlotList[i] - self.CurSlotListNum[i]
            if num > 0 then
                self:MoveChipToArea(7,i,10)
            end
        end
    end
    self.CurSlotListNum = curSlotList
end

-- 广播下注
function NiuniuView:onUserBetonResponse(data)
    
    local curSlotList = {}

    for i = 1,4 do
        local moneyPool = data.anteList[i].moneyPool
        self.SlotListNumTexts[i]:GetComponent('Text').text = moneyPool
        curSlotList[i] = moneyPool
    end

    local slot = data.slot or 0
    --[[
        {"seatId":19,
        "slot":4,
        "curCarry":962437,
        "anteList":[{"moneyPool":29200},{"moneyPool":13000,"index":1},{"moneyPool":28000,"index":2},{"moneyPool":49300,"index":3}],
        "ante":10000}
    ]]
    local index = self:isOnVipSeatWithSeatId(data.seatId)
    if index then
        self.SeatViews[index]:playChipMoveAnmi()
        self:MoveChipToArea(index, slot, 1)
        self.SeatViews[index]:refashPlayerMoney(data.curCarry)
    end

    self.CurSlotListNum = curSlotList
end

-- 自己下助动画
function NiuniuView:playSelfChipAnim(area, num)
    self:MoveChipToArea(8, area, 1)
    self.SelfChipNum[area] = self.SelfChipNum[area] + num
    self.SelfChipItems[area]:GetComponent('Text').text = self.SelfChipNum[area]
end

-- 结算
function NiuniuView:OnBalance(data)
    
    self.getSlotListTimer:Stop()
    local winParams = {}
    local losParams = {}
    local areaParams = {}

    for i = 2,5 do
        local area = i - 1
        areaParams[area] = data.cards[i].isWin
        if data.cards[i].isWin == 1 then
            table.insert(winParams,area)
        else
            table.insert(losParams,area)
        end
    end

    self:PlayCardAnim(data.cards,data.userList[7].betInfo)

    -- -- 移动筹码到庄家
    Timer.New(function()
        if self.view then
            self:MoveToBanker(losParams)
            if #losParams > 0 then
                GameManager.SoundManager:PlaySound("niuniu/coin_fly")
            end
        end
    end, 7, 1, true):Start()

    -- 移动筹码回区域
    if #winParams == 0 then
        -- winParams 为空，则庄家全赢，直接遍历播放扣钱动画
        Timer.New(function()
            if self.view then
                for index = 1,6 do
                    local item = data.userList[index]
                    if item and item.addMoney ~= 0 then
                        self:PlaySeatViewChipAnmi(index, item.addMoney)
                    end
                end

                GameManager.UserData.money = data.userList[7].userMoney
                self:PlaySelfSeatChipAnmi(data.userList[7].addMoney)
                self:PlayBankerSeatChipAnmi(data.userList[8])
            end
        end, 11, 1, true):Start()
    else
        if #losParams == 0 then
            Timer.New(function()
                if self.view then
                    self:MoveBankerToPlayer(winParams)
                end
            end, 9, 1, true):Start()
        else
            Timer.New(function()
                if self.view then
                    self:MoveBackToPlayer(losParams,winParams)
                end
            end, 9, 1, true):Start()
        end

        -- 分发筹码
        Timer.New(function()
            if self.view then
                self.PanelChip.transform:SetSiblingIndex(7)

                local playSeatWinAnim = function (item, index, winAreas)
                    
                    for area = 1, 4 do
                        local betInfoItem = item.betInfo[area]
                        if betInfoItem and betInfoItem.count and betInfoItem.count > 0 then
                            if table.keyof(winAreas,area) then
                                self:MoveChipForWin(index, area, betInfoItem.count)
                            end
                        end
                    end
                end

                for index = 1,6 do
                    local item = data.userList[index]
                    if item and item.uid ~= GameManager.UserData.mid then
                        playSeatWinAnim(item, index, winParams)
                        if item.addMoney ~= 0 then
                            Timer.New(function()
                                self:PlaySeatViewChipAnmi(index, item.addMoney)
                            end, 0.5, 1, true):Start()
                        end
                    end

                    if self.SeatViews[index].hasPlayer then
                        self.SeatViews[index]:refashPlayerMoney(item.userMoney)
                    end
                end
                playSeatWinAnim(data.userList[7], 8, winParams)

                GameManager.UserData.money = data.userList[7].userMoney
                self:PlaySelfSeatChipAnmi(data.userList[7].addMoney)
                self:PlayBankerSeatChipAnmi(data.userList[8])

                self:MoveChipForOther()
            end
        end, 11, 1, true):Start()
    end

    -- 清理开始下一轮
    Timer.New(function()
        if self.view then
            self.curTotalBonus = data.totalBonus
            self.RewardText:GetComponent('Text').text = string.formatNumberThousands(data.totalBonus)
            self.controller_.config.totalBonus = data.totalBonus
            self.controller_:refashTrend(areaParams)
            self:CleanChipAndPoker()
            self:GetRedDot()
            
            if self.bankerIsWantQuit == true then
                self.controller_:onReturnKeyClick()
            end
        end
    end, 13, 1, true):Start()
end

function NiuniuView:GetRedDot()
    -- 检查红点
    http.checkRedDot(
        function(callData)
            
            if callData then
                GameManager.GameFunctions.refashRedDotData(callData)

                if callData.winchallenge.dot == 1 then
                    self.redDot1:SetActive(true)
                end

                if callData.task.dot == 1 then
                    self.redDot2:SetActive(true)
                end
            end
        end,
        function (callData)
            
        end
    )
end

function NiuniuView:onTimerStart()
    
    if self.timer then
		self:onTimerEnd()
    end

    self.timer = Timer.New(function()
        self:onTimer()
    end,1,-1,true)
    self.timer:Start()
end

function NiuniuView:onTimer()
    self.endTime = self.endTime - 1

    if self.endTime < 0 then
        self.endTime = 0
    end

    local str
    if self.state == 1 then
        str = T("请下注 ")..self.endTime
    elseif self.state == 2 then
        str = T("正在结算")
    elseif self.state == 3 then
        str = T("休息一下 ")..self.endTime
    end

    self.StateText:GetComponent('Text').text = str
end

function NiuniuView:onTimerEnd()
    
    if self.timer then
		self.timer:Stop()
	end
end

function NiuniuView:SetStateType(type,time)
    
    self.state = type

    if time then
        self.endTime = time
    else
        self.endTime = 16
    end

    self:onTimer()
end

function NiuniuView:CreateSeatView()
    
    for i = 1,6 do
        local params = {
            parent      = self.PanelSeat.transform,
            scale       = Vector3.one,
            position    = Vector3.New(NiuniuView.SeatPos[i].x,NiuniuView.SeatPos[i].y,0),
            index       = i,
        }

        local seatView = SeatView.new(newObject(self.seat), params)
        self.SeatViews[i] = seatView
    end
end

function NiuniuView:SetSeatViewPlayer(index, state, mid, seatid)
    
    if state == true then
        self.SeatViews[index]:setPlayer(mid,seatid)
    else
        self.SeatViews[index]:setNoPlayer()
    end
end

function NiuniuView:PlaySeatViewChipAnmi(index,money)
    
    self.SeatViews[index]:playChipAnmi(money)
end

function NiuniuView:PlaySelfSeatChipAnmi(money)
    
    if money == 0 then
        return
    end

    local satrtPos = Vector3.New(-270, -240, 0)
    local endPos = Vector3.New(-270, -220, 0)

    self.playWinText.transform.localPosition = satrtPos
    if money > 0 then
        self.playWinText:GetComponent('Text').text = "<color=#FFFF00>+"..money.."</color>"
        GameManager.SoundManager:PlaySound("niuniu/wingold")
    else
        self.playWinText:GetComponent('Text').text = "<color=#999999>"..money.."</color>"
    end

    self.playWinText:SetActive(true)
    self.playWinText.transform:DOLocalMove(endPos, 0.5)

    Timer.New(function()
        self.playWinText:SetActive(false)
    end, 1.5, 1, true):Start()
end

function NiuniuView:PlayBankerSeatChipAnmi(data)
    
    local money = data.addMoney
    self.bankerMoney:GetComponent('Text').text = formatFiveNumber(data.userMoney)
    if money == 0 then
        return
    end

    local satrtPos = Vector3.New(0, 240, 0)
    local endPos = Vector3.New(0, 260, 0)

    self.bankerWinText.transform.localPosition = satrtPos
    if money > 0 then
        self.bankerWinText:GetComponent('Text').text = "<color=#FFFF00>+"..money.."</color>"
        GameManager.SoundManager:PlaySound("niuniu/wingold")
    else
        self.bankerWinText:GetComponent('Text').text = "<color=#999999>"..money.."</color>"
    end

    self.bankerWinText:SetActive(true)
    self.bankerWinText.transform:DOLocalMove(endPos, 0.5)

    Timer.New(function()
        self.bankerWinText:SetActive(false)
    end, 1.5, 1, true):Start()
end

function NiuniuView:PlayCardAnim(cards,betInfo)
    
    self:SetStateType(2)
    self:MovePokerCard(1,cards[1])
    self:showCards(1,cards[1])
    
    for i = 2, 5 do
        Timer.New(function()
            self:MovePokerCard(i,cards[i],betInfo[i-1])
        end, (i - 1)  * 0.5, 1, true):Start()

        Timer.New(function()
            self:showCards(i,cards[i],betInfo[i-1])
        end, (i - 1)  * 0.8, 1, true):Start()
    end
end

-- 移动玩家牌
function NiuniuView:MovePokerCard(index,cards,betInfo)
    -- index 为 1-4，4组
    -- 1-5，6-10，11-15，16-20
    for i = 1, 5 do
        if self.view then
            local params = {
                parent      = self.PanelPoken.transform,
                scale       = Vector3.New(0.6, 0.6, 0.6),
                position    = Vector3.New(0, 50, 0),
            }

            local pokerCard = PokerCard.new(newObject(self.pokerCard), params)
            pokerCard:setCard(cards.cards[i].card)
            local curIndex = (index - 1) * 5 + i
            pokerCard:playMoveAnmi(Vector3.New(NiuniuView.CardPos[curIndex].x, NiuniuView.CardPos[curIndex].y, 0),0.1 + i * 0.05)
            
            table.insert(self.pokerCardItems[index],pokerCard)

            table.insert(self.PokerCards,pokerCard)
        end
    end
    GameManager.SoundManager:PlaySound("niuniu/send_poker")
end

-- 翻牌
function NiuniuView:showCards(index,cards,betInfo)
    
    Timer.New(function()
        if self.view then
            for i,pokerCard in ipairs(self.pokerCardItems[index]) do
                pokerCard:showFront()
            end

            GameManager.SoundManager:PlaySound("niuniu/niu_"..cards.specialCard)
            self.SpecialCards[index]:SetActive(true)
            local image = self.SpecialCards[index].transform:Find("SpecialCard").gameObject
            local num = cards.specialCard + 1
            image:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/SenceNiuniu/SpecialCard/"..num)
            -- 下面的牌才有betInfo，庄家的牌没有
            if betInfo then
                local text = self.SpecialCards[index].transform:Find("Text").gameObject
                local winChip = ""
                if betInfo.ante == 0 and betInfo.count == 0 then
                    winChip = T("<color=#D6E3FF>没有下注</color>")
                else
                    if betInfo.bonus > 0 then
                        self.ChipAreaLights[index - 1]:SetActive(true)
                        winChip = "x"..betInfo.times.."    +"..formatFiveNumber(betInfo.bonus)
                    else
                        winChip = "x"..betInfo.times.."    "..formatFiveNumber(betInfo.bonus)
                    end
                end
                text:GetComponent('Text').text = winChip
            end
        end
    end, 0.3 + 2, 1, true):Start()
end

-- 上筹码
--[[
    @desc: 
    author:zhangyi
    time:2018-08-10 11:02:20
    --@posFrom: 出发位置的索引
	--@posTarget:目标位置索引
	--@chipNum: 筹码数量
    @return:
]]
function NiuniuView:MoveChipToArea(posFrom,posTarget,chipNum)
    if chipNum == 1 then
        local item = newObject(self.chip)
        item.transform:SetParent(self.ChipAreas[posTarget].transform)
        item.transform.localScale = Vector3.New(0.7,0.7,0.7)
        item.transform.localPosition = Vector3.New(NiuniuView.SeatPos[posFrom].x,NiuniuView.SeatPos[posFrom].y,0)

        Timer.New(function()
            local posX = NiuniuView.ChipAreaPos[posTarget].x + math.random() * 120
            local posY = NiuniuView.ChipAreaPos[posTarget].y + math.random() * 60

            if self.view then
                self:playChipSound(1)
                item.transform:DOLocalMove(Vector3.New(posX, posY, 0), 0.5)
            end
        end, 0.1, 1, true):Start()

        table.insert(self.ChipItems[posTarget], item)
        return
    end
    for i=1,chipNum do
        local item = newObject(self.chip)
        item.transform:SetParent(self.ChipAreas[posTarget].transform)
        item.transform.localScale = Vector3.New(0.7,0.7,0.7)
        item.transform.localPosition = Vector3.New(NiuniuView.SeatPos[posFrom].x,NiuniuView.SeatPos[posFrom].y,0)

        Timer.New(function()
            local posX = NiuniuView.ChipAreaPos[posTarget].x + math.random() * 120
            local posY = NiuniuView.ChipAreaPos[posTarget].y + math.random() * 60

            if self.view then
                self:playChipSound(1)
                item.transform:DOLocalMove(Vector3.New(posX, posY, 0),0.3)
            end
        end, i * 0.1, 1, true):Start()

        table.insert(self.ChipItems[posTarget], item)
    end
end

-- 庄家全陪
function NiuniuView:MoveBankerToPlayer()
    for i, v in pairs(self.CurSlotListNum) do
        local area = i
        local money = tonumber(v)
        if money ~= 0 then
            for i = 1,50 do
                local item = newObject(self.chip)
                item.transform:SetParent(self.ChipAreas[area].transform)
                item.transform.localScale = Vector3.New(0.7,0.7,0.7)
                item.transform.localPosition = Vector3.New(NiuniuView.SeatPos[9].x,NiuniuView.SeatPos[9].y,0)
    
                local randomTime = math.random(100)
                Timer.New(function()
                    local posX = NiuniuView.ChipAreaPos[area].x + math.random() * 120
                    local posY = NiuniuView.ChipAreaPos[area].y + math.random() * 60
        
                    if self.view then
                        item.transform:DOLocalMove(Vector3.New(posX, posY, 0),0.3)
                    end
                end, 0.01 * randomTime * 1, 1, true):Start()
        
                table.insert(self.ChipItems[area], item)
            end
        end
    end

    self:playChipSound(20)
end

-- 移动筹码到庄家
--[[
    @desc: 
    author:zhangyi
    time:2018-08-10 10:56:13
    --@data: 输掉的堆数对应的索引
    @return:
]]
function NiuniuView:MoveToBanker(data)
    
    for k,v in pairs(data) do
        for i,item in ipairs(self.ChipItems[v]) do
            local randomTime = math.random(100)
            Timer.New(function()
                if self.view then
                    item.transform:DOLocalMove(Vector3.New(NiuniuView.SeatPos[9].x,NiuniuView.SeatPos[9].y,0),0.5)
                end
            end, 0.01 * randomTime * 0.5, 1, true):Start()
        end
    end

    if #data ~= 0 then
        self:playChipSound(20)
    end
end

-- 筹码返回到指定堆
--[[
    @desc: 
    author:zhangyi
    time:2018-08-10 10:56:49
    --@data:输掉的堆数对应的索引集合
	--@target: 赢得堆数对应的索引集合
    @return:
]]
function NiuniuView:MoveBackToPlayer(data,target)
    for k,v in pairs(data) do
        if self.CurSlotListNum[v] == nil or self.CurSlotListNum[v] == 0 then
            return
        end
        for i,item in ipairs(self.ChipItems[v]) do
            local posX
            local posY

            local want = (#target == 1) and 1 or math.random(#target)

            posX = NiuniuView.ChipAreaPos[target[want]].x + math.random() * 120
            posY = NiuniuView.ChipAreaPos[target[want]].y + math.random() * 60

            item.transform:SetParent(self.ChipAreas[target[want]].transform)
            table.insert(self.ChipItems[target[want]],item)
            self.ChipItems[v][i] = nil
            
            local randomTime = math.random(100)
            Timer.New(function()
                if self.view then
                    item.transform:DOLocalMove(Vector3.New(posX, posY, 0),0.5)
                end
            end, 0.01 * randomTime * 0.5, 1, true):Start()
        end

        self:playChipSound(5)
    end
end

-- 分发筹码到指定座位
--[[
    @desc: 
    author:zhangyi
    time:2018-08-10 11:44:54
    --@seatIndex:移动到的座位索引
	--@areaFrom:来源的区域索引
	--@Num: 数量
    @return:
]]
function NiuniuView:MoveChipForWin(seatIndex,areaFrom,Num)
    
    for i=1,Num do
        local item = table.remove(self.ChipItems[areaFrom],1)
        local randomTime = math.random(100)
        Timer.New(function()
            if self.view then
                item.transform:DOLocalMove(Vector3.New(NiuniuView.SeatPos[seatIndex].x, NiuniuView.SeatPos[seatIndex].y, 0),0.5)
            end
        end, 0.01 * randomTime * 0.5, 1, true):Start()

        table.insert(self.PlayerWinChip,item)
    end
end

-- 分发剩余的筹码到其它人
function NiuniuView:MoveChipForOther()
    for k,v in ipairs(self.ChipItems) do
        for i,item in ipairs(v) do
            local randomTime = math.random(100)
            Timer.New(function()
                if self.view then
                    item.transform:DOLocalMove(Vector3.New(NiuniuView.SeatPos[7].x, NiuniuView.SeatPos[7].y, 0),0.5)
                end
            end, 0.01 * randomTime * 0.5, 1, true):Start()
        end
    end

    self:playChipSound(20)
end

-- 下注
function NiuniuView:onSlotBtnClick(index)
    if GameManager.UserData.money >= self.curSelectChip then
        GameManager.ServerManager:soltsBet(index - 1, self.curSelectChip, 0)
    else
        GameManager.TopTipManager:showTopTip(T("您的金币不足"))
    end
end

-- 选择下注金额
function NiuniuView:onSlotBtnChipClick(index)
    for i,item in ipairs(self.SlotBtnChip) do
        local btnLight = item.transform:Find("Light").gameObject
        btnLight:SetActive(false)
    end

    local curLight = self.SlotBtnChip[index].transform:Find("Light").gameObject
    curLight:SetActive(true)

    self.curSelectChip = NiuniuView.SelectChipItem[index]

    -- self.HDDJController:playHDDJWithType(index,NiuniuView.SeatPos[8],NiuniuView.SeatPos[index])
end

function NiuniuView:onBankerClick()
    
    if self.controller_.bankerMID and self.controller_.bankerMID ~= 1 then
        local PanelOtherInfoBig = import("Panel.PlayInfo.PanelOtherInfoBig").new(self.controller_.bankerMID, function(index)
            local times = 1
            http.useToolProp(
                times,
                function(callData)
                    if callData and callData.flag == 1 then
                        GameManager.ServerManager:sendProp(index, self.controller_.bankerMID, times)
                        GameManager.UserData.money = callData.latest_money
                    else
                        GameManager.TopTipManager:showTopTip(T("发送失败"))
                    end
                end,
                function(errData)
                    GameManager.TopTipManager:showTopTip(T("发送失败"))
                end
            )
        end)
    end
end

-- 播放筹码音效
function NiuniuView:playChipSound(count)
    if count == 1 then
        GameManager.SoundManager:PlaySoundWithNewSource("niuniu/setrategold")
        return
    end

    for i = 1, count do
        local randomTime = math.random(100)
        Timer.New(function()
            if self.view then
                GameManager.SoundManager:PlaySoundWithNewSource("niuniu/setrategold")
            end
        end, 0.01 * randomTime * 0.5, 1, true):Start()
    end
end

function NiuniuView:playerChatAnmi(message)
    
    local chatText = self.playChatPanel.transform:Find("Des").gameObject:GetComponent('Text')
    local chatBg = self.playChatPanel.transform:Find("ChatBg").gameObject

    chatText.text = message

    local chatTextSizeHeight = chatText.preferredHeight
    local chatTextSizeWidth = chatText.preferredWidth

    if chatTextSizeWidth > 307 then
        chatTextSizeWidth = 295
    end

    local bgSize = chatBg:GetComponent("RectTransform").sizeDelta
    chatBg:GetComponent("RectTransform").sizeDelta = Vector3.New(chatTextSizeWidth + 45,chatTextSizeHeight + 30,0)

    self.playChatPanel:SetActive(true)
    Timer.New(function()
        if self.view then
            self.playChatPanel:SetActive(false)
        end
    end, 1.5, 1, true):Start()
end

function NiuniuView:bankerChatAnmi(message)
    
    local chatText = self.bankerChatPanel.transform:Find("Des").gameObject:GetComponent('Text')
    local chatBg = self.bankerChatPanel.transform:Find("ChatBg").gameObject

    chatText.text = message

    local chatTextSizeHeight = chatText.preferredHeight
    local chatTextSizeWidth = chatText.preferredWidth

    if chatTextSizeWidth > 435 then
        chatTextSizeWidth = 435
    end

    local bgSize = chatBg:GetComponent("RectTransform").sizeDelta
    chatBg:GetComponent("RectTransform").sizeDelta = Vector3.New(chatTextSizeWidth + 45,chatTextSizeHeight + 30,0)

    self.bankerChatPanel:SetActive(true)
    Timer.New(function()
        if self.view then
            self.bankerChatPanel:SetActive(false)
        end
    end, 1.5, 1, true):Start()
end

-- 互动道具动画
function NiuniuView:playHDDJAnmi(count, index, fromMid, tarMid)
    -- 判断发送者是不是自己或者座位上的人
    local fromIndex
    local tarIndex

    if fromMid == GameManager.UserData.mid then
        fromIndex = 8
    elseif fromMid == self.controller_.bankerMID then
        fromIndex = 9
    elseif self:isOnVipSeatWithMid(fromMid) then
        fromIndex = self:isOnVipSeatWithMid(fromMid)
    else
        fromIndex = 7
    end

    if tarMid == GameManager.UserData.mid then
        tarIndex = 8
    elseif tarMid == self.controller_.bankerMID then
        tarIndex = 9
    elseif self:isOnVipSeatWithMid(tarMid) then
        tarIndex = self:isOnVipSeatWithMid(tarMid)
    else
        tarIndex = 7
    end

    if fromIndex ~= 7 and tarIndex ~= 7 then
        self.HDDJController:playHDDJWithCount(count, index, NiuniuView.SeatPos[fromIndex], NiuniuView.SeatPos[tarIndex])
    end
end

-- 聊天动画
function NiuniuView:playChatAnmi(mid,message)
    -- 判断发送者是不是自己或者座位上的人
    local index = self:isOnVipSeatWithMid(mid) 

    if mid == GameManager.UserData.mid then
        self:playerChatAnmi(message)
    elseif mid == self.controller_.bankerMID then
        self:bankerChatAnmi(message)
    end

    if index then
        self.SeatViews[index]:playChatAnmi(message)
    end
end

-- Emoji动画
function NiuniuView:PlayEmojiAnmi(mid,faceId,fType)
    -- 判断发送者是不是自己或者座位上的人
    local index = self:isOnVipSeatWithMid(mid)

    if mid == GameManager.UserData.mid then
        self.HDDJController:playEmojiWithType(fType,faceId,NiuniuView.SeatPos[8])
    elseif mid == self.controller_.bankerMID then
        self.HDDJController:playEmojiWithType(fType,faceId,NiuniuView.SeatPos[9])
    end

    if index then
        self.HDDJController:playEmojiWithType(fType,faceId,NiuniuView.SeatPos[index])
    end
end

-- 根据seatId判断是否在vip座位上
function NiuniuView:isOnVipSeatWithSeatId(seatId)
    for index = 1, 6 do
        if self.SeatViews[index].seatId == seatId then
            return index
        end
    end

    return nil
end

-- 根据seatId判断是否在vip座位上
function NiuniuView:isOnVipSeatWithMid(mid)
    for i = 1, 6 do
        if self.SeatViews[i].mid == mid then
            return i
        end
    end

    return nil
end

-- 清理筹码，清理牌
function NiuniuView:CleanChipAndPoker()
    
    -- 清理桌上的牌
    for k,item in ipairs(self.PokerCards) do
        item:destroy()
    end

    for i,item in ipairs(self.ChipAreas) do
        removeAllChild(item.transform)
    end

    removeAllChild(self.PanelPoken.transform)

    -- 隐藏特殊牌型的显示
    for k,item in ipairs(self.SpecialCards) do
        item:SetActive(false)
    end

    self.CenterLight:SetActive(false)
    self.PanelChip.transform:SetSiblingIndex(5)

    -- 清理字段
    self.PokerCards = {}
    self.PlayerWinChip = {}
    self.CurSlotListNum = {}

    for i = 1,4 do
        self.SlotListNumTexts[i]:GetComponent('Text').text = ""
        self.SelfChipItems[i]:GetComponent('Text').text = ""
        self.ChipAreaLights[i]:SetActive(false)
        self.SelfChipNum[i] = 0
        self.ChipItems[i] = {}
    end

    self.pokerCardItems = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
    }

    self:SetStateType(3,self.controller_.config.time_control.show_time or 15)
end

function NiuniuView:onCleanUp()
    
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "money", self.MoneyHandleId)
    self.getSlotListTimer:Stop()
    self:onTimerEnd()
    self:CleanChipAndPoker()

    if self.NoticeManager then
        self.NoticeManager:onClean()
    end
    
    self.view = nil
end

return NiuniuView