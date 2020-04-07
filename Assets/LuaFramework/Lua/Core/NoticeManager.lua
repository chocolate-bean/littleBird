local NoticeManager = class("NoticeManager")
local SP = require("Server.SERVER_PROTOCOL")

-- 虽然是叫Bilbili，实际是小喇叭功能
-- 小喇叭和弹幕的意思差不多
-- bilibili，干杯
function NoticeManager:ctor(pos)
    self.pos = pos
    self.speed = 20
    self.noticeList = {}

    resMgr:LoadPrefabByRes("Notice", { "Notice" }, function(objs)
        self:initView(objs)
    end)
end

function NoticeManager:initView(objs)
    self.NoticePanel = UnityEngine.GameObject.Instantiate(objs[0])

    local parent = UnityEngine.GameObject.Find("Canvas")
    self.NoticePanel.name = "Notice"
    self.NoticePanel.transform:SetParent(parent.transform)
    self.NoticePanel.transform.localScale = Vector3.one
    self.NoticePanel.transform.localPosition = self.pos
    self.NoticeBg = self.NoticePanel.transform:Find("NoticeBg").gameObject
    self.NoticeRect = self.NoticePanel.transform:Find("NoticeBg/NoticeMask/NoticeScroll").gameObject:GetComponent('ScrollRect')
    self.NoticeText = self.NoticePanel.transform:Find("NoticeBg/NoticeMask/NoticeScroll/NoticeText").gameObject:GetComponent('Text')
    self.NoticeText.text = " "
    self.NoticeBg:SetActive(false)

    self.NoticeIcon = self.NoticePanel.transform:Find("NoticeIcon").gameObject
    show(self.NoticeIcon)
    UIHelper.AddButtonClick(self.NoticeIcon,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        if self.NoticeListPanel then
            return
        end
        self.NoticeListPanel = import("Panel.Special.NoticePanel").new(function()
            
            if self.NoticeListPanel then
                self.NoticeListPanel.isShowing = false
                self.NoticeListPanel = nil
            end
        end)
        self.NoticeListPanel.isShowing = true
    end)
    
    
    self.updateHandle = UpdateBeat:CreateListener(self.Update, self)
    UpdateBeat:AddListener(self.updateHandle)
    Event.AddListener(EventNames.SERVER_RESPONSE, handler(self,self.onServerResponse))
end

function NoticeManager:onServerResponse(cmd, data)
    
    if not self.responseAction then
        self.responseAction = {
            [SP.SVR_COMMON_BROADCAST] = self.commonBroadcastResponse,
        }
    end

    local action = self.responseAction[cmd]
    if action then
        action(self, data)
    end
end

function NoticeManager:commonBroadcastResponse(data)
    
    local infoData = json.decode(data.info)
    if data.mtype == 2 then
        self.NoticeBg:SetActive(true)
        if infoData.type == 1 then
            infoData.notice = T("系统消息:") .. CSharpTools.Base64Decode(infoData.broadcast)
        else
            infoData.notice = infoData.name .. ":" .. CSharpTools.Base64Decode(infoData.broadcast)
        end
        table.insert(self.noticeList,infoData)
        if GameManager.GameConfig.NoticeList then
            table.insert(GameManager.GameConfig.NoticeList,infoData)
            if #GameManager.GameConfig.NoticeList > 100 then
                table.remove(GameManager.GameConfig.NoticeList,1)
            end

            if self.NoticeListPanel and self.NoticeListPanel.isShowing then
                self.NoticeListPanel:AddNotice(infoData)
                self.NoticeListPanel:UpdateView()
            end
        end
    end
end

function NoticeManager:Update()
    if self.NoticeRect and self.NoticeRect.horizontalNormalizedPosition and self.NoticeRect.horizontalNormalizedPosition > 1 then
        if #self.noticeList > 0 then
            local notice = table.remove(self.noticeList,1)
            self.NoticeRect.horizontalNormalizedPosition = 0
            self.NoticeText.text = notice.notice.."                                                                                                                                 "
        else
            self.NoticeBg:SetActive(false)
        end
    end

    local speed = self.speed/string.len(self.NoticeText.text)
    self.NoticeRect.horizontalNormalizedPosition = self.NoticeRect.horizontalNormalizedPosition + speed * Time.deltaTime

    -- local parent = UnityEngine.GameObject.Find("Canvas")
    -- local count = parent.transform.childCount
    -- self.NoticePanel.transform:SetSiblingIndex(count - 1)
end

function NoticeManager:onClean()
    
    UpdateBeat:RemoveListener(self.updateHandle)
    Event.RemoveListener(EventNames.SERVER_RESPONSE)
    self.NoticePanel:SetActive(false)
end

return NoticeManager