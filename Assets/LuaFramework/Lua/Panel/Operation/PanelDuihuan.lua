local PanelDuihuan = class("PanelDuihuan")

function PanelDuihuan:ctor()
    
    resMgr:LoadPrefabByRes("Operation", { "PanelDuihuan" }, function(objs)
        self:initView(objs)
    end)
end

function PanelDuihuan:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelDuihuan"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelDuihuan:show()
    http.checkExchangePush(
        function(callData)
            if callData then
                self.data = callData.order
                if tonumber(callData.order.jewel) < tonumber(GameManager.UserData.jewel) then
                    GameManager.PanelManager:addPanel(self,true,1)
                    self.has:GetComponent('Text').text = "当前您拥有 " .. GameManager.GameFunctions.getJewel() .. "元 红包"
                    self.des:GetComponent('Text').text = "是否使用 " .. GameManager.GameFunctions.getJewel(self.data.jewel) .. "元 兑换  " .. self.data.title
                end
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("领取失败"))
        end
    )
end

function PanelDuihuan:initProperties()
    self.data = nil
end

function PanelDuihuan:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    -- 确认按钮
    self.btnYes = self.view.transform:Find("btnYes").gameObject
    self.btnYes:addButtonClick(buttonSoundHandler(self,self.onBtnYesClick), false)

    -- 取消按钮
    self.btnNo = self.view.transform:Find("btnNo").gameObject
    self.btnNo:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.has = self.view.transform:Find("has").gameObject
    self.des = self.view.transform:Find("des").gameObject
    self.des.transform.sizeDelta = Vector3.New(600, 50)
end

function PanelDuihuan:initUIDatas()
    
end

function PanelDuihuan:onBtnYesClick()
    http.jewelExchangeCash(
        self.data.id,
        function(callData)
            if callData and callData.flag == 1 then
	dump("fage gaosu wode jieguo")
	dump(callData)
                GameManager.GameFunctions.setJewel(tonumber(callData.latest_jewel))
                GameManager.UserData.money = callData.latest_money
                GameManager.TopTipManager:showTopTip(T("兑换成功"))
                self:onClose()
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("兑换失败"))
        end
    )
end

function PanelDuihuan:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelDuihuan