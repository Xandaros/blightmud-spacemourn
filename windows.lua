local gmcp = require("gmcp")
local status = require("status")

local mod = {}

mod.window = "main"
mod.handle = nil

local writer_trigger

function mod.selectWindow(w)
    mod.window = w
    if mod.window ~= "main" then
        mod.handle = io.open("windows/" .. mod.window, "w")
        writer_trigger = blight:add_trigger(".*", {raw = true}, function(matches)
            if matches[1]:sub(1, 10) == "Location: " then
                blight:gag()
                return
            end
            if mod.window ~= "main" then
                blight:gag()
                mod.handle:write(matches[1] .. "\n")
            end
        end)
    else
        if mod.handle ~= nil then
            mod.handle:close()
        end
        mod.handle = nil
        blight:remove_trigger(writer_trigger)
        writer_trigger = nil
    end
end

gmcp.listen("Redirect.Window", function(w)
    if mod.window ~= "main" and mod.window ~= "map" then
        blight:output("Selecting window: " .. w)
    end
    mod.selectWindow(w)
    if mod.window == "map" then
        status.setPrompt("char")
    end
end)

gmcp.listen("IRE.Display.Ohmap", function(data)
    if data == "start" then
        mod.selectWindow("map")
    else
        mod.selectWindow("main")
    end
end)

blight:add_trigger("^This room has not been mapped.$", {gag = true}, function()
    local f = io.open("windows/map", "w")
    f:close()
end)

return mod
