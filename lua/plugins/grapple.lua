-- https://github.com/cbochs/grapple.nvim

local function setup()
    local grapple = require("grapple")
    grapple.setup()
    vim.keymap.set("n", "<leader>'", grapple.popup_tags)
    for i = 1, 9 do
        vim.keymap.set("n", "<leader>m" .. i, function ()
            grapple.tag({ key = "m" .. i, })
        end)
        vim.keymap.set("n", "<leader>" .. i, function ()
            grapple.select({ key = "m" .. i, })
        end)
    end
end

return setup
