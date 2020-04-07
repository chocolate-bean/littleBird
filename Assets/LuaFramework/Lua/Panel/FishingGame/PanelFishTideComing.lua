local BasePanel = require("Panel.BasePanel").new()
local PanelFishTideComing = class("PanelFishTideComing", BasePanel)

function PanelFishTideComing:ctor()
    self.type = "FishingGame/UI"
    self.prefabs = { "PanelFishTideComing", "Chip" }
    self:init()
end

function PanelFishTideComing:initView(objs)
    self.view = UnityEngine.GameObject.Instantiate(objs[0])
    self.view.name = "PanelFishTideComing"

    self.item = objs[1]

    self:initProperties()
    self:initUIControls()
    self:initUIDatas()

    local parent = UnityEngine.GameObject.Find("Canvas")
    self.view.transform:SetParent(parent.transform)
    self.view:scale(Vector3.one)
    self.view.transform.localPosition = Vector3.zero
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Horizontal, parent.transform.sizeDelta.x)
    self.view.transform:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(UnityEngine.RectTransform.Axis.Vertical, parent.transform.sizeDelta.y)
end

function PanelFishTideComing:initProperties()
    
end

function PanelFishTideComing:initUIControls()
    self.AnimParent    = self.view.transform:Find("AnimParent").gameObject
end

function PanelFishTideComing:initUIDatas()
    self:playAnim()
    Timer.New(function()
        self:onClose()
    end, 2, 1, true):Start()
end

function PanelFishTideComing:playAnim()
    for i=1,200 do
        Timer.New(function()
            local item = newObject(self.item)
            item.transform:SetParent(self.AnimParent.transform)
            item.transform.localScale = Vector3.New(0.5,0.5,0.5)
            item.transform.localPosition = Vector3.zero
            item.transform.localEulerAngles = UnityEngine.Random.insideUnitSphere

            local type = math.random(1,4)
            
            local posX
            local posY

            if type == 1 then
                posX = 740
                posY = math.random( -360, 360 )
            elseif type == 2  then
                posX = -740
                posY = math.random( -360, 360 )
            elseif type == 3  then
                posX = math.random( -640, 640 )
                posY = 460
            elseif type == 4  then
                posX = math.random( -640, 640 )
                posY = -460
            end

            if self.view then
                item.transform:DOLocalMove(Vector3.New(posX, posY, 0),0.5)
                item.transform:DOScale(Vector3.New(3,3,1), 0.5)
            end
        end, i * 0.01, 1, true):Start()
    end
end

function PanelFishTideComing:onClose()
    -- 这里最好写一个控制器控制
    destroy(self.view)
    self.view = nil
end

return PanelFishTideComing