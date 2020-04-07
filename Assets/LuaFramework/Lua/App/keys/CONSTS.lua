CONSTS = CONSTS or {}

--[[
    斗地主
]]
CONSTS.LANDLORDS = {
    TABLE_STATE = {
        STOPED	= 1,	-- 桌子上有人，但人数不够开局（比如说一个人）
        WAITING	= 2,	-- 等待游戏开始状态
        CALL	= 3,	-- 叫地主
        PLAY	= 5,	-- 玩牌
        RESTART	= 6,	-- 重新发牌
        SETTLE	= 7,	-- Server结算状态
    },
    USER_STATE =
    {
        READY     = 0, -- 准备, 等待状态
        CALL      = 1, -- 叫地主
        GRAB      = 2, -- 抢地主
        PLAY      = 3, -- 玩牌
        CHOICING  = 6, -- 正在选择
        WAITOTHER = 7, -- 等待其它人选择
        IDLE      = 8, -- 未准备
    },
    ACTION_TYPE = {
        CALL    = 1, -- 叫地主
        GRAB    = 2, -- 抢地主
        OUTCARD = 3, -- 出牌
        FOLLOW  = 4, -- 跟牌 （可以跟牌
        PASS    = 5, -- 过  （没牌出
        AI      = 6, -- 托管
    },
}

CONSTS.DOUNIU = {
    TABLE_STATE = {
        STOPED  = 1,   -- 桌子上有人，但人数不够开局（比如说一个人）
        WAITING = 2,   -- 等待游戏开始状态
        CALL    = 3,   -- 抢庄      
        BET     = 4,   -- 下注
        CONFIRM = 5,   -- 确认牌型，比牌
        SETTLE  = 6,   -- 结算状态
        CLOSING = 7,   -- 即将关闭（前端显示比牌）状态，结算完前端正在跑结算动画
    },
    USER_STATE =
    {
        READY     = 0,  --等待状态
        CALL      = 1,  --下注状态
        BET       = 2,  --已下注
        CONFIRM   = 3,  --已确认牌型
        CHOICING  = 4,  --正在选择
        WAITOTHER = 5,  --等待其它人选择
        STAND     = 6,  --站立围观状态
        GAMEOVER  = 7,  --已结算
    },
    ACTION_TYPE = {
        CALL    = 1, -- 叫地主
        BET     = 2, -- 抢地主
        CONFIRM = 3, -- 出牌
    },
}

CONSTS.FISHING = {
    TABLE_STATE = {
        STOPED  = 1,   -- 桌子上有人，但人数不够开局（比如说一个人）
        WAITING = 2,   -- 等待游戏开始状态
        CLOSING = 3,   -- 即将关闭（前端显示比牌）状态，结算完前端正在跑结算动画
    },
    USER_STATE =
    {
        READY     = 0,  --等待状态
        STAND     = 1,  --站立围观状态
        SPINT     = 2,  --急速状态
    },
    ACTION_TYPE = {
        CANNON = 1,
        PROPS  = 2,
        LOCK   = 3,
        SPRINT = 4,
        MUL    = 5,
    },
}

--[[
    支付场景  
]]
CONSTS.PAY_SCENE_TYPE = {}
local types = CONSTS.PAY_SCENE_TYPE

-- 场次无关的位置
types.HALL_SHOP             = 1001
types.HALL_BANKRUPT         = 1002
types.HALL_QUICK_BANKRUPT   = 1003
types.CHOOSE_SHOP           = 1004
types.CHOOSE_QUCIK_BANKRUPT = 1005
types.SELF_INFO_SHOP        = 1006
types.FIRST_PAY             = 1007
types.LIMIT_PAY             = 1008

-- 场次相关的位置 + level
types.ROOM_BANKRUPT_LEVEL     = 2000
types.CHOOSE_LACK_LEVEL       = 3000
types.ROOM_SHOP_LEVEL         = 4000
types.CHOOSE_BANKRUPT_LEVEL   = 5000
types.SIT_DOWN_LACK_SHOP      = 6000
types.SIT_DOWN_BANKRUPT_LEVEL = 7000
types.FIRST_PAY_LEVEL         = 8000
types.QUICK_PAY_LEVEL         = 9000

-- 支付Position
types.MAINHALL     = 1001
types.CAISHEN      = 4400
types.LOGINREWARD  = 1011
types.PLAYINFO     = 1006
types.VIP          = 1012
types.TASKJUMP     = 1013
types.LANDLORDROOM = 4300
types.SLOTROOM     = 4351
types.DOUNIUROOM   = 4410
types.NIUNIUROOM   = 4400
types.FISHINGROOM  = 4421

--[[
    房间类型
]]

CONSTS.ROOM_TYPE = {
    NORMAL    = 1,
    SLOTS     = 2,
    NIUNIU    = 3,
    LANDLORDS = 4,
    DOUNIU    = 5,
    FISHING   = 6,
}

--[[
    游戏ID
]]

CONSTS.GAME_ID = {
    NINEK     = 1,
    POKENG    = 2,
    SLOTS     = 3,
    LANDLORDS = 4,
    NIUNIU    = 5,
    DOUNIU    = 6,
    FISHING   = 7,
}

--[[
    踢人错误代码 以及原因
]]

CONSTS.KICK_REASON = {
    NORMAL      = 100,  -- 正常踢人
    OTHER_LOGIN = 101,  -- 别的地方登陆
}

--[[
    道具配置
]]
CONSTS.PROPS = {
    NONE                 = 0,
    GOLD                 = 1,
    DECORATE             = 2,
    JEWEL_REDPACKET      = 3,
    FRUIT_FREE_CARD      = 4,
    TRUMPET              = 5,
    CARD_RECORD          = 6,
    BIG_PACKET           = 7,
    DIAMOND              = 8,
    FISHING_SKILL_SPRINT = 9,
    FISHING_SKILL_FROZE  = 10,
    FISHING_SKILL_AIM    = 11,
    NUCLEAR_1            = 12,
    NUCLEAR_2            = 13,
    NUCLEAR_3            = 14,
    NUCLEAR_4            = 15,
}

return CONSTS