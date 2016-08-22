local config = require("app.MyConfig")
local userfile = config.userfile

local Panels = require("app.panel.Panels")

local SceneBase = class("SceneBase", function()
    return cc.Scene:create()
end)

function SceneBase:init(filename)
    self.panel = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(filename)
    self:addChild(self.panel)
end

function SceneBase:setEvent(name, callback)
    local btn = self.panel:getChildByName(name)
    btn:addTouchEventListener(function(sender, eventType)
        if eventType == 0 then
            AudioController:whenButton()
            return true
        elseif eventType == 2 then
            callback()
        end
    end)
end

function SceneBase:setText(name, set)
    local toSet = self.panel:getChildByName(name)
    if toSet.setTexture ~= nil then
        toSet:setTexture(set)
    elseif toSet.setString ~= nil then
        toSet:setString(set)
    else
        -- wrong
    end
end

function SceneBase:resume()
    cc.Director:getInstance():popScene()
end

function SceneBase:restart( )
    app:enterScene("GameScene")
end

function SceneBase:update()
    self:setText("Head", self:getHead())
    self:setText("BestScore", userfile.get("best1"))
    self:setText("Coin", userfile.get("coin"))
    self:setText("LevelNum", userfile.get("level"))
end

function SceneBase:showHome()
    app:enterScene("MainScene")
end

function SceneBase:showThemePanel()
    Panels.Skin.new(self, 123)
end

function SceneBase:showSetPanel()
    Panels.Setting.new(self)
end

function SceneBase:showNoADPanel()
    Panels.Shop.new(self)
end

function SceneBase:showBestPanel()
    Panels.Rank.new(self)
end

function SceneBase:showStarPanel()
    GradeManager:openMarket()
end

function SceneBase:showNoCoinPanel()
    Panels.NoCoin.new(self)
end

function SceneBase:showBuyPanel()
    Panels.Shop.new(self)
end

function SceneBase:showADPanel()
    Panels.FreeCoin.new(self)
end

function SceneBase:showHelpPanel()
    Panels.Tutor.new(self)
end

return SceneBase
