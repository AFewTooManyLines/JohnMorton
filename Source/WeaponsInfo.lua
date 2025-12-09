weapons = {}

weapons.revolver = {
    ["firerate"] = 1;
    ["max_ammo"] = 30;
    ["max_loaded"] = 6;

    ["current_stored_ammo"] = 12;
    ["current_loaded_ammo"] = 6;
    
    ["damage_values"] = {
        9;
        10;
        13;
        6;
        12;
    };

    ["icon"] = love.graphics.newImage("Assets/episode1/Images/revolver_icon.png");

    ["shake_strength"] = 25;
    ["recoil"] = 18;

    ["shoot_sound"] = "Sound/gunshot.mp3";
    ["sound_volume"] = 0.2;

    ["crosshair_radius"] = 5;

    ["animations"] = {

        ["moving"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_GunAndTorch_Right.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_GunAndTorch_Left.png");
        };

        ["shooting"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/HandgunShootRight.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/HandgunShootLeft.png");
        };
    };
}

weapons.sawed_off_shotgun = {
    ["firerate"] = 1;
    ["max_ammo"] = 12;
    ["max_loaded"] = 2;

    ["current_stored_ammo"] = 12;
    ["current_loaded_ammo"] = 2;

    ["damage_values"] = {
        15;
        12;
        20;
        25;
        29;
    };

    ["icon"] = love.graphics.newImage("Assets/episode1/Images/revolver_icon.png");

    ["shake_strength"] = 38;
    ["recoil"] = 30;

    ["shoot_sound"] = "Sound/shotgun.mp3";
    ["sound_volume"] = 0.6;

    ["crosshair_radius"] = 9;

    ["animations"] = {

        ["moving"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_TorchAndShotgun_Right.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/JohnMorton_TorchAndShotgun_Left.png");
        };

        ["shooting"] = {
            ["right"] = love.graphics.newImage("Source/Spritesheets/ShotgunShootRight.png");
            ["left"] = love.graphics.newImage("Source/Spritesheets/ShotgunShootLeft.png");
        };
    };
}

return weapons