local gmcp = require("gmcp")
local outputlistener = require("outputlistener")

local mod = {}

mod.target = {id = "", short_desc = "", hpperc = ""}
mod.targets = {}
mod.target_idx = 1
mod.inhibitors = {}

local health_indicators = {
    "healthy",
    "wounded",
    "maimed",
    "critically wounded"
}

function mod.fixTargetIdx()
    if not mod.target.id then return end
    for i, t in ipairs(mod.targets) do
        if string.match(t, mod.target.id) then
            mod.target_idx = i
            return
        end
    end
end

function mod.send()
    local t = mod.targets[mod.target_idx]
    if t then
        gmcp.send("IRE.Target.Set \"" .. t .. "\"")
    end
    blight:add_trigger("^.*$", {gag = true, count = 1, prompt = true}, function() end)
    blight:send("", {gag = true, skip_log = true})
end

function mod.previous()
        mod.target_idx = mod.target_idx - 1
    if mod.target_idx < 1 then
        mod.target_idx = #mod.targets
    end
    mod.send()
end

function mod.next()
    if mod.target.id == "" or not mod.target.id then
        mod.send()
        return
    end
    mod.target_idx = mod.target_idx + 1
    if mod.target_idx > #mod.targets then
        mod.target_idx = 1
    end
    mod.send()
end

function mod.uninhibit(inhibitor)
    mod.inhibitors[inhibitor] = nil
end

function mod.inhibit(inhibitor)
    mod.inhibitors[inhibitor] = true
end

function mod.updateTargets()
    if #mod.inhibitors > 0 then return end
    mod.targets = {}
    mod.target_idx = 1

    outputlistener.listen("info here", "^Total: |Error", function(matches)
        for _, match in ipairs(matches) do
            for _, indicator in ipairs(health_indicators) do
                if string.find(match[3], "%(" .. indicator .. "%)") then
                    mod.targets[#mod.targets + 1] = match[2]
                    break
                end
            end
        end
    end, {gag = true, regex = "^([a-zA-Z]+[0-9]+)\\s+(.*)$"})
end

blight:bind("\x1b[1;5D", function()
    mod.previous()
end)

blight:bind("\x1b[1;5C", function()
    mod.next()
end)

gmcp.listen("Room.Info", function()
    mod.updateTargets()
end)

gmcp.listen("IRE.Target.Info", 4, function(data)
    if data.id == "" then
        mod.target = data
        mod.updateTargets()
        return
    end
    mod.target.id = data.id
    mod.target.hpperc = data.hpperc
    if data.short_desc then
        mod.target.short_desc = data.short_desc
    end
end)

gmcp.listen("IRE.Target.Set", 4, function(data)
    if data == "" then
        mod.target = {id = "", short_desc = "", hpperc = ""}
        mod.updateTargets()
    end
end)
return mod
