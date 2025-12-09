local animation_module = require("Libraries.anim8")
local shack = require("Libraries.shack")
local timer = require("Libraries.timer")
local push = require("Libraries.push")
local weapons_info = require("Source.WeaponsInfo")

local gun_timer = timer.new()

player = {

    x = 250;
    y = 160;

    ["y_offset"] = 0;

    ["max_health"] = 200;
    ["max_flashlight_charge"] = 100;

    ["health"] = 200; -- max is 200
    ["flashlight_charge"] = 100; -- max is 100
    
    ["speed"] = 5;

    ["in_cutscene"] = false;
    ["game_paused"] = false;

    ["holding_flashlight"] = false;
    ["isMoving"] = false;
    ["is_Shooting"] = false;

    ["equipped_gun"] = "revolver";

    ["animations"] = {

        ["normal_walk"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_Right.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_Left.png");
        };

        ["torch_held_walk"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_Torch_Right.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_Torch_Left.png");
        };
    };

    ["current_anim_tab"] = nil;
    ["animation"] = nil;
    ["secondary_animation"] = nil;
    ["animation_speed"] = 0.2;
    ["direction"] = "left";
}

function player:load()
    -- setup:
    player.current_anim_tab = player.animations.normal_walk[player.direction]

    local g = animation_module.newGrid(100, 100, player.current_anim_tab:getWidth(), player.current_anim_tab:getHeight())
    local movement_animation = animation_module.newAnimation(g('1-4', 1), player.animation_speed)

    -- revolver spritesheet is used as reference for the grid:
    local c = animation_module.newGrid(100, 100, weapons_info.revolver.animations.shooting.right:getWidth(), weapons_info.revolver.animations.shooting.right:getHeight())
    local shooting_animation = animation_module.newAnimation(c('1-2', 1), player.animation_speed)
    
    player.animation = movement_animation
    player.secondary_animation = shooting_animation
end

function player:update(dt)
    if player.game_paused == false then
        if player.in_cutscene == false then
                
            if love.keyboard.isDown("d") then
                
                player.animation:resume()

                player.isMoving = true
                player.direction = "right"

                player.x = player.x + player.speed*dt*60

            elseif love.keyboard.isDown("a") then
                
                player.animation:resume()

                player.isMoving = true
                player.direction = "left"

                player.x = player.x - player.speed*dt*60
            end

            if player.holding_flashlight and player.equipped_gun ~= nil then
                player.current_anim_tab = weapons_info[player.equipped_gun].animations.moving[player.direction]

            elseif player.holding_flashlight and player.equipped_gun == nil then
                player.current_anim_tab = player.animations.torch_held_walk[player.direction]

            else
                player.current_anim_tab = player.animations.normal_walk[player.direction]
            end
        end
    end

    if player.isMoving == false then
        player.animation:pauseAtStart()
    end

    player.animation:update(dt)
    player.secondary_animation:update(dt)
    
    gun_timer:update(dt)
end

function player:draw()
    if player.is_Shooting then
        player.secondary_animation:draw(player.current_anim_tab, player.x, player.y + player.y_offset, 0, 5.5, 6)
    
    elseif player.is_Shooting == false then
        player.animation:draw(player.current_anim_tab, player.x, player.y + player.y_offset, 0, 5.5, 6)
    end
end

function player:detectMouseClick(button)
    if button == 1 and player.holding_flashlight then
        if player.equipped_gun ~= nil then
            
            player.in_cutscene = true
            player.is_Shooting = true

            shack:setShake(weapons_info[player.equipped_gun].shake_strength)

            if player.direction == "right" then
                player.x = player.x - weapons_info[player.equipped_gun].recoil
                flashlight.x = flashlight.x - weapons_info[player.equipped_gun].recoil

            elseif player.direction == "left" then
                player.x = player.x + weapons_info[player.equipped_gun].recoil
                flashlight.x = flashlight.x + weapons_info[player.equipped_gun].recoil
            end

            love.audio.setVolume(weapons_info[player.equipped_gun].sound_volume)
            love.audio.play(love.audio.newSource(weapons_info[player.equipped_gun].shoot_sound, "static"))
            love.audio.setVolume(1)

            player.current_anim_tab = weapons_info[player.equipped_gun].animations.shooting[player.direction]
            player.secondary_animation:resume()

            gun_timer:after(0.3, function()
                player.is_Shooting = false
                player.secondary_animation:pauseAtStart()

                player.current_anim_tab = player.animations.torch_held_walk[player.direction]

                player.in_cutscene = false
            end)
        end
    end
end

return player