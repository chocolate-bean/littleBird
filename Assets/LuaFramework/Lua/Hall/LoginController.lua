local LoginController = class("LoginController")

LoginController.AnimTime = 0.5

function LoginController:ctor(scene)
    self.scene_ = scene 
end

function LoginController:loginWithPhone(phone,password,errorCallback)
    self:startPhoneLogin_(phone,password,errorCallback)
end

function LoginController:loginWithWX()
    self:startWXLogin_()
end

function LoginController:loginWithGuest()
    self:startGuestLogin_()
end

function LoginController:startPhoneLogin_(phone,password,errorCallback)
    http.login(
        "PHONE",
        nil,
        phone,
        password,
        function(data)
            
            UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"PHONE")
            UnityEngine.PlayerPrefs.SetString(DataKeys.PHONE,phone)
            UnityEngine.PlayerPrefs.SetString(DataKeys.PASSWORD,password)
            self:onLoginSucc_(data)
        end,
        function(data)
            
            if errorCallback then
                errorCallback()
            end
            self:onLoginError_(data)
        end
    )
end

function LoginController:startWXLogin_()
    -- -- TODO 微信登陆
    -- Token    13_PqrkAg4ck-FW-a_vaMOk3Oq9FMkkznywVLqN2NcK81UzV5GiWrPQAIx_n5BSKrlwVVjsX033UY0Mie4aUwv9RwVkVOLQisVLt1276w0x6UI
    local loginWithWXCode = function(code)
        http.login(
            "WX_CODE",
            code,
            nil,
            nil,
            function(data)
                local token = data["aUser.access_token"]
                UnityEngine.PlayerPrefs.SetString(DataKeys.WX_ACCESS_TOKEN, token)
                UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"WX")
                self:onLoginSucc_(data)
            end,
            function(data)
                self:onLoginError_(data)
            end
        )
    end

    sdkMgr:WechatLogin(function(code)
        if code then
            loginWithWXCode(code)
        else
        end
    end)
    -- loginWithWXCode("071vNYOS0rKlwY1W5lNS0a2hPS0vNYOZ")
end

function LoginController:onOPPOLogin_()
    sdkMgr:OPPOLogin(function(code)
        if code then
            print("lua 获取到了 token和ssoid ?")
            local data = json.decode(code)
            self:onOPPOLoginWithParms(data.token, data.ssoid)
        else
        end
    end)
    -- local stringObject = {
    --     authToken = "whosyourdaddy",
    --     openId = "whosyourdaddy",
    -- }
    -- self:onOPPOLoginWithParms(stringObject.authToken, stringObject.openId)
end

function LoginController:onVIVOLogin_()
    sdkMgr:VIVOLogin(function(code)
        if code then
            print("lua 获取到了 vivo的回调了:" .. code)
            local jsonObject = json.decode(code)
            self:onVIVOLoginWithParms(jsonObject.authToken, jsonObject.openId)
        else
        end
    end)
    -- local stringObject = {
    --     authToken = "whosyourdaddy",
    --     openId = "whosyourdaddy",
    -- }
    -- self:onVIVOLoginWithParms(stringObject.authToken, stringObject.openId)
end

function LoginController:onOPPOLoginWithParms(token, ssoid)
    http.login(
        "OPPO",
        token,
        ssoid,
        nil,
        function(data)
            UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"LOGINOUT")
            self:onLoginSucc_(data)
        end,
        function(data)
            self:onLoginError_(data)
        end
    )
end

function LoginController:onVIVOLoginWithParms(authToken, openId)
    http.login(
        "VIVO",
        authToken,
        openId,
        nil,
        function(data)
            UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"LOGINOUT")
            self:onLoginSucc_(data)
        end,
        function(data)
            self:onLoginError_(data)
        end
    )
    -- local stringObject = {"userName":"186****3386","openId":"7f353ce3ce0c51dd","authToken":"7f353ce3ce0c51dd_7f353ce3ce0c51dd_0f2e4f417530c937f05ed552323ccdf0"}
end

function LoginController:onWXLoginSuccess(accessToken)
    http.login(
        "WX",
        accessToken,
        nil,
        nil,
        function(data)
            UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"WX")
            self:onLoginSucc_(data)
        end,
        function(data)
            self:onLoginError_(data)
        end
    )
end

function LoginController:onFBLoginSuccess(accessToken)
    -- body
    self.facebookAccessToken_ = accessToken
    http.login(
        "FACEBOOK",
        accessToken,
        nil,
        nil,
        function(data)
            -- body
            UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"FACEBOOK")
            UnityEngine.PlayerPrefs.SetString(DataKeys.FACEBOOK_ACCESS_TOKEN,accessToken)
            self:onLoginSucc_(data)
        end,
        function(data)
            self:onLoginError_(data)
        end
    )
end

function LoginController:checkAutoLogin(callbcak)
    local lastLoginType = UnityEngine.PlayerPrefs.GetString(DataKeys.LAST_LOGIN_TYPE)
    if lastLoginType then
        if lastLoginType == "PHONE" then
            local phone = UnityEngine.PlayerPrefs.GetString(DataKeys.PHONE)
            local password = UnityEngine.PlayerPrefs.GetString(DataKeys.PASSWORD)
            self:loginWithPhone(phone,password)
        elseif lastLoginType == "WX" then
            local accessToken = UnityEngine.PlayerPrefs.GetString(DataKeys.WX_ACCESS_TOKEN)
            self:onWXLoginSuccess(accessToken)
        elseif lastLoginType == "FACEBOOK" then
            local accessToken = UnityEngine.PlayerPrefs.GetString(DataKeys.FACEBOOK_ACCESS_TOKEN)
            self:onFBLoginSuccess(accessToken)
        elseif lastLoginType == "GUEST" then
            if callbcak then
                callbcak()
            end
        elseif lastLoginType == "OPPO" then
            local token = UnityEngine.PlayerPrefs.GetString(DataKeys.OPPO_TOKEN)
            local ssoid = UnityEngine.PlayerPrefs.GetString(DataKeys.OPPO_SSOID)
            self:onOPPOLoginWithParms(token,ssoid)
        elseif lastLoginType == "LOGINOUT" then
            if callbcak then
                callbcak()
            end
        end
    else
        if callbcak then
            callbcak()
        end
    end
end

function LoginController:checkLogin()
    local lastLoginType = UnityEngine.PlayerPrefs.GetString(DataKeys.LAST_LOGIN_TYPE)
    if lastLoginType then
        if lastLoginType == "PHONE" then
            return true
        elseif lastLoginType == "WX" then
            return true
        elseif lastLoginType == "FACEBOOK" then
            return true
        elseif lastLoginType == "GUEST" then
            return true
        elseif lastLoginType == "OPPO" then
            return true
        elseif lastLoginType == "LOGINOUT" then
            return false
        end
    else
        return false
    end
end

-- 登陆成功
function LoginController:onLoginSucc_(data)
    UnityEngine.PlayerPrefs.SetString(DataKeys.LOGIN_MODEL,"LOGIN")
    self.scene_:onLoginSucc(data)
end

-- 登陆失败
function LoginController:onLoginError_(data)
    UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"LOGINOUT")
    GameManager.TopTipManager:showTopTip(data.data.message)
    self.scene_.view:showButtons(0)
end

function LoginController:onCleanUp()
    if self.scene_.view.onCleanUp then
        self.scene_.view:onCleanUp()
    end
end

function LoginController:exitScene()
    GameManager:exitGame()
end

return LoginController