---@type LazyPluginSpec
return {
    "stevearc/oil.nvim",
    keys = {
        {
            "<leader>fe",
            function()
                vim.cmd.Oil("--float")
            end,
            mode = "n",
        },
    },
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = false,
        columns = {
            -- "icon",
            "permissions",
            "size",
            "mtime",
        },
        delete_to_trash = true,
        float = {
            max_width = 80,
            max_height = 20,
        },
        skip_confirm_for_simple_edits = true,
        watch_for_changes = false,
        keymaps = {
            ["<Esc>"] = "actions.close",
            ["q"] = "actions.close",
            ["<C-s>"] = false,
            ["<C-h>"] = "actions.parent",
            ["<C-l>"] = "actions.select",
            ["<C-r>"] = "actions.refresh",
        },
        view_options = {
            show_hidden = true,
            natural_order = false,
        },
        win_options = {
            colorcolumn = "",
        },
    },
}
