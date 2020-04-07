local SlotsLineManager = class("SlotsLineManager")


SlotsLineManager.LINE_CONFIG = {
    {2, 2, 2, 2, 2},
    {1, 1, 1, 1, 1},
    {3, 3, 3, 3, 3},
    {1, 2, 3, 2, 1},
    {3, 2, 1, 2, 3},
    {1, 1, 2, 3, 3},
    {3, 3, 2, 1, 1},
    {2, 3, 2, 1, 2},
    {2, 1, 2, 3, 2},
}

function SlotsLineManager:ctor()
    
end


function SlotsLineManager:getLineConfig(index)
    if 1 <= index or index <= #SlotsLineManager.LINE_CONFIG then
        return SlotsLineManager.LINE_CONFIG[index]
    end
end

return SlotsLineManager