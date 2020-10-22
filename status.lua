local gmcp = require("gmcp")
local targets = require("targets")

local mod = {}

mod.ship_stats = {}
mod.hack_stats = {}
mod.prompt_type = "char"

local function formatStat(value, max)
    local color
    value = tonumber(value)
    max = tonumber(max)
    if value < 0.3 * max then
        color = C_BRED
    elseif value < 0.7 * max then
        color = C_BYELLOW
    else
        color = C_GREEN
    end
    return color .. value .. "/" .. max .. C_RESET
end

local function formatPercent(value)
    local color
    value = tonumber(value) or 0
    if value < 30 then
        color = C_RED
    elseif value < 70 then
        color = C_BYELLOW
    else
        color = C_GREEN
    end
    return color .. value .. C_RESET
end

function mod.setPrompt(prompt)
    mod.prompt_type = prompt
    if mod.prompt_type ~= "char" then
        targets.inhibit("prompt")
    else
        targets.uninhibit("prompt")
    end
end

function mod.updateStatus()
    local line
    if mod.prompt_type == "char" then
        local vitals = gmcp.GMCP.char.vitals
        if not vitals.hp then return end
        local target_part = ""
        if targets.target.id ~= "" then
            targets.fixTargetIdx()
            target_part = string.format(" | Target(%d/%d): %s (%s)",
                    targets.target_idx,
                    #targets.targets,
                    targets.target.short_desc,
                    targets.target.hpperc)
        end
        local balance_part = "*"
        if gmcp.GMCP.char.vitals.bal == "1" then
            balance_part = "B"
        end
        line = C_WHITE .. string.format(" %s | Health: %s (%s%%) | NN: %s | Sanity: %s%s",
                balance_part,
                formatStat(vitals.hp, vitals.maxhp),
                formatPercent(vitals.hp / vitals.maxhp * 100),
                formatStat(vitals.nn, vitals.maxnn),
                formatStat(vitals.sa, vitals.maxsa),
                target_part)
    elseif mod.prompt_type == "ship" then
        line = C_WHITE .. string.format(" Speed: %s (%d%%) | Hull: %s%% | Shield: %s%% | Cap: %s%% | %s",
                mod.ship_stats.speed or "",
                mod.ship_stats.maxspeed or 0,
                formatPercent(mod.ship_stats.hull),
                formatPercent(mod.ship_stats.shield),
                formatPercent(mod.ship_stats.cap),
                mod.ship_stats.sector or "")
    elseif mod.prompt_type == "hack" then
        line = C_WHITE .. string.format(" %s | GigaOps: %d/%d | Password: %s",
                mod.hack_stats.sync,
                mod.hack_stats.ops,
                mod.hack_stats.opsmax,
                mod.hack_stats.password)
    end

    blight:status_line(0, line)
end

blight:add_trigger("^\\[ ([S*]) \\| GigaOps: (\\d+)/(\\d+) \\| Password: ([A-Z*]+) \\]", {prompt = true, gag = true}, function(matches)
    if mod.prompt_type == "char" then
        mod.prompt_type = "hack"
    end

    mod.hack_stats.sync = matches[2]
    mod.hack_stats.ops = tonumber(matches[3])
    mod.hack_stats.opsmax = tonumber(matches[4])
    mod.hack_stats.password = matches[5]

    mod.updateStatus()
end)

blight:add_trigger("^\\[ Speed: ([^\\(]+) \\((\\d+)%\\) \\| Hull: (\\d+)% \\| Shield: (\\d+)% \\| Cap: (\\d+)% \\| ([^\\]]+)", {prompt = true, gag = true}, function(matches)
    if mod.prompt_type == "char" then
        mod.prompt_type = "ship"
    end
    mod.ship_stats.speed = matches[2]
    mod.ship_stats.maxspeed = tonumber(matches[3])
    mod.ship_stats.hull = tonumber(matches[4])
    mod.ship_stats.shield = tonumber(matches[5])
    mod.ship_stats.cap = tonumber(matches[6])
    mod.ship_stats.sector = matches[7]
    mod.updateStatus()
end)

blight:add_alias("^/prompt (.*)$", function(matches)
    mod.prompt_type = matches[2]
    mod.updateStatus()
end)

gmcp.listen("Char.Vitals", function(_)
    mod.updateStatus()
end)

gmcp.listen("IRE.Target.Set", function(_)
    mod.updateStatus()
end)

gmcp.listen("IRE.Target.Info", function(_)
    mod.updateStatus()
end)

return mod
