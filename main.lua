package.path = "/home/xandaros/mud/starmourn/scripts/?.lua;" .. package.path

require("bindings")
local gmcp = require("gmcp")
local status = require("status")
local targets = require("targets")
local tasks = require("tasks")
local windows = require("windows")
local windup = require("windup")

_G.my = {
    gmcp = gmcp,
    status = status,
    targets = targets,
    tasks = tasks,
    windows = windows,
    windup = windup
}

core:exec("tmux split-window -h -l 41 \"watch -c -t -n 0.1 cat windows/map\"")
core:exec("tmux split-window -v \"watch -c -t -n 0.1 cat windows/tasks\"")
core:exec("tmux resize-pane -t 1 -y 40")
core:exec("tmux select-pane -t 0")


blight:add_trigger("^Please enter the name of your Starmourn character.", {}, function()
    local credentials = require("credentials")
    blight:add_timer(0.3, 1, function()
        gmcp.send("Char.Login " .. json.encode(credentials))
    end)
end)

blight:add_alias("^/reload$", function(_)
    core:exec("tmux kill-pane -a -t 0")
    blight:reset()
    blight:load("~/.config/blightmud/dispatcher.lua")
    blight:load("~/mud/starmourn/scripts/main.lua")
    gmcp.send("IRE.Tasks.Request")
end)
