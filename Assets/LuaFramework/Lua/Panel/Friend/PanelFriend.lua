local PanelFriend = class("PanelFriend")

PanelFriend.FriendState = {
    [1] = {state = T("<color=#9696BE>离线</color>")},
    [2] = {state = T("<color=#64FF64>在线</color>")},
    [3] = {state = T("<color=#6496FF>游戏中</color>")},
}

function PanelFriend:ctor(index)
    self.index = index or 1
    
    resMgr:LoadPrefabByRes("Friend", { "PanelFriend", "FriendItem", "FriendMessageItem" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFriend:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFriend"

    self.FriendItem = objs[1]
    self.FriendMessageItem = objs[2]

    GameManager.LoadingManager:setLoading(true, self.view)
    local timer = Timer.New(function()
        self:initProperties()
        self:initUIControls()
        self:initUIDatas()
    end,0.5,1,true)
    timer:Start() 

    Timer.New(function()
        if self.view then
            wwwMgr:StopHttp()
            GameManager.LoadingManager:setLoading(false, self.view)
        end
    end,3,1,true):Start()

    self:show()
end

function PanelFriend:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelFriend:initProperties()
    self.viewItems = {}
    self.btnItems = {}
    self.redDots = {}

    self.tuijianPlayers = {}
    self.tuijianPlayerData = {}
end

function PanelFriend:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,3 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)
        local redDot = self.view.transform:Find("btnItem"..i.."/redDot").gameObject
        if GameManager.UserData.redDotData then
            if GameManager.UserData.redDotData.friend.index[i] then
                redDot:SetActive(true)
            end
        end

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
        table.insert(self.redDots,redDot)
    end

    for i = 1,4 do
        local tuijianPlayer = self.view.transform:Find("Item1/tuijian/play"..i).gameObject
        self.tuijianPlayers[i] = tuijianPlayer

        local btnTuijianAdd = self.view.transform:Find("Item1/tuijian/play"..i.."/btnAdd").gameObject
        UIHelper.AddButtonClick(btnTuijianAdd, function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onAddFriendClick(self.tuijianPlayerData[i].mid)
        end)
    end

    self.tuijianPanel = self.view.transform:Find("Item1/tuijian").gameObject
    self.searchPanel = self.view.transform:Find("Item1/search").gameObject

    -- 玩家Mid
    self.PlayMid = self.view.transform:Find("Item1/PlayMid").gameObject

    -- 搜索的ID
    self.input = self.view.transform:Find("Item1/input").gameObject:GetComponent('InputField')
    -- 搜索按钮
    self.btnSearch = self.view.transform:Find("Item1/btnSearch").gameObject
    UIHelper.AddButtonClick(self.btnSearch,buttonSoundHandler(self,self.onSearchClick))
    -- 更新推荐好友
    self.btnChange = self.view.transform:Find("Item1/btnChange").gameObject
    UIHelper.AddButtonClick(self.btnChange,buttonSoundHandler(self,self.getTuijianPlayer))
    -- 搜索结果
    self.searchPlayer = self.view.transform:Find("Item1/search/play1").gameObject
    -- 搜索结果添加
    self.btnAddSearchPlay = self.view.transform:Find("Item1/search/play1/btnAdd").gameObject
    UIHelper.AddButtonClick(self.btnAddSearchPlay,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        self:onAddFriendClick(self.searchFriend.mid)
    end)

    -- 好友列表
    self.friendGrid = self.view.transform:Find("Item2/FriendList/Grid").gameObject
    -- 好友消息列表
    self.friendMessageGrid = self.view.transform:Find("Item3/MessageList/Grid").gameObject
end

function PanelFriend:initUIDatas()
    self.PlayMid:GetComponent('Text').text = GameManager.UserData.mid
    self:getTuijianPlayer()
    self:reFashFriendList()
    self:reFashRewardList()
    self:onBtnItemClick(self.index)
end

-- 刷新好友列表
function PanelFriend:reFashFriendList()
    self.friendData = {}
    self:GetFriendList()
end

-- 刷新消息列表
function PanelFriend:reFashRewardList()
    self.RewardData = {}
    self:GetRewardList()
end

-- 获取好友列表
function PanelFriend:GetFriendList()
    http.getAllFriendList(
        function(callData)
            if callData then
                self.friendData = callData.list
                self:DestroyFriendList()
                self:createFriendList()
            end
        end,
        function(callData)
        end
    )
end

-- 获取奖励列表
function PanelFriend:GetRewardList()
    http.getMessageList(
        2,
        function(callData)
            if callData then
                if self.view then
                    self.RewardData = callData.list
                    self:DestroyRewardList()
                    self:createRewardList()

                    GameManager.LoadingManager:setLoading(false, self.view)
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
                if self.view then
                    GameManager.LoadingManager:setLoading(false, self.view)
                end
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end
    )
end

function PanelFriend:DestroyFriendList()
    
    removeAllChild(self.friendGrid.transform)
end

function PanelFriend:DestroyRewardList()
    
    removeAllChild(self.friendMessageGrid.transform)
end

-- 创建好友列表
function PanelFriend:createFriendList()
    
    for i,data in ipairs(self.friendData) do
        local item = newObject(self.FriendItem)
        item.name = i
        item.transform:SetParent(self.friendGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("PlayIcon").gameObject
        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = data.micon,
            sex = tonumber(data.msex),
            node = icon,
            callback = function(sprite)
                
                if self.view and icon then
                    icon:GetComponent('Image').sprite = sprite
                end
            end,
        })

        icon:addButtonClick(buttonSoundHandler(self,function()
            local PanelOtherIPanelOtherInfoSmallnfoBig = import("Panel.PlayInfo.PanelOtherInfoSmall").new(data.mid,function()
                self:reFashFriendList()
            end, 0)
        end), false)

        local iconBoy = item.transform:Find("iconBoy").gameObject
        local iconGirl = item.transform:Find("iconGirl").gameObject
        if tonumber(data.msex) == 1 then
            
            iconBoy:SetActive(true)
        else
            iconGirl:SetActive(true)
        end

        local playerName = item.transform:Find("PlayName").gameObject
        playerName:GetComponent('Text').text = data.name

        local playState = item.transform:Find("PlayState").gameObject
        playState:GetComponent('Text').text = PanelFriend.FriendState [tonumber(data.position) + 1].state

        local btnChat = item.transform:Find("btnChat").gameObject
        UIHelper.AddButtonClick(btnChat,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            local PanelChat = import("Panel.Friend.PanelChat").new(data)
        end)

        local btnSend = item.transform:Find("btnSend").gameObject
        btnSend:SetActive(tonumber(data.sendable_money) == 1)
        UIHelper.AddButtonClick(btnSend,function(sender)
            
            GameManager.SoundManager:PlaySound("clickButton")
            btnSend:SetActive(false)
            self:onBtnSendClick(data)
        end)
    end
end

-- 创建好友消息列表
function PanelFriend:createRewardList()
    
    -- dump(self.RewardData)
    for i,data in ipairs(self.RewardData) do
        local item = newObject(self.FriendMessageItem)
        item.name = i
        item.transform:SetParent(self.friendMessageGrid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("PlayIcon").gameObject

        if data.action_params[1] then
            icon:addButtonClick(buttonSoundHandler(self,function()
                local PanelOtherIPanelOtherInfoSmallnfoBig = import("Panel.PlayInfo.PanelOtherInfoSmall").new(data.action_params[1],function()
                    self:reFashFriendList()
                end, 0)
            end), false)
        end

        local Title = item.transform:Find("Title").gameObject
        Title:GetComponent('Text').text = data.content

        local Time = item.transform:Find("Time").gameObject
        Time:GetComponent('Text').text = os.date("%Y-%m-%d %H:%M", data.create_time or 0)

        if tonumber(data.act_status) == 0 then

        else
            if data.msg_type == 4 then
                local PanelFriend = item.transform:Find("PanelFriend").gameObject
                PanelFriend:SetActive(true)
    
                local ButtonYes = item.transform:Find("PanelFriend/btnYes").gameObject
                UIHelper.AddButtonClick(ButtonYes,function()
                    
                    GameManager.SoundManager:PlaySound("clickButton")
                    self:onBtnYesClick(data)
                end)
                local ButtonNo = item.transform:Find("PanelFriend/btnNo").gameObject
                UIHelper.AddButtonClick(ButtonNo,function()
                    
                    GameManager.SoundManager:PlaySound("clickButton")
                    self:onBtnNoClick(data)
                end)
            end
    
            if data.msg_type == 3 or data.msg_type == 2 then
                local PanelReward = item.transform:Find("PanelReward").gameObject
                PanelReward:SetActive(true)
    
                local ButtonYes = item.transform:Find("PanelReward/btnYes").gameObject
                UIHelper.AddButtonClick(ButtonYes,function()
                    
                    GameManager.SoundManager:PlaySound("clickButton")
                    self:onBtnReceiveClick(data)
                end)
            end
        end

        
    end
end

function PanelFriend:onBtnSendClick(data)
    
    http.sendFriendSpecial(
        data.mid,
        0,
        "money",
        function(callData)
            if callData and callData.flag == 1 then
                GameManager.TopTipManager:showTopTip(T("赠送成功"))
                GameManager.UserData.money = callData.latest_money
            elseif callData and callData.flag == -4 then
                GameManager.TopTipManager:showTopTip(T("筹码不足"))
            else
                GameManager.TopTipManager:showTopTip(T("赠送失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelFriend:onBtnYesClick(data)
    
    http.handleOneMessage(
        data.id,
        3,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self:reFashFriendList()
                    self:reFashRewardList() 
                end         
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelFriend:onBtnNoClick(data)
    
    http.handleOneMessage(
        data.id,
        4,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self:reFashFriendList()
                    self:reFashRewardList() 
                end         
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelFriend:onBtnReceiveClick(data)
    
    http.handleOneMessage(
        data.id,
        2,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self:reFashFriendList()
                    self:reFashRewardList() 
                end         
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelFriend:getTuijianPlayer()
    http.recommendFriend(
        function(callData)
            print("getTuijianPlayer success")
            if callData and callData.flag == 1 then
                self.tuijianPlayerData = callData.list
                self:reflushTuijianPlayer(callData.list)
            end
        end,
        function(callData)
        end
    )
end

function PanelFriend:reflushTuijianPlayer(data)
    self.tuijianPanel:SetActive(true)
    self.searchPanel:SetActive(false)

    -- for i=1,4 do
    for i,v in ipairs(data) do
        local PlayIcon = self.tuijianPlayers[i].transform:Find("PlayIcon").gameObject
        local PlayName = self.tuijianPlayers[i].transform:Find("PlayName").gameObject

        GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
            url = data[i].micon,
            sex = tonumber(data[i].msex),
            node = PlayIcon,
            callback = function(sprite)
                
                if self.view and PlayIcon then
                    PlayIcon:GetComponent('Image').sprite = sprite
                end
            end,
        })

        PlayName:GetComponent('Text').text = data[i].name
    end
end


function PanelFriend:onBtnItemClick(index)
    
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

    self:removeRedDot(index)
end

function PanelFriend:removeRedDot(index)
    
    if GameManager.UserData.redDotData then
        if GameManager.UserData.redDotData.friend.index[index] then
            self.redDots[index]:SetActive(false)
            GameManager.UserData.redDotData.friend.index[index] = nil
            GameManager.GameFunctions.removeRedDot("friend", index)
        end

        if GameManager.UserData.redDotData.friend.index == nil or next(GameManager.UserData.redDotData.friend.index) == nil then
            GameManager.UserData.redDotData.friend.dot = 0
            if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
                GameManager.runningScene.view_:redDotManager()
            end
        end
    end
end

function PanelFriend:onSearchClick()
    -- 查找成功
    if self.input.text == "" or self.input.text == nil then
        return
    end

    http.searchUser(
        self.input.text,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self.searchFriend = callData.info
                    self:onSearchSuccess(callData.info)
                end
            elseif callData.flag == -1 then
                GameManager.TopTipManager:showTopTip(T("查无此人"))    
                if self.view then
                    self:onSearchFailed()
                end            
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
                if self.view then
                    self:onSearchFailed()
                end
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelFriend:onSearchSuccess(data)
    self.tuijianPanel:SetActive(false)
    self.searchPanel:SetActive(true)

    local PlayIcon = self.searchPlayer.transform:Find("PlayIcon").gameObject
    local PlayName = self.searchPlayer.transform:Find("PlayName").gameObject

    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = data.micon,
        sex = tonumber(data.msex),
        node = PlayIcon,
        callback = function(sprite)
            
            if self.view and PlayIcon then
                PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })

    PlayName:GetComponent('Text').text = data.name
end

function PanelFriend:onAddFriendClick(mid)
    if mid then
        http.applyFriend(
            mid,
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.TopTipManager:showTopTip(T("发送成功，请等待对方接受"))
                elseif callData and callData.flag == -3 then  
                    GameManager.TopTipManager:showTopTip(T("对方好友已到达上限"))
                elseif callData and callData.flag == -4 then
                    GameManager.TopTipManager:showTopTip(T("你的好友已到达上限"))
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

function PanelFriend:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFriend