local Puts = require("app.sprite.Puts")
local MaskView = require("app.sprite.MaskView")
local SceneBase = require("app.scenes.SceneBase")
local ScoreScene = require("app.scenes.ScoreScene")
local PauseScene = require("app.scenes.PauseScene")
local config = require("app.MyConfig")
local userfile = config.userfile

local GameScene = class("GameScene", SceneBase)

function GameScene:get(restart)
    if self.instence == nil or restart == true then
        self.instence = self:new()
        self.time = os.time()
    end
    return self.instence
end

function GameScene:ctor()
    self:init("GameScene.csb")
    self:setButtons()
    self.putPosition = cc.p(self.panel:getChildByName("PutSprite"):getPosition())
    self:restart()
    self.time = os.time()
    
    if userfile.get("firstGame") == 1 then
        self:showHelpPanel()
        userfile.set("firstGame", 0)
    end
end

function GameScene:restart()
    math.randomseed(os.time())
    self:setTexts()
    if self.maskView then
        self.maskView = nil
    end
    self.maskView = MaskView.new(self.panel:getChildByName("BoardSprite"))
    self:addPuts()
end

function GameScene:setButtons()
    self:setEvent("PauseButton",    self:showADper2min(function () self:pause() end))
    self:setEvent("ChangeButton",   self:showADper2min(function () self:changePuts() end))
    self:setEvent("BuyButton",      self:showADper2min(function () self:showBuyPanel() end))
    self:setEvent("HelpButton",     self:showADper2min(function () self:showHelpPanel() end))
end

function GameScene:showADper2min(callback)
    local refunc = function ()
        local timenow = os.time()
        if timenow - self.time > 120 then
            AdManager:getInstance():showAd(self, callback)
            self.time = timenow
            return
        end
        callback()
    end
    return refunc
end

function GameScene:pause()
    cc.Director:getInstance():pushScene(PauseScene.new({self.maskView.score, self.maskView.mergeNum}))
end

function GameScene:setTexts()
    self:setText("CoinPerChange", config.coinPerChange)
    self:setText("BestScore", userfile.get("best1"))
    self:setText("Score", 0)
    self:setText("Coin", userfile.get("coin"))
    self:updateCoin(0)
end

function GameScene:updateCoin(add)
    userfile.add("coin", add)
    self:setText("Coin", userfile.get("coin"))
end

function GameScene:addPuts()
    if self.nowPut ~= nil then
        self.nowPut:removeFromParent(true)
        self.nowPut = nil
    end
    local maxNum, maxLevel = self.maskView.mask.max0, self.maskView.mask.max
    if maxNum ~= 1 then
        maxNum = 2
    end
    local newPuts = Puts.new(math.random(1, maxNum), maxLevel, self.maskView.blockLength)
    newPuts:setPosition(self.putPosition)
    newPuts:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(newPuts)
    self.nowPut = newPuts
end

function GameScene:changePuts()
    local coin = userfile.get("coin")
    if coin >= config.coinPerChange then
        userfile.add("coin", -config.coinPerChange)
        self:setText("Coin", userfile.get("coin"))
        self:addPuts()
    else
        self:showNoCoinPanel()
    end
end

function GameScene:put(puts)
    self.maskView:put(puts, {function () self.nowPut:removeFromParent(true) self.nowPut = nil end,
    function (succ)
        if succ then
            self:update()
            self:addPuts()
        else
            self.nowPut:setPosition(self.putPosition)
        end
    end})
end

function GameScene:update()
    self:setText("Score", self.maskView.score)
    if self.maskView.fail then
        self:gameOver()
    end
end

function GameScene:gameOver()
    cc.Director:getInstance():replaceScene(ScoreScene.new({self.maskView.score, self.maskView.mergeNum}))
end

return GameScene
