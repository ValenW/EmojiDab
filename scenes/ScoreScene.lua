local SceneBase = require("app.scenes.SceneBase")
local config = require("app.MyConfig")
local userfile = config.userfile

local ScoreScene = class("ScoreScene", SceneBase)

function ScoreScene:ctor(game)
    self:init("ScoreScene.csb")
    self.score, self.mergeNum = game[1], game[2]
    self:updateBest()
    self:setButton()
    self:setTexts()
    AdManager:getInstance():showAd(self, function () end)
end

function ScoreScene:setButton()
    self:setEvent("RestartButton",  handler(self, self.restart))
    self:setEvent("NoADButton",     handler(self, self.showNoADPanel))
    self:setEvent("BuyButton",      handler(self, self.showBuyPanel))
    self:setEvent("HomeButton",     handler(self, self.showHome))
    self:setEvent("ShareButton",    handler(self, self.share))
end

function ScoreScene:share()
    if device.platform == "android" then
        ShareManager:share(string.format(config.shareWord, self.score), config.aurl)
    else
        ShareManager:share(string.format(config.shareWord, self.score), config.iurl)
    end
end

function ScoreScene:setTexts()
    self:setText("Merge", self.mergeNum)
    self:setText("Coin", userfile.get("coin"))
    self:setText("LevelNum", userfile.get("level"))
    self:setText("Score", self.score)

    local exp, lv, expSpr = userfile.get("exp"), userfile.get("level"), self.panel:getChildByName("LevelGet")
    local loc = cc.p(expSpr:getPosition())
    self.panel:removeChild(expSpr)
    
    local expPro = cc.ProgressTimer:create(expSpr)
    expPro:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    expPro:setPercentage(exp / ((lv + 1) * 500) * 100)
    expPro:setPosition(loc)
    
    local expPer = (exp + self.score) / ((lv + 1) * 500)
    userfile.add("exp", self.score)
    local proAction = cc.ProgressTo:create(1, expPer * 100)
    if expPer >= 1 then
        expPer = 1
        local sacleUpAction, sacleDownAction = cc.ScaleTo:create(1, 1.5), cc.ScaleTo:create(1, 1)
        local levelNum = self.panel:getChildByName("LevelNum")
        levelNum:runAction(cc.Sequence:create(sacleUpAction, cc.CallFunc:create(function () levelNum:setString(lv + 1) end ), sacleDownAction))
        userfile.add("level", 1)
        
        userfile.add("exp", -(lv + 1) * 500)
        local cont = cc.ProgressTo:create(1, (exp + self.score - (lv + 1) * 500) / ((lv + 2) * 500) * 100)
        proAction = cc.Sequence:create(proAction:clone(), cc.CallFunc:create(function () expPro:setPercentage(0) end ), cont)
    end
    expPro:runAction(proAction)
    self.panel:add(expPro)
end

function ScoreScene:updateBest()
    for i = 8, 1, -1 do
        local best = userfile.get("best"..i)
        if self.score > best then
            if i ~= 8 then
                userfile.set("best"..(i + 1), best)
            end
            if i == 1 then
                userfile.set("best1", self.score)
            end
        elseif i ~= 8 then
            userfile.set("best"..(i + 1), self.score)
        end
    end
    userfile.add("coin", self.score / 10)
end

return ScoreScene
