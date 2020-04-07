local AnimationManager = class("AnimationManager")

local AnimTypeConfigs = {
    {type = "Scale", ease = DG.Tweening.Ease.OutQuart, parms = {Vector3.zero, Vector3.one}},
    {type = "LocalMove", ease = DG.Tweening.Ease.OutQuart, parms = {Vector3.New(0,-720,0), Vector3.zero}},
    {type = "LocalMove", ease = DG.Tweening.Ease.OutQuart, parms = {Vector3.New(0,720,0), Vector3.zero}},
    {type = "LocalMove", ease = DG.Tweening.Ease.OutQuart, parms = {Vector3.New(-1280,0,0), Vector3.zero}},
    {type = "LocalMove", parms = {Vector3.New(0,-720,0), Vector3.zero}},
    {type = "LocalMove", parms = {Vector3.New(0,720,0), Vector3.zero}},
    -- {type = {"LocalMove", "Scale"}, 
    --  ease = DG.Tweening.Ease.OutBounce, 
    --  parms = {Scale = {Vector3.zero, Vector3.one},
    --           LocalMove = {Vector3.New(0,720,0), Vector3.zero}}},
}

function AnimationManager:addPanelShowAnimation(panel, animType, completeCallback)
    local config = AnimTypeConfigs[animType]
    local time = config.time or 0.5
    -- 首先判断有多少个动画类型
    if type(config.type) == "string" then
        local sequence = DG.Tweening.DOTween.Sequence()
        if config.ease then
            sequence:SetEase(config.ease)
        end
        if config.type == "Scale" then
            panel.transform.localScale = config.parms[1]
            panel.transform.localPosition = Vector3.zero
            sequence:Append(panel.transform:DOScale(config.parms[2], time))
        elseif config.type == "LocalMove" then
            panel.transform.localScale = Vector3.one
            panel.transform.localPosition = config.parms[1]
            sequence:Append(panel.transform:DOLocalMove(config.parms[2], time))
        end
        if completeCallback then
            sequence:OnComplete(completeCallback)
        end
    else
        print("暂时没写两个动画同时执行逻辑")
    end
end

function AnimationManager:addPanelDismissAnimation(panel, animType, completeCallback)
    local config = AnimTypeConfigs[animType]
    local time = config.time or 0.25
    if type(config.type) == "string" then
        local sequence = DG.Tweening.DOTween.Sequence()
        -- 消失动画的ease不能用回来的动画 不是很好看
        -- sequence:SetEase(config.ease)
        if config.type == "Scale" then
            sequence:Append(panel.transform:DOScale(config.parms[1], time))
        elseif config.type == "LocalMove" then
            sequence:Append(panel.transform:DOLocalMove(config.parms[1], time))
        end
        if completeCallback then
            sequence:OnComplete(function()
                completeCallback()
            end)
        end
    else
        print("暂时没写两个动画同时执行逻辑")
    end
end

function AnimationManager:playRewardAnimation(titleText,icon,rewardText,infoText,callback)
    resMgr:LoadPrefabByRes("Animation", {"RewardDragonbones"}, function(objs)
        self:OnRewardPrefabsLoaded(objs[0],titleText,icon,rewardText,infoText,callback)
    end)
end

function AnimationManager:OnRewardPrefabsLoaded(prefab,titleText,icon,rewardText,infoText,callback)
    if self.reward then
        return
    end
    self.reward = {}

    local view = newObject(prefab)
    view.name = "rewardAnimation"
    local parent = UnityEngine.GameObject.Find("Canvas")
    view.transform:SetParent(parent.transform)
    view.transform.localScale = Vector3.one
    view.transform.localPosition = Vector3.zero
    view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    GameManager.SoundManager:PlaySoundWithNewSource("box_open_reward")
    
    self.reward.view = view

    self.reward.titleText  = view.transform:Find("titleText").gameObject
    self.reward.icon       = view.transform:Find("icon").gameObject
    self.reward.rewardText = view.transform:Find("icon/Text").gameObject
    self.reward.button     = view.transform:Find("button").gameObject
    self.reward.buttonText = view.transform:Find("button/Text").gameObject
    self.reward.infoText   = view.transform:Find("infoText").gameObject

    if isFKBY() then
        self.reward.iconBg  = view.transform:Find("Image").gameObject
    end
    
    self.reward.titleText:setText(titleText)
    self.reward.rewardText:setText(rewardText)
    self.reward.infoText:setText(infoText)
    self.reward.buttonText:setText(T("确定"))

    if type(icon) ~= "table" then
        self.reward.icon:setSprite("Images/SenceMainHall/fuliItem"..icon)
        self.reward.icon:GetComponent('Image'):SetNativeSize()
    else
        self.reward.icon:setSprite(icon.url)
        GameManager.ImageLoader:loadAndCacheImage(icon.url,function (success, sprite)
            if success and sprite then
                if self.reward then
                    self.reward.icon:setSprite(sprite)
                end
            end
        end)
        self.reward.icon.transform.sizeDelta = icon.size
    end
    
    self.reward.button:addButtonClick(buttonSoundHandler(self,function()
        self:stopRewardAnimation(callback)
    end))

    local duration
    if isFKBY() then
        duration = 1

        doFadeAutoShow(self.reward.icon,        'Image', duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.iconBg,        'Image', duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.rewardText,  'Text',  duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.button,      'Image', duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.buttonText,  'Text',  duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.infoText,    'Text',  duration*0.7, duration*0.5)
    else
        local dragonBones = view.transform:Find("MovieClip").gameObject
        local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')    
        local Animation = UnityArmatureComponent.animation 
        local AnimationData = Animation.animations:get_Item("newAnimation")
        duration = AnimationData.duration
        
        doFadeAutoShow(self.reward.titleText,   'Text',  duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.icon,        'Image', duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.rewardText,  'Text',  duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.button,      'Image', duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.buttonText,  'Text',  duration*0.7, duration*0.5)
        doFadeAutoShow(self.reward.infoText,    'Text',  duration*0.7, duration*0.5)
    end
end

function AnimationManager:stopRewardAnimation(callback)
    if not self.reward then
        return
    end
    
    hide(self.reward.view)
    destroy(self.reward.view)
    self.reward.view = nil
    self.reward = nil

    if callback then
        callback()
    end
end

return AnimationManager