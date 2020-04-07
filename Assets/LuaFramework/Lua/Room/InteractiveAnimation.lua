local InteractiveAnimation = class("InteractiveAnimation")

local HDDJ_PATH  = "Images/Interactive/hddj/"
local EMOJI_PATH = "Images/Interactive/emoji/emoji_"

local HDDJ_NAME_CONFIG = {
    "rose", 
    "egg", 
    "beer", 
    "brick",
}

-- 对应的图片张数
local HDDJ_FPS_CONFIG = {
    17,
    13,
    15,
    16,
}

InteractiveAnimation.EMOJI_FPS_CONFIG = {
    {
        2, 2, 2, 2, 4,
        2, 3, 3, 3, 4,
        2, 2, 2, 4, 2,
        2, 2, 2, 2, 2,
        2, 2, 11,4, 2,
        2, 3, 9, 4,10, 
        7, 2, 2,10, 4, 
        9, 3, 5,21, 8,
        10,9, 4, 4, 4,
        15,16,
    },
}


InteractiveAnimation.ANIMATION_CONFIG = {
    Winner = {
        Small = 1,
        Mid   = 2,
        Big   = 3,
        Huge  = 4,
    }
}

function InteractiveAnimation:ctor(model, seatManager, callback)
    
    resMgr:LoadPrefabByRes("Animation", {"ImageArray", "RewardDragonbones", "AllinDragonbones", "fla_winner_1", "fla_winner_2", "fla_winner_3", "fla_winner_4", }, function(objs)
        self:setPrefabs(objs)
        if callback then
            callback(self)
        end
    end)
end

function InteractiveAnimation:setPrefabs(objs)
    self.ImageArrayPrefabs = objs[0]
    self.RewardPrefabs     = objs[1]
    self.AllinPrefabs      = objs[2]
    self.WinnerPrefabs     = {objs[3], objs[4], objs[5], objs[6]}
end


--[[
    以下是不需要model 和 seatManager的
]]

function InteractiveAnimation:playHDDJ(type, sourceParent, aimParent, moveParent)

    local animationView = newObject(self.ImageArrayPrefabs)
    animationView.transform:SetParent(moveParent and moveParent.transform or UnityEngine.GameObject.Find("Canvas").transform)
    animationView.transform.localScale = Vector3.one
    animationView.transform.localPosition = sourceParent.transform.localPosition

    local animArray = animationView:GetComponent('ChipAnim')
    local showImage = animationView:GetComponent('Image')
    showImage.sprite = UIHelper.LoadSprite(HDDJ_PATH..HDDJ_NAME_CONFIG[type].."/"..HDDJ_NAME_CONFIG[type].."_move")
    showImage:SetNativeSize()

    for i = 1, HDDJ_FPS_CONFIG[type] do
        local imagName = HDDJ_PATH..HDDJ_NAME_CONFIG[type].."/"..HDDJ_NAME_CONFIG[type].."_"..i
        animArray.SpriteFrames:Add(UIHelper.LoadSprite(imagName))
    end

    animArray.FPS = HDDJ_FPS_CONFIG[type] * 0.5
    animArray.AutoPlay = false
    animArray.Loop = false
    animArray.DoneFunction = function()
        hide(animationView)
        destroy(animationView)
    end

    local moveTime = 0.3
    local moveAnimation = animationView.transform:DOLocalMove(aimParent.transform.localPosition, moveTime)
    moveAnimation:OnComplete(function()
        animArray:Play() 
        GameManager.SoundManager:PlaySound(HDDJ_NAME_CONFIG[type])        
    end)
end

function InteractiveAnimation:playEmoji(type, index, parent)
    local animationView = newObject(self.ImageArrayPrefabs)
    animationView.transform:SetParent(parent.transform)
    animationView.transform.localScale = Vector3.one
    animationView.transform.localPosition = Vector3.zero

    local animArray = animationView:GetComponent('ChipAnim')
    local showImage = animationView:GetComponent('Image')
    showImage.sprite = UIHelper.LoadSprite(EMOJI_PATH..type.."/emoji_"..type.."_"..index.."_1")
    showImage:SetNativeSize()

    for i = 1, self.EMOJI_FPS_CONFIG[type][index] do
        local imagName = EMOJI_PATH..type.."/emoji_"..type.."_"..index.."_"..i
        animArray.SpriteFrames:Add(UIHelper.LoadSprite(imagName))
    end

    animArray.FPS = self.EMOJI_FPS_CONFIG[type][index] * 0.8
    -- animArray.FPS = 10
    animArray.AutoPlay = true
    animArray.Loop = true
    local loopTime = 3
    animArray.DoneFunction = function()
        loopTime = loopTime - 1
        if loopTime == 0 then
            animArray:Stop()
            hide(animationView)
            hide(parent)
            destroy(animationView)
        end
    end
end

function InteractiveAnimation:playWinnerAnimation(type, money, doneCallback)
    if self.winner then
        return
    end
    self.winner = newObject(self.WinnerPrefabs[type])
    self.winner.name = "WinnerAnimation"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.winner.transform:SetParent(parent.transform)
    self.winner.transform.localScale = Vector3.one
    self.winner.transform.localPosition = Vector3.zero
    self.winner.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.winner.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    self.infoText = self.winner.transform:Find("infoText").gameObject
    self.infoText:GetComponent('Text').text = string.formatNumberThousands(money)
    GameManager.SoundManager:PlaySoundWithNewSource("WheelWin")
    
    local dragonBones = self.winner.transform:Find("fla_winner_"..type).gameObject

    local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    -- if type then
    --     UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    --     UnityArmatureComponent = DragonBones.UnityFactory.factory:BuildArmatureComponent(type, "winner", nil, nil, dragonBones, true)
    -- else
    --     -- UnityArmatureComponent 
    -- end

    local Animation = UnityArmatureComponent.animation 
    local AnimationData = Animation.animations:get_Item("play")
    local duration = AnimationData.duration
    Animation:Play("play")

    if money > 0 then
        local color = self.infoText:GetComponent("Text").color
        local r,g,b,a = color:Get()
        local alphaColor = Color.New(r,g,b,0)
        self.infoText:GetComponent("Text").color = alphaColor
        self.infoText:GetComponent("Text"):DOColor(color, duration*0.5)
    end

    Timer.New(function()
        if doneCallback then
            doneCallback()
        end
        destroy(self.winner)
        self.winner = nil
    end, duration, 0, true):Start()
end


function InteractiveAnimation:playAllinAnimation()
    if self.allin then
        return
    end
    self.allin = newObject(self.AllinPrefabs)
    self.allin.name = "AllinAnimation"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.allin.transform:SetParent(parent.transform)
    self.allin.transform.localScale = Vector3.one
    self.allin.transform.localPosition = Vector3.zero
    self.allin.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.allin.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    GameManager.SoundManager:PlaySoundWithNewSource("allin")
    
    local dragonBones = self.allin.transform:Find("allin").gameObject
    local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    local Animation = UnityArmatureComponent.animation 
    local AnimationData = Animation.animations:get_Item("play")
    local duration = AnimationData.duration
    Animation:Play("play")

    Timer.New(function()
        destroy(self.allin)
        self.allin = nil
    end, duration, 0, true):Start()
end

return InteractiveAnimation