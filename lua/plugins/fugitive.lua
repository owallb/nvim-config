-- https://github.com/tpope/vim-fugitive

local function setup()
    local function git_status_tab()
        vim.cmd.tabnew()
        vim.cmd("leftabove vertical G")
        vim.cmd("vertical resize 60")
        vim.cmd.set("wfw")
    end

    vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiffsplit)
    vim.keymap.set("n", "<leader>gc", function () vim.cmd.G("commit") end)
    vim.keymap.set("n", "<leader>ga", function () vim.cmd.G("commit --amend") end)
    vim.keymap.set("n", "<leader>gp", function () vim.cmd.G("push") end)

    -- Only used if diffview is not available
    if not pcall(require, "diffview") then
        vim.keymap.set("n", "<leader>gg", git_status_tab)
    end
end

return setup
