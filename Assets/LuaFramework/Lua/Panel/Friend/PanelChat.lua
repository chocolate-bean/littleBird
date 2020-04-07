local PanelChat = class("PanelChat")

function PanelChat:ctor(data)
    
    self.data = data
    resMgr:LoadPrefabByRes("Chat", { "PanelChat", "PanelChatLeft", "PanelChatRight" }, function(objs)
        self:initView(objs)
    end)
end

function PanelChat:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelChat"

    self.PanelChatLeft = objs[1]
    self.PanelChatRight = objs[2]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelChat:show()
    
    GameManager.PanelManager:addPanel(self,false,0)
end

function PanelChat:initProperties()
end

function PanelChat:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.title = self.view.transform:Find("StaticFriend").gameObject
    self.title:SetActive(true)

    self.Grid = self.view.transform:Find("NoticeGrid/Grid")
    self.NoticeRect = self.view.transform:Find("NoticeGrid").gameObject:GetComponent('ScrollRect')

    self.btnSend = self.view.transform:Find("btnSend").gameObject
    UIHelper.AddButtonClick(self.btnSend,function()
        GameManager.SoundManager:PlaySound("clickButton")
        self:sendMessage()
    end)
    self.input = self.view.transform:Find("input").gameObject:GetComponent('InputField')
end

function PanelChat:initUIDatas()

    http.getChatLog(
        self.data.mid,
        function(callData)
            
            if callData and callData.flag == 1 then
                if callData.list ~= nil then
                    for i,data in ipairs(callData.list) do
                        self:AddChat(data)
                    end
                    self:UpdateView()
                end
            end
        end,
        function(callData)
            
        end
    )
    Event.AddListener(EventNames.CHAT_MESSAGE,handler(self,self.onChatResponse))
end

function PanelChat:AddChat(data)
    if self.view then
        local item

        if tonumber(data.from_mid)~= tonumber(GameManager.UserData.mid) then
            item = newObject(self.PanelChatLeft)
            item.name = "chatOther"
        else
            item = newObject(self.PanelChatRight)
            item.name = "chatSelf"
        end

        local chatText = item.transform:Find("Des").gameObject:GetComponent('Text')
        local chatBg = item.transform:Find("ChatBg").gameObject
        local icon = item.transform:Find("Icon").gameObject
        local playName = item.transform:Find("PlayName").gameObject:GetComponent('Text')

        chatText.text = CSharpTools.Base64Decode(data.content)

        if tonumber(data.from_mid)~= tonumber(GameManager.UserData.mid) then
            playName.text = self.data.name

            GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                url = self.data.micon,
                sex = tonumber(self.data.msex),
                node = icon,
                callback = function(sprite)
                    
                    if self.view and icon then
                        icon:GetComponent('Image').sprite = sprite
                    end
                end,
            })
        else
            playName.text = GameManager.UserData.name

            GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                url = GameManager.UserData.micon,
                sex = tonumber(GameManager.UserData.msex),
                node = icon,
                callback = function(sprite)
                    
                    if self.view and icon then
                        icon:GetComponent('Image').sprite = sprite
                    end
                end,
            })
        end

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

function PanelChat:onChatResponse(data)
    local chatData = json.decode(data.info)
    
    dump(chatData)
    if tonumber(chatData.from_mid) == tonumber(GameManager.UserData.mid) or tonumber(chatData.to_mid) == tonumber(GameManager.UserData.mid) then
        self:AddChat(chatData)
        self:UpdateView()
    end
end

function PanelChat:sendMessage()
    if self.input.text == nil or self.input.text == "" then
        return
    end

    local content = CSharpTools.Base64Encode(self.input.text)
    http.sendChat(
        self.data.mid,
        content,
        function(callData)
            
            if callData and callData.flag == 1 then
                local data = {
                    content = content,
                    from_mid = GameManager.UserData.mid,
                    to_mid = self.data.mid,
                }
                self:AddChat(data)
                self:UpdateView()

                self.input.text = ""
            else
                GameManager.TopTipManager:showTopTip(T("发送失败"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("发送失败"))
        end
    )
end

function PanelChat:UpdateView()
    
    Timer.New(function()
        self.NoticeRect.verticalNormalizedPosition = 0
    end,0.1,1,true):Start()
end

function PanelChat:onClose()
    -- 这里最好写一个控制器控制
    Event.RemoveListener(EventNames.CHAT_MESSAGE)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelChat