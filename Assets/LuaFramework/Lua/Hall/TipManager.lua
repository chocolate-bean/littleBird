local TipManager = class("TipManager")

function TipManager:ctor()
    self.showTime = 1
    self.playTime = 0.5

    self.noticeList = {}
    self.curNotice = {}

    resMgr:LoadPrefabByRes("Common", { "PanelTip" }, function(objs)
        self.toptipPrefab = objs[0]
    end)
end

function TipManager:showTopTip(info)
    if self.toptipPrefab then
        self:play(info)
    end
end

function TipManager:play(info)
    local parent = UnityEngine.GameObject.Find("Canvas").gameObject

    local tiptopPanel = newObject(self.toptipPrefab)
    tiptopPanel.transform:SetParent(parent.transform)
    tiptopPanel.transform.localScale = Vector3.one
    tiptopPanel.transform.localPosition = Vector3.New(0,0,0)
    local tiptopBg = tiptopPanel.transform:Find("tiptopBg")

    local tipText = tiptopPanel.transform:Find("tiptopText"):GetComponent("Text")
    tipText.text = info
    local width = tipText.preferredWidth
    tiptopBg:GetComponent("RectTransform").sizeDelta = Vector3.New(width + 80,80,0)
    self:showAnim(tiptopPanel)
end

function TipManager:addNotice(info)
	if #self.noticeList>0 then
		if type(info) =="table" and info.msg == self.noticeList[#self.noticeList].msg or 
		type(info) =="string" and info == self.noticeList[#self.noticeList].msg then
			return
		end
    end

    local notice = {}
    local queue = 0
    local isReplace = false

    if type(info) == "string" then
        notice.msg  = info or "0"
        notice.place = 0
        -- 这里预留了type功能，但暂未实现
        notice.type = info.type or 1
    elseif type(info) == "table" then
        notice.msg = info.msg or "0"
        notice.place = checkint(info.place) or 0
        queue = checkint(info.queue) or 0 -- 0不插队 1插队
        -- 这里预留了type功能，但暂未实现
        notice.type = info.type or 1
        isReplace = info.isReplace ~= nil and info.isReplace  or false
    end

    if isReplace then
        table.insert( self.noticeList, 1, notice )
    else
        if queue == 0 then
            table.insert( self.noticeList, notice )
        else
            table.insert( self.noticeList, 1, notice )
        end
    end
end


--判断当前场景是否与要显示的场景匹配
--我认为这个功能没特别的意义，一般都是即时显示，但是保留了这个功能
function TipManager:judgeCurSceneIsMatching(place)
    
    return true
end

function TipManager:showAnim(gameObj)
    -- 注意：此处代码会将TopTip始终置于界面的最上层，请务必注意
    local parent = UnityEngine.GameObject.Find("Canvas")
    local count = parent.transform.childCount
    gameObj.transform:SetSiblingIndex(count - 1)
    gameObj.transform.localPosition = Vector3.New(0,0,0)

    Timer.New(function()
        self:hideAnim(gameObj)
    end, 1, 1, true):Start()

end

function TipManager:hideAnim(gameObj)
    local sequence =  DG.Tweening.DOTween.Sequence()
    sequence:Append(gameObj.transform:DOLocalMove(Vector3.New(0,50,0),self.playTime))
    sequence:OnComplete(function()
        destroy(gameObj)
    end)
end

return TipManager