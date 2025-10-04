-- https://github.com/rcarriga/nvim-notify

---@type LazyPluginSpec
return {
    "rcarriga/nvim-notify",
    priority = 900,
    lazy = false,
    opts = {
        render = "default",
        stages = "static",
    },
    config = function(_, opts)
        ---@type notify
        vim.notify = require("notify")
        vim.notify.setup(opts)
    end,
}
