-- https://github.com/famiu/bufdelete.nvim

---@type LazyPluginSpec
return {
    "famiu/bufdelete.nvim",
    keys = {
        { "<C-w>q", vim.cmd.Bwipeout, { remap = false, silent = true }, mode = "n" },
    },
}
