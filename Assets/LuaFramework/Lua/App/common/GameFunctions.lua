local GameFunctions = {}

function GameFunctions.getUserInfo(default)
    local userInfo = nil
    if default ~= true then
        userInfo = {
            mavatar     = GameManager.UserData.micon,
            name        = GameManager.UserData.name,
            mlevel      = GameManager.UserData.mlevel,
            mlose       = GameManager.UserData.lose,
            mwin        = GameManager.UserData.win,
            money       = GameManager.UserData.money,
            msex        = GameManager.UserData.msex,
            mexp        = GameManager.UserData.exp,
            viplevel    = GameManager.UserData.viplevel,
            uid         = GameManager.UserData.mid,
            sitemid     = 0,
            giftId      = GameManager.UserData.attire,
            diamond     = GameManager.UserData.diamond,
            jewel       = GameManager.UserData.jewel,
            sid         = IdentityManager.Sid,
            cannonStyle = GameManager.UserData.cannonStyle,
            lid         = 1,
        }
    else
        userInfo = {
            mavatar     = "",
            name        = T("游戏玩家"),
            mlevel      = 3,
            mlose       = 0,
            mwin        = 0,
            money       = 10000,
            msex        = 1,
            mexp        = 100,
            viplevel    = 0,
            sitemid     = 0,
            giftId      = 0,
            diamond     = 0,
            jewel       = 0,
            uid         = 0,
            sid         = IdentityManager.Sid,
            cannonStyle = 1,
            lid         = 1,
        }
    end
    return userInfo 
end

function GameFunctions.getGameIdFormTableId(tableId)
    local lowValue = bit.band(bit.tobit(tableId), 0xFF00)
    local gameId = bit.rshift(lowValue, 8)
    return gameId
end

function GameFunctions.setJewel(jewel)
    local lastJewel = GameManager.UserData.jewel
    local add = jewel - lastJewel
    if add > 0 then
        GameManager.UserData.jewelGain = GameManager.UserData.jewelGain + add
    end
    GameManager.UserData.jewel = jewel
end

function GameFunctions.getJewel(jewel)
    if jewel == nil then
        jewel = GameManager.UserData.jewel
    end
    -- 取余之后是否为0
    if jewel % 100 == 0 then
        return string.format("%.0f", jewel / 100)
    else
        return string.format("%.1f", jewel / 100)
    end
end

function GameFunctions.getJewelWithUnit(jewel)
    return string.format(T("%s元"), GameFunctions.getJewel(jewel))
end


function GameFunctions.logout()
    UnityEngine.PlayerPrefs.SetString(DataKeys.LAST_LOGIN_TYPE,"LOGINOUT")
    GameManager.ServerManager:heartBeatStop()
    GameManager.ServerManager:brokenConnect()
end

function GameFunctions.refashRedDotData(callData)
    
    local friendRedotConfig = {}
    for i,v in ipairs(callData.friend.index) do
        friendRedotConfig[tonumber(v)] = v
    end
    callData.friend.index = friendRedotConfig
                
    local taskRedotConfig = {}
    for i,v in ipairs(callData.task.index) do
        taskRedotConfig[tonumber(v)] = v
    end
    callData.task.index = taskRedotConfig

    local activityRedotConfig = {}
    for i,v in ipairs(callData.activity.index) do
        activityRedotConfig[tonumber(v)] = v
    end
    callData.activity.index = activityRedotConfig

    GameManager.UserData.redDotData = callData
end

function GameFunctions.removeRedDot(type, index)
    http.removeRedDot(
        type,
        index,
        function (callData)
            
        end,
        function (callData)
            
        end
    )
end

return GameFunctions
