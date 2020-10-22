local mod = {}

mod.windups = {
    "^The rotors on a malfunctioning windmill drone begin to whir faster and faster, until they are blurry with dangerous speed\\.$"
}

function mod.windupWarning()
    blight:output(C_BRED .. "\u{001b}[1m!!! WINDUP !!!" .. C_RESET)
end

local function onWindup()
    mod.windupWarning()
    blight:send("eyestrike")
end

for _, windup in pairs(mod.windups) do
    blight:add_trigger(windup, {}, onWindup)
end

return mod
