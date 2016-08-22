local config = require("app.MyConfig")
local Block = require("app.sprite.Block")
local Mask = require("app.sprite.Mask")

local MaskView = class("MaskView")

-- pos 为世界坐标，面板左下角
function MaskView:ctor(board)
    self.board = board
    self.calTime = 0
    self.score = 0
    self.fail = false
    self.mergeNum = 0
    board:removeAllChildren(true)
    self.mask = Mask.new()

    local bSize, bPos = board:getContentSize(), cc.p(board:getPosition())
    self.blockLength = bSize.width / self.mask.wn
    self.x, self.y = bPos.x - bSize.width / 2, bPos.y - bSize.height / 2
    self.blocks = {}

    for i = 1, self.mask.wn do
	   self.blocks[i] = {}
        for j = 1, self.mask.hn do
	       self:getNewBlock(i - 1, j - 1, 0)
        end
    end
end

-- x, y start from 0
function MaskView:getNewBlock(x, y, level)
    local block = Block.new(level, false)
    local size = block:getContentSize()
    block:setScale(self.blockLength / size.width, self.blockLength / size.height)
    block:setAnchorPoint(0, 0)
    block:setPosition(x * self.blockLength, y * self.blockLength)
    if self.blocks[x + 1][y + 1] ~= nil then
        self.blocks[x + 1][y + 1]:removeFromParent(true)
    end
    self.board:addChild(block, 2)
    self.blocks[x + 1][y + 1] = block
end

function MaskView:put(puts, callbacks)
    local endCall = function ()
    	self:update()
    	callbacks[2](true)
    end
    
    local puts, position = self:getMaskLocation(puts)
    if puts == nil then return callbacks[2](false) end
    
    AudioController:whenPut()
    local changes = self.mask:put(puts, position)
    if (changes ~= false) then
        callbacks[1]()
        self:frash(puts, position)

        self:playAnim(changes, endCall)
        self.mergeNum = self.mergeNum + #changes
    else
        callbacks[2](false)
    end
end

function MaskView:updateScore(level, num)
    if level == 0 then
        self.score = self.score + 30
    else
        self.score = self.score + level * num
    end
end

function MaskView:getMaskLocation(puts)
    local reLocs = {}
    local mpos = self:gLoc2mLoc(puts[1])
    if mpos == nil then return nil end
    table.insert(reLocs, {0, 0, puts[1][3]})
    for i = 2, #puts do
        table.insert(reLocs, puts[i])
    end
    return reLocs, mpos
end

function MaskView:gLoc2mLoc(gLoc)
    local gx, gy = gLoc[1], gLoc[2]
    local dx, dy = math.floor((gx - self.x) / self.blockLength), math.floor((gy - self.y) / self.blockLength)
    local wn, hn = self.mask.wn, self.mask.hn
    if dx < 0 or dy < 0 or dx >= wn or dy >= hn then
        return nil
    end
    return {x = dx, y = dy}
end

function MaskView:playAnim(changes, callback)
    local cb = function ()
        local sp = self.board:getChildByTag(10)
        while sp ~= nil do
            sp:removeFromParent(true)
            sp = self.board:getChildByTag(10)
        end
        callback()
    end
    if #changes <= 0 then return cb(true) end
    for i = #changes, 1, -1 do
        cb = self:getPlayFunc(changes[i], cb)
    end
    cb()
end

function MaskView:getPlayFunc(change, callback)
    -- 每次单独的合并完成后进行回调
    local cb = function ()
        local newLevel = 0
        if self.blocks[change[1][1]] ~= nil and self.blocks[change[1][1]][change[1][2]].level < config.maxLevel then
            newLevel = self.blocks[change[1][1]][change[1][2]].level + 1
        end
        self:updateScore(newLevel, #change)
    	self:getNewBlock(change[1][1] - 1, change[1][2] - 1, newLevel)
    	callback()
    end
    
    -- 每个格子进行的播放动画动作
    local reFunc = function ()
        -- 最高等级消除时动画
        if self.blocks[change[1][1]] ~= nil and self.blocks[change[1][1]][change[1][2]].level == config.maxLevel then
            AudioController:when8dis()
            
            local centerSpr = self.blocks[change[1][1]][change[1][2]]
            local sprite = cc.Sprite:create("ui/9light.png")
            local cx, cy = {max = -1, min = 1}, {max = -1, min = 1}
            local bx, by = change[1][1], change[1][2]
            for i = -1, 1 do
                for j = -1, 1 do
                    if self.blocks[bx + i] ~= nil and self.blocks[bx + i][by + j] ~= nil then
                        cx.max = math.max(cx.max, i)
                        cx.min = math.min(cx.min, i)
                        cy.max = math.max(cy.max, j)
                        cy.min = math.min(cy.min, j)
                    end
                end
            end
           
            local sSize = sprite:getContentSize()
            local sPosi = cc.p(centerSpr:getPosition())
            local bw, bh = cx.max - cx.min + 1, cy.max - cy.min + 1
            local scarex, scarey = self.blockLength / sSize.width * bw, self.blockLength / sSize.height * bh
            sprite:setScale(scarex, scarey)
            local dx, dy = (cx.max + cx.min + 1) / 2, (cy.max + cy.min + 1) / 2

            local cx, cy = sPosi.x + dx * self.blockLength, sPosi.y + dy * self.blockLength
            sprite:setPosition(cc.p(cx, cy))

            local scale = cc.ScaleTo:create(0.6, scarex / 100, scarey / 100)
            local fadeout = cc.FadeOut:create(0.6)
            local anim = cc.Spawn:create(scale, fadeout)
            sprite:runAction(anim:clone())
            sprite:setAnchorPoint(0.5, 0.5)
            sprite:setTag(10)
            self.board:addChild(sprite, 2)
            
            for i = 1, 4 do
                local spr = cc.Sprite:create("ui/9light.png")
                spr:setPosition(cc.p(cx, cy))
                spr:setScale(scarex, scarey)
                spr:setAnchorPoint(0.5, 0.5)
                spr:setTag(10)
                spr:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 * i), anim:clone()))
                self.board:addChild(spr, 2)
            end
            
            local explore = cc.ParticleSystem:create("explore.plist")
            explore:setPosition(cc.p(cx, cy))
            self.board:addChild(explore)
            
        elseif self.blocks[change[1][1]] ~= nil and self.blocks[change[1][1]][change[1][2]].level == 0 then
            dump("0")
        elseif self.blocks[change[1][1]] ~= nil and self.blocks[change[1][1]][change[1][2]].level == config.maxLevel - 1 then
            dump("7")
            AudioController:when7dis()
        else
            AudioController:whenCombine()
        end
        
    	local moveAction = cc.MoveTo:create(0.5, cc.p(self.blocks[change[1][1]][change[1][2]]:getPosition()))
        local fadeAction = cc.FadeOut:create(0.5)
        local animAction = cc.Spawn:create(moveAction, fadeAction)
        local cpos = cc.p(self.blocks[change[1][1]][change[1][2]]:getPosition())
        
        for i = 2, #change do
    	   local x, y = change[i][1], change[i][2]
    	   local action = cc.Sequence:create(animAction:clone(), cc.CallFunc:create(self:getPlayCallback({x - 1, y - 1}, #change - 1, cb)))
    	   self.blocks[x][y]:runAction(action)
    	   
    	   local merge = cc.ParticleSystem:create("merge.plist")
    	   local ang = nil
    	   if x == cpos.x then
    	       if y < cpos.y then
    	           ang = 90
    	       else
    	           ang = -90
    	       end
    	   else
    	       ang = math.asin((cpos.y - y) / (cpos.x - x))
    	   end
    	   merge:setAngle(ang)
    	   merge:setPosition(cc.p(self.blocks[x][y]:getPosition()))
    	   merge:addTo(self.board)
        end
    end
    return reFunc
end

function MaskView:getPlayCallback(theBlock, time, callback)
	local re = function ()
		self.calTime = self.calTime + 1
        self:getNewBlock(theBlock[1], theBlock[2], 0)
		if self.calTime == time then
		    self.calTime = 0
		    callback()
		end
	end
	return re
end

function MaskView:frash(puts, position)
    for i = 1, #puts do
        local x, y = position.x + puts[i][1], position.y + puts[i][2]
        self:getNewBlock(x, y, puts[i][3])
    end
end

function MaskView:update()
    for i = 1, self.mask.wn do
        for j = 1, self.mask.hn do
            if self.mask.mask[i][j] ~= self.blocks[i][j].level then
                self:getNewBlock(i - 1, j - 1, self.mask.mask[i][j])
            end
        end
    end
    if self.mask.max0 <= 0 then
        self.fail = true
    end
end

function MaskView:mLoc2gLoc(mLoc)
    -- TODO when used
end

return MaskView
