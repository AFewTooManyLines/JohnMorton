local camera_module = require("Libraries.camera")
local push = require("Libraries.push")
local player = require("Source.Player")

local w, h = 800,600

player_cam = {
    ["camera"] = nil;
    ["x_offset"] = 120;
}

function player_cam:load()
    player_cam.camera = camera_module
    
    player_cam.camera:setLockedResolution(push:getDimensions())
    player_cam.camera:setScale(1,1)
end

function player_cam:update(dt)
    if not player.in_cutscene then
        player_cam.camera:setPosition(player.x - player_cam.x_offset, 0)
        player_cam.camera:move(dt)
    end
end

return player_cam