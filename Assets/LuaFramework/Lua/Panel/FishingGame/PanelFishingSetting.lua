local PanelFishingSetting = class("PanelFishingSetting")

function PanelFishingSetting:ctor()
    resMgr:LoadPrefabByRes("FishingGame/UI", { "PanelFishingGameSetting" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFishingSetting:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishingSetting"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFishingSetting:initProperties()
    
end

function PanelFishingSetting:initUIControls()
    self.closeButton    = self.view.transform:Find("btnClose").gameObject


    -- 音乐控制
    self.MusicToggle = self.view.transform:Find("Music/MusicToggle").gameObject
    UIHelper.AddToggleClick(self.MusicToggle,buttonSoundHandler(self,self.onMusicClick))
    -- 音效控制
    self.SoundToggle = self.view.transform:Find("Sound/SoundToggle").gameObject
    UIHelper.AddToggleClick(self.SoundToggle,buttonSoundHandler(self,self.onSoundClick))


    self.closeButton:addButtonClick(buttonSoundHandler(self,function()
        self:onClose()
    end), false)
end

function PanelFishingSetting:initUIDatas(ruleText)
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
end

function PanelFishingSetting:show()
    GameManager.PanelManager:addPanel(self, true, 1)
end

function PanelFishingSetting:onClose()
    GameManager.PanelManager:removePanel(self, nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

function PanelFishingSetting:onMusicClick(sender)
    local value = sender:GetComponent('Toggle').isOn
    if value then
        -- GameManager.SoundManager:PlayBGM()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.MUSIC,0)
        SoundMgr:ChangeBGM("fishingGame/bgm_Login")
    else
        -- GameManager.SoundManager:StopBGM()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.MUSIC,1)        
        SoundMgr:StopBGM()
    end
end

function PanelFishingSetting:onSoundClick(sender)
    local value = sender:GetComponent('Toggle').isOn
    if value then
        -- GameManager.SoundManager:OpenSound()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.SOUND,0)
    else
        -- GameManager.SoundManager:CloseSound()
        UnityEngine.PlayerPrefs.SetInt(DataKeys.SOUND,1)
    end
end

return PanelFishingSetting