blight:bind("F1", function()
    blight:send("freeze")
end)

blight:bind("F2", function()
    blight:send("swarm")
end)

blight:bind("F3", function()
    blight:send("nano repair")
end)

blight:bind("F4", function()
    blight:send("eyestrike")
end)

blight:bind("F5", function()
    blight:send("multistrike")
end)

blight:bind("\u{1b}[1;3d", function()
    blight:ui("step_word_left")
end)

blight:bind("\u{1b}[1;3c", function()
    blight:ui("step_word_right")
end)
