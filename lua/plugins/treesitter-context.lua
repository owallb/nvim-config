-- https://github.com/nvim-treesitter/nvim-treesitter-context

local function setup()
    require("treesitter-context").setup({
        max_lines = 1,
        min_window_height = 10,
    })
end

return setup
