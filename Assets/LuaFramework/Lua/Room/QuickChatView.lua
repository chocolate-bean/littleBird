local QuickChatView = class("QuickChatView")
local EmojiGroupItemView  = require("Room.EmojiGroupItemView")
local QuickChatItemView   = require("Room.QuickChatItemView")
local HistoryChatItemView = require("Room.HistoryChatItemView")
local InteractiveAnimation = require("Room/InteractiveAnimation")
local SP = require("Server.SERVER_PROTOCOL")

QuickChatView.Tabs = {
    Emoji   = 1,
    Quick   = 2,
    History = 3,
}

QuickChatView.Type = {
    Custom  = 1,
    Default = 2,
}

local QUICK_CHAT_CONFIG = {
    T("大家好!"),
    T("初来乍到，多多关照"),
    T("我等到花儿都谢了"),
    T("你的牌打得太好了!"),
    T("冲动是魔鬼，淡定"),
    T("送点钱给我吧"),
    T("哇，你抢钱啊"),
    T("又断线，网络太差了!"),
}

QuickChatView.AnimationTime = {
    Show = 0.5,
    Dismiss = 0.2,
} 

--[[
    --@chatHistory: {

    }
	--@params: {
        type =  QuickChatView.Type.*
    }
]]
function QuickChatView:ctor(params)
    self.params = params
    resMgr:LoadPrefabByRes("QuickChat", {"PanelQuickChat", "EmojiGroupItem", "QuickChatItem", "HistoryChatItem"}, function(objs)
        self:initView(objs)
    end)
end

function QuickChatView:initView(objs)

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "QuickChatView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    
    self:initProperties(objs)
    self:initUIControls()
    self:initUIDatas()
    self:addServerListener()
end

--[[
    server 相关
]]
function QuickChatView:addServerListener()
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
end

function QuickChatView:removeServerListener()
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
end

function QuickChatView:onServerResponse(cmd, data)
    
    if not self.responseAction then
        self.responseAction = {
            [SP.CLI_SEND_ROOM_MSG] = self.sendRoomMsgResponse,
        }
    end

    local action = self.responseAction[cmd]
    if action then
        action(self, data)
    end
end

function QuickChatView:sendRoomMsgResponse(data)
    local mtype = data.mtype
    local info = json.decode(data.info)
    local uid = tonumber(data.uid)

    info.mtype = mtype
    if mtype == 1 then
        --聊天消息
        self.chatHistory[#self.chatHistory + 1] = {
            name = info.name,
            message = info.message,
            header = info.header,
            uid = info.uid,
            sex = info.sex,
        }
        if self.backgroundImage.activeSelf then
            self:updateChatHistory()
        end
    elseif mtype == 2 then
        -- 用户换头像
    elseif mtype == 3 then
        -- 赠送礼物
    elseif mtype == 4 then
        -- 设置礼物
    elseif mtype == 5 then
        --发送表情
    elseif mtype == 6 then
        
    elseif mtype == 7 then
        
    elseif mtype == 8 then
        
    elseif mtype == 9 then
        
    end
end


function QuickChatView:initProperties(objs)
    self.chatHistory = {}
    self.EmojiGroupItemPrefab  = objs[1]
    self.QuickChatItemPrefab   = objs[2]
    self.HistoryChatItemPrefab = objs[3]
end

function QuickChatView:initUIControls()
    self.backgroundImage       = self.view.transform:Find("backgroundImage").gameObject
    self.topView               = self.view.transform:Find("backgroundImage/topView").gameObject
    self.emojiChatTab          = self.view.transform:Find("backgroundImage/topView/tabs/emojiChatTab").gameObject
    self.emojiChatText         = self.view.transform:Find("backgroundImage/topView/tabs/emojiChatTab/Text").gameObject
    self.quickChatTab          = self.view.transform:Find("backgroundImage/topView/tabs/quickChatTab").gameObject
    self.quickChatText         = self.view.transform:Find("backgroundImage/topView/tabs/quickChatTab/Text").gameObject
    self.historyChatTab        = self.view.transform:Find("backgroundImage/topView/tabs/historyChatTab").gameObject
    self.historyChatText       = self.view.transform:Find("backgroundImage/topView/tabs/historyChatTab/Text").gameObject
    self.closeButton           = self.view.transform:Find("backgroundImage/topView/closeButton").gameObject
    self.midView               = self.view.transform:Find("backgroundImage/midView").gameObject
    self.contentBg             = self.view.transform:Find("backgroundImage/midView/contentBg").gameObject
    self.contentView           = self.view.transform:Find("backgroundImage/midView/contentBg/Viewport/contentView").gameObject
    self.bottomView            = self.view.transform:Find("backgroundImage/bottomView").gameObject
    self.inputField            = self.view.transform:Find("backgroundImage/bottomView/InputField").gameObject
    self.inputFieldPlaceholder = self.view.transform:Find("backgroundImage/bottomView/InputField/Placeholder").gameObject
    self.sendButton            = self.view.transform:Find("backgroundImage/bottomView/SendButton").gameObject
    self.sendButtonText        = self.view.transform:Find("backgroundImage/bottomView/SendButton/Text").gameObject

    self.quickChatText  :GetComponent('Text').text = T("快捷聊天")
    self.historyChatText:GetComponent('Text').text = T("聊天记录")
    self.sendButtonText :GetComponent('Text').text = T("发送")
    self.inputFieldPlaceholder.transform:GetComponent('Text').text = T("点击输入聊天内容")
    
    self.tabButtons = {
        self.emojiChatTab,
        self.quickChatTab, 
        self.historyChatTab,
    }

    for i, button in ipairs(self.tabButtons) do
        UIHelper.AddButtonClick(button, function()
            GameManager.SoundManager:PlaySound("clickButton")
            self:onTabButtonClick(i)
        end)
    end

    UIHelper.AddButtonClick(self.closeButton, buttonSoundHandler(self, self.onCloseButtonClick))
    UIHelper.AddButtonClick(self.sendButton, buttonSoundHandler(self, self.onSendButtonClick))
    --TEST:
    -- hide(self.contentView)
end

function QuickChatView:initUIDatas()
    if self.params.type == QuickChatView.Type.Default then
        -- 这个是没有输入框的
        hide(self.bottomView)
        local bgHeight = self.backgroundImage.transform.sizeDelta.y
        local bottomHeight = self.bottomView.transform.sizeDelta.y
        self.backgroundImage.transform.sizeDelta = Vector3.New(self.backgroundImage.transform.sizeDelta.x,bgHeight - bottomHeight, 0)
    end
    self:onSelectIndex(QuickChatView.Tabs.Emoji)
end

function QuickChatView:updateUIDatas(tag)

    if self.selectIndex ~= tag then
        return   
    end

    local historyMessage = self.chatHistory or {}
    
    -- 查看是否要拼接
    local haveNewMessage = false
    if tag == QuickChatView.Tabs.History and self.chatItems and self.chatItems[tag] and #self.chatItems[tag] < #historyMessage then
        haveNewMessage = true
    end

    if not self.chatItems then
        self.chatItems = {}
    end

    self.chatItems[tag] = self.chatItems[tag] or {}

    for _, items in ipairs(self.chatItems) do
        for _, item in ipairs(items) do
            hide(item.view)
        end
    end

    if tag == QuickChatView.Tabs.Emoji then
        function getConfigWithType(type)
            local config = InteractiveAnimation.EMOJI_FPS_CONFIG[type]
            local count = EmojiGroupItemView.COUNT
            local newConfig = {}
            -- 一行5个 用子控件属性决定
            
            for index = 1, #config do
                local row = math.ceil(index/count)
                local column = index%count
                if column == 0 then
                    column = 5
                end
                if not newConfig[row] then
                    newConfig[row] = {}
                end
                newConfig[row][column] = {index = index, type = type}
            end
            return newConfig
        end

        local config = getConfigWithType(1)

        for i, datas in ipairs(config) do
            local item = self.chatItems[tag][i]
            if item then
                show(item.view)
            else
                item = EmojiGroupItemView.new(newObject(self.EmojiGroupItemPrefab), datas)
                item.view.transform:SetParent(self.contentView.transform)
                item.view.transform.localScale = Vector3.one
                item.view.transform.localPosition = Vector3.zero
                item:setButtonClick(function(chatHistory)
                    self:onEmojiItemClick(chatHistory)
                end)
                self.chatItems[tag][#self.chatItems[tag] + 1] = item
            end
        end
    elseif tag == QuickChatView.Tabs.Quick then
        for i, quickText in ipairs(QUICK_CHAT_CONFIG) do
            local item = self.chatItems[tag][i]
            if item then
                show(item.view)
            else
                item = QuickChatItemView.new(newObject(self.QuickChatItemPrefab), {text = quickText, index = i})
                item.view.transform:SetParent(self.contentView.transform)
                item.view.transform.localScale = Vector3.one
                item.view.transform.localPosition = Vector3.zero
                item:setButtonClick(function(chatHistory)
                    self:onQuickChatItemClick(chatHistory)
                end)
                self.chatItems[tag][#self.chatItems[tag] + 1] = item
            end
        end
    elseif tag == QuickChatView.Tabs.History then
        for i, message in ipairs(historyMessage) do
            local item = self.chatItems[tag][i]
            if item then
                show(item.view)
            else
                item = HistoryChatItemView.new(newObject(self.HistoryChatItemPrefab), message)
                item.view.transform:SetParent(self.contentView.transform)
                item.view.transform.localScale = Vector3.one
                item.view.transform.localPosition = Vector3.zero
                item:setButtonClick(function(chatHistory)
                    self:onHistoryChatItemClick(chatHistory)
                end)
                self.chatItems[tag][#self.chatItems[tag] + 1] = item
            end
        end
    end

    -- 计算高度
    local contentHeight = 0
    for i, item in ipairs(self.chatItems[tag]) do
        -- 高度在内部设置
        contentHeight = contentHeight + item.height
    end
    self.contentView.transform:GetComponent("RectTransform")
    :SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, contentHeight)

    -- 滑到底下
    local bottomOffsetY = 0
    if tag == QuickChatView.Tabs.History then
        bottomOffsetY = contentHeight - self.contentBg.transform.sizeDelta.y
        if bottomOffsetY < 0 then
            bottomOffsetY = 0
        end
    end
    local moveAnimation = self.contentView.transform:DOLocalMoveY(bottomOffsetY, 0.4)
    moveAnimation:SetEase(DG.Tweening.Ease.OutQuint)

end

--[[
    动画
]]

function QuickChatView:show(chatHistory)
    self:updateUIDatas(self.selectIndex or 1, chatHistory)

    GameManager.PanelManager:addPanel(self, true)
    show(self.view)
    self.backgroundImage.transform.localScale = Vector3.New(0.1,0.1,0.1)
    local scaleAnimation = self.backgroundImage.transform:DOScale(Vector3.one, QuickChatView.AnimationTime.Show)
    -- scaleAnimation:SetEase(DG.Tweening.Ease.OutElastic)
    scaleAnimation:SetEase(DG.Tweening.Ease.OutQuint)
end

function QuickChatView:onClose()
    local scaleAnimation = self.backgroundImage.transform:DOScale(Vector3.zero, QuickChatView.AnimationTime.Dismiss)
    scaleAnimation:OnComplete(function()
        GameManager.PanelManager:hidePanel(self)
    end)
end

--[[
    复用代码
]]
function QuickChatView:onSelectIndex(index)
    self.selectIndex = index
    for i, button in ipairs(self.tabButtons) do
        local selectImage = button.transform:Find("selectImage").gameObject
        local selectText  = button.transform:Find("Text").gameObject
        if index == i then
            show(selectImage)
            selectText.transform:GetComponent('Outline').effectColor = Color.New(97/255,132/255,28/255,1)
        else
            hide(selectImage)
            selectText.transform:GetComponent('Outline').effectColor = Color.New(106/255,103/255,111/255,1)
        end
    end
end

--[[
    event handle
]]
function QuickChatView:onTabButtonClick(tag)
    if self.selectIndex == tag then
        return
    end
    self:onSelectIndex(tag)
    self:updateUIDatas(tag)
end

function QuickChatView:onSendButtonClick()
    local inputSprite = self.inputField.transform:GetComponent('InputField')
    if string.len(inputSprite.text) <= 0 then
        self.inputFieldPlaceholder.transform:GetComponent('Text').text = T("输入不能为空")
    else
        GameManager.ServerManager:sendRoomChat(inputSprite.text, nil)
        inputSprite.text = nil
    end
end

function QuickChatView:onCloseButtonClick()
    self:onClose()
end

function QuickChatView:onEmojiItemClick(data)
    GameManager.ServerManager:sendExpression(data.type, data.index, nil)
    self:onClose()
end

function QuickChatView:onQuickChatItemClick(chatData)
    GameManager.ServerManager:sendRoomChat(chatData.text, nil)
    self:onClose()
end

function QuickChatView:onHistoryChatItemClick(chatData)

    if chatData.uid == GameManager.UserData.mid then
        local PlayInfoSmallPanel = import("Panel.PlayInfo.PlayInfoSmallPanel").new()
    else
        local OtherInfoBigPanel = import("Panel.PlayInfo.OtherInfoBigPanel").new(chatData.uid, function(index, phpid)
        end)
    end
    -- self:onClose()
end


--[[
    public method
]]
function QuickChatView:updateChatHistory()
    self:updateUIDatas(QuickChatView.Tabs.History)
end



return QuickChatView