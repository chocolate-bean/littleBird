local PROTOCOL = import("Server.SERVER_PROTOCOL")
local PacketBuilder = class("PacketBuilder")

function PacketBuilder:ctor(cmd)
    self.builder = {}
    self.builder.params = {}
    self.builder.cmd    = cmd
end

function PacketBuilder:setParameter(key, value)
    if not self.builder or not self.builder.params then
        return nil
    else
        self.builder.params[key] = value
    end
    return self
end

function PacketBuilder:hackBuildWithSeatId()
    if self.builder and self.builder.params then
        local keys = {"seatId"}
        for k,v in pairs(keys) do
            if self.builder.params[v] then
                self.builder.params[v] = self.builder.params[v] - 1
            end
        end
    end
end

function PacketBuilder:build()
    if not self.builder then
        return nil
    else
        local array = ByteArray.New()
        local config = PROTOCOL.CONFIG.PROTOBUF[self.builder.cmd]
        local message = nil
        if config.protobufName and config.request then
            self:hackBuildWithSeatId()
            message = protobuf.encode(config.protobufName..config.request, self.builder.params)
        end
        -- print("包体大小："..size)
        --  4   	包大小+后接字节 12
        array:WriteInt(0)
        --  2   	字符串： TP
        array:WriteByte(string.byte('T'))
        array:WriteByte(string.byte('P'))
        --  1   	协议包版本
        array:WriteByte(1)
        --  2   	游戏ID
        array:WriteShort(0)
        --  4   	命令字
        array:WriteInt(self.builder.cmd)
        --  2   	子命令字
        array:WriteShort(self.builder.subcmd_ or 0)
        --  1   	加密解密部分由C#完成防止解包
        array:WriteByte(0)
        -- 16
        if message then
            array:WriteBuffer(message.."\0")
        end
        array:SetPosition(0)
        local size = array.Length - 4
        array:WriteInt(size)
        return array
    end
end

return PacketBuilder