local PanelRank = class("PanelRank")

function PanelRank:ctor(index)
    self.index = index
    resMgr:LoadPrefabByRes("Rank", { "PanelRank", "rankItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelRank:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelRank"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    self.item = objs[1]

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

function PanelRank:show()
    if isFKBY() then
        GameManager.PanelManager:addPanel(self,true,1)
    else
        GameManager.PanelManager:addPanel(self,true,4)
    end
end

function PanelRank:initProperties()
    self.mid = nil
    self.rankLists    = {}
    self.rankGrid     = {}
    self.btnRank      = {}
    self.selfRankGrid = {}
    self.redpacketUIs = {}
end

function PanelRank:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i = 1,3 do 
        local btn = self.view.transform:Find("BtnList/btn"..i).gameObject
        btn:addButtonClick(function()
            self:onBtnRankClick(i)
        end)
        table.insert(self.btnRank,btn)

        local rankList = self.view.transform:Find("RankList"..i).gameObject
        table.insert(self.rankLists,rankList)
        rankList:SetActive(false)

        local grid = self.view.transform:Find("RankList"..i.."/Grid").gameObject
        table.insert(self.rankGrid,grid)

        local selfRank = self.view.transform:Find("RankSelf"..i).gameObject
        table.insert(self.selfRankGrid,selfRank)
    end

    if isFKBY() then
        self.rankText = self.view.transform:Find("Title/Text (2)").gameObject
    end

    -- self.Grid = self.view.transform:Find("RankList/Grid").gameObject
    -- self.rankSelf = self.view.transform:Find("RankSelf").gameObject
    self.panelOtherInfoSmall = self.view.transform:Find("PanelOtherInfoSmall").gameObject
    self.panelClose = self.view.transform:Find("PanelOtherInfoSmall/btnClose").gameObject
    self.panelClose:addButtonClick(buttonSoundHandler(self,function()
        self.mid = nil
        self.panelOtherInfoSmall:SetActive(false)
    end))

    -- 姓名
    self.PlayName = self.view.transform:Find("PanelOtherInfoSmall/PlayName").gameObject
    -- 头像
    self.PlayIcon = self.view.transform:Find("PanelOtherInfoSmall/PlayIcon").gameObject
    -- 金币
    self.PlayMoney = self.view.transform:Find("PanelOtherInfoSmall/PlayMoney").gameObject
    -- 红包
    self.PlayHongbao = self.view.transform:Find("PanelOtherInfoSmall/PlayHongbao").gameObject

    -- vip
    self.PlayVip = self.view.transform:Find("PanelOtherInfoSmall/PlayVip").gameObject
    self.PlayIconBg = self.view.transform:Find("PanelOtherInfoSmall/PlayIconBg").gameObject
    self.frame = self.view.transform:Find("PanelOtherInfoSmall/PlayIcon/IconFrame").gameObject
    self.PlayUID = self.view.transform:Find("PanelOtherInfoSmall/PlayUID").gameObject

    self.iconBoy = self.view.transform:Find("PanelOtherInfoSmall/iconBoy").gameObject
    self.iconGirl = self.view.transform:Find("PanelOtherInfoSmall/iconGirl").gameObject
    -- 添加好友按钮
    self.btnAdd = self.view.transform:Find("PanelOtherInfoSmall/btnAdd").gameObject
    UIHelper.AddButtonClick(self.btnAdd,buttonSoundHandler(self,self.onAddFriendClick))
    -- 删除好友
    self.btnDelete = self.view.transform:Find("PanelOtherInfoSmall/btnDelete").gameObject
    UIHelper.AddButtonClick(self.btnDelete,buttonSoundHandler(self,self.onBtnDeleteClick))

    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("RankList2").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("BtnList/btn2").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelOtherInfoSmall/Text1").gameObject 
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelOtherInfoSmall/icon2").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PanelOtherInfoSmall/PlayHongbao").gameObject

    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function PanelRank:initUIDatas()
    -- for i=1,3 do
    --     self:GetRankList(i)
    -- end
    self:GetRankList(1, 1)
    self:GetRankList(2, 2)
    self:GetRankList(3, 4)

    self:onBtnRankClick(self.index or 1)
end

function PanelRank:GetRankList(index, type)
    http.getLobbyRank(
        type,
        function(callData)
            if callData and callData.flag == 1 then
                self:DestroyRankList(index)
                self:CreateRankList(index, callData.list)
                self:setRankSelf(index, callData.myself)
                GameManager.LoadingManager:setLoading(false, self.view)
            else
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
            GameManager.LoadingManager:setLoading(false, self.view)
        end
    )
end

function PanelRank:onBtnRankClick(index)
    for i = 1,3 do
        local light = self.btnRank[i].transform:Find("Light").gameObject
        light:SetActive(false)

        self.rankLists[i]:SetActive(false)
        self.selfRankGrid[i]:SetActive(false)
    end

    local curLight = self.btnRank[index].transform:Find("Light").gameObject
    curLight:SetActive(true)

    self.rankLists[index]:SetActive(true)
    self.selfRankGrid[index]:SetActive(true)

    if isFKBY() then
        local rankText = {
            [1] = "金币",
            [2] = "红包",
            [3] = "鱼雷",
        }
        self.rankText:setText(rankText[index])
    end
end

function PanelRank:DestroyRankList(index)
    removeAllChild(self.rankGrid[index].transform)
end

function PanelRank:CreateRankList(index,list)
    local parent = self.rankGrid[index]
    for i,data in ipairs(list) do
        local item = newObject(self.item)
        item.name = i
        item.transform:SetParent(parent.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("playIcon").gameObject
        GameManager.ImageLoader:loadImage(data.micon,function(success,sprite)
            if success and self.view and icon then
                icon:GetComponent('Image').sprite = sprite
            end
        end)
        UIHelper.AddButtonClick(item,function()
            -- TODO
            self:setPlayInfoPanel(data)
        end)

        local frame = item.transform:Find("playIcon/iconFrame").gameObject
        if data.vip_level and tonumber(data.vip_level) ~= 0 then
            local sp = GameManager.ImageLoader:getVipFrame(data.vip_level)
            frame:GetComponent('Image').sprite = sp
            frame:SetActive(true)
        else
            frame:SetActive(false)
        end

        local playName = item.transform:Find("playName").gameObject
        playName:GetComponent('Text').text = data.name
        AutoTextSize(playName,160)

        local rankIcon = item.transform:Find("chipIcon").gameObject
        local rankText = item.transform:Find("rankText").gameObject
        
        if index == 2 then
            rankText:GetComponent('Text').text = GameManager.GameFunctions.getJewelWithUnit(data.score)
        else
            rankText:GetComponent('Text').text = formatFiveNumber(data.score) 
        end

        if index == 1 then
            local sp = UIHelper.LoadSprite("Images/SenceMainHall/task1")
            rankIcon:GetComponent('Image').sprite = sp
            rankIcon:GetComponent('Image'):SetNativeSize()
        elseif index == 2 then
            local sp = UIHelper.LoadSprite("Images/SenceMainHall/task3")
            rankIcon:GetComponent('Image').sprite = sp
            rankIcon:GetComponent('Image'):SetNativeSize()
        elseif index == 3 then
            local sp = UIHelper.LoadSprite("Images/SenceMainHall/task9")
            rankIcon:GetComponent('Image').sprite = sp
            rankIcon:GetComponent('Image'):SetNativeSize()
            rankIcon.transform.localScale = Vector3.New(1.1, 1.1, 1)
        end

        
        if i < 4 then
            local sp = UIHelper.LoadSprite("Images/common/"..i)
            local rankImage = item.transform:Find("rank").gameObject
            rankImage:GetComponent('Image').sprite = sp
        else
            local sp = UIHelper.LoadSprite("Images/common/4")
            local rankImage = item.transform:Find("rank").gameObject
            rankImage:GetComponent('Image').sprite = sp

            local rankIndex = item.transform:Find("rank/Text").gameObject
            rankIndex:GetComponent('Text').text = i
            rankIndex:SetActive(true)
        end
    end

end

function PanelRank:setRankSelf(index, data)
    -- body
    local item = self.selfRankGrid[index]
    local i = data.rank

    local icon = item.transform:Find("playIcon").gameObject
    GameManager.ImageLoader:loadImage(GameManager.UserData.micon,function(success, sprite)
        if self.view and icon and success then
            icon:GetComponent('Image').sprite = sprite
        end
    end)

    local frame = item.transform:Find("playIcon/iconFrame").gameObject
    if GameManager.UserData.viplevel and tonumber(GameManager.UserData.viplevel) ~= 0 then
        local sp = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
        frame:GetComponent('Image').sprite = sp
        frame:SetActive(true)
    end

    local playName = item.transform:Find("playName").gameObject
    playName:GetComponent('Text').text = GameManager.UserData.name
    AutoTextSize(playName,160)

    local rankIcon = item.transform:Find("chipIcon").gameObject
    local rankText = item.transform:Find("rankText").gameObject

    if index == 2 then
        rankText:GetComponent('Text').text = GameManager.GameFunctions.getJewelWithUnit(data.score)
    else
        rankText:GetComponent('Text').text = formatFiveNumber(data.score) 
    end

    if index == 1 then
        local sp = UIHelper.LoadSprite("Images/SenceMainHall/task1")
        rankIcon:GetComponent('Image').sprite = sp
        rankIcon:GetComponent('Image'):SetNativeSize()
    elseif index == 2 then
        local sp = UIHelper.LoadSprite("Images/SenceMainHall/task3")
        rankIcon:GetComponent('Image').sprite = sp
        rankIcon:GetComponent('Image'):SetNativeSize()
    elseif index == 3 then
        local sp = UIHelper.LoadSprite("Images/SenceMainHall/task9")
        rankIcon:GetComponent('Image').sprite = sp
        rankIcon:GetComponent('Image'):SetNativeSize()
        rankIcon.transform.localScale = Vector3.New(1.1, 1.1, 1)
    end

    if i < 4 then
        local sp = UIHelper.LoadSprite("Images/common/"..i)
        local rankImage = item.transform:Find("rank").gameObject
        rankImage:GetComponent('Image').sprite = sp
    else
        local sp = UIHelper.LoadSprite("Images/common/4")
        local rankImage = item.transform:Find("rank").gameObject
        rankImage:GetComponent('Image').sprite = sp

        local rankIndex = item.transform:Find("rank/Text").gameObject
        if tonumber(i) > 99 then
            rankIndex:GetComponent('Text').text = "99+"
        else
            rankIndex:GetComponent('Text').text = i
        end
        rankIndex:SetActive(true)
    end
end

function PanelRank:setPlayInfoPanel(data)
    self.panelOtherInfoSmall:SetActive(true)
    self.mid = data.mid

    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = data.micon,
        sex = tonumber(data.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })

    dump(data)

    -- 金币
    self.PlayMoney:GetComponent('Text').text = formatFiveNumber(data.money)
    -- 名称
    self.PlayName:GetComponent('Text').text = data.name
    AutoTextSize(self.PlayName,270)
    -- 红包
    self.PlayHongbao:GetComponent('Text').text = GameManager.GameFunctions.getJewel(data.jewel)

    -- 性别
    if tonumber(data.msex) == 1 then
        
        self.iconBoy:SetActive(true)
        self.iconGirl:SetActive(false)
    else
        self.iconBoy:SetActive(false)
        self.iconGirl:SetActive(true)
    end

    -- vip
    self.PlayVip:GetComponent('Text').text = "VIP"..data.vip_level or 0
    if tonumber(data.vip_level) > 0 then
        self.PlayIconBg:SetActive(false)
        local sp = GameManager.ImageLoader:getVipFrame(data.vip_level)
        self.frame:GetComponent('Image').sprite = sp
        self.frame:SetActive(true)
    else
        self.frame:SetActive(false)
    end

    self.PlayUID:GetComponent('Text').text = data.mid

    -- 是否好友
    if tonumber(data.isfriend) == 0 then
        self.btnAdd:SetActive(true)
        self.btnDelete:SetActive(false)
    else
        self.btnAdd:SetActive(false)
        self.btnDelete:SetActive(true)
    end
end

function PanelRank:onAddFriendClick(sender)
    if self.mid then
        http.applyFriend(
            self.mid,
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.TopTipManager:showTopTip(T("申请成功"))
                    self.btnAdd:SetActive(false)
                elseif callData and callData.flag == -3 then  
                    GameManager.TopTipManager:showTopTip(T("对方好友已到达上限"))
                elseif callData and callData.flag == -4 then
                    GameManager.TopTipManager:showTopTip(T("你的好友已到达上线"))
                else
                    GameManager.TopTipManager:showTopTip(T("请求失败"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("请求失败"))
            end
        )
    end
end

function PanelRank:onBtnDeleteClick(sender)
    if self.mid then
        http.deleteFriend(
            self.mid,
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.TopTipManager:showTopTip(T("删除成功"))
                    -- self.btnDelete:SetActive(false)
                    -- self.btnAdd:SetActive(true)
                    self:onClose()
                    if self.callback then
                        self.callback()
                    end
                else
                    GameManager.TopTipManager:showTopTip(T("删除失败"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("请求失败"))
            end
        )
    end
end

function PanelRank:onClose()
    -- 这里最好写一个控制器控制
    wwwMgr:StopHttp();
    GameManager.PanelManager:removePanel(self,4,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelRank