local component = require("Libraries.badr")
local map_sorter = require("Source.MapSorter")
local player = require("Source.Player")
local weapons_list = require("Source.WeaponsInfo")
local settings = require("Source.GameSettings")
local dialogue_sorter = require("Source.DialogueSorter")
local dialogue_system = require("Libraries.talkies")
local timer = require("Libraries.timer")

UI = {elements = {};}

local width, height = 800,600

local selected_scene_after_blackout = nil
local selected_map_after_blackout = nil

local previous_font = nil

local fonts = {
    ["default_font"] = "Fonts/Pixel_Unicode.ttf";
    ["dialogue_font"] = "Fonts/monogram_extended_custom.ttf";
    ["title_font"] = "Fonts/fusion-pixel-8px.ttf";
}

local sounds = {
    ["select"] = "Sound/select_sound.mp3";
    ["click"] = "Sound/click_sound.mp3";
    ["bell_and_crows_ambience"] = "Sound/ambience/crows_and_bell.mp3";
}

local function find_element(m,id)
    for i,v in ipairs(m.children) do
        if v.id then
            if v.id == id then
                return v
            end
        end
    end
end

local function Hex(hex, value)
    return {
        tonumber(string.sub(hex, 2, 3), 16) / 256, 
        tonumber(string.sub(hex, 4, 5), 16) / 256,
        tonumber(string.sub(hex, 6, 7), 16) / 256, 
        value or 1
    }
end

local function line(options)
    return component {
        colour = options.colour or Hex('#eb3313e3');
        width = options.width;
        height = options.height;
        opacity = options.opacity or 1;

        draw = function(self)
            love.graphics.setColor(self.colour,self.opacity)
            love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
            love.graphics.setColor(1,1,1,self.opacity)
        end
    }
end

local function label(options)
    local _font = love.graphics.newFont(options.font or fonts.default_font, options.font_size or 30) or love.graphics.getFont()
    local colour = options.colour or {0, 0, 0}

    return component {
        text = options.text or options,
        visible = options.visible or true,
        id = options.id,
        
        width = _font:getWidth(options.text or options),
        height = _font:getHeight(options.text or options),
        opacity = options.opacity or 1,
        onClick = options.onClick or nil,
        loop_function = options.onUpdate or nil,
        hoverColour = options.hoverColour or Hex('#707070fd'),
        font = _font,

        -- logic:
        onHover = options.onHover,
        hovered = false,
        hoverCalled = false,

        onUpdate = function(self)
            if self.loop_function then
                self.loop_function()
            end

            if love.mouse.isDown(1) then
                if self.mousePressed == false and self:isMouseInside() and self.parent.visible then
                    self.mousePressed = true
                    if options.onClick then
                        self:onClick()
                        love.audio.play(love.audio.newSource(sounds.click, "static"))
                    end
                end
            else
                self.mousePressed = false
            end
        end,

        draw = function(self)
            if not self.visible then
                return
            end

            love.graphics.setColor(colour[1], colour[2], colour[3], options.opacity)

            if self.onClick then
                if self:isMouseInside() then
                    
                    if not self.hoverCalled then
                        love.audio.play(love.audio.newSource(sounds.select, "static"))

                        if self.onHover then
                            self.onMouseExit = self.onHover(self)
                        end

                        self.hoverCalled = true
                    end

                    love.mouse.setCursor(love.mouse.getSystemCursor('hand'))
                    love.graphics.setColor(self.hoverColour[1], self.hoverColour[2], self.hoverColour[3], self.opacity)
                    self.hovered = true

                elseif self.hovered then
                    love.mouse.setCursor()

                    if self.onMouseExit then
                        self.onMouseExit()
                    end

                    self.hovered = false
                    self.hoverCalled = false
                end
            end

            love.graphics.setFont(self.font)
            love.graphics.print(self.text, self.x, self.y)
            love.graphics.setColor(1, 1, 1)
        end
    }
end

UI.states = {
    game_state = "main_menu";
    menu_state = "menu";
    secondary_menu_state = "none";
}

UI.load_all = function()
    local menu_tab = {}

    for i,v in pairs(UI.elements) do
        local menu = v.load()
        menu_tab[i] = menu
    end

    return menu_tab
end

UI.elements.menu = {
    ["load"] = function()

        love.graphics.setFont(love.graphics.newFont(fonts.default_font), 35)

        local menu = component {column = true, gap = 12}

            + line {
                width = 350;
                height = 2;

                colour = Hex('#692e2eff')
            }        

            + label {
                text = "JOHN MORTON";

                width = 200;
                height = 20;

                colour = Hex('#f71616ff');
                opacity = 0.85;

                font = fonts.title_font;
                font_size = 65;
            }

            + line {
                width = 350;
                height = 2;

                colour = Hex('#692e2eff')
            }
        
            + label {
                text = "START";

                width = 200;
                height = 20;

                colour = Hex('#C72C41');
                opacity = 1;

                onClick = function()
                    love.audio.stop()
                    
                    love.audio.play(love.audio.newSource(sounds.bell_and_crows_ambience, "static"))

                    UI.states.menu_state = "menu"
                    UI.states.game_state = "transition"
                end;
            }

            + label {
                text = "SETTINGS";

                width = 200;
                height = 20;

                colour = Hex('#C72C41');
                opacity = 1;

                onClick = function()
                    UI.states.menu_state = "settings"
                end;
            }

            + label {
                text = "QUIT";

                width = 200;
                height = 20;

                colour = Hex('#C72C41');
                opacity = 1;

                onClick = function()
                    UI.states.menu_state = "menu"
                    love.event.quit()
                end;
            }

            + line {
                width = 350;
                height = 2;
        
                colour = Hex('#692e2eff')
            }

        menu:updatePosition(width * 0.5 - 350, height * 0.5 - menu.height * 0.5)
        
        return menu
    end;
}

UI.elements.transition = {
    ["load"] = function()
        
        local render = {}

        local transition_timer = timer.new()

        local transition1 = false
        local transition2 = false
        local transition3 = false

        local set_map = false

        local function draw()
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, width, height)
            love.graphics.setColor(1, 1, 1)
        end

        local function draw2()
            love.graphics.setFont(love.graphics.newFont(fonts.title_font, 50))
            love.graphics.print("EPISODE 1", width - width / 2 - 105, height - height / 2 - 35)
            love.graphics.setColor(1, 1, 1)
        end

        function render:draw()

            love.graphics.setColor(1, 0, 0)

            if transition1 == false then
                transition_timer:after(4, function()
                    draw2()
                    transition1 = true
                end)
            else
                draw2()

                if transition2 == false then

                    transition_timer:after(5, function()
                        draw()
                        transition2 = true

                        if transition3 == false then
                            transition_timer:after(6, function()
                                
                                UI.states.game_state = "playing"
                                UI.states.menu_state = "HUD"
                                
                                player.in_cutscene = true
                                player.x = -500
                                
                                transition3 = true
                            end)
                        end
                    end)
                else
                    draw()
                    
                    if set_map == false then
                        
                        map_sorter.selected_map = "west_corridor_map"
                        set_map = true
                    end
                end
            end
        end

        function render:update(dt) 
            transition_timer:update(dt)
        end

        return render
    end
}

UI.elements.intro = {
    ["load"] = function()
        local render = {}
        local text_timer = timer.new()

        local default_colour = Hex('#C72C41')
        local wait_time = 6
        
        -- murder scenes:
        local t1 = false
        local t5 = false        

        local timer_points = {
            false;
            false;
        }

        local messages = dialogue_sorter.intro.script

        local function draw_text(text, y_offset)
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height/2 - y_offset, 700, "center")
        end

        local function draw_text2(text, y_offset)
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 75, height - height/2 - y_offset, 700, "center")
        end

        local function draw_heading(text, y_offset)
            love.graphics.setFont(love.graphics.newFont(fonts.title_font, 50))
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height / 2 - y_offset, 700, "center")
        end

        function render:draw()

            love.graphics.setFont(love.graphics.newFont(fonts.default_font, 35))

            love.graphics.setColor(default_colour[1],default_colour[2],default_colour[3])
            
            
            if t1 == false then
                for i = 1, #timer_points do
                    if timer_points[i] == false then
                        text_timer:after((i == 1 and 7 or wait_time), function()
                            draw_text(messages[i][1], messages[i][2])
                            timer_points[i] = true

                            if i == #timer_points then

                                text_timer:after(5, function()
                                    t1 = true
                                    t5 = true
                                end)
                            end
                        end)
                        
                        break
                    else
                        draw_text(messages[i][1], messages[i][2])
                    end
                end
            end

            if t5 == true then
                love.audio.pause()
                
                love.graphics.setColor(0,0,0)
                love.graphics.rectangle("fill",0,0,width,height)
                
                love.graphics.setColor(default_colour[1], default_colour[2], default_colour[3])

                text_timer:after(5, function()
                    selected_scene_after_blackout = "office_scene"
                    selected_map_after_blackout = "office_map"
                    UI.states.menu_state = "blackout"
                end)
            end
        end

        function render:update(dt)
            text_timer:update(dt)
        end

        return render
    end;
}

UI.elements.HUD = {
    ["load"] = function()
        local render = {}

        local runOnce = false

        local height_row = height - height / 2 + 230

        local default_font = love.graphics.newFont(fonts.default_font,25)

        local health_icon = love.graphics.newImage("Assets/episode1/Images/health_icon.png")
        local flashlight_icon = love.graphics.newImage("Assets/episode1/Images/flashlight_icon.png")

        function render:draw()
            if runOnce == false then
                player.in_cutscene = false
                player.direction = "right"

                player.x = 250
                player.y = 160

                UI.states.secondary_menu_state = "basics"

                runOnce = true
            end

            love.graphics.setFont(default_font)

            -- health bar:
            love.graphics.setColor(0.5,0.5,0.5)
            love.graphics.rectangle("line", 50, height_row - 30, player.max_health, 23)
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", 50, height_row - 30, player.health, 23)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(health_icon, 7, height_row - 30, 0, 0.05, 0.05)
            love.graphics.printf(tostring(math.floor((player.health / 200) * 100)).."%", 50, height_row - 30, 60, "left")

            -- flashlight:
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", 50, height_row, player.max_flashlight_charge, 23)
            love.graphics.setColor(0, 0, 0.5, 0.5)
            love.graphics.rectangle("fill", 50, height_row, player.flashlight_charge, 23)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(flashlight_icon, 7, height_row, 0, 0.05, 0.05)
            love.graphics.printf(tostring(math.floor((player.flashlight_charge / 100) * 100)).."%", 50, height_row, 60, "left")

            -- weapon UI:
            love.graphics.setColor(0.5,0.5,0.5)
            love.graphics.draw(weapons_list[player.equipped_gun].icon, 650, height_row - 55, 0, 0.2, 0.2)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(tostring(weapons_list[player.equipped_gun].current_loaded_ammo).."/"..tostring(weapons_list[player.equipped_gun].current_stored_ammo),700, height_row, 60, "left")
        end

        function render:update(dt)
            
        end

        return render
    end;
}

UI.elements.basics = {
    ["load"] = function()
        
        local render = {}

        local text_timer = timer.new()

        local default_colour = Hex('#C72C41')
        local tutorial_colour = Hex('#a08906f7')

        local voiceover_script = dialogue_sorter.basics.script
        local tutorial_text = dialogue_sorter.basics.tutorial

        local t1 = false
        local t2 = false
        local t3 = false

        local first_voiceover_section = {
            false;
            false;
            false;
        }

        local wait_time = 5

        local function draw_bottom_text(text)
            love.graphics.setColor(tutorial_colour[1],tutorial_colour[2],tutorial_colour[3])
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 60, height - height / 2 + 230, 700, "center")
        end

        local function draw_text(text, y_offset)
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height / 2 - y_offset, 700, "center")
        end

        function render:draw()
            if map_sorter.selected_map == "hallway_map1" then
                if t1 == false then

                    love.graphics.setColor(default_colour[1], default_colour[2], default_colour[3])

                    for i = 1, #first_voiceover_section do
                        if first_voiceover_section[i] == false then
                            text_timer:after((i == 1 and 4 or wait_time), function()

                                draw_text(voiceover_script[i][1], voiceover_script[i][2])
                                first_voiceover_section[i] = true

                                if i == #first_voiceover_section then
                                    text_timer:after(wait_time, function()
                                        t1 = true
                                    end)
                                end
                            end)

                            break
                        else
                            draw_text(voiceover_script[i][1], voiceover_script[i][2])
                        end
                    end
                end

                if t1 == true and t2 == false then
                    draw_bottom_text(tutorial_text[1])

                    text_timer:after(wait_time, function()
                        t2 = true
                    end)
                end

                if t2 == true and t3 == false then
                    draw_bottom_text(tutorial_text[2])

                    text_timer:after(wait_time, function()
                        t3 = true
                    end)
                end
            else
                UI.states.secondary_menu_state = "basics2"
            end
        end

        function render:update(dt)
            text_timer:update(dt)
        end

        return render
    end;
}

UI.elements.basics2 = {
    ["load"] = function()
        
        local render = {}

        local t1 = false
        local t2 = false
        local t3 = false

        local tutorial_text = dialogue_sorter.basics.tutorial
        local voiceover_text = dialogue_sorter.basics.script

        local default_colour = Hex('#C72C41')
        local tutorial_colour = Hex('#a08906f7')

        local wait_time = 5

        local text_timer = timer.new()

        local function draw_bottom_text(text)
            love.graphics.setColor(tutorial_colour[1], tutorial_colour[2], tutorial_colour[3])
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 60, height - height / 2 + 230, 700, "center")
        end

        function render:draw()
            if map_sorter.selected_map == "floor1_hallway_map" then
                if t1 == false then
                    draw_bottom_text(tutorial_text[3])

                    text_timer:after(wait_time, function()
                        t1 = true
                    end)
                end

                if t1 == true and t2 == false then
                    draw_bottom_text(tutorial_text[4])

                    text_timer:after(wait_time, function()
                        t2 = true
                    end)
                end

                if t2 == true and t3 == false then
                    draw_bottom_text(tutorial_text[5])

                    text_timer:after(wait_time, function()
                        t3 = true
                    end)
                end
            end
        end

        function render:update(dt)
            text_timer:update(dt)
        end

        return render
    end;
}

UI.elements.blackout = {
    ["load"] = function()
        
        local render = {}

        local screen_timer = timer.new()

        local scene_setting = dialogue_sorter.office_scene.setting

        local t1 = false
        local set_map = false

        local default_colour = Hex('#C72C41')

        local function draw_heading(text, y_offset)
            love.graphics.setFont(love.graphics.newFont(fonts.title_font, 50))
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height / 2 - y_offset, 700, "center")
        end

        function render:draw()
            if set_map == false then
                map_sorter.selected_map = selected_map_after_blackout
                set_map = true
            end

            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("fill",0,0,width,height)
            love.graphics.setColor(default_colour[1],default_colour[2],default_colour[3])

            draw_heading(scene_setting, 20)

            if t1 == false then
                screen_timer:after(5, function()
                    UI.states.menu_state = selected_scene_after_blackout
                    t1 = true
                end)
            end
        end

        function render:update(dt)
            screen_timer:update(dt)
        end

        return render
    end;
}

UI.elements.office_scene = {
    ["load"] = function()
        
        local render = {}

        -- default:
        local default_colour = Hex('#C72C41')
        local wait_time = 5

        local bruce_colour = Hex('#ffd900e3')

        -- scripts:
        local scene_setting = dialogue_sorter.office_scene.setting
        local voiceover_script = dialogue_sorter.office_scene.voiceover
        local bruce_script = dialogue_sorter.office_scene.Bruce
        local john_script = dialogue_sorter.office_scene.John
        local black_screen_script = dialogue_sorter.office_scene.black_screen_script

        -- timer:
        local scene_timer = timer.new()

        -- timer points. I know, this is as bad as it looks:
        local t1 = true 
        local t2 = false
        local t3 = false
        local t4 = false
        local t5 = true
        local t6 = true
        local t6_5 = false
        local t7 = false
        local t8 = true
        local t9 = true
        local t10 = false
        local t11 = false
        local t11_5 = false
        local t12 = false
        local t13 = false
        local t14 = false
        local t14_5 = true
        local t15 = false
        local t16 = false
        local t16_5 = true
        local t17 = false
        local t18 = false

        local first_voiceover_section = {
            false;
            false;
            false;
            false;
        }
        
        local second_voice_section = {
            false;
            false;
        }

        local third_voice_section = {
            false;
        }

        local fourth_voice_section = {
            false;
            false;
        }

        local fifth_voice_section = {
            false;
            false;
            false;
        }
        
        -- characters:
        local bruce_char = love.graphics.newImage("Assets/episode1/characters/BruceTalking.png")
        local scale_symbol = -1

        -- drawing:
        local function draw_bottom_text(text)
            love.graphics.setFont(love.graphics.newFont(fonts.default_font, 25))
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 60, height - height / 2 + 230, 700, "center")
        end

        local function draw_text(text, y_offset)
            love.graphics.setFont(love.graphics.newFont(fonts.default_font, 25))
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height / 2 - y_offset, 700, "center")
        end

        local function draw_heading(text, y_offset)
            love.graphics.setFont(love.graphics.newFont(fonts.title_font, 50))
            love.graphics.printf(text, width * 0.5 - width * 0.5 + 55, height - height / 2 - y_offset, 700, "center")
        end

        -- At this point I just don't care.
        function render:draw()

            love.graphics.draw(bruce_char, 150, 300, 0, -1/scale_symbol, 1, 100, 50)
            
            love.graphics.setFont(love.graphics.newFont(fonts.default_font, 30))
            love.graphics.setColor(default_colour[1], default_colour[2], default_colour[3])

            player.in_cutscene = true

            player.y = 160
            player.x = 300

            -- voiceover section 1:
            if t3 == false and t1 == true then
                for i = 1, #first_voiceover_section do
                    if first_voiceover_section[i] == false then
                        scene_timer:after((i == 1 and 4 or wait_time), function()

                            t2 = true

                            draw_text(voiceover_script[i][1], voiceover_script[i][2])
                            first_voiceover_section[i] = true

                            if i == #first_voiceover_section then
                                scene_timer:after(wait_time, function()
                                    t3 = true
                                end)
                            end
                        end)

                        break
                    else
                        draw_text(voiceover_script[i][1], voiceover_script[i][2])
                    end
                end
            end

            -- bruce dialogue 1:
            if t4 == false and t3 == true then
                dialogue_system.talkSound = love.audio.newSource("Sound/talk_sound.wav", "static")
                dialogue_system.titleColor = bruce_colour
                dialogue_system.messageColor = bruce_colour

               dialogue_system.say("Bruce",{bruce_script[1]},{oncomplete = function()
                    t5 = false
               end})

               t4 = true
            end

            -- John dialogue 1:
            if t4 == true and t5 == false then
                dialogue_system.titleColor = default_colour
                dialogue_system.messageColor = default_colour

                dialogue_system.say("John",{john_script[1]},{oncomplete = function()
                    t5 = true
                    t6 = false
                end})

                t5 = true
            end

            -- voiceover:
            if t5 == true and t6 == false then
                for i = 1, #second_voice_section do
                    if second_voice_section[i] == false then
                        scene_timer:after((i == 1 and 1 or wait_time), function()

                            draw_text(voiceover_script[4+i][1], voiceover_script[4+i][2])
                            second_voice_section[i] = true

                            if i == #second_voice_section then
                                scene_timer:after(wait_time, function()
                                    t6 = true
                                    t6_5 = true
                                end)
                            end
                        end)

                        break
                    else
                        draw_text(voiceover_script[4+i][1], voiceover_script[4+i][2])
                    end
                end
            end

            -- bruce dialogue 2:
            if t6 == true and t6_5 == true and t7 == false then
                dialogue_system.titleColor = bruce_colour
                dialogue_system.messageColor = bruce_colour

                dialogue_system.say("Bruce",{bruce_script[2]},{oncomplete = function()
                    t8 = false
                end})

                t7 = true
            end

            -- bruce turn around:
            if t7 == true and t8 == false then
                scene_timer:after(2, function()
                    scale_symbol = 1

                    scene_timer:after(2, function()
                        t9 = false
                    end)
                end)

                t8 = true
            end

            -- bruce dialogue 3:
            if t8 == true and t9 == false then
                --dialogue_system.textSpeed = "slow"

                scene_timer:after(2, function()
                    dialogue_system.say("Bruce", {bruce_script[3]}, {
                        oncomplete = function()
                            t10 = true
                        end
                    })
                end)

                t9 = true
            end

            -- voiceover:
            if t9 == true and t10 == true then
                for i = 1, #third_voice_section do
                    if third_voice_section[i] == false then
                        scene_timer:after((i == 1 and 1 or wait_time), function()

                            draw_text(voiceover_script[6 + i][1], voiceover_script[6 + i][2])
                            third_voice_section[i] = true

                            if i == #third_voice_section then
                                scene_timer:after(wait_time, function()
                                    t10 = false
                                    t11 = true
                                    t11_5 = true
                                end)
                            end
                        end)

                        break
                    else
                        draw_text(voiceover_script[6 + i][1], voiceover_script[6 + i][2])
                    end
                end                 
            end

            -- bruce turn around:
            if t11 == true and t11_5 == true then
                scene_timer:after(2, function()
                    scale_symbol = -1

                    scene_timer:after(2, function()
                        t12 = true
                    end)
                end)

                t11 = false
            end

            -- bruce dialogue 4:
            if t12 == true and t11 == false and t11_5 == true then
                dialogue_system.say("Bruce",{bruce_script[4]},{oncomplete = function()
                    t13 = true
                    t12 = false
                end})

                t11_5 = false
            end

            -- voiceover:
            if t12 == false and t13 == true then
               for i = 1, #fourth_voice_section do
                    if fourth_voice_section[i] == false then
                        scene_timer:after((i == 1 and 1 or wait_time), function()

                            draw_text(voiceover_script[7 + i][1], voiceover_script[7 + i][2])
                            fourth_voice_section[i] = true

                            if i == #fourth_voice_section then
                                scene_timer:after(wait_time, function()
                                    t13 = false
                                    t14 = true
                                end)
                            end
                        end)

                        break
                    else
                        draw_text(voiceover_script[7 + i][1], voiceover_script[7 + i][2])
                    end
                end
            end
            
            -- bruce dialogue 5:
            if t14 == true and t14_5 == true and t15 == false then
                local dialog1 = dialogue_system.say("Bruce",{bruce_script[5],bruce_script[6], bruce_script[7], bruce_script[8]},{oncomplete = function()
                    t15 = true
                end})

                t14_5 = false
            end

            -- voiceover:
            if t15 == true and t14_5 == false then
                for i = 1, #fifth_voice_section do
                    if fifth_voice_section[i] == false then
                        scene_timer:after((i == 1 and 1 or wait_time), function()

                            draw_text(voiceover_script[9 + i][1], voiceover_script[9 + i][2])
                            fifth_voice_section[i] = true

                            if i == #fifth_voice_section then
                                scene_timer:after(wait_time, function()
                                    t16 = true
                                    t15 = false
                                end)
                            end
                        end)

                        break 
                    else
                        draw_text(voiceover_script[9 + i][1], voiceover_script[9 + i][2])
                    end
                end                      
            end

            -- John dialogue 2:
            if t16 == true and t15 == false and t16_5 == true then
                dialogue_system.titleColor = default_colour
                dialogue_system.messageColor = default_colour

                dialogue_system.say("John",{john_script[2]},{oncomplete = function()
                    t17 = true
                end})

                t16_5 = false
            end

            if t17 == true then
                love.audio.pause()

                love.graphics.setColor(0,0,0)
                love.graphics.rectangle("fill",0,0,width,height)

                love.graphics.setColor(default_colour[1],default_colour[2],default_colour[3])
                draw_text(black_screen_script[1][1], black_screen_script[1][2])

                scene_timer:after(5, function()
                    t17 = false
                    t18 = true
                end)
            else
                if t18 == true then
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("fill", 0, 0, width, height)

                    love.graphics.setColor(default_colour[1], default_colour[2], default_colour[3])

                    draw_text(black_screen_script[3][1], black_screen_script[3][2])
                    draw_heading(black_screen_script[2][1], black_screen_script[2][2])

                    scene_timer:after(5, function()
                        map_sorter.selected_map = "hallway_map1"
                        UI.states.menu_state = "HUD"
                    end)
                end
            end
        end

        function render:update(dt)
            scene_timer:update(dt)
        end

        return render
    end;
}

UI.elements.settings = {
    ["load"] = function()
        love.graphics.setFont(love.graphics.newFont(fonts.default_font), 35)

        settings_menu = component {
            column = true,
            gap = 12
        }

        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        + label {
            text = "SETTINGS";

            width = 200;
            height = 20;

            font = fonts.title_font;
            font_size = 45;

            colour = Hex('#f71616ff');
            opacity = 0.85;
        }
        
        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        + label {
            text = "SHADERS: ON";

            id = "shader_config";

            width = 200;
            height = 20;

            colour = Hex('#C72C41');
            opacity = 1;

            onClick = function()                
                local label = find_element(settings_menu,"shader_config")
                
                settings.shaders_enabled = not settings.shaders_enabled
            end;

            onUpdate = function()
                local label = find_element(settings_menu,"shader_config")

                if settings.shaders_enabled == false then
                    label.text = "SHADERS: OFF"
                else
                    label.text = "SHADERS: ON"
                end
            end;
        }

        + label {
            text = "MUSIC: ON";

            id = "music_config";

            width = 200;
            height = 20;

            colour = Hex('#C72C41');
            opacity = 1;

            onClick = function()                
                local label = find_element(settings_menu,"music_config")

                settings.music_enabled = not settings.music_enabled

                if settings.music_enabled == false then
                    love.audio.pause()
                end
            end;

            onUpdate = function()
                local label = find_element(settings_menu,"music_config")

                if settings.music_enabled == false then
                    label.text = "MUSIC: OFF"
                else
                    label.text = "MUSIC: ON"
                end
            end;
        }

        + label {
            text = "FULLSCREEN: OFF";

            id = "fullscreen_config";

            width = 200;
            height = 20;

            colour = Hex('#C72C41');
            opacity = 1;

            onClick = function()
                local label = find_element(settings_menu,"fullscreen_config")

                love.window.setFullscreen(not love.window.getFullscreen())
            end;

            onUpdate = function()
                local label = find_element(settings_menu,"fullscreen_config")

                if love.window.getFullscreen() == false then
                    label.text = "FULLSCREEN: OFF"
                else
                    label.text = "FULLSCREEN: ON"
                end
            end;
        }

        + label {
            text = "BACK";

            width = 200;
            height = 20;

            colour = Hex('#79585dff');
            opacity = 1;

            onClick = function()
                UI.states.menu_state = "menu"
            end
        }

        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        settings_menu:updatePosition(width * 0.5 - settings_menu.width * 0.5, height * 0.5 - settings_menu.height * 0.5)

        return settings_menu
    end
}

UI.elements.paused_settings = {
    ["load"] = function()

        paused_settings_menu = component {
            column = true,
            gap = 12
        }

        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        + label {
            text = "SETTINGS";

            width = 200;
            height = 20;

            font = fonts.title_font;
            font_size = 45;

            colour = Hex('#f71616ff');
            opacity = 0.85;
        }
        
        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        + label {
            text = "SHADERS: ON";

            id = "shader_config";

            width = 200;
            height = 20;

            font = fonts.default_font;
            font_size = 25;

            colour = Hex('#C72C41');
            opacity = 1;

            onClick = function()                
                local label = find_element(paused_settings_menu,"shader_config")
                
                settings.shaders_enabled = not settings.shaders_enabled
            end;

            onUpdate = function()
                local label = find_element(paused_settings_menu,"shader_config")

                if settings.shaders_enabled == false then
                    label.text = "SHADERS: OFF"
                else
                    label.text = "SHADERS: ON"
                end
            end;
        }

        + label {
            text = "MUSIC: ON";

            id = "music_config";

            width = 200;
            height = 20;

            colour = Hex('#C72C41');
            opacity = 1;

            font = fonts.default_font;
            font_size = 25;

            onClick = function()                
                local label = find_element(paused_settings_menu,"music_config")

                settings.music_enabled = not settings.music_enabled

                if settings.music_enabled == false then
                    love.audio.pause()
                end
            end;

            onUpdate = function()
                local label = find_element(paused_settings_menu,"music_config")

                if settings.music_enabled == false then
                    label.text = "MUSIC: OFF"
                else
                    label.text = "MUSIC: ON"
                end
            end;
        }

        + label {
            text = "FULLSCREEN: OFF";

            id = "fullscreen_config";

            width = 200;
            height = 20;

            colour = Hex('#C72C41');
            opacity = 1;

            font = fonts.default_font;
            font_size = 25;

            onClick = function()
                local label = find_element(paused_settings_menu,"fullscreen_config")

                love.window.setFullscreen(not love.window.getFullscreen())
            end;

            onUpdate = function()
                local label = find_element(paused_settings_menu,"fullscreen_config")

                if love.window.getFullscreen() == false then
                    label.text = "FULLSCREEN: OFF"
                else
                    label.text = "FULLSCREEN: ON"
                end
            end;
        }

        + label {
            text = "BACK";

            width = 200;
            height = 20;

            colour = Hex('#79585dff');
            opacity = 1;

            font = fonts.default_font;
            font_size = 25;

            onClick = function()
                UI.states.game_state = "paused_menu"
            end
        }

        + line {
            width = 250;
            height = 2;

            colour = Hex("#692e2eff");
        }

        paused_settings_menu:updatePosition(width * 0.5 - paused_settings_menu.width * 0.5, height * 0.5 - paused_settings_menu.height * 0.5)

        return paused_settings_menu
    end;
}

UI.elements.paused_menu = {
    ["load"] = function()
            paused_menu = component {
                column = true,
                gap = 12
            } 
            
            + line {
                width = 250,
                height = 2,

                colour = Hex("#692e2eff")
            } 
            
            + label {
                text = "PAUSED",

                width = 200,
                height = 20,

                font = fonts.title_font,
                font_size = 45,

                colour = Hex('#f71616ff'),
                opacity = 0.85
            } 
            
            + line {
                width = 250,
                height = 2,

                colour = Hex("#692e2eff")
            } 
            
            + label {
                text = "RESUME",

                id = "shader_config",

                width = 200,
                height = 20,

                font = fonts.default_font;
                font_size = 25;

                colour = Hex('#C72C41'),
                opacity = 1,

                onClick = function()
                    UI.states.game_state = "playing"
                    player.game_paused = false
                end;
            } 
            
            + label {
                text = "SETTINGS",

                id = "music_config",

                width = 200,
                height = 20,

                font = fonts.default_font;
                font_size = 25;

                colour = Hex('#C72C41'),
                opacity = 1,

                onClick = function()
                    UI.states.game_state = "paused_settings"
                end;
            } 
            
            + label {
                text = "QUIT",

                id = "fullscreen_config",

                width = 200,
                height = 20,

                font = fonts.default_font;
                font_size = 25;

                colour = Hex('#C72C41'),
                opacity = 1,

                onClick = function()
                    love.event.quit()
                end;
            }

            + line {
                width = 250,
                height = 2,

                colour = Hex("#692e2eff")
            }

            paused_menu:updatePosition(width * 0.5 - 350, height * 0.5 - paused_menu.height * 0.5)

            return paused_menu
    end;
}

return UI