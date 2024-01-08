-- https://github.com/famiu/bufdelete.nvim

local function setup()
    vim.keymap.set(
        "n",
        "<C-w>q",
        vim.cmd.Bwipeout,
        { remap = false, silent = true, }
    )
end

return setup
