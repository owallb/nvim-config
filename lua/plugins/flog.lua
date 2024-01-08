-- https://github.com/rbong/vim-flog

local function setup()
    vim.keymap.set("n", "<leader>gl", vim.cmd.Flog)
end

return setup
