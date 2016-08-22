local config = require("app.MyConfig")
local userfile = config.userfile
local BlockConfig = config.Block

local Block = class("Block", function (level, touchAble)
    if level == 0 then
        return cc.Sprite:create()
    end
    local theme = userfile.get("theme")
    local filePath = string.format("emoji/%d/emoji%d-%d.png", theme, theme, level)
    local sprite = cc.Sprite:create(filePath)
    return sprite
end)

function Block:ctor(level, touchAble)
	self.level = level
	self:setTouchEnabled(touchAble)
end
    
return Block
