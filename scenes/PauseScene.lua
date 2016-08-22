local SceneBase = require("app.scenes.SceneBase")
local ScoreScene = require("app.scenes.ScoreScene")
local config = require("app.MyConfig")
local scheduler = require("framework.scheduler")
local userfile = config.userfile

local PauseScene = class("PauseScene", SceneBase)

function PauseScene:ctor(game)
	self:init("PauseScene.csb")
	self.game = game
	self:setButton()
    self:setTexts()

    self.updateHandler = scheduler.scheduleGlobal(handler(self, self.updatePerSecond), 1)
end

function PauseScene:setButton()
    self:setEvent("StartButton", function ()
        scheduler.unscheduleGlobal(self.updateHandler)
        self:resume()
    end)
    
    self:setEvent("RestartButton",  function ()
        scheduler.unscheduleGlobal(self.updateHandler)
        self:restart()
    end)

    self:setEvent("HomeButton",  function ()
        scheduler.unscheduleGlobal(self.updateHandler)
        self:showHome()
    end)
    
    self:setEvent("ADButton", function () self:showADPanel() end)
    self:setEvent("SetButton",   function () self:showSetPanel() end)
    
    local fadin, fadout = cc.FadeIn:create(0.5), cc.FadeOut:create(0.5)
    local fadAnim = cc.RepeatForever:create(cc.Sequence:create(fadin, fadout))
    local btn = self.panel:getChildByName("ADButton")
    local loc = cc.p(btn:getPosition())
    local sprite = cc.Sprite:create("ui/light.png")
    sprite:runAction(fadAnim)
    sprite:setPosition(loc)
    sprite:setVisible(false)
    self.adSpr = sprite
    self:addChild(sprite)
end

function PauseScene:updatePerSecond()
    AdManager:isVideoReady(handler(self, self.isADready))
end

function PauseScene:isADready(res)
    if res then
        self.adSpr:setVisible(true)
    else
        self.adSpr:setVisible(false)
    end
end

function PauseScene:setTexts()
    self:setText("Head", self:getHead())
    self:setText("BestScore", userfile.get("best"))
	self:setText("Coin", userfile.get("coin"))
	self:setText("LevelNum", userfile.get("level"))
	
    local exp, lv, expSpr = userfile.get("exp"), userfile.get("level"), self.panel:getChildByName("LevelGet")
    local loc = cc.p(expSpr:getPosition())
    self.panel:removeChild(expSpr)

    local expPro = cc.ProgressTimer:create(expSpr)
    expPro:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    expPro:setPercentage(exp / ((lv + 1) * 500) * 100)
    expPro:setPosition(loc)
    self.panel:add(expPro)
end

function PauseScene:showHome()
    cc.Director:getInstance():replaceScene(ScoreScene.new(self.game))
end

function PauseScene:getHead()
    local lv, themeNow = userfile.get("level"), userfile.get("theme")
    local headPath = string.format("emoji/%d/emoji%d-%d.png", themeNow, themeNow, lv)
    return headPath
end

return PauseScene
