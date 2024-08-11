---@type LazyPluginSpec
return {
    "wellle/context.vim",
    event = "VimEnter",
    init = function()
        vim.g.context_enabled = true
        vim.g.context_add_mappings = true
        vim.g.context_add_autocmds = true
        vim.g.context_presenter = "nvim-float"
        vim.g.context_max_height = 10
        vim.g.context_ellipsis_char = "·"
        vim.g.context_border_char = "━"
        vim.g.context_highlight_normal = "TreesitterContext"
        vim.g.context_highlight_border = "<hide>"
        vim.g.context_highlight_tag = "<hide>"
    end,
}
