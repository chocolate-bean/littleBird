local RedpacketSelectView = class("RedpacketSelectView")

RedpacketSelectView.MISSION_COUNT = 5
RedpacketSelectView.SELECT_COUNT = 5
RedpacketSelectView.ImagePath = "Images/SceneLandlords/redpacket/"

RedpacketSelectView.EventCallback = {
    InitDone = 1,
    Select   = 2,
    Dismiss  = 3
}

RedpacketSelectView.AnimationTime = {
    Show    = 0.3,
    Down    = 0.2,
    Realign = 0.3,
    Select  = 0.1,
    Flip    = 0.1,
}

RedpacketSelectView.DelayTime = {
    AutoDismiss = 3,
}

function RedpacketSelectView:ctor(param, callback)
    resMgr:LoadPrefabByRes("Room", { "RedpacketSelectPanel" }, function(objs)
        self:initView(objs, param, callback)
    end)
end

function RedpacketSelectView:initView(objs, param, callback)

    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "RedpacketSelectView"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
    
    self:initProperties(callback)
    self:initUIControls()
    self:initUIDatas(param)
    self:show()
    if self.callback then
        self.callback(RedpacketSelectView.EventCallback.InitDone)
    end
end

function RedpacketSelectView:initProperties(callback)
    self.callback = callback
    self.redpackets = {}
    self.missions = {}
end

function RedpacketSelectView:initUIControls()
    self:initMissionViewControls()
    self:initSelectViewControls()
end


function RedpacketSelectView:initUIDatas(param)
    self.datas = param.datas
    self:initMissionViewDatas()
    self:initSelectViewDatas()
end



function RedpacketSelectView:updateUIDatas(type)

end

function RedpacketSelectView:show()
    GameManager.PanelManager:addPanel(self, true)
    self:showMissionView()
end

function RedpacketSelectView:onClose()
    if self.callback then
        self.callback(RedpacketSelectView.EventCallback.Dismiss)
    end
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

--[[
    missionView
]]

function RedpacketSelectView:initMissionViewControls()
    self.missionView     = self.view.transform:Find("missionView").gameObject
    self.titleText       = self.view.transform:Find("missionView/titleView/Text").gameObject
    self.closeButton     = self.view.transform:Find("missionView/titleView/closeButton").gameObject
    self.currentText     = self.view.transform:Find("missionView/contentView/titleBg/currentText").gameObject
    self.currentInfoText = self.view.transform:Find("missionView/contentView/titleBg/currentText/currentInfoText").gameObject
    self.currentSlider   = self.view.transform:Find("missionView/contentView/Slider").gameObject
    self.dolls           = self.view.transform:Find("missionView/contentView/Slider/dolls").gameObject
    self.dollsBubble     = self.view.transform:Find("missionView/contentView/Slider/dolls/bubble").gameObject
    self.dollsWords      = self.view.transform:Find("missionView/contentView/Slider/dolls/bubble/Text").gameObject
    self.warmText        = self.view.transform:Find("missionView/contentView/warmText").gameObject

    for index = 1, RedpacketSelectView.MISSION_COUNT do
        local mission = {}
        mission.view          = self.view.transform:Find("missionView/contentView/Slider/goalArray/item ("..index..")").gameObject
        mission.goal          = mission.view.transform:Find("goal").gameObject
        mission.goalText      = mission.view.transform:Find("goal/Text").gameObject
        mission.button        = mission.view.transform:Find("base/redpacketButton").gameObject
        mission.buttonImage   = mission.button:GetComponent('Image')
        mission.receivedImage = mission.view.transform:Find("received").gameObject
        mission.receivedText  = mission.view.transform:Find("received/Text").gameObject
        self.missions[index] = mission
        UIHelper.AddButtonClick(mission.button, buttonSoundHandler(self, function()
            self:onMissionClick(index)
        end))
    end
    UIHelper.AddButtonClick(self.closeButton, buttonSoundHandler(self, function()
        self:onClose()
    end))

    self.currentSlider:GetComponent('Slider').interactable = false
end


function RedpacketSelectView:initMissionViewDatas()
    --[[
        和数据无关的初始化
    ]]

    for index, item in ipairs(self.missions) do
        item.buttonImage.sprite = UIHelper.LoadSprite(RedpacketSelectView.ImagePath.."MFNHB_hongbao_"..index)
        item.buttonImage:SetNativeSize()
        if index > 5 then
            item.button.transform.localPosition = Vector3.New(0,-5,0)
        end
        hide(item.receivedImage)
    end
    
    local datas = self.datas
    self.titleText:setText(datas.condition.title)
    self.currentInfoText:setText(datas.condition.titleInfo)
    self.currentText:GetComponent('Text').text = datas.current

    --[[
        计算slider
    ]]
    local sliderConfig = {
        7,
        28,
        49,
        70,
        90,
    }
    local currentSliderValue = sliderConfig[#sliderConfig]
    for index, value in ipairs(sliderConfig) do
        -- 需不需要限制住
        local goal = datas.current -- 不限制 有多少是多少
        -- local goal = datas.currentGoal -- 限制 没完成这个 下一个就不过去

        if goal < datas.goal[index].goal then

            local minValue = 0
            local maxValue = value
            local minGoal  = 0
            local maxGoal  = datas.goal[index].goal

            if index ~= 1 then
                minGoal  = datas.goal[index - 1].goal
                minValue = sliderConfig[index - 1]
            end

            local rateValue = (maxValue - minValue) / (maxGoal - minGoal)
            currentSliderValue = (goal - minGoal) * rateValue + minValue

            break
        elseif goal == datas.goal[index].goal then
            currentSliderValue = value
            break
        end
    end
    if currentSliderValue == sliderConfig[#sliderConfig] then
        currentSliderValue = self.currentSlider:GetComponent('Slider').maxValue
    end
    self.currentSlider:GetComponent('Slider').value = currentSliderValue

    for index, item in ipairs(self.missions) do
        local goal = datas.goal[index].goal
        local goalId = datas.goal[index].id
        item.goalText:GetComponent('Text').text = goal
        if datas.currentGoal == goal then
            if datas.current < goal then
                local last = goal - datas.current
                local lastString = string.format(datas.condition.tips, last)
                self.dollsWords:GetComponent('Text').text = lastString
            else
                local string = T("<color=#963C1E>已可领取</color>")
                self.dollsWords:GetComponent('Text').text = string
                -- 如果是最后一个的话
                if currentSliderValue == self.currentSlider:GetComponent('Slider').maxValue then
                    self.dollsWords:GetComponent('Text').text = T("全部完成")
                    self.dollsBubble.transform.localPosition = Vector3.New(self.dollsBubble.transform.localPosition.x * -1, self.dollsBubble.transform.localPosition.y, 0)
                    self.dollsBubble.transform.localEulerAngles = Vector3.New(0,180,0)
                    self.dollsWords.transform.localEulerAngles = Vector3.New(0,180,0)
                end
            end
        end

        --[[
            判断领取过没有
        ]]
        for i, received in ipairs(datas.received) do
            if received.id == goalId then
                item.button:GetComponent('Button').interactable = false
                show(item.receivedImage)
                item.receivedText:GetComponent('Text').text = received.num
                item.goal:GetComponent('Image').sprite = UIHelper.LoadSprite(RedpacketSelectView.ImagePath.."bg_goal_1")
                item.goalText:GetComponent('Text').color = Color.white
                item.goalText:GetComponent('Outline').effectColor = Color.New(58/255,41/255,26/255,0.5*255)
            end
        end
    end
end

function RedpacketSelectView:canTouchAnimation(obj)
    local scaleAniamtion = obj.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.7)
    scaleAniamtion:SetEase(DG.Tweening.Ease.Linear)
    scaleAniamtion:SetLoops(1000, DG.Tweening.LoopType.Yoyo)
end

--[[
    selectView
]]

function RedpacketSelectView:initSelectViewControls()
    self.selectView = self.view.transform:Find("selectView").gameObject
    self.redpacketView = self.view.transform:Find("selectView/redpacketView").gameObject

    for index = 1, RedpacketSelectView.SELECT_COUNT do
        local redpacket = {}
        redpacket.view      = self.view.transform:Find("selectView/redpacketView/redpacket ("..index..")").gameObject
        redpacket.image     = redpacket.view:GetComponent('Image')
        redpacket.effect    = redpacket.view.transform:Find("effect").gameObject
        redpacket.openImage = redpacket.view.transform:Find("openImage").gameObject
        redpacket.titleText = redpacket.view.transform:Find("openImage/titleText").gameObject
        redpacket.icon      = redpacket.view.transform:Find("openImage/icon").gameObject
        redpacket.infoText  = redpacket.view.transform:Find("openImage/infoText").gameObject
        redpacket.number    = redpacket.view.transform:Find("openImage/number").gameObject
        self.redpackets[index] = redpacket

        UIHelper.AddButtonClick(redpacket.view, buttonSoundHandler(self, function()
            self:onRedpacketClick(index)
        end))
    end

    self.waitText      = self.view.transform:Find("selectView/titleBg/waitText").gameObject
    self.selectedText  = self.view.transform:Find("selectView/titleBg/selectedText").gameObject

    UIHelper.AddButtonClick(self.selectView, buttonSoundHandler(self, function()
        self:onClose()
    end))
    self.selectView:GetComponent('Button').interactable = false
end

function RedpacketSelectView:initSelectViewDatas()
    
end

--[[
    动画相关
]]
function RedpacketSelectView:showMissionView()
    show(self.missionView)
    hide(self.selectView)

    local originScale = 0.2
    self.missionView.transform.localScale = Vector3.New(originScale,originScale,originScale)
    self.missionView.transform:DOScale(Vector3.one, RedpacketSelectView.AnimationTime.Show)
    
end

function RedpacketSelectView:showSelectView(datas, receiveCallback)

    self.receiveData = datas
    self.receiveCallback = receiveCallback

    hide(self.missionView)
    show(self.selectView)

    show(self.waitText)
    hide(self.selectedText)

    --[[
        第一幅动画
    ]]
    for index, redpacket in ipairs(self.redpackets) do
        hide(redpacket.view)
        redpacket.view:GetComponent('Button').interactable = false
    end

    local imagePath = RedpacketSelectView.ImagePath
    local firstRedpacket = self.redpackets[1]
    show(firstRedpacket.view)
    firstRedpacket.image.sprite = UIHelper.LoadSprite(imagePath.."1")
    firstRedpacket.image:SetNativeSize()

    local originY = firstRedpacket.view.transform.localPosition.y
    firstRedpacket.view.transform.localPosition = Vector3.New(0, 128, 0)
    local moveAnimation = firstRedpacket.view.transform:DOLocalMoveY(originY, RedpacketSelectView.AnimationTime.Down)

    moveAnimation:OnComplete(function()
        firstRedpacket.image.sprite = UIHelper.LoadSprite(imagePath.."2")
        firstRedpacket.image:SetNativeSize()

        -- 第二幅动画

        local mid = #self.redpackets * 0.5 + 0.5
        local padding = 2
        local width = 243 -- bg_select图片的宽度

        for index, redpacket in ipairs(self.redpackets) do
            show(redpacket.view)
            if mid ~= index then
                redpacket.image.sprite = UIHelper.LoadSprite(imagePath.."2")
                redpacket.image:SetNativeSize()
            end
            local aimPosition = Vector3.New((padding + width) * (index - mid), originY, 0)
            local animation = redpacket.view.transform:DOLocalMove(aimPosition, RedpacketSelectView.AnimationTime.Realign)
            animation:SetEase(DG.Tweening.Ease.Linear)
            animation:OnComplete(function()
                redpacket.view:GetComponent('Button').interactable = true
                redpacket.image.sprite = UIHelper.LoadSprite(imagePath.."bg_select")
                redpacket.image:SetNativeSize()
            end)
        end
        
    end)
end

function RedpacketSelectView:showSelectedRedpacket(selectIndex)

    hide(self.waitText)
    show(self.selectedText)

    for index, redpacket in ipairs(self.redpackets) do
        redpacket.view:GetComponent('Button').interactable = false

        local scaleRate = 0.9
        if selectIndex == index then
            scaleRate = 1
        end
        local aimScale = Vector3.New(scaleRate, scaleRate, 0)
        local animation = redpacket.view.transform:DOScale(aimScale, RedpacketSelectView.AnimationTime.Select)
        animation:SetEase(DG.Tweening.Ease.Linear)
        animation:OnComplete(function()
            if selectIndex == index then
                redpacket.view.transform:SetSiblingIndex(#self.redpackets)
                self:flipRedpacket(index, self.receiveData.gainJewel)
                self:playShowAnimation(index, function()
                    -- 在龙骨动画完成后 使得背景可点消失
                    self.selectView:GetComponent('Button').interactable = true
                end)
            else
                local otherIndex
                if selectIndex > index then
                    otherIndex = index
                else
                    otherIndex = index - 1
                end
                self:flipRedpacket(index, self.receiveData.otherJewel[otherIndex])
            end
        end)
    end

    Timer.New(function()
        if self.receiveCallback then
            self.receiveCallback()
        end
    end,RedpacketSelectView.AnimationTime.Select,1,true):Start()
    
    Timer.New(function()
        self:onClose()
    end, RedpacketSelectView.DelayTime.AutoDismiss, 0, true):Start()
end

function RedpacketSelectView:flipRedpacket(index, count)
    local redpacket = self.redpackets[index]
    local rotateAnimation = redpacket.view.transform:DOLocalRotate(Vector3.New(0,90,0), RedpacketSelectView.AnimationTime.Flip)
    rotateAnimation:SetEase(DG.Tweening.Ease.Linear)
    rotateAnimation:OnComplete(function()
        show(redpacket.openImage)
        redpacket.number:GetComponent('Text').text = count
        redpacket.view.transform:DOLocalRotate(Vector3.New(0,180,0), RedpacketSelectView.AnimationTime.Flip)
    end)
end

function RedpacketSelectView:flipBackRedpacket(index)
    local redpacket = self.redpackets[index]
    local rotateAnimation = redpacket.view.transform:DOLocalRotate(Vector3.New(0,90,0), RedpacketSelectView.AnimationTime.Flip)
    rotateAnimation:SetEase(DG.Tweening.Ease.Linear)
    rotateAnimation:OnComplete(function()
        hide(redpacket.openImage)
        redpacket.view.transform:DOLocalRotate(Vector3.zero, RedpacketSelectView.AnimationTime.Flip)
    end)
end


--[[
    event handle
]]
function RedpacketSelectView:onRedpacketClick(index)
    self:showSelectedRedpacket(index)
end

function RedpacketSelectView:onMissionClick(index)
    --[[
        判断index 是不是超过了
    ]]
    local selectGoal = self.datas.goal[index]
    if selectGoal.goal > self.datas.currentGoal then
        index = self.datas.currentId
    end
    if self.callback then
        self.callback(RedpacketSelectView.EventCallback.Select, index)
    end
end

--[[
    龙骨动画    
]]


function RedpacketSelectView:playShowAnimation(index, doneCallback)

    local effect = self.redpackets[index].effect
    show(effect)
    GameManager.SoundManager:PlaySoundWithNewSource("allin")

    local dragonBones = effect.transform:Find("fla_niyingle").gameObject
    local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
    local Animation = UnityArmatureComponent.animation 
    local AnimationData = Animation.animations:get_Item("niyingle")
    local duration = AnimationData.duration
    Animation:Play("play")

    Timer.New(function()
        hide(dragonBones)
        if doneCallback then
            doneCallback()
        end
    end, duration, 0, true):Start()

end


return RedpacketSelectView