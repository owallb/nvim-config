local function setup()
    require("colorizer").setup({
        user_default_options = {
            RRGGBBAA = true,
            AARRGGBB = true,
            css = true,
            mode = "virtualtext",
            tailwind = true,
            sass = { enable = true, },
        },
    })
end

return setup
