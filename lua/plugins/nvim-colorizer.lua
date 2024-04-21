-- https://github.com/NvChad/nvim-colorizer.lua

---@type LazyPluginSpec
return {
    "NvChad/nvim-colorizer.lua",
    opts = {
        user_default_options = {
            RRGGBBAA = true,
            AARRGGBB = true,
            css = true,
            mode = "virtualtext",
            tailwind = true,
            sass = { enable = true },
        },
    },
}
