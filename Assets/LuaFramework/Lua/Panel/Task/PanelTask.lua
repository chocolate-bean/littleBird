local PanelTask = class("PanelTask")

function PanelTask:ctor(type)

    -- 1,大厅进来的，2,娱乐场进来的
    if type and type == 2 then
        resMgr:LoadPrefabByRes("Task", { "PanelTaskForHappy", "taskItemForHappy" }, function(objs)
            self:initView(objs)
        end)
    else
        resMgr:LoadPrefabByRes("Task", { "PanelTask", "taskItem" }, function(objs)
            self:initView(objs)
        end)
    end

end

function PanelTask:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelTask"

    self.taskItem = objs[1]

    GameManager.LoadingManager:setLoading(true, self.view)
    local timer = Timer.New(function()
        self:initProperties()
        self:initUIControls()
        self:initUIDatas()
    end,0.5,1,true)
    timer:Start() 

    Timer.New(function()
        if self.view then
            wwwMgr:StopHttp()
            GameManager.LoadingManager:setLoading(false, self.view)
        end
    end,3,1,true):Start() 

    self:show()
end

function PanelTask:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelTask:initProperties()
    self.viewItems = {}
    self.btnItems = {}
    self.redDots = {}

    self.EveryDayData = {}
end

function PanelTask:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    for i=1,1 do
        local viewItem = self.view.transform:Find("Item"..i).gameObject
        local btnItem = self.view.transform:Find("btnItem"..i).gameObject
        UIHelper.AddButtonClick(btnItem,function()
            
            GameManager.SoundManager:PlaySound("clickButton")
            self:onBtnItemClick(i)
        end)

        local redDot = self.view.transform:Find("btnItem"..i.."/redDot").gameObject
        if GameManager.UserData.redDotData then
            if GameManager.UserData.redDotData.task.index[i] then
                redDot:SetActive(true)
            end
        end

        table.insert(self.viewItems,viewItem)
        table.insert(self.btnItems,btnItem)
        table.insert(self.redDots,redDot)
    end

    -- 每日
    self.EveryDayGrid = self.view.transform:Find("Item1/List/Grid").gameObject
end

function PanelTask:initUIDatas()
    self:onBtnItemClick(1)

    self:reFashTaskList()
end

function PanelTask:reFashTaskList()
    self.EveryDayData = {}

    self:GetTaskList()
end

-- 获取好友列表
function PanelTask:GetTaskList()
    -- 获取新手任务
    -- http.getUserMissionDataNoReplace(
    --     2,
    --     function(callData)
    --         if callData and callData.flag == 1 then
    --             self.GreenHandData = callData.mission

    --             local index = 1
    --             self:DestroyTaskList(index)
    --             self:createTaskList(index)
    --         end
    --     end,
    --     function(callData)
    --     end
    -- )

    -- 获取每日任务
    http.getUserMissionDataNoReplace(
        1,
        function(callData)
            if callData and callData.flag == 1 then
                self.EveryDayData = callData.mission

                local index = 2
                self:DestroyTaskList(index)
                self:createTaskList(index)

            end
            
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end
    )
end

function PanelTask:DestroyTaskList(index)
    
    removeAllChild(self.EveryDayGrid.transform)
end

function PanelTask:createTaskList(index)
    
    local listData = self.EveryDayData
    local parent = self.EveryDayGrid.transform

    for taskIndex,taskData in ipairs(listData) do
        local item = newObject(self.taskItem)
        item.name = taskIndex
        item.transform:SetParent(parent)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local icon = item.transform:Find("icon").gameObject
        local url = taskData.icon
        GameManager.ImageLoader:loadImageOnlyShop(url,function (success, sprite)
            
            if success and sprite then
                if self.view then
                    icon:GetComponent('Image').sprite = sprite
                end
            end
        end)

        -- 任务描述
        local des = item.transform:Find("des").gameObject
        des:GetComponent("Text").text = taskData.content

        -- 进度
        local current = tonumber(taskData.process.current) 
        local goal = tonumber(taskData.process.goal) 
        
        if current > goal then
            current = goal
        end
        local process = ""..formatFiveNumber(current).."/"..formatFiveNumber(goal)

        local progressBar = item.transform:Find("progressBar").gameObject
        progressBar:GetComponent("Slider").value = current/goal

        local progressText = item.transform:Find("progressBar/Text").gameObject
        progressText:GetComponent("Text").text = process

        local rewardIcon = item.transform:Find("rewardIcon").gameObject
        local rewardText = item.transform:Find("rewardText").gameObject
        rewardIcon:setSprite("Images/SenceMainHall/task"..taskData.reward_type)

        if taskData.reward_type == 1 then
            rewardText:GetComponent("Text").text = "x"..formatFiveNumber(taskData.reward.money)
        elseif taskData.reward_type == 2 then

        elseif taskData.reward_type == 3 then
            rewardText:GetComponent("Text").text = "x"..formatFiveNumber(taskData.reward.jewel)
        end

        if taskData.status == 1 then
            if current >= goal then
                local btnReward = item.transform:Find("btnReward").gameObject
                btnReward:SetActive(true)
                UIHelper.AddButtonClick(btnReward,function(sender)
                    
                    GameManager.SoundManager:PlaySound("clickButton")
                    if taskData.reward_type == 3 then
                        if GameManager.UserData.jewelGain + tonumber(taskData.reward.jewel) > GameManager.UserData.jewelLimit then
                            local PanelDialog = import("Panel.Dialog.PanelDialog").new({
                                hasFristButton = true,
                                hasSecondButton = true,
                                hasCloseButton = false,
                                title = T("红包上限提示"),
                                text = T(string.format("达到今日领取上限%s\n请去提升VIP等级！", GameManager.UserData.jewelLimit)),
                                firstButtonCallbcak = function()
                                    self:onClose()
                                    local PanelNewVipHelper = import("Panel.Special.PanelNewVipHelper").new()
                                end,
                            })
                            return
                        end
                    end
                    self:onBtnRewardClick(sender,taskData)
                end)
            else
                if taskData.action_name == "unsatisfied" then
                    local btnWait = item.transform:Find("btnWait").gameObject
                    btnWait:SetActive(true)
                else
                    local btnGoto = item.transform:Find("btnGoto").gameObject
                    btnGoto:SetActive(true)
                    UIHelper.AddButtonClick(btnGoto,function(sender)
                        
                        GameManager.SoundManager:PlaySound("clickButton")
                        self:onBtnGotoClick(taskData.action_name)
                    end)
                end
            end
        elseif taskData.status == 0 then
            local btnReady = item.transform:Find("btnReady").gameObject
            btnReady:SetActive(true)
        end
    end
end

function PanelTask:onBtnItemClick(index)
    
    -- for k,btn in pairs(self.btnItems) do
    --     local btnLight = btn.transform:Find("btnLight").gameObject
    --     btnLight:SetActive(false)
    -- end

    -- for k,view in pairs(self.viewItems) do
    --     view:SetActive(false)
    -- end

    -- local curBtnLight = self.btnItems[index].transform:Find("btnLight").gameObject
    -- curBtnLight:SetActive(true)
    -- self.viewItems[index]:SetActive(true)

    self:removeRedDot(index)
end

function PanelTask:removeRedDot(index)
    
    if GameManager.UserData.redDotData then
        if GameManager.UserData.redDotData.task.index[index] then
            self.redDots[index]:SetActive(false)
            GameManager.UserData.redDotData.task.index[index] = nil
        end

        if GameManager.UserData.redDotData.task.index == nil or next(GameManager.UserData.redDotData.task.index) == nil then
            GameManager.UserData.redDotData.task.dot = 0
            if GameManager.runningScene.name == "HallScene" and GameManager.runningScene.view_.redDotManager then
                GameManager.runningScene.view_:redDotManager()
            end
        end
    end
end

function PanelTask:onBtnRewardClick(sender,data)
    http.completeMission(
        data.id,
        data.mission_type,
        function(callData)
            
            if callData and callData.flag == 1 then
                GameManager.UserData.money = callData.latest_money
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")

                if self.view then
                    self:reFashTaskList()
                end
            else
                GameManager.TopTipManager:showTopTip(T("领取失败"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

-- 前往完成任务
function PanelTask:onBtnGotoClick(data)
    self:onClose()
    GameManager.ActivityJumpConfig:Jump(data)
end

function PanelTask:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelTask