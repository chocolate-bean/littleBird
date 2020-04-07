local PanelPlayInfoBig = class("PanelPlayInfoBig")

function PanelPlayInfoBig:ctor()
    resMgr:LoadPrefabByRes("PlayInfo", { "PanelPlayInfoBig" }, function(objs)
        self:initView(objs)
        self:show()
    end)
end

function PanelPlayInfoBig:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPlayInfoBig"
    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view.transform.localScale = Vector3.one
    self.view.transform.localPosition = Vector3.zero

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
end

function PanelPlayInfoBig:initProperties()
    self.Guns         = {}
    self.redpacketUIs = {}
end

function PanelPlayInfoBig:initUIControls()
    -- 关闭按钮
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    UIHelper.AddButtonClick(self.btnClose,buttonSoundHandler(self,self.onClose))

    -- 性别开关
    self.ToggleGirl = self.view.transform:Find("ToggleGirl").gameObject:GetComponent("Toggle")
    UIHelper.AddToggleClick(self.view.transform:Find("ToggleGirl").gameObject,handler(self,self.ChangeSex))
    self.ToggleBoy = self.view.transform:Find("ToggleBoy").gameObject:GetComponent("Toggle")
    UIHelper.AddToggleClick(self.view.transform:Find("ToggleBoy").gameObject,handler(self,self.ChangeSex))

    -- 头像
    self.PlayIcon = self.view.transform:Find("PlayIcon").gameObject
    self.PlayIconBg = self.view.transform:Find("PlayIconBg").gameObject
    self.frame = self.view.transform:Find("PlayIcon/IconFrame").gameObject
    -- 玩家姓名
    self.PlayName = self.view.transform:Find("input").gameObject
    -- UID
    self.PlayMid = self.view.transform:Find("PlayMid").gameObject
    -- 金币
    self.PlayMoney = self.view.transform:Find("btnMoney/TextNum").gameObject
    -- 钻石
    self.PlayDiamond = self.view.transform:Find("btnDiamond/TextNum").gameObject
    -- 红包
    self.PlayHongbao = self.view.transform:Find("btnHongbao/TextNum").gameObject
    self.redpacketUIs[#self.redpacketUIs + 1] = self.view.transform:Find("btnHongbao").gameObject
    -- VIP
    self.PlayVip = self.view.transform:Find("PlayVip").gameObject

    for  i = 1,11 do
        local item = self.view.transform:Find("PanelGun/Grid/"..i).gameObject
        -- if i > (GameManager.UserData.viplevel + 1) then
        --     item:SetActive(false)
        -- end
        -- item:SetActive(true)

        table.insert(self.Guns, item)
        item:addButtonClick(function()
            self:changeGun(i)
        end)
    end

    -- Vip
    self.btnVip = self.view.transform:Find("btnVip").gameObject
    UIHelper.AddButtonClick(self.btnVip,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.PanelManager:removePanel(self,nil,function()
            destroy(self.view)
            self.view = nil
            local PanelNewVipHelper = import("Panel.Special.PanelNewVipHelper").new()
            -- GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.PLAYINFO
            -- local PanelShop = import("Panel.Shop.PanelShop").new()
        end)
    end)
    -- 改名
    self.btnChange = self.view.transform:Find("btnChange").gameObject
    UIHelper.AddButtonClick(self.btnChange,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        local PanelDialog = import("Panel.Dialog.PanelDialog").new({
            hasFristButton = true,
            hasSecondButton = true,
            hasCloseButton = false,
            title = T("提示"),
            text = T("改名需要花费1万金币"),
            firstButtonCallbcak = function()
                self:ChangeName()
            end,
        })
    end)

    -- 上传头像
    self.btnChangeIcon = self.view.transform:Find("btnChangeIcon").gameObject
    UIHelper.AddButtonClick(self.btnChangeIcon,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        sdkMgr:OpenAlbum(function(sprite)
            
            self:onGetImageCallBack(sprite)
        end)
    end)

    -- 金币商城
    self.btnMoney = self.view.transform:Find("btnMoney").gameObject
    UIHelper.AddButtonClick(self.btnMoney,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.PLAYINFO
        -- local PanelShop = import("Panel.Shop.PanelShop").new()

        GameManager.PanelManager:removePanel(self,nil,function()
            destroy(self.view)
            self.view = nil
            -- local PanelSmallShop = import("Panel.Shop.PanelSmallShop").new()
            local PanelNewShop = import("Panel.Shop.PanelNewShop").new()
        end)
    end)

    -- 钻石商城
    self.btnDiamond = self.view.transform:Find("btnDiamond").gameObject
    UIHelper.AddButtonClick(self.btnDiamond,function()
        
        GameManager.SoundManager:PlaySound("clickButton")
        GameManager.GameConfig.PayPosition = CONSTS.PAY_SCENE_TYPE.PLAYINFO
        local PanelShop = import("Panel.Shop.PanelShop").new(2)
    end)

    -- 红包商城
    self.btnHongbao = self.view.transform:Find("btnHongbao").gameObject
    UIHelper.AddButtonClick(self.btnHongbao,function()
        
        GameManager.SoundManager:PlaySound("clickButton")

        GameManager.PanelManager:removePanel(self,nil,function()
            destroy(self.view)
            self.view = nil
            -- local PanelExchange = import("Panel.Exchange.PanelExchange").new()
            local PanelNewShop = import("Panel.Shop.PanelNewShop").new(2)
        end)
    end)

    showOrHide(GameManager.GameConfig.SensitiveSwitch.showRedpacket, self.redpacketUIs)
end

function PanelPlayInfoBig:initUIDatas()
    self:refashPlayerInfo()
    self:refashPlayIcon()
    self.PlayerInfoHandleId = GameManager.DataProxy:addPropertyObserver(DataKeys.USER_DATA, "micon", handler(self, self.refashPlayIcon))
    http.getFishingCannonList(
        function(callData)
            if callData and callData.flag == 1 then
                for k, data in pairs (callData.list) do
                    if tonumber(data.valid) == 1 then
                        self.Guns[tonumber(data.id)]:SetActive(true)
                        -- TODO倒计时
                        if tonumber(data.expire) ~= -1 then
                            local name = self.Guns[tonumber(data.id)].transform:Find("name").gameObject

                            local time = data.expire - os.time()
                            local timeText
                            if time > 86400 then
                                timeText = T("(剩")..string.format( "%.0f",time / 86400)..T("天)")
                            else
                                timeText = T("(剩1天)")
                            end
                            
                            if isMZBY() or isDBBY() or isFKBY() then
                                self.Guns[tonumber(data.id)].transform:Find("bg/DayText").gameObject:GetComponent('Text').text = timeText
                            else
                                name:GetComponent('Text').text = name:GetComponent('Text').text..timeText
                            end
                        else
                            if isMZBY() or isDBBY() or isFKBY() then
                                self.Guns[tonumber(data.id)].transform:Find("bg/DayText").gameObject:GetComponent('Text').text = T("永久")
                            end
                        end
                    end
                end
            else
                GameManager.TopTipManager:showTopTip(T("获取炮台样式失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("获取炮台样式失败"))
        end
    )

    if isMZBY() or isDBBY() or isFKBY() then
        self.Guns[GameManager.UserData.cannonStyle].transform:Find("toggle").gameObject:setSprite("Images/common/toggleOn")
    else
        self.Guns[GameManager.UserData.cannonStyle].transform:Find("toggle").gameObject:setSprite("Images/common/checkBoxOn")
    end


    if GameManager.GameConfig.HasDiamond == 0 then
        self.btnDiamond:SetActive(false)
        if isMZBY() or isDBBY() or isFKBY() then
            self.btnMoney.transform.localPosition = Vector3.New(-350.9,-183.1,0)
        else
            self.btnMoney.transform.localPosition = Vector3.New(-339,-177.2,0)
        end
    end
end

function PanelPlayInfoBig:refashPlayIcon()
    GameManager.ImageLoader:loadPlayerIconToNodeWithParams({
        url = GameManager.UserData.micon,
        sex = tonumber(GameManager.UserData.msex),
        node = self.PlayIcon,
        callback = function(sprite)
            
            if self.view and self.PlayIcon then
                self.PlayIcon:GetComponent('Image').sprite = sprite
            end
        end,
    })
end

function PanelPlayInfoBig:refashPlayerInfo()
    -- 名称
    self.PlayName:GetComponent('InputField').text = GameManager.UserData.name
    -- UID
    self.PlayMid:GetComponent('Text').text = GameManager.UserData.mid
    -- 金币
    self.PlayMoney:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.money)
    -- 钻石
    self.PlayDiamond:GetComponent('Text').text = formatFiveNumber(GameManager.UserData.diamond)
    -- 红包
    self.PlayHongbao:GetComponent('Text').text = GameManager.GameFunctions.getJewel()
    -- 性别
    if tonumber(GameManager.UserData.msex) == 0 then
        self.ToggleGirl.isOn = true
    else
        self.ToggleBoy.isOn = true
    end
    -- VIP
    self.PlayVip:GetComponent('Text').text = "VIP"..GameManager.UserData.viplevel or 0
    if GameManager.UserData.viplevel and tonumber(GameManager.UserData.viplevel) > 0 then
        self.PlayIconBg:SetActive(false)
        local sp = GameManager.ImageLoader:getVipFrame(GameManager.UserData.viplevel)
        self.frame:GetComponent('Image').sprite = sp
        self.frame:SetActive(true)
    end
end

-- function PanelPlayInfoBig:getPropNum()
--     -- 技能数量
--     http.getFishingSkill(
--         function(retData)
--             if retData.flag == 1 then
--                 dump(retData)
--                 for i = 1, 3 do
--                     local prop = self.view.transform:Find("PanelProp/prop"..i.."/num").gameObject
--                     prop:GetComponent('Text').text = retData.list[i].num.."个"
--                 end
--             else
--                 GameManager.TopTipManager:showTopTip(T("获取技能数目失败"))
--             end
--         end,
--         function(callData)
--             GameManager.TopTipManager:showTopTip(T("获取技能数目失败"))
--         end
--     )
-- end

function PanelPlayInfoBig:ChangeName()
    
    local curName = self.PlayName:GetComponent('InputField').text
    if curName == GameManager.UserData.name then
        return
    else
        http.modifyPlayerInfo(
            curName,
            "",
            function(callData)
                
                if callData and callData.flag == 1 then
                    GameManager.UserData.money = tonumber(callData.money)
                    GameManager.UserData.name = curName
                    self:refashPlayerInfo()
                elseif callData.flag == -4 then
                    GameManager.TopTipManager:showTopTip(T("金币不足"))
                else
                    GameManager.TopTipManager:showTopTip(T("改名失败"))
                end
            end,
            function(callData)
                
            end
        )
    end
    
end

function PanelPlayInfoBig:ChangeSex()
    
    local curSex = self.ToggleGirl.isOn == true and 0 or 1
    if curSex == tonumber(GameManager.UserData.msex) then
        return
    else
        http.modifyPlayerInfo(
            "",
            curSex,
            function(callData)
                if callData and callData.flag == 1 then
                    GameManager.UserData.msex = curSex
                else
                    GameManager.TopTipManager:showTopTip(T("修改性别失败"))
                end
                self:refashPlayerInfo()
            end,
            function(callData)
                
            end
        )
    end
end

function PanelPlayInfoBig:changeGun(index)
    http.changeFishingCannon(
        index,
        function(callData)
            if callData and callData.flag == 1 then
                for i , item in pairs (self.Guns) do
                    local img = item.transform:Find("toggle").gameObject
                    if isMZBY() or isDBBY() or isFKBY() then
                        img:setSprite("Images/common/toggleOff")
                    else
                        img:setSprite("Images/common/checkBoxOff")
                    end
                end
                
                if isMZBY() or isDBBY() or isFKBY() then
                    self.Guns[index].transform:Find("toggle").gameObject:setSprite("Images/common/toggleOn")
                else
                    self.Guns[index].transform:Find("toggle").gameObject:setSprite("Images/common/checkBoxOn")
                end
                GameManager.UserData.cannonStyle = index
            else
                GameManager.TopTipManager:showTopTip(T("设置炮台样式失败"))
            end
        end,
        function(callData)
            GameManager.TopTipManager:showTopTip(T("设置炮台样式失败"))
        end
    )
end

function PanelPlayInfoBig:onGetImageCallBack(sprite)
    if sprite then
        sdkMgr:PostImage(GameManager.GameConfig.UPLOAD_AVATAR, sprite, GameManager.UserData.mid, GameManager.UserData.valid_sign, function(isSucc,miconJson)
            
            if isSucc then
                GameManager.TopTipManager:showTopTip(T("上传成功"))
                local micon = json.decode(miconJson)
                GameManager.UserData.micon = micon.url
            else
                GameManager.TopTipManager:showTopTip(T("上传失败"))
            end
        end)
    end
end

function PanelPlayInfoBig:show()
    GameManager.PanelManager:addPanel(self, true, 3)
end

function PanelPlayInfoBig:onClose()
    GameManager.DataProxy:removePropertyObserver(DataKeys.USER_DATA, "micon", self.PlayerInfoHandleId)
    GameManager.PanelManager:removePanel(self,nil,function()
        destroy(self.view)
        self.view = nil
    end)
end

return PanelPlayInfoBig