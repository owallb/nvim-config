---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        require("onedark").setup({ style = "darker" })

        local c = require("onedark.colors")
        local highlights = {
            ["@string.special.url"] = { fg = "NONE", fmt = "NONE" },
            Cursor = { fg = c.bg, bg = c.fg, fmt = "NONE" },
            NormalFloat = { bg = c.bg0 },
            FloatBorder = { bg = c.bg0 },
            TabLineSel = { fg = c.fg, bg = c.bg0 },
            EndOfBuffer = { fg = "NONE", bg = "NONE" },
            NvimTreeIndentMarker = { fg = c.bg3 },
            TelescopeBorder = { fg = c.orange },
            TelescopePromptBorder = { fg = c.grey },
            TelescopeResultsBorder = { fg = c.grey },
            TelescopePreviewBorder = { fg = c.grey },
            TreesitterContextBottom = { fmt = "underline", sp = c.bg3 },
            TreesitterContextLineNumberBottom = {
                fmt = "underline",
                sp = c.bg3,
            },
            DiffAdd = { bg = "#1e3a2a" },
            DiffChange = { bg = "#15304a" },
            DiffDelete = { bg = "#3d2224" },
        }
        require("onedark").set_options("highlights", highlights)
        require("onedark").load()
    end,
}
