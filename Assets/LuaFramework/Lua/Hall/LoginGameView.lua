local LoginGameView = class("LoginGameView")

function LoginGameView:ctor(controller)
    self.controller_ = controller

    -- self.bg          = UnityEngine.GameObject.Find("Canvas/LoginBg")
    self.animation   = UnityEngine.GameObject.Find("Canvas/animation")

    self.versionText = UnityEngine.GameObject.Find("Canvas/versionText").gameObject
    -- 微信登陆按钮
    self.wxButton    = UnityEngine.GameObject.Find("Canvas/layout/wxButton").gameObject
    UIHelper.AddButtonClick(self.wxButton, buttonSoundHandler(self, self.onWxButtonClick))
    self.wxButton:SetActive(false)
    -- 手机号登陆按钮
    self.phoneButton = UnityEngine.GameObject.Find("Canvas/layout/phoneButton").gameObject
    UIHelper.AddButtonClick(self.phoneButton, buttonSoundHandler(self, self.onPhoneButtonClick))
    self.phoneButton:SetActive(false)
    -- FB登陆按钮
    self.fbButton    = UnityEngine.GameObject.Find("Canvas/fbButton").gameObject
    UIHelper.AddButtonClick(self.fbButton, buttonSoundHandler(self, self.onFBButtonClick))
    self.fbButton:SetActive(false)
    -- 游客登陆按钮
    self.guestButton    = UnityEngine.GameObject.Find("Canvas/guestButton").gameObject
    UIHelper.AddButtonClick(self.guestButton, buttonSoundHandler(self, self.onGuestButtonClick))
    self.guestButton:SetActive(false)

    self.loginButton   = UnityEngine.GameObject.Find("Canvas/loginButton").gameObject
    UIHelper.AddButtonClick(self.loginButton, buttonSoundHandler(self, function()
        if isOPPO() then
            self:onOPPOButtonClick()
        elseif isVIVO() then
            self:onVIVOButtonClick()
        end
    end))
    hide(self.loginButton)
    self.animTime = self.controller_.AnimTime
    self.versionText:GetComponent("Text").text = BM_UPDATE.CURVERSION
end

--为了适配高分辨率做的缩放处理
    -- local screen = UnityEngine.GameObject.Find("Canvas")
    -- self.dragonBone = self.animation.transform:Find("armatureName")
    -- local rate = screen.transform.sizeDelta.x / (1280 * (self.dragonBone.transform.localScale.x / 100))
    -- local rate = screen.transform.sizeDelta.x /1280 * (self.dragonBone.transform.localScale.x/100)
    -- self.dragonBone.transform.localScale = Vector2.New(
    --     rate < 1 and 1 / rate * 100 or rate * 100, 
    --     rate < 1 and 1 / rate * 100 or rate * 100
    -- )


-- 微信登陆
function LoginGameView:onWxButtonClick()
    self.controller_:startWXLogin_()
end

-- 游客登陆
function LoginGameView:onPhoneButtonClick()
    local PanelPhone = import("Panel.Login.PanelPhone").new(1,self.controller_)
end

-- FB登陆
function LoginGameView:onFBButtonClick()
    self.controller_:startFBLogin_()
end

-- 游客登陆
function LoginGameView:onGuestButtonClick()
    self.controller_:startGuestLogin_()
end

-- OPPO登陆
function LoginGameView:onOPPOButtonClick()
    self.controller_:onOPPOLogin_()
end

-- VIVO登陆
function LoginGameView:onVIVOButtonClick()
    self.controller_:onVIVOLogin_()
end

-- 这里用来处理进场的动画，暂时先不做这个
function LoginGameView:setShowState()
    
end

-- 这里用来处理进场的动画，暂时先不做这个
function LoginGameView:playShowAnim()
    local duration = 0.5
    if self.animation.transform:Find("home") then
        local dragonBones = self.animation.transform:Find("home").gameObject
        local UnityArmatureComponent = dragonBones:GetComponent('UnityArmatureComponent')
        local Animation = UnityArmatureComponent.animation 
        local AnimationData = Animation.animations:get_Item("newAnimation")
    end

    local w, h = getScreenSize()
    local offsetX = w * -0.55
    -- local bgMoveAnimation = self.bg.transform:DOLocalMoveX(offsetX, duration)
    -- bgMoveAnimation:SetEase(DG.Tweening.Ease.Linear)

    doFadeAutoShow(self.versionText, "Text", duration * 1.5, 0)

    if self.controller_:checkLogin() then
        Timer.New(function()
            self.controller_:checkAutoLogin(function()
                self:showButtons(duration * 0.5)
            end)
        end,duration,1,true):Start()
    else
        self:showButtons(duration * 0.5)
    end
end

function LoginGameView:showButtons(animationTime)
    Timer.New(function()
        if isOPPO() or isVIVO() then
            self.loginButton:SetActive(true)
            doFadeAutoShow(self.loginButton, "Image", animationTime, 0)
        else
            self.wxButton:SetActive(true)
            doFadeAutoShow(self.wxButton, "Image", animationTime, 0)

            -- doFadeAutoShow(self.phoneButton, "Image", animationTime, 0)
            if table.keyof(BM_UPDATE.PHONESID, tonumber(IdentityManager.Sid)) then
                self.phoneButton:SetActive(true)
                doFadeAutoShow(self.phoneButton, "Image", animationTime, 0)
            end
        end
    end, 0.7, 1, true):Start()
end

-- 这里用来隐藏的动画，暂时先不做这个
function LoginGameView:playHideAnim(viewType)
    
end

function LoginGameView:onCleanUp()
    
    self.view = nil
end

return LoginGameView