local function setup()
    require("ibl").setup({
        enabled = true,
        scope = {
            enabled = false,
            show_start = false,
            show_end = false,
        },
    })
end

return setup
