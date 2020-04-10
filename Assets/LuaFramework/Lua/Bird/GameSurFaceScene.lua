local GameSurFaceScene = class("GameSurFaceScene")

function GameSurFaceScene:ctor( )
    self.wallsSecond = {}
    self.wallsFirst = {}
    self.screenHeight = Screen.height
    self.screenWidth = Screen.width
    self.flag = false
    self:init()  
end

function GameSurFaceScene:init( )

    self.outSideView = UnityEngine.GameObject.Find("Canvas").gameObject
    self.img1        = UnityEngine.GameObject.Find("Canvas/Image1")
    self.imgbg       = UnityEngine.GameObject.Find("Canvas/Imagebg")
    self.imgbg2      = UnityEngine.GameObject.Find("Canvas/Imagebg_2")
    self.btnUp       = UnityEngine.GameObject.Find("Canvas/ButtonUp")
    self.textTip     = UnityEngine.GameObject.Find("Canvas/TextGameOverTip")
    self.textTip:SetActive(false)

    resMgr:LoadPrefabByRes("Common", { "wall"}, function(objs)
        self.wallPrefab = objs[0]
        self:option()
        local csMethod = self.img1.transform.gameObject:GetComponent("ColliderSprict")
        csMethod:SetLuaFunction(function()
            self.flag = true
            self.textTip:SetActive(true)
            self.timer:Stop()
         end )
    end)
   
end

function GameSurFaceScene:option()
    
    self.rate = (self.screenHeight)/10
    self.imgbg2.transform.localPosition  = Vector3(self.screenWidth)
    
    self:fillWallTable(self.imgbg, self.imgbg2, self.wallsFirst, self.wallsSecond, 2)
    
    self.timer = Timer.New(function ()
                -- self.imgbg:SetActive(flag)
                local birdY = self.img1.transform.localPosition.y
                if birdY <= -self.screenHeight/2+25 or birdY >= self.screenHeight/2-25 then
                    print("游戏结束")
                    --这里需要暂停游戏
                    self.flag = true
                    self.textTip:SetActive(true)
                    self.timer:Stop()  
                end    
                self.imgbg.transform:Translate(Vector3.New(-7,0)) 
                self.imgbg2.transform:Translate(Vector3.New(-7,0))
                self.img1.transform:Translate(Vector3.New(0,-2.5,0))
                local x = self.imgbg.transform.localPosition.x
                local x2 = self.imgbg2.transform.localPosition.x
                -- print(self.imgbg.transform.localPosition.x)
                
                if x <= -self.screenWidth  then
                    self.imgbg.transform.localPosition = Vector3(self.screenWidth)
                    -- 清除table表中间的存放的预置体
                    -- for i,v in pairs(self.wallsFirst) do
                    --     destroy(v) --"userdata"
                    --     v = nil
                    -- end
                    -- self.wallsFirst = {}
                    --改成了对预置体的
                    self:fillWallTable(self.imgbg,nil, self.wallsFirst, nil, 1)
                end
                if x2 <= -self.screenWidth then
                    self.imgbg2.transform.localPosition = Vector3(self.screenWidth)
                    -- 清除table表中间的存放的预置体
                    -- for i,v in pairs(self.wallsSecond) do
                    --     destroy(v)
                    --     v = nil
                    -- end
                    -- self.wallsSecond = {}
                    self:fillWallTable(nil, self.imgbg2, nil, self.wallsSecond, 1)
                end
                
            end, 0.009, -1, true)
    self.timer:Start()          
    local count = 1
    UIHelper.AddButtonClick(self.btnUp,function()
        if not self.flag then
            self.img1.transform:Translate(Vector3.New(0 ,100, 0))
        end    
        
    end)
    -- DOTween
    -- local animation = self.imgbg.transform:DOLocalMove(Vector3.New(1280), 3)
    -- animation:SetEase(DG.Tweening.Ease.Linear)
    -- animation:SetLoops(-1, DG.Tweening.LoopType.Restart)
    -- animation:OnComplete(function()
    --     --
    -- end)
        -- self:zeroToScreenWidthAnimation(self.imgbg)
        -- self:doubleScreenWidthAnimation(self.imgbg2)
    -- local x :GetComponent('colliderSprict')
    -- x:(function)
end

function GameSurFaceScene:zeroToScreenWidthAnimation(node)
    -- 设置初始量
    -- 0 imgbg 
    node.transform.localPosition = Vector3.zero
    local animation = node.transform:DOLocalMove(Vector3.New(self.screenWidth), 3)
    animation:SetEase(DG.Tweening.Ease.Linear)
    -- animation:SetLoops(-1, DG.Tweening.LoopType.Restart)
    animation:OnComplete(function()
        self:doubleScreenWidthAnimation(node)
    end)
end

function GameSurFaceScene:doubleScreenWidthAnimation(node)
    -- 设置初始量
    -- -self.screenWidth imgbg node.transform.localPosition = Vector3.zero
    -- -self.screenWidth  imgbg2 node.transform.localPosition = Vector3.zero
    node.transform.localPosition = Vector3.New(-self.screenWidth,0)
    local animation = node.transform:DOLocalMove(Vector3.New(self.screenWidth), 6)
    animation:SetEase(DG.Tweening.Ease.Linear)
    -- animation:SetLoops(-1, DG.Tweening.LoopType.Restart)
    animation:OnComplete(function()
        self:doubleScreenWidthAnimation(node)
    end)
end

function GameSurFaceScene:fillWallTable(bg1, bg2, wallTableFirst, wallTableSecond, len)
    
    for i=1,len do
        local countDelta = 0 
        local wallTable
        local parent 
        local wall
        if i == 1 and bg1 and wallTableFirst then
            wallTable = wallTableFirst
            parent = bg1
        else
            wallTable = wallTableSecond  
            parent = bg2
        end
        for k=1,3 do
            for n=1,2 do
                if wallTable and #wallTable < 6 then
                    
                    wall = newObject(self.wallPrefab)
                    --[[
                        这样子虽然可以但是显的很复杂，可阅读性不高
                        if k == 1 then
                            if n == 1 then
                                wallTable[1] = wall
                            else
                                wallTable[2] = wall   
                            end
                        else
                            if n == 1 then
                                wallTable[k+countDelta] = wall
                            else
                                wallTable[k+countDelta+1] = wall
                            end 
                        end
                        ]]
                    wallTable[#wallTable + 1] = wall
                    wall.transform:SetParent(parent.transform)
                else
                    if k == 1 then
                        if n == 1 then
                            wall = wallTable[1]
                        else
                            wall = wallTable[2] 
                        end
                    else
                        if n == 1 then
                            wall = wallTable[k+countDelta]
                        else
                            wall = wallTable[k+countDelta+1]
                        end 
                    end        
                end

                if n == 1 then
                    self.bottomWallHeight = math.random(1,4)*self.rate
                    wall.transform.localPosition = Vector3.New(-self.screenWidth/2+380*k, self.screenHeight/2-self.bottomWallHeight*0.5,0)
                    wall.transform.sizeDelta = Vector3.New(100,self.bottomWallHeight)
                else
                    wall.transform.localPosition = Vector3.New(-self.screenWidth/2+380*k, -(self.screenHeight/2-((self.screenHeight-self.bottomWallHeight-self.rate-100))*0.5),0)
                    wall.transform.sizeDelta = Vector3.New(100, (self.screenHeight-self.bottomWallHeight-self.rate-100))
                end
            end
            countDelta = countDelta + 1
        end

    end
end

return GameSurFaceScene


-- local People = class("People")
-- function People:Eat( )
    
-- end

-- function People:__add(other)
--     print("ADDD")
--     return 1, "", {}, function()
        
--     end
-- end

-- function print_fake(...)
--     local length = select('#', ...)
--     local first = select(1, ...)
--     local table = {...}
-- end

-- -- {}
-- -- []
-- -- ()

-- local a = People.new()
-- local b = People.new()
-- local c, e, f, w = a:__add(b) -- 调用了一个没有返回值的方法
-- local c = a.__add   -- function 
-- -- local c = a + b
-- print(type(c)) -- string

-- local Teacher = class("Teacher", People)

-- function Teacher:Awake()
    
-- end

-- function Teacher:Start()
    
-- end

-- function Teacher:Update()
    
-- end

-- return {
--     new = function()
        
--     end
-- }
