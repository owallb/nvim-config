---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        require("onedark").setup({ style = "darker" })

        local c = require("onedark.colors")
        local highlights = {
            NormalFloat = { bg = c.bg0 },
            FloatBorder = { bg = c.bg0 },
            TabLineSel = { fg = c.fg, bg = c.bg0 },
            EndOfBuffer = { fg = "NONE", bg = "NONE" },
            NvimTreeIndentMarker = { fg = c.bg3 },
            TelescopeBorder = { fg = c.orange },
            TelescopePromptBorder = { fg = c.grey },
            TelescopeResultsBorder = { fg = c.grey },
            TelescopePreviewBorder = { fg = c.grey },
            TreesitterContext = { bg = c.bg1 },
            TreesitterContextLineNumber = { bg = c.bg1 },
            TreesitterContextSeparator = { bg = c.bg1 },
            TreesitterContextBottom = { fmt = "underline", sp=c.grey },
            TreesitterContextLineNumberBottom = { fmt = "underline", sp=c.grey },
            DiffAdd = { bg = "#1e3a2a" },
            DiffChange = { bg = "#15304a" },
            DiffDelete = { bg = "#3d2224" },
        }
        require("onedark").set_options("highlights", highlights)

        require("onedark").colorscheme()
    end,
}
