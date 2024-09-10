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
            padding = 10,
            max_width = 80,
        },
        skip_confirm_for_simple_edits = true,
        watch_for_changes = false,
        keymaps = {
            ["q"] = "actions.close",
            ["<C-s>"] = false,
            ["<C-l>"] = false,
            ["<C-r>"] = "actions.refresh",
            ["<S-h>"] = "actions.parent",
            ["<S-l>"] = "actions.select",
        },
        view_options = {
            show_hidden = true,
            natural_order = false,
        },
    },
}
