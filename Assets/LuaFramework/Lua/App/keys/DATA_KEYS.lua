--
-- Author: Johnny Lee
-- Date: 2014-07-08 18:15:05
--

local DATA_KEYS = {}

DATA_KEYS.MUSIC                 = "MUSIC" --0是打开 --1是关闭
DATA_KEYS.SOUND                 = "SOUND"
DATA_KEYS.IS_3D                 = "IS_3D"
DATA_KEYS.USER_DATA             = "USER_DATA"
DATA_KEYS.IMEI                  = "IMEI"
DATA_KEYS.UUID                  = "UUID"
DATA_KEYS.STORE_ID              = "STORE_ID"
DATA_KEYS.IDFA                  = "IDFA"
DATA_KEYS.SID                   = "SID"
DATA_KEYS.OAID                  = "OAID"
DATA_KEYS.LOGIN_MODEL           = "LOGIN_MODEL"
DATA_KEYS.LAST_LOGIN_TYPE       = "LAST_LOGIN_TYPE"
DATA_KEYS.WX_ACCESS_TOKEN       = "WX_ACCESS_TOKEN"
DATA_KEYS.PHONE                 = "PHONE"
DATA_KEYS.PASSWORD              = "PSAAWORD"
DATA_KEYS.OPPO_TOKEN            = "OPPO_TOKEN"
DATA_KEYS.OPPO_SSOID            = "OPPO_SSOID"
DATA_KEYS.PAYMENT               = "payment"
DATA_KEYS.ROOM_CONFIG           = "roomConfig"     -- 场次配置
DATA_KEYS.ROOM_VERSION          = "roomVersion"    -- 场次版本
DATA_KEYS.ROOM_SWITCH           = "switch"      -- 场次选择 0 全显示 1 不显示九人 2 不显示五人 3 全不显示
DATA_KEYS.PRE_PLAY_DATA         = "prePlayData"    -- 上一次玩的数据 玩法 初中高 几人 {playType, playLevel, playerCount}

DATA_KEYS.LANDLORDS_ROOM_CONFIG  = "landlords_room_config"     -- 场次配置
DATA_KEYS.LANDLORDS_ROOM_VERSION = "landlords_room_version"    -- 场次版本

DATA_KEYS.HAPPY_ROOM_CONFIG = "happy_room_config"   -- 娱乐场场次配置
DATA_KEYS.HAPPY_ROOM_VERSION = "happy_room_version"  -- 娱乐场场次版本

DATA_KEYS.FISH_ROOM_CONFIG = "fish_room_config"   -- 捕鱼场场次配置
DATA_KEYS.FISH_MONEY_ROOM_CONFIG = "fish_money_room_config"   -- 捕鱼场场次配置
DATA_KEYS.FISH_ROOM_VERSION = "fish_room_version"  -- 捕鱼场场次版本
DATA_KEYS.FISH_QUALITY = "fish_quality"  -- 捕鱼画质

DATA_KEYS.CHOOSEROOM_TYPE = "landlords_type" -- 斗地主进入方式

DATA_KEYS.LUCKY_WHEEL_CONFIG   = "lucky_wheel_config"      -- 场次配置
DATA_KEYS.LUCKY_WHEEL_VERSION  = "lucky_wheel_version"     -- 场次配置

DATA_KEYS.FISHING_CANNON_LEVEL = "fishing_cannon_level"
DATA_KEYS.FISHING_FIRST_PLAY = "fishing_first_play"

DATA_KEYS.HAS_AUTOSHOT = "has_autoshot"
DATA_KEYS.FIRST_LOGIN = "first_login"
DATA_KEYS.HAS_AUTOSHOT_TOTALTIME = "has_autoshot_totaltime"
DATA_KEYS.HAS_AUTOSHOT_CURTIME = "has_autoshot_curtime"

return DATA_KEYS
