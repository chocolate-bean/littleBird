local HDDJController = class("HDDJController")

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

HDDJController.EMOJI_FPS_CONFIG = {
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


HDDJController.ANIMATION_CONFIG = {
    Winner = {
        Small = 1,
        Mid   = 2,
        Big   = 3,
        Huge  = 4,
    }
}

function HDDJController:ctor()
    resMgr:LoadPrefabByRes("Animation", {"ImageArray", "RewardDragonbones", "AllinDragonbones", "fla_winner_1", "fla_winner_2", "fla_winner_3", "fla_winner_4", }, function(objs)
        self:setPrefabs(objs)
    end)
end

function HDDJController:setPrefabs(objs)
    self.ImageArrayPrefabs = objs[0]
    self.RewardPrefabs     = objs[1]
    self.AllinPrefabs      = objs[2]
    self.WinnerPrefabs     = {objs[3], objs[4], objs[5], objs[6]}
end

-- 互动道具
function HDDJController:playHDDJWithType(type, srcPos, tarPos)
    local animationView = newObject(self.ImageArrayPrefabs)
    animationView.transform:SetParent(UnityEngine.GameObject.Find("NiuniuView").transform)
    animationView.transform.localScale = Vector3.one
    animationView.transform.localPosition = srcPos

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

    local moveTime = 0.5
    local moveAnimation = animationView.transform:DOLocalMove(tarPos, moveTime)
    moveAnimation:OnComplete(function()
        animArray:Play() 
        GameManager.SoundManager:PlaySound(HDDJ_NAME_CONFIG[type])        
    end)
end

function HDDJController:playHDDJWithCount(count, type, srcPos, tarPos)
    if count == 1 then
        self:playHDDJWithType(type, srcPos, tarPos)
        return
    end
    for index = 1, count do
        Timer.New(function ()
            self:playHDDJWithType(type, srcPos, tarPos)
        end, math.random(1, 2) * 0.1 * (index - 1), 1, true):Start()
    end
end

-- 互动表情
function HDDJController:playEmojiWithType(type, index, srcPos)
    local animationView = newObject(self.ImageArrayPrefabs)
    animationView.transform:SetParent(UnityEngine.GameObject.Find("NiuniuView").transform)
    animationView.transform.localScale = Vector3.one
    animationView.transform.localPosition = srcPos

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
            destroy(animationView)
        end
    end
end

return HDDJController