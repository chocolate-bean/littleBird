local OperationDialogManager = class("OperationDialogManager")
local PanelChaozhi  = require("Panel.Operation.PanelChaozhi")
local PanelFirstPay = require("Panel.Operation.PanelFirstPay")
local PanelPochan   = require("Panel.Operation.PanelPochan")
local PanelDuihuan   = require("Panel.Operation.PanelDuihuan")

--[[
-- 超值礼包 A
-- 首充    B 
-- 破产礼包 C
]]

OperationDialogManager.PlanConfig = {
    A = {
        Chaozhi = {
            class = PanelChaozhi,
            level = 2,      -- 优先级 越小越高
            switch = true,  -- 开关 true 展示 false 关闭 后台控制
            close = false,  -- 是否不显示 本地控制
        },
        Pochan = {
            class = PanelPochan,
            switch = true,
            close = false,
            level = 1,
        },
        Duihuan = {
            class = PanelDuihuan,
            switch = true,
            close = false,
            level = 3,
        },
    },
    B = {
        FirstPay = {
            class = PanelFirstPay,
            switch = true,
            close = false,
        },
    },
    C = {
        
    },
}

function OperationDialogManager:ctor(data)
    self.plans = OperationDialogManager.PlanConfig
    self.dialogs = {}
end

function OperationDialogManager:initProperties()
    self.haveShowList = {}
end

function OperationDialogManager:judegeIsBankrupt(money)
    local money = money or GameManager.UserData.money
    if GameManager.GameConfig.bankruptcyGrant and money < GameManager.GameConfig.bankruptcyGrant.deadline then
        return true
    end
    return false
end

function OperationDialogManager:getPriorityConfig(callback)
    http.getPriorityConfig(
        function(retData)
            for key, config in pairs(retData) do
                if key == "priority" then
                    for pName, pConfig in pairs(config) do
                        if pName == "Chaozhi" then
                            self.plans.A.Chaozhi.close  = pConfig.close
                            self.plans.A.Chaozhi.switch = pConfig.switch
                            self.plans.A.Chaozhi.level  = pConfig.level
                        elseif pName == "Pochan" then
                            self.plans.A.Pochan.close  = pConfig.close
                            self.plans.A.Pochan.switch = pConfig.switch
                            self.plans.A.Pochan.level  = pConfig.level
                        elseif pName == "Duihuan" then
                            self.plans.A.Duihuan.close  = pConfig.close
                            self.plans.A.Duihuan.switch = pConfig.switch
                            self.plans.A.Duihuan.level  = pConfig.level
                        end
                    end
                elseif key == "firstBlood" then
                    self.plans.B.FirstPay.close  = config.close
                    self.plans.B.FirstPay.switch = config.switch
                end
            end
            self.priorityData = retData
            callback(true)
        end,
        function(callData)
            dump(callData)
            callback(false)
            GameManager.TopTipManager.showTopTip(T("获取活动配置失败！"))
        end)
end

function OperationDialogManager:canGetBankruptReward()
    return GameManager.GameConfig.bankruptcyGrant.num ~= 0
end

function OperationDialogManager:canShow(planInfo)
    if planInfo.switch and not planInfo.close then
        return true
    else
        return false
    end
end

function OperationDialogManager:showDialog(planInfo, callback)
    planInfo.class.new(function(event)
        if event == planInfo.class.Event.Show then

        elseif event == planInfo.class.Event.Success then
            callback(true)
        elseif event == planInfo.class.Event.Cancel then
            callback(false)
        end
    end)
end

function OperationDialogManager:getBankruptReward(callback)
    if self:judegeIsBankrupt() and self:canGetBankruptReward() then
        http.receiveBankrupt(
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.UserData.money  = callData.latest_money
                    GameManager.GameConfig.bankruptcyGrant.num = GameManager.GameConfig.bankruptcyGrant.num - 1
                    if callback then
                        local isSuccess = true
                        callback(isSuccess)
                    end

                    local getTime = GameManager.GameConfig.bankruptcyGrant.allTime - GameManager.GameConfig.bankruptcyGrant.num
                    local infoText = string.format(T("第 <color=#FFFF00>%d/%d</color> 次领取"), getTime, GameManager.GameConfig.bankruptcyGrant.allTime)
                    GameManager.AnimationManager:playRewardAnimation(T("破产补助"),"1",T("金币x")..callData.msg, infoText)
                end
            end,
            function(callData)
                if callback then
                    local isSuccess = false
                    callback(isSuccess)
                end
                GameManager.TopTipManager:showTopTip(T("请求失败"))
            end)
    else
        if callback then
            local isSuccess = false
            callback(isSuccess)
        end
    end
end

function OperationDialogManager:showBankruptDialogs(callback)
    self:getPriorityConfig(function(isSuccess)
        if isSuccess then
            self:showDialogA(function(isShowSuccess)
                if isShowSuccess then
                    if callback then
                        callback(isShowSuccess)
                    end
                else
                    self:showDialogB(function(isShowSuccess)
                        if isShowSuccess then
                            if callback then
                                callback(isShowSuccess)
                            end
                        else
                            self:getBankruptReward(function(isSuccess)
                                if callback then
                                    callback(isSuccess)
                                end
                            end)
                        end
                    end)
                end
            end) 
        end
    end)
end

function OperationDialogManager:showDialogA(callback)
    local planA = self.plans.A
    local level
    local showPlan
    for key, planInfo in pairs(planA) do
        -- 找的要展示的 当前优先级最高的
        if self:canShow(planInfo) and ((not level) or (level and level > planInfo.level)) then
            level = planInfo.level
            showPlan = planInfo
        end
    end

    if not level then
        print("获取A最优优先级失败！")
        callback(false)
        return
    end

    self:showDialog(showPlan,callback)
end

function OperationDialogManager:showDialogB(callback)
    local planB = self.plans.B
    local showPlan
    for key, planInfo in pairs(planB) do
        if self:canShow(planInfo) then
            showPlan = planInfo
            break
        end
    end
    if not showPlan then
        print("获取B为空")
        callback(false)
        return
    end

    self:showDialog(showPlan,callback)
end

function OperationDialogManager:showDialogC(callback)
    -- local planC = self.plans.C
    -- local showPlan
    -- for key, planInfo in pairs(planC) do
    --     if self:canShow(planInfo) then
    --         showPlan = planInfo
    --         break
    --     end
    -- end

    -- self:showDialog(showPlan,callback)
end


return OperationDialogManager