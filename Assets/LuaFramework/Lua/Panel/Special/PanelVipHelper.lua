local PanelVipHelper = class("PanelVipHelper")

function PanelVipHelper:ctor(hideBtn)
    self.hideBtn = hideBtn
    self.NoticeList = clone(GameManager.GameConfig.NoticeList)
    resMgr:LoadPrefabByRes("Special", { "PanelVipHelper" }, function(objs)
        self:initView(objs)
    end)
end

function PanelVipHelper:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelVipHelper"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
    
    self:show()
end

function PanelVipHelper:show()
    
    GameManager.PanelManager:addPanel(self,true,0)
end

function PanelVipHelper:initProperties()
    self.vipDes = {}
end

function PanelVipHelper:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    -- 升级进度
    self.LevelProgress = self.view.transform:Find("progressBar/Text").gameObject
    -- 进度条
    self.progressBar = self.view.transform:Find("progressBar").gameObject
    -- 当前VIP等级
    self.curVip = self.view.transform:Find("curVip").gameObject
    -- 下一级
    self.wantVip = self.view.transform:Find("wantVip").gameObject
    -- 描述
    self.desText = self.view.transform:Find("DesText").gameObject

    -- VIP等级图片
    for i=1,10 do
        local vipDes = self.view.transform:Find("PanelVip/Grid/Vip"..i).gameObject
        vipDes:setSprite("Images/common/transparent")
        table.insert(self.vipDes,vipDes)
    end

    -- 提升btnGoto
    self.btnGoto = self.view.transform:Find("btnGoto").gameObject
    UIHelper.AddButtonClick(self.btnGoto,function()
        GameManager.SoundManager:PlaySound("clickButton")
        self:onClose()
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.VIP
        -- local PanelShop = import("Panel.Shop.PanelShop").new()
        -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
        local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
    end)
end

function PanelVipHelper:initUIDatas()
    -- 获取新手任务
    http.VIPConfig(
        function(callData)
            if callData and callData.flag == 1 then
                local current = tonumber(callData.user.vip_current) 
                local goal = tonumber(callData.upgrade) 

                if tonumber(callData.user.vip_level == 10) then
                    self.progressBar:GetComponent("Slider").value = 1
                    self.LevelProgress:GetComponent("Text").text = "MAX"

                    self.curVip:GetComponent("Text").text = "VIP10"
                    self.wantVip:SetActive(false)
                    self.desText:SetActive(false)
                else
                    local process = ""..current.."/"..goal
                    self.progressBar:GetComponent("Slider").value = current/goal
                    self.LevelProgress:GetComponent("Text").text = process
    
                    self.curVip:GetComponent("Text").text = "VIP"..callData.user.vip_level
                    self.wantVip:GetComponent("Text").text = "VIP"..(tonumber(callData.user.vip_level) + 1)
                    self.desText:GetComponent("Text").text = T("还差 ")..(goal - current)..T(" 元，即可获得更高级的VIP权限")
                end

                for i,url in ipairs(callData.pics) do
                    GameManager.ImageLoader:loadImageOnlyShop(url,function (success, sprite)
                        if success and sprite then
                            if self.view and self.vipDes[i] then
                                self.vipDes[i]:setSprite(sprite)
                            end
                        end
                    end)
                end
            end
        end,
        function(callData)
        end
    )

    if self.hideBtn then
        self.btnGoto:SetActive(false)
    end
end

function PanelVipHelper:onClose()
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelVipHelper