local config = require("app.MyConfig")
local PutsConfig = config.Puts
local Block = require("app.sprite.Block")

local Puts = class("Puts", function ()
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(cc.p(0.5, 0.5))
    return layout
end)

local function touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        sender.moving = false
        sender.opos = cc.p(sender:getPosition())
        return true
    elseif eventType == ccui.TouchEventType.moved then
        local prevPos = sender:getTouchBeganPosition()
        local nowPos = sender:getTouchMovePosition()
        local opos = sender.opos
        local lpos = cc.p(nowPos.x - prevPos.x, nowPos.y - prevPos.y)
        
        if sender.moving == true or lpos.x > 30 or lpos.y > 30 then
            sender.moving = true
            local newx, newy = math.max(math.min(opos.x + lpos.x, display.width - 10), 10), math.max(math.min(opos.y + lpos.y, display.height - 10), 10)
            sender:setPosition(cc.p(newx, newy))
        end
    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        if sender.moving == true then
            sender:bePut()
        else
            sender:toggle()
        end
        sender.moving = false
    end
end

function Puts:ctor(type, maxLevel, length)
    self.type = type
    self.blockLength = length
    self:setSize()
    self:addBlocks(maxLevel)
    self:setTouchEnabled(true)
    self:addTouchEventListener(touchEvent)
end

function Puts:setSize()
    if (self.type == 1) then
        self.width, self.height = self.blockLength, self.blockLength
    elseif (self.type <= 3 ) then
        self.width, self.height = self.blockLength, self.blockLength * 2
    elseif (true) then
    -- wrong
    end
    self:setContentSize(cc.size(self.width, self.height))
end

function Puts:addBlocks(maxLevel)
    local configs = PutsConfig.types[self.type]
    local levels = {}
    if maxLevel == 0 then maxLevel = 1 end
    maxLevel = maxLevel + 1
    for i = 1, #configs do
        local level = math.random(1, maxLevel)
        while (level > config.maxLevel or levels[level] ~= nil) do
            level = math.random(1, maxLevel)
        end
        levels[level] = 1
        
        local block = Block.new(level, false)
        block:setAnchorPoint(cc.p(0.5, 0.5))
        block:setPosition(self.blockLength * (configs[i][1] + 0.5), self.blockLength * (configs[i][2] + 0.5))
        self:addChild(block)
    end
end

function Puts:bePut()
    local children = self:getChildren()
    local pos = self:convertToWorldSpace(cc.p(children[1]:getPosition()))
    local puts = {{pos.x, pos.y, children[1].level}}
    for i = 2, #children do
        local p = self:convertToWorldSpace(cc.p(children[i]:getPosition()))
        local dx, dy = math.modf((p.x - pos.x) * 1.5 / self.blockLength), math.modf((p.y - pos.y) * 1.5 / self.blockLength)
        table.insert(puts, {dx, dy, children[i].level})
    end
    self:getParent():put(puts)
end

function Puts:toggle()
    if (self.type == 1) then
        return nil
    elseif (self.type <= 3) then
        AudioController:whenRotate()
        self.type = 5 - self.type
        local clockRotate = cc.RotateBy:create(0.3, 90)
        local antiClockRotate = cc.RotateBy:create(0.3, -90)
        self:setTouchEnabled(false)
        self:runAction(cc.Sequence:create(clockRotate, cc.CallFunc:create(function () return self:setTouchEnabled(true) end)))
        local childs = self:getChildren()
        for i = 1, #childs do
            childs[i]:runAction(antiClockRotate:clone())
        end
    end
end

return Puts
