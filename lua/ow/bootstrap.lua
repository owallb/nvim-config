local version = vim.version()

if version.major == 0 then
    if version.minor < 11 then
        error("Neovim version 0.11 or above is required with this configuration.")
    end
end

local util = require("ow.util")

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    util.assert_installed("git")
    if not os.getenv("CC") then
        util.assert_installed("cc")
    end
    util.assert_installed("make")
    util.assert_any_installed({ "curl", "wget", })
    util.assert_installed("unzip")
    util.assert_installed("tar")
    util.assert_installed("gzip")

    local resp = vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }):wait()

    assert(resp.code == 0, "Failed to download lazy")
end
vim.opt.rtp:prepend(lazypath)
