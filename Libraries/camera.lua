camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.width, camera.height = love.window.getMode()

function camera:set()
    love.graphics.push()
    love.graphics.rotate(self.rotation)
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(self.scaleX, self.scaleY)
end

function camera:unset()
    love.graphics.pop()
end

function camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
    self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
    self.x = -x or self.x
    self.y = y or self.y
end

function camera:setScale(sx, sy)
    self.scaleX = sx or self.scaleX
    self.scaleY = sy or self.scaleY
end

function camera:setLockedResolution(w, h)
    self.width = w or self.width
    self.height = h or self.height
    local window_width, window_height, flags = love.window.getMode()
    if window_width / window_height < self.width / self.height then
        self.scaleX = window_width / self.width
        self.scaleY = self.scaleX
        camera:setPosition(0, (window_height - (window_width / (self.width / self.height))) / 2)
    elseif window_width / window_height > self.width / self.height then
        self.scaleX = window_height / self.height
        self.scaleY = self.scaleX
        camera:setPosition((window_width - (window_height * (self.width / self.height))) / 2, 0)
    end
end

return camera
