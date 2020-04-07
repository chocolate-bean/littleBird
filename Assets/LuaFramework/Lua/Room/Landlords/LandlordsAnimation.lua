local LandlordsAnimation = class("LandlordsAnimation")

LandlordsAnimation.MUSIC_PATH = "landlords/cardType"

LandlordsAnimation.Animation = {
    Normal  = {
        prefab      = "CardType_1",
        dragonBones = "101",
        animation   = "newAnimation",
        music       = "landlords/cardType/liandui_texiao",
    },
    Special  = {
        prefab      = "CardType_2",
        dragonBones = "1010",
        animation   = "newAnimation",
        music       = "landlords/cardType/liandui_texiao",
    },
    Lose  = {
        prefab      = "CardType_3",
        dragonBones = "sp",
        animation   = "newAnimation",
        music       = "landlords/cardType/liandui_texiao",
    },
    Liandui  = {
        prefab      = "LianduiDragonbones",
        dragonBones = "fla_szdhTwoLine",
        animation   = "newAnimation",
        music       = "landlords/cardType/liandui_texiao",
    },
    Shunzi   = {
        prefab      = "ShunziDragonbones",
        dragonBones = "fla_szdhOneLine",
        animation   = "sunzi",
        music       = "landlords/cardType/shunzi_texiao",
    },
    Zhadan  = {
        prefab      = "ZhadanDragonbones",
        dragonBones = "fla_zhadan",
        animation   = "zadan",
        music       = "landlords/cardType/zhadan_texiao",
    },
    Wangzha  = {
        prefab      = "WangzhaDragonbones",
        dragonBones = "armature",
        animation   = "newAnimation",
        music       = "landlords/cardType/wangzha_texiao",
    },
    Chuntian  = {
        prefab      = "ChuntianDragonbones",
        dragonBones = "fla_cuntiandonghua",
        animation   = "cctiandohua",
        music       = "landlords/cardType/chuntian_texiao",
    },
    Feiji  = {
        prefab      = "FeijiDragonbones",
        dragonBones = "armatureName",
        animation   = "doudizhu_feiji",
        music       = "landlords/cardType/feiji_texiao",
    },
}


function LandlordsAnimation:ctor(animationName, callback)
    if type(animationName) == "string" then
        animationName = {animationName}
    end
        
    resMgr:LoadPrefabByRes("Room", animationName, function(objs)
        self:setPrefabs(objs, animationName)
        if callback then
            callback(self)
        end
    end)
end

function LandlordsAnimation:setPrefabs(objs, animationName)
    self.animations = {}
    for index, name in ipairs(animationName) do
        self.animations[name] = objs[index - 1]
    end
end

function LandlordsAnimation:playLandlordsAnimation(landlordsConfig, params, doneCallback)
    self:playAnimation(landlordsConfig, params, doneCallback)
end

function LandlordsAnimation:playAnimation(landlordsConfig, params, doneCallback)
    params = params or {}

    local prefab      = landlordsConfig.prefab
    local music       = landlordsConfig.music
    local dragonBones = landlordsConfig.dragonBones
    local animation   = landlordsConfig.animation
    local dontDestroy = params.dontDestroy
    local parent      = params.parent
    local position    = params.position
    local scale       = params.scale
    local animationView = newObject(self.animations[prefab])
    animationView.name = prefab
    local parent = parent or UnityEngine.GameObject.Find("Canvas")
    animationView.transform:SetParent(parent.transform)
    animationView.transform.localScale = scale or Vector3.one
    animationView.transform.localPosition = position or Vector3.zero
    animationView.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    animationView.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)

    GameManager.SoundManager:PlaySoundWithNewSource(music)
    
    local dragonBones = animationView.transform:Find(dragonBones).gameObject
    local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    local Animation = UnityArmatureComponent.animation 
    local AnimationData = Animation.animations:get_Item(animation)
    local duration = AnimationData.duration
    Animation:Play(animation)


    Timer.New(function()
        if not dontDestroy then
            destroy(animationView)
            animationView = nil
        end
        if doneCallback then
            doneCallback()
        end
    end, duration, 0, true):Start()
    return animationView
end



return LandlordsAnimation