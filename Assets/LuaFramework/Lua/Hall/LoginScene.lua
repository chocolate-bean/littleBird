local LoginSence = class("LoginSence")
local LoginGameView = import("Hall.LoginGameView")
local LoginController = import("Hall.LoginController")

function LoginSence:ctor(viewType)
    self.viewType_ = viewType or 0
    LuaFramework.Util.Log("LoginSence:ctor")
    SceneManager.LoadSceneAsync("login")
    self:init()
end

function LoginSence:init()
    
    self.controller_ = LoginController.new(self)

    self.animTime = self.controller_.AnimTime
end

function LoginSence:creatView()
    
    self.view = LoginGameView.new(self.controller_)
    self.view:setShowState()
    self.view:playShowAnim()
end

-- 登陆成功动画
function LoginSence:onLoginSucc(data)
    self.view:playHideAnim()
    Timer.New(function()
        GameManager:enterScene("HallScene",data)
    end, self.animTime, 1, true):Start()
end

return LoginSence