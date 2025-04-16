-- https://github.com/onsails/lspkind.nvim

---@type LazyPluginSpec
return {
    "onsails/lspkind.nvim",
    config = function()
        local ok, _ = pcall(require, "nvim-cmp")
        if not ok then
            require("lspkind").init()
        end
    end,
}
