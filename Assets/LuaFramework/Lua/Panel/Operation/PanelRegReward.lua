local PanelRegReward = class("PanelRegReward")

function PanelRegReward:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelRegReward" }, function(objs)
        self:initView(objs)
    end)
end

function PanelRegReward:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelRegReward"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelRegReward:show()
    
    GameManager.UserData.register_reward_status = 0
    GameManager.PanelManager:addPanel(self,true,1)
end

function PanelRegReward:initProperties()

end

function PanelRegReward:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.image1 = self.view.transform:Find("img1").gameObject
    self.image2 = self.view.transform:Find("img2").gameObject

    self.text1 = self.view.transform:Find("Text1").gameObject
    self.text2 = self.view.transform:Find("Text2").gameObject

    self.btnReward = self.view.transform:Find("btnReward").gameObject
    self.btnReward:addButtonClick(buttonSoundHandler(self,self.onClose), false)
end

function PanelRegReward:initUIDatas()
    http.ddzRegisterConfig(
        function(callData)
            
            if callData and callData.flag == 1 then
                self.rewardData1 = callData.config[1]
                self.rewardData2 = callData.config[2]

                self.image1:setSprite("Images/SenceMainHall/fuliItem"..self.rewardData1.rtype)
                self.image2:setSprite("Images/SenceMainHall/fuliItem"..self.rewardData2.rtype)

                self.text1:setText(self.rewardData1.desc)
                self.text2:setText(self.rewardData2.desc)
            else
                GameManager.TopTipManager:showTopTip(T("领取失败"))
            end
        end,
        function(callData)
            
            GameManager.TopTipManager:showTopTip(T("请求失败"))
        end
    )
end

function PanelRegReward:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil

        if self.rewardData1 and self.rewardData2 then
            GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),self.rewardData1.rtype,self.rewardData1.desc,"",function()
                GameManager.AnimationManager:playRewardAnimation(T("领取奖励"),self.rewardData2.rtype,self.rewardData2.desc,"")
            end)
        end
    end)
end

return PanelRegReward