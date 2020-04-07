local NiuniuBankerListPanel = class("NiuniuBankerListPanel")

function NiuniuBankerListPanel:ctor(data,callback)
    self.data = data
    self.callback = callback
    resMgr:LoadPrefabByRes("Special", { "PanelNiuniuBankerList", "bankerItem"}, function(objs)
        self:initView(objs)
    end)
end

function NiuniuBankerListPanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NiuniuBankerListPanel"

    self.item = objs[1]
    
    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
    
    self:show()
end

function NiuniuBankerListPanel:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function NiuniuBankerListPanel:initProperties()
end

function NiuniuBankerListPanel:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.list = self.view.transform:Find("PanelList/Grid").gameObject
    self.btnBanker = self.view.transform:Find("btnBanker").gameObject
    self.btnBanker:addButtonClick(buttonSoundHandler(self, self.onBtnBankerClick), false)
end

function NiuniuBankerListPanel:initUIDatas()
    self:refashBankerList(self.data)
end

function NiuniuBankerListPanel:refashBankerList(data)
    local uids = {}
    for i,data in ipairs(data) do
        uids[i] = data.uid
    end

    http.getMulUserData(
        json.encode(uids),
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    self.list:removeAllChildren()
                    self:createPlayerList(callData.list)
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
        end,
        function(callData)
        end
    )
end

function NiuniuBankerListPanel:createPlayerList(list)
    for i,data in ipairs(list) do
        local item = newObject(self.item)
        item.name = "item"..i
        item.transform:SetParent(self.list.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local playIcon = item.transform:Find("playIcon").gameObject
        local iconFrame = item.transform:Find("iconFrame").gameObject
        local playName = item.transform:Find("playName").gameObject
        local playMoney = item.transform:Find("playMoney").gameObject

        UIHelper.AddButtonClick(item,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onClose()
            local PanelOtherInfoBig = import("Panel.PlayInfo.PanelOtherInfoBig").new(data.mid, function(index)
                local times = 1
                http.useToolProp(
                    times,
                    function(callData)
                        if callData and callData.flag == 1 then
                            GameManager.ServerManager:sendProp(index, data.mid, times)
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

        if self.view then
            -- 设置玩家头像
            GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
                url = data.micon,
                sex = tonumber(data.msex),
                node = playIcon,
                callback = function(sprite)
                    
                    if self.view and playIcon then
                        playIcon:GetComponent('Image').sprite = sprite
                    end
                end,
            })

            -- 根据VIP等级设置玩家头像框
            if data.vip_level and tonumber(data.vip_level) ~= 0 then
                local sp = GameManager.ImageLoader:getVipFrame(data.vip_level)
                iconFrame:GetComponent('Image').sprite = sp
                iconFrame:SetActive(true)
            else
                iconFrame:SetActive(false)
            end
            -- 设置金币数
            playName:GetComponent('Text').text = data.name
            playMoney:GetComponent('Text').text = formatFiveNumber(data.money)

            -- 设置编号
            if i < 4 then
                local sp = UIHelper.LoadSprite("Images/SenceMainHall/Rank/"..i)
                local rankImage = item.transform:Find("rank").gameObject
                rankImage:GetComponent('Image').sprite = sp
            else
                local sp = UIHelper.LoadSprite("Images/SenceMainHall/Rank/4")
                local rankImage = item.transform:Find("rank").gameObject
                rankImage:GetComponent('Image').sprite = sp
                rankImage:GetComponent('Image'):SetNativeSize()
    
                local rankIndex = item.transform:Find("rank/Text").gameObject
                rankIndex:GetComponent('Text').text = i
                rankIndex:SetActive(true)
            end
        end
    end
end

function NiuniuBankerListPanel:onBtnBankerClick()
    GameManager.ServerManager:applyBanker()
end

function NiuniuBankerListPanel:onClose()
    if self.callback then
        self:callback()
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return NiuniuBankerListPanel