local CardTypeCalculation = class("CardTypeCalculation")
local Card                = require("Room.Landlords.Card")

CardTypeCalculation.AllCard = {
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,        --方块 A - K   1 - 13
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,        --梅花 A - K   17 - 29
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,        --红桃 A - K   33 - 45
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,        --黑桃 A - K   49 - 61
                                                                    0x4E,0x4F,  --78,79
}

CardTypeCalculation.CardsType = 
{
	INVALID         = -1, --非法
	SINGLE          = 0, --单张
	BLACK_JOKER     = 1, --小王
	RED_JOKER       = 2, --大王
	DOUBLE_JOKER    = 3, --双王炸
	FLUSH           = 4, --同花(底牌)
	PAIR            = 5, --对子
	THREE           = 6, --3张
	LINE            = 7, --顺子(底牌3张算顺子)
	PAIR_LINE       = 8, --连对
	THREE_LINE      = 9, --飞机
	THREE_TAKE_ONE  = 10, --三带一
	THREE_TAKE_PAIR = 11, --三带对
	FOUR_TAKE_ONE   = 12, --四带两单
	FOUR_TAKE_PAIR  = 13, --四带两对
	BOMB            = 14, --四张炸弹
};

function CardTypeCalculation:ctor(data)
    
end

function CardTypeCalculation:getRandomCard(count, debarArray)
    -- local temp = clone(CardTypeCalculation.AllCard)
    -- if debarArray and #debarArray > 0 then
    --     for i,v in ipairs(table_name) do
    --         print(i,v)
    --     end
    -- end
end


return CardTypeCalculation



-- local CardTypeCalculation = class("CardTypeCalculation")
-- --排序类型
-- ST_ORDER                                         =  1                                                                        --大小排序
-- ST_COUNT                                         =  2                                                                        --数目排序
-- ST_CUSTOM                                         =  3                                                                        --自定排序

-- --索引变量
-- local cbIndexCount = 5

-- --扑克数据
-- local        m_cbCardData  = 
-- {
--         0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,        --方块 A - K   1 - 13
--         0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,        --梅花 A - K   17 - 29
--         0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,        --红桃 A - K   33 - 45
--         0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,        --黑桃 A - K   49 - 61
--         0x4E,0x4F,                                                                         --78,79
-- }

-- ----------------------------------------------------------------------------------
-- function CardTypeCalculation:ctor()
--     print("CardTypeCalculation -> ctor()")
-- end
-- --获取类型
-- function CardTypeCalculation:GetCardType(cbCardData, cbCardCount)
--     self:SortCardList(cbCardData, cbCardCount, ST_ORDER)
--         --简单牌型
--         if cbCardCount == 0 then        --空牌                
--                 return CMD_LAND.CT_ERROR
--         elseif cbCardCount == 1 then  --单牌
--                 return CMD_LAND.CT_SINGLE                
--         elseif cbCardCount == 2 then         --对牌火箭
--                 --牌型判断
--                 if ((cbCardData[1] == 0x4F)and(cbCardData[2] == 0x4E)) then 
--             return CMD_LAND.CT_MISSILE_CARD
--         end
--                 if (self:GetCardLogicValue(cbCardData[1]) == self:GetCardLogicValue(cbCardData[2]))then
--             return CMD_LAND.CT_DOUBLE
--         end
--                 return CMD_LAND.CT_ERROR                
--         end

--         --分析扑克
--     --tagAnalyseResult
--         local AnalyseResult = {}
--         AnalyseResult = self:AnalysebCardData(cbCardData, cbCardCount)

--         --四牌判断
--         if (AnalyseResult.cbBlockCount[4] > 0)then
--                 --牌型判断
--                 if ((AnalyseResult.cbBlockCount[4] == 1) and (cbCardCount == 4))then
--             return CMD_LAND.CT_BOMB_CARD
--         end
--                 if ((AnalyseResult.cbBlockCount[4] == 1) and (cbCardCount == 6)) then 
--             return CMD_LAND.CT_FOUR_TAKE_ONE
--         end
--                 if ((AnalyseResult.cbBlockCount[4] == 1)and(cbCardCount == 8)and(AnalyseResult.cbBlockCount[2] == 2)) then
--             return CMD_LAND.CT_FOUR_TAKE_TWO
--         end
--         --下面还要判断78888999这种飞机牌
--         if (AnalyseResult.cbBlockCount[3] == 0) then
--                     return CMD_LAND.CT_ERROR
--         end
--         end

--         --三牌判断
--         if (AnalyseResult.cbBlockCount[3] > 0)then
--                 --连牌判断
--                 -- 飞机中带中4张相同牌是判断
--                 if AnalyseResult.cbBlockCount[4] > 0 then 
--                         local num = AnalyseResult.cbBlockCount[3]
--                         for i = 0, AnalyseResult.cbBlockCount[4] -1 do 
--                                 AnalyseResult.cbCardData[3][(num+i)*3 + 1] = AnalyseResult.cbCardData[4][i*4 + 1]
--                                 AnalyseResult.cbCardData[3][(num+i)*3 + 2] = AnalyseResult.cbCardData[4][i*4 + 2]
--                                 AnalyseResult.cbCardData[3][(num+i)*3 + 3] = AnalyseResult.cbCardData[4][i*4 + 3]
--                         end
--                         AnalyseResult.cbBlockCount[3] = AnalyseResult.cbBlockCount[3] + AnalyseResult.cbBlockCount[4]
--                 end

--                 if (AnalyseResult.cbBlockCount[3] > 1)then
--                         --变量定义
--                         local cbCardData = AnalyseResult.cbCardData[3][1]
--                         local cbFirstLogicValue = self:GetCardLogicValue(cbCardData)

--                         --错误过虑
--                         if (cbFirstLogicValue >=  15) then 
--                 return CMD_LAND.CT_ERROR
--             end
--                         --连牌判断         
--                         local table = {}
--                         table[cbFirstLogicValue] = 1

--                         for i = 1, AnalyseResult.cbBlockCount[3] - 1 do                        
--                                 local cbCardData = AnalyseResult.cbCardData[3][i*3 + 1]
--                                 table[self:GetCardLogicValue(cbCardData)] = 1
--                         end
--                         local max = 0
--             local min = 0
--                         for index = 3, 14 do
--                                 if table[index] == 1 then
--                                          if min == 0 then 
--                                                  min = index
--                                          end 
--                                          max = index
--                                  end
--                         end
--                         if (max - min + 1) ~= AnalyseResult.cbBlockCount[3] then 
--                                 return CMD_LAND.CT_ERROR
--                         end

--                         --for i = 1, AnalyseResult.cbBlockCount[3] - 1 do
--                         --
--                         --        local cbCardData = AnalyseResult.cbCardData[3][i*3 + 1]
--                         --        if (cbFirstLogicValue ~=  (self:GetCardLogicValue(cbCardData)+i))then
--                         --            return CMD_LAND.CT_ERROR
--                         --    end
--                         --end
--                 elseif( cbCardCount == 3 ) then
--             return CMD_LAND.CT_THREE
--         end
--                 --牌形判断
--                 if (AnalyseResult.cbBlockCount[3]*3 == cbCardCount) then
--             return CMD_LAND.CT_THREE_LINE
--         end
--                 if (AnalyseResult.cbBlockCount[3]*4 == cbCardCount) then
--             return CMD_LAND.CT_THREE_TAKE_ONE
--         end
--                 if ((AnalyseResult.cbBlockCount[3]*5 == cbCardCount)and(AnalyseResult.cbBlockCount[2] == AnalyseResult.cbBlockCount[3])) then
--             return CMD_LAND.CT_THREE_TAKE_TWO
--         end
--                 return CMD_LAND.CT_ERROR
--         end

--         --两张类型
--         if (AnalyseResult.cbBlockCount[2] >=  3)then
--                 --变量定义
--                 local cbCardData = AnalyseResult.cbCardData[2][1]
--                 local cbFirstLogicValue = self:GetCardLogicValue(cbCardData)

--                 --错误过虑
--                 if (cbFirstLogicValue >=  15) then
--             return CMD_LAND.CT_ERROR
--         end
--                 --连牌判断
--                 for i = 1, AnalyseResult.cbBlockCount[2] - 1 do
                
--                         local cbCardData = AnalyseResult.cbCardData[2][i*2 + 1]
--                         if (cbFirstLogicValue ~=  (self:GetCardLogicValue(cbCardData)+i))then
--                 return CMD_LAND.CT_ERROR
--             end
--                 end

--                 --二连判断
--                 if ((AnalyseResult.cbBlockCount[2]*2) == cbCardCount) then
--             return CMD_LAND.CT_DOUBLE_LINE
--         end
--                 return CMD_LAND.CT_ERROR
--         end

--         --单张判断
--         if ((AnalyseResult.cbBlockCount[1] >=  5)and(AnalyseResult.cbBlockCount[1] == cbCardCount))then
--                 --变量定义
--                 local cbCardData = AnalyseResult.cbCardData[1][1]
--                 local cbFirstLogicValue = self:GetCardLogicValue(cbCardData)

--                 --错误过虑
--                 if (cbFirstLogicValue >= 15) then 
--             return CMD_LAND.CT_ERROR
--         end

--                 --连牌判断
--                 for i = 1, AnalyseResult.cbBlockCount[1] - 1 do
--                         local cbCardData = AnalyseResult.cbCardData[1][i + 1]
--                         if (cbFirstLogicValue~= (self:GetCardLogicValue(cbCardData) + i))then
--                 return CMD_LAND.CT_ERROR
--                     end
--         end

--                 return CMD_LAND.CT_SINGLE_LINE
--         end

--         return CMD_LAND.CT_ERROR
-- end

-- --排列扑克
-- function CardTypeCalculation:SortCardList(cbCardData, cbCardCount, cbSortType)
--         --数目过虑
--         if (cbCardCount == 0) then return end
--         if (cbSortType == ST_CUSTOM) then return end

--         --转换数值
--         local cbSortValue = {}
--         for i = 1, cbCardCount do 
--         cbSortValue = self:GetCardLogicValue(cbCardData)        
--     end
--         --排序操作
--         local bSorted = true
--         local cbSwitchData = 0
--     local cbLast = cbCardCount-1

--         repeat
--                 bSorted = true
--                 for i = 1, cbLast do
--         if cbSortValue and cbSortValue[i+1] then


--                         if ((cbSortValue < cbSortValue[i+1]) or
--                                 ((cbSortValue == cbSortValue[i+1])and(cbCardData < cbCardData[i+1])))then
--                                 --设置标志
--                                 bSorted = false
--                 --[[
--                 printf("cbLast = %d", cbLast)
--                 printf("paixuqian:cbCardData=%d",cbCardData)
--                 printf("paixuqian:cbCardData[i+1]=%d",cbCardData[i+1])
--                 printf("paixuqian:cbSortValue=%d",cbSortValue)
--                 printf("paixuqian:cbSortValue[i+1]=%d",cbSortValue[i+1])]]
--                                 --扑克数据
--                                 cbSwitchData = cbCardData
--                                 cbCardData = cbCardData[i+1]
--                                 cbCardData[i+1] = cbSwitchData

--                                 --排序权位
--                                 cbSwitchData = cbSortValue
--                                 cbSortValue = cbSortValue[i+1]
--                                 cbSortValue[i+1] = cbSwitchData

--                         end        
--                 end
--      end
--                 cbLast = cbLast - 1
--         until bSorted == true

--         --数目排序
--         if (cbSortType == ST_COUNT)then
--                 --变量定义
--                 local cbCardIndex = 0

--                 --分析扑克
--                 local AnalyseResult = {}
--                 AnalyseResult = self:AnalysebCardData(cbCardData[cbCardIndex + 1], cbCardCount - cbCardIndex)

--                 --提取扑克
--                 for i = 1, 4 do
--                         --拷贝扑克
--                         local cbIndex = 4 - (i-1)-1
--                         cbCardData[cbCardIndex + 1] = AnalyseResult.cbCardData[cbIndex + 1]

--                         --设置索引
--                         cbCardIndex = cbCardIndex + AnalyseResult.cbBlockCount[cbIndex + 1]*(cbIndex+1)
--                 end
--         end
-- end

-- --混乱扑克(暂时没有用到的方法)
-- function CardTypeCalculation:RandCardList(cbCardBuffer, cbBufferCount)
--         --混乱准备
--         local cbCardData = {}
--         cbCardData = clone(m_cbCardData)

--         --混乱扑克
--         local cbRandCount = 0
--     local cbPosition = 0
--         repeat
--                 cbPosition = math.random(1,(cbBufferCount - cbRandCount))  
--                 cbCardBuffer[cbRandCount] = cbCardData[cbPosition]
--         cbRandCount = cbRandCount + 1
--                 cbCardData[cbPosition] = cbCardData[cbBufferCount - cbRandCount + 1]
--         until (cbRandCount >= cbBufferCount)

-- end

-- --删除扑克
-- function CardTypeCalculation:RemoveCardList(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)
--         --检验数据 nana
--         --LuaProxy:ASSERT(cbRemoveCount <= cbCardCount)

--         --定义变量
--         local cbDeleteCount = 0
--     local cbTempCardData = {}
--         if (cbCardCount > CMD_LAND.MAX_COUNT) then return false end
--         cbTempCardData = clone(cbCardData)

--         --置零扑克
--         for i = 1, cbRemoveCount do
--                 for j = 1, cbCardCount do
--                         if (cbRemoveCard == cbTempCardData[j]) then
--                                 cbDeleteCount = cbDeleteCount + 1
--                                 cbTempCardData[j] = 0
--                                 break
--                         end
--                 end
--         end
--         if (cbDeleteCount~= cbRemoveCount) then return false end

--         --清理扑克
--         local cbCardPos = 0
--         for i = 1, cbCardCount do
--                 if (cbTempCardData~= 0) then         
--             cbCardData[cbCardPos + 1] = cbTempCardData
--             cbCardPos = cbCardPos + 1
--         end
--         end

--         return true
-- end

-- --删除扑克
-- function CardTypeCalculation:RemoveCard(cbRemoveCard, cbRemoveCount, cbCardData, cbCardCount)
--         --检验数据 nana
--         --LuaProxy:ASSERT(cbRemoveCount <= cbCardCount)

--         --定义变量
--         local cbDeleteCount = 0
--     local cbTempCardData = {}
--         if (cbCardCount > CMD_LAND.MAX_COUNT) then return false end
--         cbTempCardData = clone(cbCardData)

--         --置零扑克
--         for i = 1, cbRemoveCount do
--                 for j = 1, cbCardCount do
--                         if (cbRemoveCard == cbTempCardData[j])then
--                                 cbDeleteCount = cbDeleteCount + 1
--                                 cbTempCardData[j] = 0
--                                 break
--                         end
--                 end
--         end
--         if (cbDeleteCount~= cbRemoveCount) then return false end

--         --清理扑克
--         local cbCardPos = 0
--         for i = 1, cbCardCount do
--                 if (cbTempCardData ~= 0) then            
--             cbCardData[cbCardPos + 1] = cbTempCardData
--             cbCardPos = cbCardPos + 1
--         end
--         end

--         return true
-- end

-- --排列扑克
-- function CardTypeCalculation:SortOutCardList(cbCardData, cbCardCount)
--         --获取牌型
--         local cbCardType = self:GetCardType(cbCardData,cbCardCount)

--         if( cbCardType == CMD_LAND.CT_THREE_TAKE_ONE or cbCardType == CMD_LAND.CT_THREE_TAKE_TWO )then
--                 --分析牌
--                 local AnalyseResult = {}
--                 AnalyseResult = self:AnalysebCardData( cbCardData, cbCardCount)

--                 cbCardCount = AnalyseResult.cbBlockCount[3]*3
--                 cbCardData = clone(AnalyseResult.cbCardData[3])
--                 for i = 4 , 1, -1 do
--             while true do
--                 if 3 == i then
--                     break
--                 end
--                 if( AnalyseResult.cbBlockCount > 0 )then
--                                     cbCardData[cbCardCount + 1] = clone(AnalyseResult.cbCardData)            
--                                     cbCardCount  =  cbCardCount + (i)*AnalyseResult.cbBlockCount
--                             end
--                 break
--             end                
--                 end
--         elseif( cbCardType == CMD_LAND.CT_FOUR_TAKE_ONE or cbCardType == CMD_LAND.CT_FOUR_TAKE_TWO ) then
        
--                 --分析牌
--                 local AnalyseResult = {}
--                 AnalyseResult = self:AnalysebCardData( cbCardData,cbCardCount)

--                 cbCardCount = AnalyseResult.cbBlockCount[4]*4
--                 cbCardData = clone(AnalyseResult.cbCardData[4])
--                 for i = 4, 1, -1 do
        
--                         while true do
--                 if 4 == i then
--                     break
--                 end
--                 if( AnalyseResult.cbBlockCount > 0 )then
--                                     cbCardData[cbCardCount + 1] = clone(AnalyseResult.cbCardData)
                                            
--                                     cbCardCount =  cbCardCount + (i)*AnalyseResult.cbBlockCount
--                             end
--                 break
--             end                        
--                 end
--         end

-- end

-- --逻辑数值
-- function CardTypeCalculation:GetCardLogicValue(cbCardData)
--         --扑克属性
--     if not cbCardData then return end
--         local cbCardColor = self:GetCardColor(cbCardData)
--         local cbCardValue = self:GetCardValue(cbCardData)

--         --转换数值
--         if (cbCardColor == 0x40) then return cbCardValue + 2 end
--     local value = cbCardValue
--     if cbCardValue <= 2 then
--         value = cbCardValue+13
--     end
--         return value
-- end

-- --对比扑克
-- function CardTypeCalculation:CompareCard(cbFirstCard,  cbNextCard, cbFirstCount, cbNextCount)
--         --获取类型
--         local cbNextType = self:GetCardType(cbNextCard,cbNextCount)
--         local cbFirstType = self:GetCardType(cbFirstCard,cbFirstCount)

--         --类型判断
--         if (cbNextType == CMD_LAND.CT_ERROR) then return false end
--         if (cbNextType == CMD_LAND.CT_MISSILE_CARD)then return true end
--         if (cbFirstType == CMD_LAND.CT_MISSILE_CARD) then return false end

--         --炸弹判断
--         if ((cbFirstType~= CMD_LAND.CT_BOMB_CARD)and(cbNextType == CMD_LAND.CT_BOMB_CARD)) then return true end
--         if ((cbFirstType == CMD_LAND.CT_BOMB_CARD)and(cbNextType~= CMD_LAND.CT_BOMB_CARD)) then return false end

--         --规则判断
--         if ((cbFirstType~= cbNextType)or(cbFirstCount~= cbNextCount)) then return false end

--         --开始对比
--         if cbNextType == CMD_LAND.CT_SINGLE or cbNextType == CMD_LAND.CT_DOUBLE or cbNextType == CMD_LAND.CT_THREE
--         or cbNextType == CMD_LAND.CT_SINGLE_LINE or cbNextType == CMD_LAND.CT_DOUBLE_LINE
--         or cbNextType == CMD_LAND.CT_THREE_LINE  or cbNextType == CMD_LAND.CT_BOMB_CARD then
--                 --获取数值
--                 local cbNextLogicValue = self:GetCardLogicValue(cbNextCard[1])
--                 local cbFirstLogicValue = self:GetCardLogicValue(cbFirstCard[1])

--                 --对比扑克
--                 return cbNextLogicValue > cbFirstLogicValue
                
--         elseif  cbNextType == CMD_LAND.CT_THREE_TAKE_ONE or cbNextType == CMD_LAND.CT_THREE_TAKE_TWO then
--                 --分析扑克
--                 local NextResult = {}
--                 local FirstResult = {}
--                 NextResult = self:AnalysebCardData(cbNextCard,cbNextCount)
--                 FirstResult = self:AnalysebCardData(cbFirstCard,cbFirstCount)

--                 --获取数值
--                 local cbNextLogicValue = self:GetCardLogicValue(NextResult.cbCardData[3][1])
--                 local cbFirstLogicValue = self:GetCardLogicValue(FirstResult.cbCardData[3][1])

--                 --对比扑克
--                 return cbNextLogicValue > cbFirstLogicValue
--     elseif  cbNextType == CMD_LAND.CT_FOUR_TAKE_ONE or cbNextType == CMD_LAND.CT_FOUR_TAKE_TWO then

--                 --分析扑克
--                 local NextResult = {}
--                 local FirstResult = {}
--                 NextResult = self:AnalysebCardData(cbNextCard,cbNextCount)
--                 FirstResult = self:AnalysebCardData(cbFirstCard,cbFirstCount)

--                 --获取数值
--                 local cbNextLogicValue = self:GetCardLogicValue(NextResult.cbCardData[4][1])
--                 local cbFirstLogicValue = self:GetCardLogicValue(FirstResult.cbCardData[4][1])

--                 --对比扑克
--                 return cbNextLogicValue > cbFirstLogicValue
--         end
        
        
--         return false
-- end

-- --构造扑克
-- function CardTypeCalculation:MakeCardData(cbValueIndex, cbColorIndex)
--         return bit.bor(bit.blshift(cbColorIndex,4),(cbValueIndex+1))
-- end

-- --分析扑克
-- function CardTypeCalculation:AnalysebCardData(cbCardData, cbCardCount)
--         --设置结果
--     --memset(&AnalyseResult,0,sizeof(AnalyseResult));
--         --初始化结构体中数组 AnalyseResult
--     --分析结构
-- --struct tagAnalyseResult
-- --{
-- --        BYTE                                                         cbBlockCount[4];                                        //扑克数目
-- --        BYTE                                                        cbCardData[4][CMD_LAND.MAX_COUNT];                        //扑克数据
-- --};
--     local AnalyseResult = {}
--     AnalyseResult.cbBlockCount = {}
--     AnalyseResult.cbCardData = {}
--     for i = 1, 4 do      
--         AnalyseResult.cbBlockCount = 0
--         AnalyseResult.cbCardData = {}
--         for j = 1, CMD_LAND.MAX_COUNT do
--             AnalyseResult.cbCardData[j] = 0
--         end     
--     end

--         --扑克分析
--     local index = 0
--         for i = 0, cbCardCount-1 do
--                 --变量定义
--         if i == index then
--             index = 0
--             local cbSameCount = 1
--             local cbCardValueTemp = 0
--                     local cbLogicValue = self:GetCardLogicValue(cbCardData[i+1])

--                     --搜索同牌
--                     for j = i+1, cbCardCount - 1 do
--                             --获取扑克
--                             if (self:GetCardLogicValue(cbCardData[j+1])~= cbLogicValue) then
--                     break
--                 end
--                             --设置变量
--                             cbSameCount = cbSameCount + 1
--                     end

--                     --设置结果
--             --todo:liufapu 也是一个坑
--             --BYTE cbIndex=AnalyseResult.cbBlockCount[cbSameCount-1]++;
--             if cbSameCount <= #AnalyseResult.cbBlockCount then
--                 local cbIndex = AnalyseResult.cbBlockCount[cbSameCount]
--                 AnalyseResult.cbBlockCount[cbSameCount] = AnalyseResult.cbBlockCount[cbSameCount] + 1
--                 for j = 0, cbSameCount - 1 do
--                     AnalyseResult.cbCardData[cbSameCount][cbIndex * cbSameCount + j + 1] = cbCardData[i + j + 1]
--                 end
--                 -- 设置索引
--                 -- i+=cbSameCount-1;--更大一个坑
--                 index = i + cbSameCount - 1 + 1
--                 -- 因为在下一个循环中i++，所以此处应+1
--             end
--         end        
--         end

--         return AnalyseResult
-- end

-- --分析分布
-- function CardTypeCalculation:AnalysebDistributing(cbCardData, cbCardCount)
--         --设置变量
--         local Distributing = {}
--     --初始化
--     Distributing.cbCardCount = 0
--     Distributing.cbDistributing = {}
--     for i = 1, 15 do
--         Distributing.cbDistributing = {}
--         for j = 1, 6 do
--             Distributing.cbDistributing[j] = 0
--         end     
--     end

--         --设置变量
--         for i = 1, cbCardCount do
--         while true do
--             if (cbCardData == 0)then 
--                 break
--             end
--             --获取属性
--                     local cbCardColor = self:GetCardColor(cbCardData)
--                     local cbCardValue = self:GetCardValue(cbCardData)

--                     --分布信息
--                     Distributing.cbCardCount = Distributing.cbCardCount + 1
--                     Distributing.cbDistributing[cbCardValue][cbIndexCount + 1] = Distributing.cbDistributing[cbCardValue][cbIndexCount+1] + 1
--                     local cbIndex = bit.brshift(cbCardColor,4)
--             Distributing.cbDistributing[cbCardValue][cbIndex + 1] = Distributing.cbDistributing[cbCardValue][cbIndex + 1] + 1
--             break
--         end        
--         end
--     return Distributing
-- end

-- --出牌搜索
-- function CardTypeCalculation:SearchOutCard(cbHandCardData, cbHandCardCount, cbTurnCardData, cbTurnCardCount)
--         --设置结果
--     --delete by liufpu
--         --LuaProxy:ASSERT( pSearchCardResult ~=  nil )
--         --if( pSearchCardResult == nil ) then return 0 end
        
--     local pSearchCardResult = {}
--     pSearchCardResult.cbSearchCount = 0
--     pSearchCardResult.cbCardCount = {}
--     pSearchCardResult.cbResultCard = {}
--     for i = 1, CMD_LAND.MAX_COUNT do
--         pSearchCardResult.cbCardCount = 0
--         pSearchCardResult.cbResultCard = {}
--         for j = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbResultCard[j] = 0
--         end       
--     end
--         if (cbHandCardCount == 0)then return pSearchCardResult end

--         --变量定义
--         local cbResultCount = 0
--         local tmpSearchCardResult = {}

--         --构造扑克
--         local cbCardData = {}
--         local cbCardCount = cbHandCardCount

--         cbCardData = clone(cbHandCardData)

--         --排列扑克
--         self:SortCardList(cbCardData, cbCardCount, ST_ORDER)

--         --获取类型
--         local cbTurnOutType = self:GetCardType(cbTurnCardData,cbTurnCardCount)

--         --出牌分析
--         if cbTurnOutType == CMD_LAND.CT_ERROR then                                        --错误类型
--                 --提取各种牌型一组
--         --delete by liufpu
--                 --LuaProxy:ASSERT( pSearchCardResult )
--                 --if( not pSearchCardResult )then return 0 end

--                 --是否一手出完
--                 if( self:GetCardType(cbCardData,cbCardCount) ~=  CMD_LAND.CT_ERROR ) then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = cbCardCount
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(cbCardData)
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --如果最小牌不是单牌，则提取
--                 local cbSameCount = 0
--                 if( cbCardCount > 1 and self:GetCardValue(cbCardData[cbCardCount]) == self:GetCardValue(cbCardData[cbCardCount-1]) )then
--                         cbSameCount = 1
--                         pSearchCardResult.cbResultCard[cbResultCount + 1][1] = cbCardData[cbCardCount]
--                         local cbCardValue = self:GetCardValue(cbCardData[cbCardCount])
--                         for i = cbCardCount-1, 1, -1 do
--                                 if( self:GetCardValue(cbCardData) == cbCardValue )then             
--                                         pSearchCardResult.cbResultCard[cbResultCount + 1][cbSameCount + 1] = cbCardData
--                                     cbSameCount = cbSameCount + 1
--                                 else 
--                     break
--                 end
--                         end

--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = cbSameCount
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --单牌
--                 local cbTmpCount = 0
--                 if( cbSameCount ~=  1 )then
--                         cbTmpCount, tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,1)
--                         if( cbTmpCount > 0 )then
--                                 pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                                 pSearchCardResult.cbResultCard[cbResultCount + 1]  = clone(tmpSearchCardResult.cbResultCard[1])
--                                 cbResultCount = cbResultCount + 1
--                         end
--                 end

--                 --对牌
--                 if( cbSameCount ~=  2 ) then
--                         cbTmpCount, tmpSearchCardResult = self:SearchSameCard( cbCardData, cbCardCount, 0, 2)
--                         if( cbTmpCount > 0 ) then
                        
--                                 pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                                 pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                                 cbResultCount = cbResultCount + 1
--                         end
--                 end

--                 --三条
--                 if( cbSameCount ~=  3 ) then
--                         cbTmpCount, tmpSearchCardResult = self:SearchSameCard( cbCardData, cbCardCount, 0, 3)
--                         if( cbTmpCount > 0 ) then
--                                 pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                                 pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                                 cbResultCount = cbResultCount + 1
--                         end
--                 end

--                 --三带一单
--                 cbTmpCount, tmpSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,0,3,1)
--                 if( cbTmpCount > 0 ) then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --三带一对
--                 cbTmpCount, tmpSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,0,3,2)
--                 if( cbTmpCount > 0 )then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --单连
--                 cbTmpCount, tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,1,0)
--                 if( cbTmpCount > 0 )then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --连对
--                 cbTmpCount,tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,2,0)
--                 if( cbTmpCount > 0 )then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --三连
--                 cbTmpCount, tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,3,0)
--                 if( cbTmpCount > 0 )then
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                         cbResultCount = cbResultCount + 1
--                 end

--                 --炸弹
--                 if( cbSameCount ~=  4 )then
--                         cbTmpCount, tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,4)
--                         if( cbTmpCount > 0 )then
--                                 pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount[1]
--                                 pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSearchCardResult.cbResultCard[1])
--                                 cbResultCount = cbResultCount + 1
--                         end
--                 end
--                 --搜索火箭
--                 if ((cbCardCount>= 2)and(cbCardData[1] == 0x4F)and(cbCardData[2] == 0x4E))then
--                         --设置结果
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = 2
--                         pSearchCardResult.cbResultCard[cbResultCount + 1][1] = cbCardData[1]
--                         pSearchCardResult.cbResultCard[cbResultCount + 1][2] = cbCardData[2]
--                         cbResultCount = cbResultCount + 1
--                 end
--         elseif cbTurnOutType == CMD_LAND.CT_SINGLE or cbTurnOutType == CMD_LAND.CT_DOUBLE or cbTurnOutType == CMD_LAND.CT_THREE then
--             --单牌类型
--                 --对牌类型
--                 --三条类型                                        
--                 --变量定义
--                 local cbReferCard = cbTurnCardData[1]
--                 local cbSameCount = 1
--                 if( cbTurnOutType == CMD_LAND.CT_DOUBLE ) then 
--             cbSameCount = 2
--                 elseif( cbTurnOutType == CMD_LAND.CT_THREE ) then
--             cbSameCount = 3
--         end
--                 --搜索相同牌
--                 cbResultCount, pSearchCardResult = self:SearchSameCard( cbCardData, cbCardCount, cbReferCard, cbSameCount)

--     elseif cbTurnOutType == CMD_LAND.CT_SINGLE_LINE or cbTurnOutType == CMD_LAND.CT_DOUBLE_LINE or cbTurnOutType == CMD_LAND.CT_THREE_LINE then
--                 --单连类型
--                 --对连类型
--                 --三连类型
                
--                 --变量定义
--                 local cbBlockCount = 1
--                 if( cbTurnOutType == CMD_LAND.CT_DOUBLE_LINE ) then
--             cbBlockCount = 2
--                 elseif( cbTurnOutType == CMD_LAND.CT_THREE_LINE ) then
--             cbBlockCount = 3
--         end

--                 local cbLineCount = math.floor(cbTurnCardCount/cbBlockCount)

--                 --搜索边牌
--                 cbResultCount, pSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,cbTurnCardData[1],cbBlockCount,cbLineCount)

--     elseif cbTurnOutType == CMD_LAND.CT_THREE_TAKE_ONE or cbTurnOutType == CMD_LAND.CT_THREE_TAKE_TWO then
--             --三带一单
--             --三带一对                
--                 --效验牌数
--                 if cbCardCount >= cbTurnCardCount then 
--                 --如果是三带一或三带二
--                         if( cbTurnCardCount == 4 or cbTurnCardCount == 5 )then
--                                 local cbTakeCardCount = 2
--                     if cbTurnOutType == CMD_LAND.CT_THREE_TAKE_ONE then
--                         cbTakeCardCount = 1
--                     end

--                                 --搜索三带牌型
--                                 cbResultCount, pSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,cbTurnCardData[3],3,cbTakeCardCount)
--                         else
                        
--                                 --变量定义
--                                 local cbBlockCount = 3
--                     local temp = 5
--                     if cbTurnOutType == CMD_LAND.CT_THREE_TAKE_ONE then
--                         temp = 4
--                     end
--                                 local cbLineCount = math.floor(cbTurnCardCount/temp)
--                                 local cbTakeCardCount = 2
--                     if cbTurnOutType == CMD_LAND.CT_THREE_TAKE_ONE then
--                         cbTakeCardCount = 1
--                     end

--                                 --搜索连牌
--                                 local cbTmpTurnCard = {}
--                                 cbTmpTurnCard = clone(cbTurnCardData)
--                                 self:SortOutCardList( cbTmpTurnCard,cbTurnCardCount )
--                     local comperNum = nil
--                     local sameNum = 0
--                     for aa = 1, cbTurnCardCount do
--                         local cbLogicValueTem = self:GetCardLogicValue(cbTmpTurnCard[aa])
--                             --搜索同牌
--                         sameNum = 0
--                                 for cc = aa+1, cbTurnCardCount do
--                                         --获取扑克
--                                         if (self:GetCardLogicValue(cbTmpTurnCard[cc]) ~= cbLogicValueTem) then
--                                 break
--                             end
--                             --设置变量
--                             sameNum = sameNum + 1
--                             if sameNum > 1 then
--                                 comperNum = cbTmpTurnCard[cc]
--                             end
--                                 end
--                     end
--                    if comperNum == nil then
--                       comperNum = cbTmpTurnCard[1]
--                    end
--                     cbResultCount, pSearchCardResult = self:SearchLineCardType(cbCardData,cbCardCount,comperNum,cbBlockCount,cbLineCount)
--                                 --cbResultCount, pSearchCardResult = self:SearchLineCardType(cbCardData,cbCardCount,cbTmpTurnCard[1],cbBlockCount,cbLineCount)
--                     if cbTurnOutType == CMD_LAND.CT_THREE_TAKE_ONE then

--                     elseif(cbTurnOutType == CMD_LAND.CT_THREE_TAKE_TWO) then

--                     end
--                                 --提取带牌
--                                 local bAllDistill = true
--                     for i = 1, cbResultCount do
--                                         local cbResultIndex = cbResultCount - (i - 1) -1

--                                         --变量定义
--                                         local cbTmpCardData = {}
--                                         local cbTmpCardCount = cbCardCount

--                                         --删除连牌
--                                         cbTmpCardData = clone(cbCardData)
--                                         LuaProxy:ASSERT( self:RemoveCard( pSearchCardResult.cbResultCard[cbResultIndex + 1],pSearchCardResult.cbCardCount[cbResultIndex  + 1],
--                                                 cbTmpCardData,cbTmpCardCount ) )
--                                         cbTmpCardCount =  cbTmpCardCount - pSearchCardResult.cbCardCount[cbResultIndex + 1]

--                                         --分析牌
--                                         local  TmpResult = {}
--                                         TmpResult = self:AnalysebCardData(cbTmpCardData,cbTmpCardCount)

--                                         --提取牌
--                                         local cbDistillCard = {}
--                                         local cbDistillCount = 0
--                         for j = cbTakeCardCount, 4 do
--                                                 if( TmpResult.cbBlockCount[j] > 0 )then
--                             --[[
--                             if( j+1 == cbTakeCardCount && TmpResult.cbBlockCount[j] >= cbLineCount )
--                                                                 {
--                                                                         BYTE cbTmpBlockCount = TmpResult.cbBlockCount[j];
--                                                                         memcpy( cbDistillCard,&TmpResult.cbCardData[j][(cbTmpBlockCount-cbLineCount)*(j+1)],
--                                                                                 sizeof(BYTE)*(j+1)*cbLineCount );
--                                                                         cbDistillCount = (j+1)*cbLineCount;
--                                                                         break;
--                                                                 }
--                                     ]]--todo:liufapu
--                                                         if((j -1)+1 == cbTakeCardCount and TmpResult.cbBlockCount[j] >=  cbLineCount )then
--                                                                 local cbTmpBlockCount = TmpResult.cbBlockCount[j]
--                                      for h = 1, j*cbLineCount do --nana
--                                       cbDistillCard[h] = TmpResult.cbCardData[j][(cbTmpBlockCount-cbLineCount)*(j) + h]
--                                      end
                                    
--                                                                 --cbDistillCard = clone(TmpResult.cbCardData[j][(cbTmpBlockCount-cbLineCount)*(j) + 1]) 
--                                                                 cbDistillCount = (j)*cbLineCount
--                                                                 break                                                
--                                                         else
--                                                                 for k = 1, TmpResult.cbBlockCount[j] do                                                        
--                                                                         local cbTmpBlockCount = TmpResult.cbBlockCount[j]
--                                         for z = 1, cbTakeCardCount do --nana
--                                         cbDistillCard[cbDistillCount + z] = TmpResult.cbCardData[j][(cbTmpBlockCount-(k-1)-1)*(j) + z]
--                                         end
--                                                                         cbDistillCount =  cbDistillCount + cbTakeCardCount
--                                                                         --提取完成
--                                                                         if( cbDistillCount == cbTakeCardCount*cbLineCount )then
--                                             break
--                                         end
--                                                                 end
--                                                         end
--                                                 end

--                                                 --提取完成
--                                                 if( cbDistillCount == cbTakeCardCount*cbLineCount )then
--                                 break
--                             end
--                         end

--                                         --提取完成
--                                         if( cbDistillCount == cbTakeCardCount*cbLineCount )then
--                                                 --复制带牌
--                                                 local cbCount = pSearchCardResult.cbCardCount[cbResultIndex + 1]
--                             for zz = 1, cbDistillCount do -- nana
--                                      pSearchCardResult.cbResultCard[cbResultIndex + 1][cbCount  + zz] = cbDistillCard[zz]
--                             end
--                                                 --pSearchCardResult.cbResultCard[cbResultIndex + 1][cbCount  + 1] = cbDistillCard
--                                                 pSearchCardResult.cbCardCount[cbResultIndex + 1] = pSearchCardResult.cbCardCount[cbResultIndex + 1] + cbDistillCount
                                        
--                                         --否则删除连牌
--                                         else
                                        
--                                                 bAllDistill = false
--                                                 pSearchCardResult.cbCardCount[cbResultIndex + 1] = 0
--                                         end
--                                 end

--                                 --整理组合
--                                 if( not bAllDistill )then
--                                         pSearchCardResult.cbSearchCount = cbResultCount
--                                         cbResultCount = 0
--                                         for i = 1, pSearchCardResult.cbSearchCount do
--                                                 if( pSearchCardResult.cbCardCount ~=  0 )then
--                                                         tmpSearchCardResult.cbCardCount[cbResultCount + 1] = pSearchCardResult.cbCardCount
--                                                         tmpSearchCardResult.cbResultCard[cbResultCount + 1] = clone(pSearchCardResult.cbResultCard)
--                                                         cbResultCount = cbResultCount + 1
--                                                 end
--                                         end
--                                         tmpSearchCardResult.cbSearchCount = cbResultCount
--                                         pSearchCardResult = tmpSearchCardResult
--                                 end
--                         end
--                 end
--     elseif cbTurnOutType == CMD_LAND.CT_FOUR_TAKE_ONE or cbTurnOutType == CMD_LAND.CT_FOUR_TAKE_TWO then
--             --四带两单
--             --四带两双
--                 local cbTakeCount = 2
--         if cbTurnOutType == CMD_LAND.CT_FOUR_TAKE_ONE then
--             cbTakeCount = 1
--         end

--                 local cbTmpTurnCard = {}
--                 cbTmpTurnCard = clone(cbTurnCardData)
--                 self:SortOutCardList( cbTmpTurnCard,cbTurnCardCount )

--                 --搜索带牌
--                 cbResultCount, pSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,cbTmpTurnCard[1],4,cbTakeCount)
--         end

--     if pSearchCardResult == nil or pSearchCardResult.cbCardCount == nil then
--         pSearchCardResult.cbCardCount = {}
--         if pSearchCardResult.cbResultCard == nil then
--             pSearchCardResult.cbResultCard = {}
--         end

--         for i = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbCardCount = 0
--             if pSearchCardResult.cbResultCard == nil then
--                 pSearchCardResult.cbResultCard = {}
--                 for j = 1, CMD_LAND.MAX_COUNT do
--                     pSearchCardResult.cbResultCard[j] = 0
--                 end
--             end    
--         end
--     end

--         --搜索炸弹
--         if ((cbCardCount>= 4)and(cbTurnOutType~= CMD_LAND.CT_MISSILE_CARD))then
--                 --变量定义
--                 local cbReferCard = 0
--                 if (cbTurnOutType == CMD_LAND.CT_BOMB_CARD) then
--             cbReferCard = cbTurnCardData[1]
--         end

--                 --搜索炸弹
--                 local cbTmpResultCount, tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,cbReferCard,4)
--                 for i = 1, cbTmpResultCount do
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSearchCardResult.cbCardCount
--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = tmpSearchCardResult.cbResultCard
--                         cbResultCount = cbResultCount + 1
--                 end
--         end

--         --搜索火箭
--         if (cbTurnOutType~= CMD_LAND.CT_MISSILE_CARD and (cbCardCount>= 2) and (cbCardData[1] == 0x4F) and (cbCardData[2] == 0x4E)) then
--                 --设置结果
--                 pSearchCardResult.cbCardCount[cbResultCount + 1] = 2
--                 pSearchCardResult.cbResultCard[cbResultCount + 1][1] = cbCardData[1]
--                 pSearchCardResult.cbResultCard[cbResultCount + 1][2] = cbCardData[2]

--                 cbResultCount = cbResultCount + 1
--         end


--         pSearchCardResult.cbSearchCount = cbResultCount
--         return pSearchCardResult
-- end

-- --同牌搜索
-- function CardTypeCalculation:SearchSameCard(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCardCount)
--         --[[//搜索结果
-- struct tagSearchCardResult
-- {
--         BYTE                                                        cbSearchCount;                                                //结果数目
--         BYTE                                                        cbCardCount[CMD_LAND.MAX_COUNT];                                //扑克数目
--         BYTE                                                        cbResultCard[CMD_LAND.MAX_COUNT][CMD_LAND.MAX_COUNT];        //结果扑克
-- };]]
--     --memset(pSearchCardResult,0, sizeof(tagSearchCardResult));
--     --设置结果
--         local pSearchCardResult = {}
--     pSearchCardResult.cbSearchCount = 0
--     pSearchCardResult.cbCardCount = {}
--     pSearchCardResult.cbResultCard = {}
--     for i = 1, CMD_LAND.MAX_COUNT do
--         pSearchCardResult.cbCardCount = 0
--         pSearchCardResult.cbResultCard = {}
--         for j = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbResultCard[j] = 0
--         end       
--     end

--         local cbResultCount = 0

--         --构造扑克
--         local cbCardData = {}
--         local cbCardCount = cbHandCardCount
--         cbCardData = clone(cbHandCardData)

--         --排列扑克
--         self:SortCardList(cbCardData,cbCardCount,ST_ORDER)

--         --分析扑克
--         local AnalyseResult = {}
--         AnalyseResult = self:AnalysebCardData( cbCardData,cbCardCount)

--         local cbReferLogicValue = self:GetCardLogicValue(cbReferCard)
--     if cbReferCard == 0 then
--         cbReferLogicValue = 0
--     end
--         local cbBlockIndex = cbSameCardCount - 1
--         repeat
--                 for i = 1, AnalyseResult.cbBlockCount[cbBlockIndex + 1] do
                
--                         local cbIndex = (AnalyseResult.cbBlockCount[cbBlockIndex + 1]-(i-1)-1)*(cbBlockIndex+1)
--                         if( self:GetCardLogicValue(AnalyseResult.cbCardData[cbBlockIndex + 1][cbIndex+1]) > cbReferLogicValue )then
--                                 if( pSearchCardResult == nil ) then 
--                  return 1
--                 end

--                                 LuaProxy:ASSERT( cbResultCount < CMD_LAND.MAX_COUNT )

--                            --复制扑克 --todo:liufapu zhe li ye shi keng a 
--                -- memcpy( pSearchCardResult->cbResultCard[cbResultCount],&AnalyseResult.cbCardData[cbBlockIndex][cbIndex],
--                            --         cbSameCardCount*sizeof(BYTE) );--liufapu
--                for j = 1,  cbSameCardCount do
--                     pSearchCardResult.cbResultCard[cbResultCount + 1][j] = AnalyseResult.cbCardData[cbBlockIndex + 1][cbIndex + j]
--                end              
--                                 pSearchCardResult.cbCardCount[cbResultCount + 1] = cbSameCardCount
--                                 cbResultCount = cbResultCount + 1
--                         end
--                 end

--                 cbBlockIndex = cbBlockIndex + 1
--     until( cbBlockIndex >= 4 )

--         if( pSearchCardResult ) then
--                 pSearchCardResult.cbSearchCount = cbResultCount
--     end
--         return cbResultCount, pSearchCardResult
-- end

-- --带牌类型搜索(三带一，四带一等)
-- function CardTypeCalculation:SearchTakeCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbSameCount, cbTakeCardCount)
--         --设置结果
--         local pSearchCardResult = {}
--     pSearchCardResult.cbSearchCount = 0
--     pSearchCardResult.cbCardCount = {}
--     pSearchCardResult.cbResultCard = {}
--     for i = 1, CMD_LAND.MAX_COUNT do
--         pSearchCardResult.cbCardCount = 0
--         pSearchCardResult.cbResultCard = {}
--         for j = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbResultCard[j] = 0
--         end       
--     end
--         local cbResultCount = 0

--         --效验
--         LuaProxy:ASSERT( cbSameCount == 3 or cbSameCount == 4 )
--         LuaProxy:ASSERT( cbTakeCardCount == 1 or cbTakeCardCount == 2 )
--         if( cbSameCount ~=  3 and cbSameCount ~=  4 )then
--                 return cbResultCount,pSearchCardResult
--     end
--         if( cbTakeCardCount ~=  1 and cbTakeCardCount ~=  2 )then
--                 return cbResultCount, pSearchCardResult
--     end

--         --长度判断
--         if( cbSameCount == 4 and cbHandCardCount<cbSameCount+cbTakeCardCount*2 or
--                 cbHandCardCount < cbSameCount+cbTakeCardCount )then
--                 return cbResultCount, pSearchCardResult
--     end

--         --构造扑克
--         local cbCardData = {}
--         local cbCardCount = cbHandCardCount
--         cbCardData = clone(cbHandCardData)
--         --排列扑克
--         self:SortCardList(cbCardData, cbCardCount, ST_ORDER)

--         --搜索同张
--         local SameCardResult = {}
--         local cbSameCardResultCount, SameCardResult = self:SearchSameCard( cbCardData,cbCardCount,cbReferCard,cbSameCount)

--         if( cbSameCardResultCount > 0 )then
--                 --分析扑克
--                 local AnalyseResult = {}
--                 AnalyseResult = self:AnalysebCardData(cbCardData, cbCardCount)

--                 --需要牌数
--                 local cbNeedCount = cbSameCount + cbTakeCardCount
--                 if( cbSameCount == 4 )then 
--             cbNeedCount =  cbNeedCount + cbTakeCardCount
--         end

--                 --提取带牌
--                 for i = 1, cbSameCardResultCount do
--                         local bMerge = false

--                         for j = cbTakeCardCount - 1, 4 - 1 do
--                                 for k = 0, AnalyseResult.cbBlockCount[j + 1] - 1 do
--                                         --从小到大
--                                         local cbIndex = (AnalyseResult.cbBlockCount[j + 1]-k-1)*(j+1)

--                                         --过滤相同牌
--                     while true do
--                         if( self:GetCardValue(SameCardResult.cbResultCard[1])  == 
--                                                 self:GetCardValue(AnalyseResult.cbCardData[j + 1][cbIndex + 1]) )then
--                             break
--                         end
--                         --复制带牌
--                                             local cbCount = SameCardResult.cbCardCount
--                         --memcpy(&SameCardResult.cbResultCard[cbCount], &AnalyseResult.cbCardData[j][cbIndex],
--                                                 --sizeof(BYTE)*cbTakeCardCount);
--                         for index = 1, cbTakeCardCount do
--                             SameCardResult.cbResultCard[cbCount + index] = clone(AnalyseResult.cbCardData[j + 1][cbIndex + index])
--                         end

--                                             SameCardResult.cbResultCard[cbCount + 1] = AnalyseResult.cbCardData[j + 1][cbIndex + 1]
        
--                                             SameCardResult.cbCardCount = SameCardResult.cbCardCount + cbTakeCardCount

--                                             if( SameCardResult.cbCardCount < cbNeedCount ) then 
--                             break
--                         end

--                                             --if( pSearchCardResult == nil ) then 
--                          --   return 1
--                         --end
--                                             --复制结果
--                         --memcpy(pSearchCardResult->cbResultCard[cbResultCount], SameCardResult.cbResultCard,
--                                                 --sizeof(BYTE)*SameCardResult.cbCardCount);
--                                             pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(SameCardResult.cbResultCard)
--                                             pSearchCardResult.cbCardCount[cbResultCount + 1] = SameCardResult.cbCardCount
--                                             cbResultCount = cbResultCount + 1

--                                             bMerge = true
--                         break --while xunhuan
--                     end
--                     if bMerge then
--                         break--下一组合 --k xunhuan
--                     end
                                        
--                                 end

--                                 if( bMerge )then
--                     break --j xunhuan
--                 end
--                         end
--                 end --for i xunhuan
--         end --if

--         if( pSearchCardResult )then
--                 pSearchCardResult.cbSearchCount = cbResultCount
--     end
--         return cbResultCount,pSearchCardResult
-- end

-- --连牌搜索
-- function CardTypeCalculation:SearchLineCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbBlockCount, cbLineCount)
--         --设置结果
--         local pSearchCardResult = {}
--     --初始化
--     pSearchCardResult.cbSearchCount = 0
--     pSearchCardResult.cbCardCount = {}
--     pSearchCardResult.cbResultCard = {}
--     for i = 1, CMD_LAND.MAX_COUNT do
--         pSearchCardResult.cbCardCount = 0
--         pSearchCardResult.cbResultCard = {}
--         for j = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbResultCard[j] = 0
--         end       
--     end
--         local cbResultCount = 0

--         --定义变量
--         local cbLessLineCount = 0
--         if( cbLineCount == 0 )then
--                 if( cbBlockCount == 1 )then
--                         cbLessLineCount = 5
--                 elseif( cbBlockCount == 2 )then
--                         cbLessLineCount = 3
--                 else 
--             cbLessLineCount = 2
--         end
--         else 
--         cbLessLineCount = cbLineCount
--     end

--         local cbReferIndex = 2
--         if( cbReferCard ~=  0 )then
--                 --LuaProxy:ASSERT( self:GetCardLogicValue(cbReferCard) - cbLessLineCount >= 2 )
--                 cbReferIndex = self:GetCardLogicValue(cbReferCard) - cbLessLineCount + 1
--         end
--         --超过A
--         if( cbReferIndex + cbLessLineCount > 14 )then
--         return cbResultCount, pSearchCardResult
--     end

--         --长度判断
--         if( cbHandCardCount < cbLessLineCount*cbBlockCount )then
--         return cbResultCount, pSearchCardResult
--     end
--         --构造扑克
--         local cbCardData = {}
--         local cbCardCount = cbHandCardCount
--         cbCardData = clone(cbHandCardData)

--         --排列扑克
--         self:SortCardList(cbCardData, cbCardCount, ST_ORDER)

--         --分析扑克
--         local Distributing = {}
--         Distributing = self:AnalysebDistributing(cbCardData,cbCardCount)

--         --搜索顺子
--         local cbTmpLinkCount = 0
--         local cbValueIndex = 0
--     local tempValueIndex = 0--临时变量，因为cbValueIndex经过for循环之后还是0，add by liufapu, yi da keng

--     for cbValueIndex = cbReferIndex, 12 do
--         tempValueIndex = cbValueIndex
--         local isContinue = false
--                 --继续判断 cbIndexCount = 5
--                 if ( Distributing.cbDistributing[cbValueIndex + 1][cbIndexCount + 1] < cbBlockCount )then
--             while true do
--                 if( cbTmpLinkCount < cbLessLineCount )then
--                             cbTmpLinkCount = 0
--                     isContinue = true
--                     break
--                 else
--                     cbValueIndex = cbValueIndex - 1
--                 end
--                 break
--             end                                
--                 else 
--             print("22222cbTmpLinkCount = ", cbTmpLinkCount)
--                         cbTmpLinkCount = cbTmpLinkCount + 1
--                         --寻找最长连
--             while true do
--                 if(cbLineCount == 0)then
--                     isContinue = true
--                     break
--                 end
--                 break
--             end
--                 end

--         if not isContinue then
--             if( cbTmpLinkCount >=  cbLessLineCount )then
--                             if( pSearchCardResult == nil ) then 
--                     print("return 1, pSearchCardResult ")
--                     return 1, pSearchCardResult  
--                 end

--                            -- LuaProxy:ASSERT(cbResultCount < pSearchCardResult.cbCardCount)

--                             --复制扑克
--                             local cbCount = 0
--                             for cbIndex = cbValueIndex + 1 - cbTmpLinkCount, cbValueIndex do
--                                     local cbTmpCount = 0
--                                     for cbColorIndex = 0, 4 - 1 do
--                                             for cbColorCount = 0, Distributing.cbDistributing[cbIndex + 1][3 - cbColorIndex + 1] - 1 do
--                             if pSearchCardResult.cbResultCard[cbResultCount + 1] then
--                                pSearchCardResult.cbResultCard[cbResultCount + 1][cbCount + 1] = self:MakeCardData(cbIndex, 3 - cbColorIndex)
--                             end
                                                   
--                             cbCount = cbCount + 1
--                             cbTmpCount = cbTmpCount + 1
--                            -- while true do
--                              if( cbTmpCount == cbBlockCount ) then
--                                 break
--                            -- end
--                            -- break
--                             end
                                                   
--                                             end
--                        -- while true do
--                          if( cbTmpCount == cbBlockCount ) then
--                             break
--                       --  end
--                        -- break
--                         end
                                           
--                                     end
--                             end

--                             --设置变量
--                 if pSearchCardResult.cbCardCount[cbResultCount + 1] then
--                  pSearchCardResult.cbCardCount[cbResultCount + 1] = cbCount
--                              cbResultCount = cbResultCount + 1
--                 end
                           

--                             if( cbLineCount ~=  0 )then                        
--                                     cbTmpLinkCount = cbTmpLinkCount - 1                        
--                             else 
--                                     cbTmpLinkCount = 0
--                             end
--                     end
--         end        
--         end

--     --add by liufapu,因为cbValueIndex = 12时  后面还cbValueIndex++ 了一次
--     tempValueIndex = tempValueIndex + 1
--         --特殊顺子(带A的顺子)
--         if( cbTmpLinkCount >= (cbLessLineCount - 1) and (tempValueIndex == 13) )then
--                 if( Distributing.cbDistributing[1][cbIndexCount + 1] >=  cbBlockCount or
--                         cbTmpLinkCount >=  cbLessLineCount )then
--                         if( pSearchCardResult == nil ) then 
--                 return 1, pSearchCardResult
--             end

--                         --LuaProxy:ASSERT( cbResultCount < CMD_LAND.MAX_COUNT )

--                         --复制扑克
--                         local cbCount = 0
--                         local cbTmpCount = 0
--                         for cbIndex = tempValueIndex - cbTmpLinkCount, 12 do
--                                 cbTmpCount = 0
--                                 for cbColorIndex = 0, 4 - 1 do
--                                         for cbColorCount = 0, Distributing.cbDistributing[cbIndex + 1][3 - cbColorIndex + 1] - 1 do                                    
--                                                 if pSearchCardResult.cbResultCard[cbResultCount + 1] then
--                                                  pSearchCardResult.cbResultCard[cbResultCount + 1][cbCount + 1] = self:MakeCardData(cbIndex, 3 - cbColorIndex)
--                         cbCount = cbCount + 1
--                         cbTmpCount = cbTmpCount + 1
--                                                 end

--                                                 if( cbTmpCount == cbBlockCount )then
--                             break
--                         end
--                                         end
--                                         if( cbTmpCount == cbBlockCount ) then
--                         break
--                     end
--                                 end
--                         end
--                         --复制A
--                         if( Distributing.cbDistributing[1][cbIndexCount + 1] >=  cbBlockCount )then
--                                 cbTmpCount = 0
--                                 for cbColorIndex = 0, 4 - 1 do
--                                         for cbColorCount = 0, Distributing.cbDistributing[1][3-cbColorIndex + 1] - 1 do        
--                     if pSearchCardResult.cbResultCard[cbResultCount + 1] then
--                             pSearchCardResult.cbResultCard[cbResultCount + 1][cbCount + 1] = self:MakeCardData(0,3-cbColorIndex)
--                         cbCount = cbCount + 1
--                         cbTmpCount =cbTmpCount + 1
--                     end                                    
                                        
--                                                 if( cbTmpCount == cbBlockCount ) then
--                             break
--                         end
--                                         end
--                                         if( cbTmpCount == cbBlockCount ) then 
--                         break
--                     end
--                                 end
--                         end

--                         --设置变量
--             if pSearchCardResult.cbCardCount[cbResultCount + 1] then
--             pSearchCardResult.cbCardCount[cbResultCount + 1] = cbCount
--                         cbResultCount = cbResultCount + 1
--             end
                        
--                 end
--         end

--         if( pSearchCardResult )then
--                 pSearchCardResult.cbSearchCount = cbResultCount
--     end
--         return cbResultCount, pSearchCardResult
-- end

-- --搜索飞机(暂时没用到的方法)
-- function CardTypeCalculation:SearchThreeTwoLine(cbHandCardData, cbHandCardCount)
--         --设置结果
--     local pSearchCardResult = {}
--     pSearchCardResult.cbSearchCount = 0
--     pSearchCardResult.cbCardCount = {}
--     pSearchCardResult.cbResultCard = {}
--     local tmpSingleWing = { }
--     tmpSingleWing.cbSearchCount = 0
--     tmpSingleWing.cbResultCard = { }
--     tmpSingleWing.cbCardCount = { }
--     local tmpDoubleWing = { }
--     tmpDoubleWing.cbSearchCount = 0
--     tmpDoubleWing.cbResultCard = { }
--     tmpDoubleWing.cbCardCount = { }
--     for i = 1, CMD_LAND.MAX_COUNT do
--         pSearchCardResult.cbCardCount = 0
--         pSearchCardResult.cbResultCard = { }

--         tmpSingleWing.cbCardCount = 0
--         tmpSingleWing.cbResultCard = { }

--         tmpDoubleWing.cbCardCount = 0
--         tmpDoubleWing.cbResultCard = { }
--         for j = 1, CMD_LAND.MAX_COUNT do
--             pSearchCardResult.cbResultCard[j] = 0
--             tmpSingleWing.cbResultCard[j] = 0
--             tmpDoubleWing.cbResultCard[j] = 0
--         end
--     end
--     -- 变量定义
--     local tmpSearchResult = { }
--     -- local tmpSingleWing = {}
--     -- local tmpDoubleWing = {}
--     local cbTmpResultCount = 0



--     -- 搜索连牌
--     cbTmpResultCount, tmpSearchResult = self:SearchLineCardType(cbHandCardData, cbHandCardCount, 0, 3, 0)

--     if (cbTmpResultCount > 0) then
--         -- 提取带牌
--         for i = 1, cbTmpResultCount do
--             -- 变量定义
--             local cbTmpCardData = { }
--             local cbTmpCardCount = cbHandCardCount

--             -- 不够牌
--             if (cbHandCardCount - tmpSearchResult.cbCardCount < math.floor(tmpSearchResult.cbCardCount / 3)) then
--                 local cbNeedDelCount = 3
--                 while (cbHandCardCount + cbNeedDelCount - tmpSearchResult.cbCardCount < math.floor(tmpSearchResult.cbCardCount - cbNeedDelCount) / 3) do
--                     cbNeedDelCount = cbNeedDelCount + 3
--                 end
--                 -- 不够连牌
--                 while true do
--                     if (math.floor((tmpSearchResult.cbCardCount - cbNeedDelCount) / 3) < 2) then
--                         break
--                         -- 废除连牌
--                     end
--                     -- 拆分连牌
--                     self:RemoveCard(tmpSearchResult.cbResultCard, cbNeedDelCount, tmpSearchResult.cbResultCard,
--                     tmpSearchResult.cbCardCount)
--                     tmpSearchResult.cbCardCount = tmpSearchResult.cbCardCount - cbNeedDelCount
--                     break
--                 end

--             end

--             -- if( pSearchCardResult == nil ) then
--             --    return 1
--             -- end

--             -- 删除连牌
--             cbTmpCardData = clone(cbHandCardData)
--             -- LuaProxy:ASSERT(self:RemoveCard(tmpSearchResult.cbResultCard, tmpSearchResult.cbCardCount,
--             -- cbTmpCardData,cbTmpCardCount ) )
--             cbTmpCardCount = cbTmpCardCount - tmpSearchResult.cbCardCount

--             -- 组合飞机
--             local cbNeedCount = math.floor(tmpSearchResult.cbCardCount / 3)
--             -- LuaProxy:ASSERT( cbNeedCount <=  cbTmpCardCount )
--             tmpSingleWing.cbSearchCount = tmpSingleWing.cbSearchCount + 1
--             local cbResultCount = tmpSingleWing.cbSearchCount
--             tmpSingleWing.cbResultCard[cbResultCount + 1] = clone(tmpSearchResult.cbResultCard)

--             tmpSingleWing.cbResultCard[cbResultCount + 1][tmpSearchResult.cbCardCount] = clone(cbTmpCardData[cbTmpCardCount - cbNeedCount + 1])
--             tmpSingleWing.cbCardCount = tmpSearchResult.cbCardCount + cbNeedCount

--             -- 不够带翅膀
--             if (cbTmpCardCount < math.floor(tmpSearchResult.cbCardCount / 3 * 2)) then
--                 local cbNeedDelCount = 3
--                 while (cbTmpCardCount + cbNeedDelCount - tmpSearchResult.cbCardCount < math.floor((tmpSearchResult.cbCardCount - cbNeedDelCount) / 3 * 2)) do
--                     cbNeedDelCount = cbNeedDelCount + 3
--                 end
--                 -- 不够连牌
--                 while true do
--                     if (math.floor((tmpSearchResult.cbCardCount - cbNeedDelCount) / 3) < 2) then
--                         break
--                         -- 废除连牌
--                     end
--                     -- 拆分连牌
--                     self:RemoveCard(tmpSearchResult.cbResultCard, cbNeedDelCount, tmpSearchResult.cbResultCard,
--                     tmpSearchResult.cbCardCount)
--                     tmpSearchResult.cbCardCount = tmpSearchResult.cbCardCount - cbNeedDelCount

--                     -- 重新删除连牌
--                     cbTmpCardData = clone(cbHandCardData)
--                     -- LuaProxy:ASSERT(self:RemoveCard(tmpSearchResult.cbResultCard, tmpSearchResult.cbCardCount,
--                     --  cbTmpCardData,cbTmpCardCount ) )
--                                     cbTmpCardCount = cbHandCardCount-tmpSearchResult.cbCardCount
--                     break
--                 end                
--                         end

--                         --分析牌
--                         local  TmpResult = {}
--                         TmpResult = self:AnalysebCardData(cbTmpCardData,cbTmpCardCount)

--                         --提取翅膀
--                         local cbDistillCard = {}
--                         local cbDistillCount = 0
--                         local cbLineCount = math.floor(tmpSearchResult.cbCardCount/3)
--                         for j = 1, 4 - 1 do
--                                 if( TmpResult.cbBlockCount[j + 1] > 0 )then
                                
--                                         if( j+1 == 2 and TmpResult.cbBlockCount[j + 1] >=  cbLineCount )then
                                        
--                                                 local cbTmpBlockCount = TmpResult.cbBlockCount[j+ 1]
--                                                 cbDistillCard = clone(TmpResult.cbCardData[j + 1][(cbTmpBlockCount-cbLineCount)*(j+1) + 1])
--                                                 cbDistillCount = (j+1)*cbLineCount
--                                                 break
                                        
--                                         else
                                        
--                                                 for k = 0, TmpResult.cbBlockCount[j + 1] - 1 do
                                                
--                                                         local cbTmpBlockCount = TmpResult.cbBlockCount[j + 1]
--                             --todo:liufapu
--                             --memcpy( &cbDistillCard[cbDistillCount],&TmpResult.cbCardData[j][(cbTmpBlockCount-k-1)*(j+1)],
--                                                         --        sizeof(BYTE)*2 );
--                             cbDistillCard[cbDistillCount + 1] = clone(TmpResult.cbCardData[j + 1][(cbTmpBlockCount - k - 1) *(j + 1) + 1])
--                             cbDistillCard[cbDistillCount + 2] = clone(TmpResult.cbCardData[j + 1][(cbTmpBlockCount - k - 1) *(j + 1) + 2])
--                                                         cbDistillCount =  cbDistillCount + 2

--                                                         --提取完成
--                                                         if( cbDistillCount == 2*cbLineCount ) then
--                                 break
--                             end
--                                                 end
--                                         end
--                                 end

--                                 --提取完成
--                                 if( cbDistillCount == 2*cbLineCount ) then
--                     break
--                 end
--                         end

--                         --提取完成
--                         if( cbDistillCount == 2*cbLineCount )then
--                                 --复制翅膀          
--                                 cbResultCount = tmpDoubleWing.cbSearchCount
--                 tmpDoubleWing.cbSearchCount = tmpDoubleWing.cbSearchCount + 1
--                                 tmpDoubleWing.cbResultCard[cbResultCount + 1] = clone(tmpSearchResult.cbResultCard)

--                                 tmpDoubleWing.cbResultCard[cbResultCount + 1][tmpSearchResult.cbCardCount] = clone(cbDistillCard)
--                                 tmpDoubleWing.cbCardCount = tmpSearchResult.cbCardCount+cbDistillCount
--                         end
--                 end

--                 --复制结果
--                 for i = 1,tmpDoubleWing.cbSearchCount do
--                     pSearchCardResult.cbSearchCount = pSearchCardResult.cbSearchCount + 1
--                         local cbResultCount = pSearchCardResult.cbSearchCount

--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpDoubleWing.cbResultCard)
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpDoubleWing.cbCardCount
--                 end
--                 for i = 1, tmpSingleWing.cbSearchCount do
--             pSearchCardResult.cbSearchCount =pSearchCardResult.cbSearchCount + 1
--                         local cbResultCount = pSearchCardResult.cbSearchCount

--                         pSearchCardResult.cbResultCard[cbResultCount + 1] = clone(tmpSingleWing.cbResultCard)
--                         pSearchCardResult.cbCardCount[cbResultCount + 1] = tmpSingleWing.cbCardCount
--                 end
--         end
--     local result = pSearchCardResult.cbSearchCount
--     if pSearchCardResult == nil then
--         result = 0
--     end
--     return result, pSearchCardResult
-- end

-- --获取数值
-- function CardTypeCalculation:GetCardValue(cbCardData) 
--     return bit.band(cbCardData,CMD_LAND.MASK_VALUE)
-- end
-- --获取花色
-- function CardTypeCalculation:GetCardColor(cbCardData) 
--     return bit.band(cbCardData,CMD_LAND.MASK_COLOR)
-- end


-- return CardTypeCalculation

-- --endregion