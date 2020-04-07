local Card = class("Card")

Card.PATH = "Images/Card/"
Card.JokerIndex = 14

Card.SuitNameConfig = {
    [0] = T("方块"),
    [1] = T("梅花"),
    [2] = T("红桃"),
    [3] = T("黑桃"),
    [4] = T("王"),
}

Card.CountNameConfig = {
    -- "DW", "XW", "2", "A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3",
    "A","2","3","4","5","6","7","8","9","10","J","Q","K","XW","DW",
}

Card.AllCard = {
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,        --方块 A - K   1 - 13
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,        --梅花 A - K   17 - 29
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,        --红桃 A - K   33 - 45
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,        --黑桃 A - K   49 - 61
                                                                    0x4E,0x4F,  --78,79
}

function Card:ctor(hex)
    self.hex       = hex  --十六进制
    self.suit      = Card.getSuit(hex)      -- 花色
    self.count     = Card.getCount(hex)     -- 数值
    self.suitName  = Card.getCountName(hex) -- 花色名称
    self.countName = Card.getCountName(hex) -- 数值名称
    self.name      = Card.getName(hex)      -- 名称
    self.index     = Card.getIndex(hex)     -- 下标

    self.imagePaths = {
        small  = Card.getSmallImagePath(hex),
        big    = Card.getBigImagePath(hex),
        number = Card.getNumberImagePath(hex),
        joker  = Card.getJokerImagePath(hex),
    }

    self.something = {
        suit  = self.suit,
        count = self.count,
        name  = self.name,
        hex   = self.hex,
        index = self.index,
    }
end

function Card.getSuit(hex)
    return bit.band(hex, 0xF0)/16
end

function Card.getCount(hex)
    return bit.band(hex, 0x0F)
end

function Card.getCountName(hex)
    local count  = Card.getCount(hex)
    local cardName = Card.CountNameConfig[count]
    return cardName
end

function Card.getSuitName(hex)
    local suit  = Card.getSuit(hex)
    local suitName = Card.SuitNameConfig[suit]
    return suitName
end

function Card.getName(hex)
    return Card.getSuitName(hex)..Card.getCountName(hex)
end

function Card.getIndex(hex)
    local suit = Card.getSuit(hex)
    local count = Card.getCount(hex)

    -- 首先排列大小王
    if suit == 4 then
        return 0x0F - count + 1
    end
    -- 然后排列2和A
    if count == 2 then
        return 3 + (3 - suit)
    end
    if count == 1 then
        return 7 + (3 - suit)
    end
    -- 最后是K-3
    return 11 + (0x0D - count) * 4 + (3 - suit)
end

--[[
    获取图片
]]
function Card.getSmallImagePath(hex)
    local suit = Card.getSuit(hex)
    local count = Card.getCount(hex)
    if count < Card.JokerIndex then
        return Card.PATH..suit.."_small"
    else
        return Card.PATH.."none"
    end
end

function Card.getBigImagePath(hex)
    local suit = Card.getSuit(hex)
    local count = Card.getCount(hex)
    if count < Card.JokerIndex then
        return Card.PATH..suit.."_big"
    else
        return Card.PATH.."joker_type_"..count
    end
end

function Card.getNumberImagePath(hex)
    local suit = Card.getSuit(hex)
    local count = Card.getCount(hex)
    if count < Card.JokerIndex then
        if suit == 0 or suit == 2 then
            return Card.PATH.."num_red_"..count
        else
            return Card.PATH.."num_black_"..count
        end
    else
        return Card.PATH.."none"
    end
end

function Card.getJokerImagePath(hex)
    local suit = Card.getSuit(hex)
    local count = Card.getCount(hex)
    if count < Card.JokerIndex then
        return Card.PATH.."none"
    else
        return Card.PATH.."joker_"..count
    end
end

return Card