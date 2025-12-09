dialogue_sorter = {}

dialogue_sorter.intro = {
    ["script"] = {
        {'"Revenge is a dish that tastes best when served cold"', 60};
        {"- Someone who hates a hot revenge dish", 25};
    };
}

dialogue_sorter.office_scene = {
    ["setting"] = "November, 1964. Spring";

    ["voiceover"] = {
        {"Not the most compelling way to start a story, is it?", 250};
        {"Smack in the middle of an office, with no context whatsoever?", 200};
        {"Anyway. I am John, on the right.", 150};
        {"The other guy is Bruce. My contractor.", 100};
        {"See, I wasn't really a house painter.", 250};
        {"And Bruce wasn't really the decent type.", 200};
        {"Quick note. Whenever anybody says they're a little concerned, they are very concerned.", 200};
        {"And when they say they're more than a little concerned, they are desperate.", 250};
        {"But how desperate was Bruce?", 200};
        {"Well... I did say he wasn't the decent type.", 250};
        {[[But I don't know how he went from "fingers pointed at me" to "blow up their house"]], 200};
        {"As long as the pay was good, I'd do the job. What could go wrong?", 150};
    };

    ["Bruce"] = {
        "So, John... I heard you paint houses.";
        "Good to hear. I got a job that you might like...";
        "There's this... competitor, I am a little concerned about.";
        "Actually, I'm more than a little concerned.";
        "Let's say... because of him, there are some fingers pointed at me. I think it's obvious what should be done.";
        "I want you to [REDACTED] his entire [REDACTED] family. Teach that [REDACTED] not mess with me.";
        "[REDACTED] [REDACTED] [REDACTED], and when you get him you [REDACTED] his [REDACTED].";
        "Do whatever you have to do. Blow up their house. Blow them up. What do you say?";
    };

    ["John"] = {
        "You heard right. Quality service.";
        "Yeah... yeah, alright. I'll do it.";
    };

    ["black_screen_script"] = {
        {"And that was the first mistake",200};
        {"1. Another House to Paint", 20};
        {[[Something did go wrong.]],-40};
    };
}

dialogue_sorter.basics = {
    ["script"] = {
        {"I was told that the family was hiding in an old country mansion far west.", 200};
        {"Of course it had to be a mansion.", 150};
        {"Anyway, all I had to do was just find them.", 100};
        {"Did I forget to mention this place had a bunch of hostile lunatics?", 250};
    };

    ["tutorial"] = {
        "W, A, S, D to move";
        "Press F to arm yourself.";
        "LEFT CLICK to shoot";
        "Use your torchlight to weaken enemy senses.";
        "This will deplete your flashlight's battery.";
    };
}

return dialogue_sorter