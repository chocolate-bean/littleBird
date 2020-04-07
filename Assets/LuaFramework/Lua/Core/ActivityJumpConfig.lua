--
-- Author: Your Name
-- Date: 2015-10-09 10:34:06
--

local ActivityJumpConfig = class("ActivityJumpConfig")

function ActivityJumpConfig:ctor()
end

function ActivityJumpConfig:Jump(jumpInfo)
    
    if not jumpInfo then
        return
    end

    -- 先留着这两个数据，以后会用到的
    local runningScene = GameManager.runningScene

    local getJumpSceneByTargetInst = {
        -- 快速开始-斗地主
        ["quick_play"] = function ()
            if runningScene.name == "HallScene" then
                GameManager.ChooseRoomManager:getLandlordsRoomList(function()
                    GameManager.ServerManager:getLandlordsRoomAndLogin()
                end)
            end
        end,
        ["go_fishing_money_room"] = function()
            if runningScene.name == "HallScene" then
                GameManager.ChooseRoomManager:getFishingMoneyRoomList(function()
                    local roomLists  = GameManager.ChooseRoomManager.fishingMoneyRoomConfig
                    dump(roomLists)
                    local roomConfig
                    for index, config in ipairs(roomLists) do
                        local minLimitMoney = tonumber(config.min_money)
                        local maxLimitMoney = tonumber(config.max_limit_money)
                        local currentMoney = GameManager.UserData.money
                        if currentMoney >= minLimitMoney then
                            if maxLimitMoney == 0 then
                                roomConfig = config
                            else
                                if currentMoney <= maxLimitMoney then
                                    roomConfig = config
                                end
                            end
                        end
                    end
                    if roomConfig ~= nil then
                        GameManager.ServerManager:getFishingRoomAndLogin(roomConfig.level)
                    else
                        GameManager.TopTipManager:showTopTip(T("请自行前往金币场选择场次！"))
                    end
                end)
            end
        end,
        -- 快速开始-捕鱼 红包场
        ["go_fishing_jewel_room"] = function()
            if runningScene.name == "HallScene" then
                GameManager.ChooseRoomManager:getFishRoomList(function()
                    GameManager.ServerManager:getFishingRoomAndLogin()
                end)
            end
        end,
        -- 快速开始-百人场
        ["go_ten"] = function ()
            if runningScene.name == "HallScene" then
                GameManager.ChooseRoomManager:getNiuniuConfig(function()
                    GameManager.ServerManager:getNiuniuRoomAndLogin()
                end)
            end
        end,
        -- 快速开始-水果机
        ["go_slot"] = function ()
            if runningScene.name == "HallScene" then
                GameManager.ChooseRoomManager:getSlotsConfig(function()
                    GameManager.ServerManager:getSoltsRoomAndLogin()
                end)
            end
        end,
        -- 打开个人面板
        ["go_profile"] = function ()
            
            local PanelPlayInfoBig = import("Panel.PlayInfo.PanelPlayInfoBig").new()
        end,
        -- 财神系统
        ["go_wealth"] = function ()
            
            local PanelCaishen = import("Panel.Operation.PanelCaishen").new()
        end,
        -- 商城
        ["go_shop"] = function ()
            GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.TASKJUMP
            -- local PanelShop = import("Panel.Shop.PanelShop").new()
            -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
            local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
        end,
        -- 邀请好友上线
        ["friend_list"] = function ()
            
            local PanelFriend = import("Panel.Friend.PanelFriend").new()
        end,
        -- 登陆奖励 
        ["login_reward"] = function ()
            
            local PanelLoginReward = import("Panel.Operation.PanelLoginReward").new()
        end,
        -- 分享 
        ["go_share"] = function ()
            local PanelShareDialog = import("Panel.LuckyWheel.PanelShareDialog").new()
        end,
        -- 绑定手机号
        ["go_bind"] = function()
            
            local PanelPhone = import("Panel.Login.PanelPhone").new(5)
        end,
        -- 分享赚钱
        ["go_share_friend"] = function()
            local PanelInvite = import("Panel.Operation.PanelInvite").new()
        end
    }

    if getJumpSceneByTargetInst[jumpInfo] then
        getJumpSceneByTargetInst[jumpInfo]()
    else
        print("传的啥玩意")
    end
end

return ActivityJumpConfig
