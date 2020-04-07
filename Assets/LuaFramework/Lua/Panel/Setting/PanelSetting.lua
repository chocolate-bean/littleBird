local PanelSetting = class("PanelSetting")

function PanelSetting:ctor()
    
    resMgr:LoadPrefabByRes("Setting", { "PanelSetting" }, function(objs)
        self:initView(objs)
    end)
end

function PanelSetting:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelSetting"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelSetting:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelSetting:initProperties()

end

function PanelSetting:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))
    
    -- 音乐控制
    self.MusicToggle = self.view.transform:Find("Music/MusicToggle").gameObject
    UIHelper.AddToggleClick(self.MusicToggle,buttonSoundHandler(self,self.onMusicClick))
    -- 音效控制
    self.SoundToggle = self.view.transform:Find("Sound/SoundToggle").gameObject
    UIHelper.AddToggleClick(self.SoundToggle,buttonSoundHandler(self,self.onSoundClick))
    -- 3D控制
    -- self.TDToggle = self.view.transform:Find("TD/TDToggle").gameObject
    -- UIHelper.AddToggleClick(self.TDToggle,buttonSoundHandler(self,self.on3DClick))
    -- 反馈
    self.btnFeedback = self.view.transform:Find("btnFeedback").gameObject
    UIHelper.AddButtonClick(self.btnFeedback,buttonSoundHandler(self,self.onFeedbcakClick))
    -- 用户协议
    self.btnUser = self.view.transform:Find("btnUser").gameObject
    UIHelper.AddButtonClick(self.btnUser,buttonSoundHandler(self,self.onUserClick))
    -- 隐私条款
    self.btnSecret = self.view.transform:Find("btnSecret").gameObject
    UIHelper.AddButtonClick(self.btnSecret,buttonSoundHandler(self,self.onSecretClick))
    
    -- 登出
    self.LoginOut = self.view.transform:Find("btnChange").gameObject
    UIHelper.AddButtonClick(self.LoginOut,buttonSoundHandler(self,self.onBtnLoginOutClick))

    -- 清楚缓存
    self.btnDelete = self.view.transform:Find("btnDelete").gameObject
    UIHelper.AddButtonClick(self.btnDelete,function()
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("此功能将清除缓存并关闭游戏\n请重启游戏"),
            firstButtonCallbcak = function()
                CSharpTools.cleanCache()
            end,
        })
    end)

    self.PlayIcon = self.view.transform:Find("PlayIcon").gameObject
    self.PlayName = self.view.transform:Find("PlayName").gameObject
    self.PlayIconBg = self.view.transform:Find("PlayIconBg").gameObject
    self.frame = self.view.transform:Find("PlayIcon/IconFrame").gameObject

    self.toggle1 = self.view.transform:Find("PanelToggle/1").gameObject:GetComponent("Toggle")
    self.toggle2 = self.view.transform:Find("PanelToggle/2").gameObject:GetComponent("Toggle")
    self.toggle3 = self.view.transform:Find("PanelToggle/3").gameObject:GetComponent("Toggle")
    if isMZBY() or isDBBY() then
        for i=1,3 do
            UIHelper.AddToggleClick(self.view:findChild("PanelToggle/"..i),buttonSoundHandler(self, function()
                self:onQualityToggleClick(i)
            end))
        end
    end

    self.toggles = {self.toggle1,self.toggle2,self.toggle3}
end

function PanelSetting:initUIDatas()
    
    -- 设置音乐按钮状态
    local music = UnityEngine.PlayerPrefs.GetInt(DataKeys.MUSIC)
    if music and music == 0 then
        self.MusicToggle:GetComponent("Toggle").isOn = true
    else
        self.MusicToggle:GetComponent("Toggle").isOn = false
    end
    -- 设置音效按钮状态
    local sound = UnityEngine.PlayerPrefs.GetInt(DataKeys.SOUND)
    if sound and sound == 0 then
        self.SoundToggle:GetComponent("Toggle").isOn = true
    else
        self.SoundToggle:GetComponent("Toggle").isOn = false
    end
    -- 设置音效按钮状态
    -- local is3D = UnityEngine.PlayerPrefs.GetInt(DataKeys.IS_3D)
    -- if is3D and is3D == 0 then
    --     self.TDToggle:GetComponent("Toggle").isOn = false
    -- else
    --     self.TDToggle:GetComponent("Toggle").isOn = true
    -- end
    -- 设置画质按钮状态
    local quality = UnityEngine.PlayerPrefs.GetInt(DataKeys.FISH_QUALITY)
    if quality and quality == 0 then
        self.toggles[2]:GetComponent("Toggle").isOn = true
        self:onQualityToggleClick(2)
    else
        self.toggles[quality]:GetComponent("Toggle").isOn = true
        self:onQualityToggleClick(quality)
    end

    self:refashPlayerInfo()
end

function PanelSetting:refashPlayerInfo()
    
    -- 设置头像
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })
    -- 设置玩家姓名
    self.PlayName:GetComponent('Text').text = GameManager.UserData.name
    -- 设置VIP头像框
    if tonumber(GameManager.UserData.viplevel) > 0 then
        self.PlayIconBg:SetActive(false)
        local sp = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
        self.frame:GetComponent('Image').sprite = sp
        self.frame:SetActive(true)
    end
end

function PanelSetting:onQualityToggleClick(index)
    if isMZBY() or isDBBY() then
        local on = self.view:findChild("PanelToggle/"..index).gameObject:GetComponent("Toggle").isOn
        self.view:findChild("PanelToggle/"..index.."/Background/Text"):GetComponent('Text').color = not on and Color.white or Color.New(34/255,81/255,148/255)
    end
end

function PanelSetting:onMusicClick(sender)
    local value = sender:GetComponent('Toggle').isOn
    if value then
        -- GameManager.SoundManager:PlayBGM()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.MUSIC,0)
        SoundMgr:ChangeBGM("bgMusic")
    else
        -- GameManager.SoundManager:StopBGM()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.MUSIC,1)        
        SoundMgr:StopBGM()
    end
end

function PanelSetting:onSoundClick(sender)
    local value = sender:GetComponent('Toggle').isOn
    if value then
        -- GameManager.SoundManager:OpenSound()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.SOUND,0)
    else
        -- GameManager.SoundManager:CloseSound()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.SOUND,1)
    end
end

function PanelSetting:on3DClick(sender)
    local value = sender:GetComponent('Toggle').isOn
    if value then
        UnityEngine.PlayerPrefs.SetInt(DataKeys.IS_3D,1)
    else
        UnityEngine.PlayerPrefs.SetInt(DataKeys.IS_3D,0)
    end
end

function PanelSetting:onFeedbcakClick()
    
    local PanelFeedback = import("Panel.Setting.PanelFeedback").new()
    self:onClose()
end

function PanelSetting:onUserClick()
    local webview = WebView.new()
    webview:OpenUrl("http://119.23.111.34/thumbgame/service.html")
end

function PanelSetting:onSecretClick()
    local webview = WebView.new()
    webview:OpenUrl("http://119.23.111.34/thumbgame/policy.html")
end

function PanelSetting:onBtnLoginOutClick()
    
    UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"LOGINOUT")
    Event.Brocast(EventNames.HALL_LOGOUT_SUCC)
    self:onClose()
end

--[[
    @desc: FB相关的设置
    author:张易
    time:2019-01-18 10:44:36
    @return:
]]
function PanelSetting:canBindFB()
    local lastLoginType = UnityEngine.PlayerPrefs.GetString(DataKeys.LAST_LOGIN_TYPE)
    if (lastLoginType ~= "FACEBOOK") and (GameManager.UserData.isBindFb == 0) then
        return true
    else
        return false
    end
end

function PanelSetting:onBindFbClick()
    -- body
    sdkMgr:FBLogin(
        function(accessToken)
            -- body
            print("FBLogin success")
            self:onBindFaceBook(accessToken)
        end,
        function(errorCode)
            -- body
            GameManager.TopTipManager:showTopTip(T("授权失败"))
        end
    )
end

function PanelSetting:onBindFaceBook(accessToken)
    -- body
    http.bindFacebook(
        GameManager.UserData.mid,
        accessToken,
        function(callData)
            -- body
            if callData then
                GameManager.TopTipManager:showTopTip(T("绑定成功"))
                -- TODO 设置按钮状态
                
                -- 刷新用户数据
                GameManager.UserData.isBindFb = 1
                GameManager.UserData.msex = checkint(callData.user["aUser.msex"])
                GameManager.UserData.name = checkint(callData.user["aUser.name"])
                GameManager.UserData.micon = checkint(callData.user["aUser.micon"])
            else
                GameManager.TopTipManager:showTopTip(T("授权失败"))
            end
        end,
        function()
            -- body
            GameManager.TopTipManager:showTopTip(T("授权失败"))
        end
    )
end

function PanelSetting:onClose()
    local curSelect 

    for index, v in pairs(self.toggles) do
        if v.isOn then
            curSelect = index
        end
    end

    UnityEngine.PlayerPrefs.SetInt(DataKeys.FISH_QUALITY, curSelect)

    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "name", self.handleId)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelSetting