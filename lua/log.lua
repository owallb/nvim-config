local M = {}

--- Log error message
---@param fmt string
---@param ... any
function M.error(fmt, ...)
    vim.notify(fmt:format(...), vim.log.levels.ERROR)
end

--- Log warning message
---@param fmt string
---@param ... any
function M.warning(fmt, ...)
    vim.notify(fmt:format(...), vim.log.levels.WARN)
end

--- Log info message
---@param fmt string
---@param ... any
function M.info(fmt, ...)
    vim.notify(fmt:format(...), vim.log.levels.INFO)
end

--- Log debug message
---@param fmt string
---@param ... any
function M.debug(fmt, ...)
    vim.notify(fmt:format(...), vim.log.levels.DEBUG)
end

return M
