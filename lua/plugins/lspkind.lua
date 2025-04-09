-- https://github.com/onsails/lspkind.nvim

---@type LazyPluginSpec
return {
    "onsails/lspkind.nvim",
    enabled = true,
    config = function() require("lspkind").init() end,
}
