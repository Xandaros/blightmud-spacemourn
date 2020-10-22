local windows = require("windows")

local mod = {}

mod.starchartOpen = false
mod.starchartBalanceGag = nil
mod.starchartTarget = ""

function mod.toggleStarchart()
    if mod.starchartOpen then
        core:exec("tmux kill-pane -t 1")
        if mod.starchartBalanceGag then
            blight:remove_trigger(mod.starchartBalanceGag)
            mod.starchartBalanceGag = nil
        end
    else
        core:exec("tmux split-pane -h -l 58 \"watch -c -t -n 0.1 cat windows/starchart\"")
        core:exec("tmux select-pane -t 0")
        mod.starchartBalanceGag = blight:add_trigger("^You have recovered your balance.", {gag = true}, function() end)
    end
    mod.starchartOpen = not mod.starchartOpen
end

blight:add_timer(5, 0, function()
    if not mod.starchartOpen then return end
    if not windows.window == "main" then return end
    local f = io.open("windows/starchart", "w")
    local trigger = blight:add_trigger("^[^\\s]+", {gag = true, raw = true}, function(matches)
        if matches[1]:sub(1,3) == "Map" then return end
        if matches[1]:sub(8,10) == "You" then return end
        if matches[1]:sub(15,21) == "Balance" then return end
        f:write(matches[1] .. "\n")
    end)
    blight:add_trigger("^Balance used", {gag = true, count = 1}, function()
        blight:remove_trigger(trigger)
        f:close()
    end)
    blight:send("starchart " .. mod.starchartTarget, {gag = true, skip_log = true})
end)

blight:add_alias("^/starchart ?(.*)$", function(matches)
    mod.starchartTarget = matches[2]
    mod.toggleStarchart()
end)

return mod
