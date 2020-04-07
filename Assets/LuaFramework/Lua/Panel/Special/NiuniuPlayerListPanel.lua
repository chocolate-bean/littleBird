local NiuniuPlayerListPanel = class("NiuniuPlayerListPanel")

function NiuniuPlayerListPanel:ctor(data)
    self.data = data
    resMgr:LoadPrefabByRes("Special", { "PanelNiuniuPlayerList", "playItem"}, function(objs)
        self:initView(objs)
    end)
end

function NiuniuPlayerListPanel:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "NiuniuPlayerListPanel"

    self.item = objs[1]
    
    GameManager.LoadingManager:setLoading(true, self.view)
    local timer = Timer.New(function()
        self:initProperties()
        self:initUIControls()
        self:initUIDatas()
    end,0.5,1,true)
    timer:Start() 
    
    self:show()
end

function NiuniuPlayerListPanel:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function NiuniuPlayerListPanel:initProperties()
end

function NiuniuPlayerListPanel:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.list = self.view.transform:Find("PanelList/Grid").gameObject

    self.text = self.view.transform:Find("TitleBg/Text").gameObject
end

function NiuniuPlayerListPanel:initUIDatas()
    self.text:GetComponent('Text').text = T("当前无座玩家共  ")..#self.data..T("  人")
    
    local uids = {}
    for i,data in ipairs(self.data) do
        uids[i] = data.uid
    end

    http.getMulUserData(
        json.encode(uids),
        function(callData)
            if callData and callData.flag == 1 then
                if self.view then
                    table.sort(callData.list, function(a,b)
                        
                        if tonumber(a.vip_level) == tonumber(b.vip_level) then
                            return tonumber(a.money) >  tonumber(b.money)
                        else
                            return tonumber(a.vip_level) > tonumber(b.vip_level)
                        end
                    end)
                    self:createPlayerList(callData.list)
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
            GameManager.LoadingManager:setLoading(false, self.view)
        end
    )
end

function NiuniuPlayerListPanel:createPlayerList(list)
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
        end
    end

    GameManager.LoadingManager:setLoading(false, self.view)
end

function NiuniuPlayerListPanel:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return NiuniuPlayerListPanel