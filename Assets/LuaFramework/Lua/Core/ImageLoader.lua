local ImageLoader = class("ImageLoader")

ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.CACHE_TYPE_IMG = "CACHE_TYPE_IMG"

function ImageLoader:ctor()
    self.spriteCache = {}
end

function ImageLoader:loadImage(url, callback)
    if url =="" or not url then
        print("图片url 不对")
        return
    end
    self:addJob_(url,callback,ImageLoader.CACHE_TYPE_NONE)
end

function ImageLoader:loadAndCacheImage(url, callback)
    if url =="" or not url then
        print("图片url 不对")
        return
    end
    self:addJob_(url,callback,ImageLoader.CACHE_TYPE_IMG)
end

function ImageLoader:loadPlayerIconToNodeWithParams(params)
    
    local url = params.url
    local sex = params.sex
    local callback = params.callback

    local getDefultIcon = function()
        
        if sex == 1 then
            return UIHelper.LoadSprite("Images/common/avatar_big_male")
        else
            return UIHelper.LoadSprite("Images/common/avatar_big_female")
        end
    end

    if self.spriteCache[url] then
        callback(self.spriteCache[url])
        return
    end

    local sprite = getDefultIcon()
    callback(sprite)    
    -- 如果url合法将根绝url加载头像
    if not (url == nil or url == "" or type(url) == "number")  then
        self:loadAndCacheImage(url,function(success,sprite)
            
            if success and sprite then
                local sprite = sprite
                self.spriteCache[url] = sprite
                callback(sprite)
            else
                local sprite = getDefultIcon()
                callback(sprite)
            end
        end)
    end
end

function ImageLoader:addJob_(url,callback,type)
    -- 这个有未知的bug，下个版本再说吧
    if type == ImageLoader.CACHE_TYPE_NONE then
        wwwMgr:LoadImage(url,callback)
    elseif type == ImageLoader.CACHE_TYPE_IMG then
        wwwMgr:LoadAndCacheImage(url,callback,true)
    end
end

function ImageLoader:getVipFrame(VipLevel)
    VipLevel = tonumber(VipLevel)
    if VipLevel and VipLevel ~= 0 then
        return UIHelper.LoadSprite("Images/SenceMainHall/Frame/v"..VipLevel)
    else
        return UIHelper.LoadSprite("Images/common/transparent")
    end
end

function ImageLoader:loadImageWithCoroutine(url, callback, type)
    local hash = crypto.md5(url)
    local path = UnityEngine.Application.persistentDataPath.."/"..hash..".png"
    if io.exists(path) then
        coroutine.start(function ()
            local www = WWW("file:///"..path)
            coroutine.www(www)
            if www.error == nil then
                local sprite = ImageLoaderHelper.GetSpriteByTex(www.texture)
                callback(sprite ~= nil,sprite)
            else
                callback(false,nil)
            end
        end)
    else
        coroutine.start(function ()
            local www = WWW(url)
            coroutine.www(www)
            if www.error == nil then
                local sprite = ImageLoaderHelper.GetSpriteByTex(www.texture)

                if type == ImageLoader.CACHE_TYPE_IMG then
                    ImageLoaderHelper.SaveTexByPath(www.texture,path)
                end

                callback(sprite ~= nil,sprite)
            else
                callback(false,nil)
            end
        end)
    end
end

-- 这个是只给ShopPanel和AttirePanel用的，别问我为什么，我也很烦
function ImageLoader:loadImageOnlyShop(url, callback)
    
    if url =="" or not url then
        print("图片url 不对")
        return
    end

    self:loadImageWithCoroutine(url, callback, ImageLoader.CACHE_TYPE_IMG)
end

-- 这个是只给RankPanel使用的，别问我为什么，我也很烦
function ImageLoader:loadIconOnlyRank(params)
    
    local url = params.url
    local sex = params.sex
    local callback = params.callback

    local getDefultIcon
    getDefultIcon = function()
        
        if sex == 1 then
            return UIHelper.LoadSprite("Images/common/avatar_big_male")
        else
            return UIHelper.LoadSprite("Images/common/avatar_big_female")
        end
    end

    -- 如果url合法将根据url加载头像
    if url == nil or url == "" or type(url) == "number" then
        local sprite = getDefultIcon()
        callback(sprite)
    -- 否则从本地加载头像
    else
        self:loadImageWithCoroutine(url,function(success,sprite)
            
            if success then
                local sprite = sprite
                callback(sprite)
            else
                local sprite = getDefultIcon()
                callback(sprite)
            end
        end)
    end
end

return ImageLoader