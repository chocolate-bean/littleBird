local PanelOtherInfoSmall = class("PanelOtherInfoSmall")

function PanelOtherInfoSmall:ctor(mid, callback, showMask, type)
    
    self.mid = mid
    self.callback = callback
    self.showMask = showMask

    -- 1,大厅进来的，2,娱乐场进来的
    if type and type == 2 then
        resMgr:LoadPrefabByRes("PlayInfo", { "PanelOtherInfoSmallForHappy"}, function(objs)
            self:initView(objs)
        end)
    else
        resMgr:LoadPrefabByRes("PlayInfo", { "PanelOtherInfoSmall"}, function(objs)
            self:initView(objs)
        end)
    end
    
end

function PanelOtherInfoSmall:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelOtherInfoSmall"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelOtherInfoSmall:show()
    
    if self.showMask and self.showMask == 0 then
        GameManager.PanelManager:addPanel(self,false,1)
    else
        GameManager.PanelManager:addPanel(self,true,1)
    end
end

function PanelOtherInfoSmall:initProperties()
    self.redpacketUIs = {}
end

function PanelOtherInfoSmall:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    -- 姓名
    self.PlayName = self.view.transform:Find("PlayName").gameObject
    -- 头像
    self.PlayIcon = self.view.transform:Find("PlayIcon").gameObject
    -- 金币
    self.PlayMoney = self.view.transform:Find("PlayMoney").gameObject
    -- 红包
    self.PlayHongbao = self.view.transform:Find("PlayHongbao").gameObject
    -- vip
    self.PlayVip = self.view.transform:Find("PlayVip").gameObject
    self.PlayIconBg = self.view.transform:Find("PlayIconBg").gameObject
    self.frame = self.view.transform:Find("PlayIcon/IconFrame").gameObject
    self.PlayUID = self.view.transform:Find("PlayUID").gameObject

    self.iconBoy = self.view.transform:Find("iconBoy").gameObject
    self.iconGirl = self.view.transform:Find("iconGirl").gameObject
    -- 添加好友按钮
    self.btnAdd = self.view.transform:Find("btnAdd").gameObject
    UIHelper.AddButtonClick(self.btnAdd,buttonSoundHandler(self,self.onAddFriendClick))
    -- 删除好友
    self.btnDelete = self.view.transform:Find("btnDelete").gameObject
    UIHelper.AddButtonClick(self.btnDelete,buttonSoundHandler(self,self.onBtnDeleteClick))

    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("Text1").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("icon2").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("PlayHongbao").gameObject

    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function PanelOtherInfoSmall:initUIDatas()
    http.getUserData(
        self.mid,
        0,
        1,
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    if callData.user then
                        self:refashPlayerInfo(callData.user)
                    end
                end
            elseif callData.flag == -1 then
                GameManager.TopTipManager:showTopTip(T("查找玩家数据失败"))                
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelOtherInfoSmall:refashPlayerInfo(data)
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
    end

    self.PlayUID:GetComponent('Text').text = data.mid

    -- 是否好友
    if data.isFriend == 0 then
        self.btnAdd:SetActive(true)
    else
        self.btnDelete:SetActive(true)
    end
end

function PanelOtherInfoSmall:onAddFriendClick(sender)
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

function PanelOtherInfoSmall:onBtnDeleteClick(sender)
    
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

function PanelOtherInfoSmall:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelOtherInfoSmall