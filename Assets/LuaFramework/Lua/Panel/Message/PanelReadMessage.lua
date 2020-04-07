local PanelReadMessage = class("PanelReadMessage")

function PanelReadMessage:ctor(data)
    
    self.data = data
    resMgr:LoadPrefabByRes("Message", { "PanelReadMessage" }, function(objs)
        self:initView(objs)
    end)
end

function PanelReadMessage:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelReadMessage"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelReadMessage:show()
    
    GameManager.PanelManager:addPanel(self,false,1)
end

function PanelReadMessage:initProperties()
end

function PanelReadMessage:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.Title = self.view.transform:Find("Title").gameObject
    self.Title:GetComponent('Text').text = self.data.title

    self.text = self.view.transform:Find("Des/Grid/Text").gameObject
    self.text:GetComponent('Text').text = self.data.content

    self.btnYes = self.view.transform:Find("btnYes").gameObject
    self.btnText = self.view.transform:Find("btnYes/Text").gameObject
    -- UIHelper.AddButtonClick(self.btnYes,buttonSoundHandler(self,self.onClose))
    self.Reward = self.view.transform:Find("Reward").gameObject
    self.RewardTitle = self.view.transform:Find("Reward/Title").gameObject
    self.RewardIcon = self.view.transform:Find("Reward/Image").gameObject
    self.RewardText = self.view.transform:Find("Reward/RewardText").gameObject
    self.RewardPropText = self.view.transform:Find("Reward/PropText").gameObject

    if self.data.msg_type then
        if self.data.msg_type == 3 or self.data.msg_type == 2 then
            if self.data.action_params.money or self.data.action_params.jewel or self.data.action_params.prop then
                self.Reward:SetActive(true)
                self.RewardIcon:setSprite("Images/SenceMainHall/fuliItem"..self.data.reward_type)
                if self.data.reward_type == 1 then
                    self.RewardTitle:GetComponent('Text').text = T("奖励金币:")
                    self.RewardText:GetComponent('Text').text = "x"..formatFiveNumber(self.data.action_params.money)
                elseif self.data.reward_type == 3 then
                    self.RewardTitle:GetComponent('Text').text = T("奖励红包:")
                    self.RewardText:GetComponent('Text').text = "x"..formatFiveNumber(self.data.action_params.jewel)
                else
                    self.RewardTitle:GetComponent('Text').text = T("奖励道具:")
                    self.RewardPropText:GetComponent('Text').text = self.data.prize_desc
                end
            end
        end
    end

    if self.data.act_status == 1 then
        self.btnText:GetComponent('Text').text = T("领取")
        UIHelper.AddButtonClick(self.btnYes,buttonSoundHandler(self,self.onRewardClick))
    else
        UIHelper.AddButtonClick(self.btnYes,buttonSoundHandler(self,self.onClose))
    end
end

function PanelReadMessage:initUIDatas()

end

function PanelReadMessage:onRewardClick()
    http.handleOneMessage(
        self.data.id,
        2,
        function(callData)
            if callData and callData.flag == 1 then
                self:onClose()
                GameManager.UserData.money = callData.latest_money
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),callData.rtype,callData.desc,"")
            else
                GameManager.TopTipManager:showTopTip(T("领取失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("网络请求失败"))
        end
    )
end

function PanelReadMessage:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelReadMessage