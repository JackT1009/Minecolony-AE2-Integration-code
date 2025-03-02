local config = require("config")
local TaskScheduler = {
    queue = {},
    active_tasks = 0
}

function TaskScheduler.add(task)
    table.insert(TaskScheduler.queue, task)
end

function TaskScheduler.run()
    while #TaskScheduler.queue > 0 and TaskScheduler.active_tasks < 2 do
        local task = table.remove(TaskScheduler.queue, 1)
        TaskScheduler.active_tasks = TaskScheduler.active_tasks + 1
        parallel.waitForAny(function()
            task.fn(unpack(task.args))
            TaskScheduler.active_tasks = TaskScheduler.active_tasks - 1
        end)
    end
end
