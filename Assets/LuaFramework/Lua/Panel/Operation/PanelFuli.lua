local PanelFuli = class("PanelFuli")

function PanelFuli:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelFuli" }, function(objs)
        self:initView(objs)
    end)
end

function PanelFuli:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFuli"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFuli:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelFuli:initProperties()
    self.Items = {}
end

function PanelFuli:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    for i = 1,7 do
        local item = self.view.transform:Find("Item"..i).gameObject
        self.Items[i] = item
    end

    -- 第几天
    self.day = self.view.transform:Find("Day").gameObject
    -- 进度条
    self.progressBar = self.view.transform:Find("progressBar").gameObject
    -- 进度
    self.LevelProgress = self.view.transform:Find("progressBar/Text").gameObject 
    -- 任务描述
    self.des = self.view.transform:Find("des").gameObject
    -- 剩余时间
    self.Time = self.view.transform:Find("Time").gameObject

    -- 去完成
    self.btnGoto = self.view.transform:Find("btnGoto").gameObject
    -- 去领取
    self.btnReady = self.view.transform:Find("btnReady").gameObject
end

function PanelFuli:initUIDatas()
    http.checkLoginMission(
        function(callData)
            
            if callData then
                dump(callData)
                self:refashPanel(callData)
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelFuli:refashPanel(data)
    
    local day = data.days
    self.day:setText(T("第")..day..T("天"))

    -- 进度
    local current = tonumber(data.mission.process.current) 
    local goal = tonumber(data.mission.process.goal) 
    
    if current > goal then
        current = goal
    end
    local process = ""..current.."/"..goal

    self.progressBar:GetComponent("Slider").value = current/goal
    self.LevelProgress:setText(process)

    self.des:setText(data.mission.title)

    self.lastTime = data.left_time
    self:onTimerStart()
    local time = formatTimerForDay(self.lastTime)
    self.Time:setText(time)

    if tonumber(data.mission.status) == 1 then
        if current >= goal then
            self.btnReady:addButtonClick(buttonSoundHandler(self, function()
                -- 领取
                http.receiveLoginMission(
                    data.mission.id,
                    data.mission.mission_type,
                    function(callData)
                        if callData and callData.flag == 1 then
                            self.btnReady:SetActive(false)
                            GameManager.UserData.money = callData.latest_money
                            GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                            GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
                        else
                            GameManager.TopTipManager:showTopTip(T("领取失败"))
                        end
                    end,
                    function(callData)
                        GameManager.TopTipManager:showTopTip(T("领取失败"))
                    end
                )
            end), false)
            self.btnReady:SetActive(true)
        else
            self.btnGoto:addButtonClick(buttonSoundHandler(self, function()
                -- 去完成
                self:onClose()
                GameManager.ActivityJumpConfig:Jump(data.mission.action_name)
            end), false)
            self.btnGoto:SetActive(true)
        end
    else
    end

    for i = 1,7 do
        print(i)
        if i == day then
            local light = self.Items[i].transform:Find("Light").gameObject
            light:SetActive(true)
        end

        if i < day then
            local Ready = self.Items[i].transform:Find("Ready").gameObject
            Ready:SetActive(true)
        end

        local Num = self.Items[i].transform:Find("Num").gameObject
        Num:setText(data.reward[i].num)
        local Name = self.Items[i].transform:Find("Name").gameObject
        Name:setText(data.reward[i].reward)
        local Icon = self.Items[i].transform:Find("Icon").gameObject
        Icon:setSprite("Images/SenceMainHall/fuliItem"..data.reward[i].rtype)
    end
end

function PanelFuli:onTimerStart()
    
    if self.timer then
		self:onTimerEnd()
    end

    self.timer = Timer.New(function()
        self:onTimer()
    end,1,-1,true)
    self.timer:Start()
end

function PanelFuli:onTimer()
    self.lastTime = self.lastTime - 1

    if self.lastTime == 0 then
        self.Time:setText(T("0天0时0分"))
        self:onTimerEnd()
    else
        local time = formatTimerForDay(self.lastTime)
        self.Time:setText(time)
    end
end

function PanelFuli:onTimerEnd()
    
    if self.timer then
		self.timer:Stop()
	end
end

function PanelFuli:onClose()
    -- 这里最好写一个控制器控制
    self:onTimerEnd()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelFuli