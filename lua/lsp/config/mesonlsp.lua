---@type ServerConfig
return {
    enable = true,
    mason = { "mesonlsp" },
    lspconfig = {
        ---@type fun(filename: string, bufnr: number): string?
        root_dir = function(filename, bufnr)
            local parent = require("lspconfig").util.find_git_ancestor(filename)
            if not parent then
                local win = vim.fn.bufwinid(bufnr)
                parent = vim.fn.getcwd(win)
            end
            return parent
        end,
        settings = {
            others = {
                disableInlayHints = true,
            },
        },
    },
}
