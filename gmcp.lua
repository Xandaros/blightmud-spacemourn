local mod = {}
setmetatable(mod, {__index = gmcp})

mod.GMCP = {
    char = {
        vitals = {}
    }
}

mod.listeners = {}

function mod.listen(s, priority, cb)
    if not priority then
        priority = 3
    end
    if type(priority) == "function" then
        cb = priority
        priority = 3
    end
    mod.listeners[s] = mod.listeners[s] or {{}, {}, {}, {}, {}}
    local tbl = mod.listeners[s][priority]
    tbl[#tbl + 1] = cb
end

local function register_listener(s)
    gmcp.receive(s, function(encoded_data)
        if not mod.listeners[s] then return end
        local data = json.decode(encoded_data)
        for i = 5, 1, -1 do
            for _, cb in pairs(mod.listeners[s][i]) do
                cb(data)
            end
        end
    end)
end

local gmcp_modules = {
    "Char",
    "Comm",
    "Comm.Channel",
    "Room",
    "IRE",
    "IRE.Target",
    "IRE.Tasks",
    "IRE.Sound",
    "IRE.Display",
    "Redirect"
}

local gmcp_messages = {
    "Char.Vitals",
    "Comm.Channel.List",
    "Comm.Channel.Text",
    "Redirect.Window",
    "Room.Info",
    "IRE.Tasks.List",
    "IRE.Tasks.Update",
    "IRE.Tasks.Completed",
    "IRE.Sound.Preload",
    "IRE.Sound.Play",
    "IRE.Display.Ohmap",
    "IRE.Target.Info",
    "IRE.Target.Set",
    "IRE.Target.Request"
}

mod.listen("Char.Vitals", function(data)
    mod.GMCP.char.vitals = data
end)

gmcp.on_ready(function()
    blight:output("GMCP enabled")

    for _, module in pairs(gmcp_modules) do
        gmcp.register(module)
    end

    for _, message in pairs(gmcp_messages) do
        register_listener(message)
    end

    --[[
    gmcp.receive("Comm.Channel.List", function(encoded_data)
        -- blight:output("Comm.Channel.List " .. encoded_data)
        -- Comm.Channel.List  [ { "name": "newbie", "caption": "Newbie", "command": "newbie" }, { "name": "ft", "caption": "Song", "command": "ft" } ]
    end)
    gmcp.receive("Comm.Channel.Text", function(encoded_data)
       --  blight:output("Comm.Channel.Text " .. encoded_data)
        -- Comm.Channel.Text  { "channel": "newbie", "talker": "Isabella", "text": "\u001b[0;1;32m(Newbie): Isabella says, \"Sure :)\"\u001b[0;37m", "raw": "Sure :)" }
        -- { "channel": "say", "talker": "Yiraet", "text": "\u001b[0;1;36mYou say, \"Test.\"\u001b[0;37m", "raw": "Test." }
    end)
    gmcp.receive("IRE.Sound.Preload", function(encoded_data)
        blight:output("IRE.Sound.Preload " .. encoded_data)
    end)
    gmcp.receive("IRE.Sound.Play", function(encoded_data)
        blight:output("IRE.Sound.Play " .. encoded_data)
    end)
    gmcp.receive("IRE.Target.Request", function(encoded_data)
        blight:output("IRE.Target.Request " .. encoded_data)
    end)
    ]]
end)

return mod
