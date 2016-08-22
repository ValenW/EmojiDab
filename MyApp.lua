
require("config")
require("cocos.init")
require("framework.init")
require("clc.init")
local MainScene = require("app.scenes.MainScene")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("src/")
    cc.FileUtils:getInstance():addSearchPath("res/")
    AdManager:getInstance():checkNoAdState()
    self:enterScene("MainScene")
end

return MyApp
