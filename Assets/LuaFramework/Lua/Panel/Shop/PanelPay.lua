local PanelPay = class("PanelPay")

PanelPay.pmode = {
    WX             = 1001,
    ZFB            = 1002,
    APPLE_OFFICIAL = 1003,
    OPPO           = 1010,
    VIVO           = 1011,
    ZRBY           = 1012,
    GP             = 1100,
}

function PanelPay:ctor(data,closeCallback)
    dump(data)
    self.closeCallback = closeCallback
    self.data = data
    resMgr:LoadPrefabByRes("Shop", { "PanelPay" }, function(objs)
        self:initView(objs)
    end)
end

function PanelPay:initView(objs)
    
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelPay"

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()
    self:ifShowPayDiscountView()

    self:show()
end

function PanelPay:show()
    if isOPPO() then
        self:onOPPOPay(self.data)
    else
        GameManager.PanelManager:addPanel(self,false,1)
    end
end

function PanelPay:initProperties()
end

function PanelPay:initUIControls()
    self.btnClose = self.view.transform:Find("btnClose").gameObject
    self.btnClose:addButtonClick(buttonSoundHandler(self,self.onClose), false)

    self.Des = self.view.transform:Find("Des").gameObject
    self.Money = self.view.transform:Find("Money").gameObject

    self.btnWX = self.view.transform:Find("PanelPayType/Grid/btnWX").gameObject
    self.btnWX:SetActive(false)
    self.btnWX:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
        if isVIVO() then
            self:onVIVOWXPay(self.data)
        else
            self:onWXPay(self.data)
        end
    end), false)

    self.btnZFB       = self.view.transform:Find("PanelPayType/Grid/btnZFB").gameObject
    self.btnZFB:SetActive(false)
    self.btnZFB:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
        if isVIVO() then
            self:onVIVOZFBPay(self.data)
        else
            self:onZFBPay(self.data)
        end
    end), false)
    
    --折扣的视图
    self.discouts = {
        [PanelPay.pmode.WX] = {
            img  = self.btnWX.transform:Find("ImgDiscount").gameObject,
            text = self.btnWX.transform:Find("ImgDiscount/textDiscount").gameObject,
        },
        [PanelPay.pmode.ZFB] = {
            img  = self.btnZFB.transform:Find("ImgDiscount").gameObject,
            text = self.btnZFB.transform:Find("ImgDiscount/textDiscount").gameObject,
        }
    }

    self.btnGP = self.view.transform:Find("PanelPayType/Grid/btnGP").gameObject
    self.btnGP:SetActive(false)
    self.btnGP:addButtonClick(buttonSoundHandler(self, function()
        self:onClose()
        self:onGPpay(self.data)
    end), false)
end

function PanelPay:initUIDatas()
    for i,v in ipairs(self.data.inland_pmode) do
        if tonumber(v) == PanelPay.pmode.WX then
            self.btnWX:SetActive(true)
        end

        if tonumber(v) == PanelPay.pmode.ZFB then
            self.btnZFB:SetActive(true)
        end

        if tonumber(v) == PanelPay.pmode.GP then
            self.btnGP:SetActive(true)
        end
    end

    self.Des:setText(self.data.getname)
    self.Money:setText(self.data.pamount..T("元"))
    
end

--控制折扣视图的显示
function PanelPay:ifShowPayDiscountView()
    if self.data.discount then
        for key, discount in pairs(self.data.discount) do
            showOrHide(string.len(discount) > 0, self.discouts[tonumber(key)].img)
            self.discouts[tonumber(key)].text:setText(discount)
        end
    end
end

-- 这里分离了支付宝和微信支付的方法，以备两者出现不同
function PanelPay:onWXPay(data)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from   
        end
        http.callPayOrder(
            params, 
            function(retData)
                dump(retData)
                if retData.flag == 1 then
                    --[[
                        appid:"wxdd40e209fb285321"
                        sign:"BEF4789CDF8DFB096D8FCE1881AE9744"
                        noncestr:"IipEdejGf7Diwbgd"
                        package:"Sign=WXPay"
                        timestamp:1536995889
                        prepayid:"wx1515180978441505f5be390b0375436407"
                        partnerid:"1514445311"
                    ]]
                    -- WechatPay(string partnerId, string prepayId, string noncestr, string timeStamp, string sign)
                    local params = retData.data
                    sdkMgr:WechatPay(params.partnerid, params.prepayid, params.noncestr, params.timestamp, params.sign)
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end
    creatPayOrder(PanelPay.pmode.WX, data)
end

-- 这里分离了支付宝和微信支付的方法，以备两者出现不同
function PanelPay:onZFBPay(data)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from   
        end
        http.callPayOrder(
            params, 
            function(retData)
                dump(retData)
                if retData.flag == 1 then
                    sdkMgr:Alipay(retData.data)
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end

    creatPayOrder(PanelPay.pmode.ZFB, data)
end

-- 谷歌支付
function PanelPay:onGPpay(data)
    -- 初始化C#的支付回调
    shopMgr:OnShopInit(handler(self,self.onBuyCallBack))
    
    local params = {}
    params.product_id = tonumber(data.id)
    params.pmode = tonumber(data.pmode)
    params.position = GameManager.GameConfig.PayPosition or 1000
    
    local mid = GameManager.UserData.mid
    local version = BM_UPDATE and AppConst.OsVersion or "0"
    local sid = AppConst.Sid

    params.mid = GameManager.UserData.mid
    params.uuid = GameManager.UserData.uuid
    params.version = version
    params.sid = sid

    params.pay_scene = GameManager.UserData.pay_scene or CONSTS.PAY_SCENE_TYPE.HALL_SHOP
    params.gameparty_subname = "0"
    if data.from then
        params.from = data.from   
    end
    http.callPayOrder(
		params,
		function (callData)
			-- body
			if callData and callData.flag == 1 then
				local orderId = callData.data
				shopMgr:OnBuyCoins(params.product_id,orderId)
			else
				GameManager.TopTipManager:showTopTip(T("下单失败"))
			end
		end,
		function (callData)
			-- body
			GameManager.TopTipManager:showTopTip(T("下单失败"))
		end
	)
end

function PanelPay:onInAppPurchases(data, callback)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from   
        end
        http.callPayOrder(
            params, 
            function(retData)
                if retData.flag == 1 then
                    local params = retData.data
                    sdkMgr:InAppPurchases(data.id, retData.data, function(jsonString)
                        if callback then
                            callback(jsonString)
                        end
                    end)
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end
    creatPayOrder(PanelPay.pmode.APPLE_OFFICIAL, data)
end

function PanelPay:onOPPOPay(data)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from   
        end
        http.callPayOrder(
            params, 
            function(retData)
                dump(retData)
                if retData.flag == 1 then
                    local params = retData.data
                    sdkMgr:OPPOPay(params.out_trade_no, params.attach, params.pamount, params.productDes, params.getname, params.setCallbackurl, function(resultString)
                        print("lua获取到了 支付回调：" .. resultString)
                    end)
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end
    creatPayOrder(PanelPay.pmode.OPPO, data)
end

function PanelPay:onVIVOPay(data, channel)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from   
        end
        http.callPayOrder(
            params, 
            function(retData)
                dump(retData)
                if retData.flag == 1 then
                    local params = retData.data
                    if channel == 1 then
                        sdkMgr:VIVOWXPay(params.callTrade.orderNumber, params.callTrade.accessKey, params.pamount, params.productDes, params.getname, function(resultString)
                            print("lua获取到了 VIVO wx 支付回调：" .. resultString)
                        end)
                    else
                        sdkMgr:VIVOAliPay(params.callTrade.orderNumber, params.callTrade.accessKey, params.pamount, params.productDes, params.getname, function(resultString)
                            print("lua获取到了 VIVO ali 支付回调：" .. resultString)
                        end)
                    end
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end
    creatPayOrder(PanelPay.pmode.VIVO, data)
end

function PanelPay:onVIVOZFBPay(data)
    self:onVIVOPay(data, 2)
end

function PanelPay:onVIVOWXPay(data)
    self:onVIVOPay(data, 1)
end

function PanelPay:onIAppPayPay(data, channel)
    function creatPayOrder(pmode, data)
        local params = {
            pmode = pmode,
            product_id = data.id,
            position = GameManager.GameConfig.PayPosition or 1000
        }
        if data.from then
            params.from = data.from
        end
        if channel == 1 then
            params.way = "wechat"
        else
            params.way = "ali"
        end
        http.callPayOrder(
            params, 
            function(retData)
                if retData.flag == 1 then
                    -- 不去调用sdk 采用h5的方式
                    if retData.url then
                        local webview = WebView.new()
                        webview:OpenUrl(retData.url.h5)
                    end
                else
                    GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
                end
            end,
            function(callData)
                GameManager.TopTipManager:showTopTip(T("创建订单失败！"))
            end
        )
    end
    creatPayOrder(PanelPay.pmode.ZRBY, data)
end

function PanelPay:onIAppPayAliPay(data)
    self:onIAppPayPay(data, 2)
end

function PanelPay:onIAppPayWXPay(data)
    self:onIAppPayPay(data, 1)
end

-- 谷歌支付回调
function PanelPay:onBuyCallBack(result,gpJson,gpSig)
	-- body
	if result then
		print("支付成功,".."gpJson:"..gpJson..",gpSig:"..gpSig)
		
		-- gpJson = "{"orderId":"GPA.3332-0991-6762-36146","packageName":"com.thumbp.pokeng","productId":"1000","purchaseTime":1531107002716,"purchaseState":0,"developerPayload":"{\"developerPayload\":\"eyJpZCI6NDE0ODYsInByb2R1Y3RfaWQiOjEwMDAsInBtb2RlIjoxfQ==\\n\",\"is_free_trial\":false,\"has_introductory_price_trial\":false,\"is_updated\":false}","purchaseToken":"njnojadeompgaaikbgooalhm.AO-J1OyyGWLo1hiUASo_Qso87ny3FJAcWV-RDRxZRYQvUn7FtrRNQfqgHSxwdfPwMG2Sks36Zg1_kjLb6mjAg-4ozQLb5msZRQol46gkHwpPKlCwGAk5NRw"}"
		local gpSourceDta = json.decode(gpJson)
		local developPayload = json.decode(gpSourceDta.developerPayload)
		local payloadDecode = crypto.decodeBase64(developPayload.developerPayload)
		gpSourceDta.developerPayload = payloadDecode
		local gpJson = json.encode(gpSourceDta)

		local params = {}
    	params.inapp_purchase_data = gpJson
		params.inapp_data_signature = gpSig
		params.pmode = 1
		
		local retryTimes = 6
		local preservePayment
		local callClientPayment

		preservePayment = function(params)
			-- body
			local paymentJson = UnityEngine.PlayerPrefs.GetString(DataKeys.PAYMENT)
			local payment

			-- 注意这里可能已经有未完成的订单了，这里要追加保存
			if paymentJson and paymentJson ~= "" then
				payment = json.decode(paymentJson)
			else
				payment = {}
			end
			
			table.insert(payment, params)
			paymentJson = json.encode(payment)
            UnityEngine.PlayerPrefs.SetString(DataKeys.PAYMENT,paymentJson)
		end

		callClientPayment = function()
			-- body
			http.callClientPayment(
				params,
				function(callData)
					if callData and callData.flag == 1 then
                        GameManager.TopTipManager:showTopTip(T("已支付成功，正在进行发货，请稍候.."))
                        -- TODO 接入AF后需要后台统计
						-- if GameManager.AFInit then
						-- 	print("AFInit")
						-- 	if self.goodData then
						-- 		local name = self.goodData.getname
						-- 		local sku = self.goodData.id
						-- 		local currency = self.goodData.currency 
                        --         local price = self.goodData.pamount
                        --         -- TODO AF后台统计
						-- 		sdkMgr:AFTrackEvent(name, sku, currency, price)
						-- 	end
						-- end
					else
						retryTimes = retryTimes - 1
		    			if retryTimes > 0 then
		    				callClientPayment()
						else
							preservePayment(params)
		    			end
					end
				end,
				function(errData)
					retryTimes = retryTimes - 1
					if retryTimes > 0 then
						callClientPayment()
					else
						preservePayment(params)
					end
				end
			)
		end

		callClientPayment()
	else
		GameManager.TopTipManager:showTopTip(T("支付失败"))
	end
end

function PanelPay:onClose()
    -- 这里最好写一个控制器控制
    GameManager.PanelManager:removePanel(self,nil,function()
        if self.closeCallback then
            self.closeCallback()
        end
        destroy(self.view)
        self.view = nil
    end)
end

return PanelPay