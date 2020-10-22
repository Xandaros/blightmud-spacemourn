local mod = {}

mod.actions = {}
mod.running = false

local function runActions()
    if mod.running then return end
    if #mod.actions == 0 then return end
    mod.running = true

    local output = {}
    local running = true

    local action = table.remove(mod.actions, 1)
    local trigger = blight:add_trigger(action.regex, {gag = action.gag}, function(matches)
        output[#output + 1] = matches
    end)
    local stop_trigger
    stop_trigger = blight:add_trigger(action.stop, {gag = action.gag, count = 1}, function(_)
        blight:remove_trigger(trigger)
        running = false
        stop_trigger = nil
        trigger = nil

        if not pcall(action.cb, output, true) then
            blight:output("Error in callback")
        end

        mod.running = false
        runActions()
    end)
    if action.timeout > 0 then
        blight:add_timer(action.timeout, 1, function()
            if not running then return end
            blight:remove_trigger(trigger)
            trigger = nil
            if stop_trigger then
                blight:remove_trigger(stop_trigger)
            end

            if not pcall(action.cb, output, false) then
                blight:output("Error in callback")
            end

            mod.running = false
            runActions()
        end)
    end
    blight:send(action.cmd)
end

function mod.listen(cmd, stop, cb, options)
    options = options or {}
    local gag = options.gag
    local regex = options.regex or ".*"
    local timeout = options.timeout or 1

    mod.actions[#mod.actions + 1] = {cmd = cmd, stop = stop, cb = cb, regex = regex, gag = gag, timeout = timeout}
    runActions()
end

return mod
