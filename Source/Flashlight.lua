local player = require("Source.Player")
local animation_module = require("Libraries.anim8")

local offset_x1 = 444
local offset_x2 = 844
local offset_y = -15

flashlight = {
    x = player.x - offset_x2;
    y = player.y - offset_y;

    ["light"] = nil;
    ["current_anim_tab"] = nil;

    ["animations"] = {
        ["right"] = love.graphics.newImage("Source/Spritesheets/PlayerLightRightMotion.png");
        ["left"] = love.graphics.newImage("Source/Spritesheets/PlayerLightLeftMotion.png");
    };

    ["occluders"] = {};
}

function flashlight:load()
    flashlight.current_anim_tab = flashlight.animations.right

    local g = animation_module.newGrid(100, 100, flashlight.current_anim_tab:getWidth(), flashlight.current_anim_tab:getHeight())
    flashlight.light = animation_module.newAnimation(g('1-4', 1), player.animation_speed)

    local w,h = flashlight.light:getDimensions()
    flashlight.width = w
    flashlight.height = h
end

function flashlight:update(dt)
    if player.direction == "right" then
        flashlight.x = player.x - offset_x1

    elseif player.direction == "left" then
        flashlight.x = player.x - offset_x2
    end

    flashlight.y = player.y - offset_y

    if player.isMoving == true then
        flashlight.current_anim_tab = flashlight.animations[player.direction]
        flashlight.light:resume()

    else
        flashlight.light:pauseAtStart()
    end

    flashlight.light:update(dt)
end

function flashlight:drawLight(x, y)
    if player.holding_flashlight == true then
        love.graphics.setColor(1,1,1,128)
        flashlight.light:draw(flashlight.current_anim_tab, flashlight.x, flashlight.y + player.y_offset, 0, 15, 5)
    end
end

function flashlight:keypressed(key)
    if key == "f" then
        if player.in_cutscene == false then
            
            player.holding_flashlight = not player.holding_flashlight

            if player.holding_flashlight == true then
                player.current_anim_tab = player.animations.torch_held_walk[player.direction] 
            else    
                player.current_anim_tab = player.animations.normal_walk[player.direction]
            end
        end
    end
end

return flashlight