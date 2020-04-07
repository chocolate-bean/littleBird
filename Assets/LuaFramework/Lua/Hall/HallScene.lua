local HallScene = class("HallScene")
local HallController = import("Hall.HallController")
local HallView = import("Hall.MainHall")

function HallScene:ctor(loginData)
    self.loginData = loginData
    LuaFramework.Util.Log("HallScene:ctor")
    SceneManager.LoadSceneAsync("hall")
    self:init()
end

function HallScene:init()
    
    -- self.viewType_ = viewType or 0
    self.controller_ = HallController.new(self)

    self.animTime = self.controller_.AnimTime
end

-- 显示主界面视图
function HallScene:showMainHallView_()
    -- 主界面视图
    self.mainHallView_ = HallView.new(self.controller_)
    -- self.mainHallView_:setShowState()
    -- self.mainHallView_:playShowAnim()
    self.view_ = self.mainHallView_
end

function HallScene:creatView()
    if self.loginData == 2 then
        -- 请求网络去判断是否需要重新登录
        http.getLoadSwitchControl(
            function(callData)
                GameManager.GameConfig.casinoWin = callData.casinoWin
                GameManager.GameConfig.fishingRoom = callData.fishing_room
                GameManager.GameConfig.HasDiamond = callData.platform_core -- 0是没有钻石 1是有砖石
                GameManager.GameConfig.LimitPay = callData.snatch -- 夺宝活动开关

                -- 水果机 和 牛牛的显示开关 1是关 0是开
                GameManager.GameConfig.closeSlot   = callData.closeSlot
                GameManager.GameConfig.closeNiuniu = callData.closeNiuniu
                GameManager.GameConfig.closeRedpacket = callData.closeRedpacket

                -- 敏感功能开关
                GameManager.GameConfig.SensitiveSwitch = {
                    showRedpacket    = callData.closeRedpacket == 0,      -- 红包相关
                    showLottery      = callData.closeWheelLucky == 0,     -- 十连抽的 抽奖功能
                    showShare        = callData.closeShare == 0,          -- 带有分享的大转盘
                    showShareFriend  = callData.closeShareFriend == 0,    -- 跳转公众号的分享
                    showOneToMillion = callData.closeCapticalProfit == 0, -- 一本万利
                }
                self:showMainHallView_()
            end,
            function(errorData)
                self:showMainHallView_()
            end
        )
    else
        self.controller_:onLoginSucc_(self.loginData)
    end
end

-- 登陆成功动画
function HallScene:onLoginSucc()
    self:showMainHallView_()
end

-- 登出成功动画
function HallScene:onLogoutSucc()
    GameManager:enterScene("LoginScene",0)
end

return HallScene