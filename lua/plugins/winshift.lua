-- https://github.com/sindrets/winshift.nvim

local function setup()
    vim.keymap.set(
        "n",
        "<C-W>m",
        vim.cmd.WinShift
    )
end

return setup
