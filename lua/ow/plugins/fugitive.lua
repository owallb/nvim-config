-- https://github.com/tpope/vim-fugitive

local function open_git_status()
    local previous_win = vim.api.nvim_get_current_win()
    vim.cmd("leftabove vertical G")
    vim.api.nvim_win_set_width(0, 50)
    vim.api.nvim_set_option_value("winfixwidth", true, { scope = "local" })
    vim.api.nvim_set_current_win(previous_win)
end

local function get_git_status_win()
    local current_tabpage = vim.api.nvim_get_current_tabpage()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tabpage)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
        if
            buftype == "nowrite"
            and vim.api.nvim_buf_get_name(buf):match("^fugitive://.*%.git//$")
        then
            return win
        end
    end
end

local function toggle_git_status()
    local win = get_git_status_win()
    if win then
        vim.api.nvim_win_close(win, false)
        return
    end

    open_git_status()
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
    config = function()
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                vim.fn["fugitive#ReloadStatus"]()
            end,
        })
    end,
}
