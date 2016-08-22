local Mask = class("Mask")
local config = require("app.MyConfig")
local MaskConfig = config.Mask

local function bfs(start, getNext, func)
    local nexts = {start}
    local visited = {}
    local finished = {}
    for i = 1, 5 do
        finished[i] = {}
        for j = 1, 5 do
            finished[i][j] = 0
        end
    end
    finished[start[1]][start[2]] = 1
    while #nexts > 0 do
        local newNext = {}
        for _, node in pairs(nexts) do
            table.insert(visited, node)
            func(node)
            for _, newNode in ipairs(getNext(node)) do
                if finished[newNode[1]][newNode[2]] == 0 then
                    table.insert(newNext, newNode)
                    finished[newNode[1]][newNode[2]] = 1
                end
            end
        end
        nexts = newNext
    end
    return visited
end

local function sortByLevel(a, b)
    return a.level <= b.level
end

function Mask:ctor()
    self.wn = MaskConfig.width
    self.hn = MaskConfig.height
    self.maxLevel = config.maxLevel
    self.max0 = self.wn * self.hn
    self.max = 0
    
    self:reset()
end

function Mask:reset()
    self.mask = {}
    for i = 1, self.wn do
        self.mask[i] = {}
        for j = 1, self.hn do
            self.mask[i][j] = 0
        end
    end
end

--[[
    puts, position
           都是mask坐标，1~maxl
]] 
function Mask:tryPut(puts, position)
    local rePuts = {}
    for i = 1, #puts do
        rePuts[i] = {}
        local line = self.mask[position.x + puts[i][1] + 1]
        if line == nil or line[position.y + puts[i][2] + 1] ~= 0 then
            return nil
        else
            rePuts[i].x = position.x + puts[i][1] + 1
            rePuts[i].y = position.y + puts[i][2] + 1
            rePuts[i].level = puts[i][3]
        end
    end
    return rePuts
end

function Mask:put(puts, position)
    local toPuts = self:tryPut(puts, position)
    if (toPuts == nil) then return false end
    for i = 1, #toPuts do
        self.mask[toPuts[i].x][toPuts[i].y] = toPuts[i].level
    end
    table.sort(toPuts, sortByLevel)
    local re = self:update(toPuts)
    return re
end

function Mask:update(puts)
    local change = {}
    for i = 1, #puts do
        local px, py, pl = puts[i].x, puts[i].y, puts[i].level
        if (self.mask[px][py] == pl) then
            local merged = self:merge(px, py)
            while (merged ~= nil) do
                self:updateLevels(merged)
                table.insert(change, merged)
                merged = self:merge(px, py)
            end
        end
    end
    self:updateMax0NumMax()
    return change
end

function Mask:merge(px, py)
    local oldLevel = self.mask[px][py]
    if (oldLevel == 0) then return nil end
    if (oldLevel == config.maxLevel + 1) then
        local visited = {{px, py}}
        for i = -1, 1 do
            for j = -1, 1 do
                if i ~= 0 or j ~= 0 then
                    local line = self.mask[px + i]
                    if (line ~= nil and line[py + j] ~= nil) then
                        table.insert(visited, {px + i, py + j})
                    end
                end
            end
        end
        return visited
    end

    local visited = bfs({px, py}, self:getNextFunc(oldLevel), function () return nil end)
    if (#visited < 3) then return nil
    else return visited end
end

function Mask:getNextFunc(oldLevel)
    local dir = {{-1, 0}, {0, 1}, {1, 0}, {0, -1}}
    local tbl = self.mask
    local olv = oldLevel

    local reFunc = function (node)
        local re = {}
        for i = 1, #dir do
            local newNode = {node[1] + dir[i][1], node[2] + dir[i][2]}
            if (tbl[newNode[1]] ~= nil and tbl[newNode[1]][newNode[2]] == olv) then
                table.insert(re, newNode)
            end
        end
        return re
    end
    return reFunc
end

function Mask:updateLevels(merged)
    local ox, oy = merged[1][1], merged[1][2]
    if (self.mask[ox][oy] == 0) then return end
    if (self.mask[ox][oy] == config.maxLevel + 1) then
        self.mask[ox][oy] = 0
    else
        self.mask[ox][oy] = self.mask[ox][oy] + 1
    end
    for i = 2, #merged do
        local x, y = merged[i][1], merged[i][2]
        self.mask[x][y] = 0
    end
end

function Mask:updateMax0NumMax()
    local all0s = {}
    for i = 1, 5 do
        all0s[i] = {}
        for j = 1, 5 do
            all0s[i][j] = 0
        end
    end
    local allVisited = {}
    for i = 1, self.wn do
        for j = 1, self.hn do
            if self.mask[i][j] <= self.maxLevel then
                self.max = self.max < self.mask[i][j] and self.mask[i][j] or self.max
            end
            if (self.mask[i][j] == 0 and all0s[i][j] == 0) then
                all0s[i][j] = 1
                local visited = bfs({i, j}, self:getNextFunc(0), function (node) return nil end)
                table.insert(allVisited, visited)
                for _, node in pairs(visited) do
                    all0s[node[1]][node[2]] = 1
                end
            end
        end
    end

    local maxN, maxVisited = 0, nil
    for i = 1, #allVisited do
        if (#allVisited[i] > maxN) then
            maxN = #allVisited[i]
            maxVisited = allVisited[i]
        end
    end

    self.max0 = maxN
    return {maxN, maxVisited}
end

return Mask
