local gmcp = require("gmcp")

local mod = {}

mod.tasks = {}
mod.active_task = nil

function mod.updateTasks()
    local f = io.open("windows/tasks", "w")
    for _, task in pairs(mod.tasks) do
        if task.type == "quests" and task.status == "0" then
            f:write("[" .. task.id .. "] " .. task.name .. "\n")
            if task.id == mod.active_task then
                for line in string.gmatch(task.desc, "[^\n]+") do
                    f:write("\t" .. line .. "\n")
                end
            end
        end
    end
    f:close()
end

blight:add_alias("^/task (\\d+)$", function(matches)
    mod.active_task = matches[2]
    mod.updateTasks()
end)

blight:add_alias("^/task$", function(_)
    mod.active_task = nil
    mod.updateTasks()
end)

gmcp.listen("IRE.Tasks.List", function(data)
    mod.tasks = {}
    for _, task in ipairs(data) do
        mod.tasks[task.id] = task
    end
    mod.updateTasks()
end)

gmcp.listen("IRE.Tasks.Update", function(data)
    for _, task in ipairs(data) do
        mod.tasks[task.id] = task
    end
    mod.updateTasks()
end)

gmcp.listen("IRE.Tasks.Completed", function(_)
    mod.updateTasks()
end)

return mod
