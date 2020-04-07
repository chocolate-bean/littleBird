local PROTOCOL = import("Server.SERVER_PROTOCOL")
local PacketParser = class("PacketBuilder")

PacketParser.HEAD_LEN = 16

function PacketParser:ctor(receiveValue)
    self.receiveValue = receiveValue
end

function PacketParser:hackReceiveWithSeatId(cmd, ret)
    local config = PROTOCOL.CONFIG.PROTOBUF[cmd]
    if not config then
        return
    end
    local findConfig = {
        {message = "SendTableInfo",         key = {"playerList", "seatId"}},
        {message = "SrvBroadcastGameOver",  key = {"playerList", "seatId"}},
        {message = "SrvBroadcastGameOver",  key = {"bonusList", "antes", "seatId"}},
        {message = "SrvSendGameStart",      key = {"anteList", "seatId"}},
        {message = "SrvBroadcastThirdCard", key = {"seatList", "seatId"}},
        {message = "SrvBroadcastUserCard",  key = {"userCards", "seatId"}},
        
        {message = "SendTableInfo", key = {"table", "bankSeatid"}, notTable = true},
        {message = "SendTableInfo", key = {"table", "curSeatid"}, notTable = true},
        
        {message = "UserSendPropResp",       key = "seatId"},
        {message = "SrvBroadcastSitDown",    key = "seatId"},
        {message = "SrvBroadcastStandUp",    key = "seatId"},
        {message = "SrvSendNextOperate",     key = "seatId"},
        {message = "SrvBroadcastOperate",    key = "seatId"},
        {message = "SrvBroadcastDropCards",  key = "seatId"},
        {message = "SrvBroadcastSlotResult", key = "seatId"},
        {message = "SrvBroadcastBoardCards", key = "seatId"},
        {message = "SrvBroadcastUserReady",  key = "seatId"},
        {message = "BankerInfo",             key = "seatId"},
        {message = "SrvSendGameStart",       key = "bankSeatid"},
        {message = "SrvBroadcastBetOn",      key = "slot"},
        {message = "ShotFishMsg",            key = "seatId"},
        {message = "UserShooting",           key = "seatId"},
    }
    for i,v in ipairs(findConfig) do
        if config.response == v.message then
            if type(v.key) == "string" then
                ret[v.key] = ret[v.key] + 1
            elseif type(v.key) == "table" then
                if v.notTable then
                    ret[v.key[1]][v.key[2]] = ret[v.key[1]][v.key[2]] + 1
                else
                    if type(ret) == "boolean" then
                        print("-----------------"..v.message.."___"..v.key[1])
                    end
                    for _, v1 in ipairs(ret[v.key[1]]) do
                        if #v.key > 2 then
                            for _, v2 in ipairs(v1[v.key[2]]) do
                                v2[v.key[3]] = v2[v.key[3]] + 1
                            end
                        else
                            v1[v.key[2]] = v1[v.key[2]] + 1
                        end
                    end
                end
            end
        end
    end
end

function PacketParser:read()
    local array = self.receiveValue
    local gid = -1
    local cmd = -1
    local len = -1
    local pos = array.Position
    local len = array.Length
    array:SetPosition(4)
    local byteT = array:ReadByte()
    local byteP = array:ReadByte()
    if string.char(byteT) == "T" and string.char(byteP) == "P" then
        array:SetPosition(7)
        gid = array:ReadShort()
        cmd = array:ReadInt()
        len = len - PacketParser.HEAD_LEN
        array:SetPosition(PacketParser.HEAD_LEN)
        local ret = nil
        if len >= 4 then
            local protobufLen = array:ReadInt()
            -- 这里减一是因为有个结束符
            local data = array:ReadBuffer(protobufLen - 1)
            local config = PROTOCOL.CONFIG.PROTOBUF[cmd]
            if config then
                local messageName = config.protobufName..config.response
                ret = protobuf.decodeAll(messageName, array:checkLua(data))
                self:hackReceiveWithSeatId(cmd, ret)
            else
                print("没有这个cmd"..cmd)
            end
            if not (cmd == 0x0216 or cmd == 0x0116 or cmd == 0x0117 or cmd == 0x0206 or cmd == 0x0107) then
                print(string.format("%#x %s %s", cmd, PROTOCOL.NAME[cmd], json.encode(ret)))
            end
        end

        if cmd == PROTOCOL.SVR_KICK_OUT and ret.reason and ret.reason == CONSTS.KICK_REASON.OTHER_LOGIN then
            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                hasFristButton = true,
                hasSecondButton = false,
                hasCloseButton = false,
                title = T("提示"),
                text = T("你的账号已在其他设备登陆"),
                firstButtonCallbcak = function()
                    GameManager.GameFunctions.logout()
                    GameManager:enterScene("LoginScene",0)
                end,
            })

            return nil,nil
        else
            return cmd, ret
        end
    else
        return nil,nil
    end
end

return PacketParser