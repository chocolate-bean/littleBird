local NoticePanel = class("NoticePanel")

function NoticePanel:ctor(callback)
    self.callback = callback
    self.NoticeList = clone(GameManager.GameConfig.NoticeList)
    resMgr:LoadPrefabByRes("Chat", { "PanelChat", "PanelChatLeft", "PanelChatRight" }, function(objs)
        self:initView(objs)
    end)
end

function NoticePanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NoticePanel"

    self.noticeItem = objs[1]

    self.PanelChatLeft = objs[1]
    self.PanelChatRight = objs[2]
    
    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
    
    self:show()
end

function NoticePanel:show()
    
    GameManager.PanelManager:addPanel(self,false,0)
end

function NoticePanel:initProperties()

end

function NoticePanel:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    -- 标题
    self.title = self.view.transform:Find("StaticNotice").gameObject
    self.title:SetActive(true)

    self.Grid = self.view.transform:Find("NoticeGrid/Grid")
    self.NoticeRect = self.view.transform:Find("NoticeGrid").gameObject:GetComponent('ScrollRect')

    self.NoticeNum = self.view.transform:Find("StaticNotice/Num").gameObject

    self.btnSend = self.view.transform:Find("btnSend").gameObject
    UIHelper.AddButtonClick(self.btnSend,function()
        GameManager.SoundManager:PlaySound("clickButton")
        self:sendMessage()
    end)
    self.input = self.view.transform:Find("input").gameObject:GetComponent('InputField')
    -- self.NoticeList = {
    --     {type = 1, broadcast = "111"},
    --     {type = 1, broadcast = "1kasdjgfuiaesdk,jfghbasjkl,fgbasjiklfgbasjkfgbaskjlfgbaskjfgbasjklfgbasiujkf"},
    --     {type = 1, broadcast = "55"},
    --     {type = 1, broadcast = "6"},
    -- }

    for i,data in ipairs(self.NoticeList) do
        self:AddNotice(data)
    end

    Timer.New(function()
        
        self.NoticeRect.verticalNormalizedPosition = 0
    end,0.1,1,true):Start()
end

function NoticePanel:initUIDatas()
    http.getUserProp(
        4,
        function(callData)
            if callData then
                if #callData == 0 then
                    self.NoticeNum:GetComponent('Text').text = "0"
                else
                    local num = callData[1].property
                    self.NoticeNum:GetComponent('Text').text = num
                end
            else
                self.NoticeNum:GetComponent('Text').text = "0"
            end
        end,
        function(callData)
            self.NoticeNum:GetComponent('Text').text = "0"
        end
    )
end

function NoticePanel:AddNotice(data)
    if self.view then
        local item

        if data.type == 1 then
            item = newObject(self.PanelChatLeft)
            item.name = "chatOther"
        elseif data.type == 2 then
            if data.mid and data.mid == GameManager.UserData.mid then
                item = newObject(self.PanelChatRight)
                item.name = "chatSelf"
            else
                item = newObject(self.PanelChatLeft)
                item.name = "chatOther"
            end
        end

        local chatText = item.transform:Find("Des").gameObject:GetComponent('Text')
        local chatBg = item.transform:Find("ChatBg").gameObject
        local icon = item.transform:Find("Icon").gameObject
        local playName = item.transform:Find("PlayName").gameObject:GetComponent('Text')

        if data.type == 1 then
            playName.text = T("<color=#ffe600>系统消息</color>")
            icon:GetComponent('Image').sprite = UIHelper.LoadSprite("Images/common/System")
        else
            playName.text = data.name
            GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                url = data.micon,
                sex = tonumber(data.msex),
                callback = function(sprite)
                    
                    if self.view and icon then
                        icon:GetComponent('Image').sprite = sprite
                    end
                end,
            })
        end

        local content = CSharpTools.Base64Decode(data.broadcast)
        chatText.text = content

        local chatTextSizeHeight = chatText.preferredHeight
        local chatTextSizeWidth = chatText.preferredWidth

        if chatTextSizeWidth > 600 then
            chatTextSizeWidth = 590
        end

        local panelSize = item:GetComponent("RectTransform").sizeDelta
        item:GetComponent("RectTransform").sizeDelta = Vector3.New(860,chatTextSizeHeight + 100,0)

        local bgSize = chatBg:GetComponent("RectTransform").sizeDelta
        chatBg:GetComponent("RectTransform").sizeDelta = Vector3.New(chatTextSizeWidth + 45,chatTextSizeHeight + 30,0)

        item.transform:SetParent(self.Grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero
    end
end

function NoticePanel:UpdateView()
    
    Timer.New(function()
        self.NoticeRect.verticalNormalizedPosition = 0
    end,0.1,1,true):Start()
end

function NoticePanel:sendMessage()
    if self.input.text == nil or self.input.text == "" then
        return
    end

    local content = CSharpTools.Base64Encode(self.input.text)
    http.sendBroadcast(
        content,
        function(callData)
            
            if callData and callData.flag == 1 then
                self.input.text = ""
            else
                GameManager.TopTipManager:showTopTip(T("小喇叭数量不足"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("发送失败"))
        end
    )
end

function NoticePanel:onClose()
    self.callback()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return NoticePanel