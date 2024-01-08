-- https://github.com/nvim-lualine/lualine.nvim

local function setup()
    require("lualine").setup({
        options = {
            icons_enabled = true,
            theme = "auto",
            component_separators = { left = "", right = "", },
            section_separators = { left = "", right = "", },
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                "mode",
                { "filename",    path = 1, },
                "diff",
                { "diagnostics", sources = { "nvim_lsp", }, },
                {
                    function ()
                        local key = require("grapple").key()
                        return "  [" .. key .. "]"
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
