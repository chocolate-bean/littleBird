local SoundManager = class("SoundManager")

function SoundManager:ctor()
    self.loopSound = {}
    self.currentBGMName = nil
    self.SoundEffectPrefab = nil
end

-- 播放背景音乐
function SoundManager:PlayBGM(name)
    
    if name then
        self:ChangeBGM(name)
    else
        self:ChangeBGM("bgMusic")
    end
end

-- 停止背景音乐
function SoundManager:StopBGM()
    
    SoundMgr:StopBGM()
end

-- 暂停背景音乐
function SoundManager:PauseBGM()
    
    SoundMgr:PauseBGM()
end

-- 切换
function SoundManager:ChangeBGM(name)
    if self.currentBGMName and self.currentBGMName == name then
        return
    else
        self.currentBGMName = name
        SoundMgr:ChangeBGM(name)
    end
end

-- 播放指定音效
function SoundManager:PlaySound(name)
    SoundMgr:PlaySound(name)
end

--[[
    一定要退出loop
]]
function SoundManager:PlaySoundWithNewSource(name, isLoop, doneCallback)
    SoundMgr:PlaySoundWithNewSource(name, isLoop, doneCallback)
end

function SoundManager:StopSoundWithName(name)
    SoundMgr:StopSoundWithName(name)
end

-- 打开音效
-- function SoundManager:OpenSound()
    
--     SoundMgr:OpenSound()
-- end

-- -- 关闭音效
-- function SoundManager:CloseSound()
    
--     SoundMgr:CloseSound()
-- end

-- 打开一些东西
function SoundManager:playSomething(BGMName)
    self:PlayBGM(BGMName)
end

return SoundManager