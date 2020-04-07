local BasePanel = require("Panel.BasePanel").new()
local PanelFree = class("PanelFree", BasePanel)

function PanelFree:ctor()
    self.type = "Free"
    self.prefabs = { "PanelFree", "FreeItem" }
    self.translateobjs = { "Static/Title" }
    self:init()
end

function PanelFree:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFree"

    self.systemItem = objs[1]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    self:show()
end

function PanelFree:initProperties()
end

function PanelFree:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    self.Grid = self.view.transform:Find("FreeList/Grid").gameObject
end

function PanelFree:initUIDatas()
    self:reFashSystemList()
end

function PanelFree:reFashSystemList()
    
    self.SystemData = {}
    self:GetSystemList()
end

-- 获取邮件
function PanelFree:GetSystemList()
    http.freeConfig(
        function(callData)
            if callData then
                if self.view then
                    self.SystemData = callData.list
                    self:DestroySystemList()
                    self:createSystemList()
                end
            else
                GameManager.TopTipManager:showTopTip(T("数据为空"))
            end
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("请求失败"))
            if self.view then
                GameManager.LoadingManager:setLoading(false, self.view)
            end
        end
    )
end

function PanelFree:DestroySystemList()
    
    removeAllChild(self.Grid.transform)
end

-- 创建系统列表
function PanelFree:createSystemList()
    
    for i,data in ipairs(self.SystemData) do
        local item = newObject(self.systemItem)
        item.name = i
        item.transform:SetParent(self.Grid.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3.zero

        local Icon = item.transform:Find("Icon").gameObject
        local url = data.icon
        GameManager.ImageLoader:loadAndCacheImage(url,function (success, sprite)
            
            if success and sprite then
                if self.view then
                    Icon:GetComponent('Image').sprite = sprite
                end
            end
        end)

        local Title = item.transform:Find("Title").gameObject
        Title:GetComponent('Text').text = data.title

        local Des = item.transform:Find("Des").gameObject
        Des:GetComponent('Text').text = data.desc

        local btnGoto = item.transform:Find("btnGoto").gameObject
        local btnReward = item.transform:Find("btnReward").gameObject
        local btnReady = item.transform:Find("btnReady").gameObject

        if data.action == "quick_play" then
            btnGoto:SetActive(true)
            UIHelper.AddButtonClick(btnGoto,function()
                
                GameManager.SoundManager:PlaySound("clickButton")
                GameManager.ActivityJumpConfig:Jump(data.action)
            end)
        elseif data.action == "login_reward" then
            if data.status == 0 then
                btnReady:SetActive(true)
            else
                btnGoto:SetActive(true)
                local text = btnGoto.transform:Find("Text").gameObject
                text:GetComponent("Text").text = T("去领取")

                UIHelper.AddButtonClick(btnGoto,function()
                    GameManager.SoundManager:PlaySound("clickButton")
                    self:onClose()
                    GameManager.ActivityJumpConfig:Jump(data.action)
                end)
            end
        elseif data.action == "bankrupt" then
            if data.status == 0 then
                btnReady:SetActive(true)
            else
                if GameManager.ODialogManager:judegeIsBankrupt() then
                    btnReward:SetActive(true)
                    UIHelper.AddButtonClick(btnReward,function()
                        GameManager.SoundManager:PlaySound("clickButton")
                        GameManager.ODialogManager:getBankruptReward(function(isSuccess)
                            self:reFashSystemList()
                        end)
                    end)
                else
                    btnGoto:SetActive(true)
                    UIHelper.AddButtonClick(btnGoto,function()
                        GameManager.SoundManager:PlaySound("clickButton")
                        GameManager.ActivityJumpConfig:Jump("go_fishing_money_room")
                    end)
                end 
            end
        end
    end
end

return PanelFree