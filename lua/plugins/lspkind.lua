-- https://github.com/onsails/lspkind.nvim

local function setup()
    local ok, _ = pcall(require, "nvim-cmp")
    if ok then
        -- configured and loaded in plugins.config.cmp
    else
        require("lspkind").init()
    end
end

return setup
