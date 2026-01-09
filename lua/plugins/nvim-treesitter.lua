-- https://github.com/nvim-treesitter/nvim-treesitter

local languages = {
    "dap_repl",
    "bash",
    "zsh",
    "python",
    "c",
    "cpp",
    "lua",
    "luadoc",
    "vim",
    "vimdoc",
    "php",
    "phpdoc",
    "rust",
    "comment",
    "gitcommit",
}

---@type LazyPluginSpec
return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
        local ts = require("nvim-treesitter")
        ts.install(languages):await(ts.update)
    end,
    dependencies = {
        {
            "LiadOz/nvim-dap-repl-highlights",
            config = true,
        },
    },
    config = function()
        local filetypes = {}
        for _, lang in ipairs(languages) do
            for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
                if not vim.list_contains(filetypes, ft) then
                    table.insert(filetypes, ft)
                end
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = filetypes,
            callback = function()
                vim.treesitter.start()
                vim.wo.foldmethod = "expr"
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end,
        })
    end,
}
