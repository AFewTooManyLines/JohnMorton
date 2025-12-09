-- defaults:
love.graphics.setDefaultFilter("nearest", "nearest")

-- source:
local player = require("Source.Player")
local flashlight = require("Source.Flashlight")
local weapons_info = require("Source.WeaponsInfo")
local player_cam = require("Source.PlayerCam")
local camera_module = require("Source.PlayerCam")
local UI_handler = require("Source.UI.Handler")
local settings = require("Source.GameSettings")
local enemy_handler = require("Source.EnemyHandler")

-- libraries:
local push = require("Libraries.push")
local dialogue = require("Libraries.talkies")
local shack = require("Libraries.shack")
local tiled = require("Libraries/sti")
local timer = require("Libraries.timer")

-- maps and enemy handler:
local map_sorter = require("Source.MapSorter")
local maps_table = {}

local map = nil
local last_map = map
local run_once_enemy_function = false

local spawned_enemies = {}

-- setup:
local main_timer = nil

local time = 0

local window_x, window_y = love.graphics.getDimensions()
window_x, window_y = window_x*1.3, window_y*1.3

push:setupScreen(800, 600, window_x, window_y, {
    fullscreen = false,
    resizable = false,
    highdpi = true,
    canvas = true
})

local w,h = push:getDimensions()

local menu_items = {}

local running_menu = nil
local running_menu2 = nil

local running_music_track = nil

-- main:
function love.load()
      -- load timer:
      main_timer = timer.new()

      -- loading modules:
      menu_items = UI_handler.load_all()

      for i,v in pairs(map_sorter.maps) do
            maps_table[i] = tiled(map_sorter.maps[i].path)
      end

      map_sorter.selected_map = "main_menu"
      map = maps_table[map_sorter.selected_map]      

      -- loading main menu:
      running_menu = menu_items.main_menu

      if running_music_track then
            running_music_track:setLooping(true)
            love.audio.play(running_music_track)            
      end

      camera_module:load()
      player:load()
      flashlight:load()

      -- setting up screen:
      shack:setDimensions(push:getDimensions())

      -- shaders:
      colour_shift_shader = love.graphics.newShader("Source/Shaders/ColourShift.fs")
      pixel_shift_shader = love.graphics.newShader("Source/Shaders/PixelShift.fs")
      manager_shader = love.graphics.newShader("Source/Shaders/ManagerShader.fs")

      -- dialogue setup:
      dialogue.font = love.graphics.newFont("Fonts/Pixel_Unicode.ttf", 35)

      -- sorting enemies:

      -- test:
      --enemy_handler:create_enemy("test", "normal", "right", {400; 300}, "hallway_map1", maps_table["hallway_map1"])
      
      for i,v in pairs(map_sorter.maps) do
            if v.extras and v.extras.enemy_info then
                  for t,g in ipairs(v.extras.enemy_info) do
                        enemy_handler:create_enemy(g[1],g[2],g[3],g[4],i,maps_table[i])
                  end
            end
      end
end

function love.update(dt)

      colour_shift_shader:send("shift", 2.5 + math.cos(love.timer.getTime() * math.pi * 2) * 0.5)
      pixel_shift_shader:send("shift", 2.5 + math.sin(love.timer.getTime() * math.pi * 2) * 0.5)
      manager_shader:send("time", love.timer.getTime() * 5)

      if UI_handler.states.game_state ~= "paused_menu" and UI_handler.states.game_state ~= "paused_settings" then

            if UI_handler.states.game_state == "playing" then
                  player:update(dt)
                  flashlight:update(dt)

                  player.isMoving = false

                  running_menu = menu_items[UI_handler.states.menu_state]

                  if UI_handler.states.menu_state == "HUD" then
                        running_menu2 = menu_items[UI_handler.states.secondary_menu_state]
                  end

            elseif UI_handler.states.game_state == "main_menu" then
                  running_menu = menu_items[UI_handler.states.menu_state]

            else
                  if UI_handler.states.game_state ~= "paused_menu" and UI_handler.states.game_state ~= "paused_settings" then
                        running_menu = menu_items[UI_handler.states.game_state]
                  end
            end

            if map_sorter.maps[map_sorter.selected_map].music and running_music_track ~= map_sorter.maps[map_sorter.selected_map].music then
                  
                  running_music_track = map_sorter.maps[map_sorter.selected_map].music

                  if running_music_track ~= nil then
                        if settings.music_enabled then
                              running_music_track:setLooping(true)
                              love.audio.play(running_music_track)
                              print("works")
                        end
                  end
            end

            if settings.music_enabled == false then
                  running_music_track = nil      
            end

            -- enemy handler:
            enemy_handler:update(dt)

            -- map:
            if map == nil or map_sorter.selected_map ~= last_map then
                  map = maps_table[map_sorter.selected_map]
                  last_map = map_sorter.selected_map
                  
                  run_once_enemy_function = false
                  spawned_enemies = {}
            end
            
            if running_menu then
                  running_menu:update(dt)
            end

            if running_menu2 then
                  running_menu2:update(dt)
            end

            dialogue.update(dt)
            shack:update(dt)
            camera_module:update(dt)

            if map then
                  map:update(dt)
                  
                  player.y_offset = map_sorter.maps[map_sorter.selected_map].player_y_offset
                  
                  local mapW = map.width / map.tilewidth

                  -- camera boundaries:
                  local camera_left_boundary = map_sorter.maps[map_sorter.selected_map].camera_scaling[1]
                  local camera_right_boundary = map_sorter.maps[map_sorter.selected_map].camera_scaling[2]

                  -- left boundary:
                  if player_cam.camera.x > (mapW - w * camera_left_boundary) then
                        player_cam.camera.x = mapW - w * camera_left_boundary
                  end

                  -- right boundary:
                  if player_cam.camera.x < (mapW - w * camera_right_boundary) then
                        player_cam.camera.x = mapW - w * camera_right_boundary
                  end
                  
                  -- map boundary collisions:
                  if player.in_cutscene == false then
                        -- left boundary:
                        if player.x < (mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[1]) then
                              player.x = mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[1]

                              if map_sorter.maps[map_sorter.selected_map].level_load.left then
                                    
                                    map_sorter.selected_map = map_sorter.maps[map_sorter.selected_map].level_load.left
                                    player.x = -(mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[2])
                              end
                        end

                        -- right boundary:
                        if player.x > -(mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[2]) then
                              player.x = -(mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[2])

                              if map_sorter.maps[map_sorter.selected_map].level_load.right then
                                    map_sorter.selected_map = map_sorter.maps[map_sorter.selected_map].level_load.right
                                    player.x = mapW - w * map_sorter.maps[map_sorter.selected_map].border_collisions[1]
                              end
                        end
                  end
            end

      else
            menu_items[UI_handler.states.game_state]:update(dt)
      end
end

function love.mousepressed(x, y, button, isTouch)
      if UI_handler.states.game_state == "playing" then
         player:detectMouseClick(button)   
      end
end

function love.keypressed(key, scancode, isrepeat)
    -- window:
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    -- pause:
    if UI_handler.states.menu_state == "HUD" then
            if key == "escape" then
                  if UI_handler.states.game_state == "paused_menu" then
                        UI_handler.states.game_state = "playing"
                        player.game_paused = false
                  else
                        UI_handler.states.game_state = "paused_menu"
                        player.game_paused = true
                  end
            end
      end

    -- dialogue:
    if key == "return" then
      dialogue.onAction()
    end

    if key == "up" then
      dialogue.prevOption()
    
      elseif key == "down" then
      dialogue.nextOption()
    end

    -- modules:
    if UI_handler.states.game_state == "playing" then
      flashlight:keypressed(key)
    end
end

function love.resize(w,h)
      push:resize(w,h)

      if map then
            map:resize(w,h)
      end
end
  
function love.draw()
      push:start()

      local scaleX = map_sorter.maps[map_sorter.selected_map].scaling[1]
      local scaleY = map_sorter.maps[map_sorter.selected_map].scaling[2]

      shack:apply()

      love.graphics.setColor(1, 1, 0)

      -- visuals:
      if settings.shaders_enabled then
            push:setShader({colour_shift_shader, pixel_shift_shader;})
      else
            push:setShader()       
      end

      -- default background:
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("fill", 0, 0, 800, 700)
      love.graphics.setColor(1, 1, 1)
      
      -- static layers:
      if map and map_sorter.maps[map_sorter.selected_map].static == true then
            map:draw(0, 0, scaleX, scaleY)
      end

      -- CAMERA SETUP BLOCK:
      camera_module.camera:set()

      -- drawing moving layers:

      if map and map_sorter.maps[map_sorter.selected_map].static == false then
            love.graphics.push()

            love.graphics.scale(scaleX, scaleY)

            for i, v in ipairs(map.layers) do
                  map:drawLayer(v)
            end

            love.graphics.pop()
      end

      -- enemies:
      enemy_handler:draw()

      -- player:
      if UI_handler.states.game_state == "playing" or UI_handler.states.game_state == "paused_menu" or UI_handler.states.game_state == "paused_settings" then
            player:draw()
      end

      -- CAMERA END
      camera_module.camera:unset()

      -- filter:
      love.graphics.setColor(0.2, 0.2, 0.2, 0.35)
      love.graphics.rectangle("fill", 0, 0, 800, 600)
      love.graphics.setColor(1, 1, 1)

      love.graphics.setColor(1, 1, 1)

      if running_menu then
            running_menu:draw()
      end

      if running_menu2 then
            running_menu2:draw()
      end

      -- camera block to draw flashlight over everything:
      camera_module.camera:set()

      if UI_handler.states.game_state == "playing" or UI_handler.states.game_state == "paused_menu" or UI_handler.states.game_state == "paused_settings" then
            flashlight:drawLight()
      end

      camera_module.camera:unset()

      dialogue:draw()

      -- paused screen drawn over everything:
      if UI_handler.states.game_state == "paused_menu" or UI_handler.states.game_state == "paused_settings" then
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", 0, 0, w, h)
            menu_items[UI_handler.states.game_state]:draw()
      end

      -- player mouse:
      local mousex, mousey = push:toGame(love.mouse.getX(), love.mouse.getY())

      love.graphics.setColor(1, 1, 1)

      if mousex and mousey and UI_handler.states.game_state == "playing" then
            if player.equipped_gun ~= nil and player.holding_flashlight then
                  love.graphics.circle("fill", mousex, mousey, weapons_info[player.equipped_gun].crosshair_radius)
            end
      end

      push:finish()

      love.graphics.setShader()
end