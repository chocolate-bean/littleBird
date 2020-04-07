local RoomScene = class("RoomScene")

RoomScene.RoomConfig = {
    [CONSTS.ROOM_TYPE.SLOTS] = {
        scene           = "slots",
        name            = "SlotsPanel",
        prefab          = {"SlotsPanel", "columnScrollView", "slotsItem"},
        viewClass       = require("Slots.SlotsView"),
        controllerClass = require("Slots.SlotsController"),
    },
    [CONSTS.ROOM_TYPE.NIUNIU] = {
        scene           = "niuniu",
        name            = "NiuNiuPanel",
        prefab          = {"NiuNiuPanel", "PokerCard", "Chip", "SeatView"},
        viewClass       = require("Niuniu.NiuniuView"),
        controllerClass = require("Niuniu.NiuniuController"),
    },
    [CONSTS.ROOM_TYPE.LANDLORDS] = {
        scene           = "landlords",
        name            = "LandlordsPanel",
        prefab          = {"LandlordsPanel", "SelfCard", "LandlordsCard"},
        viewClass       = require("Room.Landlords.LandlordsView"),
        controllerClass = require("Room.Landlords.LandlordsController"),
    },
    [CONSTS.ROOM_TYPE.DOUNIU] = {
        scene           = "douniu",
        name            = "DouniuPanel",
        prefab          = {"DouniuPanel", "Chip" },
        viewClass       = require("Room.Douniu.DouniuView"),
        controllerClass = require("Room.Douniu.DouniuController"),
    },
    [CONSTS.ROOM_TYPE.FISHING] = {
        scene           = "fishing",
        name            = "FishingPanel",
        prefab          = {"FishingUIPanel", "PositionHint", "SeatCannonSprint"},
        viewClass       = require("Room.Fishing.FishingView"),
        controllerClass = require("Room.Fishing.FishingController"),
    },
}

function RoomScene:ctor(data)
    local config = RoomScene.RoomConfig[data.roomType]
    if config then
        self:showRoom(config, data.data)
    else
        print("没有对应的房间类型！")
    end
end

function RoomScene:showRoom(config, data)
    if config.scene == "fishing" then
        local sceneName
        local quality = UnityEngine.PlayerPrefs.GetInt(DataKeys.FISH_QUALITY)
        if quality == 1 then
            sceneName = "fishingLow"
        elseif quality == 2 then
            sceneName = "fishing"
        elseif quality == 3 then
            sceneName = "fishingHigh"
        else
            sceneName = "fishing"
        end
        SceneManager.LoadSceneAsync(sceneName)
    else
        SceneManager.LoadSceneAsync(config.scene)
    end
    self.config_ = config
    self.controller_ = config.controllerClass.new(self, data)
    self.prefabName_ = config.name
    resMgr:LoadPrefabByRes("Room", config.prefab, function(objs)
        self.view = config.viewClass.new(self.controller_, objs)
        self.controller_:prefabDidLoad()
    end)
end

function RoomScene:creatView()

end

function RoomScene:onCleanUp()
end

return RoomScene