local SeatView = class("SeatView")

SeatView.ANIMATION_TIME = 0.2

function SeatView:ctor(prefab, params)
    self:initView(prefab, params)
end

function SeatView:initView(prefab, params)
    self.view = prefab
    self.view.name = "SeatView"

    self.index = params.index
    self.pos = params.position
    if params then
        
        self.view.transform:SetParent(params.parent.transform)
        self.view.transform.localScale = params.scale
        self.view.transform.localPosition = params.position
    end
    
    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
end

function SeatView:initProperties()
    -- 自带属性
    -- 玩家mid
    self.mid = nil
    -- 玩家座位号
    self.seatId = nil
    -- 位置是否有人
    self.hasPlayer = false
end

function SeatView:initUIControls()
    self.btnSeat      = self.view.transform:Find("btnSeatView").gameObject
    UIHelper.AddButtonClick(self.btnSeat,function ()
        
        GameManager.SoundManager:PlaySound("clickButton")
        if GameManager.UserData.money < 200000 then
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = false,
                hasCloseButton = false,
                title = T("提示"),
                text = T("坐下需要20万金币"),
            })
        else
            GameManager.ServerManager:getNiuniuVipSeat()
        end
    end)

    self.btnPlayer    = self.view.transform:Find("btnPlayer").gameObject
    UIHelper.AddButtonClick(self.btnPlayer,function ()
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelOtherInfoBig = import("Panel.PlayInfo.PanelOtherInfoBig").new(self.mid, function(index)
            local times = 1
            http.useToolProp(
                times,
                function(callData)
                    if callData and callData.flag == 1 then
                        GameManager.ServerManager:sendProp(index, self.mid, times)
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
    end)

    self.playIcon     = self.view.transform:Find("btnPlayer/playIcon").gameObject
    self.playName     = self.view.transform:Find("btnPlayer/playName").gameObject
    self.iconFrame    = self.view.transform:Find("btnPlayer/iconFrame").gameObject
    self.playMoney    = self.view.transform:Find("btnPlayer/playMoney").gameObject

    if self.index <= 3 then
        self.winText = self.view.transform:Find("winTextRight").gameObject
        self.chatText = self.view.transform:Find("ChatRight").gameObject
    else
        self.winText = self.view.transform:Find("winTextLeft").gameObject
        self.chatText = self.view.transform:Find("ChatLeft").gameObject
    end
end

function SeatView:initUIDatas()
    -- 初始化时应该是无人状态
    self:setNoPlayer()
end

-- 设置为有人的状态
function SeatView:setPlayer(mid,seatId)
    
    self.mid = mid
    self.seatId = seatId
    self.hasPlayer = true
    
    self.btnPlayer:SetActive(true)
    self.btnSeat:SetActive(false)

    self:GetPlayerInfo()
end

-- 设置为无人的状态
function SeatView:setNoPlayer()
    
    self.mid = nil
    self.seatId = nil
    self.hasPlayer = false

    self.btnPlayer:SetActive(false)
    self.btnSeat:SetActive(true)
end

-- 结算动画
function SeatView:playChipAnmi(money)
    
    if self.view then
        local startPos
        local endPos

        if self.index <= 3 then
            -- 左边的头像
            startPos = Vector3.New(60, -60, 0)
            endPos = Vector3.New(60, -40, 0)
        else
            -- 右边的头像
            startPos = Vector3.New(-60, -60, 0)
            endPos = Vector3.New(-60, -40, 0)
        end
        
        self.winText.transform.localPosition = startPos

        if tonumber(money) > 0 then
            self.winText:GetComponent('Text').text = "<color=#FFF23B>+"..money.."</color>"
        else
            self.winText:GetComponent('Text').text = "<color=#CAC4BD>"..money.."</color>"
        end

        self.winText:SetActive(true)
        self.winText.transform:DOLocalMove(endPos, 0.5)

        Timer.New(function()
            if self.view then
                self.winText:SetActive(false)
            end
        end, 1.5, 1, true):Start()
    end
end

-- 聊天动画
function SeatView:playChatAnmi(message)
    local chatText = self.chatText.transform:Find("Text").gameObject:GetComponent('Text')
    local chatBg = self.chatText.transform:Find("ChatBg").gameObject

    chatText.text = message

    local chatTextSizeHeight = chatText.preferredHeight
    local chatTextSizeWidth = chatText.preferredWidth

    if chatTextSizeWidth > 245 then
        chatTextSizeWidth = 235
    end

    local bgSize = chatBg:GetComponent("RectTransform").sizeDelta
    chatBg:GetComponent("RectTransform").sizeDelta = Vector3.New(chatTextSizeWidth + 45,chatTextSizeHeight + 30,0)

    self.chatText:SetActive(true)
    Timer.New(function()
        if self.view then
            self.chatText:SetActive(false)
        end
    end, 1.5, 1, true):Start()
end

-- 下注动画
function SeatView:playChipMoveAnmi()
    local wantPos
    if self.index <= 3 then
        -- 左边的头像
        wantPos = Vector3.New(self.pos.x + 20, self.pos.y, 0)
    else
        -- 右边的头像
        wantPos = Vector3.New(self.pos.x - 20, self.pos.y, 0)
    end

    self.view.transform:DOLocalMove(wantPos,0.3)

    Timer.New(function()
        self.view.transform:DOLocalMove(self.pos,0.3)
    end, 0.3, 1, true):Start()
end

-- 从PHP获取玩家信息
function SeatView:GetPlayerInfo()
    
    http.getUserData(
        self.mid,
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
                        node = self.playIcon,
                        callback = function(sprite)
                            
                            if self.view and self.playIcon then
                                self.playIcon:GetComponent('Image').sprite = sprite
                            end
                        end,
                    })
                    -- 根据VIP等级设置玩家头像框
                    if self.view then
                        if callData.user.vip_level and tonumber(callData.user.vip_level) ~= 0 then
                            local sp = GameManager.ImageLoader:getVipFrame(callData.user.vip_level)
                            self.iconFrame:GetComponent('Image').sprite = sp
                            self.iconFrame:SetActive(true)
                        else
                            self.iconFrame:SetActive(false)
                        end
                        -- 设置名字
                        self.playName:GetComponent('Text').text = callData.user.name
                        -- 设置金币数
                        self.playMoney:GetComponent('Text').text = formatFiveNumber(callData.user.money)
                    end
                end
            end
        end,
        function(callData)
        end
    )
end

-- 刷新用户金币（通过PHP)
function SeatView:refashPlayerInfo()
    http.getUserData(
        self.mid,
        0,
        0,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self.playMoney:GetComponent('Text').text = formatFiveNumber(callData.user.money)
                end
            end
        end,
        function(callData)
        end
    )
end

-- 刷新用户金币（通过Server）
function SeatView:refashPlayerMoney(money)
    self.playMoney:GetComponent('Text').text = formatFiveNumber(money)
end

function SeatView:destroy()
    destroy(self.view)
    self.view = nil
end

return SeatView