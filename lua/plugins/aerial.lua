---@type LazyPluginSpec
return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        {
            "<leader>ss",
            function()
                require("aerial").toggle({ focus = false, direction = "left" })
            end,
        },
        {
            "gs",
            function()
                require("aerial").focus()
            end,
        },
    },
    opts = {
        layout = {
            max_width = 60,
            min_width = 60,
        },
        attach_mode = "global",
    },
}
