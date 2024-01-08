-- https://github.com/simeji/winresizer

local function setup()
    vim.g.winresizer_vert_resize = "5"
    vim.g.winresizer_horiz_resize = "5"
    vim.g.winresizer_start_key = ""

    vim.keymap.set("n", "<C-W>r", vim.cmd.WinResizerStartResize)
end

return setup
