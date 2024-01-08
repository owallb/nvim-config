-- https://github.com/nvim-lualine/lualine.nvim

local function setup()
    local custom_moonfly = require("lualine.themes.moonfly")
    custom_moonfly.normal.c.bg = "#000000"

    require("lualine").setup({
        options = {
            icons_enabled = true,
            theme = custom_moonfly,
            component_separators = { left = "", right = "", },
            section_separators = { left = "", right = "", },
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                { "filename",    path = 1, },
                "diff",
                { "diagnostics", sources = { "nvim_lsp", }, },
                {
                    function ()
                        local key = require("grapple").key()
                        return "[" .. key .. "]"
                    end,
                    cond = require("grapple").exists,
                },
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
end

return setup
