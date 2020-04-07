--
-- Author: zhangyibc@outlook.com
-- Date: 2018-5-3
--

-- ┏┓　　　┏┓
-- ┏┛┻━━━━━━┛┻┓
-- ┃　　　    ┃ 　
-- ┃　　　━　 ┃
-- ┃　┳┛　┗┳　┃
-- ┃　　　　　┃
-- ┃　　┻　　 ┃
-- ┃　　　　　┃
-- ┗━┓　　　┏━┛
-- ┃　　　┃ 神兽保佑　　　　　　　　
-- ┃　　　┃ 代码无BUG！
-- ┃　　　┗━━━━━━━┓
-- ┃　　　　　　　┣┓
-- ┃　　　　　　　┏┛
-- ┗┓┓┏━━━━━━━━┳┓┏┛
--  ┃┫┫　       ┃┫┫
--  ┗┻┛　       ┗┻┛

--[[                                                                   
              .,,       .,:;;iiiiiiiii;;:,,.     .,,                   
            rGB##HS,.;iirrrrriiiiiiiiiirrrrri;,s&##MAS,                
           r5s;:r3AH5iiiii;;;;;;;;;;;;;;;;iiirXHGSsiih1,               
              .;i;;s91;;;;;;::::::::::::;;;;iS5;;;ii:                  
            :rsriii;;r::::::::::::::::::::::;;,;;iiirsi,               
         .,iri;;::::;;;;;;::,,,,,,,,,,,,,..,,;;;;;;;;iiri,,.           
      ,9BM&,            .,:;;:,,,,,,,,,,,hXA8:            ..,,,.       
     ,;&@@#r:;;;;;::::,,.   ,r,,,,,,,,,,iA@@@s,,:::;;;::,,.   .;.      
      :ih1iii;;;;;::::;;;;;;;:,,,,,,,,,,;i55r;;;;;;;;;iiirrrr,..       
     .ir;;iiiiiiiiii;;;;::::::,,,,,,,:::::,,:;;;iiiiiiiiiiiiri         
     iriiiiiiiiiiiiiiii;;;::::::::::::::::;;;iiiiiiiiiiiiiiiir;        
    ,riii;;;;;;;;;;;;;:::::::::::::::::::::::;;;;;;;;;;;;;;iiir.       
    iri;;;::::,,,,,,,,,,:::::::::::::::::::::::::,::,,::::;;iir:       
   .rii;;::::,,,,,,,,,,,,:::::::::::::::::,,,,,,,,,,,,,::::;;iri       
   ,rii;;;::,,,,,,,,,,,,,:::::::::::,:::::,,,,,,,,,,,,,:::;;;iir.      
   ,rii;;i::,,,,,,,,,,,,,:::::::::::::::::,,,,,,,,,,,,,,::i;;iir.      
   ,rii;;r::,,,,,,,,,,,,,:,:::::,:,:::::::,,,,,,,,,,,,,::;r;;iir.      
   .rii;;rr,:,,,,,,,,,,,,,,:::::::::::::::,,,,,,,,,,,,,:,si;;iri       
    ;rii;:1i,,,,,,,,,,,,,,,,,,:::::::::,,,,,,,,,,,,,,,:,ss:;iir:       
    .rii;;;5r,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,sh:;;iri        
     ;rii;:;51,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.:hh:;;iir,        
      irii;::hSr,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,sSs:;;iir:         
       irii;;:iSSs:.,,,,,,,,,,,,,,,,,,,,,,,,,,,..:135;:;;iir:          
        ;rii;;:,r535r:...,,,,,,,,,,,,,,,,,,..,;sS35i,;;iirr:           
         :rrii;;:,;1S3Shs;:,............,:is533Ss:,;;;iiri,            
          .;rrii;;;:,;rhS393S55hh11hh5S3393Shr:,:;;;iirr:              
            .;rriii;;;::,:;is1h555555h1si;:,::;;;iirri:.               
              .:irrrii;;;;;:::,,,,,,,,:::;;;;iiirrr;,                  
                 .:irrrriiiiii;;;;;;;;iiiiiirrrr;,.                    
                    .,:;iirrrrrrrrrrrrrrrrri;:.                        
                         ..,:::;;;;:::,,.                             
]]--

-- 这里为了省事，懒得写更多的配置了
local PropController = class("PropController")

local isInit = false

function PropController:ctor()
    
    -- 全部道具
    self.allProp = {}
    -- 全部装扮
    self.allAttire = {}

    -- 可购买的道具
    self.canBuyProp = {}
    -- 互动道具
    self.HDDJProp = {}

    -- 可购买的装扮
    self.canBuyAttire = {}
    -- 可购买的热门装扮
    self.hotAttire = {}
    -- 可购买的节日装扮
    self.festivalAttire = {}

end

function PropController:getInit()
	return isInit
end

--退出登录时isInit置为false，清理数据
function PropController:setInit(initbool)
	isInit = initbool
end

-- 加载商品分类
function PropController:loadPropConfig(url)
    print("loadPropConfig")
    GameManager.JsonFileLoader:cacheFile(url,function (result, content)
        
        if result == true then
            local propJson = json.decode(content)
            -- dump(propJson)
            self:getAllPropData(true,propJson)
        else
            self:getAllPropData(false,nil)
        end
    end)
end

-- 分发
function PropController:getAllPropData(configSucc, data)
    print("getAllPropData")
    print(configSucc)
    if configSucc then
        -- 全部道具
        self.allProp = {}
        -- 全部装扮
        self.allAttire = {}
        -- 可购买的道具
        self.canBuyProp = {}
        -- 可购买的装扮
        self.canBuyAttire = {}
        -- 可购买的热门装扮
        self.hotAttire = {}
        -- 可购买的节日装扮
        self.festivalAttire = {}
        local prop_config = data.prop_config
        for i,data in ipairs(prop_config) do
            if tonumber(data.shop) == 1 then
                -- table.insert(self.allAttire,data)
                self.allAttire[tonumber(data.pid)] = data
                -- 可购买的装扮
                if tonumber(data.status) == 1 then
                    
                    table.insert(self.canBuyAttire,data)
                    -- 热门装扮
                    if tonumber(data.tab) == 1 then
                        
                        table.insert(self.hotAttire,data)
                    -- 节日装扮
                    elseif tonumber(data.tab) == 2 then
                        
                        table.insert(self.festivalAttire,data)
                    end
                end
            elseif tonumber(data.shop) == 2 then
                
                -- table.insert(self.allProp,data)
                self.allProp[tonumber(data.pid)] = data
                if tonumber(data.status) == 2 then
                    table.insert(self.canBuyProp,data)
                end
                if tonumber(data.prop_type) == 2 then
                    self.HDDJProp[tonumber(data.pid)] = data
                end 
            end
        end
    end
    print("111")
end

-- 加载装扮分类
function PropController:getAttireData()
    local AttireData = {}
    table.insert(AttireData,self.hotAttire)
    table.insert(AttireData,self.festivalAttire)
    table.insert(AttireData,self.canBuyAttire)
    return AttireData
end

-- 获取自身装扮分类信息
function PropController:getSelfAttireData(data)
    local AttireData = {}
    local hotAttire = {}
    local festivalAttire = {}
    local allAttire = {}

    for k,v in pairs(data) do
        local pid = tonumber(v.pid)
        local property = tonumber(v.property)
        local item = self.allAttire[pid]
        item.property = property

        table.insert(allAttire,item)
        -- 热门装扮
        if tonumber(item.tab) == 1 then
            table.insert(hotAttire,item)
        -- 节日装扮
        elseif tonumber(item.tab) == 2 then
            table.insert(festivalAttire,item)
        end
    end

    table.insert(AttireData,hotAttire)
    table.insert(AttireData,festivalAttire)
    table.insert(AttireData,allAttire)

    return AttireData
end

-- 获取pid对应的装扮信息
function PropController:getAttireDataByPid(data)
    -- dump(self.allAttire)
    return self.allAttire[data]
end

-- 获取自身装扮信息（不分类）
function PropController:getAllSelfAttireData(data)
    local AttireData = {}

    for k,v in pairs(data) do
        local pid = tonumber(v.pid)
        local property = tonumber(v.property)
        local item = self.allAttire[pid]
        item.property = property

        table.insert(AttireData,item)
    end

    return AttireData
end

-- 获取自身道具信息（不分类）（本来也没有分类）
function PropController:getAllSelfPropData(data)
    
    local PropData = {}

    for k,v in pairs(data) do
        local pid = tonumber(v.pid)
        local property = tonumber(v.property)

        local item = self.allProp[pid]

        if item then
            item.property = property
            table.insert(PropData,item)
        end
    end

    return PropData
end

-- 获取互动道具的次数
function PropController:getHDDJPropProperty(data)
    
    for k,v in pairs(data) do
        local pid = tonumber(v.pid)
        if pid == self.HDDJProp.pid then
            return tonumber(v.property)
        end
    end
end

-- 加载道具数据
function PropController:getPropData()
    return self.allProp
end

return PropController



