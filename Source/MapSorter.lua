map_sorter = {
    ["selected_map"] = nil;

    ["maps"] = {
        ["main_menu"] = {
            ["path"] = "Source/Maps/MainMenu_map.lua";

            ["scaling"] = {0.8, 0.8};
            ["camera_scaling"] = {0.02,0.02};

            ["static"] = true;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = love.audio.newSource("Sound/music/main_menu_theme.mp3", "stream")
        };
        
        ["intro"] = {
            ["path"] = "Source/Maps/Intro_map.lua";

            ["scaling"] = {0.8, 0.8};
            ["camera_scaling"] = {0.02,0.02};

            ["static"] = true;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = love.audio.newSource("Sound/ambience/wind_ambience.mp3", "stream");
        };
        
        ["murder_case1"] = {
            ["path"] = "Source/Maps/murder_scene1_map.lua";

            ["scaling"] = {0.9, 1};
            ["camera_scaling"] = {0.02,0.02};
            
            ["static"] = true;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = nil;
        };
        
        ["murder_case2"] = {
            ["path"] = "Source/Maps/murder_scene2_map.lua";

            ["scaling"] = {0.9, 1};
            ["camera_scaling"] = {0.02,0.02};

            ["static"] = true;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = nil;
        };

        ["murder_case3"] = {
            ["path"] = "Source/Maps/murder_scene3_map.lua";

            ["scaling"] = {0.9, 1};
            ["camera_scaling"] = {0.02,0.02};

            ["static"] = true;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = nil;
        };

        ["office_map"] = {
            ["path"] = "Source/Maps/Office_map.lua";

            ["scaling"] = {0.8, 1};
            ["camera_scaling"] = {0.02,0.02};

            ["static"] = false;

            ["border_collisions"] = {0.15,0.5};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = nil;
            };

            ["music"] = love.audio.newSource("Sound/ambience/rain_ambience.mp3", "stream");
        };
        
        ["hallway_map1"] = {
            ["path"] = "Source/Maps/hallway_map1.lua";

            ["scaling"] = {1, 1};
            ["camera_scaling"] = {0.05,1.58};

            ["static"] = false;

            ["border_collisions"] = {0.05,2.1};

            ["player_y_offset"] = 0;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = nil;
                ["right"] = "floor1_hallway_map";
            };

            ["music"] = love.audio.newSource("Sound/ambience/intro_ambience.mp3", "stream");
        };

        ["floor1_hallway_map"] = {
            ["path"] = "Source/Maps/floor1_hallway_map.lua";

            ["scaling"] = {1, 1};
            ["camera_scaling"] = {0.05,1.58};

            ["static"] = false;

            ["border_collisions"] = {0.05,2.1};

            ["player_y_offset"] = 10;

            ["extras"] = {
                ["enemy_info"] = {
                    {"test1", "normal", "left", {400; 300}};
                    --{"test2", "normal", "left", {700; 300}};
                };
            };

            ["level_load"] = {
                ["left"] = "hallway_map1";
                ["right"] = "floor1_hallway2_map";
            };

            ["music"] = love.audio.newSource("Sound/ambience/intro_ambience.mp3", "stream");
        };

        ["floor1_hallway2_map"] = {
            ["path"] =  "Source/Maps/floor1_hallway2_map.lua";

            ["scaling"] = {1, 1};
            ["camera_scaling"] = {0.05, 1.58};

            ["static"] = false;

            ["border_collisions"] = {0.05, 2.1};

            ["player_y_offset"] = 10;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = "floor1_hallway_map";
                ["right"] = "west_corridor_map";
            };

            ["music"] = nil;
        };

        ["west_corridor_map"] = {
            ["path"] =  "Source/Maps/west_corridor_map.lua";

            ["scaling"] = {1, 1};
            ["camera_scaling"] = {0.05, 0.5};

            ["static"] = false;

            ["border_collisions"] = {0.05, 1};

            ["player_y_offset"] = 10;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = "floor1_hallway2_map";
                ["right"] = "east_corridor_map";
            };

            ["music"] = nil;
        };

        ["east_corridor_map"] = {
            ["path"] =  "Source/Maps/east_corridor_map.lua";

            ["scaling"] = {1, 1};
            ["camera_scaling"] = {0.05, 0.5};

            ["static"] = false;

            ["border_collisions"] = {0.05, 1};

            ["player_y_offset"] = 10;

            ["extras"] = nil;

            ["level_load"] = {
                ["left"] = "west_corridor_map";
                ["right"] = nil;
            };

            ["music"] = nil;
        };
    };
}

return map_sorter