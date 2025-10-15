vim.loader.enable()

local log = require("log")

local files = {
    "globals",
    "options",
    "autocommands",
    "commands",
    "mappings",
}

for _, file in ipairs(files) do
    local pkg = "core." .. file
    local ok, err = pcall(require, pkg)
    if not ok then
        log.error("Error while loading package " .. pkg)
        log.error(err)
        return
    end
end

local ok, err = pcall(require, "bootstrap")
if not ok then
    log.error("Error during bootstrap")
    log.error(err:gsub("\t", "  "))
    return
end

---@type LazyConfig
local opts = {
    install = {
        colorscheme = { "onedark" },
    },
    ui = {
        icons = {
            cmd = "",
            config = "",
            event = "",
            favorite = "",
            ft = "",
            init = "",
            import = "",
            keys = "",
            lazy = "",
            loaded = "",
            not_loaded = "",
            plugin = "",
            runtime = "",
            require = " ",
            source = "",
            start = "",
            task = "",
            list = {
                "",
                "",
                "",
                "",
            },
        },
    },
}

require("lazy").setup("plugins", opts)
