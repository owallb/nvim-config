-- https://github.com/NvChad/nvim-colorizer.lua

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
    opts = {
        default_file_explorer = true,
        columns = {
            -- "icon",
            "permissions",
            "size",
            "mtime",
        },
        constrain_cursor = "name",
        delete_to_trash = true,
        float = {
            max_width = 80,
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
