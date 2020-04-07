local GameManager = class("GameManager")

function GameManager:ctor()
    
    CONSTS     = require("App/keys/CONSTS")
    EventNames = require("App/keys/EVENT_NAMES")
    DataKeys   = require("App/keys/DATA_KEYS")

    crypto     = require("Core/crypto")
    Event      = require("Core/events")
    http       = require("Core/http")
    http.init()

    self.DataProxy          = require("Core/DataProxy").new()
    self.ImageLoader        = require("Core/ImageLoader").new()
    self.JsonFileLoader     = require("Core/JsonFileLoader").new()
    self.SoundManager       = require("Core/SoundManager").new()
    self.PanelManager       = require("Core/PanelManager").new()
    self.LoadingManager     = require("Core/LoadingManager").new()
    self.ActivityJumpConfig = require("Core/ActivityJumpConfig").new()
    self.TopTipManager      = require("Hall/TipManager").new()
    self.AnimationManager   = require("Core/AnimationManager").new()
    self.ServerManager      = require("Server/ServerManager").new()
    self.ChooseRoomManager  = require("ChooseRoom/ChooseRoomManager").new()
    self.ODialogManager     = require("Room/OperationDialogManager").new()
    self.GameFunctions      = require("App/common/GameFunctions")

    self.runningScene        = nil
    self.sceneName           = nil

    self:enterScene("LoginScene",0)
end

function GameManager:creatScene(sceneName, data)
    if sceneName ~= self.currentSceneName then
        self.sourceSceneName = self.currentSceneName
    end

    if sceneName == "HallScene" then
        local HallScene = require("Hall/HallScene").new(data)
        self.runningScene = HallScene
        self.runningScene.name = "HallScene"
    elseif sceneName == "RoomScene" then
        local RoomScene = require("Room/RoomScene").new(data)
        self.runningScene = RoomScene
        self.runningScene.name = "RoomScene"
    elseif sceneName == "LoginScene" then
        local LoginScene = require("Hall/LoginScene").new(data)
        self.runningScene = LoginScene
        self.runningScene.name = "LoginScene"
    end
    self.currentSceneName = sceneName 
end

function GameManager:enterScene(sceneName, data)
    if self.runningScene and self.runningScene.controller_.exitSceneAnimation then
        self.SoundManager:StopBGM()
        self.SoundManager:PlaySound("replaceScene")
        self.runningScene.controller_:exitSceneAnimation(function()
            self:creatScene(sceneName, data)
        end)
    else      
        -- self.SoundManager:StopBGM()
        -- self.SoundManager:PlaySound("replaceScene")      
        if self.runningScene and self.runningScene.controller_.onCleanUp then
            self.runningScene.controller_:onCleanUp()
        end
        self:creatScene(sceneName, data)
    end
end

function GameManager:onReturnKeyClick()
    if self.runningScene.controller_ and self.runningScene.controller_.onReturnKeyClick then
        self.runningScene.controller_:onReturnKeyClick()
    end
end

function GameManager:exitGame()
    if isOPPO() then
        sdkMgr:OPPOExit(function(resultString)
            if resultString == "success" then
                UnityEngine.Application.Quit()
            end
        end)
    elseif isVIVO() then
        sdkMgr:VIVOExit(function(resultString)
            if resultString == "success" then
                UnityEngine.Application.Quit()
            end
        end)
    else
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("确认退出"),
            text = T("真的确认退出游戏吗？\n淫家好舍不得滴啦~\\(≧▽≦)/~"),
            firstButtonCallbcak = function()
                UnityEngine.Application.Quit()
            end,
        })
    end
end

function GameManager:playSound(type, param)
    if self.runningScene.controller_ and self.runningScene.controller_.playSound then
        self.runningScene.controller_:playSound(type, param)
    end
end

function GameManager:onApplicationFocus(focus)
    if self.runningScene.controller_ and self.runningScene.controller_.onApplicationFocus then
        self.runningScene.controller_:onApplicationFocus(focus)
    end
end

return GameManager