local PanelLimitTask = class("PanelLimitTask")

function PanelLimitTask:ctor()
    
    resMgr:LoadPrefabByRes("Task", { "PanelLimitTask" }, function(objs)
        self:initView(objs)
    end)
end

function PanelLimitTask:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelLimitTask"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelLimitTask:show()
    
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelLimitTask:initProperties()
end

function PanelLimitTask:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))
end

function PanelLimitTask:initUIDatas()
    self:getLimitTask()
end

function PanelLimitTask:getLimitTask()
    
    http.challengeMission(
        function(callData)
            if callData and callData.flag == 1 then
                self:reflushLimitTask(callData.mission)
            end
        end,
        function(callData)
        end
    )
end

function PanelLimitTask:reflushLimitTask(taskData)
    
    local item = self.view.transform:Find("Item1/taskBg").gameObject

    local icon = item.transform:Find("icon").gameObject
    local url = taskData.icon
    GameManager.ImageLoader:loadAndCacheImage(url,function (success, sprite)
        
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
    local process = ""..current.."/"..goal

    local progressBar = item.transform:Find("progressBar").gameObject
    progressBar:GetComponent("Slider").value = current/goal

    local progressText = item.transform:Find("progressBar/Text").gameObject
    progressText:GetComponent("Text").text = process

    local btnReward = item.transform:Find("btnReward").gameObject
    local btnGoto = item.transform:Find("btnGoto").gameObject
    local btnReady = item.transform:Find("btnReady").gameObject
    -- 任务状态
    if taskData.status == 1 then
        if current >= goal then
            btnReward:SetActive(true)
            UIHelper.AddButtonClick(btnReward,function(sender)
                
                GameManager.SoundManager:PlaySound("clickButton")
                self:onBtnRewardClick(taskData,btnReward,btnReady)
            end)
        else
            btnGoto:SetActive(true)
            UIHelper.AddButtonClick(btnGoto,function(sender)
                
                GameManager.SoundManager:PlaySound("clickButton")
                self:onBtnGotoClick(taskData.action_name)
            end)
        end
    elseif taskData.status == 0 then
        btnReady:SetActive(true)
    end
end

function PanelLimitTask:onBtnRewardClick(data,btnReward,btnReady)
    if data.reward_type == 3 then
        if GameManager.UserData.jewelGain + tonumber(data.reward.jewel) > GameManager.UserData.jewelLimit then
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

    local mission_type = data.mission_type
    http.completeMission(
        data.id,
        mission_type,
        function(callData)
            
            if callData and callData.flag == 1 then
                GameManager.UserData.money = callData.latest_money
                GameManager.TopTipManager:showTopTip(T("领取成功"))

                btnReward:SetActive(false)
                btnReady:SetActive(false)
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
function PanelLimitTask:onBtnGotoClick(data)
    GameManager.ActivityJumpConfig:Jump(data)
end

function PanelLimitTask:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelLimitTask