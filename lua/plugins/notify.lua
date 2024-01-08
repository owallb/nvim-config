-- https://github.com/rcarriga/nvim-notify

local function setup()
    local has_telescope, telescope = pcall(require, "telescope")

    local notify = require("notify")
    notify.setup({
        render = "default",
        stages = "static",
    })

    vim.notify = notify

    if has_telescope then
        telescope.load_extension("notify")
        vim.keymap.set("n", "<leader>fn", telescope.extensions.notify.notify)
    end
end

return setup
