
local P = {}
local SERVER_PROTOCOL = P
P.CONFIG          = {}
P.CONFIG.PROTOBUF = {}

local B      = P.CONFIG.PROTOBUF

-- P = {
--     CLISVR_HEART_BEAT = 0XFFFF,
--     CONFIG = {
--         PROTOBUF = {
--             [0xFFFF] = {
--                 protobufName = "nkclient.",
--             },
--         }
--     },
--     NAME = {
--         [0xFFFF] = "心跳包",
--     }
-- }

----------------------------------------------------------------
------------------------- 客户端请求 Request -------------------
----------------------------------------------------------------


local PROTOBUF_NAME = "nkclient."
--------------------- Hall Command Start
P.CLISVR_HEART_BEAT          = 0xFFFF    --心跳包
P.CLI_LOGIN                  = 0X1002    --登录大厅
P.CLI_GET_ROOM               = 0x1003    --请求桌子
P.CLI_CHANGE_ROOM            = 0x1004    --请求换桌
P.TRACE_FRIEND               = 0x1005    --跟踪好友
P.CLI_REQUEST_COUNT_OF_TABLE = 0x1006    --请求场次人数
P.SVR_COMMON_BROADCAST       = 0x1101    --跑马灯


B[P.CLISVR_HEART_BEAT] = {
    protobufName = PROTOBUF_NAME,
}    


B[P.CLI_LOGIN] = {
    protobufName = PROTOBUF_NAME,
    request      = "LoginHallReq",
    response     = "LoginHallResp",
} 


B[P.CLI_GET_ROOM] = {
    protobufName = PROTOBUF_NAME,
    request      = "AllocTableReq",
    response     = "AllocTableResp",
}


B[P.CLI_CHANGE_ROOM] = {
    protobufName = PROTOBUF_NAME,
    request      = "AllocTableReq",
    response     = "AllocTableResp",
}


B[P.TRACE_FRIEND] = {
    protobufName = PROTOBUF_NAME,
    request      = "TraceFriendReq",
    response     = "TraceFriendResp",
}


B[P.CLI_REQUEST_COUNT_OF_TABLE] = {
    protobufName = PROTOBUF_NAME,
    response     = "GetUserCountResp",
}


B[P.SVR_COMMON_BROADCAST] = {
    protobufName = PROTOBUF_NAME,
    response     = "BroadcastMsg",
}
--------------------- Hall Command End

--------------------- Game Command Start 
P.CLI_LOGIN_ROOM          = 0x0101    --登陆房间
P.CLI_SIT_DOWN            = 0x0102    --请求坐下
P.CLI_STAND_UP            = 0x0103    --请求站起
P.CLI_SEND_TIP_TO_GIRL    = 0x0104    --请求打赏
P.CLI_SEND_ROOM_COST_PROP = 0x0105    --互动道具
P.CLI_USER_IN_BACKGROUND  = 0x0106    --进入后台
P.CLI_SET_BET             = 0x0107    --请求操作
P.CLI_LOGOUT_ROOM         = 0x0108    --请求离开
P.CLI_SEND_ROOM_MSG       = 0x0109    --玩家互动
P.CLI_TABLE_SYNC          = 0x010A    --同步桌子
P.CLI_DROP_CARDS          = 0x010B    --玩家弃牌（目前：四张牌玩法才用得到
P.CLI_SLOT_BET            = 0x010E    --水果机下注
P.CLI_SEND_USER_READY     = 0x010F    --玩家准备
P.CLI_SEND_GET_VIPSEAT    = 0x0110    --牛牛请求vip座位
P.CLI_SEND_GET_USERLIST   = 0x0111    --牛牛请求玩家列表
P.CLI_SEND_GET_SLOTLIST   = 0x0112    --牛牛请求注池信息
P.CLI_SEND_REQ_HINT       = 0x0113    --牛牛请求注池信息
P.CLI_SEND_APPLY_BANKER   = 0x0114    --牛牛请求上庄
P.CLI_SEND_GET_BANKERLIST = 0x0115    --牛牛请求上庄列表
P.CLI_SEND_FISHING_MSG    = 0x0116    --捕鱼消息
P.CLI_SEND_SHOOTING       = 0x0117    --射击

P.SVR_SIT_DOWN            = 0x0201    --广播坐下
P.SVR_GAME_START          = 0x0202    --广播开始
P.SVR_OTHER_STAND_UP      = 0x0203    --广播站起
P.SVN_AUTO_ADD_MIN_CHIPS  = 0x0204    --自动买入通知
P.SVR_NEXT_BET            = 0x0205    --通知下一玩家操作
P.SVR_BET                 = 0x0206    --广播玩家操作
P.SVR_RECEIVE_FOURTH_CARD = 0x0207    --服务器下轮发牌
P.SVR_GAME_OVER           = 0x0208    --牌局结束
P.SVR_BROADCAST_RESULT    = 0x0209    --广播游戏结果
P.SVR_KICK_OUT            = 0x020A    --玩家被踢
P.SVR_DROP_CARDS          = 0x020B    --广播弃牌（目前：四张牌玩法才用得到
P.SVR_FLIP_CARDS          = 0x020C    --广播翻地主牌
P.SVR_BC_GET_CARD         = 0x020D    --广播要牌（博定玩法
P.SVR_SEND_SHOW_CARD      = 0x020E    --广播亮牌 (DOUNIU
P.SVR_BC_USER_READY       = 0x0210    --广播玩家准备
P.SVR_BC_USER_BETON       = 0x0211    --广播下注（NIUNIU
P.SVR_BC_NIUNIU_RESULT    = 0x0212    --广播结算（NIUNIU
P.SVR_BC_VIPSEAT_INFO     = 0x0213    --广播公共座位信息（NIUNIU
P.SVR_BC_BANKER_INFO      = 0x0214    --广播庄家信息 (DOUNIU
P.SVR_BC_START_BET        = 0x0215    --广播开始下注 (DOUNIU
P.SVR_BC_CREATE_FISH      = 0x0216    --广播生成鱼

B[P.CLI_LOGIN_ROOM] = {
    protobufName = PROTOBUF_NAME,
    request      = "LoginGameReq",
    response     = "SendTableInfo",
}

B[P.CLI_SIT_DOWN] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserSitDownReq",
    response     = "UserSitDownResp",
}

B[P.SVR_SIT_DOWN] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastSitDown",
}

B[P.SVR_GAME_START] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvSendGameStart",
}

B[P.CLI_STAND_UP] = {
    protobufName = PROTOBUF_NAME,
    response     = "UserStandUpResp",
}

B[P.SVR_OTHER_STAND_UP] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastStandUp",
}

B[P.CLI_SEND_TIP_TO_GIRL] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserSendTipsReq",
    response     = "UserSendTipsResp",
}

B[P.CLI_SEND_ROOM_COST_PROP] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserSendPropReq",
    response     = "UserSendPropResp",
}

B[P.CLI_USER_IN_BACKGROUND] = {
    protobufName = PROTOBUF_NAME,
}

B[P.CLI_TABLE_SYNC] = {
    protobufName = PROTOBUF_NAME,
    response     = "SendTableInfo",
}

B[P.CLI_SEND_USER_READY] =  {
    protobufName = PROTOBUF_NAME,
}

B[P.SVN_AUTO_ADD_MIN_CHIPS] = {
    protobufName = PROTOBUF_NAME,
    response     = "AutoBuyinResp",
}

B[P.SVR_NEXT_BET] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvSendNextOperate",
}

B[P.CLI_SET_BET] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserOperateReq",
    response     = "UserOperateResp",
}

B[P.SVR_BET] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastOperate",
}

B[P.SVR_RECEIVE_FOURTH_CARD] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastThirdCard",
}

B[P.SVR_GAME_OVER] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastGameOver",
}

B[P.CLI_LOGOUT_ROOM] = {
    protobufName = PROTOBUF_NAME,
    response     = "UserLogoutResp",
}

B[P.CLI_SEND_ROOM_MSG] = {
    protobufName = PROTOBUF_NAME,
    request      = "BroadcastMsg",
    response     = "BroadcastMsg",
}

B[P.SVR_KICK_OUT] = {
    protobufName = PROTOBUF_NAME,
    response     = "KickOutUser",
}

B[P.CLI_DROP_CARDS] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserDropCards",
}

B[P.SVR_DROP_CARDS] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastDropCards",
}

B[P.SVR_FLIP_CARDS] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastBoardCards",
}

B[P.SVR_BC_GET_CARD] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastUserCard",
}

B[P.SVR_SEND_SHOW_CARD] = {
    protobufName = PROTOBUF_NAME,
    response     = "ShowCards",
}

B[P.SVR_BC_USER_BETON] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastBetOn",
}

B[P.SVR_BC_NIUNIU_RESULT] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastNiuniuResult",
}

B[P.SVR_BC_VIPSEAT_INFO] = {
    protobufName = PROTOBUF_NAME,
    response     = "SendTableInfo",
}

B[P.CLI_SLOT_BET] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserSlotBetReq",
    response     = "UserSlotBetResp",
}

B[P.CLI_SEND_GET_VIPSEAT] = {
    protobufName = PROTOBUF_NAME,
    response     = "UserOperateResp",
}

B[P.CLI_SEND_GET_USERLIST] = {
    protobufName = PROTOBUF_NAME,
    response     = "SendTableInfo",
}

B[P.CLI_SEND_GET_SLOTLIST] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastBetOn",
}

B[P.CLI_SEND_APPLY_BANKER] = {
    protobufName = PROTOBUF_NAME,
    response     = "UserOperateResp",
}

B[P.CLI_SEND_GET_BANKERLIST] = {
    protobufName = PROTOBUF_NAME,
    response     = "SendTableInfo",
}

B[P.SVR_BROADCAST_RESULT] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastSlotResult",
}

B[P.CLI_SEND_REQ_HINT] = {
    protobufName = PROTOBUF_NAME,
    response     = "UserCardList",
}

B[P.SVR_BC_USER_READY] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvBroadcastUserReady",
}

B[P.SVR_BC_BANKER_INFO] = {
    protobufName = PROTOBUF_NAME,
    response     = "BankerInfo",
}

B[P.SVR_BC_START_BET] = {
    protobufName = PROTOBUF_NAME,
    response     = "SrvSendNextOperate",
}

B[P.SVR_BC_CREATE_FISH] = {
    protobufName = PROTOBUF_NAME,
    response     = "CreateFish",
}

B[P.CLI_SEND_SHOOTING] = {
    protobufName = PROTOBUF_NAME,
    request      = "UserShooting",
    response     = "UserShooting",
}

B[P.CLI_SEND_FISHING_MSG] = {
    protobufName = PROTOBUF_NAME,
    request      = "ShotFishMsg",
    response     = "ShotFishMsg",
}

--------------------- Game Command End


--------------------- Command Name Start

P.NAME = {
    [P.CLISVR_HEART_BEAT]          = "心跳包",
    [P.CLI_LOGIN]                  = "登录大厅",
    [P.CLI_GET_ROOM]               = "请求桌子",
    [P.CLI_CHANGE_ROOM]            = "请求换桌",
    [P.TRACE_FRIEND]               = "跟踪好友",
    [P.CLI_REQUEST_COUNT_OF_TABLE] = "请求场次人数",
    [P.SVR_COMMON_BROADCAST]       = "跑马灯",
    [P.CLI_LOGIN_ROOM]             = "登陆房间",
    [P.CLI_SIT_DOWN]               = "请求坐下",
    [P.CLI_STAND_UP]               = "请求站起",
    [P.CLI_SEND_TIP_TO_GIRL]       = "请求打赏",
    [P.CLI_SEND_ROOM_COST_PROP]    = "互动道具",
    [P.CLI_USER_IN_BACKGROUND]     = "进入后台",
    [P.CLI_SET_BET]                = "请求操作",
    [P.CLI_LOGOUT_ROOM]            = "请求离开",
    [P.CLI_SEND_ROOM_MSG]          = "玩家互动",
    [P.CLI_TABLE_SYNC]             = "同步桌子",
    [P.CLI_DROP_CARDS]             = "玩家弃牌（目前：四张牌玩法才用得到",
    [P.CLI_SLOT_BET]               = "水果机下注",
    [P.CLI_SEND_USER_READY]        = "玩家准备",
    [P.CLI_SEND_GET_VIPSEAT]       = "牛牛请求vip座位",
    [P.CLI_SEND_GET_USERLIST]      = "牛牛请求玩家列表",
    [P.CLI_SEND_GET_SLOTLIST]      = "牛牛请求注池信息",
    [P.CLI_SEND_REQ_HINT]          = "牛牛请求注池信息",
    [P.CLI_SEND_APPLY_BANKER]      = "牛牛请求上庄",
    [P.CLI_SEND_GET_BANKERLIST]    = "牛牛请求庄家列表",
    [P.CLI_SEND_FISHING_MSG]       = "捕鱼消息",
    [P.SVR_SIT_DOWN]               = "广播坐下",
    [P.SVR_GAME_START]             = "广播开始",
    [P.SVR_OTHER_STAND_UP]         = "广播站起",
    [P.SVN_AUTO_ADD_MIN_CHIPS]     = "自动买入通知",
    [P.SVR_NEXT_BET]               = "通知下一玩家操作",
    [P.SVR_BET]                    = "广播玩家操作",
    [P.SVR_RECEIVE_FOURTH_CARD]    = "服务器下轮发牌",
    [P.SVR_GAME_OVER]              = "牌局结束",
    [P.SVR_BROADCAST_RESULT]       = "广播游戏结果",
    [P.SVR_KICK_OUT]               = "玩家被踢",
    [P.SVR_DROP_CARDS]             = "广播弃牌（目前：四张牌玩法才用得到",
    [P.SVR_FLIP_CARDS]             = "广播翻地主牌",
    [P.SVR_BC_GET_CARD]            = "广播要牌（博定玩法",
    [P.SVR_SEND_SHOW_CARD]         = "广播亮牌 (DOUNIU",
    [P.SVR_BC_USER_READY]          = "广播玩家准备",
    [P.SVR_BC_USER_BETON]          = "广播下注（NIUNIU",
    [P.SVR_BC_NIUNIU_RESULT]       = "广播结算（NIUNIU",
    [P.SVR_BC_VIPSEAT_INFO]        = "广播公共座位信息（NIUNIU",
    [P.SVR_BC_BANKER_INFO]         = "广播庄家信息 (DOUNIU",
    [P.SVR_BC_START_BET]           = "广播开始下注 (DOUNIU",
    [P.SVR_BC_CREATE_FISH]         = "广播生成鱼",
    [P.CLI_SEND_SHOOTING]          = "广播射击鱼",
}

--------------------- Command Name End
return SERVER_PROTOCOL