local animation_module = require("Libraries.anim8")
local player = require("Source.Player")
local push = require("Libraries.push")
local map_sorter = require("Source.MapSorter")
local flashlight = require("Source.Flashlight")

local enemies = {}

enemy_handler = {
    ["enemy_types"] = {
        ["normal"] = {
            ["max_health"] = 200;

            ["damage"] = {
                10;
                15;
                20;
            };

            ["animations"] = {
                ["left"] = love.graphics.newImage("Assets/episode1/characters/enemies/enemy_walk_left.png");
                ["right"] = love.graphics.newImage("Assets/episode1/characters/enemies/enemy_walk_right.png");
            };

            ["speed"] = 120;
        };

        ["stronger_guy"] = {
            ["max_health"] = 100;

            ["damage"] = {
                20;
                30;
                40;
            };

            ["animations"] = {
                ["left"] = "";
                ["right"] = "";
            };

            ["speed"] = 120;
        };
    };
}

local function isMouseInside(element)
    -- getting mouse coords:
    local mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())

    -- mouse collision rectangle:
    local mouse_rectangle = {x = mouseX, y = mouseY, width = 40, height = 40}

    if mouseX and mouseY then
        if mouse_rectangle.x + mouse_rectangle.width / 2 <= element.x + element.width and mouse_rectangle.x + mouse_rectangle.width / 2 >= element.x and mouse_rectangle.y + mouse_rectangle.height <= element.y + element.height and mouse_rectangle.y + mouse_rectangle.height >= element.y then
            return true
        end
    end
end


function enemy_handler:create_enemy(id, enemy_type, starting_animation_type, pos, current_map, tiled_map)
    -- new enemy object:
    local new_enemy = {}
    new_enemy.id = id or "#"..tostring(love.timer.getTime)
    new_enemy.type = enemy_handler.enemy_types[enemy_type]

    new_enemy.allocated_map = current_map
    new_enemy.local_map = {width = tiled_map.width, height = tiled_map.height}
    
    new_enemy.x = pos[1]
    new_enemy.y = pos[2]

    new_enemy.max_health = new_enemy.type.max_health
    new_enemy.health = new_enemy.max_health
    new_enemy.damage = new_enemy.type.damage

    new_enemy.speed = math.random(40, new_enemy.type.speed)
    
    new_enemy.isMoving = true
    new_enemy.direction = starting_animation_type
    new_enemy.animation_speed = 0.2;
    new_enemy.currentAnimTab = new_enemy.type.animations[starting_animation_type] or new_enemy.type.animations["right"]

    local sheet_grid = animation_module.newGrid(200, 300, new_enemy.currentAnimTab:getWidth(), new_enemy.currentAnimTab:getHeight())
    local animation = animation_module.newAnimation(sheet_grid('1-8',1), new_enemy.animation_speed)

    new_enemy.animation = animation

    table.insert(enemies, new_enemy)
end

function enemy_handler:destroy(id, request_type)
    if request_type == "manual" then
        for i,v in ipairs(enemies) do
            if v.id == id then
                table.remove(enemies,i)
            end
        end
    
    elseif request_type == "all" then
        enemies = {}
    end
end

function enemy_handler:update(dt)
    for i,enemy in ipairs(enemies) do
        if enemy.allocated_map == map_sorter.selected_map then

            -- enemy AI:
            local direction_x = (player.x - enemy.x + 150)
            local direction_y = (player.y - enemy.y)

            local distance = math.sqrt(direction_x^2 + direction_y^2)

            if distance > 0.4 then
                direction_x = direction_x / distance
                direction_y = direction_y / distance

                enemy.x = enemy.x + direction_x*enemy.speed*dt
                enemy.y = enemy.y + direction_y*enemy.speed*dt
            else
                enemy.isMoving = false
                enemy.currentAnimTab = enemy.type.animations[enemy.direction]
            end

            if player.x + 150 > enemy.x and distance > 0.4 then
                enemy.isMoving = true
                enemy.currentAnimTab = enemy.type.animations.right

            elseif player.x < enemy.x - 150 and distance > 0.4 then
                enemy.isMoving = true
                enemy.currentAnimTab = enemy.type.animations.left
            end

            if enemy.isMoving == false then
                enemy.animation:pauseAtStart()
            else
                enemy.animation:resume()
            end

            -- player aim handling:
            local w,h = enemy.animation:getDimensions()

            if isMouseInside({x = enemy.x - 150, y = enemy.y, width = enemy.x + w, height = enemy.y + h}) then
                --print("shooting range")
                
                if player.is_Shooting then
                    enemy.health = enemy.health - 10
                end
            end

            enemy.animation:update(dt)
        end
    end
end

function enemy_handler:draw()
    for i,enemy in ipairs(enemies) do
        if enemy.allocated_map == map_sorter.selected_map then
            enemy.animation:draw(enemy.currentAnimTab, enemy.x, enemy.y + 80, 0, 1, 1)

            local w, h = enemy.animation:getDimensions()

            --love.graphics.rectangle("line",enemy.x, enemy.y, w, h)

            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", enemy.x, enemy.y - 5, enemy.max_health, 23)
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", enemy.x, enemy.y - 5, enemy.health, 23)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.printf(tostring(math.floor((enemy.health / 200) * 100)) .. "%", enemy.x, enemy.y - 5, 60, "left")
            love.graphics.setColor(1, 1, 1, 1)

            
            if enemy.health <= 0 then
                enemy_handler:destroy(enemy.id,"manual")
            end
        end
    end
end

return enemy_handler