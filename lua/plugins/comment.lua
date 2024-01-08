-- https://github.com/numToStr/Comment.nvim

local function setup()
    require("Comment").setup(
        {
            --ignore empty lines
            ignore = "^$",
        }
    )
end

return setup
