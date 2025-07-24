-- https://github.com/tpope/vim-fugitive

local function git_status_tab()
    vim.cmd.tabnew()
    vim.cmd("leftabove vertical G")
    vim.cmd("vertical resize 50")
    vim.cmd.set("wfw")
end

---@type LazyPluginSpec
return {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    ---@type LazyKeysSpec[]
    keys = {
        {
            "<leader>gd",
            vim.cmd.Gvdiffsplit,
            mode = "n",
        },
        {
            "<leader>gc",
            function()
                vim.cmd.G("commit")
            end,
            mode = "n",
        },
        {
            "<leader>ga",
            function()
                vim.cmd.G("commit --amend")
            end,
            mode = "n",
        },
        {
            "<leader>gp",
            function()
                vim.cmd.G("push")
            end,
            mode = "n",
        },
        {
            "<leader>gg",
            toggle_git_status,
            mode = "n",
        },
    },
}
