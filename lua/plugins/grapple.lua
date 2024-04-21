-- https://github.com/cbochs/grapple.nvim

---@type LazyPluginSpec
return {
    "cbochs/grapple.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local grapple = require("grapple")
        grapple.setup()
        vim.keymap.set("n", "<leader>'", grapple.toggle_tags)
        vim.keymap.set("n", "<leader>mm", function()
            if grapple.exists() then
                grapple.untag()
                return
            end

            for i = 1, 9 do
                local opts = { name = "m" .. i }
                if not grapple.exists(opts) then
                    grapple.tag(opts)
                    return
                end
            end

            grapple.tag({ name = "m0" })
        end)

        for i = 1, 9 do
            local opts = { name = "m" .. i }

            vim.keymap.set("n", "<leader>m" .. i, function()
                grapple.tag(opts)
            end)

            vim.keymap.set("n", "<leader>" .. i, function()
                grapple.select(opts)
            end)
        end
    end,
}
