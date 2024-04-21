-- https://github.com/nvim-lualine/lualine.nvim

---@type LazyPluginSpec
return {
    "nvim-lualine/lualine.nvim",
    lazy = true,
    event = "VimEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local custom_moonfly = require("lualine.themes.moonfly")
        custom_moonfly.normal.c.bg = require("moonfly").palette.bg

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = custom_moonfly,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    { "filename",                    path = 1 },
                    { "diff" },
                    { "diagnostics",                 sources = { "nvim_lsp" } },
                    { require("grapple").statusline, cond = require("grapple").exists },
                },
                lualine_x = {
                    "bo:filetype",
                    "encoding",
                    "bo:fileformat",
                    "progress",
                    "location",
                },
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
